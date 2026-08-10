import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';

import '../domain/dashboard_summary_model.dart';
import 'dashboard_controller.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_metrics_grid.dart';
import 'widgets/low_stock_quick_view.dart';
import 'widgets/quick_actions_row.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).fetchDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 24),
                if (state.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.failure != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentDanger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.accentDanger),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.failure!.message,
                            style: const TextStyle(color: AppTheme.accentDanger),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(dashboardControllerProvider.notifier)
                              .fetchDashboardData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  DashboardMetricsGrid(
                    summary: state.summary ??
                        const DashboardSummaryModel(
                          todaySales: 0,
                          todayTransactions: 0,
                          lowStockCount: 0,
                          totalProducts: 0,
                        ),
                  ),
                  const SizedBox(height: 24),
                  QuickActionsRow(isDark: isDark),
                  const SizedBox(height: 24),
                  LowStockQuickView(products: state.lowStockProducts),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
