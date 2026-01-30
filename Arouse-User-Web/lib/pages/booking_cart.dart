// booking_cart.dart
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Dropdown.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_TextField.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ------------------------- Dummy Data -------------------------

final Map<String, dynamic> variantData = {
  'variantName': 'Arouse ZX 2025',
  'variantSub': 'Premium Edition',
  'exShowroom': 1200000,
  'baseOnRoad': 1350000,
  'dealerName': 'Arouse Automotive',
  'dealerAddress': 'Kirti Nagar, New Delhi',
  'dealerEmail': 'info@arouseauto.com',
  'dealerPhone': '9876543210',
};

final List<String> availableTypes = ['Standard Market', 'Premium Market'];

final List<String> branches = [
  'Arouse Automotive, Kirti Nagar',
  'Arouse Automotive, Rohini',
];

final List<String> cities = ['New Delhi', 'Noida', 'Gurgaon'];

final List<String> rtoList = ['Delhi RTO', 'Noida RTO'];

final List<String> insuranceList = ['Comprehensive', 'Third Party'];

final List<Map<String, dynamic>> accessories = [
  {
    'id': 'a1',
    'title': 'Floor Mat',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 1200,
    'isSelected': false,
  },
  {
    'id': 'a2',
    'title': 'Seat Cover',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 2500,
    'isSelected': false,
  },
  {
    'id': 'a3',
    'title': 'Car Cover',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 3000,
    'isSelected': false,
  },
  {
    'id': 'a4',
    'title': 'Alloy Wheels',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 15000,
    'isSelected': false,
  },
  {
    'id': 'a1',
    'title': 'Floor Mat',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 1200,
    'isSelected': false,
  },
  {
    'id': 'a2',
    'title': 'Seat Cover',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 2500,
    'isSelected': false,
  },
  {
    'id': 'a3',
    'title': 'Car Cover',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 3000,
    'isSelected': false,
  },
  {
    'id': 'a4',
    'title': 'Alloy Wheels',
    'image': 'assets/images/Booking_Cart/wheel.png',
    'price': 15000,
    'isSelected': false,
  },
];

// ------------------------- Booking Cart -------------------------
class BookingCart extends StatefulWidget {
  final Map<String, dynamic> carData;
  const BookingCart({super.key, required this.carData});

  @override
  State<BookingCart> createState() => _BookingCartState();
}

