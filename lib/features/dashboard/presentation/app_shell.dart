import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive_layout.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
      path: AppRoutes.dashboard,
    ),
    _NavDestination(
      label: 'POS',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale_rounded,
      path: AppRoutes.pos,
    ),
    _NavDestination(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
      path: AppRoutes.products,
    ),
    _NavDestination(
      label: 'Inventory',
      icon: Icons.warehouse_outlined,
      selectedIcon: Icons.warehouse_rounded,
      path: AppRoutes.inventory,
    ),
    _NavDestination(
      label: 'Sales',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      path: AppRoutes.sales,
    ),
    _NavDestination(
      label: 'Customers',
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      path: AppRoutes.customers,
    ),
    _NavDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      path: AppRoutes.settings,
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    for (int i = 0; i < _destinations.length; i++) {
      if (location.startsWith(_destinations[i].path)) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index >= 0 && index < _destinations.length) {
      context.go(_destinations[index].path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isPhone = ResponsiveLayout.isPhone(context);
    final isTablet = ResponsiveLayout.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Phone Layout: Navigation Drawer menu
    if (isPhone) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_destinations[selectedIndex].label),
          elevation: 0,
        ),
        drawer: NavigationDrawer(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            Navigator.of(context).pop(); // Close drawer
            _onItemTapped(index, context);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 16, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS System',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Navigation Menu',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(indent: 28, endIndent: 28),
            const SizedBox(height: 8),
            ..._destinations.map((dest) {
              return NavigationDrawerDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon, color: AppTheme.primaryColor),
                label: Text(dest.label),
              );
            }),
          ],
        ),
        body: child,
      );
    }

    // Tablet Layout: Bottom Navigation Bar
    if (isTablet) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          destinations: _destinations.map((dest) {
            return NavigationDestination(
              icon: Icon(dest.icon),
              selectedIcon: Icon(dest.selectedIcon, color: AppTheme.primaryColor),
              label: dest.label,
            );
          }).toList(),
        ),
      );
    }

    // Desktop Layout: Navigation Rail
    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              border: Border(
                right: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.point_of_sale_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              destinations: _destinations.map((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon:
                      Icon(dest.selectedIcon, color: AppTheme.primaryColor),
                  label: Text(dest.label),
                );
              }).toList(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const _NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}
