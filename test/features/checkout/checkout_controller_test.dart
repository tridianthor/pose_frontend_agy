import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/checkout/presentation/checkout_controller.dart';
import 'package:pose_frontend/features/payments/domain/payment_method_model.dart';
import 'package:pose_frontend/features/pos/domain/cart_item_model.dart';
import 'package:pose_frontend/features/pos/presentation/cart_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';
import 'package:pose_frontend/features/sales/data/sales_repository.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

class MockSalesRepository extends SalesRepository {
  bool shouldSucceed = true;

  MockSalesRepository() : super(ApiClient(Dio()));

  @override
  Future<SaleModel> createSale({
    required int paymentMethodId,
    required List<Map<String, dynamic>> items,
    int? customerId,
    double discount = 0.0,
    double amountPaid = 0.0,
  }) async {
    if (shouldSucceed) {
      return SaleModel(
        id: 999,
        transactionNumber: 'POS-20260811-000999',
        createdAt: DateTime.now(),
        paymentMethodId: paymentMethodId,
        subtotal: 50000,
        discount: discount,
        tax: 0,
        total: 50000 - discount,
        amountPaid: amountPaid,
        change: amountPaid - (50000 - discount),
        status: 'COMPLETED',
      );
    } else {
      throw Exception('Checkout failed');
    }
  }
}

void main() {
  late MockSalesRepository mockRepository;
  late ApiClient mockApiClient;
  late CheckoutController checkoutController;

  setUp(() {
    mockRepository = MockSalesRepository();
    mockApiClient = ApiClient(Dio());
    checkoutController = CheckoutController(mockRepository, mockApiClient);
  });

  test('Cash payment change calculation', () {
    const cashMethod = PaymentMethodModel(id: 1, name: 'Cash', code: 'cash');
    checkoutController.selectPaymentMethod(cashMethod);
    checkoutController.setAmountPaid(50000);

    expect(checkoutController.state.change(40000), equals(10000));
  });

  test('Non-cash payment change calculation is always 0', () {
    const qrisMethod = PaymentMethodModel(id: 2, name: 'QRIS', code: 'qris');
    checkoutController.selectPaymentMethod(qrisMethod);

    expect(checkoutController.state.change(40000), equals(0.0));
  });

  test('submitCheckout success updates completedSale in state', () async {
    mockRepository.shouldSucceed = true;
    const cashMethod = PaymentMethodModel(id: 1, name: 'Cash', code: 'cash');
    checkoutController.selectPaymentMethod(cashMethod);
    checkoutController.setAmountPaid(50000);

    final cartState = CartState(
      items: [
        const CartItemModel(
          product: ProductModel(id: 1, name: 'Coffee', sku: 'COF', sellingPrice: 25000),
          quantity: 2,
        ),
      ],
    );

    final success = await checkoutController.submitCheckout(cartState);

    expect(success, isTrue);
    expect(checkoutController.state.completedSale, isNotNull);
    expect(checkoutController.state.completedSale!.transactionNumber, equals('POS-20260811-000999'));
  });
}
