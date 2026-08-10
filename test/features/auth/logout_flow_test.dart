import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/core/routing/app_router.dart';
import 'package:pose_frontend/core/storage/secure_storage_service.dart';
import 'package:pose_frontend/features/auth/domain/auth_state.dart';
import 'package:pose_frontend/features/auth/presentation/login_controller.dart';
import 'package:dio/dio.dart';

import 'package:pose_frontend/features/dashboard/presentation/dashboard_controller.dart';

class MockDashboardController extends DashboardController {
  MockDashboardController() : super(ApiClient(Dio())) {
    state = const DashboardState(isLoading: false);
  }

  @override
  Future<void> fetchDashboardData() async {}
}

class MockSecureStorage extends SecureStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _data[key];
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clearAll() async {
    _data.clear();
  }
}

class TestLoginController extends LoginController {
  TestLoginController(AuthState initialState, SecureStorageService storage)
      : super(ApiClient(Dio()), storage) {
    state = initialState;
  }

  @override
  Future<void> checkAuthStatus() async {}
}

void main() {
  testWidgets('Logout updates auth state and redirects to login without assertion exception',
      (WidgetTester tester) async {
    final mockStorage = MockSecureStorage();
    await mockStorage.saveAccessToken('valid_token');
    await mockStorage.saveUsername('test_user');

    final container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(mockStorage),
        dashboardControllerProvider.overrideWith((ref) => MockDashboardController()),
        authStateProvider.overrideWith((ref) => TestLoginController(
              const AuthState(
                status: AuthStatus.authenticated,
                username: 'test_user',
                role: 'Cashier',
              ),
              mockStorage,
            )),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial logged in screen (Dashboard)
    expect(find.text('Welcome back,'), findsOneWidget);

    // Perform logout
    await container.read(authStateProvider.notifier).logout();
    await tester.pumpAndSettle();

    // Verify redirected to LoginScreen and no exception was thrown
    expect(find.text('Simple POS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
