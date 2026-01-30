import 'dart:convert';
import 'package:arouse_ecommerce_frontend/utils/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VehiclesApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<List<Map<String, dynamic>>> getAllCars() async {
    final url = Uri.parse('$baseUrl/cars');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required String bookingDate,
    required String vehicleId,
    String? branch,
    double amountPaid = 0,
  }) async {
    final token = await TokenStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/bookings/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "bookingDate": bookingDate,
        "vehicleId": vehicleId,
        "amountPaid": amountPaid,
        "branch": branch,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Booking failed");
    }
  }
}
