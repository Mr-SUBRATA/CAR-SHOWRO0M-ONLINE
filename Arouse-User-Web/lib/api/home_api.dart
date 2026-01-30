import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<List<Map<String, dynamic>>> searchCar(String query) async {
    final url = Uri.parse('$baseUrl/search/cars?q=$query');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded.containsKey("results")) {
          return List<Map<String, dynamic>>.from(decoded["results"]);
        }

        if (decoded is List) {
          return List<Map<String, dynamic>>.from(decoded);
        }

        return [];
      } else {
        print("Search failed: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error fetching cars: $e");
      return [];
    }
  }

  Future<List<dynamic>> getAllBlog() async {
    final url = Uri.parse('$baseUrl/blogs');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        //  print("Blogs fetched successfully: $data");
        return data; // <-- return blog list or blog data
      } else {
        print("Failed to fetch blogs: ${response.body}");
        return []; // return empty list on failure
      }
    } catch (e) {
      print("Error fetching blogs: $e");
      return [];
    }
  }
}
