import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<void> downloadImage(BuildContext context, File file) async {
  try {
    // Проверяем разрешения
    bool hasPermission = await _requestPermissions();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Нет разрешения на доступ к галерее")),
      );
      return;
    }

    // Сохраняем в галерею
    await Gal.putImage(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Изображение сохранено в галерею")),
    );

  } catch (e) {
    print("Ошибка при сохранении: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ошибка при сохранении: $e")),
    );
  }
}

Future<bool> _requestPermissions() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) { // Android 13+
      final status = await Permission.photos.request();
      return status.isGranted;
    } else if (sdkInt >= 30) { // Android 11-12
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      // Если не получили полный доступ, пробуем обычные разрешения
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else { // Android 10 и ниже
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  return true; // Для iOS
}