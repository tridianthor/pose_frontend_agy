import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/responsive_layout.dart';
import '../../checkout/presentation/checkout_modal.dart';

import 'cart_controller.dart';
import 'pos_catalog_controller.dart';
import 'widgets/cart_item_list.dart';
import 'widgets/cart_summary_panel.dart';
import 'widgets/category_filter_pills.dart';
import 'widgets/pos_keyboard_shortcuts.dart';
import 'widgets/pos_product_grid.dart';
import 'widgets/product_search_bar.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (mounted) {
        ref.read(posCatalogControllerProvider.notifier).fetchCatalog();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onCheckout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const CheckoutModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(posCatalogControllerProvider);
    final cartState = ref.watch(cartControllerProvider);
    final isMobile = ResponsiveLayout.isMobile(context);

    final Widget body = isMobile
        ? Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                elevation: 1,
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          const Tab(
                              icon: Icon(Icons.grid_view_rounded),
                              text: 'Catalog'),
                          Tab(
                            icon: Badge(
                              isLabelVisible: cartState.totalItemCount > 0,
                              label: Text('${cartState.totalItemCount}'),
                              child: const Icon(Icons.shopping_cart_rounded),
                            ),
                            text: 'Cart',
                          ),
                        ],
                      ),
                    ),
                    if (cartState.items.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear Cart',
                        icon: const Icon(Icons.delete_sweep_rounded,
                            color: AppTheme.accentDanger),
                        onPressed: () {
                          ref.read(cartControllerProvider.notifier).clearCart();
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Catalog Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const ProductSearchBar(),
                          const SizedBox(height: 12),
                          CategoryFilterPills(
                            categories: catalogState.categories,
                            selectedCategoryId: catalogState.selectedCategoryId,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: catalogState.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : PosProductGrid(
                                    products: catalogState.filteredProducts),
                          ),
                        ],
                      ),
                    ),
                    // Cart Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: CartItemList(items: cartState.items),
                            ),
                          ),
                          const SizedBox(height: 12),
                          CartSummaryPanel(onCheckoutPressed: _onCheckout),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Catalog (65% width)
                    Expanded(
                      flex: 65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'POS Terminal',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              IconButton(
                                tooltip: 'Refresh Catalog',
                                icon: const Icon(Icons.refresh_rounded),
                                onPressed: () {
                                  ref
                                      .read(posCatalogControllerProvider.notifier)
                                      .fetchCatalog();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const ProductSearchBar(),
                          const SizedBox(height: 16),
                          CategoryFilterPills(
                            categories: catalogState.categories,
                            selectedCategoryId: catalogState.selectedCategoryId,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: catalogState.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : PosProductGrid(products: catalogState.filteredProducts),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Cart Panel (35% width)
                    Expanded(
                      flex: 35,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_cart_outlined,
                                        color: AppTheme.primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Current Order',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                                if (cartState.items.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      ref.read(cartControllerProvider.notifier).clearCart();
                                    },
                                    icon: const Icon(Icons.delete_sweep_outlined,
                                        color: AppTheme.accentDanger, size: 18),
                                    label: const Text(
                                      'Clear',
                                      style: TextStyle(color: AppTheme.accentDanger),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: CartItemList(items: cartState.items),
                              ),
                            ),
                            const SizedBox(height: 12),
                            CartSummaryPanel(onCheckoutPressed: _onCheckout),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    return PosKeyboardShortcuts(
      onCartShortcut: () {
        if (isMobile) _tabController.animateTo(1);
      },
      onCheckoutShortcut: () {
        if (cartState.items.isNotEmpty) _onCheckout();
      },
      child: body,
    );
  }
}
