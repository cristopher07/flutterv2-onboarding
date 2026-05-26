import '../../domain/entities/payment_method.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/ecommerce_repository.dart';
import '../datasources/ecommerce_mock_datasource.dart';
import '../models/payment_method_model.dart';
import '../models/product_model.dart';

class EcommerceRepositoryImpl implements EcommerceRepository {
  const EcommerceRepositoryImpl({required this.datasource});

  final EcommerceMockDatasource datasource;

  @override
  List<Product> getProducts() {
    return datasource
        .getProducts()
        .map((productModel) => productModel.fromModel())
        .toList();
  }

  @override
  List<PaymentMethod> getPaymentMethods() {
    return datasource
        .getPaymentMethods()
        .map((paymentMethodModel) => paymentMethodModel.fromModel())
        .toList();
  }
}
