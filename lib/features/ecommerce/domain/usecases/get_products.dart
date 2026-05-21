import '../entities/product.dart';
import '../repositories/ecommerce_repository.dart';

class GetProducts {
  const GetProducts({required this.repository});

  final EcommerceRepository repository;

  List<Product> call() {
    return repository.getProducts();
  }
}
