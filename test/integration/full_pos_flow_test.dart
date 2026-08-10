import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/features/customers/domain/customer_model.dart';
import 'package:pose_frontend/features/pos/presentation/cart_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';

void main() {
  group('Full POS End-to-End Workflow Verification Test', () {
    late CartController cartController;

    const coffee = ProductModel(
      id: 1,
      name: 'Signature Arabica Coffee',
      sku: 'COF-001',
      sellingPrice: 30000,
      stockQuantity: 15,
      minimumStock: 5,
    );

    const pastry = ProductModel(
      id: 2,
      name: 'Butter Croissant',
      sku: 'PAS-001',
      sellingPrice: 20000,
      stockQuantity: 10,
      minimumStock: 2,
    );

    setUp(() {
      cartController = CartController();
    });

    test('Full Workflow: Product Selection -> Cart -> Discount -> Customer -> Summary', () {
      // Step 1: Add items to cart
      cartController.addToCart(coffee);
      cartController.addToCart(coffee); // Qty 2
      cartController.addToCart(pastry); // Qty 1

      expect(cartController.state.totalItemCount, equals(3));
      expect(cartController.state.subtotal, equals(80000)); // 2x30k + 1x20k

      // Step 2: Apply discount
      cartController.setDiscount(10000);
      expect(cartController.state.discount, equals(10000));
      expect(cartController.state.grandTotal, equals(70000));
      expect(cartController.state.formattedGrandTotal, equals('Rp70,000'));

      // Step 3: Attach customer
      const customer = CustomerModel(id: 10, name: 'Alice Smith', phone: '08123456789');
      cartController.selectCustomer(customer);
      expect(cartController.state.selectedCustomer.name, equals('Alice Smith'));

      // Step 4: Clear cart upon transaction completion
      cartController.clearCart();
      expect(cartController.state.items, isEmpty);
      expect(cartController.state.totalItemCount, equals(0));
      expect(cartController.state.selectedCustomer.isWalkIn, isTrue);
    });
  });
}
