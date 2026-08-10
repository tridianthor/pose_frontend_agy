import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customers/domain/customer_model.dart';
import '../../../payments/domain/payment_method_model.dart';
import '../../../pos/presentation/cart_controller.dart';

class CheckoutConfirmationDialog extends StatelessWidget {
  final CartState cartState;
  final CustomerModel customer;
  final PaymentMethodModel paymentMethod;
  final double amountPaid;
  final double change;
  final VoidCallback onConfirm;

  const CheckoutConfirmationDialog({
    super.key,
    required this.cartState,
    required this.customer,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.onConfirm,
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
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primaryColor),
          SizedBox(width: 8),
          Text('Confirm Sale'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Customer:', customer.name),
            _row('Items Count:', '${cartState.totalItemCount} items'),
            _row('Subtotal:', cartState.formattedSubtotal),
            if (cartState.discount > 0)
              _row('Discount:', '- ${cartState.formattedDiscount}'),
            const Divider(height: 16),
            _row('TOTAL:', cartState.formattedGrandTotal, isBold: true),
            const SizedBox(height: 8),
            _row('Payment Method:', paymentMethod.name),
            _row('Amount Paid:', _formatRupiah(amountPaid)),
            _row('Change:', _formatRupiah(change), isSuccess: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: const Text('Complete Sale'),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isBold = false, bool isSuccess = false}) {
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
