import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient);
});

class SettingsRepository {
  final ApiClient apiClient;

  SettingsRepository(this.apiClient);

  Future<Map<String, dynamic>> getStoreSettings() async {
    try {
      final response = await apiClient.get(ApiEndpoints.settings);
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return {
        'store_name': 'My POS Store',
        'address': 'Jl. Utama No. 45, Jakarta',
        'phone': '021-5550199',
        'receipt_header': 'Welcome to My POS Store',
        'receipt_footer': 'Thank you for shopping with us!',
        'tax_rate': 10.0,
        'currency_symbol': 'Rp',
      };
    } catch (_) {
      return {
        'store_name': 'My POS Store',
        'address': 'Jl. Utama No. 45, Jakarta',
        'phone': '021-5550199',
        'receipt_header': 'Welcome to My POS Store',
        'receipt_footer': 'Thank you for shopping with us!',
        'tax_rate': 10.0,
        'currency_symbol': 'Rp',
      };
    }
  }

  Future<bool> updateStoreSettings(Map<String, dynamic> payload) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.settings,
        data: payload,
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw ServerFailure(message: e.message ?? 'Failed to update store settings.');
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
