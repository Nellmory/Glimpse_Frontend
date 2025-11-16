import 'package:glimpse/features/authentication/data/authentication_service.dart';
import 'package:glimpse/features/friends/data/friends_service.dart';
import 'package:glimpse/features/posts/data/posts_service.dart';
import 'package:glimpse/features/profile_settings/data/settings_service.dart';
import 'package:glimpse/features/home/data/home_page_service.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.0.104:5000';
  static final AuthenticationService authenticationService = AuthenticationService(baseUrl: baseUrl);
  static final FriendsService friendsService  = FriendsService(baseUrl: baseUrl);
  static final PostsService postsService = PostsService(baseUrl: baseUrl);
  static final SettingsService settingsService = SettingsService(baseUrl: baseUrl);
  static final HomePageService homePageService = HomePageService(baseUrl: baseUrl);
}