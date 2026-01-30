import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/booking_details.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
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
        appBar: CAppbar(),
        body: Center(child: Text("No Bookings")),
      );
    }
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: Column(
        children: [
          Container(
            padding: AppSizes.screenWidth(context) < 480
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : AppSizes.screenWidth(context) < 900
                ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                : const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
            width: AppSizes.screenWidth(context),
            decoration: BoxDecoration(color: Color(0xFF1A4C8E)),
            child: Text(
              'My Booking',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.titleFont(context),
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              itemCount: widget.bookings.length,
              itemBuilder: (context, index) {
                final booking = widget.bookings[index];
                //If Desktop
                return AppSizes.isDesktop(context)
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetails(booking: booking),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: 16,
                            left: AppSizes.screenWidth(context) * 0.1,
                            right: AppSizes.screenWidth(context) * 0.2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFDADADA),
                              width: 0.74,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/booking_car.svg',
                                      height: 92,
                                      width: 92,
                                    ),
                                    SizedBox(width: 25),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Booking ID: ${booking["bookingId"]}',
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizes.mediumFont(
                                              context,
                                            ),
                                            letterSpacing: 0.5,
                                            color: Color(0xFF1F384C),
                                          ),
                                        ),
                                        Text(
                                          'Date: ${booking['updatedAt']} | Branch: ${booking['branch'] ?? ""}',
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontWeight: FontWeight.w400,
                                            fontSize: AppSizes.smallFont(
                                              context,
                                            ),
                                            color: Color(0xFF3E3E3E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF1A4C8E),
                                  size: AppSizes.iconLarge(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetails(booking: booking),
                            ),
                          );
                        },
                        child: Container(
                          //If Mobile
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xFFDADADA),
                              width: 0.74,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/booking_car.svg',
                                ),
                                Text(
                                  'Booking ID: ${booking["bookingId"]}',
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
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
