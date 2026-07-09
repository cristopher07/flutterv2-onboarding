import '../entities/purchase.dart';
import '../repositories/ecommerce_repository.dart';

class WatchUserPurchases {
  const WatchUserPurchases({required EcommerceRepository repository})
    : _repository = repository;

  final EcommerceRepository _repository;

  Stream<List<Purchase>> call(String userId) {
    return _repository.watchUserPurchases(userId);
  }
}
