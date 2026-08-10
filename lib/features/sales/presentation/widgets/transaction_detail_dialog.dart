import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/sale_model.dart';
import 'receipt_preview_dialog.dart';
import 'void_sale_dialog.dart';

class TransactionDetailDialog extends StatelessWidget {
  final SaleModel sale;

  const TransactionDetailDialog({super.key, required this.sale});

  void _openReceiptPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiptPreviewDialog(sale: sale),
    );
  }

  void _openVoidDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => VoidSaleDialog(sale: sale),
    );
    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVoided = sale.status.toUpperCase() == 'VOIDED';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${sale.transactionNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _StatusBadge(status: sale.status),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow('Date:', sale.createdAt.toString().split('.')[0]),
            _infoRow('Customer:', sale.customerName ?? 'Walk-in Customer'),
            _infoRow('Payment Method:', sale.paymentMethodName ?? 'Cash'),
            const SizedBox(height: 16),
            Text('Purchased Items (${sale.items.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: sale.items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = sale.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('Rp${item.unitPrice.toInt()} × ${item.quantity}'),
                          ],
                        ),
                        Text('Rp${item.subtotal.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow('Subtotal:', 'Rp${sale.subtotal.toInt()}'),
            if (sale.discount > 0)
              _infoRow('Discount:', '- Rp${sale.discount.toInt()}'),
            _infoRow('TOTAL:', sale.formattedTotal, isBold: true),
            _infoRow('Amount Paid:', sale.formattedAmountPaid),
            _infoRow('Change:', sale.formattedChange, isSuccess: true),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openReceiptPreview(context),
                    icon: const Icon(Icons.receipt_rounded),
                    label: const Text('Receipt'),
                  ),
                ),
                if (!isVoided) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentDanger),
                      onPressed: () => _openVoidDialog(context),
                      icon: const Icon(Icons.delete_forever_rounded),
                      label: const Text('Void Sale'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, bool isSuccess = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isVoided = status.toUpperCase() == 'VOIDED';
    final color = isVoided ? AppTheme.accentDanger : AppTheme.accentSuccess;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
