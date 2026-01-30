import 'package:flutter/material.dart';

class CAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;

  const CAppbar({super.key, required this.screenName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back_ios_new_outlined,
          size: MediaQuery.of(context).size.width * 0.06,
          color: const Color.fromRGBO(26, 76, 142, 1),
        ),
      ),
      centerTitle: true,
      title: Text(
        screenName,
        style: TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
          fontSize: MediaQuery.of(context).size.width * 0.045,
          color: const Color.fromRGBO(26, 76, 142, 1),
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 5,
      shadowColor: Colors.grey,
    );
  }

  // 👇 Important: AppBar height (same as default AppBar)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
