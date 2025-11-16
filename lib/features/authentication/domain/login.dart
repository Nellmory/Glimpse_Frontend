import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/data/authentication_repository.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';

final AuthenticationRepository _authenticationRepository =
    getIt<AuthenticationRepository>();

Future<void> login(BuildContext context, String email, String password) async {
    try {
        final response = await _authenticationRepository.login(email, password);
        if (response.containsKey('token')) {
            // Аутентификация прошла успешно
            final String token = response['token'];

            // Сохранение токена
            await saveToken(token);
        } else {
            showErrorMessage(response['error'] ?? "Неверная почта или пароль.", context);
        }
    } catch (e) {
        print('Error login: $e');
        showErrorMessage('Ошибка при добавлении в друзья: $e', context);
    }
}
