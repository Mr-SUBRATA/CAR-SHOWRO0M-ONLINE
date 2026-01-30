import 'dart:convert';

import 'package:arouse_ecommerce_frontend/utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";
  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No token found");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    // print(data);
    if (response.statusCode == 200) {
      return data; // user object
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch user');
    }
  }

  // UPDATE PROFILE
  static Future<bool> updateProfile(Map<String, dynamic> payload) async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;

    final res = await http.put(
      Uri.parse("$baseUrl/profile/me/update"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    return res.statusCode == 200;
  }

  // Get Profile pic
  Future<String?> getProfilePhoto() async {
    final token = await TokenStorage.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl/profile/photo"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      //print(data);
      return data['imageBase64'];
    }
    return null;
  }

  // Upload Profile pic
  static Future<void> uploadProfilePhoto({
    required String base64Image,
    required String mimeType,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No token found");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/profile/upload-photo"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"imageBase64": base64Image, "mimeType": mimeType}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to upload profile image");
    }
  }

  static Future<List<dynamic>> getMyBookings() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      return throw Exception("No token found");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/profile/bookings"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    //print(jsonDecode(response.body));
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['bookings'];
    } else {
      return throw Exception("Failed to upload profile image");
    }
  }

  // Log Out
  Future<void> logOut() async {
    await TokenStorage.clearToken();
  }
}
