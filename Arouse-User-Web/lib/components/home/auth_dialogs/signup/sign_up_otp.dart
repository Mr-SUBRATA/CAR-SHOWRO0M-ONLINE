import 'package:arouse_ecommerce_frontend_web/api/authentication_api.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/auth_success_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/primary_button.dart';
import 'package:flutter/material.dart';

class SignUpOtp extends StatefulWidget {
  final VoidCallback onBack;
  final String phoneNumber;
  final String email;
  final String name;

  const SignUpOtp({
    super.key,
    required this.onBack,
    required this.phoneNumber,
    required this.email,
    required this.name,
  });

  @override
  State<SignUpOtp> createState() => _SignUpOtpState();
}

class _SignUpOtpState extends State<SignUpOtp> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool isLoading = false;
  bool isResending = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _resendOtp() async {
    if (isResending) return;

    setState(() => isResending = true);

    final success = await AuthenticationApi().signUpSendOtp(
      widget.phoneNumber,
      widget.email,
      widget.name,
    );

    setState(() => isResending = false);

    if (success) {
      _clearOtp();
      _showSnack("OTP resent successfully");
    } else {
      _showSnack("Failed to resend OTP");
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length != 6) {
      _showSnack("Enter valid 6-digit OTP");
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthenticationApi().verifySignUpOtp(
      widget.phoneNumber,
      otp,
      widget.name,
      widget.email,
    );

    setState(() => isLoading = false);

    if (!result["success"]) {
      _showSnack(result["message"]);
      return;
    }

    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AuthSuccessDialog(),
    );
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
          "Enter OTP",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        const Text(
          "We have sent an OTP to your phone number",
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, _otpBox),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Didn’t receive OTP? "),
            GestureDetector(
              onTap: _resendOtp,
              child: Text(
                isResending ? "Resending..." : "Resend",
                style: const TextStyle(
                  color: Color(0xFF1A4C8E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        primaryButton(
          isLoading ? "Verifying..." : "Verify & Proceed",
          isLoading ? null : _verifyOtp,
        ),

        const SizedBox(height: 12),

        TextButton(onPressed: widget.onBack, child: const Text("Back")),
      ],
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 48,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: "",
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
