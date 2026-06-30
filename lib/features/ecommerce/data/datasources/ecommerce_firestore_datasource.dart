import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class EcommerceFirestoreDatasource {
  const EcommerceFirestoreDatasource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final price = data['price'];

      return ProductModel(
        id: doc.id,
        name: data['name'] as String? ?? '',
        price: price is num ? price.toDouble() : 0,
        description: data['description'] as String? ?? '',
        category: data['category'] as String? ?? '',
        sizes:
            (data['sizes'] as List<dynamic>? ?? const [])
                .map((size) => size.toString())
                .toList(),
        colors:
            (data['colors'] as List<dynamic>? ?? const [])
                .map(_colorFromFirestore)
                .whereType<int>()
                .toList(),
        imageUrl: data['imageUrl'] as String?,
      );
    }).toList();
  }

  Future<void> createProduct(ProductModel product) {
    return _firestore.collection('products').add(_productToFirestore(product));
  }

  Future<void> updateProduct(ProductModel product) {
    return _firestore
        .collection('products')
        .doc(product.id)
        .update(_productToFirestore(product));
  }

  Future<void> deleteProduct(String productId) {
    return _firestore.collection('products').doc(productId).delete();
  }

  Map<String, dynamic> _productToFirestore(ProductModel product) {
    return {
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'sizes': product.sizes,
      'colors': product.colors,
      'imageUrl': product.imageUrl,
    };
  }

  static int? _colorFromFirestore(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }
}
