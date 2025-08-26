# Unison API Client

This directory contains the type-safe Dart API client for the Unison backend, generated from the OpenAPI specification.

## Structure

- `unison_api.dart` - OpenAPI generator configuration
- `unison_api_service.dart` - Service wrapper with enhanced error handling and connectivity checks
- `generated/` - Auto-generated API client code (do not modify manually)

## Usage

### Basic Usage (Generated Client)

```dart
import 'package:unison/unison.dart';

// Create API client
final apiClient = ApiClient();
apiClient.basePath = 'http://localhost:4132';

// Use authentication API
final authApi = AuthApi(apiClient);
final response = await authApi.authLoginPost(
  authLoginPostRequest: AuthLoginPostRequest(
    email: 'user@example.com',
    password: 'hashed_password',
  ),
);

print('Token: ${response?.token}');
```

### Recommended Usage (Service Wrapper)

```dart
import 'package:unison/api/unison_api_service.dart';

// Initialize the service
final apiService = UnisonApiService();
await apiService.initialize();

// Login with proper error handling
try {
  final response = await apiService.login(
    email: 'user@example.com',
    password: 'hashed_password',
  );
  
  print('Logged in as: ${response.user?.name}');
} on AuthError catch (e) {
  print('Authentication failed: ${e.message}');
} on NetworkError catch (e) {
  print('Network error: ${e.message}');
}

// Get friends list
try {
  final friends = await apiService.getFriendsList();
  print('Friends: ${friends.length}');
} catch (e) {
  print('Error getting friends: $e');
}
```

## Features

### Service Wrapper Benefits

1. **Error Handling**: Properly categorizes errors (AuthError, NetworkError, ServerError, ApiError)
2. **Connectivity Checks**: Automatically checks network connectivity before making requests
3. **Token Management**: Handles authentication token storage and refresh automatically
4. **Type Safety**: Full type safety with generated Dart models
5. **Consistent API**: Unified interface for all API operations

### Available APIs

- **Authentication**: Login, register, refresh token, logout
- **Friends**: Get friends list, send/approve/refuse friend requests
- **Todos**: (Future) Task management operations
- **Focus**: (Future) Focus timer operations

## Regeneration

When the OpenAPI specification changes, regenerate the client:

```bash
# Clean rebuild (recommended after spec changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Or incremental build
flutter pub run build_runner build
```

## Error Types

- `AuthError`: Authentication failures (401, 403)
- `NetworkError`: Connectivity issues
- `ServerError`: Server-side errors (5xx)
- `ApiError`: Other API errors

## Configuration

### Base URL

Set the base URL for different environments:

```dart
final apiService = UnisonApiService();
apiService.updateBasePath('https://api.unison.example.com');
```

### Authentication

The service automatically manages authentication tokens:

```dart
// Manual token update (if needed)
await apiService.updateAuthToken('new_token');

// Clear authentication
await apiService.clearAuth();
```

## Best Practices

1. Always use the service wrapper for better error handling
2. Handle specific error types appropriately
3. Check connectivity before making requests
4. Use the generated models for type safety
5. Regenerate client after API spec changes