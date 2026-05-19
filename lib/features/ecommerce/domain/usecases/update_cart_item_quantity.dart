import '../entities/cart_item.dart';

class UpdateCartItemQuantity {
  const UpdateCartItemQuantity();

  List<CartItem> call({
    required List<CartItem> currentItems,
    required String productId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      return currentItems
          .where((item) => item.product.id != productId)
          .toList(growable: false);
    }

    return currentItems
        .map((item) {
          if (item.product.id != productId) return item;
          return item.copyWith(quantity: quantity);
        })
        .toList(growable: false);
  }
}
