import '../models/friend.dart';

abstract class FriendsServiceInterface {
  Future<List<Friend>> getFriendsList();
  Future<void> sendFriendRequest(String targetUserID);
  Future<Friend> approveFriendRequest(String friendRelationID);
  Future<void> refuseFriendRequest(String relationID, String reason);
}