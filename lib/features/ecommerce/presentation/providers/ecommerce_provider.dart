import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/http/api_exception.dart';
import '../../../../core/http/http_client.dart';
import '../../data/datasources/ecommerce_mock_datasource.dart';
import '../../data/datasources/ecommerce_payment_datasource.dart';
import '../../data/repositories/ecommerce_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../../domain/usecases/add_product_to_cart.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/select_payment_method.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';

const _paymentBaseUrl = 'https://processpayment-sfdkfoab2q-uc.a.run.app';
const _unset = Object();

final ecommerceDatasourceProvider = Provider<EcommerceMockDatasource>(
  (ref) => const EcommerceMockDatasource(),
);

final ecommercePaymentDatasourceProvider = Provider<EcommercePaymentDatasource>(
  (ref) =>
      EcommercePaymentDatasource(client: HttpClient(baseUrl: _paymentBaseUrl)),
);

final ecommerceRepositoryProvider = Provider<EcommerceRepository>((ref) {
  return EcommerceRepositoryImpl(
    datasource: ref.watch(ecommerceDatasourceProvider),
    paymentDatasource: ref.watch(ecommercePaymentDatasourceProvider),
  );
});

final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(repository: ref.watch(ecommerceRepositoryProvider));
});

final ecommerceProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(getProductsProvider)();
});

final getPaymentMethodsProvider = Provider<GetPaymentMethods>((ref) {
  return GetPaymentMethods(repository: ref.watch(ecommerceRepositoryProvider));
});

final ecommercePaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return ref.watch(getPaymentMethodsProvider)();
});

final processPaymentProvider = Provider<ProcessPayment>((ref) {
  return ProcessPayment(repository: ref.watch(ecommerceRepositoryProvider));
});

final ecommerceControllerProvider =
    StateNotifierProvider<EcommerceController, EcommerceState>(
      (ref) => EcommerceController(
        addProductToCart: const AddProductToCart(),
        updateCartItemQuantity: const UpdateCartItemQuantity(),
        selectPaymentMethod: const SelectPaymentMethod(),
        processPayment: ref.watch(processPaymentProvider),
      ),
    );

@immutable
class EcommerceState {
  const EcommerceState({
    this.cartItems = const [],
    this.selectedPaymentMethodId = 'visa_mid_funds',
    this.billingSameAsShipping = true,
    this.isProcessingPayment = false,
    this.paymentResult,
    this.paymentError,
  });

  final List<CartItem> cartItems;
  final String selectedPaymentMethodId;
  final bool billingSameAsShipping;
  final bool isProcessingPayment;
  final PaymentResult? paymentResult;
  final String? paymentError;

  double get total {
    return cartItems.fold(0, (sum, item) => sum + item.subtotal);
  }

  EcommerceState copyWith({
    List<CartItem>? cartItems,
    String? selectedPaymentMethodId,
    bool? billingSameAsShipping,
    bool? isProcessingPayment,
    Object? paymentResult = _unset,
    Object? paymentError = _unset,
  }) {
    return EcommerceState(
      cartItems: cartItems ?? this.cartItems,
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      billingSameAsShipping:
          billingSameAsShipping ?? this.billingSameAsShipping,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      paymentResult:
          identical(paymentResult, _unset)
              ? this.paymentResult
              : paymentResult as PaymentResult?,
      paymentError:
          identical(paymentError, _unset)
              ? this.paymentError
              : paymentError as String?,
    );
  }
}

class EcommerceController extends StateNotifier<EcommerceState> {
  EcommerceController({
    required AddProductToCart addProductToCart,
    required UpdateCartItemQuantity updateCartItemQuantity,
    required SelectPaymentMethod selectPaymentMethod,
    required ProcessPayment processPayment,
  }) : _addProductToCart = addProductToCart,
       _updateCartItemQuantity = updateCartItemQuantity,
       _selectPaymentMethod = selectPaymentMethod,
       _processPayment = processPayment,
       super(const EcommerceState());

  final AddProductToCart _addProductToCart;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final SelectPaymentMethod _selectPaymentMethod;
  final ProcessPayment _processPayment;

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
      paymentResult: null,
      paymentError: null,
    );
  }

  void setBillingSameAsShipping(bool value) {
    state = state.copyWith(billingSameAsShipping: value);
  }

  Future<void> processSelectedPayment(List<PaymentMethod> methods) async {
    final selectedMethod = methods.where(
      (method) => method.id == state.selectedPaymentMethodId,
    );

    if (state.cartItems.isEmpty) {
      state = state.copyWith(
        paymentResult: null,
        paymentError: 'Agrega productos al carrito antes de pagar.',
      );
      return;
    }

    if (selectedMethod.isEmpty || selectedMethod.first.cardNumber.isEmpty) {
      state = state.copyWith(
        paymentResult: null,
        paymentError: 'Selecciona una tarjeta de prueba para procesar el pago.',
      );
      return;
    }

    state = state.copyWith(
      isProcessingPayment: true,
      paymentResult: null,
      paymentError: null,
    );

    try {
      final result = await _processPayment(
        amount: state.total,
        paymentMethod: selectedMethod.first,
      );

      state = state.copyWith(
        isProcessingPayment: false,
        paymentResult: result,
        paymentError: null,
      );
    } on ApiException catch (error) {
      state = state.copyWith(
        isProcessingPayment: false,
        paymentResult: null,
        paymentError: error.message,
      );
    } catch (_) {
      state = state.copyWith(
        isProcessingPayment: false,
        paymentResult: null,
        paymentError: 'No se pudo procesar el pago. Intenta de nuevo.',
      );
    }
  }
}
