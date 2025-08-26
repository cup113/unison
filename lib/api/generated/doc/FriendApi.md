# openapi.api.FriendApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost:4132*

Method | HTTP request | Description
------------- | ------------- | -------------
[**friendsApprovePost**](FriendApi.md#friendsapprovepost) | **POST** /friends/approve | 
[**friendsListGet**](FriendApi.md#friendslistget) | **GET** /friends/list | 
[**friendsRefusePost**](FriendApi.md#friendsrefusepost) | **POST** /friends/refuse | 
[**friendsRequestPost**](FriendApi.md#friendsrequestpost) | **POST** /friends/request | 


# **friendsApprovePost**
> FriendsListGet200ResponseInner friendsApprovePost(authorization, friendsApprovePostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = FriendApi();
final authorization = authorization_example; // String | 
final friendsApprovePostRequest = FriendsApprovePostRequest(); // FriendsApprovePostRequest | Body

try {
    final result = api_instance.friendsApprovePost(authorization, friendsApprovePostRequest);
    print(result);
} catch (e) {
    print('Exception when calling FriendApi->friendsApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 
 **friendsApprovePostRequest** | [**FriendsApprovePostRequest**](FriendsApprovePostRequest.md)| Body | [optional] 

### Return type

[**FriendsListGet200ResponseInner**](FriendsListGet200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsListGet**
> List<FriendsListGet200ResponseInner> friendsListGet(authorization)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = FriendApi();
final authorization = authorization_example; // String | 

try {
    final result = api_instance.friendsListGet(authorization);
    print(result);
} catch (e) {
    print('Exception when calling FriendApi->friendsListGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 

### Return type

[**List<FriendsListGet200ResponseInner>**](FriendsListGet200ResponseInner.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsRefusePost**
> Object friendsRefusePost(authorization, friendsRefusePostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = FriendApi();
final authorization = authorization_example; // String | 
final friendsRefusePostRequest = FriendsRefusePostRequest(); // FriendsRefusePostRequest | Body

try {
    final result = api_instance.friendsRefusePost(authorization, friendsRefusePostRequest);
    print(result);
} catch (e) {
    print('Exception when calling FriendApi->friendsRefusePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 
 **friendsRefusePostRequest** | [**FriendsRefusePostRequest**](FriendsRefusePostRequest.md)| Body | [optional] 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **friendsRequestPost**
> Object friendsRequestPost(authorization, friendsRequestPostRequest)



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = FriendApi();
final authorization = authorization_example; // String | 
final friendsRequestPostRequest = FriendsRequestPostRequest(); // FriendsRequestPostRequest | Body

try {
    final result = api_instance.friendsRequestPost(authorization, friendsRequestPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling FriendApi->friendsRequestPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authorization** | **String**|  | 
 **friendsRequestPostRequest** | [**FriendsRequestPostRequest**](FriendsRequestPostRequest.md)| Body | [optional] 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

