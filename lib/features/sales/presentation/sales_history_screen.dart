import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/sale_model.dart';
import 'sales_controller.dart';
import 'widgets/receipt_preview_dialog.dart';
import 'widgets/sales_export_dialog.dart';
import 'widgets/transaction_detail_dialog.dart';
import 'widgets/void_sale_dialog.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetailDialog(SaleModel sale) {
    showDialog(
      context: context,
      builder: (ctx) => TransactionDetailDialog(sale: sale),
    );
  }

  void _openReceiptDialog(SaleModel sale) {
    showDialog(
      context: context,
      builder: (ctx) => ReceiptPreviewDialog(sale: sale),
    );
  }

  void _openVoidDialog(SaleModel sale) {
    showDialog(
      context: context,
      builder: (ctx) => VoidSaleDialog(sale: sale),
    );
  }

  void _openExportDialog() {
    final state = ref.read(salesControllerProvider);
    showDialog(
      context: context,
      builder: (ctx) => SalesExportDialog(sales: state.filteredSales),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(salesControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales & Audit Log',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Transaction history, receipts, voiding workflow, and sales CSV exports',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: state.sales.isEmpty ? null : _openExportDialog,
                    icon: const Icon(Icons.file_download_rounded),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        ref
                            .read(salesControllerProvider.notifier)
                            .setSearchQuery(val);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search transaction # or customer name...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: state.selectedPaymentFilter ?? 'All',
                    hint: const Text('Payment Method'),
                    items: ['All', 'Cash', 'QRIS', 'Debit Card'].map((method) {
                      return DropdownMenuItem<String?>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (val) {
                      ref
                          .read(salesControllerProvider.notifier)
                          .setPaymentFilter(val);
                    },
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String?>(
                    value: state.selectedStatusFilter ?? 'All',
                    hint: const Text('Status'),
                    items: ['All', 'COMPLETED', 'VOIDED'].map((status) {
                      return DropdownMenuItem<String?>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (val) {
                      ref
                          .read(salesControllerProvider.notifier)
                          .setStatusFilter(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.filteredSales.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 56, color: Theme.of(context).disabledColor),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No sales transactions found.',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.filteredSales.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final sale = state.filteredSales[index];
                              return _SalesTile(
                                sale: sale,
                                onTap: () => _openDetailDialog(sale),
                                onReceipt: () => _openReceiptDialog(sale),
                                onVoid: () => _openVoidDialog(sale),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesTile extends StatelessWidget {
  final SaleModel sale;
  final VoidCallback onTap;
  final VoidCallback onReceipt;
  final VoidCallback onVoid;

  const _SalesTile({
    required this.sale,
    required this.onTap,
    required this.onReceipt,
    required this.onVoid,
  });

  @override
  Widget build(BuildContext context) {
    final isVoided = sale.status.toUpperCase() == 'VOIDED';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: isVoided
            ? AppTheme.accentDanger.withValues(alpha: 0.15)
            : AppTheme.primaryColor.withValues(alpha: 0.15),
        child: Icon(
          isVoided ? Icons.block_rounded : Icons.shopping_bag_rounded,
          color: isVoided ? AppTheme.accentDanger : AppTheme.primaryColor,
        ),
      ),
      title: Text(
        '#${sale.transactionNumber}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${sale.customerName ?? "Walk-in"} • ${sale.paymentMethodName ?? "Cash"} • ${sale.createdAt.toString().split('.')[0]}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sale.formattedTotal,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isVoided ? AppTheme.accentDanger : AppTheme.primaryColor,
              decoration: isVoided ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'View Receipt',
            icon: const Icon(Icons.receipt_outlined),
            onPressed: onReceipt,
          ),
          if (!isVoided)
            IconButton(
              tooltip: 'Void Sale',
              icon: const Icon(Icons.delete_outline, color: AppTheme.accentDanger),
              onPressed: onVoid,
            ),
        ],
      ),
    );
  }
}
