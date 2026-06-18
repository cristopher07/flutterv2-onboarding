# Firebase en este proyecto

Esta guia resume los archivos importantes para conectar la app Flutter con Firebase y consumir datos desde Firestore.

## Servicios usados

- Firebase Authentication: login, registro y cierre de sesion.
- Cloud Firestore: productos y perfil/rol de usuario.
- FlutterFire CLI: genero `lib/firebase_options.dart` y archivos nativos como `google-services.json`.

## Archivos de configuracion

### `lib/firebase_options.dart`

Archivo generado por FlutterFire CLI. Contiene las credenciales publicas del proyecto Firebase por plataforma.

Se usa desde `main.dart`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### `lib/main.dart`

Inicializa Firebase antes de levantar la app:

```dart
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

Sin esto, `FirebaseAuth.instance` y `FirebaseFirestore.instance` no deben usarse.

### `pubspec.yaml`

Dependencias Firebase usadas:

```yaml
firebase_core
cloud_firestore
firebase_auth
```

## Authentication

Auth esta organizado con una separacion parecida a Clean Architecture:

```text
presentation -> domain/usecases -> domain/repository -> data/repository -> data/datasources -> Firebase
```

### Archivos principales

```text
lib/features/auth/
  presentation/
    views/auth_view.dart
    providers/auth_provider.dart
  domain/
    entities/user_profile.dart
    repositories/auth_repository.dart
    usecases/sign_in.dart
    usecases/sign_up.dart
    usecases/sign_out.dart
    usecases/get_current_user_profile.dart
    usecases/get_auth_state_changes.dart
  data/
    datasources/firebase_auth_datasource.dart
    datasources/user_profile_firestore_datasource.dart
    repositories/auth_repository_impl.dart
    models/user_profile_model.dart
```

### `lib/features/auth/presentation/providers/auth_provider.dart`

Conecta Riverpod con los casos de uso. Aqui se crean:

- `firebaseAuthProvider`
- `firebaseAuthDatasourceProvider`
- `userProfileFirestoreDatasourceProvider`
- `authRepositoryProvider`
- `signInProvider`
- `signUpProvider`
- `signOutProvider`
- `userProfileProvider`

Ejemplo:

```dart
final signInProvider = Provider<SignIn>((ref) {
  return SignIn(repository: ref.watch(authRepositoryProvider));
});
```

### `lib/features/auth/data/datasources/firebase_auth_datasource.dart`

Es el unico archivo de Auth que llama directamente a Firebase Authentication:

```dart
_auth.signInWithEmailAndPassword(...)
_auth.createUserWithEmailAndPassword(...)
_auth.signOut()
_auth.authStateChanges()
```

### `lib/features/auth/data/datasources/user_profile_firestore_datasource.dart`

Lee el perfil del usuario desde Firestore usando el UID del usuario autenticado:

```dart
final userDoc = await _firestore.collection('users').doc(uid).get();
```

Campos esperados en Firestore:

```text
users/{uid}
  email: string
  rol: string
  name: string
```

Ejemplo:

```text
users/J6GuLkEegKfQBJVIPcOCKHxkWck2
  email: test@test.com
  rol: admin
  name: Cristopher
```

### `lib/features/auth/data/repositories/auth_repository_impl.dart`

Une los dos datasources:

- `FirebaseAuthDatasource` para login, registro, logout y sesion.
- `UserProfileFirestoreDatasource` para leer `users/{uid}`.

Tambien convierte `UserProfileModel` a la entidad `UserProfile`.

### `lib/features/auth/presentation/views/auth_view.dart`

Pantalla de login y registro. Ya no llama Firebase directo. Consume los casos de uso:

```dart
await ref.read(signInProvider)(
  email: email,
  password: password,
);

await ref.read(signUpProvider)(
  email: email,
  password: password,
);
```

Despues del login o registro exitoso consulta el perfil actual:

```dart
await ref.read(getCurrentUserProfileProvider)();
```

Luego navega al ecommerce.

### `lib/app/router/app_router.dart`

Protege rutas segun el repositorio de Auth:

```dart
final authRepository = ref.watch(authRepositoryProvider);
final signedIn = authRepository.isSignedIn;

if (!signedIn && !isAuthRoute) return '/auth';
if (signedIn && isAuthRoute) return '/ecommerce';
```

Escucha cambios de sesion con:

```dart
authRepository.authStateChanges()
```

Por eso, al cerrar sesion la app vuelve automaticamente al login.

## Productos desde Firestore

### `lib/features/ecommerce/data/datasources/ecommerce_firestore_datasource.dart`

Este archivo consume la coleccion `products`:

```dart
final snapshot = await _firestore.collection('products').get();
```

Cada documento se convierte a `ProductModel`.

Campos esperados:

```text
products/{documentId}
  name: string
  price: number
  description: string
  category: string
  sizes: array<string>
  colors: array<number>
```

Categorias usadas por la app:

```text
Perfect for you
For this summer
```

Si `category` no coincide exactamente, el producto se lee desde Firebase pero no aparece en esas secciones.

### `lib/features/ecommerce/data/repositories/ecommerce_repository_impl.dart`

El repositorio ya usa Firestore para productos:

```dart
final products = await firestoreDatasource.getProducts();
return products.map((productModel) => productModel.fromModel()).toList();
```

El mock ya no se usa para productos. Se mantiene solo para metodos de pago:

```dart
mockDatasource.getPaymentMethods()
```

### `lib/features/ecommerce/presentation/providers/ecommerce_provider.dart`

Crea el datasource de Firestore:

```dart
final ecommerceFirestoreDatasourceProvider =
    Provider<EcommerceFirestoreDatasource>(
  (ref) => EcommerceFirestoreDatasource(
    firestore: FirebaseFirestore.instance,
  ),
);
```

Expone productos como `FutureProvider` porque Firestore responde de forma asincrona:

```dart
final ecommerceProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(getProductsProvider)();
});
```

## Consumo en vistas

### `lib/features/ecommerce/presentation/views/ecommerce_home_view.dart`

Consume productos:

```dart
final productsAsync = ref.watch(ecommerceProductsProvider);
```

Consume perfil del usuario:

```dart
final userProfileAsync = ref.watch(userProfileProvider);
```

Muestra el nombre en el header:

```dart
userName: userProfileAsync.valueOrNull?.name ?? ''
```

Tambien hace logout:

```dart
await ref.read(signOutProvider)();
```

### `lib/features/ecommerce/presentation/views/product_detail_view.dart`

Tambien consume `ecommerceProductsProvider` para buscar el producto por ID y mostrar su detalle.

## Flujo actual

1. La app inicia y ejecuta `Firebase.initializeApp`.
2. El router revisa si hay usuario autenticado.
3. Si no hay usuario, manda a `/auth`.
4. Login/registro se hace con Firebase Authentication.
5. Al iniciar sesion, la app consulta `users/{uid}` para leer `rol` y `name`.
6. El ecommerce consulta `products` en Firestore.
7. La UI separa productos por `category`.
8. Al cerrar sesion, `authStateChanges()` actualiza el router y vuelve a `/auth`.

## Comandos utiles

Configurar Firebase:

```powershell
flutterfire configure
```

Instalar dependencias:

```powershell
flutter pub add firebase_core cloud_firestore firebase_auth
```

Analizar el proyecto:

```powershell
dart analyze
```
