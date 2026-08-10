import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/responsive_layout.dart';

class QuickActionsRow extends StatelessWidget {
  final bool isDark;

  const QuickActionsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    final actions = [
      _QuickActionItem(
        label: 'Open POS Cart',
        icon: Icons.add_shopping_cart_rounded,
        isPrimary: true,
        onTap: () => context.go(AppRoutes.pos),
      ),
      _QuickActionItem(
        label: 'Manage Products',
        icon: Icons.inventory_2_outlined,
        isPrimary: false,
        onTap: () => context.go(AppRoutes.products),
      ),
      _QuickActionItem(
        label: 'Stock Inventory',
        icon: Icons.warehouse_outlined,
        isPrimary: false,
        onTap: () => context.go(AppRoutes.inventory),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Operations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  child: action.isPrimary
                      ? ElevatedButton.icon(
                          onPressed: action.onTap,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: action.onTap,
                          icon: Icon(action.icon),
                          label: Text(action.label),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                ),
              );
            }).toList(),
          )
        else
          Row(
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: action.isPrimary
                      ? ElevatedButton.icon(
                          onPressed: action.onTap,
                          icon: Icon(action.icon),
                          label: Text(
                            action.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : OutlinedButton.icon(
                          onPressed: action.onTap,
                          icon: Icon(action.icon),
                          label: Text(
                            action.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _QuickActionItem {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });
}
