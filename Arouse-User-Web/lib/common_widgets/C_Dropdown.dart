import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class CDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const CDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: AppSizes.smallFont(context),
            color: Color(0xFF1A4C8E),
          ),
        ),
        const SizedBox(height: 9),

        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC6C6C6), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF1A4C8E),
                width: 1.5,
              ),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: const Text(
            "Select",
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 15, fontFamily: "Inter"),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
