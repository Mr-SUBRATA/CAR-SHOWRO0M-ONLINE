import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/login/login_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/login/otp_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/signup/sign_up_otp.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/signup/signup_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum AuthStep { loginPhone, loginOtp, signupDetails, signupOtp }

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  AuthStep step = AuthStep.loginPhone;
  bool isLogin = true;
  String loginPhoneNumber = "";
  String signupPhone = "";
  String signupEmail = "";
  String signupName = "";

  double dialogWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1100) return 420;
    if (w > 700) return 380;
    return w * 0.92;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          width: dialogWidth(context),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_tabs(), const SizedBox(height: 24), _body()],
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return Row(
      children: [
        _tab("Login", isLogin, () {
          setState(() {
            isLogin = true;
            step = AuthStep.loginPhone;
          });
        }),
        _tab("Sign Up", !isLogin, () {
          setState(() {
            isLogin = false;
            step = AuthStep.signupDetails;
          });
        }),
      ],
    );
  }

  Widget _tab(String title, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? AppColors.buttoColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              color: active ? AppColors.buttoColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (step) {
      case AuthStep.loginPhone:
        return LoginPhoneView(
          onNext: (phone) => setState(() {
            loginPhoneNumber = phone;
            step = AuthStep.loginOtp;
          }),
        );
      case AuthStep.loginOtp:
        return OtpView(
          onBack: () => setState(() => step = AuthStep.loginPhone),
          phoneNumber: loginPhoneNumber,
        );
      case AuthStep.signupDetails:
        return SignupDetailsView(
          onNext: (phone, email, name) => setState(() {
            signupPhone = phone;
            signupEmail = email;
            signupName = name;
            step = AuthStep.signupOtp;
          }),
        );
      case AuthStep.signupOtp:
        return SignUpOtp(
          onBack: () => setState(() => step = AuthStep.signupDetails),
          phoneNumber: signupPhone,
          email: signupEmail,
          name: signupName,
        );
    }
  }
}
