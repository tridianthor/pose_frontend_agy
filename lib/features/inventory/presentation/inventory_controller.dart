import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../products/domain/product_model.dart';
import '../data/inventory_repository.dart';
import '../domain/inventory_movement_model.dart';

class InventoryState {
  final bool isLoading;
  final bool isSubmitting;
  final List<ProductModel> items;
  final List<InventoryMovementModel> history;
  final bool isLowStockFilterActive;
  final String searchQuery;
  final Failure? failure;

  const InventoryState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.items = const [],
    this.history = const [],
    this.isLowStockFilterActive = false,
    this.searchQuery = '',
    this.failure,
  });

  List<ProductModel> get filteredItems {
    return items.where((p) {
      final matchesLowStock = !isLowStockFilterActive || p.isLowStock;
      final matchesSearch = searchQuery.isEmpty ||
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.sku.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesLowStock && matchesSearch;
    }).toList();
  }

  InventoryState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<ProductModel>? items,
    List<InventoryMovementModel>? history,
    bool? isLowStockFilterActive,
    String? searchQuery,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      items: items ?? this.items,
      history: history ?? this.history,
      isLowStockFilterActive: isLowStockFilterActive ?? this.isLowStockFilterActive,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final inventoryControllerProvider =
    StateNotifierProvider<InventoryController, InventoryState>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return InventoryController(repository);
});

class InventoryController extends StateNotifier<InventoryState> {
  final InventoryRepository repository;

  InventoryController(this.repository) : super(const InventoryState()) {
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final items = await repository.getInventoryList();
      final history = await repository.getInventoryMovements();
      state = state.copyWith(
        isLoading: false,
        items: items,
        history: history,
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

  void toggleLowStockFilter(bool active) {
    state = state.copyWith(isLowStockFilterActive: active);
  }

  Future<bool> adjustStock({
    required int productId,
    required String type,
    required int quantity,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      final success = await repository.createStockAdjustment(
        productId: productId,
        type: type,
        quantity: quantity,
        reason: reason,
      );

      if (success) {
        await fetchInventory(); // Refetch updated stock
      }

      state = state.copyWith(isSubmitting: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }

  Future<void> fetchHistory({String? movementType}) async {
    try {
      final history = await repository.getInventoryMovements(movementType: movementType);
      state = state.copyWith(history: history);
    } catch (e) {
      state = state.copyWith(failure: ServerFailure(message: e.toString()));
    }
  }
}
