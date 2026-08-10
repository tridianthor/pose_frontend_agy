import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../products/domain/category_model.dart';
import '../../products/domain/product_model.dart';

class PosCatalogState {
  final bool isLoading;
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final Failure? failure;

  const PosCatalogState({
    this.isLoading = false,
    this.products = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.failure,
  });

  List<ProductModel> get filteredProducts {
    return products.where((p) {
      final matchesCategory = selectedCategoryId == null || p.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (p.barcode != null && p.barcode!.contains(searchQuery));
      return matchesCategory && matchesSearch && p.isActive;
    }).toList();
  }

  PosCatalogState copyWith({
    bool? isLoading,
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    bool clearCategory = false,
    String? searchQuery,
    Failure? failure,
  }) {
    return PosCatalogState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      searchQuery: searchQuery ?? this.searchQuery,
      failure: failure ?? this.failure,
    );
  }
}

final posCatalogControllerProvider =
    StateNotifierProvider<PosCatalogController, PosCatalogState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PosCatalogController(apiClient);
});

class PosCatalogController extends StateNotifier<PosCatalogState> {
  final ApiClient apiClient;
  Timer? _debounceTimer;

  PosCatalogController(this.apiClient) : super(const PosCatalogState()) {
    fetchCatalog();
  }

  Future<void> fetchCatalog() async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final productsResponse = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'is_active': true},
      );

      final categoriesResponse = await apiClient.get(ApiEndpoints.categories);

      List<ProductModel> productList = [];
      if (productsResponse.statusCode == 200 && productsResponse.data != null) {
        final data = productsResponse.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          productList = (data['results'] as List)
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          productList = data
              .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      List<CategoryModel> categoryList = [];
      if (categoriesResponse.statusCode == 200 && categoriesResponse.data != null) {
        final data = categoriesResponse.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          categoryList = (data['results'] as List)
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          categoryList = data
              .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      state = state.copyWith(
        isLoading: false,
        products: productList,
        categories: categoryList,
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.message ?? 'Failed to load POS product catalog.'),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: ServerFailure(message: e.toString()),
      );
    }
  }

  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(searchQuery: query.trim());
    });
  }

  void selectCategory(int? categoryId) {
    if (categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategoryId: categoryId);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
