import '../entities/payment_method.dart';
import '../entities/payment_result.dart';
import '../entities/product.dart';

abstract class EcommerceRepository {
  List<Product> getProducts();

  List<PaymentMethod> getPaymentMethods();

  Future<PaymentResult> processPayment({
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'USD',
  });
}
