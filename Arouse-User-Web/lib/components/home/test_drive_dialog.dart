import 'package:arouse_ecommerce_frontend_web/api/book_test_drive_api.dart';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/components/Book_Test_Drive/booking_failure_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/Book_Test_Drive/booking_success_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class TestDriveDialog extends StatefulWidget {
  const TestDriveDialog({super.key});

  @override
  State<TestDriveDialog> createState() => _TestDriveDialogState();
}

class _TestDriveDialogState extends State<TestDriveDialog> {
  String? selectedState;
  String? selectedCity;
  String? selectedTimeSlot;
  String? selectedPhoneCode = "+91";
  String? selectedAltPhoneCode = "+91";
  TextEditingController phoneController = TextEditingController();
  TextEditingController altPhoneController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<String> drivingLicense = ["Yes", "No"];
  DateTime? selectedDate;
  String? selectedLicense;

  List<String> timeSlots = [
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
  ];

  final List<String> stateList = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman & Nicobar Islands',
    'Chandigarh',
    'Dadra & Nagar Haveli and Daman & Diu',
    'Delhi',
    'Jammu & Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  final Map<String, List<String>> cityList = {
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Saket', 'Karol Bagh'],
    'Uttar Pradesh': ['Noida', 'Ghaziabad', 'Agra', 'Lucknow', 'Varanasi'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Thane'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Hubli', 'Mangalore'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota'],
    'Punjab': ['Amritsar', 'Ludhiana', 'Jalandhar', 'Patiala'],
    'Haryana': ['Gurgaon', 'Faridabad', 'Panipat', 'Hisar'],
    'Gujarat': ['Ahmedabad', 'Vadodara', 'Surat', 'Rajkot'],
  };

  List<Map<String, dynamic>>? cars;
  List<Map<String, dynamic>> allCars = [];
  List<String> brands = [];
  List<String> models = [];
  bool isLoading = false;
  String? selectedBrand;
  String? selectedModel;

  @override
  void initState() {
    super.initState();
    fetchCarsData();
  }

  Future<void> fetchCarsData() async {
    allCars = await VehiclesApi.getAllCars();
    setState(() {
      cars = allCars;
      brands = allCars.map((v) => v['brand'] as String).toSet().toList();
      models = allCars.map((v) => v['name'] as String).toSet().toList();
    });
  }

  void onBrandSelected(String? brand) {
    setState(() {
      selectedBrand = brand;
      selectedModel = null;
      models = allCars
          .where((v) => v['brand'] == brand)
          .map((v) => v['name'] as String)
          .toSet()
          .toList();
    });
  }

