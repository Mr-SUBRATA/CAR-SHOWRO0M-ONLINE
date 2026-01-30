import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_brochur.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_feature.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_specifications.dart';
import 'package:arouse_ecommerce_frontend_web/pages/vehicle_view_info.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class VariantSafety extends StatefulWidget {
  final Map<String, dynamic>? carData;
  final int selectedTab;

  const VariantSafety({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VariantSafety> createState() => _VariantSafetyState();
}

class _VariantSafetyState extends State<VariantSafety> {
  List<dynamic> safety = [];

  @override
  void initState() {
    super.initState();

    /// safety is stored as Array of Strings in Mongo
    /// Example:
    /// ["6 Airbags...", "ABS+EBD", ...]
    safety = widget.carData?['safety'] ?? [];
  }

  final List<String> tabs = [
    "Available Variants",
    "Features",
    "Safety",
    "Specifications",
    "Brochure",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ------------------ HEADER IMAGE ------------------
            Stack(
              children: [
                SizedBox(
                  height: AppSizes.screenHeight(context) * 0.28,
                  width: AppSizes.screenWidth(context),
                  child: Image.asset(
                    'assets/carbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: AppSizes.screenHeight(context) * 0.28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Find Your Perfect Car",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "DM Sans",
                        fontWeight: FontWeight.w700,
                        fontSize: AppSizes.isDesktop(context)
                            ? AppSizes.extraLargeFont(context)
                            : AppSizes.titleFont(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            /// ------------------ TABS ------------------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CScrolableButton(
                      label: tabs[index],
                      isSelected: widget.selectedTab == index,
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleViewInfo(
                                selectedTab: 0,
                                carId: widget.carData!['_id'],
                              ),
                            ),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantFeature(
                                carData: widget.carData,
                                selectedTab: 1,
                              ),
                            ),
                          );
                        } else if (index == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantSpecifications(
                                carData: widget.carData,
                                selectedTab: 3,
                              ),
                            ),
                          );
                        } else if (index == 4) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantBrochur(
                                carData: widget.carData,
                                selectedTab: 4,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            /// ------------------ SAFETY LIST ------------------
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.isDesktop(context) ? 120 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Safety Features",
                    style: TextStyle(
                      fontFamily: "DM Sans",
                      fontSize: AppSizes.isDesktop(context)
                          ? 26
                          : AppSizes.titleFont(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 14),

                  safety.isEmpty
                      ? Center(child: Text("No Safety Features Available"))
                      : Column(
                          children: List.generate(
                            safety.length,
                            (i) => safetyBullet(safety[i].toString(), context),
                          ),
                        ),
                ],
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

/// ------------------ BULLET POINT WIDGET ------------------
Widget safetyBullet(String text, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("•  ", style: TextStyle(fontSize: AppSizes.mediumFont(context))),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "DM Sans",
              fontSize: AppSizes.smallFont(context),
              fontWeight: FontWeight.w400,
              color: Color(0xFF3E3E3E),
            ),
          ),
        ),
      ],
    ),
  );
}
