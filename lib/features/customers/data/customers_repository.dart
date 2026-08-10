import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../sales/domain/sale_model.dart';
import '../domain/customer_model.dart';

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomersRepository(apiClient);
});

class CustomersRepository {
  final ApiClient apiClient;

  CustomersRepository(this.apiClient);

  Future<List<CustomerModel>> getCustomers({int page = 1, String? search}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.customers,
        queryParameters: {
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          return (data['results'] as List)
              .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          return data
              .map((item) => CustomerModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [CustomerModel.walkIn()];
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Failed to fetch customers.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<CustomerModel> createCustomer(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.customers,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to create customer.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<CustomerModel> updateCustomer(int id, Map<String, dynamic> payload) async {
    if (id == 0) {
      throw const ValidationFailure(message: 'Walk-in Customer cannot be modified.');
    }
    try {
      final response = await apiClient.patch(
        ApiEndpoints.customerDetail(id),
        data: payload,
      );

      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Failed to update customer.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<List<SaleModel>> getCustomerHistory(int customerId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.sales,
        queryParameters: {'customer_id': customerId},
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
}
