import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pose_frontend/core/routing/app_router.dart';
import 'package:pose_frontend/features/dashboard/presentation/app_shell.dart';

Widget _buildTestAppWithShell() {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const Scaffold(body: Text('Dashboard Content')),
          ),
          GoRoute(
            path: AppRoutes.pos,
            builder: (context, state) => const Scaffold(body: Text('POS Content')),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('AppShell renders NavigationDrawer on Phone screen size (< 600 width)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildTestAppWithShell());
    await tester.pumpAndSettle();

    // On phone width (< 600), should NOT find NavigationBar or NavigationRail
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);

    // Should find AppBar with drawer toggle button
    expect(find.byType(AppBar), findsOneWidget);

    // Open drawer by tapping hamburger button
    final drawerButton = find.byTooltip('Open navigation menu');
    expect(drawerButton, findsOneWidget);
    await tester.tap(drawerButton);
    await tester.pumpAndSettle();

    // Verify NavigationDrawer is present and displays items
    expect(find.byType(NavigationDrawer), findsOneWidget);
    expect(find.text('Dashboard'), findsNWidgets(2)); // AppBar title & drawer label
    expect(find.text('POS'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
  });

  testWidgets('AppShell renders NavigationBar on Tablet screen size (600 <= width < 1024)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildTestAppWithShell());
    await tester.pumpAndSettle();

    // On tablet width (800), should render NavigationBar and NOT NavigationRail or NavigationDrawer
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
  });

  testWidgets('AppShell renders NavigationRail on Desktop screen size (width >= 1024)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_buildTestAppWithShell());
    await tester.pumpAndSettle();

    // On desktop width (1280), should render NavigationRail and NOT NavigationBar or NavigationDrawer
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationDrawer), findsNothing);
  });
}
