import 'dart:convert';
import 'package:arouse_ecommerce_frontend/components/Book_test_drive/booking_done.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookTestDriveApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<bool> bookTestDrive(
    BuildContext context, {
    required String name,
    required String phone,
    required String altPhone,
    required String email,
    required String city,
    required String date,
    required String time,
    required String state,
    required String address,
    required String brand,
    required String model,
    required bool hasDriving,
  }) async {
    final url = Uri.parse('$baseUrl/cars/book-test-drive');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "date": date,
          "timeSlot": time,
          "state": state,
          "city": city,
          "address": address,
          "modelName": model,
          "brand": brand,
          "customerName": name,
          "phoneNumber": phone,
          "alternatePhoneNumber": altPhone,
          "email": email,
          "hasDrivingLicense": hasDriving,
        }),
      );

      if (response.statusCode == 201) {
        //  print("Test Drive Booked Successfully!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingDone()),
        );
        return true;
      } else {
        //  print("Failed: ${response.body}");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => bookingFailure()),
        );
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
