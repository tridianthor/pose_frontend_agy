import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/features/customers/domain/customer_model.dart';
import 'package:pose_frontend/features/pos/presentation/cart_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';

void main() {
  late CartController cartController;

  const sampleProduct1 = ProductModel(
    id: 101,
    name: 'Coffee Arabica',
    sku: 'COF-001',
    sellingPrice: 25000,
    stockQuantity: 10,
  );

  const sampleProduct2 = ProductModel(
    id: 102,
    name: 'Green Tea',
    sku: 'TEA-001',
    sellingPrice: 15000,
    stockQuantity: 5,
  );

  setUp(() {
    cartController = CartController();
  });

  test('Cart initially empty with Walk-in Customer', () {
    expect(cartController.state.items, isEmpty);
    expect(cartController.state.totalItemCount, equals(0));
    expect(cartController.state.selectedCustomer.isWalkIn, isTrue);
  });

  test('addToCart adds new item or increments quantity', () {
    cartController.addToCart(sampleProduct1);
    expect(cartController.state.items.length, equals(1));
    expect(cartController.state.items.first.quantity, equals(1));
    expect(cartController.state.subtotal, equals(25000));

    // Add same product again
    cartController.addToCart(sampleProduct1);
    expect(cartController.state.items.length, equals(1));
    expect(cartController.state.items.first.quantity, equals(2));
    expect(cartController.state.subtotal, equals(50000));
  });

  test('Adding multiple products computes totals correctly', () {
    cartController.addToCart(sampleProduct1); // 25,000
    cartController.addToCart(sampleProduct2); // 15,000

    expect(cartController.state.totalItemCount, equals(2));
    expect(cartController.state.subtotal, equals(40000));
    expect(cartController.state.formattedGrandTotal, equals('Rp40,000'));
  });

  test('Setting discount updates grandTotal', () {
    cartController.addToCart(sampleProduct1); // 25,000
    cartController.addToCart(sampleProduct2); // 15,000
    cartController.setDiscount(5000);

    expect(cartController.state.subtotal, equals(40000));
    expect(cartController.state.discount, equals(5000));
    expect(cartController.state.grandTotal, equals(35000));
    expect(cartController.state.formattedGrandTotal, equals('Rp35,000'));
  });

  test('incrementQuantity, decrementQuantity & removeFromCart', () {
    cartController.addToCart(sampleProduct1);
    cartController.incrementQuantity(sampleProduct1.id);
    expect(cartController.state.items.first.quantity, equals(2));

    cartController.decrementQuantity(sampleProduct1.id);
    expect(cartController.state.items.first.quantity, equals(1));

    cartController.decrementQuantity(sampleProduct1.id); // Reaches 0 -> removed
    expect(cartController.state.items, isEmpty);
  });

  test('clearCart resets items, discount, and customer', () {
    cartController.addToCart(sampleProduct1);
    cartController.setDiscount(5000);
    cartController.selectCustomer(const CustomerModel(id: 5, name: 'Jane Doe'));

    cartController.clearCart();

    expect(cartController.state.items, isEmpty);
    expect(cartController.state.discount, equals(0.0));
    expect(cartController.state.selectedCustomer.isWalkIn, isTrue);
  });
}
