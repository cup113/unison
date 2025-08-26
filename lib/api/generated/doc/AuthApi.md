# openapi.api.AuthApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:4132*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLoginPost**](AuthApi.md#authloginpost) | **POST** /auth/login | 
[**authRefreshPost**](AuthApi.md#authrefreshpost) | **POST** /auth/refresh | 
[**authRegisterPost**](AuthApi.md#authregisterpost) | **POST** /auth/register | 


# **authLoginPost**
> AuthRegisterPost200Response authLoginPost(authLoginPostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AuthApi();
final authLoginPostRequest = AuthLoginPostRequest(); // AuthLoginPostRequest | Body

try {
    final result = api_instance.authLoginPost(authLoginPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authLoginPostRequest** | [**AuthLoginPostRequest**](AuthLoginPostRequest.md)| Body | [optional] 

### Return type

[**AuthRegisterPost200Response**](AuthRegisterPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRefreshPost**
> AuthRegisterPost200Response authRefreshPost(authorization, authRefreshPostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AuthApi();
final authorization = authorization_example; // String | 
final authRefreshPostRequest = AuthRefreshPostRequest(); // AuthRefreshPostRequest | Body

try {
    final result = api_instance.authRefreshPost(authorization, authRefreshPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 
 **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md)| Body | [optional] 

### Return type

[**AuthRegisterPost200Response**](AuthRegisterPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRegisterPost**
> AuthRegisterPost200Response authRegisterPost(authRegisterPostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = AuthApi();
final authRegisterPostRequest = AuthRegisterPostRequest(); // AuthRegisterPostRequest | Body

try {
    final result = api_instance.authRegisterPost(authRegisterPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling AuthApi->authRegisterPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRegisterPostRequest** | [**AuthRegisterPostRequest**](AuthRegisterPostRequest.md)| Body | [optional] 

### Return type

[**AuthRegisterPost200Response**](AuthRegisterPost200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

