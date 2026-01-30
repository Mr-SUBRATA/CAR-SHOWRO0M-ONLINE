import 'package:arouse_ecommerce_frontend/common_widgets/C_download_pdf.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_vehicle_AppBar.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_feature.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_safety.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_specification.dart';
import 'package:arouse_ecommerce_frontend/pages/vehicle_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VehicleInfoBrochure extends StatefulWidget {
  final int selectedTab;
  final Map carData;
  const VehicleInfoBrochure({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VehicleInfoBrochure> createState() => _VehicleInfoBrochureState();
}

class _VehicleInfoBrochureState extends State<VehicleInfoBrochure> {
  final List<String> tabs = [
    "Available varients",
    "Features",
    "Safety",
    "Specification",
    "Brochure",
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;
    print('isTab: $isTablet');

    // Dynamic Sizing
    double imageSize = isWebOrDesktop
        ? 40
        : isTablet
        ? 30
        : screenWidth * 0.075;
    double iconSize = isWebOrDesktop
        ? 30
        : isTablet
        ? 20
        : screenWidth * 0.08;
    double fontSize = isWebOrDesktop
        ? 20
        : isTablet
        ? 18
        : screenWidth * 0.03 + 4;
    double spacing = isWebOrDesktop
        ? 10
        : isTablet
        ? 8
        : screenWidth * 0.01;
    return Scaffold(
      appBar: CVehicleAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
              Text(
                'Hyundai i10 NIOS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1.94,
                ),
              ),
              Text(
                'Change Model',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D80D4),
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
              SizedBox(height: 24),
              CDownloadPdf(
                title: "I10 Nios 2025 (January Edition)",
                subtitle: "Vehicle Brochure",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
