import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../pos/presentation/pos_catalog_controller.dart';
import '../../sales/domain/sale_model.dart';
import 'checkout_controller.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  final SaleModel sale;

  const CheckoutSuccessScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                decoration: AppTheme.glassDecoration(isDark: isDark),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.accentSuccess,
                      child: Icon(Icons.check_rounded, color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sale Completed!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Transaction #${sale.transactionNumber}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _receiptRow('Customer:', sale.customerName ?? 'Walk-in Customer'),
                    _receiptRow('Payment Method:', sale.paymentMethodName ?? 'Cash'),
                    _receiptRow('Subtotal:', 'Rp${sale.subtotal.toInt()}'),
                    if (sale.discount > 0)
                      _receiptRow('Discount:', '- Rp${sale.discount.toInt()}'),
                    const SizedBox(height: 8),
                    _receiptRow('TOTAL:', sale.formattedTotal, isBold: true),
                    _receiptRow('Amount Paid:', sale.formattedAmountPaid),
                    _receiptRow('Change:', sale.formattedChange, isSuccess: true),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sale.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.productName} × ${item.quantity}'),
                              Text('Rp${item.subtotal.toInt()}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(checkoutControllerProvider.notifier).resetCheckout();
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                              context.go(AppRoutes.sales);
                            },
                            child: const Text('Sales Log'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(checkoutControllerProvider.notifier).resetCheckout();
                              ref.read(posCatalogControllerProvider.notifier).fetchCatalog();
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                              context.go(AppRoutes.pos);
                            },
                            child: const Text('New Sale'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isBold = false, bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isSuccess ? AppTheme.accentSuccess : (isBold ? AppTheme.primaryColor : null),
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
