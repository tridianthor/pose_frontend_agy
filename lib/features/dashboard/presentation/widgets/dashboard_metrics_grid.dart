import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/responsive_layout.dart';
import '../../domain/dashboard_summary_model.dart';

class DashboardMetricsGrid extends StatelessWidget {
  final DashboardSummaryModel summary;

  const DashboardMetricsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cards = [
      _MetricCardData(
        title: "Today's Sales",
        value: summary.formattedTodaySales,
        icon: Icons.payments_rounded,
        accentColor: AppTheme.accentSuccess,
      ),
      _MetricCardData(
        title: "Transactions",
        value: '${summary.todayTransactions}',
        icon: Icons.shopping_bag_rounded,
        accentColor: AppTheme.primaryColor,
      ),
      _MetricCardData(
        title: "Low Stock Alert",
        value: '${summary.lowStockCount} products',
        icon: Icons.warning_amber_rounded,
        accentColor: AppTheme.accentWarning,
      ),
      _MetricCardData(
        title: "Total Products",
        value: '${summary.totalProducts}',
        icon: Icons.inventory_2_rounded,
        accentColor: AppTheme.secondaryColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.4 : 1.6,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.glassDecoration(isDark: isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      card.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: card.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(card.icon, color: card.accentColor, size: 20),
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  card.value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });
}
