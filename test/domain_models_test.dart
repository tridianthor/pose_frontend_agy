import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/paginated_response.dart';
import 'package:pose_frontend/features/auth/domain/user_model.dart';
import 'package:pose_frontend/features/customers/domain/customer_model.dart';
import 'package:pose_frontend/features/dashboard/domain/dashboard_summary_model.dart';
import 'package:pose_frontend/features/inventory/domain/inventory_movement_model.dart';
import 'package:pose_frontend/features/payments/domain/payment_method_model.dart';
import 'package:pose_frontend/features/pos/domain/cart_item_model.dart';
import 'package:pose_frontend/features/products/domain/category_model.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';
import 'package:pose_frontend/features/sales/domain/sale_item_model.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

void main() {
  group('UserModel tests', () {
    test('UserModel.fromJson & fullName/isAdmin getters', () {
      final json = {
        'id': 1,
        'username': 'admin1',
        'first_name': 'John',
        'last_name': 'Doe',
        'role': 'Admin',
        'is_active': true,
      };
      final user = UserModel.fromJson(json);

      expect(user.id, equals(1));
      expect(user.fullName, equals('John Doe'));
      expect(user.isAdmin, isTrue);
    });
  });

  group('ProductModel & CategoryModel tests', () {
    test('CategoryModel.fromJson & toJson', () {
      final json = {'id': 10, 'name': 'Beverages', 'description': 'Drinks'};
      final cat = CategoryModel.fromJson(json);

      expect(cat.name, equals('Beverages'));
      expect(cat.toJson()['name'], equals('Beverages'));
    });

    test('ProductModel.isLowStock & formattedPrice calculation', () {
      final json = {
        'id': 101,
        'name': 'Coffee Arabica',
        'sku': 'COF-001',
        'selling_price': 25000,
        'stock_quantity': 4,
        'minimum_stock': 10,
      };
      final product = ProductModel.fromJson(json);

      expect(product.isLowStock, isTrue);
      expect(product.formattedPrice, equals('Rp25,000'));
    });
  });

  group('CustomerModel & PaymentMethodModel tests', () {
    test('CustomerModel.walkIn fallback', () {
      final customer = CustomerModel.walkIn();

      expect(customer.isWalkIn, isTrue);
      expect(customer.name, equals('Walk-in Customer'));
    });

    test('PaymentMethodModel.isCash check', () {
      final pm = PaymentMethodModel.fromJson({
        'id': 1,
        'name': 'Cash Payment',
        'code': 'cash',
        'is_active': true,
      });

      expect(pm.isCash, isTrue);
    });
  });

  group('CartItemModel & SaleModel tests', () {
    test('CartItemModel subtotal calculation', () {
      const product = ProductModel(
        id: 1,
        name: 'Coffee',
        sku: 'COF',
        sellingPrice: 15000,
      );
      const cartItem = CartItemModel(product: product, quantity: 3);

      expect(cartItem.lineSubtotal, equals(45000));
      expect(cartItem.formattedSubtotal, equals('Rp45,000'));
    });

    test('SaleModel & SaleItemModel.fromJson & total formatting', () {
      final itemJson = {
        'product_id': 1,
        'product_name': 'Coffee',
        'sku': 'COF',
        'unit_price': 15000,
        'quantity': 3,
        'subtotal': 45000,
      };
      final saleItem = SaleItemModel.fromJson(itemJson);
      expect(saleItem.productName, equals('Coffee'));

      final json = {
        'id': 1,
        'transaction_number': 'POS-001',
        'created_at': '2026-08-11T03:00:00Z',
        'payment_method_id': 1,
        'subtotal': 45000,
        'discount': 5000,
        'total': 40000,
        'amount_paid': 50000,
        'change': 10000,
        'status': 'COMPLETED',
        'items': [itemJson]
      };
      final sale = SaleModel.fromJson(json);

      expect(sale.total, equals(40000));
      expect(sale.formattedTotal, equals('Rp40,000'));
      expect(sale.formattedChange, equals('Rp10,000'));
      expect(sale.items.length, equals(1));
    });
  });

  group('DashboardSummary & InventoryMovement & PaginatedResponse tests', () {
    test('InventoryMovementModel parsing', () {
      final movement = InventoryMovementModel.fromJson({
        'id': 101,
        'created_at': '2026-08-11T03:00:00Z',
        'product_id': 5,
        'product_name': 'Arabica Coffee',
        'movement_type': 'Stock In',
        'quantity': 20,
        'previous_stock': 10,
        'resulting_stock': 30,
        'reason': 'New Shipment',
      });

      expect(movement.isStockIn, isTrue);
      expect(movement.resultingStock, equals(30));
    });

    test('DashboardSummaryModel formatting', () {

      final summary = DashboardSummaryModel.fromJson({
        'today_sales': 1250000,
        'today_transactions': 42,
        'low_stock_count': 8,
        'total_products': 150,
      });

      expect(summary.formattedTodaySales, equals('Rp1,250,000'));
      expect(summary.todayTransactions, equals(42));
    });

    test('PaginatedResponse parsing', () {
      final json = {
        'count': 50,
        'next': 'http://api/products/?page=2',
        'previous': null,
        'results': [
          {'id': 1, 'name': 'Item 1', 'sku': 'SKU1', 'selling_price': 1000}
        ]
      };
      final page = PaginatedResponse<ProductModel>.fromJson(
        json,
        (item) => ProductModel.fromJson(item as Map<String, dynamic>),
      );

      expect(page.count, equals(50));
      expect(page.hasMore, isTrue);
      expect(page.results.length, equals(1));
      expect(page.results.first.name, equals('Item 1'));
    });
  });
}
