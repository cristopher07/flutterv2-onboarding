// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'product_model.dart';

mixin _$ProductModel {
  String get id;
  String get name;
  double get price;
  String get description;
  String get category;
  List<String> get sizes;
  List<int> get colors;

  $ProductModelCopyWith<ProductModel> get copyWith;
}

abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res>;

  $Res call({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    List<String>? sizes,
    List<int>? colors,
  });
}

class _$ProductModelCopyWithImpl<$Res> implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  final ProductModel _value;
  final $Res Function(ProductModel) _then;

  @override
  $Res call({
    String? id,
    String? name,
    double? price,
    String? description,
    String? category,
    List<String>? sizes,
    List<int>? colors,
  }) {
    return _then(
      _ProductModel(
        id: id ?? _value.id,
        name: name ?? _value.name,
        price: price ?? _value.price,
        description: description ?? _value.description,
        category: category ?? _value.category,
        sizes: sizes ?? _value.sizes,
        colors: colors ?? _value.colors,
      ),
    );
  }
}

class _ProductModel implements ProductModel {
  const _ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.sizes,
    required this.colors,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final double price;
  @override
  final String description;
  @override
  final String category;
  @override
  final List<String> sizes;
  @override
  final List<int> colors;

  @override
  $ProductModelCopyWith<ProductModel> get copyWith =>
      _$ProductModelCopyWithImpl<ProductModel>(this, (value) => value);

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, description: $description, category: $category, sizes: $sizes, colors: $colors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProductModel &&
            runtimeType == other.runtimeType &&
            id == other.id &&
            name == other.name &&
            price == other.price &&
            description == other.description &&
            category == other.category &&
            sizes == other.sizes &&
            colors == other.colors;
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    price,
    description,
    category,
    sizes,
    colors,
  );
}
