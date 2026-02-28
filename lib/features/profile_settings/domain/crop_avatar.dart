import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Читает изображение из [sourcePath], обрезает по центру до квадрата,
/// сохраняет в JPEG во временный файл и возвращает путь к нему.
Future<String> cropImageToSquare(String sourcePath) async {
  final bytes = await File(sourcePath).readAsBytes();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) throw Exception('Не удалось прочитать изображение');

  final side = image.width < image.height ? image.width : image.height;
  final x = (image.width - side) ~/ 2;
  final y = (image.height - side) ~/ 2;
  final cropped = img.copyCrop(image, x: x, y: y, width: side, height: side);

  final jpeg = img.encodeJpg(cropped, quality: 85);
  final dir = await getTemporaryDirectory();
  final outPath = '${dir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(outPath).writeAsBytes(jpeg);
  return outPath;
}
