import '../entities/payment_method.dart';
import '../entities/payment_result.dart';
import '../entities/product.dart';

abstract class EcommerceRepository {
  Future<List<Product>> getProducts();

  Future<void> createProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String productId);

  List<PaymentMethod> getPaymentMethods();

  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'USD',
  });
}
