class SaleItemModel {
  final int? id;
  final int productId;
  final String productName;
  final String sku;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const SaleItemModel({
    this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
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

    return SaleItemModel(
      id: json['id'] != null ? parseInt(json['id']) : null,
      productId: parseInt(json['product'] ?? json['product_id']),
      productName: json['product_name'] as String? ?? json['name'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      unitPrice: parseDouble(json['unit_price'] ?? json['price']),
      quantity: parseInt(json['quantity'] ?? json['qty']),
      subtotal: parseDouble(json['subtotal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'sku': sku,
      'unit_price': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() =>
      'SaleItemModel(product: $productName, quantity: $quantity, subtotal: $subtotal)';
}
