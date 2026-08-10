import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../customers/domain/customer_model.dart';
import '../../products/domain/product_model.dart';
import '../domain/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final double discount;
  final double taxRate;
  final CustomerModel selectedCustomer;

  const CartState({
    this.items = const [],
    this.discount = 0.0,
    this.taxRate = 0.0,
    CustomerModel? selectedCustomer,
  }) : selectedCustomer = selectedCustomer ?? const CustomerModel(id: 0, name: 'Walk-in Customer');

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineSubtotal);

  double get grandTotal {
    final totalAfterDiscount = subtotal - discount;
    final total = totalAfterDiscount < 0 ? 0.0 : totalAfterDiscount;
    final taxAmount = total * taxRate;
    return total + taxAmount;
  }

  String _formatRupiah(double amount) {
    final intPrice = amount.toInt();
    final buffer = StringBuffer();
    final str = intPrice.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return 'Rp${buffer.toString()}';
  }

  String get formattedSubtotal => _formatRupiah(subtotal);
  String get formattedDiscount => _formatRupiah(discount);
  String get formattedGrandTotal => _formatRupiah(grandTotal);

  CartState copyWith({
    List<CartItemModel>? items,
    double? discount,
    double? taxRate,
    CustomerModel? selectedCustomer,
  }) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, CartState>((ref) {
  return CartController();
});

class CartController extends StateNotifier<CartState> {
  CartController() : super(CartState(selectedCustomer: CustomerModel.walkIn()));

  void addToCart(ProductModel product) {
    final index = state.items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final existingItem = state.items[index];
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[index] = existingItem.copyWith(quantity: existingItem.quantity + 1);
      state = state.copyWith(items: updatedList);
    } else {
      final newItem = CartItemModel(product: product, quantity: 1);
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = state.items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(quantity: quantity);
      state = state.copyWith(items: updatedList);
    }
  }

  void incrementQuantity(int productId) {
    final index = state.items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      updateQuantity(productId, state.items[index].quantity + 1);
    }
  }

  void decrementQuantity(int productId) {
    final index = state.items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      updateQuantity(productId, state.items[index].quantity - 1);
    }
  }

  void removeFromCart(int productId) {
    final updatedList = state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: updatedList);
  }

  void setDiscount(double discount) {
    final validDiscount = discount < 0 ? 0.0 : discount;
    state = state.copyWith(discount: validDiscount);
  }

  void selectCustomer(CustomerModel customer) {
    state = state.copyWith(selectedCustomer: customer);
  }

  void clearCart() {
    state = CartState(selectedCustomer: CustomerModel.walkIn());
  }
}
