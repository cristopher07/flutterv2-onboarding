import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/purchase_model.dart';

class PurchaseFirestoreDatasource {
  const PurchaseFirestoreDatasource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _purchases =>
      _firestore.collection('purchases');

  Future<void> createPurchase(PurchaseModel purchase) {
    return _purchases.add(purchase.toFirestore());
  }

  Stream<List<PurchaseModel>> watchUserPurchases(String userId) {
    if (userId.isEmpty) return Stream.value(const []);

    return _purchases.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final purchases = snapshot.docs.map(PurchaseModel.fromFirestore).toList();

      purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return purchases;
    });
  }
}
