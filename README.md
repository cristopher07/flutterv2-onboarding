
# flutterv2-onboarding

Starter de Flutter con **Arquitectura Limpia (Clean Architecture)**.

Este repo se deja listo como base de proyecto; las vistas de onboarding se implementan después.

## Estructura

lib/
├── main.dart
├── app/
│   ├── router/
│   │   └── app_router.dart
│   └── presentation/
│       └── controllers/
│           └── locale_controller.dart
├── core/
│   ├── environmet/
│   │   └── env.dart
│   └── assets.dart
└── features/
    └── onboarding/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── providers/
            └── views/
                └── onboarding_view.dart

## Comandos

- Instalar dependencias: `flutter pub get`
- Ejecutar: `flutter run`



