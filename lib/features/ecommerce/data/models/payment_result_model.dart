import '../../domain/entities/payment_result.dart';

class PaymentResultModel {
  const PaymentResultModel({
    required this.success,
    required this.status,
    required this.amount,
    required this.currency,
    required this.cardLast4,
    required this.message,
    required this.timestamp,
    this.transactionId,
  });

  final bool success;
  final String status;
  final String? transactionId;
  final double amount;
  final String currency;
  final String cardLast4;
  final String message;
  final DateTime timestamp;

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    return PaymentResultModel(
      success: json['success'] as bool? ?? false,
      status: json['status'] as String? ?? 'unknown',
      transactionId: json['transactionId'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      cardLast4: json['cardLast4'] as String? ?? '',
      message: json['message'] as String? ?? 'No se pudo procesar el pago.',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  PaymentResult fromModel() {
    return PaymentResult(
      success: success,
      status: status,
      transactionId: transactionId,
      amount: amount,
      currency: currency,
      cardLast4: cardLast4,
      message: message,
      timestamp: timestamp,
    );
  }
}
