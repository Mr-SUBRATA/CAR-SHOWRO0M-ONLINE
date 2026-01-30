import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/components/EMI_calculator/emiSemiCircleChart.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class EmiDialog extends StatefulWidget {
  const EmiDialog({super.key});

  @override
  State<EmiDialog> createState() => _EmiDialogState();
}

class _EmiDialogState extends State<EmiDialog> {
  String? selectedTenure;
  String? selectedInterest;

  TextEditingController price = TextEditingController();
  TextEditingController downPayment = TextEditingController();

  List<String> tenure = ["5 Years", "10 Years", "15 Years", "20 Years"];
  List<String> interest = ["5%", "9%", "12%", "25%"];

  int loanAmount = 0;

  void calculateLoanAmount() {
    int p = int.tryParse(price.text) ?? 0;
    int dPayment = int.tryParse(downPayment.text) ?? 0;

    setState(() {
      loanAmount = p - dPayment;
      if (loanAmount < 0) loanAmount = 0;
    });
  }

  double getInterest(String rate) {
    return double.parse(rate.replaceAll("%", ""));
  }

  int getMonths(String tenure) {
    int years = int.parse(tenure.split(" ")[0]);
    return years * 12;
  }

  Map<String, dynamic>? calculatedEMI;

  void calculateEMI() async {
    if (selectedTenure == null || selectedInterest == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields are required!")));
      return;
    }

    int tenureMonths = getMonths(selectedTenure!);
    double interestValue = getInterest(selectedInterest!);

    var data = await VehiclesApi.calculateEMI(
      loanAmount.toString(),
      interestValue.toString(),
      tenureMonths.toString(),
    );

    setState(() => calculatedEMI = data);
    //print(calculatedEMI);
  }

  @override
  void initState() {
    super.initState();
    price.addListener(calculateLoanAmount);
    downPayment.addListener(calculateLoanAmount);
  }

  @override
  void dispose() {
    price.dispose();
    downPayment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Choose your EMI Options",
                    style: TextStyle(
                      fontSize: AppSizes.mediumFont(context),
                      fontWeight: FontWeight.w700,
                      fontFamily: "DM Sans",
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              SizedBox(height: 20),

              isMobile
                  ? Column(
                      children: [
                        _leftFormSection(),
                        SizedBox(height: 20),
                        _rightEmiSection(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: _leftFormSection()),
                        VerticalDivider(width: 30),
                        Expanded(child: _rightEmiSection()),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // LEFT SECTION
  Widget _leftFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Enter Estimated Price of the Car"),
        SizedBox(height: 9),
        _textField("Rs. 18,79,000", price),
        SizedBox(height: 16),

        _label("Enter Down Payment"),
        SizedBox(height: 9),
        _textField("Rs. 5,00,000", downPayment),
        SizedBox(height: 6),
        Text(
          "Your loan amount will be ₹ $loanAmount",
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        SizedBox(height: 16),

        _label("Select Tenure"),
        SizedBox(height: 9),
        _dropdown(
          items: tenure,
          selectedValue: selectedTenure,
          onChanged: (v) => setState(() => selectedTenure = v),
        ),
        SizedBox(height: 16),

        _label("Select Interest Rate"),
        SizedBox(height: 9),
        _dropdown(
          items: interest,
          selectedValue: selectedInterest,
          onChanged: (v) => setState(() => selectedInterest = v),
        ),
        SizedBox(height: 20),

        /// Calculate Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF004C90),
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: calculateEMI,
            child: Text(
              "Calculate EMI",
              style: TextStyle(
                fontSize: AppSizes.smallFont(context),
                fontFamily: "DM Sans",
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // RIGHT SECTION
  Widget _rightEmiSection() {
    // If EMI not calculated yet → show a placeholder message
    if (calculatedEMI == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Please calculate your EMI",
            style: TextStyle(
              fontSize: AppSizes.mediumFont(context),
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 30),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            width: 400,
            height: 170,
            decoration: BoxDecoration(color: Color(0xFFF8F9FB)),
            child: Center(
              child: Text("No Data", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      );
    }

    // If EMI values are available → show full result UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Rs. ${(calculatedEMI!['emi'] ?? 0).toStringAsFixed(0)} Monthly EMI',
          style: TextStyle(
            fontSize: AppSizes.mediumFont(context),
            fontFamily: "Poppins",
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 20),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          width: 400,
          height: 170,
          decoration: BoxDecoration(color: Color(0xFFF8F9FB)),
          child: CustomPaint(
            painter: EMISemiCircleChart(
              principal: double.parse(calculatedEMI!['loanAmount']),
              totalInterest: calculatedEMI!['totalInterest'],
            ),
          ),
        ),

        SizedBox(height: 20),
        Divider(),

        _emiRow("Principal Loan Amount", "₹ ${calculatedEMI!['loanAmount']}"),
        _emiRow(
          "Total Interest Amount",
          "₹ ${(calculatedEMI!['totalInterest'] ?? 0).toStringAsFixed(0)}",
        ),
        Divider(),
        _emiRow(
          "Total Amount Payable",
          "₹ ${(calculatedEMI!['totalPayable'] ?? 0).toStringAsFixed(0)}",
        ),

        SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Color(0xFF004C90), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: Text(
              "Get EMI Offers",
              style: TextStyle(
                color: Color(0xFF004C90),
                fontFamily: "DM Sans",
                fontSize: AppSizes.smallFont(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: AppSizes.smallFont(context),
      fontWeight: FontWeight.w600,
      fontFamily: "Inter",
      color: Color(0xFF1A4C8E),
    ),
  );

  Widget _textField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _dropdown({
    required List<String> items,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFC6C6C6), width: 1),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        underline: SizedBox(),
        items: items
            .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _emiRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: "Sofia Pro",
              fontSize: AppSizes.smallFont(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: AppSizes.bodyFont(context),
            ),
          ),
        ],
      ),
    );
  }
}
