import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/sale_model.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SalesRepository(apiClient);
});

class SalesRepository {
  final ApiClient apiClient;

  SalesRepository(this.apiClient);

  Future<SaleModel> createSale({
    required int paymentMethodId,
    required List<Map<String, dynamic>> items,
    int? customerId,
    double discount = 0.0,
    double amountPaid = 0.0,
  }) async {
    try {
      final payload = {
        'payment_method_id': paymentMethodId,
        'items': items,
        if (customerId != null && customerId > 0) 'customer_id': customerId,
        'discount': discount,
        'amount_paid': amountPaid,
      };

      final response = await apiClient.post(
        ApiEndpoints.sales,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SaleModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const ServerFailure(message: 'Failed to complete transaction.');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure();
      }

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map<String, dynamic> &&
            errorData.containsKey('insufficient_stock')) {
          final stockInfo = errorData['insufficient_stock'] as Map<String, dynamic>? ?? {};
          throw InsufficientStockFailure(
            productName: stockInfo['product_name'] as String? ?? 'Product',
            availableStock: stockInfo['available_stock'] as int? ?? 0,
          );
        }
        final message = errorData is Map ? (errorData['detail'] ?? errorData['message'] ?? 'Validation error') : 'Validation error';
        throw ValidationFailure(message: message.toString());
      }

      throw ServerFailure(
        message: e.response?.data?['detail']?.toString() ?? 'Server error occurred during checkout.',
      );
    }
  }

  Future<List<SaleModel>> getSalesHistory({int page = 1, String? search}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.sales,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => SaleModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => SaleModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<SaleModel> voidSale(int saleId) async {
    try {
      final response = await apiClient.post(ApiEndpoints.saleVoid(saleId));
      if (response.statusCode == 200 && response.data != null) {
        return SaleModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to void sale.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
