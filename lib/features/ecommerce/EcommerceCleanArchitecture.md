# Flujo Clean Architecture en E-commerce

Esta feature separa responsabilidades por capas para que las pantallas no dependan directamente de datos mock, API o base de datos.

## Flujo general

```txt
View
  -> Provider / Controller
  -> UseCase
  -> Repository abstracto
  -> Repository implementation
  -> Datasource
  -> Model con Freezed
```

## Flujo actual de lectura

```txt
EcommerceHomeView
  -> ecommerceProductsProvider
  -> GetProducts
  -> EcommerceRepository
  -> EcommerceRepositoryImpl
  -> EcommerceMockDatasource
  -> ProductModel
  -> fromModel()
  -> Product
```

El datasource devuelve modelos:

```dart
List<ProductModel> getProducts() {
  return const [
    ProductModel(
      id: 'amazing-tshirt',
      name: 'Amazing T-shirt',
      price: 12,
      category: 'Perfect for you',
      description: '...',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
      colors: [0xFF202124, 0xFF70727A],
    ),
  ];
}
```

El repository convierte esos modelos a entidades:

```dart
@override
List<Product> getProducts() {
  return datasource
      .getProducts()
      .map((productModel) => productModel.fromModel())
      .toList();
}
```

## Model con Freezed

Los modelos viven en `data/models`. Representan la forma en que llega la data desde una fuente externa o mock.

Ejemplo:

```dart
@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required double price,
    required String description,
    required String category,
    required List<String> sizes,
    required List<int> colors,
  }) = _ProductModel;
}
```

`freezed` ayuda a crear modelos inmutables, comparacion por valor y `copyWith`.

## fromModel

`fromModel()` convierte un model de la capa `data` a una entidad de la capa `domain`.

```dart
extension ProductModelMapper on ProductModel {
  Product fromModel() {
    return Product(
      id: id,
      name: name,
      price: price,
      description: description,
      category: category,
      sizes: sizes,
      colors: colors,
    );
  }
}
```

La entidad `Product` es la que usa la app por dentro:

```dart
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.sizes,
    required this.colors,
  });

  final String id;
  final String name;
  final double price;
  final String description;
  final String category;
  final List<String> sizes;
  final List<int> colors;
}
```

## Por que el mapper vive en data

La entidad `Product` pertenece a `domain`.

El modelo `ProductModel` pertenece a `data`.

Para mantener clean architecture, `domain` no debe conocer `ProductModel`. Por eso la conversion se hace desde `data`, en el mapper o en el repository implementation.

## Flujo con metodos de pago

```txt
CheckoutPaymentView
  -> ecommercePaymentMethodsProvider
  -> GetPaymentMethods
  -> EcommerceRepository
  -> EcommerceRepositoryImpl
  -> EcommerceMockDatasource
  -> PaymentMethodModel
  -> fromModel()
  -> PaymentMethod
```

Ejemplo:

```dart
extension PaymentMethodModelMapper on PaymentMethodModel {
  PaymentMethod fromModel() {
    return PaymentMethod(
      id: id,
      brand: brand,
      lastDigits: lastDigits,
    );
  }
}
```

## Responsabilidad de cada capa

`presentation`

Pantallas, widgets, providers y controllers. Maneja UI y estado de pantalla.

`domain`

Entidades, casos de uso y contratos de repositories. No debe depender de Flutter, modelos, API ni storage.

`data`

Modelos con Freezed, datasources, mappers e implementaciones de repositories. Aqui viven los detalles de donde vienen los datos.

## Regla practica

```txt
Presentation usa Entity
Domain usa Entity
Data usa Model y convierte a Entity
```

La pantalla nunca deberia usar `ProductModel` directamente. Debe recibir `Product`.

## Comando para generar Freezed

Cuando Flutter este disponible en la terminal:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
