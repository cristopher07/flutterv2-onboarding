import 'package:flutter/foundation.dart';

@immutable
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.lastDigits,
  });

  final String id;
  final String brand;
  final String lastDigits;
}
