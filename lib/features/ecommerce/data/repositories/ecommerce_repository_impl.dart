import '../../domain/entities/payment_method.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../datasources/ecommerce_mock_datasource.dart';

class EcommerceRepositoryImpl implements EcommerceRepository {
  const EcommerceRepositoryImpl({required this.datasource});

  final EcommerceMockDatasource datasource;

  @override
  List<Product> getProducts() {
    return datasource.getProducts();
  }

  @override
  List<PaymentMethod> getPaymentMethods() {
    return datasource.getPaymentMethods();
  }
}
