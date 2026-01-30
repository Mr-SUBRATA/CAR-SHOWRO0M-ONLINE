import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_brochur.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_feature.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_safety.dart';
import 'package:arouse_ecommerce_frontend_web/pages/vehicle_view_info.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class VariantSpecifications extends StatefulWidget {
  final Map<String, dynamic>? carData;
  final int selectedTab;
  const VariantSpecifications({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VariantSpecifications> createState() => _VariantSpecificationsState();
}

class _VariantSpecificationsState extends State<VariantSpecifications> {
  List<Map<String, dynamic>>? specSections;

  List<dynamic> overview = [];
  List<dynamic> wheels = [];
  List<dynamic> performance = [];
  List<dynamic> technology = [];

  @override
  void initState() {
    super.initState();

    overview = widget.carData?['specifications']?['overview'] ?? [];
    wheels = widget.carData?['specifications']?['wheels'] ?? [];
    performance = widget.carData?['specifications']?['performance'] ?? [];
    technology = widget.carData?['specifications']?['technology'] ?? [];

    specSections = [
      {"title": "Wheels", "points": wheels},
      {"title": "Performance", "points": performance},
      {"title": "Technology", "points": technology},
    ];
  }

  final List<String> tabs = [
    "Available Variants",
    "Features",
    "Safety",
    "Specifications",
    "Brochure",
  ];

  int expandedIndex = -1;

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
            /// 🔹 Banner
            Stack(
              children: [
                SizedBox(
                  height: AppSizes.screenHeight(context) * 0.3,
                  width: AppSizes.screenWidth(context),
                  child: Image.asset(
                    'assets/carbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),

                // Overlay gradient optional (keeps text readable)
                Container(
                  height: AppSizes.screenHeight(context) * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Centered text for all screens
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Find Your Perfect Car',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.isDesktop(context)
                            ? AppSizes.extraLargeFont(context)
                            : AppSizes.titleFont(context),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            /// 🔹 Scrollable Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  tabs.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                          // Features
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantFeature(
                                carData: widget.carData,
                                selectedTab: 1,
                              ),
                            ),
                          );
                        } else if (index == 2) {
                          //Safety
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VariantSafety(
                                carData: widget.carData,
                                selectedTab: 2,
                              ),
                            ),
                          );
                        } else if (index == 3) {
                          // Specifications
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantSpecifications(
                                selectedTab: 3,
                                carData: widget.carData,
                              ),
                            ),
                          );
                        } else if (index == 4) {
                          // Brouchure
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantBrochur(
                                selectedTab: 4,
                                carData: widget.carData,
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
            Divider(),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.isDesktop(context) ? 130 : 20,
                vertical: 25,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  border: Border.all(color: Color(0xFFDADADA), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ---------------- OVERVIEW ----------------
                    Text(
                      "Overview",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: AppSizes.mediumFont(context),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F384C),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        overview.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "•  ",
                                style: TextStyle(fontSize: 15, height: 1.35),
                              ),
                              Expanded(
                                child: Text(
                                  overview[i],
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: AppSizes.smallFont(context),
                                    height: 1.35,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF3E3E3E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Divider(),

                    /// ---------------- DROPDOWN SECTIONS ----------------
                    Column(
                      children: List.generate(specSections!.length, (i) {
                        final section = specSections![i];
                        final List points = section["points"] ?? [];

                        return Column(
                          children: [
                            ExpansionTile(
                              shape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              collapsedShape: const RoundedRectangleBorder(
                                side: BorderSide.none,
                              ),
                              title: Text(
                                section["title"],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: AppSizes.mediumFont(context),
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF0D80D4),
                                  letterSpacing: 0.67,
                                ),
                              ),
                              tilePadding: EdgeInsets.zero,
                              trailing: Icon(
                                expandedIndex == i
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: const Color(0xFF0D80D4),
                                size: 26,
                              ),
                              initiallyExpanded: i == expandedIndex,
                              onExpansionChanged: (isOpen) {
                                setState(() => expandedIndex = isOpen ? i : -1);
                              },
                              childrenPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 12,
                              ),
                              children: [
                                if (points.isEmpty)
                                  const Text(
                                    "Details coming soon...",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  )
                                else
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      points.length,
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Text(
                                          "• ${points[p]}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.35,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (i < specSections!.length - 1)
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                                height: 22,
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
