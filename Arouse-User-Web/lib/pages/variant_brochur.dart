import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_download_pdf.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_feature.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_safety.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_specifications.dart';
import 'package:arouse_ecommerce_frontend_web/pages/vehicle_view_info.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class VariantBrochur extends StatefulWidget {
  final Map<String, dynamic>? carData;
  final int selectedTab;
  const VariantBrochur({
    super.key,
    required this.carData,
    required this.selectedTab,
  });

  @override
  State<VariantBrochur> createState() => _VariantBrochurState();
}

class _VariantBrochurState extends State<VariantBrochur> {
  int selectedTab = 4;
  final List<String> tabs = [
    "Available Variants",
    "Features",
    "Safety",
    "Specifications",
    "Brochure",
  ];

  final List<Map<String, dynamic>> documents = [
    {
      "title": "I10 Nios 2025 (January Edition)",
      "subtitle": "Vehicle Brochure",
      "fileUrl": "https://example.com/doc.pdf",
    },
    {
      "title": "Insurance Plan 2025",
      "subtitle": "Insurance Document",
      "fileUrl": "https://example.com/doc2.pdf",
    },
    {
      "title": "Invoice May 2025",
      "subtitle": "Purchase Invoice",
      "fileUrl": "https://example.com/doc3.pdf",
    },
    {
      "title": "Invoice May 2025",
      "subtitle": "Purchase Invoice",
      "fileUrl": "https://example.com/doc3.pdf",
    },
    {
      "title": "Invoice May 2025",
      "subtitle": "Purchase Invoice",
      "fileUrl": "https://example.com/doc3.pdf",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: Column(
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
                    colors: [Colors.black.withOpacity(0.4), Colors.transparent],
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
          SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return Padding(
                  padding: AppSizes.isDesktop(context)
                      ? const EdgeInsets.symmetric(
                          horizontal: 130,
                          vertical: 10,
                        )
                      : const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16,
                        ),
                  child: CDownloadPdf(
                    title: doc['title'],
                    subtitle: doc['subtitle'],
                    // fileUrl: doc['fileUrl'], // pass URL to download
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
