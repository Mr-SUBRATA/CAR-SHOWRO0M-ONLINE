import 'package:arouse_ecommerce_frontend_web/api/enquiry_api.dart';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class EnquiryPage extends StatefulWidget {
  const EnquiryPage({super.key});

  @override
  State<EnquiryPage> createState() => _EnquiryPageState();
}

class _EnquiryPageState extends State<EnquiryPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final alternateMobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final pinCodeController = TextEditingController();
  final remarkController = TextEditingController();

  String? selectedState;
  String? selectedCity;
  String? selectedBrand;
  String? selectedModel;

  List<String> states = [];
  List<String> cities = [];
  List<Map<String, dynamic>> allCars = [];
  List<String> brands = [];
  List<String> models = [];

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final cars = await VehiclesApi.getAllCars();
    final rtoCities = await VehiclesApi().fetchRtoCities();

    Set<String> brandSet = {};
    for (var car in cars) {
      if (car['brand'] != null) {
        brandSet.add(car['brand'].toString());
      }
    }

    setState(() {
      allCars = cars;
      brands = brandSet.toList()..sort();
      cities = rtoCities;
      states = [
        'Delhi', 'Maharashtra', 'Karnataka', 'Tamil Nadu', 'Gujarat',
        'Uttar Pradesh', 'Rajasthan', 'West Bengal', 'Madhya Pradesh', 'Kerala'
      ];
    });
  }

  void onBrandChanged(String? brand) {
    if (brand == null) return;

    final filteredModels = allCars
        .where((car) => car['brand'] == brand)
        .map((car) => car['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    setState(() {
      selectedBrand = brand;
      selectedModel = null;
      models = filteredModels;
    });
  }

  void submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final Map<String, String> data = {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'mobile': mobileController.text.trim(),
    };

    if (alternateMobileController.text.isNotEmpty) {
      data['alternateMobile'] = alternateMobileController.text.trim();
    }
    if (emailController.text.isNotEmpty) {
      data['email'] = emailController.text.trim();
    }
    if (addressController.text.isNotEmpty) {
      data['currentAddress'] = addressController.text.trim();
    }
    if (selectedState != null) data['state'] = selectedState!;
    if (selectedCity != null) data['city'] = selectedCity!;
    if (pinCodeController.text.isNotEmpty) {
      data['pinCode'] = pinCodeController.text.trim();
    }
    if (selectedBrand != null) data['preferredBrand'] = selectedBrand!;
    if (selectedModel != null) data['preferredModel'] = selectedModel!;
    if (remarkController.text.isNotEmpty) {
      data['remark'] = remarkController.text.trim();
    }

    final result = await EnquiryApi.submitEnquiry(data);
    setState(() => isSubmitting = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Enquiry submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _formKey.currentState!.reset();
      firstNameController.clear();
      lastNameController.clear();
      mobileController.clear();
      alternateMobileController.clear();
      emailController.clear();
      addressController.clear();
      pinCodeController.clear();
      remarkController.clear();
      setState(() {
        selectedState = null;
        selectedCity = null;
        selectedBrand = null;
        selectedModel = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit enquiry'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CAppbar(selectedIndex: 6),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Image.asset(
            'assets/images/enquiry_car.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF0A4C8B),
                child: const Center(
                  child: Icon(Icons.directions_car, size: 100, color: Colors.white54),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 6,
          child: _buildFormSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.asset(
              'assets/images/enquiry_car.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF0A4C8B),
                  child: const Center(
                    child: Icon(Icons.directions_car, size: 60, color: Colors.white54),
                  ),
                );
              },
            ),
          ),
          _buildFormSection(),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 48,
          vertical: isMobile ? 24 : 40,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enquiry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0A4C8B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 70, height: 3, color: const Color(0xFF0A4C8B)),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                'Submit Your Enquiry',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please enter your details to submit an enquiry',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),

              _sectionTitle('Customer Details'),
              const SizedBox(height: 16),

              if (isMobile) ..._buildMobileCustomerFields() else ..._buildDesktopCustomerFields(),

              const SizedBox(height: 32),
              _sectionTitle('Vehicle Details'),
              const SizedBox(height: 16),

              if (isMobile) ..._buildMobileVehicleFields() else ..._buildDesktopVehicleFields(),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : submitEnquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A4C8B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Enquiry',
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  List<Widget> _buildMobileCustomerFields() {
    return [
      _buildTextField('First Name', 'Enter First Name', firstNameController, required: true),
      const SizedBox(height: 16),
      _buildTextField('Last Name', 'Enter Last Name', lastNameController, required: true),
      const SizedBox(height: 16),
      _buildPhoneField('Mobile', mobileController, required: true),
      const SizedBox(height: 16),
      _buildPhoneField('Alternate No.', alternateMobileController),
      const SizedBox(height: 16),
      _buildTextField('Email', 'Enter Email', emailController, isEmail: true),
      const SizedBox(height: 16),
      _buildTextField('Current Address', 'Enter Address', addressController),
      const SizedBox(height: 16),
      _buildDropdownField('State', 'Select State', states, selectedState,
          (val) => setState(() => selectedState = val)),
      const SizedBox(height: 16),
      _buildDropdownField('City', 'Select City', cities, selectedCity,
          (val) => setState(() => selectedCity = val)),
      const SizedBox(height: 16),
      _buildTextField('Pin Code', 'Enter Pin Code', pinCodeController),
    ];
  }

  List<Widget> _buildDesktopCustomerFields() {
    return [
      Row(children: [
        Expanded(child: _buildTextField('First Name', 'Enter First Name', firstNameController, required: true)),
        const SizedBox(width: 20),
        Expanded(child: _buildTextField('Last Name', 'Enter Last Name', lastNameController, required: true)),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _buildPhoneField('Mobile', mobileController, required: true)),
        const SizedBox(width: 20),
        Expanded(child: _buildPhoneField('Alternate No.', alternateMobileController)),
        const SizedBox(width: 20),
        Expanded(child: _buildTextField('Email', 'Enter Email', emailController, isEmail: true)),
      ]),
      const SizedBox(height: 16),
      _buildTextField('Current Address', 'Enter your full Address', addressController),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: _buildDropdownField('State', 'Select State', states, selectedState,
            (val) => setState(() => selectedState = val))),
        const SizedBox(width: 20),
        Expanded(child: _buildDropdownField('City', 'Select City', cities, selectedCity,
            (val) => setState(() => selectedCity = val))),
        const SizedBox(width: 20),
        Expanded(child: _buildTextField('Pin Code', 'Enter Pin Code', pinCodeController)),
      ]),
    ];
  }

  List<Widget> _buildMobileVehicleFields() {
    return [
      _buildDropdownField('Preferred Brand', 'Select Brand', brands, selectedBrand,
          (val) => onBrandChanged(val)),
      const SizedBox(height: 16),
      _buildDropdownField('Preferred Model', 'Select Model', models, selectedModel,
          (val) => setState(() => selectedModel = val)),
      const SizedBox(height: 16),
      _buildTextField('Remark', 'Any additional comments...', remarkController, maxLines: 3),
    ];
  }

  List<Widget> _buildDesktopVehicleFields() {
    return [
      Row(children: [
        Expanded(child: _buildDropdownField('Preferred Brand', 'Select Brand', brands, selectedBrand,
            (val) => onBrandChanged(val))),
        const SizedBox(width: 20),
        Expanded(child: _buildDropdownField('Preferred Model', 'Select Model', models, selectedModel,
            (val) => setState(() => selectedModel = val))),
      ]),
      const SizedBox(height: 16),
      _buildTextField('Remark', 'Any additional comments...', remarkController, maxLines: 3),
    ];
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller,
      {bool required = false, bool isEmail = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0A4C8B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0A4C8B), width: 1.5)),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) return '$label is required';
            if (isEmail && value != null && value.isNotEmpty && !value.contains('@')) return 'Enter valid email';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller, {bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(required ? '$label *' : label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0A4C8B))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter Phone Number',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('+91', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 18),
                  Container(width: 1, height: 20, color: Colors.grey[300], margin: const EdgeInsets.only(left: 6)),
                ],
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0A4C8B), width: 1.5)),
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) return 'Phone is required';
            if (value != null && value.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Enter valid 10-digit number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, String? value, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0A4C8B))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0A4C8B), width: 1.5)),
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    alternateMobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    pinCodeController.dispose();
    remarkController.dispose();
    super.dispose();
  }
}
