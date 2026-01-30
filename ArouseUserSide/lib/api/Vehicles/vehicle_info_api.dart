import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class VehicleInfoApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<Map<String, dynamic>?> getCarInfo(String cardId) async {
    final url = Uri.parse('$baseUrl/cars/$cardId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch car: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching car: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getOnRoadPrice(
    String cardId,
    String city,
  ) async {
    final url = Uri.parse('$baseUrl/rto/cars/$cardId/price?city=$city');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch car: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching car: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> calculateEMI(
    String loan,
    String interest,
    String tenure,
  ) async {
    final url = Uri.parse('$baseUrl/cars/emi');

    try {
      final response = await http.post(
        url,
        body: jsonEncode({
          "loanAmount": loan,
          "interestRate": interest,
          "tenureMonths": tenure,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Failed to fetch EMI: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching EMI: $e");
      return null;
    }
  }

  Future<List<String>> fetchRtoCities() async {
    final uri = Uri.parse('$baseUrl/rto/cities');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List cities = data['cities'] ?? [];

      return cities.map((c) => c.toString()).toList();
    } else {
      throw Exception('Failed to load RTO cities');
    }
  }
}
