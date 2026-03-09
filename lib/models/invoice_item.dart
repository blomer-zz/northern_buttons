class InvoiceItem {
  final String brand;
  final String product;
  final String flavor;
  final double price;
  final double? salePrice;
  int quantity;
  bool isSale;

  InvoiceItem({
    required this.brand,
    required this.product,
    required this.flavor,
    required this.price,
    this.salePrice,
    this.quantity = 1,
    this.isSale = false,
  });

  double get activePrice =>
      isSale && salePrice != null ? salePrice! : price;

  double get total => activePrice * quantity;

  /// Key for deduplication: same brand+product+flavor means increment quantity
  String get key => '$brand|$product|$flavor';

  /// Display name combining brand and product (e.g., "Stokke Pizza")
  String get brandProduct => '$brand $product';
}
