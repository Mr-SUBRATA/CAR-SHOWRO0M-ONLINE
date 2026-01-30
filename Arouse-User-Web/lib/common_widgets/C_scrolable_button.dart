import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class CScrolableButton extends StatelessWidget {
  final bool isSelected;
  final String label;
  final bool isLuxury;
  final VoidCallback onTap;

  const CScrolableButton({
    super.key,
    required this.isSelected,
    required this.label,
    this.isLuxury = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: AppSizes.smallFont(context),
                letterSpacing: 0.38,
                color: isSelected
                    ? isLuxury
                          ? Color(0XFFFFFFFF)
                          : const Color(0xFF1A4C8E)
                    : isLuxury
                    ? Color(0XFFFFFFFF)
                    : Color(0xFF000000),
              ),
            ),

            const SizedBox(height: 12),

            // Underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 3,
              width: isSelected ? 40 : 0,
              decoration: BoxDecoration(
                color: isLuxury ? Color(0XFFFFFFFF) : const Color(0xFF1A4C8E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget FeatureCard() {
  return Column(children: [Image.asset('assets/')]);
}
