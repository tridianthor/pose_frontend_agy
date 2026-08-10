import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/customers/presentation/customer_list_screen.dart';
import '../../features/dashboard/presentation/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/products/presentation/product_list_screen.dart';
import '../../features/sales/presentation/sales_history_screen.dart';
import '../../features/settings/presentation/store_settings_screen.dart';
import '../../features/users/presentation/user_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String pos = '/pos';
  static const String products = '/products';
  static const String inventory = '/inventory';
  static const String sales = '/sales';
  static const String customers = '/customers';
  static const String settings = '/settings';
  static const String users = '/users';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: AppRouter.rootNavigatorKey,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (authState.status == AuthStatus.initial) {
        return null;
      }

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      if (isAuthenticated && isLoggingIn) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: AppRouter.routes,
  );
});

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static List<RouteBase> get routes => [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.pos,
              builder: (context, state) => const PosScreen(),
            ),
            GoRoute(
              path: AppRoutes.products,
              builder: (context, state) => const ProductListScreen(),
            ),
            GoRoute(
              path: AppRoutes.inventory,
              builder: (context, state) => const InventoryScreen(),
            ),
            GoRoute(
              path: AppRoutes.sales,
              builder: (context, state) => const SalesHistoryScreen(),
            ),
            GoRoute(
              path: AppRoutes.customers,
              builder: (context, state) => const CustomerListScreen(),
            ),
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const StoreSettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.users,
              builder: (context, state) => const UserListScreen(),
            ),
          ],
        ),
      ];

  static GoRouter get router => GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: AppRoutes.login,
        routes: routes,
      );
}
