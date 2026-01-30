import 'package:flutter/material.dart';

class AppSizes {
  // Breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 600;
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600 &&
      MediaQuery.of(context).size.width <= 1024;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1024;

  static screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
  // AppBar Logo

  static double logoHeight(BuildContext context) {
    if (isDesktop(context)) return 70;
    if (isTablet(context)) return 60;
    return 45;
  }

  static double logoWidth(BuildContext context) {
    if (isDesktop(context)) return 110;
    if (isTablet(context)) return 90;
    return 60;
  }

  // Featured Car
  static double carCardMinHeight(BuildContext context) {
    if (isDesktop(context)) return 800;
    if (isTablet(context)) return 600;
    return 460;
  }

  static double carCardMinWidth(BuildContext context) {
    if (isDesktop(context)) return 1050;
    if (isTablet(context)) return 800;
    return 460;
  }

  static double carImageHeight(BuildContext context) {
    return carCardMinHeight(context) * (isMobile(context) ? 0.55 : 0.70);
  }
  // ------------------ FONT SIZES ------------------

  static double carNameFont(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 16;
    return 12;
  }

  static double carPriceFont(BuildContext context) {
    if (isDesktop(context)) return 20;
    if (isTablet(context)) return 16;
    return 8;
  }

  // ---------------- BUTTON DIMENSIONS ----------------
  static double buttonWidth(BuildContext context) {
    if (isDesktop(context)) return 467;
    if (isTablet(context)) return 200;
    return 100;
  }

  static EdgeInsets buttonPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 18, horizontal: 32);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 15, horizontal: 26);
    }
    return const EdgeInsets.symmetric(vertical: 12, horizontal: 18);
  }

  static double buttonFont(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 14;
    return 12;
  }

  // Font Sizes
  static double extraLargeFont(BuildContext context) {
    if (isDesktop(context)) return 70;
    if (isTablet(context)) return 40;
    return 30;
  }

  static double titleFont(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 28;
    return 24;
  }

  static double mediumFont(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 16;
  }

  static double bodyFont(BuildContext context) {
    if (isDesktop(context)) return 20;
    if (isTablet(context)) return 18;
    return 16;
  }

  static double smallFont(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 14;
    return 12;
  }

  // Image Sizes
  static double bannerHeight(BuildContext context) {
    if (isDesktop(context)) return 450;
    if (isTablet(context)) return 350;
    return 250;
  }

  static double productImage(BuildContext context) {
    if (isDesktop(context)) return 220;
    if (isTablet(context)) return 180;
    return 140;
  }

  // Padding / Margin
  static double horizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 20;
    return 16;
  }

  static double verticalPadding(BuildContext context) {
    if (isDesktop(context)) return 40;
    if (isTablet(context)) return 30;
    return 20;
  }

  /// 🔥 Button Sizes
  static Size buttonSize(BuildContext context) {
    if (isDesktop(context)) return const Size(200, 55);
    if (isTablet(context)) return const Size(170, 50);
    return const Size(150, 45);
  }

  static double buttonFontSize(BuildContext context) {
    if (isDesktop(context)) return 18;
    if (isTablet(context)) return 16;
    return 14;
  }

  /// 🔥 Icon Sizes
  static double iconLarge(BuildContext context) {
    if (isDesktop(context)) return 34;
    if (isTablet(context)) return 28;
    return 24;
  }

  static double iconMedium(BuildContext context) {
    if (isDesktop(context)) return 26;
    if (isTablet(context)) return 22;
    return 20;
  }

  static double iconSmall(BuildContext context) {
    if (isDesktop(context)) return 16;
    if (isTablet(context)) return 12;
    return 9;
  }
}
