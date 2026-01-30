import 'package:arouse_ecommerce_frontend/api/Home/book_test_drive_api.dart';
import 'package:arouse_ecommerce_frontend/api/Vehicles/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class BookTestDrive extends StatefulWidget {
  const BookTestDrive({super.key});

  @override
  State<BookTestDrive> createState() => _BookTestDriveState();
}

class _BookTestDriveState extends State<BookTestDrive> {
  String? selectedState;
  String? selectedCity;
  String? selectedLicense;

  List<String> states = ["Uttarakhand", "Uttar Pradesh", "Delhi", "Haryana"];
  List<String> cities = ["Roorkee", "Haridwar", "Dehradun", "Meerut"];
  // List<String> brands = ["Hyundai", "Tata", "Mahindra", "Kia"];
  // List<String> models = ["i20", "Nexon", "Scorpio", "Seltos"];
  List<String> drivingLicense = ["Yes", "No"];

  List<String> timeSlots = [
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
  ];
  String? selectedTimeSlot;

  String? selectedPhoneCode = "+91";
  String? selectedAltPhoneCode = "+91";
  TextEditingController phoneController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  DateTime? selectedDate;

  List<Map<String, dynamic>>? cars;
  List<Map<String, dynamic>> allCars = []; // full API data
  List<String> brands = [];
  List<String> models = [];

  String? selectedBrand;
  String? selectedModel;

  @override
  void initState() {
    super.initState();
    fetchCarsData();
  }

  Future<void> fetchCarsData() async {
    allCars = await VehiclesApi.getAllCars(); // full API data
    setState(() {
      cars = allCars;
      brands = allCars.map((v) => v['brand'] as String).toSet().toList();
      models = allCars.map((v) => v['name'] as String).toSet().toList();
    });
  }

  // When brand changes
  void onBrandSelected(String? brand) {
    setState(() {
      selectedBrand = brand;
      selectedModel = null; // reset model
      // Filter models for selected brand
      models = allCars
          .where((v) => v['brand'] == brand)
          .map((v) => v['name'] as String)
          .toSet()
          .toList();
    });
  }

  // When model changes
  void onModelSelected(String? model) {
    setState(() {
      selectedModel = model;
      // Filter brands that have this model
      brands = allCars
          .where((v) => v['name'] == model)
          .map((v) => v['brand'] as String)
          .toSet()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(screenName: "Book a Test Drive"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book a Test Drive',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Please enter your details too schedule a test drive',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: Color(0xFF515151),
                ),
              ),
              SizedBox(height: 27),
              buildDropdown(
                label: "State",
                value: selectedState,
                items: states,
                onChanged: (v) => setState(() => selectedState = v),
              ),
              SizedBox(height: 21),

              buildDropdown(
                label: "City",
                value: selectedCity,
                items: cities,
                onChanged: (v) => setState(() => selectedCity = v),
              ),
              SizedBox(height: 21),

              buildTextField(
                label: "Address",
                hintText: "Enter full address",
                maxLines: 4,
                controller: addressController,
              ),
              SizedBox(height: 21),

              buildDropdown(
                label: "Brand",
                value: selectedBrand,
                items: brands,
                onChanged: (v) => setState(() => selectedBrand = v),
              ),
              SizedBox(height: 21),

              buildDropdown(
                label: "Model",
                value: selectedModel,
                items: models,
                onChanged: (v) => setState(() => selectedModel = v),
              ),
              SizedBox(height: 21),

              datePickerField(
                label: "Test Drive Date Selection",
                controller: dateController,
                context: context,
              ),

              SizedBox(height: 21),

              buildDropdown(
                label: "Select Time Slot",
                value: selectedTimeSlot,
                items: timeSlots,
                onChanged: (v) => setState(() => selectedTimeSlot = v),
              ),

              SizedBox(height: 21),

              buildTextField(
                label: "Name",
                hintText: "Enter your Full Name",
                maxLines: 1,
                controller: nameController,
              ),
              SizedBox(height: 21),

              phoneField(
                label: "Phone Number*",
                selectedCode: selectedPhoneCode,
                controller: phoneController,
                onChanged: (v) => setState(() => selectedPhoneCode = v),
              ),

              SizedBox(height: 21),

              phoneField(
                label: "Alternate Phone Number",
                selectedCode: selectedAltPhoneCode,
                controller: altPhoneController,
                onChanged: (v) => setState(() => selectedAltPhoneCode = v),
              ),

              SizedBox(height: 21),

              buildTextField(
                label: "Email Address",
                hintText: "Enter your Email Address",
                maxLines: 1,
                controller: emailController,
              ),
              SizedBox(height: 21),

              buildDropdown(
                label: "Do you have Driving License?",
                value: selectedLicense,
                items: drivingLicense,
                onChanged: (v) => setState(() => selectedLicense = v),
              ),
              SizedBox(height: 33),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await BookTestDriveApi.bookTestDrive(
                      context,
                      state: selectedState!,
                      city: selectedCity!,
                      address: addressController.text.trim(),
                      brand: selectedBrand!,
                      model: selectedModel!,
                      date: dateController.text.trim(),
                      time: selectedTimeSlot!,
                      name: nameController.text.trim(),
                      phone: phoneController.text,
                      altPhone: altPhoneController.text,
                      email: emailController.text.trim(),
                      hasDriving: selectedLicense == "Yes",
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004C90),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Text(
                    'Book Now',
                    style: const TextStyle(
                      fontFamily: "DM Sans",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildTextField({
  required String label,
  String? hintText,
  int maxLines = 1,
  TextEditingController? controller,
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

      const SizedBox(height: 16),
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
      const SizedBox(height: 16),
    ],
  );
}

Widget phoneField({
  required String label,
  required String? selectedCode,
  required Function(String?) onChanged,
  required TextEditingController controller,
}) {
  List<String> countryCodes = ["+91", "+1", "+44", "+971", "+61"];

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: selectedCode,
                hint: const Text("+91"),
                underline: const SizedBox(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: countryCodes.map((code) {
                  return DropdownMenuItem(
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
                onChanged: onChanged,
              ),
            ),

            Container(height: 40, width: 1, color: const Color(0xFFC6C6C6)),

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

Widget datePickerField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
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
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Select Date",
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          suffixIcon: const Icon(
            Icons.calendar_today,
            color: Color(0xFF000000),
          ),
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
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF1A4C8E),
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: Color(0xFF1A4C8E),
                    ),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.text = "${picked.day}-${picked.month}-${picked.year}";
          }
        },
      ),

      const SizedBox(height: 16),
    ],
  );
}
