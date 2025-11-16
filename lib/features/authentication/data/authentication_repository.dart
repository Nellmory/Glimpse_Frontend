import 'package:glimpse/features/authentication/data/authentication_service.dart';

class AuthenticationRepository {
  final AuthenticationService _authenticationService;

  AuthenticationRepository({required AuthenticationService authenticationService})
      : _authenticationService = authenticationService;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _authenticationService.login(email, password);
      return response;
    } catch (e) {
      print('Error login: $e');
      throw Exception('Error login: $e');
    }
  }

  Future<Map<String, dynamic>> registry(String email, String password, String username) async {
    try {
      final response = await _authenticationService.registry(email, password, username);
      return response;
    } catch (e) {
      print('Error login: $e');
      throw Exception('Error login: $e');
    }
  }
}
