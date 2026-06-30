import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/product.dart';

part 'product_model.freezed.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    required String description,
    required String category,
    required List<String> sizes,
    required List<int> colors,
    String? imageUrl,
  }) = _ProductModel;
}

extension ProductModelMapper on ProductModel {
  Product fromModel() {
    return Product(
      id: id,
      name: name,
      price: price,
      description: description,
      category: category,
      sizes: sizes,
      colors: colors,
      imageUrl: imageUrl,
    );
  }
}
