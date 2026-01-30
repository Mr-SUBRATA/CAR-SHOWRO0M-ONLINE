import 'package:arouse_ecommerce_frontend/api/Vehicles/vehicle_info_api.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class EmiCalculator extends StatefulWidget {
  final Map<String, dynamic>? emiFiveYears;
  const EmiCalculator({super.key, required this.emiFiveYears});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
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
      ).showSnackBar(SnackBar(content: Text('All fields are required!')));
    }
    int tenureMonths = getMonths(selectedTenure!);
    double interestValue = getInterest(selectedInterest!);

    var data = await VehicleInfoApi.calculateEMI(
      loanAmount.toString(),
      interestValue.toString(),
      tenureMonths.toString(),
    );

    setState(() {
      calculatedEMI = data;
    });
  }

  @override
  void initState() {
    super.initState();

    // Listen to both textfields for dynamic update
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
    return Scaffold(
      appBar: CAppbar(screenName: "EMI Calculator"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),

              Text(
                "Choose your EMI Options",
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Text(
                  'Standard EMI',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Color(0xFF6D6D6D),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(width: 10, height: 2, color: Color(0xFFBDBDBD)),
                    Container(
                      width: 129,
                      height: 2.4,
                      color: Color(0xFF004C90),
                    ),

                    Expanded(
                      child: Container(height: 2, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Rs. ${(widget.emiFiveYears!['emi'] ?? 0).toStringAsFixed(0)} ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  Text(
                    'for 5 Years',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      showEmiBreakupDialog(context, widget.emiFiveYears);
                    },
                    child: Text(
                      'View EMI breakup',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                        color: Color(0xFF0D80D4),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Color(0xFF0D80D4),
                  ),
                ],
              ),

              SizedBox(height: 41),
              buildTextField(
                label: "Enter Estimated Price of the Car",
                controller: price,
              ),
              const SizedBox(height: 24),

              buildTextField(
                label: "Enter Down Payement",
                controller: downPayment,
              ),
              const SizedBox(height: 9),

              Text(
                'Your loan amount will be Rs $loanAmount',
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 24),

              buildDropdown(
                label: "Select Tenure",
                value: selectedTenure,
                items: tenure,
                onChanged: (v) => setState(() => selectedTenure = v),
              ),
              const SizedBox(height: 24),

              buildDropdown(
                label: "Select Interest Rate",
                value: selectedInterest,
                items: interest,
                onChanged: (v) => setState(() => selectedInterest = v),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    calculateEMI();
                    if (calculatedEMI != null) {
                      showCalculatedEMIDialog(context, calculatedEMI);
                    }
                    price.clear();
                    downPayment.clear();
                    selectedInterest = null;
                    selectedTenure = null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004C90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    'Calculate EMI',
                    style: const TextStyle(
                      fontFamily: "DM Sans",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

void showEmiBreakupDialog(BuildContext context, Map<String, dynamic>? emiData) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "EMI Breakup",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),

                SizedBox(height: 24),
                Text(
                  "Standard EMI",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF6D6D6D),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 104,
                        height: 2.4,
                        color: Color(0xFF004C90),
                      ),

                      Expanded(
                        child: Container(height: 2, color: Color(0xFFBDBDBD)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  "Rs. ${(emiData!['emi'] ?? 0).toStringAsFixed(0)} EMI For 5 Years",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 11,
                      width: 11,
                      decoration: BoxDecoration(
                        color: Color(0xFF223577),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Principal Loan Amount",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Rs. ${emiData['loanAmount']}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 11,
                      width: 11,
                      decoration: BoxDecoration(
                        color: Color(0xFF2799E3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Total Interest Amount",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(emiData['totalInterest'] ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount Payable",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(emiData['totalPayable'] ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF004C90),
                        width: 1.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Get EMI Offers",
                      style: TextStyle(
                        fontFamily: "DM Sans",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF004C90),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  String? hintText,
  int maxLines = 1,
}) {
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

      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'Inter',
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC6C6C6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1A4C8E), width: 1.5),
          ),
        ),
      ),
    ],
  );
}

Widget buildDropdown({
  required String label,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
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
            borderSide: const BorderSide(color: Color(0xFF1A4C8E), width: 1.5),
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
    ],
  );
}

void showCalculatedEMIDialog(
  BuildContext context,
  Map<String, dynamic>? emiData,
) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Calculated EMI",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 21,
                        color: Color(0xFF4A4A4A),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),

                SizedBox(height: 24),
                Text(
                  "Standard EMI",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF6D6D6D),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 104,
                        height: 2.4,
                        color: Color(0xFF004C90),
                      ),

                      Expanded(
                        child: Container(height: 2, color: Color(0xFFBDBDBD)),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),

                Text(
                  "Rs. ${(emiData!['emi'] ?? 0).toStringAsFixed(0)}",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 19,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 11,
                      width: 11,
                      decoration: BoxDecoration(
                        color: Color(0xFF223577),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Principal Loan Amount",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "Rs. ${emiData['loanAmount']}",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 11,
                      width: 11,
                      decoration: BoxDecoration(
                        color: Color(0xFF2799E3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Total Interest Amount",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(emiData['totalInterest'] ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount Payable",
                      style: TextStyle(
                        fontFamily: 'Sofia Pro',
                        fontWeight: FontWeight.w400,
                        fontSize: 11,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(emiData['totalPayable'] ?? 0).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 17),
              ],
            ),
          ),
        ),
      );
    },
  );
}
