import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/products/data/products_repository.dart';
import 'package:pose_frontend/features/products/domain/category_model.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';
import 'package:pose_frontend/features/products/presentation/products_controller.dart';

class MockProductsRepository extends ProductsRepository {
  MockProductsRepository() : super(ApiClient(Dio()));

  @override
  Future<List<ProductModel>> getProducts({int page = 1, String? search, int? categoryId, bool? isActive}) async {
    return const [
      ProductModel(id: 1, name: 'Espresso', sku: 'COF-1', sellingPrice: 20000, categoryId: 10, isActive: true),
      ProductModel(id: 2, name: 'Croissant', sku: 'BAK-1', sellingPrice: 25000, categoryId: 20, isActive: true),
      ProductModel(id: 3, name: 'Old Muffin', sku: 'BAK-2', sellingPrice: 15000, categoryId: 20, isActive: false),
    ];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return const [
      CategoryModel(id: 10, name: 'Coffee'),
      CategoryModel(id: 20, name: 'Bakery'),
    ];
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> payload) async {
    return ProductModel.fromJson({
      'id': 99,
      ...payload,
    });
  }

  @override
  Future<CategoryModel> createCategory(String name, String? description) async {
    return CategoryModel(id: 99, name: name, description: description);
  }
}

void main() {
  late MockProductsRepository mockRepository;
  late ProductsController controller;

  setUp(() {
    mockRepository = MockProductsRepository();
    controller = ProductsController(mockRepository);
  });

  test('fetchProductsAndCategories loads products and categories', () async {
    await controller.fetchProductsAndCategories();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.products.length, equals(3));
    expect(controller.state.categories.length, equals(2));
  });

  test('selectCategory & toggleShowActiveOnly filter product list correctly', () async {
    await controller.fetchProductsAndCategories();

    // Show active only (default true) -> Espresso & Croissant (2)
    expect(controller.state.filteredProducts.length, equals(2));

    // Select Coffee Category (ID: 10) -> Espresso (1)
    controller.selectCategory(10);
    expect(controller.state.filteredProducts.length, equals(1));
    expect(controller.state.filteredProducts.first.name, equals('Espresso'));

    // Clear category & show all including inactive -> 3 products
    controller.selectCategory(null);
    controller.toggleShowActiveOnly(false);
    expect(controller.state.filteredProducts.length, equals(3));
  });

  test('saveProduct and saveCategory dispatch successfully', () async {
    final productSuccess = await controller.saveProduct({
      'name': 'Matcha Latte',
      'sku': 'TEA-1',
      'selling_price': 30000,
    });

    final categorySuccess = await controller.saveCategory('Tea', 'Tea beverages');

    expect(productSuccess, isTrue);
    expect(categorySuccess, isTrue);
  });
}
