import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WhyChooseUsCard extends StatelessWidget {
  final String icon;
  final String label;
  final bool isLuxury;
  final String subtitle1;
  final String subtitle2;

  const WhyChooseUsCard({
    super.key,
    required this.icon,
    required this.label,
    this.isLuxury = false,
    required this.subtitle1,
    required this.subtitle2,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon),
        const SizedBox(height: 20),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
            fontSize: 20,
            color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          subtitle1,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle2,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: isLuxury ? Color(0XFFFFFFFF) : Color(0xFF050B20),
          ),
        ),
      ],
    );
  }
}
