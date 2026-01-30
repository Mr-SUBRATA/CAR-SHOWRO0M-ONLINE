import 'package:arouse_ecommerce_frontend/api/auth_api.dart';
import 'package:arouse_ecommerce_frontend/authentication/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  const OtpPage({super.key, required this.phoneNumber});
  @override
  OtpPageState createState() => OtpPageState();
}

class OtpPageState extends State<OtpPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isResending = false;

  Future<void> resendOtp() async {
    if (isResending) return;

    setState(() => isResending = true);

    final success = await AuthApi().loginSendOtp(widget.phoneNumber);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
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

  Future<void> verifyOtp() async {
    final otp = _controllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid 6-digit OTP")));
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthApi().verifyLoginOtp(widget.phoneNumber, otp);

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
                  ? 0.056
                  : isTablet
                  ? 0.046
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
                    SizedBox(height: screenHeight * 0.02),
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
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          const Text(
            "We have sent an OTP to your phone number",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => _buildOtpTextField(index, isLargeScreen),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
              Navigator.pop(context);
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
      width: isLargeScreen ? 55 : 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(
          fontSize: isLargeScreen ? 22 : 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF004C90), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
