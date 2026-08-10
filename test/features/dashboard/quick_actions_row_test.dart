import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pose_frontend/features/dashboard/presentation/widgets/quick_actions_row.dart';

void main() {
  group('QuickActionsRow Widget Tests', () {
    testWidgets('Renders all quick operations buttons vertically on mobile viewport without text cutoff',
        (WidgetTester tester) async {
      // Mobile screen size (360x640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: QuickActionsRow(isDark: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Operations'), findsOneWidget);
      expect(find.text('Open POS Cart'), findsOneWidget);
      expect(find.text('Manage Products'), findsOneWidget);
      expect(find.text('Stock Inventory'), findsOneWidget);

      // Verify buttons are laid out in a vertical Column on mobile (different dy coordinates)
      final posButtonCenter = tester.getCenter(find.text('Open POS Cart'));
      final productsButtonCenter = tester.getCenter(find.text('Manage Products'));
      final inventoryButtonCenter = tester.getCenter(find.text('Stock Inventory'));

      expect(productsButtonCenter.dy, greaterThan(posButtonCenter.dy));
      expect(inventoryButtonCenter.dy, greaterThan(productsButtonCenter.dy));
    });

    testWidgets('Renders quick operations buttons horizontally in a row on desktop viewport',
        (WidgetTester tester) async {
      // Desktop screen size (1200x800)
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: QuickActionsRow(isDark: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick Operations'), findsOneWidget);
      expect(find.text('Open POS Cart'), findsOneWidget);
      expect(find.text('Manage Products'), findsOneWidget);
      expect(find.text('Stock Inventory'), findsOneWidget);

      // Verify buttons are laid out in a horizontal Row on desktop (same dy, increasing dx coordinates)
      final posButtonCenter = tester.getCenter(find.text('Open POS Cart'));
      final productsButtonCenter = tester.getCenter(find.text('Manage Products'));
      final inventoryButtonCenter = tester.getCenter(find.text('Stock Inventory'));

      expect(posButtonCenter.dy, equals(productsButtonCenter.dy));
      expect(productsButtonCenter.dy, equals(inventoryButtonCenter.dy));
      expect(productsButtonCenter.dx, greaterThan(posButtonCenter.dx));
      expect(inventoryButtonCenter.dx, greaterThan(productsButtonCenter.dx));
    });
  });
}
