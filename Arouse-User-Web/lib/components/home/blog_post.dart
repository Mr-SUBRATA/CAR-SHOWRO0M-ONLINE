import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class BlogPost extends StatelessWidget {
  final String buttonLabel;
  final Uint8List? carImageBytes;
  final String title;
  final String date;
  final String user;
  final bool isLuxury;
  final VoidCallback onTap;
  const BlogPost({
    super.key,
    this.carImageBytes,
    required this.buttonLabel,
    required this.title,
    required this.date,
    required this.user,
    this.isLuxury = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppSizes.screenWidth(context) > 1200
            ? 400
            : AppSizes.screenWidth(context) > 800
            ? 330
            : AppSizes.screenWidth(context) * 0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    carImageBytes!,
                    height: 300,
                    width: 450,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFF050B20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              children: [
                Text(
                  user,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
