import '../entities/product.dart';
import '../repositories/ecommerce_repository.dart';

class UpdateProduct {
  const UpdateProduct({required this.repository});

  final EcommerceRepository repository;

  Future<void> call(Product product) {
    return repository.updateProduct(product);
  }
}
