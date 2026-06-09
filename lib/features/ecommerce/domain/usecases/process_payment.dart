import '../entities/payment_method.dart';
import '../entities/payment_result.dart';
import '../repositories/ecommerce_repository.dart';

class ProcessPayment {
  const ProcessPayment({required this.repository});

  final EcommerceRepository repository;

  Future<PaymentResult> call({
    required double amount,
    required PaymentMethod paymentMethod,
    String currency = 'USD',
  }) {
    return repository.processPayment(
      amount: amount,
      paymentMethod: paymentMethod,
      currency: currency,
    );
  }
}
