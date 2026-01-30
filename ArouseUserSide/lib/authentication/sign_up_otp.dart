import 'package:arouse_ecommerce_frontend/api/auth_api.dart';
import 'package:arouse_ecommerce_frontend/authentication/signup_page.dart';
import 'package:arouse_ecommerce_frontend/authentication/success_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpOtp extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String name;
  const SignUpOtp({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.name,
  });
  @override
  SignUpOtpState createState() => SignUpOtpState();
}

class SignUpOtpState extends State<SignUpOtp> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  bool isLoading = false;
  bool isResending = false;

  Future<void> resendOtp() async {
    if (isResending) return;

    setState(() => isResending = true);

    final success = await AuthApi().signUpSendOtp(
      widget.phoneNumber,
      widget.email,
      widget.name,
    );

    setState(() => isResending = false);

    if (success) {
      clearOtp();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP resent successfully")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to resend OTP")));
    }
  }

  void clearOtp() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> verifyOtp() async {
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid 6-digit OTP")));
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthApi().verifySignUpOtp(
      widget.phoneNumber,
      otp,
      widget.name,
      widget.email,
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result["message"])));

    if (result["success"]) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuccessPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Initialize controllers and focus nodes
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          bool isTablet = screenWidth > 600 && screenWidth <= 1024;
          bool isWeb = screenWidth > 1024;

          double horizontalPadding =
              screenWidth *
              (isWeb
                  ? 0.25
                  : isTablet
                  ? 0.15
                  : 0.00);
          double verticalPadding =
              screenHeight *
              (isWeb
                  ? 0.076
                  : isTablet
                  ? 0.056
                  : 0.36);

          bool isLargeScreen = screenWidth > 600;

          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/image.png",
                      width:
                          screenWidth *
                          (isWeb
                              ? 0.3
                              : isTablet
                              ? 0.5
                              : 0.7),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.020,
                    ),
                    _buildOtpContainer(isLargeScreen),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpContainer(bool isLargeScreen) {
    return Container(
      width: isLargeScreen ? 400 : double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Enter OTP",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.010),
          const Text(
            "We have sent an OTP to your phone number",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.020),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return _buildOtpTextField(index, isLargeScreen);
            }),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Didn't receive OTP? ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                TextSpan(
                  text: " Resend OTP",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF004C90),
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      await resendOtp();
                    },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004C90),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Verify and Proceed",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: const Text(
              "Back",
              style: TextStyle(color: Color(0xFF004C90), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpTextField(int index, bool isLargeScreen) {
    return SizedBox(
      width: isLargeScreen ? 60 : 50,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: isLargeScreen ? 24 : 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF004C90), width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          // Move forward
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          }
          // Move backward
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
