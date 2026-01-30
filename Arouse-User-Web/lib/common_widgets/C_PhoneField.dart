import 'package:flutter/material.dart';

Widget CPhoneField({
  required String label,
  required String selectedCode,
  required ValueChanged<String> onCodeChanged,
  required TextEditingController controller,
}) {
  const List<String> countryCodes = ["+91", "+1", "+44", "+971", "+61"];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color(0xFF1A4C8E),
        ),
      ),
      const SizedBox(height: 9),

      Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC6C6C6)),
        ),
        child: Row(
          children: [
            // COUNTRY CODE DROPDOWN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButton<String>(
                value: selectedCode,
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: countryCodes.map((code) {
                  return DropdownMenuItem<String>(
                    value: code,
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontFamily: "Inter",
                        fontSize: 14,
                        color: Color(0xFF1A4C8E),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onCodeChanged(value);
                  }
                },
              ),
            ),

            Container(height: 40, width: 1, color: const Color(0xFFC6C6C6)),

            // PHONE INPUT
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Enter phone number",
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),
    ],
  );
}
