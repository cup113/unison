import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import '../utils/crypto_utils.dart';
import 'secure_storage_service.dart';
import 'network_service.dart';
import '../constants/app_constants.dart';
import '../utils/app_errors.dart';
import 'auth_service_interface.dart';

class AuthService implements AuthServiceInterface {
  final SecureStorageService _storageService = SecureStorageService();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError(AppConstants.networkUnavailable);
    }

    try {
      final hashedPassword = CryptoUtils.hashPassword(password);

      final response = await http.post(
        Uri.parse(ConfigService.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': hashedPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.storeAuthToken(data['token']);
        await _storageService.storeUserData(data['user']);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError(errorData['message'] ?? AppConstants.loginFailed);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError('Login failed', underlyingError: e);
    }
  }

  @override
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError(AppConstants.networkUnavailable);
    }

    try {
      final hashedPassword = CryptoUtils.hashPassword(password);

      final response = await http.post(
        Uri.parse(ConfigService.registerUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': hashedPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.storeAuthToken(data['token']);
        await _storageService.storeUserData(data['user']);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError(
            errorData['message'] ?? AppConstants.registrationFailed);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError('Registration failed', underlyingError: e);
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError(AppConstants.networkUnavailable);
    }

    try {
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw AuthError(AppConstants.noAuthToken);
      }

      final response = await http.post(
        Uri.parse(ConfigService.refreshUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storageService.storeAuthToken(data['token']);
        await _storageService.storeUserData(data['user']);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthError(
            errorData['message'] ?? AppConstants.tokenRefreshFailed);
      }
    } catch (e) {
      if (e is AuthError) rethrow;
      throw AuthError('Token refresh failed', underlyingError: e);
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.clearAllAuthData();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAuthToken();
    final userData = await _storageService.getUserData();
    return token != null && userData != null;
  }

  @override
  Future<String?> getAuthToken() async {
    return await _storageService.getAuthToken();
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    return await _storageService.getUserData();
  }

  @override
  Future<Map<String, dynamic>?> initializeAuth() async {
    try {
      final isLoggedIn = await this.isLoggedIn();
      if (isLoggedIn) {
        await refreshToken();
        return await getUserData();
      }
      return null;
    } catch (e) {
      await logout();
      return null;
    }
  }
}
