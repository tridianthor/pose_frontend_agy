import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/main.dart';

void main() {
  testWidgets('App renders LoginScreen UI components', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PoseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Simple POS'), findsOneWidget);
    expect(find.byKey(const Key('username_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_button')), findsOneWidget);
  });
}
