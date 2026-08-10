import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/settings/data/settings_repository.dart';
import 'package:pose_frontend/features/settings/presentation/settings_controller.dart';

class MockSettingsRepository extends SettingsRepository {
  MockSettingsRepository() : super(ApiClient(Dio()));

  @override
  Future<Map<String, dynamic>> getStoreSettings() async {
    return {
      'store_name': 'Test Coffee Shop',
      'address': 'Jl. Testing 123',
      'phone': '021-111222',
      'receipt_header': 'Welcome!',
      'receipt_footer': 'See you soon!',
      'tax_rate': 10.0,
      'currency_symbol': 'Rp',
    };
  }

  @override
  Future<bool> updateStoreSettings(Map<String, dynamic> payload) async {
    return true;
  }
}

void main() {
  late MockSettingsRepository mockRepository;
  late SettingsController controller;

  setUp(() {
    mockRepository = MockSettingsRepository();
    controller = SettingsController(mockRepository);
  });

  test('fetchSettings loads store configuration', () async {
    await controller.fetchSettings();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.storeName, equals('Test Coffee Shop'));
    expect(controller.state.taxRate, equals(10.0));
  });

  test('saveStoreSettings dispatches successfully and updates state', () async {
    final success = await controller.saveStoreSettings({
      'store_name': 'Updated Coffee Shop',
      'address': 'Jl. New 456',
      'phone': '021-999888',
      'receipt_header': 'Welcome back!',
      'receipt_footer': 'Bye!',
      'tax_rate': 11.0,
    });

    expect(success, isTrue);
    expect(controller.state.storeName, equals('Updated Coffee Shop'));
  });
}
