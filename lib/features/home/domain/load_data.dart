import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glimpse/features/friends/data/friends_repository.dart';
import 'package:intl/intl.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/authentication/view/authentication.dart';
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/home/data/home_page_repository.dart';
import 'package:glimpse/features/posts/data/posts_repository.dart';

final HomePageRepository _homePageRepository = getIt<HomePageRepository>();
final PostsRepository _postsRepository = getIt<PostsRepository>();
final FriendsRepository _friendsRepository = getIt<FriendsRepository>();

Future<void> loadUserData(BuildContext context,
    [UserAndPostState? state]) async {
  final token = await getToken();
  if (token != null) {
    try {
      final userData = await _homePageRepository.getUserData();

      if (state != null) {
        state.user = User.fromJson(userData);
        state.updateLoadingState(false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      await deleteToken();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Authentication()),
        (route) => false,
      );
    }
  } else {
    // Если токена нет, перенаправляем на страницу входа
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authentication()),
    );
  }
}

Future<void> loadPostData(BuildContext context,
    [UserAndPostState? state]) async {
  try {
    print('Starting loadPostData');
    print('State: ${state != null}');
    if (state != null && state.user != null) {
      print('User: ${state.user}');
      print('UserId: ${state.user.userId}');

      final postData = await _postsRepository.getUserPost(state.user.userId);
      print('PostData: $postData');

      final now = DateTime.now();
      final todayFormatted = DateFormat('yyyy-MM-dd').format(now);
      print('Today formatted: $todayFormatted');

      if (postData != null) {
        final postDateFormatted = DateFormat('yyyy-MM-dd').format(postData.timestamp);
        print('Post date formatted: $postDateFormatted');

        if (postDateFormatted == todayFormatted) {
          state.post = postData;
          print('Post set successfully');
        } else {
          state.post = null;
          print('Даты не совпали.');
        }
      } else {
        state.post = null;
        print('No post data received');
      }
    }
  } catch (e, stackTrace) {
    print('Error loading post data: $e');
    print('Stack trace: $stackTrace');  // добавляем вывод stack trace
  } finally {
    state?.updateLoadingState(false);
  }
}

Future<List<dynamic>> loadFriends(BuildContext context, int userId) async {
  try {
    final friends = await _friendsRepository.getFriends(userId);
    return friends;
  } catch (e) {
    print('Error loading friends in loadFriends function: $e');
    throw Exception('Failed to load friends: $e');
  }
}

Future<File> getImage(String imagePath) async {
  try {
    return await _postsRepository.getImageAsFile(imagePath);
  } catch (e) {
    print('Error loading post data: $e');
    throw Exception('Failed to load image: $e');
  }
}

Future<String?> getLikeCount(int postID) async {
  try {
    return await _postsRepository.getPostLikeCount(postID);
  } catch (e) {
    print('Error getting post like count: $e');
    throw Exception('Error getting post like count: $e');
  }
}
