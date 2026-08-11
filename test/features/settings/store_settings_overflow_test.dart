import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/features/settings/data/settings_repository.dart';
import 'package:pose_frontend/features/settings/presentation/store_settings_screen.dart';

class MockSettingsRepository extends SettingsRepository {
  MockSettingsRepository() : super(ApiClient(Dio()));

  @override
  Future<Map<String, dynamic>> getStoreSettings() async {
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

void main() {
  testWidgets('StoreSettingsScreen renders header subtitle without overflow on narrow screen', (tester) async {
    // Set a narrow screen size (320x600)
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(MockSettingsRepository()),
        ],
        child: const MaterialApp(
          home: StoreSettingsScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Title, Subtitle, and Save button are present
    expect(find.text('Store Settings & Preferences'), findsOneWidget);
    expect(find.text('Configure store identity, receipt formatting, theme, and security'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);

    // Verify no overflow exception was thrown
    expect(tester.takeException(), isNull);
  });
}
