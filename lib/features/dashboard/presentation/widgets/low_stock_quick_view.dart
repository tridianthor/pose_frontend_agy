import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/product_model.dart';

class LowStockQuickView extends StatelessWidget {
  final List<ProductModel> products;

  const LowStockQuickView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(isDark: isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.accentWarning),
                  const SizedBox(width: 8),
                  Text(
                    'Low Stock Products',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRoutes.inventory),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'No low-stock products found. All items in stock!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length > 5 ? 5 : products.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = products[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('SKU: ${item.sku}'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentWarning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accentWarning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${item.stockQuantity} / min ${item.minimumStock}',
                      style: const TextStyle(
                        color: AppTheme.accentWarning,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
