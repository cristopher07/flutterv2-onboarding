import '../entities/payment_method.dart';
import '../entities/product.dart';

abstract class EcommerceRepository {
  List<Product> getProducts();

  List<PaymentMethod> getPaymentMethods();
}
