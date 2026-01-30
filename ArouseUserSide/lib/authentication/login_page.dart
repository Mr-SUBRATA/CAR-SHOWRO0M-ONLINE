import 'package:arouse_ecommerce_frontend/api/auth_api.dart';
import 'package:arouse_ecommerce_frontend/authentication/otp_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

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
                ? 0.011
                : isTablet
                ? 0.056
                : 0.36);

        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    Container(
                      width: isWeb
                          ? 450
                          : isTablet
                          ? 350
                          : double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter Phone Number",
                            style: TextStyle(
                              fontSize: isWeb
                                  ? 24
                                  : isTablet
                                  ? 24
                                  : 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "Please enter your phone number to verify your identity",
                            style: TextStyle(
                              fontSize: isWeb
                                  ? 18
                                  : isTablet
                                  ? 18
                                  : 14,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            "Phone Number*",
                            style: TextStyle(
                              fontSize: isWeb
                                  ? 18
                                  : isTablet
                                  ? 18
                                  : 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF004C90),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                DropdownButton<String>(
                                  value: "+91",
                                  onChanged: (value) {},
                                  underline: SizedBox(),
                                  items: ["+91", "+1", "+44", "+61"]
                                      .map(
                                        (code) => DropdownMenuItem(
                                          value: code,
                                          child: Text(code),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: "Enter your Phone Number",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final phone = phoneController.text.trim();

                                if (phone.length != 10) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Enter valid phone number'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => isLoading = true);

                                final success = await AuthApi().loginSendOtp(
                                  phone,
                                );
                                setState(() => isLoading = false);

                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OtpPage(phoneNumber: phone),
                                    ),
                                  );
                                  phoneController.clear();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to send OTP'),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF004C90),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                ),
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
                                      "Next",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Back",
                                style: TextStyle(color: Color(0xFF004C90)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
