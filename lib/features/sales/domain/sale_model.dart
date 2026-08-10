import 'sale_item_model.dart';

class SaleModel {
  final int id;
  final String transactionNumber;
  final DateTime createdAt;
  final String? cashierName;
  final int? customerId;
  final String? customerName;
  final int paymentMethodId;
  final String? paymentMethodName;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final double change;
  final String status;
  final List<SaleItemModel> items;

  const SaleModel({
    required this.id,
    required this.transactionNumber,
    required this.createdAt,
    this.cashierName,
    this.customerId,
    this.customerName,
    required this.paymentMethodId,
    this.paymentMethodName,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.total,
    required this.amountPaid,
    required this.change,
    this.status = 'COMPLETED',
    this.items = const [],
  });

  bool get isVoided => status.toUpperCase() == 'VOIDED';

  static String _formatRupiah(double amount) {
    final intPrice = amount.toInt();
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

  String get formattedTotal => _formatRupiah(total);
  String get formattedChange => _formatRupiah(change);
  String get formattedAmountPaid => _formatRupiah(amountPaid);

  factory SaleModel.fromJson(Map<String, dynamic> json) {
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

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawItems = json['items'] as List<dynamic>? ?? [];

    return SaleModel(
      id: parseInt(json['id']),
      transactionNumber: json['transaction_number'] as String? ?? json['transactionNumber'] as String? ?? '',
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      cashierName: json['cashier_name'] as String? ?? json['cashier'] as String?,
      customerId: json['customer_id'] != null ? parseInt(json['customer_id']) : null,
      customerName: json['customer_name'] as String? ?? json['customer'] as String?,
      paymentMethodId: parseInt(json['payment_method_id'] ?? json['paymentMethodId'] ?? json['payment_method']),
      paymentMethodName: json['payment_method_name'] as String? ?? json['paymentMethodName'] as String?,
      subtotal: parseDouble(json['subtotal']),
      discount: parseDouble(json['discount']),
      tax: parseDouble(json['tax']),
      total: parseDouble(json['total']),
      amountPaid: parseDouble(json['amount_paid'] ?? json['amountPaid']),
      change: parseDouble(json['change']),
      status: json['status'] as String? ?? 'COMPLETED',
      items: rawItems.map((item) => SaleItemModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'created_at': createdAt.toIso8601String(),
      'cashier_name': cashierName,
      'customer_id': customerId,
      'customer_name': customerName,
      'payment_method_id': paymentMethodId,
      'payment_method_name': paymentMethodName,
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'amount_paid': amountPaid,
      'change': change,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      'SaleModel(id: $id, tx: $transactionNumber, total: $total, status: $status)';
}
