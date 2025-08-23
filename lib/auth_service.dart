import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config_service.dart';
import 'crypto_utils.dart';
import 'secure_storage_service.dart';
import 'network_service.dart';

class AuthService {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (!await NetworkService.isConnected()) {
      throw Exception('网络连接不可用，请检查网络设置');
    }

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
      throw Exception(errorData['message'] ?? '登录失败');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    if (!await NetworkService.isConnected()) {
      throw Exception('网络连接不可用，请检查网络设置');
    }

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
      throw Exception((errorData['message'] ?? '注册失败') + response.body);
    }
  }

  Future<Map<String, dynamic>> refreshToken() async {
    if (!await NetworkService.isConnected()) {
      throw Exception('网络连接不可用，无法刷新认证');
    }

    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw Exception('没有找到有效的认证令牌');
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
      throw Exception(errorData['message'] ?? '令牌刷新失败');
    }
  }

  Future<void> logout() async {
    await _storageService.clearAllAuthData();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAuthToken();
    final userData = await _storageService.getUserData();
    return token != null && userData != null;
  }

  Future<String?> getAuthToken() async {
    return await _storageService.getAuthToken();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    return await _storageService.getUserData();
  }

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
