import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EnquiryApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<Map<String, dynamic>> submitEnquiry(
      Map<String, String> data) async {
    final url = Uri.parse('$baseUrl/user-enquiries');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Enquiry submitted successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to submit enquiry',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
