import 'dart:convert';

import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/common/data/api_service.dart';

import 'package:http/http.dart' as http;

class FriendsService extends ApiService {
  FriendsService({required super.baseUrl});

  Future<Map<String, dynamic>> addFriend(int userId, int friendId) async {
    return await post(
        'api/friends', {'user_id': userId, 'friend_id': friendId});
  }

  Future<List<dynamic>> searchUsers(String query) async {
    return await get('api/users/search?query=${Uri.encodeComponent(query)}');
  }

  @override
  Future<dynamic> post(String endpoint, dynamic body, {bool throwOnHttpError = true}) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to post data to $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  @override
  Future<List<dynamic>> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      if (response.statusCode != 400) {
        throw Exception(
            'Failed to load data from $endpoint. Status code: ${response
                .statusCode}, body: ${response.body}');
      } else {
        return [jsonDecode(response.body)];
      }
    }
  }
}