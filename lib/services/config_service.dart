import 'package:flutter/foundation.dart';

class ConfigService {
  static String get serverUrl {
    if (kDebugMode) {
      return 'http://localhost:4132';
    } else {
      return 'https://unison-server.cup11.top';
    }
  }

  static String get authUrl => '$serverUrl/auth';
  static String get loginUrl => '$authUrl/login';
  static String get registerUrl => '$authUrl/register';
  static String get refreshUrl => '$authUrl/refresh';
}
