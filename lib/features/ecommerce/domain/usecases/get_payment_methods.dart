import '../entities/payment_method.dart';
import '../repositories/ecommerce_repository.dart';

class GetPaymentMethods {
  const GetPaymentMethods({required this.repository});

  final EcommerceRepository repository;

  List<PaymentMethod> call() {
    return repository.getPaymentMethods();
  }
}
