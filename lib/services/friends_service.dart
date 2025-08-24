import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config_service.dart';
import 'secure_storage_service.dart';
import 'network_service.dart';
import '../utils/app_errors.dart';
import '../models/friend.dart';
import 'friends_service_interface.dart';

class FriendsService implements FriendsServiceInterface {
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Friend>> getFriendsList() async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError('网络不可用');
    }

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse(ConfigService.friendsListUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Friend.fromJson(json)).toList();
      } else {
        throw Exception('获取好友列表失败');
      }
    } catch (e) {
      throw Exception('获取好友列表失败: ${e.toString()}');
    }
  }

  @override
  Future<void> sendFriendRequest(String targetUserID) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError('网络不可用');
    }

    try {
      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse(ConfigService.friendsRequestUrl),
        headers: headers,
        body: jsonEncode({
          'targetUserID': targetUserID,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('发送好友请求失败');
      }
    } catch (e) {
      throw Exception('发送好友请求失败: ${e.toString()}');
    }
  }

  @override
  Future<Friend> approveFriendRequest(String friendRelationID) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError('网络不可用');
    }

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(ConfigService.friendsApproveUrl),
        headers: headers,
        body: jsonEncode({"id": friendRelationID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Friend.fromJson(data);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(Friend.fromJson(data));
      }
    } catch (e) {
      throw Exception('批准好友请求失败: ${e.toString()}');
    }
  }

  @override
  Future<void> refuseFriendRequest(String relationID, String reason) async {
    if (!await NetworkService.isConnected()) {
      throw NetworkError('网络不可用');
    }

    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(ConfigService.friendsRefuseUrl),
        headers: headers,
        body: jsonEncode({
          'relation': relationID,
          'reason': reason,
        }),
      );

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception('拒绝好友请求失败 $data');
      }
    } catch (e) {
      throw Exception('拒绝好友请求失败: ${e.toString()}');
    }
  }
}
