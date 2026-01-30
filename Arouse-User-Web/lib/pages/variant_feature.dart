import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_brochur.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_safety.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_specifications.dart';
import 'package:arouse_ecommerce_frontend_web/pages/vehicle_view_info.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class VariantFeature extends StatefulWidget {
  final Map<String, dynamic>? carData;
  final int selectedTab;

  const VariantFeature({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VariantFeature> createState() => _VariantFeatureState();
}

class _VariantFeatureState extends State<VariantFeature> {
  late ScrollController _scrollController;
  List<dynamic> features = [];

  Uint8List? getImageBytes(Map<String, dynamic> item) {
    try {
      if (item["image"] != null &&
          item["image"]["data"] != null &&
          item["image"]["data"]["data"] != null) {
        List<int> bytes = List<int>.from(item["image"]["data"]["data"]);
        return Uint8List.fromList(bytes);
      }
    } catch (e) {
      debugPrint("Failed to parse feature image: $e");
    }
    return null;
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
    features = widget.carData!['features'];
  }

  void scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 350,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 350,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            SizedBox(height: AppSizes.screenHeight(context) * 0.02),
            features.isEmpty
                ? Center(child: Text('No Feature Available'))
                : Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController, // 🔥 added
                        child: AppSizes.isDesktop(context)
                            ? Row(
                                children: List.generate(features.length, (
                                  index,
                                ) {
                                  final item = features[index];
                                  final bytes = getImageBytes(item);

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          AppSizes.screenWidth(context) * 0.02,
                                    ),
                                    child: featureCard(
                                      context,
                                      image: bytes,
                                      title: item["title"]!,
                                      subtitle: item["caption"]!,
                                    ),
                                  );
                                }),
                              )
                            : Column(
                                spacing: 15,
                                children: List.generate(features.length, (
                                  index,
                                ) {
                                  final item = features[index];
                                  final bytes = getImageBytes(item);

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right:
                                          AppSizes.screenWidth(context) * 0.02,
                                    ),
                                    child: featureCard(
                                      context,
                                      image: bytes,
                                      title: item["title"]!,
                                      subtitle: item["subtitle"]!,
                                    ),
                                  );
                                }),
                              ),
                      ),

                      if (AppSizes.isDesktop(context)) ...[
                        Positioned(
                          top: AppSizes.screenHeight(context) * 0.20,
                          left: 0,
                          child: GestureDetector(
                            onTap: scrollLeft,
                            child: Container(
                              height: 40,
                              width: 26,
                              color: Color(0xFF1A4C8E),
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: AppSizes.screenHeight(context) * 0.20,
                          right: 0,
                          child: GestureDetector(
                            onTap: scrollRight,
                            child: Container(
                              height: 40,
                              width: 26,
                              color: Color(0xFF1A4C8E),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

Widget featureCard(
  BuildContext context, {
  Uint8List? image,
  required String title,
  required String subtitle,
}) {
  return Column(
    children: [
      SizedBox(
        height: AppSizes.isDesktop(context)
            ? AppSizes.screenHeight(context) * 0.55
            : AppSizes.screenHeight(context) * 0.30,
        width: AppSizes.isDesktop(context)
            ? AppSizes.screenWidth(context) * 0.45
            : AppSizes.screenWidth(context),
        child: image == null
            ? Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported),
              )
            : Image.memory(image, fit: BoxFit.contain),
      ),

      SizedBox(height: AppSizes.screenHeight(context) * 0.02),
      Center(
        child: Text(
          textAlign: TextAlign.center,
          title,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F384C),
            fontSize: AppSizes.mediumFont(context),
          ),
        ),
      ),
      SizedBox(height: 10),
      Center(
        child: Text(
          textAlign: TextAlign.center,
          subtitle,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            color: Color(0xFF3E3E3E),
            fontSize: AppSizes.smallFont(context),
          ),
        ),
      ),
    ],
  );
}
