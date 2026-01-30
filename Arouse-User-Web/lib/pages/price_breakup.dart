import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class PriceBreakupPage extends StatelessWidget {
  final String carName;
  final String variantName;
  final double exShowroomPrice;
  final String city;

  const PriceBreakupPage({
    super.key,
    required this.carName,
    required this.variantName,
    required this.exShowroomPrice,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    // Check if exShowroomPrice is valid
    if (exShowroomPrice <= 0) {
      return Scaffold(
        appBar: const CAppbar(),
        body: const Center(
          child: Text("Price details not available for this variant."),
        ),
      );
    }

    // --- ESTIMATION LOGIC ---
    // CarWale-style logic (approximate for demo)
    // RTO: ~10% for petrol/diesel, might vary. Using 10% as base.
    final double rtoCharges = exShowroomPrice * 0.10;
    
    // Insurance: ~4% comprehensive
    final double insuranceCharges = exShowroomPrice * 0.04;
    
    // Other charges (Fastag, handling, etc.): ~1% or fixed
    final double otherCharges = 2000.0; // Fixed small amount for demo

    final double onRoadPrice = exShowroomPrice + rtoCharges + insuranceCharges + otherCharges;
    // -------------------------

    return Scaffold(
      appBar: const CAppbar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.isDesktop(context) ? 100 : 20,
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb / Back
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 20, color: Color(0xFF1A4C8E)),
                    const SizedBox(width: 8),
                    Text(
                      'Back to $carName',
                      style: const TextStyle(
                        color: Color(0xFF1A4C8E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Title
              Text(
                '$carName $variantName Price in $city',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: AppSizes.titleFont(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The on-road price of $carName $variantName in $city is ₹ ${onRoadPrice.toStringAsFixed(0)}.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 40),

              // Price Table
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildRow(context, "Ex-Showroom Price", exShowroomPrice, isHeader: false),
                    const Divider(height: 1),
                    _buildRow(context, "RTO", rtoCharges),
                    const Divider(height: 1),
                    _buildRow(context, "Insurance", insuranceCharges),
                    const Divider(height: 1),
                    _buildRow(context, "Others", otherCharges),
                    const Divider(height: 1, thickness: 2),
                    _buildRow(
                      context,
                      "On-Road Price in $city",
                      onRoadPrice,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              // EMI Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1A4C8E)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "EMI starts at ₹ ${(onRoadPrice * 0.015).toStringAsFixed(0)} / month",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF1A4C8E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.black : Colors.grey.shade800,
              fontFamily: 'DM Sans',
            ),
          ),
          Text(
            "₹ ${amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 16,
              color: isTotal ? Colors.black : Colors.grey.shade800,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}
