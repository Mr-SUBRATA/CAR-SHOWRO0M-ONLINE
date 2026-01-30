import 'dart:convert';

import 'package:arouse_ecommerce_frontend/utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CompareApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<List<String>> getCompareList() async {
    final token = await TokenStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/user/compare-list'),
      headers: {"Authorization": "Bearer $token"},
    );
    return List<String>.from(jsonDecode(response.body)["compareList"]);
  }

  static Future<List<String>> addToCompare(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cars/$id/compare'),
      headers: {"Authorization": "Bearer $token"},
    );
    return List<String>.from(jsonDecode(response.body)["compareList"]);
  }

  static Future<List<String>> removeFromCompare(String id) async {
    final token = await TokenStorage.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/cars/$id/remove-from-compare'),
      headers: {"Authorization": "Bearer $token"},
    );
    return List<String>.from(jsonDecode(response.body)["compareList"]);
  }

  static Future<List<Map<String, dynamic>>> getAllCars() async {
    final res = await http.get(Uri.parse("$baseUrl/cars"));
    List data = jsonDecode(res.body);

    // Cast each element to Map<String, dynamic>
    return data
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
