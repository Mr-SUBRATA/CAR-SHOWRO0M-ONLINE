import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

class AuthenticationApi {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// =====================
  /// Signup - Send OTP
  /// =====================
  Future<bool> signUpSendOtp(String mobile, String email, String name) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": mobile, "email": email, "name": name}),
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200;
  }

  /// =====================
  /// Login - Send OTP
  /// =====================
  Future<bool> loginSendOtp(String mobile) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login/send-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": mobile}),
    );

    final data = jsonDecode(response.body);
    return response.statusCode == 200;
  }

  /// =====================
  /// Verify OTP (Signup)
  /// =====================
  Future<Map<String, dynamic>> verifySignUpOtp(
    String mobile,
    String otp,
    String name,
    String email,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": mobile,
        "otp": otp,
        "name": name,
        "email": email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null) {
      await TokenStorage.saveToken(data["token"]);
    }

    return {
      "success": response.statusCode == 200,
      "message": data["message"] ?? "Verification failed",
    };
  }

  /// =====================
  /// Verify OTP (Login)
  /// =====================
  Future<Map<String, dynamic>> verifyLoginOtp(String mobile, String otp) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": mobile, "otp": otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["token"] != null) {
      await TokenStorage.saveToken(data["token"]);
    }

    return {
      "success": response.statusCode == 200,
      "message": data["message"] ?? "Invalid OTP",
    };
  }
}
