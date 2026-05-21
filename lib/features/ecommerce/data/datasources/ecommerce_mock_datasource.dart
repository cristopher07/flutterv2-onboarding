import '../models/payment_method_model.dart';
import '../models/product_model.dart';

class EcommerceMockDatasource {
  const EcommerceMockDatasource();

  List<ProductModel> getProducts() {
    return const [
      ProductModel(
        id: 'amazing-tshirt',
        name: 'Amazing T-shirt',
        price: 12,
        category: 'Perfect for you',
        description:
            'The perfect T-shirt for when you want to feel comfortable but still stylish. Amazing for all occasions.',
        sizes: ['XS', 'S', 'M', 'L', 'XL'],
        colors: [0xFF202124, 0xFF70727A, 0xFFC2C4CA, 0xFFE8EAF1],
      ),
      ProductModel(
        id: 'fabulous-pants',
        name: 'Fabulous Pants',
        price: 15,
        category: 'Perfect for you',
        description: 'Easy pants with a clean silhouette for daily outfits.',
        sizes: ['40', '42', '44'],
        colors: [0xFF1F2937, 0xFF93C5FD],
      ),
      ProductModel(
        id: 'fabulous-jeans',
        name: 'Fabulous Jeans',
        price: 18,
        category: 'Perfect for you',
        description: 'Comfortable jeans with a modern fit for any occasion.',
        sizes: ['32', '34', '36'],
        colors: [0xFF1F2937, 0xFF93C5FD],
      ),
      ProductModel(
        id: 'spectacular-dress',
        name: 'Spectacular Dress',
        price: 20,
        category: 'For this summer',
        description: 'Light dress made for warm days and relaxed plans.',
        sizes: ['S', 'M', 'L'],
        colors: [0xFFD4AF37, 0xFFE5E7EB],
      ),
      ProductModel(
        id: 'stunning-jacket',
        name: 'Stunning Jacket',
        price: 18,
        category: 'For this summer',
        description:
            'A light jacket that adds structure without feeling heavy.',
        sizes: ['S', 'M', 'L'],
        colors: [0xFF60A5FA, 0xFF111827],
      ),
       ProductModel(
        id: 'stunning-jacket',
        name: 'Stunning Jacket',
        price: 18,
        category: 'For this summer',
        description:
            'A light jacket that adds structure without feeling heavy.',
        sizes: ['S', 'M', 'L'],
        colors: [0xFF60A5FA, 0xFF111827],
      ),
    ];
  }

  List<PaymentMethodModel> getPaymentMethods() {
    return const [
      PaymentMethodModel(
        id: 'mastercard',
        brand: 'Mastercard',
        lastDigits: '1234',
      ),
      PaymentMethodModel(id: 'visa', brand: 'Visa', lastDigits: '9876'),
    ];
  }
}
