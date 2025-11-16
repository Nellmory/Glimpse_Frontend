import 'package:glimpse/features/common/data/api_service.dart';

class AuthenticationService extends ApiService {
  AuthenticationService({required super.baseUrl});

  Future<Map<String, dynamic>> registry(
      String email, String password, String username) async {
    final response = await post(
      'api/registry',
      {'email': email, 'password': password, 'username': username},
      throwOnHttpError: false,
    );
    return response as Map<String, dynamic>;
  }


  Future<Map<String, dynamic>> login(String email, String password) async {
    return await post('api/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> createUser(String username, String password,
      String email, String profilePic, String status) async {
    return await post('api/users', {
      'username': username,
      'password': password,
      'email': email,
      'profile_pic': profilePic,
      'status': status
    });
  }
}
