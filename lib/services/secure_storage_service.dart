import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['id']);
    await prefs.setString('user_name', userData['name']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setBool('is_logged_in', true);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userName = prefs.getString('user_name');
    final userEmail = prefs.getString('user_email');
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn && userId != null && userName != null && userEmail != null) {
      return {
        'id': userId,
        'name': userName,
        'email': userEmail,
        'is_logged_in': isLoggedIn,
      };
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.setBool('is_logged_in', false);
  }

  Future<void> clearAllAuthData() async {
    await deleteAuthToken();
    await clearUserData();
  }
}
