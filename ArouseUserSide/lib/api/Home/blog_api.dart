import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BlogApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<List<dynamic>> getAllBlog() async {
    final url = Uri.parse('$baseUrl/blogs');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print("Blogs fetched successfully: $data");
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
