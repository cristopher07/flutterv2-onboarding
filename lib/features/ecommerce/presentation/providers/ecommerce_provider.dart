import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/environmet/env.dart';
import '../../../../core/http/api_exception.dart';
import '../../../../core/http/http_client.dart';
import '../../data/datasources/ecommerce_firestore_datasource.dart';
import '../../data/datasources/ecommerce_mock_datasource.dart';
import '../../data/datasources/ecommerce_payment_datasource.dart';
import '../../data/datasources/product_image_storage_datasource.dart';
import '../../data/datasources/purchase_firestore_datasource.dart';
import '../../data/repositories/ecommerce_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../../domain/usecases/add_product_to_cart.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/create_purchase.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/get_payment_methods.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/process_payment.dart';
import '../../domain/usecases/select_payment_method.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';
import '../../domain/usecases/upload_product_image.dart';
import '../../domain/usecases/watch_user_purchases.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

const _paymentBaseUrl = 'https://processpayment-sfdkfoab2q-uc.a.run.app';
const _unset = Object();

final ecommerceDatasourceProvider = Provider<EcommerceMockDatasource>(
  (ref) => const EcommerceMockDatasource(),
);

final ecommerceFirestoreDatasourceProvider = Provider<
  EcommerceFirestoreDatasource
>((ref) => EcommerceFirestoreDatasource(firestore: FirebaseFirestore.instance));

final ecommercePaymentDatasourceProvider = Provider<EcommercePaymentDatasource>(
  (ref) =>
      EcommercePaymentDatasource(client: HttpClient(baseUrl: _paymentBaseUrl)),
);

final productImageStorageDatasourceProvider =
    Provider<ProductImageStorageDatasource>(
      (ref) => ProductImageStorageDatasource(
        cloudName: Env.cloudinaryCloudName,
        uploadPreset: Env.cloudinaryUploadPreset,
      ),
    );

final purchaseFirestoreDatasourceProvider = Provider<
  PurchaseFirestoreDatasource
>((ref) => PurchaseFirestoreDatasource(firestore: FirebaseFirestore.instance));

final ecommerceRepositoryProvider = Provider<EcommerceRepository>((ref) {
  return EcommerceRepositoryImpl(
    firestoreDatasource: ref.watch(ecommerceFirestoreDatasourceProvider),
    mockDatasource: ref.watch(ecommerceDatasourceProvider),
    paymentDatasource: ref.watch(ecommercePaymentDatasourceProvider),
    productImageStorageDatasource: ref.watch(
      productImageStorageDatasourceProvider,
    ),
    purchaseDatasource: ref.watch(purchaseFirestoreDatasourceProvider),
  );
});

final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(repository: ref.watch(ecommerceRepositoryProvider));
});

final createProductProvider = Provider<CreateProduct>((ref) {
  return CreateProduct(repository: ref.watch(ecommerceRepositoryProvider));
});

final updateProductProvider = Provider<UpdateProduct>((ref) {
  return UpdateProduct(repository: ref.watch(ecommerceRepositoryProvider));
});

final deleteProductProvider = Provider<DeleteProduct>((ref) {
  return DeleteProduct(repository: ref.watch(ecommerceRepositoryProvider));
});

final uploadProductImageProvider = Provider<UploadProductImage>((ref) {
  return UploadProductImage(repository: ref.watch(ecommerceRepositoryProvider));
});

final ecommerceProductsProvider = FutureProvider<List<Product>>((ref) {
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

final createPurchaseProvider = Provider<CreatePurchase>((ref) {
  return CreatePurchase(repository: ref.watch(ecommerceRepositoryProvider));
});

final watchUserPurchasesProvider = Provider<WatchUserPurchases>((ref) {
  return WatchUserPurchases(repository: ref.watch(ecommerceRepositoryProvider));
});

final userPurchasesProvider = StreamProvider<List<Purchase>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final userId = auth.currentUser?.uid ?? '';
  return ref.watch(watchUserPurchasesProvider)(userId);
});

final ecommerceControllerProvider =
    StateNotifierProvider<EcommerceController, EcommerceState>(
      (ref) => EcommerceController(
        addProductToCart: const AddProductToCart(),
        updateCartItemQuantity: const UpdateCartItemQuantity(),
        selectPaymentMethod: const SelectPaymentMethod(),
        processPayment: ref.watch(processPaymentProvider),
        createPurchase: ref.watch(createPurchaseProvider),
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
    return cartItems.fold(0, (total, item) => total + item.subtotal);
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
    required CreatePurchase createPurchase,
  }) : _addProductToCart = addProductToCart,
       _updateCartItemQuantity = updateCartItemQuantity,
       _selectPaymentMethod = selectPaymentMethod,
       _processPayment = processPayment,
       _createPurchase = createPurchase,
       super(const EcommerceState());

  final AddProductToCart _addProductToCart;
  final UpdateCartItemQuantity _updateCartItemQuantity;
  final SelectPaymentMethod _selectPaymentMethod;
  final ProcessPayment _processPayment;
  final CreatePurchase _createPurchase;

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

  Future<void> processSelectedPayment(
    List<PaymentMethod> methods, {
    required String userId,
    required String userEmail,
  }) async {
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

    if (userId.isEmpty) {
      state = state.copyWith(
        paymentResult: null,
        paymentError: 'Inicia sesión para registrar la compra.',
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

      if (result.success) {
        await _createPurchase(
          Purchase(
            id: '',
            userId: userId,
            userEmail: userEmail,
            status: 'completed',
            total: state.total,
            createdAt: DateTime.now(),
            items:
                state.cartItems
                    .map(
                      (item) => PurchaseItem(
                        productId: item.product.id,
                        name: item.product.name,
                        price: item.product.price,
                        quantity: item.quantity,
                        imageUrl: item.product.imageUrl,
                      ),
                    )
                    .toList(),
          ),
        );
      }

      state = state.copyWith(
        isProcessingPayment: false,
        cartItems: result.success ? const [] : state.cartItems,
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
