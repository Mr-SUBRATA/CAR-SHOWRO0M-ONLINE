import 'package:flutter/material.dart';

class CScrolableButton extends StatelessWidget {
  final bool isSelected;
  final String label;
  final VoidCallback onTap;

  const CScrolableButton({
    super.key,
    required this.isSelected,
    required this.label,
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
                fontSize: 12,
                letterSpacing: 0.38,
                color: isSelected ? const Color(0xFF1A4C8E) : Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            // Underline
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A4C8E)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
