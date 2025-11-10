class ReceiptItem {
  final String name;
  final int cents;
  const ReceiptItem({required this.name, required this.cents});
  Map<String, dynamic> toJson() => {"name": name, "cents": cents};
  factory ReceiptItem.fromJson(Map<String, dynamic> j) => ReceiptItem(
      name: (j["name"] ?? "") as String, cents: (j["cents"] ?? 0) as int);
}

class Receipt {
  final String id;
  final String merchant;
  final DateTime purchasedAt;
  final int totalCents;
  final int? taxCents;
  final int? tipCents;
  final List<ReceiptItem> items;
  final String? imagePath;

  const Receipt({
    required this.id,
    required this.merchant,
    required this.purchasedAt,
    required this.totalCents,
    this.taxCents,
    this.tipCents,
    this.items = const [],
    this.imagePath,
  });

  factory Receipt.fromJson(String id, Map<String, dynamic> j) => Receipt(
        id: id,
        merchant: (j["merchant"] ?? "") as String,
        purchasedAt: DateTime.tryParse((j["purchasedAt"] ?? "") as String) ??
            DateTime.now(),
        totalCents: (j["totalCents"] ?? 0) as int,
        taxCents: j["taxCents"] as int?,
        tipCents: j["tipCents"] as int?,
        items: (j["items"] as List? ?? [])
            .map(
                (e) => ReceiptItem.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        imagePath: j["imagePath"] as String?,
      );
}
