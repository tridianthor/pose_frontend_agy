import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/checkout/presentation/checkout_controller.dart';
import 'package:pose_frontend/features/payments/domain/payment_method_model.dart';
import 'package:pose_frontend/features/pos/domain/cart_item_model.dart';
import 'package:pose_frontend/features/pos/presentation/cart_controller.dart';
import 'package:pose_frontend/features/pos/presentation/pos_catalog_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';
import 'package:pose_frontend/features/sales/data/sales_repository.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

class DynamicMockDioAdapter implements HttpClientAdapter {
  int stock = 10;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('products')) {
      return ResponseBody.fromString(
        '''{
          "count": 1,
          "results": [
            {
              "id": 101,
              "name": "Matcha Latte",
              "sku": "MAT-001",
              "selling_price": "35000.00",
              "stock_quantity": $stock,
              "minimum_stock": 2,
              "is_active": true,
              "category": 1
            }
          ]
        }''',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    } else if (options.path.contains('categories')) {
      return ResponseBody.fromString(
        '''{
          "count": 1,
          "results": [
            {"id": 1, "name": "Beverages"}
          ]
        }''',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    } else if (options.path.contains('payment-methods')) {
      return ResponseBody.fromString(
        '''{
          "count": 1,
          "results": [
            {"id": 1, "name": "Cash", "code": "cash", "is_active": true}
          ]
        }''',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

class TestSalesRepository extends SalesRepository {
  final DynamicMockDioAdapter adapter;

  TestSalesRepository(ApiClient apiClient, this.adapter) : super(apiClient);

  @override
  Future<SaleModel> createSale({
    required int paymentMethodId,
    required List<Map<String, dynamic>> items,
    int? customerId,
    double discount = 0.0,
    double amountPaid = 0.0,
  }) async {
    // Simulate backend inventory reduction upon sale
    for (final item in items) {
      if (item['product_id'] == 101) {
        adapter.stock -= (item['quantity'] as num).toInt();
      }
    }

    return SaleModel(
      id: 501,
      transactionNumber: 'POS-20260815-000501',
      createdAt: DateTime.now(),
      paymentMethodId: paymentMethodId,
      subtotal: 70000,
      discount: discount,
      tax: 0,
      total: 70000 - discount,
      amountPaid: amountPaid,
      change: amountPaid - (70000 - discount),
      status: 'COMPLETED',
    );
  }
}

void main() {
  test('Completing a sale automatically refreshes posCatalogController with decreased stock', () async {
    final adapter = DynamicMockDioAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/'));
    dio.httpClientAdapter = adapter;
    final apiClient = ApiClient(dio);
    final salesRepo = TestSalesRepository(apiClient, adapter);

    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(apiClient),
        salesRepositoryProvider.overrideWithValue(salesRepo),
      ],
    );
    addTearDown(container.dispose);

    // 1. Initial POS Catalog Load
    final catalogNotifier = container.read(posCatalogControllerProvider.notifier);
    await catalogNotifier.fetchCatalog();

    var catalogState = container.read(posCatalogControllerProvider);
    expect(catalogState.products.length, equals(1));
    expect(catalogState.products.first.stockQuantity, equals(10));

    // 2. Add product to cart (Qty = 2)
    final cartNotifier = container.read(cartControllerProvider.notifier);
    final matchaProduct = catalogState.products.first;
    cartNotifier.addToCart(matchaProduct);
    cartNotifier.addToCart(matchaProduct);

    final cartState = container.read(cartControllerProvider);
    expect(cartState.totalItemCount, equals(2));
    expect(cartState.grandTotal, equals(70000));

    // 3. Perform checkout
    final checkoutNotifier = container.read(checkoutControllerProvider.notifier);
    checkoutNotifier.selectPaymentMethod(const PaymentMethodModel(id: 1, name: 'Cash', code: 'cash'));
    checkoutNotifier.setAmountPaid(70000);

    final success = await checkoutNotifier.submitCheckout(cartState);
    expect(success, isTrue);

    // 4. Verify catalog is immediately refreshed with decreased stock
    catalogState = container.read(posCatalogControllerProvider);
    expect(catalogState.products.first.stockQuantity, equals(8));
  });
}
