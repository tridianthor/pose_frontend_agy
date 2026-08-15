import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../pos/presentation/pos_catalog_controller.dart';
import '../data/products_repository.dart';
import '../domain/category_model.dart';
import '../domain/product_model.dart';

class ProductsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final bool showActiveOnly;
  final Failure? failure;

  const ProductsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.showActiveOnly = true,
    this.failure,
  });

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchesCategory = selectedCategoryId == null || p.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (p.barcode != null && p.barcode!.contains(searchQuery));
      final matchesActive = !showActiveOnly || p.isActive;
      return matchesCategory && matchesSearch && matchesActive;
    }).toList();
  }

  ProductsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    bool? showActiveOnly,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      showActiveOnly: showActiveOnly ?? this.showActiveOnly,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final productsControllerProvider =
    StateNotifierProvider<ProductsController, ProductsState>((ref) {
  final repository = ref.watch(productsRepositoryProvider);
  return ProductsController(repository, ref);
});

class ProductsController extends StateNotifier<ProductsState> {
  final ProductsRepository repository;
  final Ref? ref;

  ProductsController(this.repository, [this.ref]) : super(const ProductsState()) {
    fetchProductsAndCategories();
  }

  Future<void> fetchProductsAndCategories() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final productList = await repository.getProducts();
      final categoryList = await repository.getCategories();

      state = state.copyWith(
        isLoading: false,
        products: productList,
        categories: categoryList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void selectCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  void toggleShowActiveOnly(bool activeOnly) {
    state = state.copyWith(showActiveOnly: activeOnly);
  }

  Future<bool> saveProduct(Map<String, dynamic> payload, {int? productId}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      if (productId != null) {
        await repository.updateProduct(productId, payload);
      } else {
        await repository.createProduct(payload);
      }

      await fetchProductsAndCategories();
      if (ref != null) {
        await Future.wait([
          ref!.read(posCatalogControllerProvider.notifier).fetchCatalog(),
          ref!.read(inventoryControllerProvider.notifier).fetchInventory(),
        ]);
      }
      if (mounted) {
        state = state.copyWith(isSubmitting: false);
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSubmitting: false,
          failure: ServerFailure(message: e.toString()),
        );
      }
      return false;
    }
  }

  Future<bool> deactivateProduct(int productId) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      final success = await repository.deactivateProduct(productId);
      if (success) {
        await fetchProductsAndCategories();
        if (ref != null) {
          await Future.wait([
            ref!.read(posCatalogControllerProvider.notifier).fetchCatalog(),
            ref!.read(inventoryControllerProvider.notifier).fetchInventory(),
          ]);
        }
      }
      if (mounted) {
        state = state.copyWith(isSubmitting: false);
      }
      return success;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSubmitting: false,
          failure: ServerFailure(message: e.toString()),
        );
      }
      return false;
    }
  }

  Future<bool> saveCategory(String name, String? description, {int? categoryId}) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      if (categoryId != null) {
        await repository.updateCategory(categoryId, name, description);
      } else {
        await repository.createCategory(name, description);
      }

      await fetchProductsAndCategories();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }
}
