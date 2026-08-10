import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../products/domain/category_model.dart';
import '../pos_catalog_controller.dart';

class CategoryFilterPills extends ConsumerWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;

  const CategoryFilterPills({
    super.key,
    required this.categories,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return FilterChip(
              selected: isSelected,
              label: const Text('All Categories'),
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.primaryColor,
              onSelected: (_) {
                ref
                    .read(posCatalogControllerProvider.notifier)
                    .selectCategory(null);
              },
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;
          return FilterChip(
            selected: isSelected,
            label: Text(category.name),
            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primaryColor,
            onSelected: (_) {
              ref
                  .read(posCatalogControllerProvider.notifier)
                  .selectCategory(category.id);
            },
          );
        },
      ),
    );
  }
}
