import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_download_pdf.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class MyDocuments extends StatefulWidget {
  const MyDocuments({super.key});

  @override
  State<MyDocuments> createState() => _MyDocumentsState();
}

class _MyDocumentsState extends State<MyDocuments> {
  int selectedTab = 0;

  final List<String> tabs = [
    "Payment Recipients",
    "Insurance",
    "Invoice",
    "TDS Certificate",
    "Loyalty Card Certificate",
    "Others",
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
      endDrawer: CDrawer(isLoggedIn: true),
      appBar: CAppbar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSizes.screenWidth(context) < 480
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : AppSizes.screenWidth(context) < 900
                  ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  : const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
              width: AppSizes.screenWidth(context),
              decoration: BoxDecoration(color: Color(0xFF1A4C8E)),
              child: Text(
                'My Documents',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.titleFont(context),
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                      isSelected: selectedTab == index,
                      onTap: () {
                        setState(() {
                          selectedTab = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 6),
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
                            horizontal: 100,
                            vertical: 10,
                          )
                        : const EdgeInsets.only(bottom: 24.0),
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
      ),
    );
  }
}
