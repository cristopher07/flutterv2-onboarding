# Flujo Clean Architecture en E-commerce

Esta feature separa responsabilidades por capas para que la pantalla no dependa directamente de datos mock, API o base de datos.

## Flujo general

```txt
View
  -> Provider / Controller
  -> UseCase
  -> Repository abstracto
  -> Repository implementation
  -> Datasource
  -> Model
```

## Ejemplo con productos

La pantalla `EcommerceHomeView` no pide productos directamente al datasource. La pantalla solo lee este provider:

```dart
final products = ref.watch(ecommerceProductsProvider);
```

Ese provider llama al caso de uso:

```dart
final ecommerceProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(getProductsProvider)();
});
```

El caso de uso vive en `domain/usecases/get_products.dart` y llama al repository abstracto:

```dart
class GetProducts {
  const GetProducts({required this.repository});

  final EcommerceRepository repository;

  List<Product> call() {
    return repository.getProducts();
  }
}
```

El repository abstracto vive en `domain/repositories/ecommerce_repository.dart`. Esta capa solo define lo que la app necesita:

```dart
abstract class EcommerceRepository {
  List<Product> getProducts();

  List<PaymentMethod> getPaymentMethods();
}
```

La implementación real vive en `data/repositories/ecommerce_repository_impl.dart`:

```dart
class EcommerceRepositoryImpl implements EcommerceRepository {
  const EcommerceRepositoryImpl({required this.datasource});

  final EcommerceMockDatasource datasource;

  @override
  List<Product> getProducts() {
    return datasource.getProducts();
  }
}
```

Finalmente, el datasource mock vive en `data/datasources/ecommerce_mock_datasource.dart` y devuelve `ProductModel`.

## Por qué hacerlo así

La pantalla no sabe si los productos vienen de mock, API o base de datos. Solo sabe que recibe una lista de `Product`.

Si mañana cambias el mock por una API, normalmente solo cambias la capa `data`, no la pantalla.

## Responsabilidad de cada capa

`presentation`

Pantallas, widgets, providers y controllers. Maneja UI y estado de pantalla.

`domain`

Entidades, casos de uso y contratos. No debe depender de Flutter ni de detalles externos.

`data`

Modelos, datasources e implementaciones de repositories. Aquí viven los detalles de dónde vienen los datos.

## Flujo actual de productos

```txt
EcommerceHomeView
  -> ecommerceProductsProvider
    -> GetProducts
      -> EcommerceRepository
        -> EcommerceRepositoryImpl
          -> EcommerceMockDatasource 
            -> ProductModel
```

## Flujo actual de métodos de pago

```txt
CheckoutPaymentView
  -> ecommercePaymentMethodsProvider
  -> GetPaymentMethods
  -> EcommerceRepository
  -> EcommerceRepositoryImpl
  -> EcommerceMockDatasource
  -> PaymentMethodModel
```


shared prefrences 

es una librería que está usando el maestro para un local storage 

para que sir