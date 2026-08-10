import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../payments/domain/payment_method_model.dart';

class NonCashCheckoutView extends StatelessWidget {
  final PaymentMethodModel paymentMethod;
  final double grandTotal;

  const NonCashCheckoutView({
    super.key,
    required this.paymentMethod,
    required this.grandTotal,
  });

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Non-Cash Payment: ${paymentMethod.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Exact payment amount of ${_formatRupiah(grandTotal)} will be charged. Change is Rp0.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
