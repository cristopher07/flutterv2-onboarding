import '../entities/product.dart';
import '../repositories/ecommerce_repository.dart';

class CreateProduct {
  const CreateProduct({required this.repository});

  final EcommerceRepository repository;

  Future<void> call(Product product) {
    return repository.createProduct(product);
  }
}
