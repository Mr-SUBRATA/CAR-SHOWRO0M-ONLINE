import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: CAppbar(screenName: "About Us"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            /// LOGO
            Center(child: Image.asset("assets/image.png", height: 90)),

            const SizedBox(height: 24),

            /// CONTENT CARD
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Who We Are"),
                  _sectionText(
                    "Arouse is a modern automotive platform designed to simplify "
                    "vehicle discovery, comparison, and ownership through a "
                    "secure and seamless digital experience.",
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("What We Do"),
                  _bulletPoint("Discover & compare vehicles easily"),
                  _bulletPoint("Secure OTP-based login system"),
                  _bulletPoint("Digital KYC & profile verification"),
                  _bulletPoint("Fast and reliable user experience"),

                  const SizedBox(height: 20),

                  _sectionTitle("Our Mission"),
                  _sectionText(
                    "To build a trusted, transparent, and user-first automotive "
                    "ecosystem that empowers users at every step.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// FOOTER
            Column(
              children: const [
                Text(
                  "Arouse App v1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 6),
                Text(
                  "© 2025 Arouse Technologies",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0A4C8B),
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 14,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18, height: 1.3)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
