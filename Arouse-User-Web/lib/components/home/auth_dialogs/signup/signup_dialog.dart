import 'package:arouse_ecommerce_frontend_web/api/authentication_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_PhoneField.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_TextField.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/primary_button.dart';
import 'package:flutter/material.dart';

class SignupDetailsView extends StatefulWidget {
  final void Function(String phone, String email, String name) onNext;
  const SignupDetailsView({super.key, required this.onNext});

  @override
  State<SignupDetailsView> createState() => _SignupDetailsViewState();
}

class _SignupDetailsViewState extends State<SignupDetailsView> {
  String selectedCode = "+91";

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendSignupOtp() async {
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final name = nameController.text.trim();

    if (name.isEmpty) {
      _showSnack("Please enter your name");
      return;
    }

    if (!isValidEmail(email)) {
      _showSnack("Enter a valid email address");
      return;
    }

    if (phone.length != 10) {
      _showSnack("Enter valid phone number");
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthenticationApi().signUpSendOtp(phone, email, name);

    setState(() => isLoading = false);

    if (success) {
      widget.onNext("$selectedCode$phone", email, name);
    } else {
      _showSnack("Failed to send OTP");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Enter your details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        CTextfield(
          label: "Full Name",
          hint: "Enter your full name",
          controller: nameController,
        ),
        const SizedBox(height: 12),

        CTextfield(
          label: "Email",
          hint: "Enter your email",
          controller: emailController,
        ),
        const SizedBox(height: 12),

        CPhoneField(
          label: "Phone Number",
          selectedCode: selectedCode,
          controller: phoneController,
          onCodeChanged: (code) {
            setState(() => selectedCode = code);
          },
        ),

        const SizedBox(height: 24),

        primaryButton("Next", _sendSignupOtp, isLoading: isLoading),
      ],
    );
  }
}
