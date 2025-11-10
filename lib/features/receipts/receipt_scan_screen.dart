// lib/features/receipts/receipt_scan_screen.dart
import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Mobile OCR libs (safe to import on desktop; only used on mobile)
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanScreen extends StatefulWidget {
  static const route = "/receipt_scan";
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  String? _merchant;
  DateTime? _date;
  double? _subtotal, _tax, _total;
  List<_ParsedItem> _items = [];

  bool _saving = false;
  Timer? _debounce;
  int? _lastAutoSavedHash;
  static const double _autoSaveThreshold = 0.8;

  // People tagging (kept in state between saves)
  final List<String> _people = [];

  @override
  void initState() {
    super.initState();
    _textCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textCtrl.dispose();
    _textFocus.dispose();
    super.dispose();
  }

  // ============ LISTEN / AUTOPARSE ============
  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      await _parse();
      await _maybeAutoSave();
    });
  }

  // ============ DESKTOP DROP ============
  Future<void> _handleDropFiles(List<XFile> files) async {
    if (files.isEmpty) return;
    final f = files.first;

    // Try .txt
    if (f.name.toLowerCase().endsWith('.txt')) {
      final txt = await f.readAsString();
      _textCtrl.text = txt;
      _toast('Text loaded from ${f.name}');
      return;
    }

    // Images on desktop → tip (OCR is mobile)
    if (f.name.toLowerCase().endsWith('.png') ||
        f.name.toLowerCase().endsWith('.jpg') ||
        f.name.toLowerCase().endsWith('.jpeg') ||
        f.name.toLowerCase().endsWith('.heic') ||
        f.name.toLowerCase().endsWith('.webp')) {
      _toast('Image selected. OCR runs on mobile — paste text for now.');
      return;
    }

    // Anything else → try read text
    try {
      final txt = await f.readAsString();
      _textCtrl.text = txt;
      _toast('Loaded ${f.name}');
    } catch (_) {
      _toast('Unsupported file "${f.name}". Drop a .txt or paste text.');
    }
  }

  // ============ MOBILE: PICK IMAGE + OCR ============
  Future<void> _pickImageMobile() async {
    if (kIsWeb) {
      _toast('OCR not supported on web build.');
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS)) {
      _toast('Use drag & drop on desktop. OCR runs on phone builds.');
      return;
    }

    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Camera'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 6),
        ]),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: source);
    if (img == null) return;

    try {
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFilePath(img.path);
      final res = await recognizer.processImage(input);
      await recognizer.close();

      _textCtrl.text = res.text;
      _toast('Text recognized — parsing…');
    } catch (e) {
      _toast('OCR failed: $e');
    }
  }

  // ============ PARSER ============
  Future<void> _parse() async {
    final raw = _textCtrl.text;
    if (raw.trim().isEmpty) {
      setState(() {
        _merchant = null;
        _date = null;
        _subtotal = null;
        _tax = null;
        _total = null;
        _items = [];
      });
      return;
    }

    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Merchant as first alpha line
    String? merchant;
    for (final l in lines) {
      if (RegExp(r'[A-Za-z]').hasMatch(l)) {
        merchant = l.replaceAll(RegExp(r"[^A-Za-z0-9 &'\-]"), '').trim();
        break;
      }
    }

    double? toDouble(String s) =>
        double.tryParse(s.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.\-]'), ''));

    DateTime? foundDate;
    double? subtotal, total;
    double taxSum = 0.0;
    bool sawAnyTax = false;

    // Collect items and add-ons
    final items = <_ParsedItem>[];
    _ParsedItem? lastParent;

    for (final l in lines) {
      final low = l.toLowerCase();

      // Date (e.g., Nov 06, 25 8:20 pm OR 11/03/2025)
      if (foundDate == null) {
        final m1 = RegExp(
                r'([A-Za-z]{3,9})\s+(\d{1,2}),\s*(\d{2,4})(?:\s+(\d{1,2}:\d{2}\s*[ap]m))?')
            .firstMatch(l);
        final m2 = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})').firstMatch(l);
        if (m1 != null) {
          final mon = m1.group(1)!;
          final day = m1.group(2)!;
          final yr = m1.group(3)!;
          final tm = m1.group(4);
          try {
            final base = DateTime.parse(
                '${_monthToNum(mon).toString().padLeft(2, '0')}-${day.padLeft(2, '0')}-${_normalizeYear(yr)}');
            if (tm != null) {
              final parsed =
                  TimeOfDayFormat(tm).toDateTime(base); // helper below
              foundDate = parsed;
            } else {
              foundDate = base;
            }
          } catch (_) {}
        } else if (m2 != null) {
          final s = m2.group(1)!.replaceAll('/', '-');
          foundDate = DateTime.tryParse(s);
        }
      }

      // Totals (prefer explicit "total" lines; don't let normal item lines override)
      if (low.contains('total')) {
        final m = RegExp(r'([-]?\d+[.,]\d{2})').firstMatch(l);
        if (m != null) {
          total = toDouble(m.group(1)!);
          continue; // don't consider this as an item
        }
      }

      if (low.contains('subtotal')) {
        final m = RegExp(r'([-]?\d+[.,]\d{2})').firstMatch(l);
        if (m != null) subtotal = toDouble(m.group(1)!);
        continue;
      }

      // Tax fragments (sum possible multiple tax lines)
      if (low.contains('tax') || low.contains('gst') || low.contains('pst')) {
        final m = RegExp(r'([-]?\d+[.,]\d{2})').firstMatch(l);
        if (m != null) {
          taxSum += toDouble(m.group(1)!) ?? 0.0;
          sawAnyTax = true;
        }
        continue;
      }

      // Item lines: "2 The Pourhouse Burger   $60.00"
      final itemMatch = RegExp(r'^\s*(\d+)?\s*([^\$]*?)\s+([-]?\d+[.,]\d{2})\s*$')
          .firstMatch(l);
      if (itemMatch != null) {
        final qty = int.tryParse(itemMatch.group(1) ?? '1') ?? 1;
        final name = itemMatch.group(2)!.trim();
        final price = toDouble(itemMatch.group(3)!) ?? 0.0;

        // Add-on detection
        final isAddon = _looksLikeAddon(name);
        final newItem = _ParsedItem(
          raw: l,
          name: name,
          qty: qty,
          price: price,
          isAddon: isAddon,
          parentIndex: null,
        );

        if (isAddon && lastParent != null) {
          // attach to last non-addon
          final parentIdx = items.lastIndexWhere((it) => !it.isAddon);
          if (parentIdx != -1) {
            items.add(newItem.copyWith(parentIndex: parentIdx));
          } else {
            items.add(newItem);
          }
        } else {
          lastParent = newItem;
          items.add(newItem);
        }
        continue;
      }

      // Skip obvious non-items
      if (low.contains('change') ||
          low.contains('cashless') ||
          low.contains('master sale')) {
        continue;
      }
    }

    setState(() {
      _merchant = merchant;
      _date = foundDate;
      _subtotal = subtotal;
      _total = total;
      _tax = sawAnyTax ? taxSum : null;
      _items = items;
    });
  }

  // Helpers
  int _monthToNum(String mon) {
    const m = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'sept': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return m[mon.substring(0, 3).toLowerCase()] ?? 1;
  }

  String _normalizeYear(String yr) {
    if (yr.length == 2) {
      final n = int.parse(yr);
      return (n >= 70 ? 1900 + n : 2000 + n).toString();
    }
    return yr;
  }

  bool _looksLikeAddon(String name) {
    final low = name.toLowerCase();
    return low.startsWith('add ') ||
        low.startsWith('+') ||
        low.contains('extra ') ||
        low.contains('sub ') ||
        low.contains('no ') ||
        low.contains('w/') ||
        low.contains(' with ');
  }

  double _confidence() {
    double score = 0;
    if (_merchant != null && _merchant!.length >= 3) score += 0.2;
    if (_date != null) score += 0.1;
    if (_items.isNotEmpty) score += 0.35;

    // Totals
    if (_subtotal != null && _tax != null) {
      final calc = (_subtotal ?? 0) + (_tax ?? 0);
      if (_total != null) {
        score += ((calc - _total!).abs() <= 0.06) ? 0.35 : 0.15;
      } else {
        score += 0.15;
      }
    } else if (_total != null) {
      score += 0.15;
    }
    return score.clamp(0.0, 1.0);
  }

  // ============ SAVE + PEOPLE ============
  Future<void> _maybeAutoSave() async {
    if (_saving) return;
    if (_items.isEmpty) return;

    final currentHash = _textCtrl.text.hashCode;
    if (_confidence() >= _autoSaveThreshold &&
        _lastAutoSavedHash != currentHash) {
      _lastAutoSavedHash = currentHash;
      await _save(promptForPeople: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Receipt saved (confidence ${(_confidence() * 100).round()}%).'),
        ),
      );
    }
  }

  Future<void> _save({required bool promptForPeople}) async {
    if (_items.isEmpty) {
      _toast('Parse a receipt first');
      _textFocus.requestFocus();
      return;
    }
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final db = FirebaseFirestore.instance;
      final rid = db.collection('tmp').doc().id;
      final receiptRef =
          db.collection('users').doc(uid).collection('receipts').doc(rid);

      await receiptRef.set({
        'created_at': DateTime.now().toIso8601String(),
        'merchant': _merchant,
        'date': _date?.toIso8601String(),
        'subtotal': _subtotal,
        'tax': _tax,
        'total': _total,
        'confidence': _confidence(),
        'raw': _textCtrl.text,
      }, SetOptions(merge: true));

      // Save items
      final saved = <_SavedReceiptItem>[];
      for (final it in _items) {
        final iid = db.collection('tmp').doc().id;
        await receiptRef.collection('items').doc(iid).set({
          'raw': it.raw,
          'name': it.name,
          'qty': it.qty,
          'price': it.price,
          'is_addon': it.isAddon,
          'parent_index': it.parentIndex,
          'place_id': it.placeId,
          'menu_item_id': it.menuItemId,
        });
        saved.add(_SavedReceiptItem(itemDocId: iid, parsed: it));
      }

      if (!mounted) return;

      // People flow
      if (promptForPeople) {
        final assignment =
            await showModalBottomSheet<_PeopleAssignmentResult>(
          context: context,
          isScrollControlled: true,
          builder: (ctx) => _PeopleAssignSheet(
            people: List.of(_people),
            items: saved,
          ),
        );

        if (assignment != null) {
          // persist people list for next time
          _people
            ..clear()
            ..addAll(assignment.people);

          // Create visits per person
          for (final entry in assignment.byItem.entries) {
            final item = saved.firstWhere((e) => e.itemDocId == entry.key);
            for (final person in entry.value) {
              final visitRef =
                  db.collection('users').doc(uid).collection('visits').doc();
              await visitRef.set({
                'created_at': DateTime.now().toIso8601String(),
                'merchant': _merchant,
                'item_name': item.parsed.name,
                'price': item.parsed.price,
                'person': person,
                'place_id': item.parsed.placeId,
                'menu_item_id': item.parsed.menuItemId,
                'from_receipt': rid,
              });
              await receiptRef
                  .collection('items')
                  .doc(item.itemDocId)
                  .update({
                'visit_id_${person.replaceAll(' ', '_')}': visitRef.id
              });
            }
          }
          _toast('Saved visits for ${assignment.totalAssignments} selection(s)');
        } else {
          _toast('Receipt saved');
        }
      } else {
        _toast('Receipt saved');
      }
    } catch (e) {
      _toast('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // ============ UI ============
  @override
  Widget build(BuildContext context) {
    final conf = _confidence();
    final calcTotal =
        (_subtotal ?? 0) + (_tax ?? 0); // may be 0 if nulls; we handle below
    final hasBoth = _subtotal != null && _tax != null;
    final totalsMatch =
        hasBoth && _total != null && (calcTotal - _total!).abs() <= 0.06;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Conf ${(conf * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          IconButton(
            tooltip: 'Pick image (mobile)',
            icon: const Icon(Icons.photo_camera),
            onPressed: _pickImageMobile,
          ),
          IconButton(
            tooltip: 'Parse',
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              await _parse();
              await _maybeAutoSave();
            },
          ),
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save),
            onPressed: _saving ? null : () => _save(promptForPeople: true),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Drop target line
          Center(
            child: Text(
              'Drop an image or .txt file (desktop) • Paste text below • Mobile supports camera OCR',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ),
          const SizedBox(height: 8),
          DropTarget(
            onDragDone: (details) => _handleDropFiles(details.files),
            child: TextField(
              controller: _textCtrl,
              focusNode: _textFocus,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Paste receipt text (temporary MVP)',
                hintText: 'Paste full receipt text here — auto-parse will run',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _kv('Merchant', _merchant),
              _kv('Date', _date?.toString()),
              _kv('Subtotal', _subtotal?.toStringAsFixed(2)),
              _kv('Tax', _tax?.toStringAsFixed(2)),
              _kv('Total', _total?.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(height: 10),
          // Grand total row
          if (hasBoth || _total != null) _grandTotalBanner(calcTotal, totalsMatch),

          const Divider(height: 32),
          Text('Items (${_items.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          // Render items with nesting for add-ons
          ..._buildNestedItemCards(),
          const SizedBox(height: 100),
        ],
      ),
      floatingActionButton: _items.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : () => _save(promptForPeople: true),
              icon: const Icon(Icons.save),
              label: const Text('Save & tag people'),
            ),
    );
  }

  Widget _grandTotalBanner(double calcTotal, bool totalsMatch) {
    final textTheme = Theme.of(context).textTheme;
    final bool hasCalc = _subtotal != null && _tax != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: totalsMatch
            ? Colors.green.withOpacity(.10)
            : Colors.orange.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: totalsMatch ? Colors.green : Colors.orange, width: 1),
      ),
      child: Row(
        children: [
          Icon(totalsMatch ? Icons.check_circle : Icons.warning_amber,
              color: totalsMatch ? Colors.green : Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCalc
                      ? 'Calculated: ${calcTotal.toStringAsFixed(2)}'
                      : 'Calculated: —',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  'Receipt total: ${_total?.toStringAsFixed(2) ?? "—"}',
                  style: textTheme.bodyMedium,
                ),
                Text(
                  totalsMatch
                      ? 'Looks good — subtotal + tax ≈ total.'
                      : 'Totals don’t perfectly line up (tips/rounding/surcharges can cause this). You can still save.',
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildNestedItemCards() {
    final widgets = <Widget>[];
    for (int i = 0; i < _items.length; i++) {
      final it = _items[i];
      final indent = it.isAddon ? 24.0 : 0.0;
      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: _ItemCard(
            item: it,
            onChanged: (updated) {
              setState(() => _items[i] = updated);
            },
            isAddon: it.isAddon,
          ),
        ),
      );
    }
    return widgets;
  }

  Widget _kv(String k, String? v) => Chip(label: Text('$k: ${v ?? "—"}'));
}

// ========= Models & UI Bits =========

class _ParsedItem {
  final String raw;
  final String name;
  final int qty;
  final double price;
  final bool isAddon;
  final int? parentIndex;
  final String? placeId;
  final String? menuItemId;

  _ParsedItem({
    required this.raw,
    required this.name,
    required this.qty,
    required this.price,
    required this.isAddon,
    required this.parentIndex,
    this.placeId,
    this.menuItemId,
  });

  _ParsedItem copyWith({
    String? raw,
    String? name,
    int? qty,
    double? price,
    bool? isAddon,
    int? parentIndex,
    String? placeId,
    String? menuItemId,
  }) {
    return _ParsedItem(
      raw: raw ?? this.raw,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      isAddon: isAddon ?? this.isAddon,
      parentIndex: parentIndex ?? this.parentIndex,
      placeId: placeId ?? this.placeId,
      menuItemId: menuItemId ?? this.menuItemId,
    );
  }
}

class _ItemCard extends StatelessWidget {
  final _ParsedItem item;
  final ValueChanged<_ParsedItem> onChanged;
  final bool isAddon;
  const _ItemCard({
    required this.item,
    required this.onChanged,
    required this.isAddon,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        '${item.qty} ${item.name}${isAddon ? ' (add-on)' : ''}   \$${item.price.toStringAsFixed(2)}';

    return Card(
      color: isAddon ? Colors.brown.withOpacity(.04) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (v) => onChanged(item.copyWith(name: v)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextFormField(
                  initialValue: item.price.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Price'),
                  onChanged: (v) => onChanged(
                    item.copyWith(price: double.tryParse(v) ?? item.price),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.placeId ?? '',
                  decoration:
                      const InputDecoration(labelText: 'Place ID (optional)'),
                  onChanged: (v) =>
                      onChanged(item.copyWith(placeId: v.isEmpty ? null : v)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: item.menuItemId ?? '',
                  decoration: const InputDecoration(
                      labelText: 'Menu Item ID (optional)'),
                  onChanged: (v) =>
                      onChanged(item.copyWith(menuItemId: v.isEmpty ? null : v)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _SavedReceiptItem {
  final String itemDocId;
  final _ParsedItem parsed;
  _SavedReceiptItem({required this.itemDocId, required this.parsed});
}

// ======== People picker sheet ========

class _PeopleAssignSheet extends StatefulWidget {
  final List<String> people;
  final List<_SavedReceiptItem> items;
  const _PeopleAssignSheet({required this.people, required this.items});

  @override
  State<_PeopleAssignSheet> createState() => _PeopleAssignSheetState();
}

class _PeopleAssignSheetState extends State<_PeopleAssignSheet> {
  late List<String> people;
  final Map<String, Set<String>> byItem = {}; // itemDocId -> people
  final TextEditingController _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    people = [...widget.people];
    for (final it in widget.items) {
      byItem[it.itemDocId] = <String>{};
    }
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _addPerson() {
    final n = _addCtrl.text.trim();
    if (n.isEmpty) return;
    if (!people.contains(n)) setState(() => people.add(n));
    _addCtrl.clear();
  }

  int get _totalAssignments =>
      byItem.values.fold(0, (sum, s) => sum + s.length);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom, left: 16, right: 16, top: 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Who ate what?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),

            // People row
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _addCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Add person',
                    hintText: 'e.g., You, Partner, Kiddo',
                  ),
                  onSubmitted: (_) => _addPerson(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _addPerson, child: const Text('Add')),
            ]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: people
                    .map((p) => FilterChip(
                          label: Text(p),
                          selected: true,
                          onSelected: (_) {},
                          onDeleted: () =>
                              setState(() => people.removeWhere((e) => e == p)),
                        ))
                    .toList(),
              ),
            ),
            const Divider(height: 24),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (_, i) {
                  final it = widget.items[i];
                  final selected = byItem[it.itemDocId]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${it.parsed.name}  •  \$${it.parsed.price.toStringAsFixed(2)}'
                        '${it.parsed.isAddon ? ' (add-on)' : ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: people.map((p) {
                          final isSel = selected.contains(p);
                          return ChoiceChip(
                            label: Text(p),
                            selected: isSel,
                            onSelected: (v) {
                              setState(() {
                                if (v) {
                                  selected.add(p);
                                } else {
                                  selected.remove(p);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      _PeopleAssignmentResult(
                        people: people,
                        byItem: byItem.map((k, v) => MapEntry(k, v.toList())),
                      ),
                    );
                  },
                  child: Text('Create visits ($_totalAssignments)'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PeopleAssignmentResult {
  final List<String> people;
  final Map<String, List<String>> byItem;
  _PeopleAssignmentResult({required this.people, required this.byItem});

  int get totalAssignments =>
      byItem.values.fold(0, (sum, v) => sum + v.length);
}

// ======== Small time helper ========

class TimeOfDayFormat {
  final String raw;
  TimeOfDayFormat(this.raw);

  DateTime toDateTime(DateTime baseDate) {
    // ex: "8:20 pm"
    final m = RegExp(r'(\d{1,2}):(\d{2})\s*([ap]m)', caseSensitive: false)
        .firstMatch(raw);
    if (m == null) return baseDate;
    int h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2)!);
    final ap = m.group(3)!.toLowerCase();
    if (ap == 'pm' && h != 12) h += 12;
    if (ap == 'am' && h == 12) h = 0;
    return DateTime(
        baseDate.year, baseDate.month, baseDate.day, h, min, 0, 0, 0);
  }
}
