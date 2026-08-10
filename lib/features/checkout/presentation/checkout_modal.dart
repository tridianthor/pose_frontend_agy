import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../pos/presentation/cart_controller.dart';
import 'checkout_controller.dart';
import 'checkout_success_screen.dart';
import 'widgets/cash_payment_calculator.dart';
import 'widgets/checkout_confirmation_dialog.dart';
import 'widgets/customer_picker_modal.dart';
import 'widgets/non_cash_checkout_view.dart';
import 'widgets/payment_method_selector.dart';

class CheckoutModal extends ConsumerWidget {
  const CheckoutModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final isCash = checkoutState.selectedPaymentMethod?.isCash ?? true;
    final isAmountValid = !isCash || checkoutState.amountPaid >= cartState.grandTotal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Checkout',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              // Customer Selection Header
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.person_rounded, color: Colors.white),
                ),
                title: const Text('Customer', style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(
                  checkoutState.selectedCustomer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                trailing: OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => CustomerPickerModal(
                        selectedCustomer: checkoutState.selectedCustomer,
                        onCustomerSelected: (customer) {
                          ref
                              .read(checkoutControllerProvider.notifier)
                              .selectCustomer(customer);
                        },
                      ),
                    );
                  },
                  child: const Text('Change'),
                ),
              ),
              const SizedBox(height: 16),
              // Payment Method Selector
              PaymentMethodSelector(
                methods: checkoutState.paymentMethods,
                selectedMethod: checkoutState.selectedPaymentMethod,
                onMethodSelected: (method) {
                  ref
                      .read(checkoutControllerProvider.notifier)
                      .selectPaymentMethod(method);
                },
              ),
              const SizedBox(height: 20),
              // Payment Input (Cash vs Non-Cash)
              if (checkoutState.selectedPaymentMethod != null) ...[
                if (isCash)
                  CashPaymentCalculator(
                    grandTotal: cartState.grandTotal,
                    amountPaid: checkoutState.amountPaid,
                    onAmountPaidChanged: (paid) {
                      ref
                          .read(checkoutControllerProvider.notifier)
                          .setAmountPaid(paid);
                    },
                  )
                else
                  NonCashCheckoutView(
                    paymentMethod: checkoutState.selectedPaymentMethod!,
                    grandTotal: cartState.grandTotal,
                  ),
              ],
              const SizedBox(height: 24),
              // Error Banner if API Failure occurs
              if (checkoutState.failure != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentDanger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.accentDanger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checkoutState.failure!.message,
                          style: const TextStyle(color: AppTheme.accentDanger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Complete Sale Trigger Button
              ElevatedButton(
                onPressed: (!isAmountValid || checkoutState.isSubmitting)
                    ? null
                    : () {
                        _showConfirmation(context, ref, cartState, checkoutState);
                      },
                child: checkoutState.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Complete Sale (${cartState.formattedGrandTotal})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmation(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
    CheckoutState checkoutState,
  ) {
    final isCash = checkoutState.selectedPaymentMethod?.isCash ?? true;
    final finalPaid = isCash ? checkoutState.amountPaid : cartState.grandTotal;
    final change = checkoutState.change(cartState.grandTotal);

    showDialog(
      context: context,
      builder: (ctx) => CheckoutConfirmationDialog(
        cartState: cartState,
        customer: checkoutState.selectedCustomer,
        paymentMethod: checkoutState.selectedPaymentMethod!,
        amountPaid: finalPaid,
        change: change,
        onConfirm: () async {
          final success = await ref
              .read(checkoutControllerProvider.notifier)
              .submitCheckout(cartState);

          if (success && context.mounted) {
            final completedSale =
                ref.read(checkoutControllerProvider).completedSale;
            ref.read(cartControllerProvider.notifier).clearCart();
            Navigator.of(context).pop(); // Close checkout dialog

            if (completedSale != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => CheckoutSuccessScreen(sale: completedSale),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