  void onModelSelected(String? model) {
    setState(() {
      selectedModel = model;
      brands = allCars
          .where((v) => v['name'] == model)
          .map((v) => v['brand'] as String)
          .toSet()
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        AppSizes.isDesktop(context) || MediaQuery.of(context).size.width > 900;

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: AppSizes.screenWidth(context) * 0.85,
        height: AppSizes.screenHeight(context) * 0.75,
        child: Row(
          children: [
            if (AppSizes.screenWidth(context) > 1080)
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.asset(
                    "assets/images/Home_Images/Book_Test_Drive/test.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Drive',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: AppSizes.bodyFont(context),
                        color: const Color(0xFF6D6D6D),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Book a Test Drive",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: AppSizes.mediumFont(context),
                            color: const Color(0xFF4A4A4A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // ------------------ STATE & CITY ------------------
                            isDesktop
                                ? Row(
                                    children: [
                                      const SizedBox(height: 6),
                                      Expanded(child: stateField(context)),
                                      const SizedBox(width: 16),
                                      Expanded(child: cityField(context)),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      stateField(context),
                                      SizedBox(height: 16),
                                      cityField(context),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            _InputField(
                              context,
                              label: "Address",
                              hint: "Enter your full address",
                              controller: addressController,
                            ),

                            const SizedBox(height: 16),

                            // ------------------ BRAND & MODEL ------------------
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: buildDropdown(
                                          label: "Brand",
                                          value: selectedBrand,
                                          items: brands,
                                          onChanged: onBrandSelected,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: buildDropdown(
                                          label: "Model",
                                          value: selectedModel,
                                          items: models,
                                          onChanged: onModelSelected,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      buildDropdown(
                                        label: "Brand",
                                        value: selectedBrand,
                                        items: brands,
                                        onChanged: onBrandSelected,
                                      ),
                                      buildDropdown(
                                        label: "Model",
                                        value: selectedModel,
                                        items: models,
                                        onChanged: onModelSelected,
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            // ------------------ DATE & TIME ------------------
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: datePickerField(
                                          label: "Test Drive Date",
                                          controller: dateController,
                                          context: context,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: buildDropdown(
                                          label: "Time Slot",
                                          value: selectedTimeSlot,
                                          items: timeSlots,
                                          onChanged: (v) => setState(
                                            () => selectedTimeSlot = v,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      datePickerField(
                                        label: "Test Drive Date",
                                        controller: dateController,
                                        context: context,
                                      ),
                                      buildDropdown(
                                        label: "Time Slot",
                                        value: selectedTimeSlot,
                                        items: timeSlots,
                                        onChanged: (v) => setState(
                                          () => selectedTimeSlot = v,
                                        ),
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            // ------------------ NAME & PHONE ------------------
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: _InputField(
                                          context,
                                          label: "Name",
                                          hint: "Enter your name",
                                          controller: nameController,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: phoneField(
                                          label: "Phone Number",
                                          controller: phoneController,
                                          selectedCode: selectedPhoneCode,
                                          onChanged: (v) => setState(
                                            () => selectedPhoneCode = v,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _InputField(
                                        context,
                                        label: "Name",
                                        hint: "Enter your name",
                                        controller: nameController,
                                      ),
                                      phoneField(
                                        label: "Phone Number",
                                        controller: phoneController,
                                        selectedCode: selectedPhoneCode,
                                        onChanged: (v) => setState(
                                          () => selectedPhoneCode = v,
                                        ),
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            // ------------------ ALT PHONE & EMAIL ------------------
                            isDesktop
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: phoneField(
                                          label: "Alternate Number",
                                          controller: altPhoneController,
                                          selectedCode: selectedAltPhoneCode,
                                          onChanged: (v) => setState(
                                            () => selectedAltPhoneCode = v,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _InputField(
                                          context,
                                          label: "Email",
                                          hint: "yourmail@mail.com",
                                          controller: emailController,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      phoneField(
                                        label: "Alternate Number",
                                        controller: altPhoneController,
                                        selectedCode: selectedAltPhoneCode,
                                        onChanged: (v) => setState(
                                          () => selectedAltPhoneCode = v,
                                        ),
                                      ),
                                      _InputField(
                                        context,
                                        label: "Email",
                                        hint: "yourmail@mail.com",
                                        controller: emailController,
                                      ),
                                    ],
                                  ),

                            const SizedBox(height: 16),

                            buildDropdown(
                              label: "Do you have a driving license?",
                              value: selectedLicense,
                              items: drivingLicense,
                              onChanged: (v) =>
                                  setState(() => selectedLicense = v),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ------------------ BUTTON WITH LOADER ------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: const Color(0xFF004C90),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() => isLoading = true);

                                var response =
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

                                setState(() => isLoading = false);

                                Navigator.of(context).pop();

                                showDialog(
                                  context: context,
                                  builder: (context) => response
                                      ? BookingSuccessDialog()
                                      : BookingFailureDialog(),
                                );
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Book Now",
                                style: TextStyle(
                                  fontSize: AppSizes.buttonFont(context),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SMALL HELPERS ----------------

  Widget stateField(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'State',
        style: TextStyle(
          fontSize: AppSizes.smallFont(context),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      SizedBox(height: 6),
      DropdownButtonFormField<String>(
        decoration: _dropDecoration(),
        value: selectedState,
        isExpanded: true, // 👈 IMPORTANT
        hint: const Text("State"),
        items: stateList
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  overflow: TextOverflow.ellipsis, // 👈 optional safety
                ),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() {
          selectedState = v;
          selectedCity = null;
        }),
      ),
    ],
  );

  Widget cityField(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'City',
        style: TextStyle(
          fontSize: AppSizes.smallFont(context),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      SizedBox(height: 6),
      DropdownButtonFormField<String>(
        decoration: _dropDecoration(),
        value: selectedCity,
        hint: const Text("Select City"),
        items: selectedState != null && cityList[selectedState] != null
            ? cityList[selectedState]!
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList()
            : [],
        onChanged: (v) => setState(() => selectedCity = v),
      ),
    ],
  );

  InputDecoration _dropDecoration() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

//----------------- Reusable Fields -----------------

Widget _InputField(
  BuildContext context, {
  required String label,
  required String hint,
  required TextEditingController controller,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: AppSizes.smallFont(context),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFC6C6C6), width: 1),
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
