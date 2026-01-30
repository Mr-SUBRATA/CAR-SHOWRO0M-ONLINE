import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_vehicle_AppBar.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_brochure.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_feature.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_safety.dart';
import 'package:arouse_ecommerce_frontend/pages/vehicle_info_page.dart';
import 'package:flutter/material.dart';

class VehicleInfoSpecification extends StatefulWidget {
  final int selectedTab;
  final Map carData;

  const VehicleInfoSpecification({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VehicleInfoSpecification> createState() =>
      _VehicleInfoSpecificationState();
}

class _VehicleInfoSpecificationState extends State<VehicleInfoSpecification> {
  List<dynamic> overview = [];
  List<dynamic> wheels = [];
  List<dynamic> performance = [];
  List<dynamic> technology = [];

  @override
  void initState() {
    super.initState();
    overview = widget.carData['specifications']['overview'];
    wheels = widget.carData['specifications']['wheels'];
    performance = widget.carData['specifications']['performance'];
    technology = widget.carData['specifications']['technology'];

    print(widget.carData);
  }

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
                'Hyundai i10 NIOS',
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
                            // VehicleInfo
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Overview',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  letterSpacing: 0.67,
                  color: Color(0xFF1F384C),
                ),
              ),
            ),
            SizedBox(height: 10),
            for (var v in overview) bulletPoint(v),

            SizedBox(height: 37),
            Divider(),
            buildBottomDropdown(label: "Overview", items: overview),
            Divider(),
            buildBottomDropdown(label: "Wheels", items: wheels),
            Divider(),
            buildBottomDropdown(label: "Performance", items: performance),
            Divider(),
            buildBottomDropdown(label: "Technology", items: technology),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

Widget bulletPoint(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("•  ", style: TextStyle(fontSize: 16, height: 1.4)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: "DM Sans",
              color: Color(0xFF3E3E3E),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildBottomDropdown({
  required String label,
  required List<dynamic> items,
}) {
  bool isOpen = false;

  return StatefulBuilder(
    builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.only(left: 32, right: 22, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color: Color(0xFF0D80D4),
                    letterSpacing: 0.67,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      isOpen = !isOpen;
                    });
                  },
                  icon: Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 26,
                    color: Color(0xFF0D80D4),
                  ),
                ),
              ],
            ),

            // Dropdown content
            if (isOpen)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "• $e",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "DM Sans",
                          color: Color(0xFF3E3E3E),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      );
    },
  );
}
