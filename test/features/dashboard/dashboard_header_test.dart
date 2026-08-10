import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/features/auth/domain/auth_state.dart';
import 'package:pose_frontend/features/auth/presentation/login_controller.dart';
import 'package:pose_frontend/features/dashboard/presentation/widgets/dashboard_header.dart';

import 'package:dio/dio.dart';
import 'package:pose_frontend/core/network/api_client.dart';
import 'package:pose_frontend/core/storage/secure_storage_service.dart';

class _MockLoginController extends LoginController {
  _MockLoginController(AuthState initialState)
      : super(
          ApiClient(Dio()),
          SecureStorageService(),
        ) {
    state = initialState;
  }

  @override
  Future<void> checkAuthStatus() async {}

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('DashboardHeader renders welcome text on two lines without overflow on small screens',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const testState = AuthState(
      status: AuthStatus.authenticated,
      username: 'Super Long User Name Tester',
      role: 'Administrator',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => _MockLoginController(testState),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: DashboardHeader(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Super Long User Name Tester 👋'), findsOneWidget);
    expect(find.text('ADMINISTRATOR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
