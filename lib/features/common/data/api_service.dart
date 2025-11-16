import 'dart:convert';
import 'dart:typed_data' show Uint8List;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

abstract class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Общая функция для GET запросов
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data from $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  // Общая функция для POST запросов
  Future<dynamic> post(String endpoint, dynamic body, {bool throwOnHttpError = true}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      if (throwOnHttpError) {
        throw Exception('Failed to post data to $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
      } else {
        return jsonDecode(response.body);
      }
    }
  }

  // Общая функция для PUT запросов
  Future<dynamic> put(String endpoint, dynamic body) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update data at $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  // Общая функция для DELETE запросов
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete data at $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  // Метод для отправки файлов
  Future<Map<String, dynamic>> uploadFile(String endpoint, String filePath, {Map<String, String>? fields}) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$endpoint'));

    // Добавляем файл
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    // Добавляем дополнительные поля, если они есть
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Отправляем запрос
    var streamedResponse = await request.send();

    // Получаем ответ
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to upload file to $endpoint. Status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  //Метод для получения файлов
  Future<Uint8List> getImageFile(String imagePath) async {
    final response = await http.get(Uri.parse('$baseUrl/images/$imagePath'));

    if (response.statusCode == 200) {
      return response.bodyBytes;  // Возвращаем байты файла
    } else {
      throw Exception('Failed to load image from $imagePath. Status code: ${response.statusCode}');
    }
  }
}