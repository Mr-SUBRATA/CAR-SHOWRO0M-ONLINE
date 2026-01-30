import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CDownloadPdf extends StatelessWidget {
  final String title;
  final String subtitle;
  const CDownloadPdf({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Color(0xFFDADADA))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/pdf.svg'),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: Color(0xFF1F384C),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Download",
                      style: TextStyle(
                        fontFamily: "DM Sans",
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: Color(0xFF0D80D4),
                      ),
                    ),
                    SizedBox(width: 8),

                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: Color(0xFF0D80D4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
