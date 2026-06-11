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
      );
    }).toList();
  }

  static int? _colorFromFirestore(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }
}
