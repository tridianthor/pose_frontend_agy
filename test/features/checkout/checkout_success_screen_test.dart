import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pose_frontend/core/routing/app_router.dart';
import 'package:pose_frontend/features/checkout/presentation/checkout_success_screen.dart';
import 'package:pose_frontend/features/sales/domain/sale_model.dart';

void main() {
  group('CheckoutSuccessScreen Button Action Tests', () {
    final dummySale = SaleModel(
      id: 101,
      transactionNumber: 'TRX-999',
      createdAt: DateTime.now(),
      paymentMethodId: 1,
      paymentMethodName: 'Cash',
      subtotal: 50000.0,
      total: 50000.0,
      amountPaid: 50000.0,
      change: 0.0,
    );

    GoRouter createTestRouter(Widget child) {
      return GoRouter(
        initialLocation: AppRoutes.pos,
        routes: [
          GoRoute(
            path: AppRoutes.pos,
            builder: (context, state) => Scaffold(
              body: Column(
                children: [
                  const Text('POS Screen'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutSuccessScreen(sale: dummySale),
                        ),
                      );
                    },
                    child: const Text('Open Success Screen'),
                  ),
                ],
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.sales,
            builder: (context, state) => const Scaffold(
              body: Text('Sales Log Screen'),
            ),
          ),
        ],
      );
    }

    testWidgets('Sales Log button pops modal screen and navigates to sales log screen',
        (WidgetTester tester) async {
      final router = createTestRouter(const SizedBox());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Open Success Screen
      await tester.tap(find.text('Open Success Screen'));
      await tester.pumpAndSettle();

      expect(find.text('Sale Completed!'), findsOneWidget);
      expect(find.text('Sales Log'), findsOneWidget);

      // Tap Sales Log button
      await tester.tap(find.text('Sales Log'));
      await tester.pumpAndSettle();

      // Verify CheckoutSuccessScreen popped off the stack and navigated to Sales Log Screen
      expect(find.text('Sale Completed!'), findsNothing);
      expect(find.text('Sales Log Screen'), findsOneWidget);
    });

    testWidgets('New Sale button pops modal screen and navigates to POS screen',
        (WidgetTester tester) async {
      final router = createTestRouter(const SizedBox());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Open Success Screen
      await tester.tap(find.text('Open Success Screen'));
      await tester.pumpAndSettle();

      expect(find.text('Sale Completed!'), findsOneWidget);
      expect(find.text('New Sale'), findsOneWidget);

      // Tap New Sale button
      await tester.tap(find.text('New Sale'));
      await tester.pumpAndSettle();

      // Verify CheckoutSuccessScreen popped off the stack and navigated to POS Screen
      expect(find.text('Sale Completed!'), findsNothing);
      expect(find.text('POS Screen'), findsOneWidget);
    });
  });
}
