import 'package:get_it/get_it.dart';
import 'package:glimpse/features/authentication/data/authentication_repository.dart';
import 'package:glimpse/features/authentication/data/authentication_service.dart';
import 'package:glimpse/features/friends/data/friends_service.dart';
import 'package:glimpse/features/friends/data/friends_repository.dart';
import 'package:glimpse/features/home/data/home_page_repository.dart';
import 'package:glimpse/features/home/data/home_page_service.dart';
import 'package:glimpse/features/posts/data/posts_repository.dart';
import 'package:glimpse/features/posts/data/posts_service.dart';
import 'package:glimpse/features/profile_settings/data/settings_repository.dart';
import 'package:glimpse/features/profile_settings/data/settings_service.dart';
import 'package:glimpse/features/common/data/api_client.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Регистрация сервисов
  getIt.registerLazySingleton<PostsService>(() => PostsService(baseUrl: ApiClient.baseUrl));
  getIt.registerLazySingleton<HomePageService>(() => HomePageService(baseUrl: ApiClient.baseUrl));
  getIt.registerLazySingleton<SettingsService>(() => SettingsService(baseUrl: ApiClient.baseUrl));
  getIt.registerLazySingleton<FriendsService>(() => FriendsService(baseUrl: ApiClient.baseUrl));
  getIt.registerLazySingleton<AuthenticationService>(() => AuthenticationService(baseUrl: ApiClient.baseUrl));

  // Регистрация репозиториев
  getIt.registerLazySingleton<PostsRepository>(
          () => PostsRepository(postsService: getIt<PostsService>())
  );
  getIt.registerLazySingleton<HomePageRepository>(
          () => HomePageRepository(homePageService: getIt<HomePageService>())
  );
  getIt.registerLazySingleton<SettingsRepository>(
          () => SettingsRepository(settingsService: getIt<SettingsService>())
  );
  getIt.registerLazySingleton<FriendsRepository>(
          () => FriendsRepository(friendsService: getIt<FriendsService>())
  );
  getIt.registerLazySingleton<AuthenticationRepository>(
          () => AuthenticationRepository(authenticationService: getIt<AuthenticationService>())
  );

  // Регистрация use cases
  /*getIt.registerLazySingleton<PostUpload>(
          () => PostUpload(postRepository: getIt<PostRepository>())
  );*/
}