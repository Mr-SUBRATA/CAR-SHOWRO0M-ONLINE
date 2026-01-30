import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_vehicle_AppBar.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_brochure.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_safety.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_specification.dart';
import 'package:arouse_ecommerce_frontend/pages/vehicle_info_page.dart';
import 'package:flutter/material.dart';

class VehicleInfoFeature extends StatefulWidget {
  final int selectedTab;
  final Map carData;
  const VehicleInfoFeature({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VehicleInfoFeature> createState() => _VehicleInfoFeatureState();
}

class _VehicleInfoFeatureState extends State<VehicleInfoFeature> {
  List<dynamic> features = [];

  @override
  void initState() {
    super.initState();

    features = widget.carData['features'];

    print(features);
  }

  final List<String> tabs = [
    "Available varients",
    "Features",
    "Safety",
    "Specification",
    "Brochure",
  ];

  // Convert backend binary → Uint8List
  Uint8List? getImageBytes(dynamic imageData) {
    try {
      if (imageData != null &&
          imageData["data"] != null &&
          imageData["data"]["data"] != null) {
        return Uint8List.fromList(List<int>.from(imageData["data"]["data"]));
      }
    } catch (e) {
      print("Image parse error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CVehicleAppbar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 55,
                  width: screenWidth,
                  child: Image.asset(
                    'assets/carbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 18,
                  left: screenWidth * 0.3,
                  child: Text(
                    'Find Your Perfect Car',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.carData['name'],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1.94,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Change Model',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D80D4),
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: CScrolableButton(
                        label: tabs[index],
                        isSelected: widget.selectedTab == index,
                        onTap: () {
                          if (index == 0) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VehicleInfoPage(
                                  selectedTab: 0,
                                  carId: widget.carData['_id'],
                                ),
                              ),
                            );
                          } else if (index == 1) {
                            // Features
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VehicleInfoFeature(
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
                                builder: (context) => VehicleInfoSafety(
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
                                builder: (_) => VehicleInfoSpecification(
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
                                builder: (_) => VehicleInfoBrochure(
                                  selectedTab: 4,
                                  carData: widget.carData,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 22),
            if (features.isEmpty) Center(child: Text("Features Not Available")),

            for (var f in features)
              if (f['image'] != null)
                buildFeature(
                  title: f['title'] ?? "",
                  subtitle: f['caption'] ?? "",
                  image: getImageBytes(f['image']),
                ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Widget buildFeature({
  required String title,
  required String subtitle,
  required Uint8List? image,
}) {
  return Column(
    children: [
      Image.memory(image!, fit: BoxFit.cover),
      SizedBox(height: 12),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: 0.67,
              color: Color(0xFF1F384C),
            ),
          ),
        ),
      ),
      SizedBox(height: 6),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Color(0xFF3E3E3E),
            ),
          ),
        ),
      ),
    ],
  );
}
