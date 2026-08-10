import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/inventory/data/inventory_repository.dart';
import 'package:pose_frontend/features/inventory/domain/inventory_movement_model.dart';
import 'package:pose_frontend/features/inventory/presentation/inventory_controller.dart';
import 'package:pose_frontend/features/products/domain/product_model.dart';

class MockInventoryRepository extends InventoryRepository {
  MockInventoryRepository() : super(ApiClient(Dio()));

  @override
  Future<List<ProductModel>> getInventoryList({bool? lowStock, String? search}) async {
    return const [
      ProductModel(id: 1, name: 'Normal Coffee', sku: 'COF-1', sellingPrice: 20000, stockQuantity: 20, minimumStock: 5),
      ProductModel(id: 2, name: 'Low Tea', sku: 'TEA-1', sellingPrice: 10000, stockQuantity: 2, minimumStock: 10),
    ];
  }

  @override
  Future<List<InventoryMovementModel>> getInventoryMovements({int page = 1, String? movementType}) async {
    return [
      InventoryMovementModel(
        id: 1,
        createdAt: DateTime.now(),
        productId: 1,
        productName: 'Normal Coffee',
        movementType: 'Stock In',
        quantity: 10,
        previousStock: 10,
        resultingStock: 20,
      ),
    ];
  }

  @override
  Future<bool> createStockAdjustment({
    required int productId,
    required String type,
    required int quantity,
    required String reason,
  }) async {
    return true;
  }
}

void main() {
  late MockInventoryRepository mockRepository;
  late InventoryController controller;

  setUp(() {
    mockRepository = MockInventoryRepository();
    controller = InventoryController(mockRepository);
  });

  test('fetchInventory loads products and history', () async {
    await controller.fetchInventory();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.items.length, equals(2));
    expect(controller.state.history.length, equals(1));
  });

  test('toggleLowStockFilter filters low stock items only', () async {
    await controller.fetchInventory();
    expect(controller.state.filteredItems.length, equals(2));

    controller.toggleLowStockFilter(true);
    expect(controller.state.filteredItems.length, equals(1));
    expect(controller.state.filteredItems.first.name, equals('Low Tea'));
  });

  test('adjustStock dispatches successfully and refetches inventory', () async {
    final success = await controller.adjustStock(
      productId: 1,
      type: 'Stock In',
      quantity: 10,
      reason: 'New Delivery',
    );

    expect(success, isTrue);
  });
}
