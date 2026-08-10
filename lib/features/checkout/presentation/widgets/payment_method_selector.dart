import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../payments/domain/payment_method_model.dart';

class PaymentMethodSelector extends ConsumerWidget {
  final List<PaymentMethodModel> methods;
  final PaymentMethodModel? selectedMethod;
  final ValueChanged<PaymentMethodModel> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.methods,
    this.selectedMethod,
    required this.onMethodSelected,
  });

  IconData _getIconForMethod(String code) {
    switch (code.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'qris':
      case 'qr':
        return Icons.qr_code_2_rounded;
      case 'card':
      case 'debit':
      case 'credit':
        return Icons.credit_card_rounded;
      case 'bank':
      case 'transfer':
        return Icons.account_balance_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (methods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Payment Method',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            final isSelected = selectedMethod?.id == method.id;

            return InkWell(
              onTap: () => onMethodSelected(method),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForMethod(method.code),
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        method.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
