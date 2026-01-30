import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class BookingFailureDialog extends StatelessWidget {
  const BookingFailureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 500,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 40,
          vertical: isMobile ? 28 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button (top right)
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 26, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Check Icon
            Image.asset('assets/images/Home_Images/Book_Test_Drive/failed.png'),

            const SizedBox(height: 25),

            // Title
            Text(
              "Oops! This vehicle is not available with us for the test Drive",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.mediumFont(context),
                color: const Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              "Please try another vehicle, we will reach out to you if this vehicle is available with us in future.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: AppSizes.smallFont(context),
                color: const Color(0xFF8F8F8F),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
