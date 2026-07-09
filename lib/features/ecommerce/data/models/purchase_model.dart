import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/purchase.dart';

class PurchaseModel extends Purchase {
  const PurchaseModel({
    required super.id,
    required super.userId,
    required super.userEmail,
    required super.status,
    required super.total,
    required super.createdAt,
    required super.items,
  });

  factory PurchaseModel.fromEntity(Purchase purchase) {
    return PurchaseModel(
      id: purchase.id,
      userId: purchase.userId,
      userEmail: purchase.userEmail,
      status: purchase.status,
      total: purchase.total,
      createdAt: purchase.createdAt,
      items: purchase.items,
    );
  }

  factory PurchaseModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return PurchaseModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      userEmail: data['userEmail']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      total: _toDouble(data['total']),
      createdAt: _toDateTime(data['createdAt']),
      items: _parseItems(data['items']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'status': status,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'items':
          items
              .map(
                (item) => {
                  'productId': item.productId,
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'imageUrl': item.imageUrl ?? '',
                },
              )
              .toList(),
    };
  }

  static List<PurchaseItem> _parseItems(dynamic value) {
    if (value is! List) return const [];

    final maps =
        value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

    if (maps.isEmpty) return const [];

    final hasSplitFields = maps.every((item) => item.length <= 1);
    if (hasSplitFields) {
      final merged = <String, dynamic>{};
      for (final item in maps) {
        merged.addAll(item);
      }
      return [_parseItem(merged)];
    }

    return maps.map(_parseItem).toList();
  }

  static PurchaseItem _parseItem(Map<String, dynamic> data) {
    return PurchaseItem(
      productId: data['productId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      price: _toDouble(data['price']),
      quantity: _toInt(data['quantity']),
      imageUrl: data['imageUrl']?.toString(),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
