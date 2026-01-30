import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/C_download_pdf.dart';
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
      appBar: CAppbar(screenName: "My Documents"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,

                      child: GestureDetector(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tabs[index],
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                letterSpacing: 0.38,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
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
                    padding: const EdgeInsets.only(bottom: 24.0),
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
