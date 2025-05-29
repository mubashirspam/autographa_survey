import 'package:flutter/foundation.dart';

enum Environment {
  development,
  production,
}

class EnvironmentConfig {
  static late Environment _environment;
  static late String _baseUrl;
  static late String _baseUrl2;
  static late bool _enableLogging;

  // Getters
  static Environment get environment => _environment;
  static String get baseUrl => _baseUrl;
  static String get baseUrl2 => _baseUrl2;
  static bool get enableLogging => _enableLogging;

  // Check current environment
  static bool isDevelopment() => _environment == Environment.development;
  static bool isProduction() => _environment == Environment.production;

  // Initialize environment configuration
  static void initialize({Environment env = Environment.development}) {
    _environment = env;

    switch (env) {
      case Environment.development:
        _baseUrl = 'https://backend.staging.autographa.io/survey';
        _baseUrl2 = 'https://api.staging.autographa.io';
        _enableLogging = true;
        break;
      case Environment.production:
        _baseUrl = 'https://backend.autographa.io/survey';
        _baseUrl2 = 'https://api.autographa.io';
        _enableLogging = false;
        break;
    }

    debugPrint('Environment: ${env.toString().split('.').last}');
    debugPrint('Base URL: $_baseUrl');
    debugPrint('Base URL 2: $_baseUrl2');
  }
}
