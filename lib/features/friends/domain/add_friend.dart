import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/authentication/view/authentication.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';
import 'package:glimpse/features/friends/data/friends_repository.dart';
import 'package:glimpse/features/friends/domain/friend_entity.dart';

final FriendsRepository _friendsRepository = getIt<FriendsRepository>();

Future<void> addFriend(BuildContext context, int userId, int friendId) async {
  try {
    final token = await getToken();
    if (token != null) {
      final response = await _friendsRepository.addFriend(userId, friendId);

      if (response.containsValue('Friend added successfully')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Заявка в друзья отправлена'),
            backgroundColor: Colors.blueGrey[700],
          ),
        );
      } else {
        showErrorMessage('Ошибка при добавлении в друзья', context);
      }
    }
  } catch (e) {
    print('Error adding friend: $e');
    showErrorMessage('Ошибка при добавлении в друзья: $e', context);
  }
}
