//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class AuthApi {
  AuthApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /auth/login' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [AuthLoginPostRequest] authLoginPostRequest:
  ///   Body
  Future<Response> authLoginPostWithHttpInfo({ AuthLoginPostRequest? authLoginPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = authLoginPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [AuthLoginPostRequest] authLoginPostRequest:
  ///   Body
  Future<AuthRegisterPost200Response?> authLoginPost({ AuthLoginPostRequest? authLoginPostRequest, }) async {
    final response = await authLoginPostWithHttpInfo( authLoginPostRequest: authLoginPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AuthRegisterPost200Response',) as AuthRegisterPost200Response;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /auth/refresh' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] authorization (required):
  ///
  /// * [AuthRefreshPostRequest] authRefreshPostRequest:
  ///   Body
  Future<Response> authRefreshPostWithHttpInfo(String authorization, { AuthRefreshPostRequest? authRefreshPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/refresh';

    // ignore: prefer_final_locals
    Object? postBody = authRefreshPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'authorization'] = parameterToString(authorization);

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [String] authorization (required):
  ///
  /// * [AuthRefreshPostRequest] authRefreshPostRequest:
  ///   Body
  Future<AuthRegisterPost200Response?> authRefreshPost(String authorization, { AuthRefreshPostRequest? authRefreshPostRequest, }) async {
    final response = await authRefreshPostWithHttpInfo(authorization,  authRefreshPostRequest: authRefreshPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AuthRegisterPost200Response',) as AuthRegisterPost200Response;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /auth/register' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [AuthRegisterPostRequest] authRegisterPostRequest:
  ///   Body
  Future<Response> authRegisterPostWithHttpInfo({ AuthRegisterPostRequest? authRegisterPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/register';

    // ignore: prefer_final_locals
    Object? postBody = authRegisterPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// Parameters:
  ///
  /// * [AuthRegisterPostRequest] authRegisterPostRequest:
  ///   Body
  Future<AuthRegisterPost200Response?> authRegisterPost({ AuthRegisterPostRequest? authRegisterPostRequest, }) async {
    final response = await authRegisterPostWithHttpInfo( authRegisterPostRequest: authRegisterPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AuthRegisterPost200Response',) as AuthRegisterPost200Response;
    
    }
    return null;
  }
}
