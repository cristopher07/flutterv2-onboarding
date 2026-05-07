import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
 
enum Environment { development, staging, production }
 
class Env {
  Env._();
  static Env? _instance;
  static Env get instance {
    _instance ??= Env._();
    return _instance!;
  }
  // Variables
 
  static String get urlBaseApi => _values['apiUrl'] ?? '';
  static String get keyApi => _values['apiKey'] ?? '';
  static String get nameApp {
    final nameApp = _values['appName'];
    if (nameApp == null) {
      debugPrint(
        "Warning: 'appName' is not defined in the environment configuration.",
      );
    }
    return _values['appName'] ?? '';
  }
 
  //final String apiBaseUrl;
 
  static Map<String, dynamic> _values = {};
 
  static late final Environment environment;
 
  static Future<void> initialize() async {
    String nameFile;
    switch (environment) {
      case Environment.development:
        nameFile = 'env_dev.json';
        break;
      case Environment.staging:
        nameFile = 'env_staging.json';
        break;
      case Environment.production:
        nameFile = 'env_prod.json';
        break;
    }
    _values = await load(nameFile);
  }
 
  static Future<Map<String, dynamic>> load(String nameFile) async {
    // Cargar el archivo JSON correspondiente al entorno
    return rootBundle.loadString(nameFile).then((jsonString) {
      return json.decode(jsonString);
    });
  }
}
 
