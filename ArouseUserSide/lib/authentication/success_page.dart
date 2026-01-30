import 'package:arouse_ecommerce_frontend/pages/home_screen.dart';
import 'package:flutter/material.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();

    // Redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "Registration Done",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: bookingSuccess(),
    );
  }
}

Widget bookingSuccess() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/booking_done.png'),
          SizedBox(height: 43),
          Center(
            child: Text(
              'Thank you for sign up with Arouse Automotive',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.27,
              ),
            ),
          ),
          SizedBox(height: 11),
          Center(
            child: Text(
              'Please Verify your Email Address and Login Again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                letterSpacing: -0.27,
                color: Color(0xFF8F8F8F),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
