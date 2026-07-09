class Purchase {
  const Purchase({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String status;
  final double total;
  final DateTime createdAt;
  final List<PurchaseItem> items;
}

class PurchaseItem {
  const PurchaseItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
}
