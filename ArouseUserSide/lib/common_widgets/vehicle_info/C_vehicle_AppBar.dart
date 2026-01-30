import 'package:arouse_ecommerce_frontend/components/help&support/helpPage.dart';
import 'package:arouse_ecommerce_frontend/pages/menu_screen.dart';
import 'package:flutter/material.dart';

class CVehicleAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CVehicleAppbar({super.key});

  @override
  State<CVehicleAppbar> createState() => _CVehicleAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _CVehicleAppbarState extends State<CVehicleAppbar> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWeb = screenWidth >= 1024;

    double imageSize = isWeb
        ? 40
        : isTablet
        ? 30
        : screenWidth * 0.075;
    double iconSize = isWeb
        ? 30
        : isTablet
        ? 20
        : screenWidth * 0.08;
    double fontSize = isWeb
        ? 20
        : isTablet
        ? 18
        : screenWidth * 0.035;
    double spacing = isWeb
        ? 10
        : isTablet
        ? 8
        : screenWidth * 0.01;

    return AppBar(
      elevation: 5.0,
      shadowColor: Colors.grey,

      // LEFT PADDING
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: IconButton(
          icon: Image.asset('assets/menu.png', width: 20, height: 20),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuScreen()),
            );
          },
        ),
      ),

      // TITLE with padding
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/image.png',
            height: imageSize,
            fit: BoxFit.contain,
          ),
          SizedBox(width: spacing),
          Text(
            'AROUSE',
            style: TextStyle(
              color: Color(0xFF004C90),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: "DMSans",
            ),
          ),
          SizedBox(width: spacing),
          Text(
            'AUTOMOTIVE',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: "DMSans",
            ),
          ),
        ],
      ),

      centerTitle: true,

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.search),
              color: Color(0xFF1A4C8E),
            ),
          ),
        ),
      ],
    );
  }
}
