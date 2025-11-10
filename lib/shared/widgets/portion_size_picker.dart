import "package:flutter/material.dart";
import 'package:similar_eats_desktop/shared/portion.dart';
import 'package:similar_eats_desktop/shared/portion_size.dart';

class PortionSizePicker extends StatefulWidget {
  final Portion initialValue;
  final ValueChanged<Portion> onChanged;
  final bool showGramsField;
  final String? gramsLabel;

  const PortionSizePicker({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.showGramsField = false,
    this.gramsLabel,
  });

  @override
  State<PortionSizePicker> createState() => _PortionSizePickerState();
}

class _PortionSizePickerState extends State<PortionSizePicker> {
  late PortionSize _size;
  late TextEditingController _gramsCtl;

  @override
  void initState() {
    super.initState();
    _size = widget.initialValue.size;
    _gramsCtl = TextEditingController(
      text: widget.initialValue.grams?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _gramsCtl.dispose();
    super.dispose();
  }

  void _emit() {
    final text = _gramsCtl.text.trim();
    final g = text.isEmpty ? null : double.tryParse(text);
    widget.onChanged(Portion(size: _size, grams: g));
  }

  @override
  Widget build(BuildContext context) {
    final items = PortionSize.values
        .map((p) => ButtonSegment<PortionSize>(
              value: p,
              label: Text(p.label),
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PortionSize>(
          segments: items,
          selected: {_size},
          onSelectionChanged: (sel) {
            setState(() => _size = sel.first);
            _emit();
          },
          multiSelectionEnabled: false,
          showSelectedIcon: false,
        ),
        if (widget.showGramsField) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _gramsCtl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    labelText: widget.gramsLabel ?? 'Grams (optional)',
                  ),
                  onChanged: (_) => _emit(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Optional precise weight',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
