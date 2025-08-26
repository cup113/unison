import '../services/secure_storage_service.dart';
import '../api/unison_api_service.dart';

class AccountService {
  final _secureStorageService = SecureStorageService();
  AuthRegisterPost200ResponseUser? _userData;
  AuthRegisterPost200ResponseUser? get userData => _userData;

  Future<AuthRegisterPost200ResponseUser?> getUserData() async {
    _userData = await _secureStorageService.getUserData();
    return _userData;
  }

  Future<void> logout() async {
    await _secureStorageService.clearAllAuthData();
  }

  Future<void> storeUserInfo(AuthRegisterPost200ResponseUser userData) async {
    await _secureStorageService.storeUserData(userData);
  }

  Future<void> storeToken(String token) async {
    await _secureStorageService.storeAuthToken(token);
  }
}
