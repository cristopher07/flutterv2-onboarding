import 'package:flutter/foundation.dart';

@immutable
class PaymentResult {
  const PaymentResult({
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
}