class _BookingCartState extends State<BookingCart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner header area
            Stack(
              children: [
                SizedBox(
                  height: AppSizes.screenHeight(context) * 0.28,
                  width: AppSizes.screenWidth(context),
                  child: Image.asset(
                    'assets/carbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: AppSizes.isDesktop(context)
                      ? AppSizes.screenHeight(context) * 0.10
                      : AppSizes.screenHeight(context) * 0.13,
                  left: 24,
                  right: 24,
                  child: Text(
                    'Booking Cart',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppSizes.extraLargeFont(context),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Main content area
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1180;
                final horizontalPadding = isDesktop ? 32.0 : 16.0;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: LeftFormSection()),
                            const SizedBox(width: 22),
                            SizedBox(
                              width: AppSizes.screenWidth(context) * 0.4,
                              child: Transform.translate(
                                offset: const Offset(0, -90),

                                child: RightPanel(car: widget.carData),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LeftFormSection(),
                            const SizedBox(height: 20),
                            RightPanel(car: widget.carData),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ------------------------- Left Form Section -------------------------
class LeftFormSection extends StatefulWidget {
  const LeftFormSection({super.key});

  @override
  State<LeftFormSection> createState() => _LeftFormSectionState();
}

class _LeftFormSectionState extends State<LeftFormSection> {
  final _formKey = GlobalKey<FormState>();
  String selectedType = availableTypes[0];
  String selectedBranch = branches[0];
  String selectedRTO = rtoList[0];
  String selectedInsurance = insuranceList[0];

  final TextEditingController name = TextEditingController(
    text: 'Mohd Abdulla',
  );
  final TextEditingController mobile = TextEditingController(
    text: '9876543210',
  );

  String? selectedState;
  String? selectedCity;

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
  final TextEditingController pinCode = TextEditingController();
  String? answer;
  final ScrollController scrollController = ScrollController();

  int selectedIndex = -1;

  List<Map<String, String>> addOns = [
    {"label": "Third party", "point": "250"},
    {"label": "Engine Cover", "point": "250"},
    {"label": "Zero Depreciation", "point": "250"},
    {"label": "Tyre Cover", "point": "250"},
  ];

  String selected = "Standard Market";

  final List<String> options = ["Standard Market", "CSD", "CPC"];
  @override
  Widget build(BuildContext context) {
    double formSpacing = AppSizes.isDesktop(context) ? 20 : 12;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFC6C6C6), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Choose Type
                sectionHeading(context, title: 'Choose Type', number: "1"),
                const SizedBox(height: 23),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: options.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: GestureDetector(
                          onTap: () => setState(() => selected = item),
                          child: Row(
                            children: [
                              Radio<String>(
                                value: item,
                                groupValue: selected,
                                onChanged: (val) =>
                                    setState(() => selected = val!),
                                activeColor: const Color(0xFF1A4C8E),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                item,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: selected == item
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: const Color(0xFF1A4C8E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: formSpacing * 1.2),
                // Branch / City selects
                sectionHeading(context, title: 'Select Branch', number: "2"),
                const SizedBox(height: 16),
                AppSizes.isDesktop(context)
                    ? Row(
                        children: [
                          Expanded(child: stateField(context)),

                          const SizedBox(width: 12),
                          Expanded(
                            child: CDropdown(
                              label: "City",
                              value: selectedCity,
                              items: cities,
                              onChanged: (v) {
                                setState(() => selectedCity = v as String);
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          stateField(context),

                          const SizedBox(height: 12),
                          CDropdown(
                            label: "City",
                            value: selectedCity,
                            items: cities,
                            onChanged: (v) {
                              setState(() => selectedCity = v as String);
                            },
                          ),
                        ],
                      ),

                CTextfield(label: "Pin Code", hint: "Enter pin code"),
                SizedBox(height: formSpacing * 1.2),

                sectionHeading(context, title: 'Address Details', number: "3"),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Current Address',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.bodyFont(context),
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Current address
                CTextfield(
                  label: "Address Line1",
                  hint: "Enter current address",
                  maxLines: 1,
                ),
                SizedBox(height: formSpacing * 1.2),
                CTextfield(
                  label: "Address Line2",
                  hint: "Enter current address",
                  maxLines: 1,
                ),
                SizedBox(height: formSpacing * 1.2),
                AppSizes.isDesktop(context)
                    ? Row(
                        children: [
                          Expanded(child: stateField(context)),

                          const SizedBox(width: 12),
                          Expanded(
                            child: CDropdown(
                              label: "City",
                              value: selectedCity,
                              items: cities,
                              onChanged: (v) {
                                setState(() => selectedCity = v as String);
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          stateField(context),

                          const SizedBox(height: 12),
                          CDropdown(
                            label: "City",
                            value: selectedCity,
                            items: cities,
                            onChanged: (v) {
                              setState(() => selectedCity = v as String);
                            },
                          ),
                        ],
                      ),

                CTextfield(label: "Pin Code", hint: "Enter pin code"),
                SizedBox(height: formSpacing * 1.2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Permanent Address',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.bodyFont(context),
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Permanent address
                CTextfield(
                  label: "Address Line1",
                  hint: "Enter current address",
                  maxLines: 1,
                ),
                SizedBox(height: formSpacing * 1.2),
                CTextfield(
                  label: "Address Line2",
                  hint: "Enter current address",
                  maxLines: 1,
                ),
                SizedBox(height: formSpacing * 1.2),

                AppSizes.isDesktop(context)
                    ? Row(
                        children: [
                          Expanded(child: stateField(context)),

                          const SizedBox(width: 12),
                          Expanded(
                            child: CDropdown(
                              label: "City",
                              value: selectedCity,
                              items: cities,
                              onChanged: (v) {
                                setState(() => selectedCity = v as String);
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          stateField(context),

                          const SizedBox(height: 12),
                          CDropdown(
                            label: "City",
                            value: selectedCity,
                            items: cities,
                            onChanged: (v) {
                              setState(() => selectedCity = v as String);
                            },
                          ),
                        ],
                      ),

                CTextfield(label: "Pin Code", hint: "Enter pin code"),
                SizedBox(height: formSpacing * 1.2),
                sectionHeading(context, title: 'Select RTO', number: "4"),
                const SizedBox(height: 16),
                // RTO / Insurance
                CDropdown(
                  label: "RTO",
                  value: selectedRTO,
                  items: rtoList,
                  onChanged: (v) => setState(() => selectedRTO = v as String),
                ),
                SizedBox(height: formSpacing * 1.2),
                sectionHeading(
                  context,
                  title: 'Financial Details',
                  number: "5",
                ),
                const SizedBox(height: 16),
                radioButtons(
                  context,
                  question:
                      "Do you want to explore financing options for your vehicle?",
                  groupValue: answer,
                  onChanged: (val) {
                    setState(() {
                      answer = val;
                    });
                  },
                ),
                SizedBox(height: formSpacing * 1.2),
                AppSizes.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CTextfield(
                              label: "Preferred Finance Provider",
                              hint: "HDFC Bank",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                child: CTextfield(
                                  label: "Loan Amount",
                                  hint: "12,000000",
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Minimum 2,50,000 down payment is required',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: AppSizes.smallFont(context),
                                  color: const Color(0xFF1F1F1F),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CTextfield(
                            label: "Preferred Finance Provider",
                            hint: "HDFC Bank",
                          ),
                          const SizedBox(height: 16),
                          CTextfield(label: "Loan Amount", hint: "12,000000"),
                          const SizedBox(height: 6),
                          Text(
                            'Minimum 2,50,000 down payment is required',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: AppSizes.smallFont(context),
                              color: const Color(0xFF1F1F1F),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                SizedBox(height: formSpacing * 1.2),
                AppSizes.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CDropdown(
                              label: "Preferred Loan terms",
                              items: ["5 Years", "10 Years", "15 Years"],
                              value: "5 Years",
                              onChanged: (v) {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CTextfield(
                              label: "Rate of Interest",
                              hint: "5%",
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CTextfield(label: "", hint: "5%"),
                          const SizedBox(height: 16),
                          CTextfield(label: "Rate of Interest", hint: "5%"),
                        ],
                      ),
                SizedBox(height: formSpacing * 1.2),
                sectionHeading(
                  context,
                  title: 'Insurance Details',
                  number: "6",
                ),
                SizedBox(height: formSpacing * 1.2),
                AppSizes.isDesktop(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CDropdown(
                              label: "Preferred Insurance Provider",
                              items: ["5 Years", "10 Years", "15 Years"],
                              value: "5 Years",
                              onChanged: (v) {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CTextfield(
                              label: "Car Value",
                              hint: "12,00000",
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CTextfield(label: "", hint: "5%"),
                          const SizedBox(height: 16),
                          CTextfield(label: "Rate of Interest", hint: "5%"),
                        ],
                      ),
                SizedBox(height: formSpacing * 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Preferred Add Ons',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A4C8E),
                      fontSize: AppSizes.smallFont(context),
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Stack(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 140),
                      child: ListView.separated(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 40),
                        itemCount: addOns.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 15),

                        itemBuilder: (context, index) {
                          return addOnsCard(
                            context,
                            label: addOns[index]['label']!,
                            point: addOns[index]['point']!,
                            selected: selectedIndex == index,
                            onTap: () => setState(() => selectedIndex = index),
                          );
                        },
                      ),
                    ),

                    Positioned(
                      right: 0,
                      top: 50,
                      child: GestureDetector(
                        onTap: () {
                          scrollController.animateTo(
                            scrollController.offset + 200,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A4C8E),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(3),
                              bottomRight: Radius.circular(3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: formSpacing * 2),

                // Accessories
                sectionHeading(context, title: 'Accessories', number: "7"),
                const SizedBox(height: 30),
                GridView.builder(
                  itemCount: accessories.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppSizes.isDesktop(context)
                        ? 4
                        : (AppSizes.isTablet(context) ? 3 : 2),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, idx) {
                    final a = accessories[idx];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => a['isSelected'] = !a['isSelected']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.56,
                            color: a['isSelected']
                                ? const Color(0xFF1A4C8E)
                                : const Color(0xFF0D80D4),
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                a['image'],
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Radio, Title & Price Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Radio(
                                  value: true,
                                  groupValue: a['isSelected'],
                                  onChanged: (_) => setState(
                                    () => a['isSelected'] = !a['isSelected'],
                                  ),
                                  activeColor: const Color(0xFF1A4C8E),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['title'],
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Sofia Pro',
                                          fontSize: AppSizes.smallFont(context),
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF646363),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '+${a['price']}',
                                        style: TextStyle(
                                          fontFamily: 'Sofia Pro',
                                          fontWeight: FontWeight.w400,
                                          fontSize: AppSizes.mediumFont(
                                            context,
                                          ),
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  InputDecoration _dropDecoration() => InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

// ------------------------- Right Summary Card -------------------------
class RightPanel extends StatefulWidget {
  final Map<String, dynamic> car;
  const RightPanel({super.key, required this.car});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  Color selectedColor = Colors.red;
  String selectedName = "Red";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Variant + Color + Dealer
        infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Selected Variant", context),
              const SizedBox(height: 6),
              Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFC6C6C6), width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car['name'] ?? "",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: AppSizes.bodyFont(context),
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "1.5T MT Executive 7S - Petrol",
                      style: TextStyle(
                        fontSize: AppSizes.smallFont(context),
                        color: Color(0xFF3E3E3E),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "*Ex-showroom price – Rs. 13,00,000",
                      style: TextStyle(
                        fontSize: AppSizes.smallFont(context),
                        color: Color(0xFF8E8E8E),
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AppSizes.isMobile(context)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "On-road price – Rs. 14,50,000",
                                style: TextStyle(
                                  fontSize: AppSizes.smallFont(context),
                                  color: Color(0xFF295800),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'View price breakup',
                                      style: TextStyle(
                                        fontSize: AppSizes.smallFont(context),
                                        color: Color(0xFF0D80D4),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF0D80D4),
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                "On-road price – Rs. 14,50,000",
                                style: TextStyle(
                                  fontSize: AppSizes.smallFont(context),
                                  color: Color(0xFF295800),
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Row(
                                  children: [
                                    Text(
                                      'View price breakup',
                                      style: TextStyle(
                                        fontSize: AppSizes.smallFont(context),
                                        color: Color(0xFF0D80D4),
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Color(0xFF0D80D4),
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              sectionTitle('Selected Color', context),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFDFDFDF)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedName,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: AppSizes.smallFont(context),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1F384C),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Dealer Details
              sectionTitle("Dealer Details", context),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFDADADA)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Arouse Automotive",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E3E3E),
                        fontSize: AppSizes.bodyFont(context),
                      ),
                    ),
                    SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF1A4C8E),
                        ),
                        SizedBox(width: 15),
                        Text(
                          "A big line of address for this",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: AppSizes.smallFont(context),
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Color(0xFF1A4C8E)),
                        SizedBox(width: 15),
                        Text(
                          "arouse.ag@gmail.com",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: AppSizes.smallFont(context),
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Color(0xFF1A4C8E)),
                        SizedBox(width: 15),
                        Text(
                          "011-9274109214",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w500,
                            fontSize: AppSizes.smallFont(context),
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Booking Amount Paid  ",
                    style: TextStyle(
                      fontSize: AppSizes.isMobile(context)
                          ? 14
                          : AppSizes.mediumFont(context),
                      color: Color(0xFF8E8E8E),
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Rs. 11,000",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: AppSizes.isMobile(context)
                          ? 14
                          : AppSizes.mediumFont(context),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4C8E),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/icons/book_online.svg'),
                      SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: AppSizes.bodyFont(context),
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget infoCard({required Widget child}) => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Color(0x11000000), blurRadius: 10, offset: Offset(0, 3)),
    ],
  ),
  child: child,
);

Widget sectionTitle(String title, BuildContext context) => Text(
  title,
  style: TextStyle(
    fontFamily: 'DM Sans',
    fontSize: AppSizes.bodyFont(context),
    fontWeight: FontWeight.w600,
    color: Color(0xFF6D6D6D),
  ),
);

// ------------------------- Section Heading -------------------------
Widget sectionHeading(
  BuildContext context, {
  required String title,
  required String number,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            height: 29,
            width: 29,
            decoration: BoxDecoration(
              color: Color(0xFF1A4C8E),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number, style: TextStyle(color: Color(0xFFFFFFFF))),
            ),
          ),
          SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.bodyFont(context),
              color: Color(0xFF6D6D6D),
            ),
          ),
        ],
      ),
      SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(width: 216, height: 2.4, color: Color(0xFF004C90)),
            SizedBox(height: 14),
            Expanded(child: Container(height: 2, color: Color(0xFFBDBDBD))),
          ],
        ),
      ),
    ],
  );
}

// ------------------------- Helper -------------------------
String formatIndianCurrency(num amount) {
  final intVal = amount.toInt();
  String s = intVal.toString();
  if (s.length <= 3) return 'Rs. $s';
  final last3 = s.substring(s.length - 3);
  String rest = s.substring(0, s.length - 3);
  String groups = '';
  while (rest.length > 2) {
    groups = ',${rest.substring(rest.length - 2)}$groups';
    rest = rest.substring(0, rest.length - 2);
  }
  groups = rest + groups;
  return 'Rs. $groups,$last3';
}

Widget radioButtons(
  BuildContext context, {
  required String question,
  required String? groupValue,
  required Function(String?) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        question,
        style: TextStyle(
          fontSize: AppSizes.smallFont(context),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      Row(
        children: [
          Radio<String>(
            value: 'Yes',
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          const Text('Yes', style: TextStyle(color: Color(0xFF004C90))),
          Radio<String>(
            value: 'No',
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          const Text('No', style: TextStyle(color: Color(0xFF004C90))),
        ],
      ),
    ],
  );
}

Widget addOnsCard(
  BuildContext context, {
  required String label,
  required String point,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(18),
      width: 220,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0D80D4), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Radio<bool>(
                value: true,
                groupValue: selected,
                activeColor: const Color(0xFF003C8A),
                onChanged: (_) => onTap(),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sofia Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: AppSizes.smallFont(context),
                    color: Color(0xFF646363),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "+$point ",
                  style: TextStyle(
                    fontFamily: 'Sofia Pro',
                    fontWeight: FontWeight.w400,
                    fontSize: AppSizes.mediumFont(context),
                  ),
                ),
                TextSpan(
                  text: "Approx",
                  style: TextStyle(
                    fontFamily: 'Sofia Pro',
                    fontSize: AppSizes.smallFont(context),
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF646363),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
