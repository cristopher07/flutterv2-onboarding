import 'package:flutter/foundation.dart';

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.sizes,
    required this.colors,
    this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final List<String> sizes;
  final List<int> colors;
  final String? imageUrl;
}
