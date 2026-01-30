import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String selectedCity = "New Delhi";

  /// Save city
  static Future<void> setSelectedCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedCity, city);
  }

  /// Get city
  static Future<String> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(selectedCity) ?? "New Delhi";
  }
}
