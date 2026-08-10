import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/sale_model.dart';

class ReceiptPreviewDialog extends StatefulWidget {
  final SaleModel sale;

  const ReceiptPreviewDialog({super.key, required this.sale});

  @override
  State<ReceiptPreviewDialog> createState() => _ReceiptPreviewDialogState();
}

class _ReceiptPreviewDialogState extends State<ReceiptPreviewDialog> {
  bool _is80mm = false;

  String _buildThermalText() {
    final width = _is80mm ? 48 : 32;
    final lineChar = '-' * width;
    final doubleLineChar = '=' * width;

    final buffer = StringBuffer();

    void center(String text) {
      if (text.length >= width) {
        buffer.writeln(text);
      } else {
        final padding = (width - text.length) ~/ 2;
        buffer.writeln(' ' * padding + text);
      }
    }

    void row(String left, String right) {
      final totalLen = left.length + right.length;
      if (totalLen >= width) {
        buffer.writeln('$left $right');
      } else {
        final spaces = width - totalLen;
        buffer.writeln('$left${' ' * spaces}$right');
      }
    }

    center('POS SYSTEM STORE');
    center('Jl. Sudirman No. 123, Jakarta');
    center('Telp: (021) 555-0199');
    buffer.writeln(doubleLineChar);
    row('Tx #:', widget.sale.transactionNumber);
    row('Date:', widget.sale.createdAt.toString().split('.')[0]);
    row('Customer:', widget.sale.customerName ?? 'Walk-in Customer');
    row('Payment:', widget.sale.paymentMethodName ?? 'Cash');
    buffer.writeln(lineChar);

    for (final item in widget.sale.items) {
      buffer.writeln(item.productName);
      row(
        '  ${item.quantity} x Rp${item.unitPrice.toInt()}',
        'Rp${item.subtotal.toInt()}',
      );
    }

    buffer.writeln(lineChar);
    row('Subtotal:', 'Rp${widget.sale.subtotal.toInt()}');
    if (widget.sale.discount > 0) {
      row('Discount:', '- Rp${widget.sale.discount.toInt()}');
    }
    buffer.writeln(doubleLineChar);
    row('TOTAL:', widget.sale.formattedTotal);
    row('Amount Paid:', widget.sale.formattedAmountPaid);
    row('Change:', widget.sale.formattedChange);
    buffer.writeln(lineChar);
    center('Thank you for your purchase!');
    center('Please come again');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final receiptText = _buildThermalText();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text('Thermal Receipt Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  selected: !_is80mm,
                  label: const Text('58mm Thermal'),
                  onSelected: (_) => setState(() => _is80mm = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  selected: _is80mm,
                  label: const Text('80mm Thermal'),
                  onSelected: (_) => setState(() => _is80mm = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    receiptText,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontFamilyFallback: ['monospace'],
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: receiptText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Receipt copied to clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy Text'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sent receipt to thermal printer.')),
                      );
                    },
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print Receipt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
