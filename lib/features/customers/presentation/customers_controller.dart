import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../sales/domain/sale_model.dart';
import '../data/customers_repository.dart';
import '../domain/customer_model.dart';

class CustomersState {
  final bool isLoading;
  final bool isSubmitting;
  final List<CustomerModel> customers;
  final List<SaleModel> selectedCustomerHistory;
  final String searchQuery;
  final Failure? failure;

  const CustomersState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.customers = const [],
    this.selectedCustomerHistory = const [],
    this.searchQuery = '',
    this.failure,
  });

  List<CustomerModel> get filteredCustomers {
    return customers.where((c) {
      final matchesSearch = searchQuery.isEmpty ||
          c.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (c.phone != null && c.phone!.contains(searchQuery)) ||
          (c.email != null && c.email!.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesSearch;
    }).toList();
  }

  CustomersState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<CustomerModel>? customers,
    List<SaleModel>? selectedCustomerHistory,
    String? searchQuery,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CustomersState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      customers: customers ?? this.customers,
      selectedCustomerHistory: selectedCustomerHistory ?? this.selectedCustomerHistory,
      searchQuery: searchQuery ?? this.searchQuery,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final customersControllerProvider =
    StateNotifierProvider<CustomersController, CustomersState>((ref) {
  final repository = ref.watch(customersRepositoryProvider);
  return CustomersController(repository);
});

class CustomersController extends StateNotifier<CustomersState> {
  final CustomersRepository repository;

  CustomersController(this.repository) : super(const CustomersState()) {
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    try {
      final list = await repository.getCustomers();
      // Ensure Walk-in Customer is always in the list
      final hasWalkIn = list.any((c) => c.isWalkIn);
      final fullList = hasWalkIn ? list : [CustomerModel.walkIn(), ...list];

      state = state.copyWith(isLoading: false, customers: fullList);
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

  Future<bool> saveCustomer(Map<String, dynamic> payload, {int? customerId}) async {
    if (customerId == 0) {
      state = state.copyWith(
        failure: const ValidationFailure(message: 'Walk-in Customer cannot be modified.'),
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearFailure: true);
    try {
      if (customerId != null) {
        await repository.updateCustomer(customerId, payload);
      } else {
        await repository.createCustomer(payload);
      }

      await fetchCustomers();
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

  Future<void> fetchCustomerHistory(int customerId) async {
    try {
      final history = await repository.getCustomerHistory(customerId);
      state = state.copyWith(selectedCustomerHistory: history);
    } catch (e) {
      state = state.copyWith(failure: ServerFailure(message: e.toString()));
    }
  }
}
