// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'payment_method_model.dart';

mixin _$PaymentMethodModel {
  String get id;
  String get brand;
  String get lastDigits;

  $PaymentMethodModelCopyWith<PaymentMethodModel> get copyWith;
}

abstract class $PaymentMethodModelCopyWith<$Res> {
  factory $PaymentMethodModelCopyWith(
    PaymentMethodModel value,
    $Res Function(PaymentMethodModel) then,
  ) = _$PaymentMethodModelCopyWithImpl<$Res>;

  $Res call({String? id, String? brand, String? lastDigits});
}

class _$PaymentMethodModelCopyWithImpl<$Res>
    implements $PaymentMethodModelCopyWith<$Res> {
  _$PaymentMethodModelCopyWithImpl(this._value, this._then);

  final PaymentMethodModel _value;
  final $Res Function(PaymentMethodModel) _then;

  @override
  $Res call({String? id, String? brand, String? lastDigits}) {
    return _then(
      _PaymentMethodModel(
        id: id ?? _value.id,
        brand: brand ?? _value.brand,
        lastDigits: lastDigits ?? _value.lastDigits,
      ),
    );
  }
}

class _PaymentMethodModel implements PaymentMethodModel {
  const _PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.lastDigits,
  });

  @override
  final String id;
  @override
  final String brand;
  @override
  final String lastDigits;

  @override
  $PaymentMethodModelCopyWith<PaymentMethodModel> get copyWith =>
      _$PaymentMethodModelCopyWithImpl<PaymentMethodModel>(
        this,
        (value) => value,
      );

  @override
  String toString() {
    return 'PaymentMethodModel(id: $id, brand: $brand, lastDigits: $lastDigits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PaymentMethodModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            brand == other.brand &&
            lastDigits == other.lastDigits;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, brand, lastDigits);
}
