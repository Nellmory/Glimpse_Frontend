import 'dart:convert';

import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/common/data/api_service.dart';
import 'package:http/http.dart' as http;

class HomePageService extends ApiService {
  HomePageService({required super.baseUrl});

  Future<Map<String, dynamic>> getUserData() async {
    return await get('api/user');
  }

  Future<Map<String, dynamic>> getUserById(int userId) async {
    return await get('api/users/$userId');
  }

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
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
      throw Exception(
          'Failed to load data from $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }
}
