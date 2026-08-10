import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../customers_controller.dart';
import '../../domain/customer_model.dart';

class CustomerDetailDialog extends ConsumerStatefulWidget {
  final CustomerModel customer;

  const CustomerDetailDialog({super.key, required this.customer});

  @override
  ConsumerState<CustomerDetailDialog> createState() => _CustomerDetailDialogState();
}

class _CustomerDetailDialogState extends ConsumerState<CustomerDetailDialog> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(customersControllerProvider.notifier)
          .fetchCustomerHistory(widget.customer.id);
    });
  }

  String _formatRupiah(double amount) {
    final intPrice = amount.toInt();
    final buffer = StringBuffer();
    final str = intPrice.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customersControllerProvider);
    final history = state.selectedCustomerHistory;

    final totalSpend = history.fold(0.0, (sum, s) => sum + s.total);
    final totalVisits = history.length;
    final avgBasket = totalVisits > 0 ? totalSpend / totalVisits : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Icon(
                        widget.customer.isWalkIn
                            ? Icons.directions_walk_rounded
                            : Icons.person_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        if (widget.customer.phone != null)
                          Text(
                            widget.customer.phone!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),
            // Metric Cards Row
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Spend',
                    value: _formatRupiah(totalSpend),
                    icon: Icons.payments_rounded,
                    color: AppTheme.accentSuccess,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Visits',
                    value: '$totalVisits orders',
                    icon: Icons.shopping_bag_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Avg Order',
                    value: _formatRupiah(avgBasket),
                    icon: Icons.analytics_rounded,
                    color: AppTheme.accentWarning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Purchase History Log',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No past purchases recorded.'))
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final sale = history[index];
                        return ListTile(
                          title: Text('#${sale.transactionNumber}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '${sale.createdAt.toString().split('.')[0]} • ${sale.paymentMethodName ?? "Cash"}',
                          ),
                          trailing: Text(
                            sale.formattedTotal,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
