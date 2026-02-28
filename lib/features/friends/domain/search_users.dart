import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/authentication/view/authentication.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';
import 'package:glimpse/features/friends/data/friends_repository.dart';
import 'package:glimpse/features/friends/domain/friend_entity.dart';

final FriendsRepository _friendsRepository = getIt<FriendsRepository>();

Future<List<Friend>> searchUsers(BuildContext context, String query) async {
  final token = await getToken();
  if (token != null) {
    try {
      final response = await _friendsRepository.searchUsers(query);
      if (response.isEmpty) {
        return <Friend>[];
      }
      if (response[0].containsKey('message')) {
        if (response[0].containsValue('Query must be at least 2 characters long')) {
          showErrorMessage('Введите хотя бы 3 первых символа', context);
          return <Friend>[];
        } else {
          if (response[0].containsValue('Query parameter is required')) {
            showErrorMessage('Неверные данные для поиска', context);
            return <Friend>[];
          } else {
            throw Exception('Error adding friend');
          }
        }
      } else {
        return response.map((json) => Friend.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error loading friends: $e');
      showErrorMessage('Ошибка при загрузке списка друзей: $e', context);
      throw Exception('Error loading friends: $e');
    }
  } else {
    // Если токена нет, перенаправляем на страницу входа
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Authentication()),
    );
    return <Friend>[];
  }
}
