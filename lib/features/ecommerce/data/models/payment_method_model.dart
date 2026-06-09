import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/payment_method.dart';

part 'payment_method_model.freezed.dart';

@freezed
abstract class PaymentMethodModel with _$PaymentMethodModel {
  const factory PaymentMethodModel({
    required String id,
    required String brand,
    required String lastDigits,
  }) = _PaymentMethodModel;
}

extension PaymentMethodModelMapper on PaymentMethodModel {
  PaymentMethod fromModel() {
    return PaymentMethod(
      id: id,
      brand: brand,
      lastDigits: lastDigits,
      cardNumber: switch (id) {
        'visa_low_funds' => '4111111111111111',
        'visa_mid_funds' => '4242424242424242',
        'mastercard_high_funds' => '5555555555554444',
        'declined_card' => '4000000000000002',
        _ => '',
      },
    );
  }
}
