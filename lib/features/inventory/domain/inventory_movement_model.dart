class InventoryMovementModel {
  final int id;
  final DateTime createdAt;
  final int productId;
  final String productName;
  final String movementType;
  final int quantity;
  final int previousStock;
  final int resultingStock;
  final String? userName;
  final String? reason;

  const InventoryMovementModel({
    required this.id,
    required this.createdAt,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.resultingStock,
    this.userName,
    this.reason,
  });

  bool get isStockIn => movementType.toUpperCase() == 'STOCK IN' || quantity > 0;
  bool get isStockOut => movementType.toUpperCase() == 'STOCK OUT' || quantity < 0;

  factory InventoryMovementModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    String? parseString(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      if (val is Map) {
        return val['username']?.toString() ?? val['name']?.toString();
      }
      return null;
    }

    return InventoryMovementModel(
      id: parseInt(json['id']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      productId: parseInt(json['product'] ?? json['product_id']),
      productName: json['product_name']?.toString() ?? (json['product'] is Map ? json['product']['name']?.toString() ?? '' : ''),
      movementType: json['movement_type']?.toString() ?? json['type']?.toString() ?? 'ADJUSTMENT',
      quantity: parseInt(json['quantity']),
      previousStock: parseInt(json['previous_stock'] ?? json['prevStock']),
      resultingStock: parseInt(json['resulting_stock'] ?? json['resultingStock']),
      userName: parseString(json['user_name']) ?? parseString(json['user']),
      reason: json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'product_id': productId,
      'product_name': productName,
      'movement_type': movementType,
      'quantity': quantity,
      'previous_stock': previousStock,
      'resulting_stock': resultingStock,
      'user_name': userName,
      'reason': reason,
    };
  }

  @override
  String toString() =>
      'InventoryMovementModel(id: $id, product: $productName, type: $movementType, qty: $quantity)';
}
