//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class FriendApi {
  FriendApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// Performs an HTTP 'POST /friends/approve' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] authorization (required):
  ///
  /// * [FriendsApprovePostRequest] friendsApprovePostRequest:
  ///   Body
  Future<Response> friendsApprovePostWithHttpInfo(String authorization, { FriendsApprovePostRequest? friendsApprovePostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/friends/approve';

    // ignore: prefer_final_locals
    Object? postBody = friendsApprovePostRequest;

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
  /// * [FriendsApprovePostRequest] friendsApprovePostRequest:
  ///   Body
  Future<FriendsListGet200ResponseInner?> friendsApprovePost(String authorization, { FriendsApprovePostRequest? friendsApprovePostRequest, }) async {
    final response = await friendsApprovePostWithHttpInfo(authorization,  friendsApprovePostRequest: friendsApprovePostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'FriendsListGet200ResponseInner',) as FriendsListGet200ResponseInner;
    
    }
    return null;
  }

  /// Performs an HTTP 'GET /friends/list' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] authorization (required):
  Future<Response> friendsListGetWithHttpInfo(String authorization,) async {
    // ignore: prefer_const_declarations
    final path = r'/friends/list';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    headerParams[r'authorization'] = parameterToString(authorization);

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
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
  Future<List<FriendsListGet200ResponseInner>?> friendsListGet(String authorization,) async {
    final response = await friendsListGetWithHttpInfo(authorization,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<FriendsListGet200ResponseInner>') as List)
        .cast<FriendsListGet200ResponseInner>()
        .toList(growable: false);

    }
    return null;
  }

  /// Performs an HTTP 'POST /friends/refuse' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] authorization (required):
  ///
  /// * [FriendsRefusePostRequest] friendsRefusePostRequest:
  ///   Body
  Future<Response> friendsRefusePostWithHttpInfo(String authorization, { FriendsRefusePostRequest? friendsRefusePostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/friends/refuse';

    // ignore: prefer_final_locals
    Object? postBody = friendsRefusePostRequest;

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
  /// * [FriendsRefusePostRequest] friendsRefusePostRequest:
  ///   Body
  Future<Object?> friendsRefusePost(String authorization, { FriendsRefusePostRequest? friendsRefusePostRequest, }) async {
    final response = await friendsRefusePostWithHttpInfo(authorization,  friendsRefusePostRequest: friendsRefusePostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// Performs an HTTP 'POST /friends/request' operation and returns the [Response].
  /// Parameters:
  ///
  /// * [String] authorization (required):
  ///
  /// * [FriendsRequestPostRequest] friendsRequestPostRequest:
  ///   Body
  Future<Response> friendsRequestPostWithHttpInfo(String authorization, { FriendsRequestPostRequest? friendsRequestPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/friends/request';

    // ignore: prefer_final_locals
    Object? postBody = friendsRequestPostRequest;

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
  /// * [FriendsRequestPostRequest] friendsRequestPostRequest:
  ///   Body
  Future<Object?> friendsRequestPost(String authorization, { FriendsRequestPostRequest? friendsRequestPostRequest, }) async {
    final response = await friendsRequestPostWithHttpInfo(authorization,  friendsRequestPostRequest: friendsRequestPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }
}
