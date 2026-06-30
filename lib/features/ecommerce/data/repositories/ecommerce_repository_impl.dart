import '../../domain/entities/payment_method.dart';
import '../../domain/entities/payment_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../datasources/ecommerce_firestore_datasource.dart';
import '../datasources/ecommerce_mock_datasource.dart';
import '../datasources/ecommerce_payment_datasource.dart';
import '../models/payment_method_model.dart';
import '../models/product_model.dart';

class EcommerceRepositoryImpl implements EcommerceRepository {
  const EcommerceRepositoryImpl({
    required this.firestoreDatasource,
    required this.mockDatasource,
    required this.paymentDatasource,
  });

  final EcommerceFirestoreDatasource firestoreDatasource;
  final EcommerceMockDatasource mockDatasource;
  final EcommercePaymentDatasource paymentDatasource;

  @override
  Future<List<Product>> getProducts() async {
    final products = await firestoreDatasource.getProducts();

    return products.map((productModel) => productModel.fromModel()).toList();
  }

  @override
  Future<void> createProduct(Product product) {
    return firestoreDatasource.createProduct(_productToModel(product));
  }

  @override
  Future<void> updateProduct(Product product) {
    return firestoreDatasource.updateProduct(_productToModel(product));
  }

  @override
  Future<void> deleteProduct(String productId) {
    return firestoreDatasource.deleteProduct(productId);
  }

  @override
  List<PaymentMethod> getPaymentMethods() {
    return mockDatasource
        .getPaymentMethods()
        .map((paymentMethodModel) => paymentMethodModel.fromModel())
        .toList();
  }

  @override
  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'USD',
  }) async {
    final result = await paymentDatasource.processPayment(
      amount: amount,
      cardNumber: paymentMethod.cardNumber,
      currency: currency,
    );

    return result.fromModel();
  }

  ProductModel _productToModel(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      description: product.description,
      category: product.category,
      sizes: product.sizes,
      colors: product.colors,
      imageUrl: product.imageUrl,
    );
  }
}
