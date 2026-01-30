import 'package:arouse_ecommerce_frontend/pages/home_screen.dart';
import 'package:arouse_ecommerce_frontend/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend/authentication/onboarding_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      await ProfileApi().getCurrentUser();
      isLoggedIn = true;
    } catch (_) {
      //await TokenStorage.clearToken();
      isLoggedIn = false;
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return isLoggedIn ? const HomeScreen() : const OnboardingPage();
  }
}
