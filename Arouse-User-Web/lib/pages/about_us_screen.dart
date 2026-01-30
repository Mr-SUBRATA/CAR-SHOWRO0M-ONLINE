import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: CAppbar(selectedIndex: 1),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;
          final bool isTablet = constraints.maxWidth < 1100;

          final double maxContentWidth = isMobile ? constraints.maxWidth : 900;

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 24,
                    vertical: isMobile ? 16 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// LOGO
                      const SizedBox(height: 12),
                      Image.asset(
                        "assets/image.png",
                        height: isMobile ? 70 : 110,
                      ),

                      const SizedBox(height: 20),

                      /// TITLE
                      Text(
                        "About Us",
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0A4C8B),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// MAIN CARD
                      Container(
                        padding: EdgeInsets.all(isMobile ? 16 : 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle("Who We Are", isMobile),
                            sectionText(
                              "Arouse is a modern automotive platform designed "
                              "to simplify vehicle discovery, comparison and "
                              "ownership through a secure digital experience.",
                              isMobile,
                            ),

                            const SizedBox(height: 16),

                            sectionTitle("What We Do", isMobile),

                            /// RESPONSIVE BULLETS
                            isTablet
                                ? Column(
                                    children: bulletList
                                        .map((e) => bulletPoint(e, isMobile))
                                        .toList(),
                                  )
                                : Wrap(
                                    spacing: 20,
                                    runSpacing: 8,
                                    children: bulletList
                                        .map(
                                          (e) => SizedBox(
                                            width: 400,
                                            child: bulletPoint(e, isMobile),
                                          ),
                                        )
                                        .toList(),
                                  ),

                            const SizedBox(height: 16),

                            sectionTitle("Our Mission", isMobile),
                            sectionText(
                              "To build a trusted, transparent and "
                              "user-first automotive ecosystem "
                              "that empowers users at every step.",
                              isMobile,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// FOOTER
                      Text(
                        "Arouse App v1.0.0",
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "© 2025 Arouse Technologies",
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> get bulletList => [
    "Discover & compare vehicles easily",
    "Secure OTP based authentication",
    "Digital KYC & verification",
    "Fast and reliable user experience",
    "Book test drives online",
    "Track bookings & updates",
  ];

  Widget sectionTitle(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 16 : 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0A4C8B),
        ),
      ),
    );
  }

  Widget sectionText(String text, bool isMobile) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isMobile ? 13 : 15,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }

  Widget bulletPoint(String text, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("• "),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: isMobile ? 13 : 15, height: 1.5),
          ),
        ),
      ],
    );
  }
}
