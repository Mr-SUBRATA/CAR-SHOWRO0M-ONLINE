import 'dart:convert';

import 'package:arouse_ecommerce_frontend_web/components/EMI_calculator/emi_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/test_drive_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/about_us_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/enquiry_page.dart';
import 'package:arouse_ecommerce_frontend_web/pages/home_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/luxury_cars.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/auth_dialog.dart';

class CAppbar extends StatefulWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final bool isLuxury;

  const CAppbar({super.key, this.selectedIndex = 0, this.isLuxury = false});

  @override
  Size get preferredSize {
    final width =
        WidgetsBinding
            .instance
            .platformDispatcher
            .views
            .first
            .physicalSize
            .width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    if (width < 600) return const Size.fromHeight(60); // mobile
    if (width < 1100) return const Size.fromHeight(80); // tablet
    return const Size.fromHeight(100); // desktop
  }

  @override
  State<CAppbar> createState() => _CAppbarState();
}

class _CAppbarState extends State<CAppbar> {
  Map<String, dynamic>? _user;
  late int isSelectedIndex;

  @override
  void initState() {
    super.initState();
    isSelectedIndex = widget.selectedIndex;

    AuthService.instance.isLoggedIn.addListener(_onAuthChanged);
    _loadUserIfNeeded();
  }

  @override
  void dispose() {
    AuthService.instance.isLoggedIn.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (AuthService.instance.isLoggedIn.value) {
      _loadUserIfNeeded();
    } else {
      setState(() => _user = null);
    }
  }

  Future<void> _loadUserIfNeeded() async {
    try {
      if (AuthService.instance.isLoggedIn.value) {
        final user = await ProfileApi().getCurrentUser();
        final photo = await ProfileApi().getProfilePhoto();

        if (photo != null) {
          user['profilePhoto'] = photo;
        }

        setState(() => _user = user);
      }
    } catch (_) {
      setState(() => _user = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = AppSizes.isMobile(context);
    final bool isDesktop = AppSizes.isDesktop(context);
    final bool forceHamburger = AppSizes.screenWidth(context) < 1380;

    return AppBar(
      backgroundColor: widget.isLuxury ? Color(0xFF050B20) : Colors.white,
      elevation: 5,
      automaticallyImplyLeading: false,
      toolbarHeight: AppSizes.isMobile(context)
          ? 60
          : AppSizes.isTablet(context)
          ? 100
          : 120,
      iconTheme: const IconThemeData(color: Color(0xFF1A4C8E)),
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// LOGO
                Image.asset(
                  "assets/image.png",
                  height: AppSizes.logoHeight(context),
                  width: AppSizes.logoWidth(context),
                  color: widget.isLuxury ? Color(0xFFFFFFFF) : null,
                ),
                const SizedBox(height: 12),
                if (!isMobile)
                  Text(
                    "AROUSE AUTOMOTIVE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isLuxury
                          ? Color(0xFFFFFFFF)
                          : Color(0xFF004C90),
                      fontFamily: "DMSans",
                    ),
                  ),
              ],
            ),

            const Spacer(),

            /// DESKTOP NAVIGATION
            if (isDesktop && !forceHamburger) ...[
              _menuButton("Home", 0),
              _menuButton("About Us", 1),
              _menuButton("Book a Test Drive", 2),
              _menuButton("Virtual Showroom", 3),
              _menuButton("Luxury Cars", 4),
              _menuButton("EMI Calculator", 5),
              _menuButton("Enquiry", 6),

              const SizedBox(width: 35),

              /// 🔥 KEY FIX HERE
              AuthService.instance.isLoggedIn.value && _user != null
                  ? _profileSection(_user!)
                  : _loginButton(context),
              const SizedBox(width: 25),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isLuxury
                      ? Color.fromARGB(255, 86, 91, 111)
                      : const Color(0xFF1A4C8E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 22,
                  ),
                ),
                child: const Text(
                  "Book Online",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontFamily: "DMSans",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// ---------------- MENU BUTTON ----------------
  Widget _menuButton(String label, int index) {
    return TextButton(
      onPressed: () {
        setState(() => isSelectedIndex = index);

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutUsScreen()),
          );
        } else if (index == 2) {
          showDialog(context: context, builder: (_) => TestDriveDialog());
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LuxuryCars()),
          );
        } else if (index == 5) {
          showDialog(context: context, builder: (_) => EmiDialog());
        } else if (index == 6) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EnquiryPage()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: isSelectedIndex == index ? 2 : 0,
              color: isSelectedIndex == index
                  ? widget.isLuxury
                        ? Color(0XFFFFFFFF)
                        : const Color(0xFF1A4C8E)
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallFont(context),
            fontWeight: FontWeight.w500,
            fontFamily: "DMSans",
            color: isSelectedIndex == index
                ? widget.isLuxury
                      ? Color(0XFFFFFFFF)
                      : const Color(0xFF004C90)
                : widget.isLuxury
                ? Color(0xFFFFFFFF)
                : Colors.black,
          ),
        ),
      ),
    );
  }

  /// ---------------- LOGIN BUTTON ----------------
  Widget _loginButton(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: widget.isLuxury ? Color(0XFFFFFFFF) : Color(0XFF1A4C8E),
          width: 2,
        ), // border
        foregroundColor: Colors.white, // text + icon color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // rounded corners
        ),
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const AuthDialog(),
          barrierDismissible: true,
        );
      },
      child: Text(
        "Login/Signup",
        style: TextStyle(
          color: widget.isLuxury ? Color(0XFFFFFFFF) : Color(0xFF1A4C8E),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ---------------- PROFILE SECTION ----------------
  Widget _profileSection(Map<String, dynamic> user) {
    final displayName = user['name'] ?? user['fullName'] ?? 'User';
    final firstName = displayName.toString().split(' ').first;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isLuxury ? Color(0XFFFFFFFF) : Color(0xFF1A4C8E),
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: (user['profilePhoto'] != null)
                ? Image.memory(
                    base64Decode(
                      (user['profilePhoto'] as String).split(',').last,
                    ),
                    fit: BoxFit.cover,
                  )
                : _initialAvatar(user),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "Hi $firstName",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            fontFamily: "DMSans",
            color: widget.isLuxury ? Color(0XFFFFFFFF) : Color(0xFF1A4C8E),
          ),
        ),
      ],
    );
  }
}

Widget _initialAvatar(Map<String, dynamic>? user) {
  final name = user?['name']?.toString() ?? 'U';

  return Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
      style: TextStyle(
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w600,
        fontSize: 32,
        color: Color(0xFF1A4C8E),
      ),
    ),
  );
}
