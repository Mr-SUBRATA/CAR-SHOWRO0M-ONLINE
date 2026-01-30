import 'package:flutter/material.dart';

class AuthSuccessDialog extends StatelessWidget {
  const AuthSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Success Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A4C8E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 42, color: Colors.white),
                ),

                const SizedBox(height: 24),

                // ✅ Title
                const Text(
                  "Thank you for sign up with Arouse Automotive",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 12),

                // ✅ Subtitle
                const Text(
                  "Please Verify your Email Address and Login Again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ❌ Close Button
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close, size: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
