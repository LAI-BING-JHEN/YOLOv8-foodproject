import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://8d28-2402-7500-92e-48b1-145d-9b25-89-342f.ngrok-free.app';

  //  上傳圖片（加 timeout + debug）
  static Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    final url = Uri.parse('$baseUrl/upload');

    try {
      print(" 開始上傳圖片...");

      final request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse =
          await request.send().timeout(Duration(seconds: 30));

      final response = await http.Response.fromStream(streamedResponse);

      print(" Server 回應: ${response.statusCode}");
      print(" Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'source': data['source'] ?? 'unknown',

          // YOLO
          'food': data['food'],
          'confidence': data['confidence'],
          'calories': data['calories'] ?? data['total_calories'] ?? 0,
          'carbs': data['carbs'] ?? 0,
          'protein': data['protein'] ?? 0,
          'fat': data['fat'] ?? 0,

          // ChatGPT
          'foods': data['foods'] ?? [],
          'total_calories': data['total_calories'] ?? data['calories'] ?? 0,
          'total_fat': data['total_fat'] ?? 0,
          'total_carbs': data['total_carbs'] ?? 0,
          'total_protein': data['total_protein'] ?? 0,

          // fallback
          'description': data['description'],
          'error': data['error'],
        };
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print(" 上傳錯誤: $e");

      return {
        'source': 'error',
        'foods': [],
        'total_calories': 0,
        'error': e.toString(),
      };
    }
  }

  //  飲食建議（加 timeout）
  static Future<Map<String, dynamic>> getRecommend({
    required double height,
    required double weight,
    required int age,
    required String gender,
    required String foodName,
    required num calories,
  }) async {
    final url = Uri.parse('$baseUrl/recommend');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'height': height,
              'weight': weight,
              'age': age,
              'gender': gender,
              'food_name': foodName,
              'calories': calories,
            }),
          )
          .timeout(Duration(seconds: 15));

      print("📥 recommend 回應: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Recommend failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print(" recommend 錯誤: $e");

      return {
        'error': e.toString(),
      };
    }
  }
}