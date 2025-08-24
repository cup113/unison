abstract class AuthServiceInterface {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(
      String name, String email, String password);
  Future<Map<String, dynamic>> refreshToken();
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAuthToken();
  Future<Map<String, dynamic>?> getUserData();
  Future<Map<String, dynamic>?> initializeAuth();
}
