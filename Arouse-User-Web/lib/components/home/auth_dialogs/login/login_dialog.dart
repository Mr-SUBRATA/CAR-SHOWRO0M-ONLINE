import 'package:arouse_ecommerce_frontend_web/api/authentication_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_PhoneField.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/primary_button.dart';
import 'package:flutter/material.dart';

class LoginPhoneView extends StatefulWidget {
  final void Function(String phone) onNext;
  const LoginPhoneView({super.key, required this.onNext});

  @override
  State<LoginPhoneView> createState() => _LoginPhoneViewState();
}

class _LoginPhoneViewState extends State<LoginPhoneView> {
  String selectedCode = "+91";
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp(BuildContext context) async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      _showSnack(context, "Please enter phone number");
      return;
    }

    if (phone.length != 10) {
      _showSnack(context, "Enter valid phone number");
      return;
    }

    setState(() => isLoading = true);

    final success = await AuthenticationApi().loginSendOtp(
      "$selectedCode$phone",
    );

    setState(() => isLoading = false);

    if (!success) {
      _showSnack(context, "Failed to send OTP");
      return;
    }

    phoneController.clear();
    widget.onNext("$selectedCode$phone");
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Enter Phone Number",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          "Please enter your phone number to verify your identity",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        CPhoneField(
          label: "Phone Number",
          selectedCode: selectedCode,
          controller: phoneController,
          onCodeChanged: (code) {
            setState(() {
              selectedCode = code;
            });
          },
        ),

        const SizedBox(height: 24),

        primaryButton(
          isLoading ? "Sending OTP..." : "Next",
          isLoading ? null : () => _sendOtp(context),
        ),
      ],
    );
  }
}
