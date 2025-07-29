import 'package:share_plus/share_plus.dart';
import 'dart:io';

Future<void> shareImage(File file) async {
  try {
    // Проверяем, существует ли файл
    if (await file.exists()) {
      // Используем shareXFiles для новых версий или shareFiles для старых
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Посмотри это изображение! Я сделала его в Glimpse ;) Жду тебя там!',
        subject: 'Изображение из Glimpse',
      );
    } else {
      print('Файл не существует: ${file.path}');
    }
  } catch (e) {
    print('Ошибка при шаринге: $e');
  }
}