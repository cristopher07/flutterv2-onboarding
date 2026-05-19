import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ecommerce_mock_datasource.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product_to_cart.dart';
import '../../domain/usecases/select_payment_method.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';

final ecommerceDatasourceProvider = Provider<EcommerceMockDatasource>(
  (ref) => const EcommerceMockDatasource(),
);

final ecommerceProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(ecommerceDatasourceProvider).getProducts();
});

final ecommercePaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return ref.watch(ecommerceDatasourceProvider).getPaymentMethods();
});

final ecommerceControllerProvider =
    StateNotifierProvider<EcommerceController, EcommerceState>(
      (ref) => EcommerceController(
        addProductToCart: const AddProductToCart(),
        updateCartItemQuantity: const UpdateCartItemQuantity(),
        selectPaymentMethod: const SelectPaymentMethod(),
      ),
    );

@immutable
class EcommerceState {
  const EcommerceState({
    this.cartItems = const [],
    this.selectedPaymentMethodId = 'mastercard',
    this.billingSameAsShipping = true,
  });

  final List<CartItem> cartItems;
  final String selectedPaymentMethodId;
  final bool billingSameAsShipping;

  double get total {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  EcommerceState copyWith({
    List<CartItem>? cartItems,
    String? selectedPaymentMethodId,
    bool? billingSameAsShipping,
  }) {
    return EcommerceState(
      cartItems: cartItems ?? this.cartItems,
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      billingSameAsShipping:
          billingSameAsShipping ?? this.billingSameAsShipping,
    );
  }
}

class EcommerceController extends StateNotifier<EcommerceState> {
  EcommerceController({
    required AddProductToCart addProductToCart,
    required UpdateCartItemQuantity updateCartItemQuantity,
    required SelectPaymentMethod selectPaymentMethod,
  }) : _addProductToCart = addProductToCart,
       _updateCartItemQuantity = updateCartItemQuantity,
       _selectPaymentMethod = selectPaymentMethod,
       super(const EcommerceState());

  final AddProductToCart _addProductToCart;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final SelectPaymentMethod _selectPaymentMethod;

  void addToCart(Product product) {
    state = state.copyWith(
      cartItems: _addProductToCart(
        currentItems: state.cartItems,
        product: product,
      ),
    );
  }

  void updateQuantity(String productId, int quantity) {
    state = state.copyWith(
      cartItems: _updateCartItemQuantity(
        currentItems: state.cartItems,
        productId: productId,
        quantity: quantity,
      ),
    );
  }

  void selectPaymentMethod(String paymentMethodId) {
    state = state.copyWith(
      selectedPaymentMethodId: _selectPaymentMethod(paymentMethodId),
    );
  }

  void setBillingSameAsShipping(bool value) {
    state = state.copyWith(billingSameAsShipping: value);
  }
}
