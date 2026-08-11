import '../entities/purchase_page.dart';
import '../repositories/ecommerce_repository.dart';

class GetUserPurchasesPage {
  const GetUserPurchasesPage({required EcommerceRepository repository})
    : _repository = repository;

  final EcommerceRepository _repository;

  Future<PurchasePage> call({
    required String userId,
    required int pageSize,
    Object? cursor,
  }) {
    return _repository.getUserPurchasesPage(
      userId: userId,
      pageSize: pageSize,
      cursor: cursor,
    );
  }
}
