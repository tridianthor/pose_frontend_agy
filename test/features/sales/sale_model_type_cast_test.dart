import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

void main() {
  group('SaleModel.fromJson Type Cast Tests', () {
    test('Correctly parses JSON with integer foreign key IDs for cashier, customer, and payment_method', () {
      final json = {
        'id': 101,
        'transaction_number': 'TRX-101',
        'created_at': '2026-08-11T05:12:00Z',
        'cashier': 1, // Integer ID instead of string name
        'customer': 5, // Integer ID instead of string name
        'payment_method': 2, // Integer ID instead of string name
        'subtotal': 150000.0,
        'discount': 10000.0,
        'tax': 0.0,
        'total': 140000.0,
        'amount_paid': 140000.0,
        'change': 0.0,
        'status': 'COMPLETED',
        'items': [
          {
            'id': 1,
            'product': 10,
            'product_name': 'Test Item',
            'sku': 'SKU-001',
            'unit_price': 150000.0,
            'quantity': 1,
            'subtotal': 150000.0,
          }
        ]
      };

      expect(() => SaleModel.fromJson(json), returnsNormally);

      final sale = SaleModel.fromJson(json);
      expect(sale.id, equals(101));
      expect(sale.transactionNumber, equals('TRX-101'));
      expect(sale.cashierName, isNull);
      expect(sale.customerId, equals(5));
      expect(sale.customerName, isNull);
      expect(sale.paymentMethodId, equals(2));
      expect(sale.paymentMethodName, isNull);
      expect(sale.total, equals(140000.0));
      expect(sale.items.length, equals(1));
    });

    test('Correctly parses JSON with nested Map objects for cashier, customer, and payment_method', () {
      final json = {
        'id': 102,
        'transaction_number': 'TRX-102',
        'created_at': '2026-08-11T05:12:00Z',
        'cashier': {'id': 1, 'username': 'cashier_john'},
        'customer': {'id': 9, 'name': 'Alice Smith'},
        'payment_method': {'id': 1, 'name': 'Cash'},
        'subtotal': 50000.0,
        'discount': 0.0,
        'tax': 0.0,
        'total': 50000.0,
        'amount_paid': 50000.0,
        'change': 0.0,
        'status': 'COMPLETED',
        'items': []
      };

      expect(() => SaleModel.fromJson(json), returnsNormally);

      final sale = SaleModel.fromJson(json);
      expect(sale.cashierName, equals('cashier_john'));
      expect(sale.customerId, equals(9));
      expect(sale.customerName, equals('Alice Smith'));
      expect(sale.paymentMethodId, equals(1));
      expect(sale.paymentMethodName, equals('Cash'));
    });

    test('Correctly parses JSON with string names for cashier_name, customer_name, and payment_method_name', () {
      final json = {
        'id': 103,
        'transaction_number': 'TRX-103',
        'created_at': '2026-08-11T05:12:00Z',
        'cashier_name': 'Bob Cashier',
        'customer_name': 'Charlie',
        'payment_method_name': 'QRIS',
        'payment_method_id': 3,
        'subtotal': 25000.0,
        'total': 25000.0,
        'amount_paid': 25000.0,
        'change': 0.0,
        'status': 'COMPLETED',
        'items': []
      };

      expect(() => SaleModel.fromJson(json), returnsNormally);

      final sale = SaleModel.fromJson(json);
      expect(sale.cashierName, equals('Bob Cashier'));
      expect(sale.customerName, equals('Charlie'));
      expect(sale.paymentMethodId, equals(3));
      expect(sale.paymentMethodName, equals('QRIS'));
    });
  });
}
