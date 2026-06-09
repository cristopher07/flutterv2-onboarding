import '../../../../core/http/http_client.dart';
import '../models/payment_result_model.dart';

class EcommercePaymentDatasource {
  const EcommercePaymentDatasource({required this.client});

  final HttpClient client;

  Future<PaymentResultModel> processPayment({
    required double amount,
    required String cardNumber,
    String currency = 'USD',
  }) {
    return client.post<PaymentResultModel>(
      endpoint: '',
      body: {'amount': amount, 'cardNumber': cardNumber, 'currency': currency},
      fromJson: PaymentResultModel.fromJson,
    );
  }
}
