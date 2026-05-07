import 'package:flutter/material.dart';

class AppLocaleController extends ValueNotifier<Locale?> {
  AppLocaleController() : super(null);

  void codeLanguageSet(String codeLanguage) {
    value = Locale(codeLanguage);
  }
}

final controllerLocaleApp = AppLocaleController();
