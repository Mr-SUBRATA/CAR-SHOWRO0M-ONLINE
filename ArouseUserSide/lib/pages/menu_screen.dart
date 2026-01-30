import 'dart:convert';

import 'package:arouse_ecommerce_frontend/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend/authentication/onboarding_page.dart';
import 'package:arouse_ecommerce_frontend/components/Book_test_drive/my_booking.dart';
import 'package:arouse_ecommerce_frontend/components/User_profile/edit_profile.dart';
import 'package:arouse_ecommerce_frontend/components/User_profile/my_documents.dart';
import 'package:arouse_ecommerce_frontend/components/help&support/helpPage.dart';
import 'package:arouse_ecommerce_frontend/pages/about_us_screen.dart';
import 'package:arouse_ecommerce_frontend/pages/refer_and_earn.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool isLogedIn = false;
  bool isLoading = true;
  String? profilePhoto;

  Map<String, dynamic>? user;
  List<dynamic>? bookings;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadProfilePhoto();
    loadBookings();
  }

  Future<void> loadBookings() async {
    var data = await ProfileApi.getMyBookings();
    setState(() {
      bookings = data;
    });
    print("Bookings: $bookings");
  }

  Future<void> loadProfilePhoto() async {
    try {
      final photo = await ProfileApi().getProfilePhoto();
      if (!mounted) return;
      setState(() {
        profilePhoto = photo;
      });
    } catch (_) {}
  }

  Future<void> loadUser() async {
    try {
      final data = await ProfileApi().getCurrentUser();
      setState(() {
        user = data;
        isLogedIn = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLogedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //double screenHeight = MediaQuery.of(context).size.height;
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(leading: Container()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              color: Color(0xFF1A4C8E),
              child: isLogedIn
                  ? Padding(
                      padding: const EdgeInsets.only(
                        top: 9,
                        bottom: 9,
                        left: 17,
                        right: 27,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi ${user?["name"] ?? ""}!',
                                style: TextStyle(
                                  fontFamily: 'Work Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  letterSpacing: -0.2,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditProfile(),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: Color(0xFFBEBEBE),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFFBEBEBE),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: profilePhoto != null
                                ? Image.memory(
                                    base64Decode(profilePhoto!.split(',').last),
                                    fit: BoxFit.cover,
                                  ).image
                                : null,

                            child: profilePhoto == null
                                ? Text(
                                    user?["name"] != null
                                        ? user!["name"]
                                              .substring(0, 1)
                                              .toUpperCase()
                                        : "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        top: 9,
                        bottom: 9,
                        left: 17,
                        right: 27,
                      ),
                      child: Text(
                        'Hey!',
                        style: TextStyle(
                          fontFamily: 'Work Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: -0.2,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (isLogedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyBooking(bookings: bookings ?? []),
                    ),
                  );
                }
              },
              child: ListTile(
                leading: Icon(
                  Icons.shopping_bag_outlined,
                  color: isLogedIn
                      ? Color(0xFF1F1F1F)
                      : Color.fromRGBO(107, 105, 105, 1),
                ),
                title: Text(
                  'Your Booking',
                  style: isLogedIn
                      ? TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1F1F1F),
                        )
                      : TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(107, 105, 105, 1),
                        ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                if (isLogedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyDocuments()),
                  );
                }
              },
              child: ListTile(
                leading: Icon(
                  Icons.bookmark_outline,
                  color: isLogedIn
                      ? Color(0xFF1F1F1F)
                      : Color.fromRGBO(107, 105, 105, 1),
                ),
                title: Text(
                  'My Documents',
                  style: isLogedIn
                      ? TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1F1F1F),
                        )
                      : TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color.fromRGBO(107, 105, 105, 1),
                        ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReferAndEarn()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.share),
                title: Text(
                  'Refer & Earn',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsScreen()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  'About Us',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Helppage()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text(
                  'Help & Support',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 14),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.feedback_outlined),
              title: Text(
                'Feedback Form',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 14),
            ),
            SizedBox(height: 100),
            isLogedIn
                ? TextButton(
                    onPressed: () async {
                      await ProfileApi().logOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => OnboardingPage()),
                        (route) => false,
                      );
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Color(0xFFFB344F),
                        size: 24,
                      ),
                      title: Text(
                        'LogOut',
                        style: const TextStyle(
                          fontFamily: "Inter",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFB344F),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004C90),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          'Login/Register',
                          style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
