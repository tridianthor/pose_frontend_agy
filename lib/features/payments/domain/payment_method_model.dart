class PaymentMethodModel {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final int sortOrder;

  const PaymentMethodModel({
    required this.id,
    required this.name,
    required this.code,
    this.isActive = true,
    this.sortOrder = 0,
  });

  bool get isCash => code.toLowerCase() == 'cash';

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
      'sort_order': sortOrder,
    };
  }

  PaymentMethodModel copyWith({
    int? id,
    String? name,
    String? code,
    bool? isActive,
    int? sortOrder,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() => 'PaymentMethodModel(id: $id, name: $name, code: $code)';
}
