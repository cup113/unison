import 'package:unison/utils/crypto_utils.dart';

import '../services/secure_storage_service.dart';
import '../utils/app_errors.dart';
import '../constants/app_constants.dart';
import '../services/network_service.dart';
import '../services/config_service.dart';
import 'package:unison/api/generated/lib/api.dart';
export 'package:unison/api/generated/lib/api.dart';

/// Unified API service that wraps the generated OpenAPI client
/// Provides better error handling, connectivity checks, and token management
class UnisonApiService {
  static final UnisonApiService _instance = UnisonApiService._internal();

  late ApiClient _apiClient;
  final SecureStorageService _storageService = SecureStorageService();

  factory UnisonApiService() {
    return _instance;
  }

  UnisonApiService._internal() {
    _apiClient = ApiClient(basePath: ConfigService.serverUrl);
  }

  /// Update authentication token
  Future<void> updateAuthToken(String token) async {
    await _storageService.storeAuthToken(token);
  }

  /// Clear authentication
  Future<void> clearAuth() async {
    await _storageService.clearAllAuthData();
  }

  Future<String> getRequiredToken() async {
    final token = await _storageService.getAuthToken();
    if (token == null) {
      throw AuthError("No token found");
    } else {
      return 'Bearer $token';
    }
  }

  /// Execute API call with proper error handling and connectivity check
  Future<T> executeApiCall<T>(Future<T> Function() apiCall) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError(AppConstants.networkUnavailable);
    }

    try {
      return await apiCall();
    } on ApiException catch (e) {
      // Handle specific API errors
      if (e.code == 401) {
        throw AuthError('Authentication failed');
      } else if (e.code == 403) {
        throw AuthError('Access denied');
      } else if (e.code >= 500) {
        throw ServerError('Server error: ${e.code}');
      } else {
        throw ApiError('API error: ${e.message}');
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ApiError('Unexpected error: $e');
    }
  }

  // Auth API methods
  Future<AuthRegisterPost200Response> login({
    required String email,
    required String password,
  }) async {
    return executeApiCall(() async {
      final authApi = AuthApi(_apiClient);
      final request = AuthLoginPostRequest(
        email: email,
        password: CryptoUtils.hashPassword(password),
      );

      final response =
          await authApi.authLoginPost(authLoginPostRequest: request);
      if (response != null) {
        await updateAuthToken(response.token);
        return response;
      }
      throw ApiError('Login response was null');
    });
  }

  Future<AuthRegisterPost200Response> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return executeApiCall(() async {
      final authApi = AuthApi(_apiClient);
      final request = AuthRegisterPostRequest(
        name: name,
        email: email,
        password: CryptoUtils.hashPassword(password),
      );

      final response =
          await authApi.authRegisterPost(authRegisterPostRequest: request);
      if (response != null) {
        await updateAuthToken(response.token);
        return response;
      }
      throw ApiError('Registration response was null');
    });
  }

  Future<AuthRegisterPost200Response> refreshToken() async {
    return executeApiCall(() async {
      final authApi = AuthApi(_apiClient);
      final token = await _storageService.getAuthToken();
      if (token == null) {
        throw AuthError('No authentication token available');
      }

      final request = AuthRefreshPostRequest(token: token);
      final response = await authApi.authRefreshPost(
        'Bearer $token',
        authRefreshPostRequest: request,
      );

      if (response != null) {
        await updateAuthToken(response.token);
        return response;
      }
      throw ApiError('Token refresh response was null');
    });
  }

  // Friend API methods
  Future<List<FriendsListGet200ResponseInner>> getFriendsList() async {
    return executeApiCall(() async {
      final friendApi = FriendApi(_apiClient);
      final response = await friendApi.friendsListGet(await getRequiredToken());
      return response ?? [];
    });
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    return executeApiCall(() async {
      final friendApi = FriendApi(_apiClient);
      final request = FriendsRequestPostRequest(targetUserID: targetUserId);
      await friendApi.friendsRequestPost(await getRequiredToken(),
          friendsRequestPostRequest: request);
    });
  }

  Future<void> approveFriendRequest(String requestId) async {
    return executeApiCall(() async {
      final friendApi = FriendApi(_apiClient);
      final request = FriendsApprovePostRequest(id: requestId);
      await friendApi.friendsApprovePost(await getRequiredToken(),
          friendsApprovePostRequest: request);
    });
  }

  Future<void> refuseFriendRequest(String requestId, String reason) async {
    return executeApiCall(() async {
      final friendApi = FriendApi(_apiClient);
      final request =
          FriendsRefusePostRequest(relation: requestId, reason: reason);
      await friendApi.friendsRefusePost(await getRequiredToken(),
          friendsRefusePostRequest: request);
    });
  }

  /// Get the underlying API client for advanced usage
  ApiClient get apiClient => _apiClient;
}
