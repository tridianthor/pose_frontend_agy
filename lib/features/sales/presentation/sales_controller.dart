import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../data/sales_repository.dart';
import '../domain/sale_model.dart';

class SalesState {
  final bool isLoading;
  final bool isSubmitting;
  final List<SaleModel> sales;
  final String searchQuery;
  final String? selectedPaymentFilter;
  final String? selectedStatusFilter;
  final Failure? failure;

  const SalesState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.sales = const [],
    this.searchQuery = '',
    this.selectedPaymentFilter,
    this.selectedStatusFilter,
    this.failure,
  });

  List<SaleModel> get filteredSales {
    return sales.where((s) {
      final matchesSearch = searchQuery.isEmpty ||
          s.transactionNumber.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (s.customerName != null && s.customerName!.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesPayment = selectedPaymentFilter == null ||
          selectedPaymentFilter == 'All' ||
          (s.paymentMethodName != null &&
              s.paymentMethodName!.toLowerCase() == selectedPaymentFilter!.toLowerCase());
      final matchesStatus = selectedStatusFilter == null ||
          selectedStatusFilter == 'All' ||
          s.status.toLowerCase() == selectedStatusFilter!.toLowerCase();
      return matchesSearch && matchesPayment && matchesStatus;
    }).toList();
  }

  SalesState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<SaleModel>? sales,
    String? searchQuery,
    String? selectedPaymentFilter,
    bool clearPaymentFilter = false,
    String? selectedStatusFilter,
    bool clearStatusFilter = false,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return SalesState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      sales: sales ?? this.sales,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPaymentFilter: clearPaymentFilter
          ? null
          : (selectedPaymentFilter ?? this.selectedPaymentFilter),
      selectedStatusFilter: clearStatusFilter
          ? null
          : (selectedStatusFilter ?? this.selectedStatusFilter),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final salesControllerProvider =
    StateNotifierProvider<SalesController, SalesState>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  return SalesController(repository);
});

class SalesController extends StateNotifier<SalesState> {
  final SalesRepository repository;

  SalesController(this.repository) : super(const SalesState()) {
    fetchSales();
  }

  Future<void> fetchSales() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final list = await repository.getSalesHistory();
      state = state.copyWith(isLoading: false, sales: list);
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

  void setPaymentFilter(String? filter) {
    if (filter == null || filter == 'All') {
      state = state.copyWith(clearPaymentFilter: true);
    } else {
      state = state.copyWith(selectedPaymentFilter: filter);
    }
  }

  void setStatusFilter(String? status) {
    if (status == null || status == 'All') {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(selectedStatusFilter: status);
    }
  }

  Future<bool> voidSale(int saleId, String reason) async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      await repository.voidSale(saleId);
      await fetchSales();
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
