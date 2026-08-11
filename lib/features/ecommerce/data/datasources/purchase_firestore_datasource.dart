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

  Future<PurchasePageModel> getUserPurchasesPage({
    required String userId,
    required int pageSize,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    if (userId.isEmpty) {
      return const PurchasePageModel(
        purchases: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    // Firestore pagination with a composite query. If Firestore asks for an
    // index, the UI will surface the exact error link.
    Query<Map<String, dynamic>> query = _purchases
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    try {
      return await _getPageFromQuery(query, lastDocument, pageSize: pageSize);
    } on FirebaseException catch (error) {
      if (error.code != 'failed-precondition') rethrow;

      Query<Map<String, dynamic>> fallbackQuery = _purchases
          .where('userId', isEqualTo: userId)
          .limit(pageSize);

      if (lastDocument != null) {
        fallbackQuery = fallbackQuery.startAfterDocument(lastDocument);
      }

      return await _getPageFromQuery(
        fallbackQuery,
        lastDocument,
        pageSize: pageSize,
        sortLocally: true,
      );
    }
  }

  Future<PurchasePageModel> _getPageFromQuery(
    Query<Map<String, dynamic>> query,
    DocumentSnapshot<Map<String, dynamic>>? previousDocument, {
    required int pageSize,
    bool sortLocally = false,
  }) async {
    final snapshot = await query.get();
    final purchases = snapshot.docs.map(PurchaseModel.fromFirestore).toList();

    if (sortLocally) {
      purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return PurchasePageModel(
      purchases: purchases,
      lastDocument:
          snapshot.docs.isEmpty ? previousDocument : snapshot.docs.last,
      hasMore: snapshot.docs.length == pageSize,
    );
  }
}

class PurchasePageModel {
  const PurchasePageModel({
    required this.purchases,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<PurchaseModel> purchases;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}
