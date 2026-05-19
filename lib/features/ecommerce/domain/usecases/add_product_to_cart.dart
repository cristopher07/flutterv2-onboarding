import '../entities/cart_item.dart';
import '../entities/product.dart';

class AddProductToCart {
  const AddProductToCart();

  List<CartItem> call({
    required List<CartItem> currentItems,
    required Product product,
  }) {
    final updatedItems = [...currentItems];
    final itemIndex = updatedItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (itemIndex == -1) {
      updatedItems.add(CartItem(product: product));
      return updatedItems;
    }

    final currentItem = updatedItems[itemIndex];
    updatedItems[itemIndex] = currentItem.copyWith(
      quantity: currentItem.quantity + 1,
    );
    return updatedItems;
  }
}
