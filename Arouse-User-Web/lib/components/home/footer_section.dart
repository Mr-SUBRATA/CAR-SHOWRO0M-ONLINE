import 'package:arouse_ecommerce_frontend_web/api/home_api.dart';
import 'package:arouse_ecommerce_frontend_web/pages/about_us_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/help_and_support.dart';
import 'package:arouse_ecommerce_frontend_web/pages/search_vehicles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FooterSection extends StatefulWidget {
  final bool isLuxury;
  const FooterSection({super.key, this.isLuxury = false});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection> {
  TextEditingController searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> searchResults;
  void searchCar(String query) {
    searchResults = HomeApi.searchCar(query);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchedVehicles(
          vehicles: searchResults,
          query: searchController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      color: widget.isLuxury ? Color(0XFF050B20) : const Color(0xFF071224),
      padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 Brand + Subscribe Section
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 750;

              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        brandHeader(),
                        const SizedBox(height: 25),
                        subscribeBox(w),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        brandHeader(),
                        const SizedBox(width: 30),
                        subscribeBox(w),
                      ],
                    );
            },
          ),
          const SizedBox(height: 60),

          Divider(),
          const SizedBox(height: 60),

          /// 🔹 Footer Link Columns (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              bool isTablet = constraints.maxWidth < 1100;
              bool isMobile = constraints.maxWidth < 650;

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: footerColumns(),
                );
              } else if (isTablet) {
                return Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  children: footerColumns(),
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: footerColumns(),
                );
              }
            },
          ),

          const SizedBox(height: 60),
          const Divider(color: Color(0xFF2B3545)),
          const SizedBox(height: 12),

          /// 🔹 Copyright Row (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 650;
              return isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "© 2024 exemple.com. All rights reserved.",
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Terms & Conditions   •   Privacy Notice",
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "© 2024 exemple.com. All rights reserved.",
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                        Text(
                          "Terms & Conditions   •   Privacy Notice",
                          style: TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  /// BRAND TITLE + SUBTEXT
  Widget brandHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "AROUSE ",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: "DM Sans",
                  color: Color(0xFF1A4C8E), // AROUSE in blue
                ),
              ),
              TextSpan(
                text: "AUTOMOTIVE",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: "DM Sans",
                  color: Colors.white, // AUTOMOTIVE in white
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Receive pricing updates, shopping tips & more!",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA7B3C4),
            fontFamily: "DM Sans",
          ),
        ),
      ],
    );
  }

  /// EMAIL SUBSCRIPTION FIELD
  Widget subscribeBox(double w) {
    return Container(
      width: w < 750 ? double.infinity : w * 0.35,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2433),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Your email address",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: widget.isLuxury
                  ? Color.fromARGB(255, 85, 86, 100)
                  : Color(0xFF1B74D1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// FOOTER COLUMNS LIST
  List<Widget> footerColumns() {
    return [
      buildFooterColumn("Company", [
        "About Us",
        "Blog",
        "Services",
        "FAQs",
        "Terms",
        "Contact Us",
      ]),
      buildFooterColumn("Quick Links", [
        "Get in Touch",
        "Help center",
        "Live chat",
        "How it works",
      ]),
      buildFooterColumn("Our Brands", [
        "Toyota",
        "Porsche",
        "Audi",
        "BMW",
        "Ford",
        "Nissan",
        "Peugeot",
        "Volkswagen",
      ]),
      buildFooterColumn("Vehicles Type", [
        "Sedan",
        "Hatchback",
        "SUV",
        "Hybrid",
        "Electric",
        "Coupe",
        "Truck",
        "Convertible",
      ]),
      socialColumn(),
    ];
  }

  /// SOCIAL
  Widget socialColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Connect With Us",
          style: TextStyle(
            fontFamily: "DM Sans",
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 18),
        Row(
          children: [
            Icon(FontAwesomeIcons.facebookF, size: 18, color: Colors.white),
            SizedBox(width: 18),
            Icon(FontAwesomeIcons.twitter, size: 18, color: Colors.white),
            SizedBox(width: 18),
            Icon(FontAwesomeIcons.instagram, size: 18, color: Colors.white),
            SizedBox(width: 18),
            Icon(FontAwesomeIcons.linkedinIn, size: 18, color: Colors.white),
          ],
        ),
      ],
    );
  }

  /// FOOTER COLUMN BUILDER
  Widget buildFooterColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "DM Sans",
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                // call your search function
                if (title == "Our Brands" || title == "Vehicles Type") {
                  searchCar(e);
                } else if (title == "Quick Links") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpAndSupport()),
                  );
                } else if (title == "Company") {
                  switch (e) {
                    case "About Us":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutUsScreen(),
                        ),
                      );
                      break;
                    case "Blog":
                      break;
                    case "Services":
                      break;
                    case "FAQs":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpAndSupport(),
                        ),
                      );
                      break;
                    case "Terms":
                      break;
                    case "Contact Us":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpAndSupport(),
                        ),
                      );
                      break;
                    default:
                      break;
                  }
                }
              },
              hoverColor: Colors.transparent,
              child: Text(
                e,
                style: const TextStyle(
                  fontFamily: "DM Sans",
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Color(0xFFA7B3C4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
