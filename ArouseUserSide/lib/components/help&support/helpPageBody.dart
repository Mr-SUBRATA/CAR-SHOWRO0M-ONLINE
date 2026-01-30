import 'package:arouse_ecommerce_frontend/components/ContactUs/contact_us.dart';
import 'package:arouse_ecommerce_frontend/components/FAQ%E2%80%99s/faqs.dart';
import 'package:arouse_ecommerce_frontend/components/PrivacyPolicy/privacy_and_policy.dart';
import 'package:arouse_ecommerce_frontend/components/RefundPolicy/refund_policy.dart';
import 'package:arouse_ecommerce_frontend/components/Terms&Conditions/terms_and_conditions.dart';
import 'package:flutter/material.dart';

class Helppagebody extends StatelessWidget {
  const Helppagebody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25.0,
            right: 25.0,
            top: 40,
            bottom: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Faqs()),
                  );
                },
                child: Text(
                  "FAQ’s",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
              Divider(thickness: 2, color: Color.fromRGBO(205, 209, 224, 1)),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ContactUs()),
                  );
                },
                child: Text(
                  "Contact Us",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
              Divider(thickness: 2, color: Color.fromRGBO(205, 209, 224, 1)),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TermsAndConditions(),
                    ),
                  );
                },
                child: Text(
                  "Terms & Conditions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
              Divider(thickness: 2, color: Color.fromRGBO(205, 209, 224, 1)),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PrivacyAndPolicy()),
                  );
                },
                child: Text(
                  "Privacy Policy",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
              Divider(thickness: 2, color: Color.fromRGBO(205, 209, 224, 1)),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RefundPolicy()),
                  );
                },
                child: Text(
                  "Refund Policy",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(31, 31, 31, 1),
                  ),
                ),
              ),
              Divider(thickness: 2, color: Color.fromRGBO(205, 209, 224, 1)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
