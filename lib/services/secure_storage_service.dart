import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unison/api/generated/lib/api.dart';
import '../constants/app_constants.dart';
import 'dart:convert';

class SecureStorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _authTokenKey = 'auth_token';

  Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }

  Future<void> storeUserData(AuthRegisterPost200ResponseUser userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.userInfoKey, json.encode(userData.toJson()));
  }

  Future<AuthRegisterPost200ResponseUser?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString(AppConstants.userInfoKey);

    if (user != null && user.isNotEmpty) {
      return AuthRegisterPost200ResponseUser.fromJson(json.decode(user));
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userInfoKey);
  }

  Future<void> clearAllAuthData() async {
    await deleteAuthToken();
    await clearUserData();
  }
}
