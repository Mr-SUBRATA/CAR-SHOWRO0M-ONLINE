import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class BookingDone extends StatelessWidget {
  const BookingDone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(screenName: "Booking Done"),
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
              'Thank you for booking your test drive with Arouse Automotive',
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
              'Our Executive will call you for the confirmation',
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

Widget bookingFailure() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/booking_failure.png'),
          SizedBox(height: 43),
          Center(
            child: Text(
              'Oops! This vehicle is not available with us for the test Drive',
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
              'Please try another vehicle, we will reach out to you if this vehicle is available with us in future.',
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
