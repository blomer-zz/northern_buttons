class Product {
  final int? id;
  final String brand;
  final String product;
  final String flavor;
  final int caseQty;
  final bool soldByCase;
  final String? upc;
  final double defaultPrice;
  final double? defaultSalePrice;
  final double? superOnePrice;
  final double? superOneSalePrice;
  final double? speedwayPrice;
  final String? notes;

  const Product({
    this.id,
    required this.brand,
    required this.product,
    required this.flavor,
    required this.caseQty,
    required this.soldByCase,
    this.upc,
    required this.defaultPrice,
    this.defaultSalePrice,
    this.superOnePrice,
    this.superOneSalePrice,
    this.speedwayPrice,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'product': product,
      'flavor': flavor,
      'case_qty': caseQty,
      'sold_by_case': soldByCase ? 1 : 0,
      'upc': upc,
      'default_price': defaultPrice,
      'default_sale_price': defaultSalePrice,
      'super_one_price': superOnePrice,
      'super_one_sale_price': superOneSalePrice,
      'speedway_price': speedwayPrice,
      'notes': notes,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      brand: map['brand'] as String,
      product: map['product'] as String,
      flavor: map['flavor'] as String,
      caseQty: map['case_qty'] as int,
      soldByCase: (map['sold_by_case'] as int) == 1,
      upc: map['upc'] as String?,
      defaultPrice: (map['default_price'] as num).toDouble(),
      defaultSalePrice: map['default_sale_price'] != null
          ? (map['default_sale_price'] as num).toDouble()
          : null,
      superOnePrice: map['super_one_price'] != null
          ? (map['super_one_price'] as num).toDouble()
          : null,
      superOneSalePrice: map['super_one_sale_price'] != null
          ? (map['super_one_sale_price'] as num).toDouble()
          : null,
      speedwayPrice: map['speedway_price'] != null
          ? (map['speedway_price'] as num).toDouble()
          : null,
      notes: map['notes'] as String?,
    );
  }

  /// Returns the regular price for a given pricing category.
  /// Falls back to defaultPrice if the category-specific price is null.
  double getPrice(String pricingCategory) {
    switch (pricingCategory) {
      case 'super_one':
        return superOnePrice ?? defaultPrice;
      case 'speedway':
        return speedwayPrice ?? defaultPrice;
      default:
        return defaultPrice;
    }
  }

  /// Returns the sale price for a given pricing category, or null if none exists.
  double? getSalePrice(String pricingCategory) {
    switch (pricingCategory) {
      case 'super_one':
        return superOneSalePrice;
      default:
        return defaultSalePrice;
    }
  }

  /// The brand + product combined, matching the button labels (e.g., "Stokke Pizza")
  String get brandProduct => '$brand $product';
}
