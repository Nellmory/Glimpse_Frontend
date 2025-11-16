import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/data/authentication_repository.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';

final AuthenticationRepository _authenticationRepository =
    getIt<AuthenticationRepository>();

void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
        ),
    );
}

Future<void> registry(BuildContext context, String email, String password, String username) async {
    try {
        final response = await _authenticationRepository.registry(email, password, username);
        if (response.containsKey('message') &&
            response['message'] == 'User registered successfully') {
            showSuccess(context, "Регистрация прошла успешно. Войдите в свой аккаунт.");
        } else {
            // Обработка ошибок регистрации
            showErrorMessage(
                response['message'] ?? "Ошибка регистрации. Попробуйте еще раз.", context);
        }
    } catch (e) {
        print('Error login: $e');
        showErrorMessage('Ошибка при регистрации: $e', context);
    }
}


