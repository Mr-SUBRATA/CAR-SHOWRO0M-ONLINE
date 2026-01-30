import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ContactUsApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<void> contactUs(
    BuildContext context, {
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/contact-us/');

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "subject": subject,
          "message": message,
        }),
      );
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thanks for contact us we will reach out to you soon!',
            ),
          ),
        );
      }
    } catch (e) {
      print("Conatct Submission Failed $e");
    }
  }
}
