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

  static String get friendsBaseUrl => '$serverUrl/friends';
  static String get friendsListUrl => '$friendsBaseUrl/list';
  static String get friendsRequestUrl => '$friendsBaseUrl/request';
  static String get friendsApproveUrl => '$friendsBaseUrl/approve';
  static String get friendsRefuseUrl => '$friendsBaseUrl/refuse';
}
