import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/category_model.dart';
import '../domain/product_model.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductsRepository(apiClient);
});

class ProductsRepository {
  final ApiClient apiClient;

  ProductsRepository(this.apiClient);

  Future<List<ProductModel>> getProducts({
    int page = 1,
    String? search,
    int? categoryId,
    bool? isActive,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
          if (categoryId != null) 'category_id': categoryId,
          if (isActive != null) 'is_active': isActive,
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
      throw ServerFailure(message: e.message ?? 'Failed to fetch products.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<ProductModel> createProduct(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.products,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to create product.');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationFailure(
          message: e.response?.data?['detail']?.toString() ?? 'Invalid product data.',
        );
      }
      throw ServerFailure(message: e.message ?? 'Server error creating product.');
    }
  }

  Future<ProductModel> updateProduct(int id, Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.productDetail(id),
        data: payload,
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to update product.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<bool> deactivateProduct(int id) async {
    try {
      final response = await apiClient.post(ApiEndpoints.productDeactivate(id));
      return response.statusCode == 200;
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.get(ApiEndpoints.categories);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<CategoryModel> createCategory(String name, String? description) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.categories,
        data: {
          'name': name,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CategoryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to create category.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<CategoryModel> updateCategory(int id, String name, String? description) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.categoryDetail(id),
        data: {
          'name': name,
          'description': description,
        },
      );
      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to update category.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
