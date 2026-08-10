import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../products/domain/product_model.dart';
import '../domain/inventory_movement_model.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return InventoryRepository(apiClient);
});

class InventoryRepository {
  final ApiClient apiClient;

  InventoryRepository(this.apiClient);

  Future<List<ProductModel>> getInventoryList({bool? lowStock, String? search}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {
          if (lowStock == true) 'low_stock': true,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Failed to load inventory.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<bool> createStockAdjustment({
    required int productId,
    required String type,
    required int quantity,
    required String reason,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.stockAdjustments,
        data: {
          'product_id': productId,
          'type': type,
          'quantity': quantity,
          'reason': reason,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw ServerFailure(message: e.response?.data?['detail'] ?? 'Stock adjustment failed.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<List<InventoryMovementModel>> getInventoryMovements({
    int page = 1,
    String? movementType,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.inventoryMovements,
        queryParameters: {
          'page': page,
          if (movementType != null && movementType.isNotEmpty) 'type': movementType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => InventoryMovementModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => InventoryMovementModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
