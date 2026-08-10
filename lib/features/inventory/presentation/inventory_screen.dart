import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../products/domain/product_model.dart';
import 'inventory_controller.dart';
import 'inventory_history_screen.dart';
import 'widgets/stock_adjustment_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openStockAdjustment([ProductModel? product]) {
    final state = ref.read(inventoryControllerProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StockAdjustmentDialog(
        products: state.items,
        selectedProduct: product,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);

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
                        'Inventory Management',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monitor current stock, low-stock alerts, and movement logs',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: state.items.isEmpty ? null : () => _openStockAdjustment(),
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text('Adjust Stock'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.warehouse_rounded), text: 'Stock Overview'),
                  Tab(icon: Icon(Icons.history_rounded), text: 'Movement Audit Log'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Stock Overview Tab
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  ref
                                      .read(inventoryControllerProvider.notifier)
                                      .setSearchQuery(val);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search product or SKU...',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilterChip(
                              selected: state.isLowStockFilterActive,
                              avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                              label: const Text('Low Stock Alerts Only'),
                              selectedColor: AppTheme.accentWarning.withValues(alpha: 0.2),
                              onSelected: (active) {
                                ref
                                    .read(inventoryControllerProvider.notifier)
                                    .toggleLowStockFilter(active);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: state.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : state.filteredItems.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No inventory items match your criteria.',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: state.filteredItems.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final item = state.filteredItems[index];
                                        return _InventoryTile(
                                          item: item,
                                          onAdjust: () => _openStockAdjustment(item),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                    // Inventory History Tab
                    const InventoryHistoryScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final ProductModel item;
  final VoidCallback onAdjust;

  const _InventoryTile({required this.item, required this.onAdjust});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('SKU: ${item.sku} • Price: ${item.formattedPrice}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StockBadge(item: item),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Adjust Stock',
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
            onPressed: onAdjust,
          ),
        ],
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final ProductModel item;

  const _StockBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentDanger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
              color: AppTheme.accentDanger,
              fontWeight: FontWeight.bold,
              fontSize: 11),
        ),
      );
    }

    if (item.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accentWarning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Low Stock: ${item.stockQuantity} / min ${item.minimumStock}',
          style: const TextStyle(
              color: AppTheme.accentWarning,
              fontWeight: FontWeight.bold,
              fontSize: 11),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentSuccess.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'In Stock: ${item.stockQuantity}',
        style: const TextStyle(
            color: AppTheme.accentSuccess,
            fontWeight: FontWeight.bold,
            fontSize: 11),
      ),
    );
  }
}
