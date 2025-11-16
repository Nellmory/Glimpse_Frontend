import 'package:glimpse/features/friends/data/friends_service.dart';

class FriendsRepository {
  final FriendsService _friendsService;

  FriendsRepository({required FriendsService friendsService})
      : _friendsService = friendsService;

  Future<List> searchUsers(String query) async {
    try {
      final response = await _friendsService.searchUsers(query);
      return response;
    } catch (e) {
      print('Error getting user data: $e');
      throw Exception('Error getting user data: $e');
    }
  }

  Future<Map<String, dynamic>> addFriend(int userId, int friendId) async {
    try {
      final response = await _friendsService.addFriend(userId, friendId);
      return response;
    } catch (e) {
      print('Error getting user data: $e');
      throw Exception('Error getting user data: $e');
    }
  }

  Future<List> getFriends(int userId) async {
    try {
      final List<dynamic> friends = await _friendsService.getFriends(userId);
      return friends;
    } catch (e) {
      print('Error getting friends: $e');
      throw Exception('Error getting friends: $e');
    }
  }
}
