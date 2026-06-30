import '../repositories/ecommerce_repository.dart';

class DeleteProduct {
  const DeleteProduct({required this.repository});

  final EcommerceRepository repository;

  Future<void> call(String productId) {
    return repository.deleteProduct(productId);
  }
}
