import 'app/presentation/controllers/locale_controller.dart';
import 'app/router/app_router.dart';
import 'core/environmet/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterv2_onboarding/l10n/app_localizations.dart';

void main() {
  Env.environment = Environment.development;
  runProject();
}

void runProject() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: controllerLocaleApp,
      builder: (context, locale, _) {
        return Consumer(
          builder: (context, ref, child) {
            final router = ref.watch(appRouterProvider);
            return MaterialApp.router(
              onGenerateTitle: (context) => AppLocalizations.of(context)!.titleApp,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              ),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }
}







