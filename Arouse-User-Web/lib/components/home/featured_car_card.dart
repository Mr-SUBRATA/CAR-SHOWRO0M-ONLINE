import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend_web/api/compare_car_api.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/test_drive_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/compare_car.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FeaturedCarCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final bool isLuxury;

  const FeaturedCarCard({super.key, required this.car, this.isLuxury = false});

  Uint8List? getCarImageBytes(Map<String, dynamic> car) {
    try {
      if (car["images"] != null && car["images"].isNotEmpty) {
        var imageData = car["images"][0]["data"]["data"];
        List<int> bytes = List<int>.from(imageData);
        return Uint8List.fromList(bytes);
      }
    } catch (e) {
      print("Failed to parse car image: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bytes = getCarImageBytes(car);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen size
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // Define breakpoints for responsiveness
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1200;
        final isLargeScreen = screenWidth >= 1200;

        // Responsive multipliers
        final cardWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : (isSmallScreen
                  ? screenWidth
                  : isMediumScreen
                  ? screenWidth * 0.8
                  : screenWidth * 0.3);
        final imageHeight = cardWidth * 0.4; // Aspect ratio, adjustable
        final paddingHorizontal = screenWidth * (isSmallScreen ? 0.02 : 0.02);
        final paddingVertical = screenHeight * (isSmallScreen ? 0.02 : 0.015);
        final spacingSmall = screenHeight * (isSmallScreen ? 0.01 : 0.005);
        final spacingMedium = screenHeight * (isSmallScreen ? 0.02 : 0.01);
        final spacingLarge = screenHeight * (isSmallScreen ? 0.04 : 0.02);
        final buttonHeight = screenHeight * (isSmallScreen ? 0.05 : 0.04);
        final iconSizeSmall = screenHeight * (isSmallScreen ? 0.02 : 0.02);
        final iconSizeMedium = screenHeight * (isSmallScreen ? 0.03 : 0.025);
        final fontSizeMultiplier = isSmallScreen
            ? 0.7
            : isMediumScreen
            ? 0.9
            : 1.0; // Adjusted for more flexibility

        if (bytes == null) {
          return Container(
            height: imageHeight,
            width: cardWidth,
            color: Colors.grey.shade200,
            child: Icon(Icons.directions_car, size: iconSizeMedium),
          );
        }

        return Container(
          width: cardWidth,
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xFFE4E4E4),
              width: screenWidth * 0.001,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Image.memory(
                    bytes,
                    height: imageHeight,
                    width: cardWidth,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: imageHeight * 0.4,
                    right: cardWidth * 0.25,
                    child: SvgPicture.asset(
                      'assets/icons/360_view.svg',
                      height: imageHeight * 0.1,
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.02,
                    right: 0,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          List<dynamic> carList =
                              await CompareCarApi.addToCompare(car['_id']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompareCar(selectedCarsFromPrev: carList),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.05,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/compare.svg',
                                color: Color(0xFFFFFFFF),
                                height: iconSizeSmall,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                'Add to Compare',
                                style: TextStyle(
                                  color: Color(0xFFFFFFFF),
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize:
                                      AppSizes.smallFont(context) *
                                      fontSizeMultiplier,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingSmall),
              Text(
                car['name'],
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w800,
                  fontSize: AppSizes.carNameFont(context) * fontSizeMultiplier,
                  color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF1F384C),
                ),
              ),
              SizedBox(height: spacingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Starting at',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize:
                                AppSizes.carPriceFont(context) *
                                fontSizeMultiplier,
                            letterSpacing: 0.76,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF393939),
                          ),
                        ),
                        SizedBox(height: spacingSmall),
                        Text(
                          'Rs. ${car['price']} onwards',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize:
                                AppSizes.carPriceFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF000000),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'On-Road Price',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            fontSize:
                                AppSizes.carPriceFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF9D9D9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * (isSmallScreen ? 0.08 : 0.1),
                    width: screenWidth * 0.002,
                    decoration: BoxDecoration(color: Color(0xFFDBDBDB)),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Engine Options',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize:
                                AppSizes.carPriceFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF393939),
                          ),
                        ),
                        SizedBox(height: spacingSmall),
                        SvgPicture.asset(
                          'assets/icons/fuelType.svg',
                          height: iconSizeSmall,
                        ),
                        Text(
                          car['fuelType'] ?? "",
                          style: TextStyle(
                            fontSize:
                                AppSizes.smallFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury ? Color(0XFFFFFFFF) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * (isSmallScreen ? 0.08 : 0.1),
                    width: screenWidth * 0.002,
                    decoration: BoxDecoration(color: Color(0xFFDBDBDB)),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transmission Available',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize:
                                AppSizes.carPriceFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF393939),
                          ),
                        ),
                        SizedBox(height: spacingSmall),
                        SvgPicture.asset(
                          'assets/icons/transmission.svg',
                          height: iconSizeSmall,
                        ),
                        Text(
                          car['transmission'] ?? "",
                          style: TextStyle(
                            fontSize:
                                AppSizes.smallFont(context) *
                                fontSizeMultiplier,
                            color: isLuxury ? Color(0XFFFFFFFF) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingLarge),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF004C90),
                            width: screenWidth * 0.001,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.04,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                          ),
                        ),
                        child: Text(
                          "Learn More",
                          style: TextStyle(
                            fontFamily: "Work Sans",
                            fontSize: 14 * fontSizeMultiplier,
                            fontWeight: FontWeight.w700,
                            color: isLuxury
                                ? Color(0XFFFFFFFF)
                                : Color(0xFF004C90),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Expanded(
                    child: SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const TestDriveDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLuxury
                              ? Color.fromARGB(255, 94, 98, 110)
                              : const Color(0xFF004C90),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.05,
                            ),
                          ),
                        ),
                        child: Text(
                          'Book a test Drive',
                          style: TextStyle(
                            fontFamily: "Work Sans",
                            fontSize: 14 * fontSizeMultiplier,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingMedium),
            ],
          ),
        );
      },
    );
  }
}
