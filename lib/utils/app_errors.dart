class AppError implements Exception {
  final String message;
  final dynamic underlyingError;

  AppError(this.message, {this.underlyingError});

  @override
  String toString() =>
      'AppError: $message${underlyingError != null ? ' ($underlyingError)' : ''}';
}

class NetworkError extends AppError {
  NetworkError(super.message, {super.underlyingError});
}

class AuthError extends AppError {
  AuthError(super.message, {super.underlyingError});
}

class ApiError extends AppError {
  ApiError(super.message, {super.underlyingError});
}

class ServerError extends ApiError {
  ServerError(super.message, {super.underlyingError});
}

class StorageError extends AppError {
  StorageError(super.message, {super.underlyingError});
}

class ValidationError extends AppError {
  ValidationError(super.message, {super.underlyingError});
}
