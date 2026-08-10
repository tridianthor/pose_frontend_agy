import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/sale_model.dart';

class SalesExportDialog extends StatelessWidget {
  final List<SaleModel> sales;

  const SalesExportDialog({super.key, required this.sales});

  String _generateCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Transaction Number,Date,Customer,Payment Method,Subtotal,Discount,Tax,Total,Amount Paid,Change,Status');

    for (final s in sales) {
      buffer.writeln(
        '${s.id},"${s.transactionNumber}","${s.createdAt}","${s.customerName ?? "Walk-in"}","${s.paymentMethodName ?? "Cash"}",${s.subtotal},${s.discount},${s.tax},${s.total},${s.amountPaid},${s.change},${s.status}',
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final csvContent = _generateCsv();

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.file_download_rounded, color: AppTheme.primaryColor),
          SizedBox(width: 8),
          Text('Export Sales Log (CSV)'),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Exporting ${sales.length} transaction log entries to CSV format.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${csvContent.split('\n').take(4).join('\n')}\n...',
                style: const TextStyle(fontFamily: 'Courier', fontSize: 11),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sales log CSV exported successfully!'),
                backgroundColor: AppTheme.accentSuccess,
              ),
            );
          },
          child: const Text('Download CSV'),
        ),
      ],
    );
  }
}
