import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../categories/presentation/category_list_screen.dart';
import '../domain/product_model.dart';
import 'products_controller.dart';
import 'widgets/product_form_dialog.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen>
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

  void _openProductForm([ProductModel? product]) {
    final state = ref.read(productsControllerProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ProductFormDialog(
        product: product,
        categories: state.categories,
      ),
    );
  }

  void _confirmDeactivateProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate Product'),
        content: Text('Are you sure you want to deactivate "${product.name}"? It will be hidden from the POS catalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentDanger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success = await ref
                  .read(productsControllerProvider.notifier)
                  .deactivateProduct(product.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${product.name} deactivated.')),
                );
              }
            },
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsControllerProvider);

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
                        'Products & Categories',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage product catalog, pricing, SKU codes, and categories',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openProductForm(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Product Catalog'),
                  Tab(icon: Icon(Icons.category_rounded), text: 'Categories'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Product Catalog Tab
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  ref
                                      .read(productsControllerProvider.notifier)
                                      .setSearchQuery(val);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search product name, SKU, or barcode...',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            DropdownButton<int?>(
                              value: state.selectedCategoryId,
                              hint: const Text('All Categories'),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('All Categories'),
                                ),
                                ...state.categories.map((c) {
                                  return DropdownMenuItem<int?>(
                                    value: c.id,
                                    child: Text(c.name),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                ref
                                    .read(productsControllerProvider.notifier)
                                    .selectCategory(val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: state.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : state.filteredProducts.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No products found matching filters.',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: state.filteredProducts.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(height: 1),
                                      itemBuilder: (context, index) {
                                        final product = state.filteredProducts[index];
                                        return _ProductTile(
                                          product: product,
                                          onEdit: () => _openProductForm(product),
                                          onDeactivate: () => _confirmDeactivateProduct(product),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                    // Categories Tab
                    const CategoryListScreen(),
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

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  const _ProductTile({
    required this.product,
    required this.onEdit,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        'SKU: ${product.sku} • Price: ${product.formattedPrice} • Stock: ${product.stockQuantity}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit Product',
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
            onPressed: onEdit,
          ),
          IconButton(
            tooltip: 'Deactivate Product',
            icon: const Icon(Icons.delete_outline, color: AppTheme.accentDanger),
            onPressed: onDeactivate,
          ),
        ],
      ),
    );
  }
}
