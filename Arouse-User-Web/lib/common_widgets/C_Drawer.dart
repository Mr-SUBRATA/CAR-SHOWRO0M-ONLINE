import 'dart:convert';

import 'package:arouse_ecommerce_frontend_web/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/auth_dialogs/auth_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/pages/about_us_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/help_and_support.dart';
import 'package:arouse_ecommerce_frontend_web/pages/my_booking.dart';
import 'package:arouse_ecommerce_frontend_web/pages/my_documents.dart';
import 'package:arouse_ecommerce_frontend_web/pages/profile_screen.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:arouse_ecommerce_frontend_web/pages/refer_and_earn.dart';
import 'package:flutter/material.dart';

class CDrawer extends StatefulWidget {
  final bool isLoggedIn;

  const CDrawer({super.key, required this.isLoggedIn});

  @override
  State<CDrawer> createState() => _CDrawerState();
}

class _CDrawerState extends State<CDrawer> {
  late Future<Map<String, dynamic>?> _userFuture;
  List<dynamic>? bookings;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
    loadBookings();
  }

  Future<void> loadBookings() async {
    var data = await ProfileApi.getMyBookings();
    setState(() {
      bookings = data;
    });
    print("Bookings: $bookings");
  }

  Future<Map<String, dynamic>?> _fetchUser() async {
    try {
      final user = await ProfileApi().getCurrentUser();
      final photo = await ProfileApi().getProfilePhoto();

      if (photo != null) {
        user['profilePhoto'] = photo;
      }

      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isLoggedIn
        ? _buildUserDrawerAsync(context)
        : _loginDrawer(context);
  }

  Widget _buildUserDrawerAsync(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        /// ---------------- LOADING UI ---------------- ///
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        /// ---------------- ERROR UI ---------------- ///
        if (snapshot.hasError) {
          return const Drawer(
            child: Center(child: Text("Failed to load user")),
          );
        }

        final user = snapshot.data;

        /// ---------------- NULL USER UI ---------------- ///
        if (user == null) {
          return const Drawer(child: Center(child: Text("No user data found")));
        }

        /// safe name resolution
        final displayName =
            user['name'] ?? user['fullName'] ?? user['firstName'] ?? 'Hi!';

        return Drawer(
          shape: const Border(),
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(26, 76, 142, 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Color.fromRGBO(190, 190, 190, 1),
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.002),
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  size: 15,
                                  color: Color.fromRGBO(190, 190, 190, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 87,
                        width: 87,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF1A4C8E),
                            width: 4.83,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: (user['profilePhoto'] != null)
                              ? Image.memory(
                                  base64Decode(
                                    (user['profilePhoto'] as String)
                                        .split(',')
                                        .last,
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return _initialAvatar(user);
                                  },
                                )
                              : _initialAvatar(user),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// ---------------- MENU SECTIONS ---------------- ///
              _drawerMenuSection([
                _drawerItem(Icons.shopping_bag_outlined, "Your Bookings", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyBooking(bookings: bookings ?? []),
                    ),
                  );
                }, arrow: true),
                _divider(),
                _drawerItem(Icons.bookmark_outline, "My Documents", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyDocuments()),
                  );
                }, arrow: true),
                _divider(),
                _drawerItem(Icons.share_outlined, "Refer & Earn", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ReferAndEarn()),
                  );
                }, arrow: true),
              ]),

              SizedBox(height: screenHeight * 0.03),

              _drawerMenuSection([
                _drawerItem(Icons.error_outline, "About Us", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutUsScreen()),
                  );
                }, arrow: true),
                _divider(),
                _drawerItem(Icons.help_outline, "Help & Support", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HelpAndSupport()),
                  );
                }, arrow: true),
                _divider(),
                _drawerItem(
                  Icons.feedback_outlined,
                  "Feedback Form",
                  () {},
                  arrow: true,
                ),
              ]),

              const Spacer(),

              /// ---------------- LOGOUT ---------------- ///
              _drawerMenuSection([
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color.fromRGBO(251, 52, 79, 1),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Color.fromRGBO(251, 52, 79, 1),
                      fontSize: 16,
                    ),
                  ),
                  onTap: () async {
                    try {
                      await ProfileApi().logOut();
                    } catch (_) {}

                    AuthService.instance.setLoggedIn(false);
                    Navigator.pop(context);
                  },
                ),
              ]),
            ],
          ),
        );
      },
    );
  }
}

/// -------------------- LOGIN DRAWER -------------------- ///
Widget _loginDrawer(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Drawer(
    shape: const Border(),
    child: Column(
      children: [
        SizedBox(
          height: 100,
          child: const DrawerHeader(
            decoration: BoxDecoration(color: Color.fromRGBO(26, 76, 142, 1)),
            child: Row(
              children: [
                Text(
                  "Hey!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        _drawerMenuSection([
          _drawerItem(Icons.shopping_bag_outlined, "Your Bookings", () {}),
          _divider(),
          _drawerItem(Icons.bookmark_outline, "My Documents", () {}),
        ]),

        SizedBox(height: screenHeight * 0.03),

        _drawerMenuSection([
          _drawerItem(Icons.share_outlined, "Refer & Earn", () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReferAndEarn()),
            );
          }, arrow: true),
          _divider(),
          _drawerItem(Icons.error_outline, "About Us", () {}, arrow: true),
          _divider(),
          _drawerItem(Icons.help_outline, "Help & Support", () {}, arrow: true),
          _divider(),
          _drawerItem(
            Icons.feedback_outlined,
            "Feedback Form",
            () {},
            arrow: true,
          ),
        ]),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.of(context, rootNavigator: true).push(
                DialogRoute(
                  context: context,
                  builder: (_) => const AuthDialog(),
                  barrierDismissible: true,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(26, 76, 142, 1),
              shape: const StadiumBorder(),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Login/Register",
                style: TextStyle(color: Colors.white, fontSize: 15.5),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _initialAvatar(Map<String, dynamic>? user) {
  final name = user?['name']?.toString() ?? 'U';

  return Center(
    child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : 'U',
      style: const TextStyle(
        fontFamily: 'Open Sans',
        fontWeight: FontWeight.w600,
        fontSize: 32,
        color: Color(0xFF1A4C8E),
      ),
    ),
  );
}

/// ---------- REUSABLES ---------- ///
Widget _drawerMenuSection(List<Widget> children) {
  return Container(
    color: Colors.white,
    child: Column(children: children),
  );
}

Widget _drawerItem(
  IconData icon,
  String title,
  VoidCallback onTap, {
  bool arrow = false,
}) {
  return ListTile(
    leading: Icon(icon, size: 20),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    trailing: arrow ? const Icon(Icons.keyboard_arrow_right) : null,
    onTap: onTap,
  );
}

Divider _divider() =>
    const Divider(thickness: 0.5, color: Color.fromRGBO(205, 209, 224, 1));
