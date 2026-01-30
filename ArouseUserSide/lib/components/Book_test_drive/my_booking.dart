import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyBooking extends StatefulWidget {
  final List<dynamic> bookings;
  const MyBooking({super.key, required this.bookings});

  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> {
  @override
  Widget build(BuildContext context) {
    if (widget.bookings.isEmpty) {
      return Scaffold(
        appBar: CAppbar(screenName: "My Booking"),
        body: Center(child: Text("No Bookings")),
      );
    }
    return Scaffold(
      appBar: CAppbar(screenName: "My Booking"),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        itemCount: widget.bookings.length,
        itemBuilder: (context, index) {
          final booking = widget.bookings[index];

          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFDADADA), width: 0.74),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset('assets/icons/booking_car.svg'),
                  Text(
                    'Booking ID: ${booking['bookingId']}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: Color(0xFF1F384C),
                    ),
                  ),
                  Text(
                    'Date: ${booking['updatedAt']} | Branch: ${booking['branch'] ?? ""}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF3E3E3E),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
