import '../entities/purchase.dart';
import '../repositories/ecommerce_repository.dart';

class CreatePurchase {
  const CreatePurchase({required EcommerceRepository repository})
    : _repository = repository;

  final EcommerceRepository _repository;

  Future<void> call(Purchase purchase) {
    return _repository.createPurchase(purchase);
  }
}
