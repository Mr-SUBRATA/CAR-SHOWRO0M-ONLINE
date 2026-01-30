import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class CTextfield extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboard;
  final bool readOnly;
  final int maxLines;
  final VoidCallback? onTap;

  const CTextfield({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboard = TextInputType.text,
    this.readOnly = false,
    this.maxLines = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.smallFont(context),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A4C8E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          readOnly: readOnly,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFC6C6C6), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
