import 'dart:convert';
import 'dart:io';
import 'package:arouse_ecommerce_frontend_web/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  // 🧾 Common headers
  static Future<Map<String, String>> headers() async {
    final token = await TokenStorage.getToken();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<void> createFakeLoyaltyCard() async {
    await http.post(
      Uri.parse("$baseUrl/loyalty/fake-create"),
      headers: await headers(),
    );
  }

  // 🔹 CREATE ENQUIRY (USER)
  static Future<Map<String, dynamic>> createEnquiry({
    required String customerName,
    required String contactNumber,
    String? preferredBrand,
    String? alternateNumber,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/user-enquiries/create-enquiry"),
      headers: await headers(),
      body: jsonEncode({
        "customerName": customerName,
        "contactNumber": contactNumber,
        "preferredBrand": preferredBrand,
        "alternateNumber": alternateNumber,
      }),
    );
    print(response.body);

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to create enquiry: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 MY ENQUIRIES (USER)
  static Future<List<dynamic>> getMyEnquiries() async {
    final response = await http.get(
      Uri.parse("$baseUrl/enquiries/my"),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch enquiries: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 POINTS HISTORY
  static Future<List<dynamic>> getPointsHistory() async {
    final response = await http.get(
      Uri.parse("$baseUrl/loyalty/points/history"),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch points history: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 SINGLE ENQUIRY STATUS
  static Future<Map<String, dynamic>> getEnquiryStatus(String enquiryId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/enquiries/$enquiryId"),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch enquiry status: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 MY POINTS BALANCE
  static Future<Map<String, dynamic>> getMyPoints() async {
    final response = await http.get(
      Uri.parse("$baseUrl/points/me"),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch points: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 LOYALTY CARD STATUS
  static Future<Map<String, dynamic>> getMyLoyaltyCard() async {
    final response = await http.get(
      Uri.parse("$baseUrl/loyalty/me"),
      headers: await headers(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to fetch loyalty card: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 INITIATE LOYALTY PAYMENT
  static Future<Map<String, dynamic>> initiateLoyaltyPayment() async {
    final response = await http.post(
      Uri.parse("$baseUrl/loyalty/payment/initiate"),
      headers: await headers(),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to initiate payment: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  // 🔹 VERIFY LOYALTY PAYMENT
  static Future<Map<String, dynamic>> verifyLoyaltyPayment(
    String paymentId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/loyalty/payment/verify"),
      headers: await headers(),
      body: jsonEncode({"paymentId": paymentId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to verify payment: ${jsonDecode(response.body)["message"]}",
      );
    }
  }

  static Future<void> downloadEnquiryReport({
    required int month,
    required int year,
  }) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user-enquiries/my/download?month=$month&year=$year"),
      headers: await headers(),
    );
    //print("Downloaded ${response.bodyBytes.length} bytes");

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory(); // temp folder

      final file = File("${dir.path}/enquiries_${month}_$year.csv");

      await file.writeAsBytes(response.bodyBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)], text: "Enquiry Report");
    } else if (response.statusCode == 404) {
      throw Exception("NO_DATA");
    } else {
      throw Exception("DOWNLOAD_FAILED");
    }
  }

  // 🔹 REFER FRIEND
  static Future<Map<String, dynamic>> referFriend(String mobile) async {
    final response = await http.post(
      Uri.parse("$baseUrl/referral"),
      headers: await headers(),
      body: jsonEncode({"mobile": mobile}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Failed to send referral: ${jsonDecode(response.body)["message"]}",
      );
    }
  }
}
