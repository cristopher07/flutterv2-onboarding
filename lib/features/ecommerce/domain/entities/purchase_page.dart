import 'purchase.dart';

class PurchasePage {
  const PurchasePage({
    required this.purchases,
    required this.cursor,
    required this.hasMore,
  });

  final List<Purchase> purchases;
  final Object? cursor;
  final bool hasMore;
}
