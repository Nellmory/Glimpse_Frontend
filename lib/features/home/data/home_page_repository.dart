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
}
