import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../products/domain/category_model.dart';
import '../../products/presentation/products_controller.dart';
import 'widgets/category_form_dialog.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  void _openCategoryForm(BuildContext context, [CategoryModel? category]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CategoryFormDialog(category: category),
    );
  }

  void _confirmDeactivateCategory(BuildContext context, WidgetRef ref, CategoryModel category) {
    final productsState = ref.read(productsControllerProvider);
    final linkedProducts = productsState.products.where((p) => p.categoryId == category.id).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.accentWarning),
              SizedBox(width: 8),
              Text('Deactivate Category'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to deactivate "${category.name}"?'),
              if (linkedProducts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWarning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Warning: ${linkedProducts.length} product(s) are currently assigned to this category.',
                    style: const TextStyle(color: AppTheme.accentWarning, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentDanger),
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Category ${category.name} deactivated.')),
                );
              },
              child: const Text('Deactivate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsControllerProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories (${state.categories.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ElevatedButton.icon(
              onPressed: () => _openCategoryForm(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: state.categories.isEmpty
              ? const Center(child: Text('No categories available.'))
              : ListView.separated(
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    final productCount =
                        state.products.where((p) => p.categoryId == category.id).length;

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.category_rounded),
                      ),
                      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${category.description ?? "No description"} • $productCount product(s)',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryColor),
                            onPressed: () => _openCategoryForm(context, category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.accentDanger),
                            onPressed: () => _confirmDeactivateCategory(context, ref, category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
