class ProductModel {
  final int id;
  final String name;
  final String sku;
  final String? barcode;
  final int? categoryId;
  final String? categoryName;
  final double sellingPrice;
  final double? costPrice;
  final String? unit;
  final int stockQuantity;
  final int minimumStock;
  final String? description;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.categoryId,
    this.categoryName,
    required this.sellingPrice,
    this.costPrice,
    this.unit,
    this.stockQuantity = 0,
    this.minimumStock = 0,
    this.description,
    this.isActive = true,
  });

  bool get isLowStock => stockQuantity <= minimumStock;
  bool get isOutOfStock => stockQuantity <= 0;

  String get formattedPrice {
    final intPrice = sellingPrice.toInt();
    final buffer = StringBuffer();
    final str = intPrice.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    return ProductModel(
      id: parseInt(json['id']),
      name: json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      barcode: json['barcode'] as String?,
      categoryId: json['category'] is Map
          ? parseInt((json['category'] as Map)['id'])
          : json['category_id'] != null
              ? parseInt(json['category_id'])
              : json['category'] is int
                  ? parseInt(json['category'])
                  : null,
      categoryName: json['category'] is Map
          ? (json['category'] as Map)['name'] as String?
          : json['category_name'] as String?,
      sellingPrice: parseDouble(json['selling_price'] ?? json['price']),
      costPrice: json['cost_price'] != null ? parseDouble(json['cost_price']) : null,
      unit: json['unit'] as String?,
      stockQuantity: parseInt(json['stock_quantity'] ?? json['stock']),
      minimumStock: parseInt(json['minimum_stock'] ?? json['min_stock']),
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'category_name': categoryName,
      'selling_price': sellingPrice,
      'cost_price': costPrice,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'minimum_stock': minimumStock,
      'description': description,
      'is_active': isActive,
    };
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? sku,
    String? barcode,
    int? categoryId,
    String? categoryName,
    double? sellingPrice,
    double? costPrice,
    String? unit,
    int? stockQuantity,
    int? minimumStock,
    String? description,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      costPrice: costPrice ?? this.costPrice,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumStock: minimumStock ?? this.minimumStock,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, sku: $sku, price: $sellingPrice, stock: $stockQuantity)';
}
