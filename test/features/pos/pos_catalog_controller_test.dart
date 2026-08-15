import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/pos/presentation/pos_catalog_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';

class MockDioAdapter implements HttpClientAdapter {
  Map<String, dynamic>? mockProductsResponse;
  Map<String, dynamic>? mockCategoriesResponse;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('products')) {
      return ResponseBody.fromString(
        mockProductsResponse != null
            ? '''{
                "count": 2,
                "results": [
                  {
                    "id": 1,
                    "name": "Espresso Roast",
                    "sku": "ESP-001",
                    "selling_price": "30000.00",
                    "stock_quantity": 8,
                    "minimum_stock": 2,
                    "is_active": true,
                    "category": 1
                  },
                  {
                    "id": 2,
                    "name": "Croissant",
                    "sku": "CRS-001",
                    "selling_price": "20000.00",
                    "stock_quantity": 0,
                    "minimum_stock": 2,
                    "is_active": true,
                    "category": 2
                  }
                ]
              }'''
            : '{"results": []}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    } else if (options.path.contains('categories')) {
      return ResponseBody.fromString(
        mockCategoriesResponse != null
            ? '''{
                "count": 2,
                "results": [
                  {"id": 1, "name": "Beverages"},
                  {"id": 2, "name": "Pastries"}
                ]
              }'''
            : '{"results": []}',
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

void main() {
  late Dio dio;
  late MockDioAdapter mockAdapter;
  late ApiClient apiClient;
  late PosCatalogController controller;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.com/api/'));
    mockAdapter = MockDioAdapter();
    dio.httpClientAdapter = mockAdapter;
    apiClient = ApiClient(dio);
  });

  test('PosCatalogController fetches products and categories with accurate stock', () async {
    mockAdapter.mockProductsResponse = {};
    mockAdapter.mockCategoriesResponse = {};

    controller = PosCatalogController(apiClient);
    await controller.fetchCatalog();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.products.length, equals(2));
    expect(controller.state.categories.length, equals(2));

    final product1 = controller.state.products.firstWhere((p) => p.id == 1);
    expect(product1.stockQuantity, equals(8));
    expect(product1.isOutOfStock, isFalse);

    final product2 = controller.state.products.firstWhere((p) => p.id == 2);
    expect(product2.stockQuantity, equals(0));
    expect(product2.isOutOfStock, isTrue);
  });

  test('Filtering by category correctly restricts filteredProducts', () async {
    mockAdapter.mockProductsResponse = {};
    mockAdapter.mockCategoriesResponse = {};

    controller = PosCatalogController(apiClient);
    await controller.fetchCatalog();

    controller.selectCategory(1);
    expect(controller.state.filteredProducts.length, equals(1));
    expect(controller.state.filteredProducts.first.name, equals('Espresso Roast'));

    controller.selectCategory(null);
    expect(controller.state.filteredProducts.length, equals(2));
  });
}
