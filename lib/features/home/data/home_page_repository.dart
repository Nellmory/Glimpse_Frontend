import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/home/data/home_page_service.dart';

class HomePageRepository {
  final HomePageService _homePageService;

  HomePageRepository({required HomePageService homePageService})
      : _homePageService = homePageService;

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await _homePageService.getUserData();
      return response;
    } catch (e) {
      print('Error getting user data: $e');
      throw Exception('Error getting user data: $e');
    }
  }

  Future<User?> getUserById(int userId) async {
    try {
      final response = await _homePageService.getUserById(userId);
      return User.fromJson(response);
    } catch (e) {
      print('Error getting user by id: $e');
      return null;
    }
  }

  /// Загружает аватар; возвращает relative path profile_pic из ответа.
  Future<String> uploadAvatar(int userId, String imageFilePath) async {
    try {
      final response = await _homePageService.uploadAvatar(userId, imageFilePath);
      final path = response['profile_pic'] as String?;
      if (path == null || path.isEmpty) {
        throw Exception('No profile_pic in response');
      }
      return path;
    } catch (e) {
      print('Error uploading avatar: $e');
      rethrow;
    }
  }
}
