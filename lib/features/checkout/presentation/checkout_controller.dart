import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../customers/domain/customer_model.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../payments/domain/payment_method_model.dart';
import '../../pos/presentation/cart_controller.dart';
import '../../pos/presentation/pos_catalog_controller.dart';
import '../../products/presentation/products_controller.dart';
import '../../sales/data/sales_repository.dart';
import '../../sales/domain/sale_model.dart';
import '../../sales/presentation/sales_controller.dart';

class CheckoutState {
  final CustomerModel selectedCustomer;
  final List<PaymentMethodModel> paymentMethods;
  final PaymentMethodModel? selectedPaymentMethod;
  final double amountPaid;
  final bool isSubmitting;
  final SaleModel? completedSale;
  final Failure? failure;

  const CheckoutState({
    CustomerModel? selectedCustomer,
    this.paymentMethods = const [],
    this.selectedPaymentMethod,
    this.amountPaid = 0.0,
    this.isSubmitting = false,
    this.completedSale,
    this.failure,
  }) : selectedCustomer = selectedCustomer ?? const CustomerModel(id: 0, name: 'Walk-in Customer');

  double change(double grandTotal) {
    if (selectedPaymentMethod?.isCash ?? false) {
      final diff = amountPaid - grandTotal;
      return diff < 0 ? 0.0 : diff;
    }
    return 0.0;
  }

  CheckoutState copyWith({
    CustomerModel? selectedCustomer,
    List<PaymentMethodModel>? paymentMethods,
    PaymentMethodModel? selectedPaymentMethod,
    double? amountPaid,
    bool? isSubmitting,
    SaleModel? completedSale,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CheckoutState(
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedSale: completedSale ?? this.completedSale,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, CheckoutState>((ref) {
  final repository = ref.watch(salesRepositoryProvider);
  final apiClient = ref.watch(apiClientProvider);
  return CheckoutController(repository, apiClient, ref);
});

class CheckoutController extends StateNotifier<CheckoutState> {
  final SalesRepository salesRepository;
  final ApiClient apiClient;
  final Ref? ref;

  CheckoutController(this.salesRepository, this.apiClient, [this.ref])
      : super(CheckoutState(selectedCustomer: CustomerModel.walkIn())) {
    loadPaymentMethods();
  }

  Future<void> loadPaymentMethods() async {
    try {
      final response = await apiClient.get(ApiEndpoints.paymentMethods);
      List<PaymentMethodModel> methods = [];
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['results'] is List) {
          methods = (data['results'] as List)
              .map((item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data is List) {
          methods = data
              .map((item) => PaymentMethodModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      // Default fallbacks if backend array is empty
      if (methods.isEmpty) {
        methods = [
          const PaymentMethodModel(id: 1, name: 'Cash', code: 'cash'),
          const PaymentMethodModel(id: 2, name: 'QRIS', code: 'qris'),
          const PaymentMethodModel(id: 3, name: 'Debit Card', code: 'card'),
        ];
      }

      if (mounted) {
        state = state.copyWith(
          paymentMethods: methods,
          selectedPaymentMethod: methods.first,
        );
      }
    } catch (_) {
      if (mounted) {
        final fallbackMethods = [
          const PaymentMethodModel(id: 1, name: 'Cash', code: 'cash'),
          const PaymentMethodModel(id: 2, name: 'QRIS', code: 'qris'),
          const PaymentMethodModel(id: 3, name: 'Debit Card', code: 'card'),
        ];
        state = state.copyWith(
          paymentMethods: fallbackMethods,
          selectedPaymentMethod: fallbackMethods.first,
        );
      }
    }
  }

  void selectCustomer(CustomerModel customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void selectPaymentMethod(PaymentMethodModel method) {
    state = state.copyWith(
      selectedPaymentMethod: method,
      amountPaid: method.isCash ? state.amountPaid : 0.0,
    );
  }

  void setAmountPaid(double paid) {
    state = state.copyWith(amountPaid: paid);
  }

  Future<bool> submitCheckout(CartState cartState) async {
    if (state.selectedPaymentMethod == null) return false;

    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final payloadItems = cartState.items.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.product.sellingPrice,
      };
    }).toList();

    final isCash = state.selectedPaymentMethod!.isCash;
    final finalPaid = isCash ? state.amountPaid : cartState.grandTotal;

    try {
      final sale = await salesRepository.createSale(
        paymentMethodId: state.selectedPaymentMethod!.id,
        items: payloadItems,
        customerId: state.selectedCustomer.isWalkIn ? null : state.selectedCustomer.id,
        discount: cartState.discount,
        amountPaid: finalPaid,
      );

      state = state.copyWith(
        isSubmitting: false,
        completedSale: sale,
      );

      // Trigger cross-module refresh so POS catalog and inventory stock immediately update
      if (ref != null) {
        await Future.wait([
          ref!.read(posCatalogControllerProvider.notifier).fetchCatalog(),
          ref!.read(productsControllerProvider.notifier).fetchProductsAndCategories(),
          ref!.read(inventoryControllerProvider.notifier).fetchInventory(),
          ref!.read(salesControllerProvider.notifier).fetchSales(),
        ]);
      }

      return true;
    } on Failure catch (failure) {
      state = state.copyWith(
        isSubmitting: false,
        failure: failure,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        failure: ServerFailure(message: e.toString()),
      );
      return false;
    }
  }

  void resetCheckout() {
    state = CheckoutState(
      selectedCustomer: CustomerModel.walkIn(),
      paymentMethods: state.paymentMethods,
      selectedPaymentMethod: state.paymentMethods.isNotEmpty ? state.paymentMethods.first : null,
    );
  }
}
