import 'package:arouse_ecommerce_frontend_web/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget primaryButton(
  String text,
  VoidCallback? onTap, {
  bool isLoading = false,
  double radius = 24,
}) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttoColor,
        disabledBackgroundColor: AppColors.buttoColor.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.buttoTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'DM Sans',
                ),
              ),
            ),
    ),
  );
}
