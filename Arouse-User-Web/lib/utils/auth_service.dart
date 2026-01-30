import 'package:flutter/foundation.dart';
import 'package:arouse_ecommerce_frontend_web/utils/token_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  Future<void> refresh() async {
    final token = await TokenStorage.getToken();
    isLoggedIn.value = token != null;
  }

  void setLoggedIn(bool v) => isLoggedIn.value = v;
}
