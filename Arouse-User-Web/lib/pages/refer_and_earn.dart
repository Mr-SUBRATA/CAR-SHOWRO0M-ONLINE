import 'dart:ui';

import 'package:arouse_ecommerce_frontend_web/api/refer_and_earn_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class ReferAndEarn extends StatefulWidget {
  const ReferAndEarn({super.key});

  @override
  State<ReferAndEarn> createState() => _ReferAndEarnState();
}

class _ReferAndEarnState extends State<ReferAndEarn> {
  String? selectedBrand;
  String? selectedMonth;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController alternateController = TextEditingController();
  Map<String, dynamic>? loyaltyCard;
  int loyaltyPoints = 0;
  int referralPoints = 0;
  String referralCode = "";
  List<dynamic> pointsHistory = [];

  List<String> brands = ["Mercedes", "BMW", "Audi", "Toyota", "Honda"];

  List<String> getMonthsWithYear() {
    int year = DateTime.now().year;

    return [
      "January $year",
      "February $year",
      "March $year",
      "April $year",
      "May $year",
      "June $year",
      "July $year",
      "August $year",
      "September $year",
      "October $year",
      "November $year",
      "December $year",
    ];
  }

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      // Fetch loyalty card
      final cardData = await ReferAndEarnApi.getMyLoyaltyCard();
      setState(() => loyaltyCard = cardData['card']);

      // Fetch points
      final pointsData = await ReferAndEarnApi.getMyPoints();
      setState(() {
        loyaltyPoints = pointsData["loyaltyPoints"] ?? 0;
        referralPoints = pointsData["referralPoints"] ?? 0;
      });

      // Fetch points history
      final historyData = await ReferAndEarnApi.getPointsHistory();
      setState(() => pointsHistory = historyData);

      // Fetch referral code dynamically (assuming API returns it)
      setState(() => referralCode = pointsData["referralCode"] ?? "N/A");
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  // ---------------- Enquiry ----------------
  Future<void> submitEnquiry() async {
    if (loyaltyCard == null || loyaltyCard!['status'] != "ACTIVE") {
      payAndEarnDialog(context);
      return;
    }

    if (nameController.text.isEmpty || contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Contact Number are required")),
      );
      return;
    }

    try {
      await ReferAndEarnApi.createEnquiry(
        customerName: nameController.text.trim(),
        contactNumber: contactController.text.trim(),
        preferredBrand: selectedBrand,
        alternateNumber: alternateController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enquiry submitted successfully!")),
      );

      await fetchAllData(); // refresh points and loyalty card
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------------- Refer a Friend ----------------
  Future<void> referFriend(String mobile) async {
    if (mobile.isEmpty) return;

    try {
      await ReferAndEarnApi.referFriend(mobile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Referral sent successfully!")),
      );
      await fetchAllData(); // refresh points
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // 🔹 Open Enquiry Status Dialog
  void openEnquiryStatusDialog() {
    enqueryStatusDialog(
      context,
      value: selectedMonth,
      items: getMonthsWithYear(),
      onChanged: (v) {
        setState(() => selectedMonth = v);
      },
    );
  }

  // 🔹 Open Invite & Earn Dialog
  void openPayAndEarnDialog() {
    payAndEarnDialog(context);
  }

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
            Container(
              padding: AppSizes.screenWidth(context) < 480
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : AppSizes.screenWidth(context) < 900
                  ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  : const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
              width: AppSizes.screenWidth(context),
              decoration: BoxDecoration(color: Color(0xFF1A4C8E)),
              child: Text(
                'Refer & Earn',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.titleFont(context),
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Main content area
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1000;
                final horizontalPadding = isDesktop ? 32.0 : 16.0;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: BuildLeftSection(
                                loyaltyCard: loyaltyCard,
                                loyaltyPoints: loyaltyPoints,
                                referralPoints: referralPoints,
                                pointsHistory: pointsHistory,
                              ),
                            ),
                            const SizedBox(width: 22),
                            SizedBox(
                              width: AppSizes.screenWidth(context) * 0.4,
                              child: BuildRightSection(
                                nameController: nameController,
                                contactController: contactController,
                                alternateController: alternateController,
                                selectedBrand: selectedBrand,
                                referralCode: referralCode,
                                submitEnquiry: submitEnquiry,
                                openEnquiryStatusDialog:
                                    openEnquiryStatusDialog,
                                openPayAndEarnDialog: openPayAndEarnDialog,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BuildLeftSection(
                              loyaltyCard: loyaltyCard,
                              loyaltyPoints: loyaltyPoints,
                              referralPoints: referralPoints,
                              pointsHistory: pointsHistory,
                            ),
                            const SizedBox(height: 20),
                            BuildRightSection(
                              nameController: nameController,
                              contactController: contactController,
                              alternateController: alternateController,
                              selectedBrand: selectedBrand,
                              referralCode: referralCode,
                              submitEnquiry: submitEnquiry,
                              openEnquiryStatusDialog: openEnquiryStatusDialog,
                              openPayAndEarnDialog: openPayAndEarnDialog,
                            ),
                          ],
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BuildLeftSection extends StatefulWidget {
  final Map<String, dynamic>? loyaltyCard;
  final int loyaltyPoints;
  final int referralPoints;
  final List<dynamic> pointsHistory;
  const BuildLeftSection({
    super.key,
    required this.loyaltyCard,
    required this.loyaltyPoints,
    required this.referralPoints,
    required this.pointsHistory,
  });
  @override
  State<BuildLeftSection> createState() => _BuildLeftSectionState();
}

class _BuildLeftSectionState extends State<BuildLeftSection> {
  String? selectedBrand;
  String? selectedMonth;

  List<String> brands = ["Mercedes", "BMW", "Audi", "Toyota", "Honda"];

  List<String> getMonthsWithYear() {
    final year = DateTime.now().year;
    return [
      "January $year",
      "February $year",
      "March $year",
      "April $year",
      "May $year",
      "June $year",
      "July $year",
      "August $year",
      "September $year",
      "October $year",
      "November $year",
      "December $year",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 TAB HEADER
        const SizedBox(height: 30),
        Container(
          padding: AppSizes.isDesktop(context)
              ? EdgeInsets.all(20)
              : EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFC6C6C6), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My E- Loyalty Card",
                style: TextStyle(
                  fontFamily: "DM Sans",
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.bodyFont(context),
                  color: Color(0xFF6D6D6D),
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 129,
                      height: 2.4,
                      color: Color(0xFF004C90),
                    ),

                    Expanded(
                      child: Container(height: 1, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 CARD SLIDER
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (widget.loyaltyCard != null)
                      _loyaltyCard(
                        context,
                        cardNumber: widget.loyaltyCard!["cardNumber"] ?? "",
                        expiry: widget.loyaltyCard!["validTill"] != null
                            ? DateTime.parse(
                                widget.loyaltyCard!["validTill"],
                              ).toLocal().toString().split(' ')[0]
                            : null,
                      )
                    else
                      _loyaltyCard(
                        cardNumber: "Create / Renew Loyalty Card",
                        expiry: "XX/XX",
                        context,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              // 🔹 Card Balance Header
              Text(
                "Card Balance",
                style: TextStyle(
                  fontFamily: "DM Sans",
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.bodyFont(context),
                  color: Color(0xFF6D6D6D),
                ),
              ),
              SizedBox(height: 6),
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
                      child: Container(height: 1, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "₹${widget.loyaltyPoints + widget.referralPoints}",
                style: TextStyle(
                  fontFamily: "SF Pro Display",
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF000000),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        Container(
          padding: AppSizes.isDesktop(context)
              ? EdgeInsets.all(20)
              : EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFC6C6C6), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: AppSizes.screenWidth(context) > 1250
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 180),
                        child: currentBalance(
                          context,
                          widget.loyaltyPoints,
                          widget.referralPoints,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(minHeight: 180),
                        child: cardStatementTable(
                          context,
                          widget.pointsHistory,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    currentBalance(
                      context,
                      widget.loyaltyPoints,
                      widget.referralPoints,
                    ),
                    cardStatementTable(context, widget.pointsHistory),
                  ],
                ),
        ),

        SizedBox(height: 32),

        SizedBox(height: 50),
      ],
    );
  }
}

class BuildRightSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController alternateController;
  final String? selectedBrand;
  final String referralCode;
  final VoidCallback submitEnquiry;
  final VoidCallback openEnquiryStatusDialog;
  final VoidCallback openPayAndEarnDialog;
  const BuildRightSection({
    super.key,
    required this.nameController,
    required this.contactController,
    required this.alternateController,
    required this.selectedBrand,
    required this.referralCode,
    required this.submitEnquiry,
    required this.openEnquiryStatusDialog,
    required this.openPayAndEarnDialog,
  });
  @override
  State<BuildRightSection> createState() => _BuildRightSectionState();
}

class _BuildRightSectionState extends State<BuildRightSection> {
  String? selectedBrand;
  String? selectedMonth;

  List<String> brands = ["Mercedes", "BMW", "Audi", "Toyota", "Honda"];

  List<String> getMonthsWithYear() {
    final year = DateTime.now().year;
    return [
      "January $year",
      "February $year",
      "March $year",
      "April $year",
      "May $year",
      "June $year",
      "July $year",
      "August $year",
      "September $year",
      "October $year",
      "November $year",
      "December $year",
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Container(
          padding: AppSizes.isDesktop(context)
              ? EdgeInsets.symmetric(horizontal: 36, vertical: 36)
              : EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFC6C6C6)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              // Add Enquiry + Check Enquiry Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Add Enquiry",
                    style: TextStyle(
                      fontFamily: "DM Sans",
                      fontWeight: FontWeight.w600,
                      fontSize: AppSizes.bodyFont(context),
                      color: Color(0xFF6D6D6D),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.openEnquiryStatusDialog();
                    },
                    child: Row(
                      children: const [
                        Text(
                          "Check Enquiry Status",
                          style: TextStyle(
                            fontFamily: "Inter",
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF0D80D4),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 13,
                          color: Color(0xFF0D80D4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(width: 92, height: 2.4, color: Color(0xFF004C90)),

                    Expanded(
                      child: Container(height: 1, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22),
              // 🔹 INPUT FIELDS
              inputField(label: "Name", value: widget.nameController.text),
              inputField(
                label: "Contact Number",
                value: widget.contactController.text,
              ),
              inputField(
                label: "Alternate Number",
                value: widget.alternateController.text,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Preferred Brand",
                    style: const TextStyle(
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFF1A4C8E),
                    ),
                  ),
                  const SizedBox(height: 9),

                  DropdownButtonFormField<String>(
                    value: selectedBrand,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFC6C6C6),
                          width: 1,
                        ),
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

                    items: brands.map((brand) {
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(
                          brand,
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: "Inter",
                          ),
                        ),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() => selectedBrand = value);
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    widget.submitEnquiry();
                    widget.nameController.clear();
                    widget.contactController.clear();
                    widget.alternateController.clear();
                    setState(() => selectedBrand = null);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF004C90),
                      width: 1.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontFamily: "DM Sans",
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF004C90),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 32),

        // ---------- Card ----------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Color(0xFFC6C6C6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "My Referral Code",
                  style: TextStyle(
                    fontFamily: "DM Sans",
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.bodyFont(context),
                    color: Color(0xFF6D6D6D),
                  ),
                ),
              ),
              SizedBox(height: 6),
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
                      child: Container(height: 1, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.referralCode.toString().toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 35,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A4C8E),
                ),
              ),
              const SizedBox(height: 10),

              // Copy & Share Row
              GestureDetector(
                onTap: () {
                  if (widget.referralCode.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: widget.referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Referral code copied to clipboard!"),
                      ),
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.copy, size: 11, color: Colors.blue.shade700),
                    const SizedBox(width: 5),
                    Text(
                      "Copy Referral Code",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Color(0xFF0D80D4),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.38,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1.5, height: 16, color: Color(0xFFCDCDCD)),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.share_outlined,
                      size: 11,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Share Link",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Color(0xFF0D80D4),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.38,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 54),

              // Invite + Earn text
              Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    color: Color(0xFF1A4C8E),
                    size: AppSizes.iconMedium(context),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      payAndEarnDialog(context);
                    },
                    child: Text(
                      "Invite & Earn!",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: AppSizes.mediumFont(context),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A4C8E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "Share your referral code with friends and earn points "
                "for every successful signup! The more you share, the more you earn—"
                "start inviting now!",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: AppSizes.smallFont(context),
                  height: 1.5,
                  color: Color(0xFF747474),
                ),
              ),

              const SizedBox(height: 18),

              // Watch Video Button
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(57),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF1A4C8E), width: 1.25),
                    borderRadius: BorderRadius.circular(57),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        color: Color(0xFF1A4C8E),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Watch Video",
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A4C8E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 50),
      ],
    );
  }
}

Widget cardStatementTable(BuildContext context, List<dynamic> pointsHistory) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Card Statement",
            style: TextStyle(
              fontFamily: "DM Sans",
              fontWeight: FontWeight.w600,
              fontSize: AppSizes.bodyFont(context),
              color: Color(0xFF6D6D6D),
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (pointsHistory.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No card history to export.")),
                );
                return;
              }

              try {
                //await ReferAndEarnApi.exportCardStatement(); // implement backend API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Report downloaded successfully!"),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error exporting report: $e")),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD9D9D9), width: 0.67),
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.file_download_outlined,
                      size: 13,
                      color: Color(0xFF0D80D4),
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Export Card Statement",
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0D80D4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(width: 92, height: 2.4, color: Color(0xFF004C90)),

            Expanded(child: Container(height: 1, color: Color(0xFFBDBDBD))),
          ],
        ),
      ),
      const SizedBox(height: 6),
      // ---------- Table Header ----------
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF2F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Date",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Reference No",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Earned",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Redeemed",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
            Expanded(
              child: Text(
                "Total",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Sofia Pro',
                  fontSize: 6,
                  color: Color(0xFF212224),
                ),
              ),
            ),
          ],
        ),
      ),
      // ---------- Table Rows (same width alignment) ----------
      pointsHistory.isNotEmpty
          ? Column(
              children: pointsHistory.map((history) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD9D9D9), width: 0.49),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            history['date'] ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            history['description'] ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            history['referenceNo'] ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            history['earned'] != null
                                ? "+${history['earned']}"
                                : "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            history['redeemed'] != null
                                ? "-${history['redeemed']}"
                                : "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            history['total']?.toString() ?? "-",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Sofia Pro',
                              fontSize: 6,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No card statement history available.",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
    ],
  );
}

Widget currentBalance(
  BuildContext context,
  int loyaltyPoints,
  int referralPoints,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Crrunt Balance",
        style: TextStyle(
          fontFamily: "DM Sans",
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.bodyFont(context),
          color: Color(0xFF6D6D6D),
        ),
      ),
      SizedBox(height: 6),
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(width: 104, height: 2.4, color: Color(0xFF004C90)),

            Expanded(child: Container(height: 1, color: Color(0xFFBDBDBD))),
          ],
        ),
      ),
      SizedBox(height: 16),
      SingleChildScrollView(
        child: Column(
          children: [
            crruntBalCard(
              context,
              balance: loyaltyPoints.toString(),
              point: "Loyalty Points",
              redeemNow: () {},
            ),
            SizedBox(height: 12),
            crruntBalCard(
              context,
              balance: referralPoints.toString(),
              point: "Referal Points",
              redeemNow: () {},
            ),
          ],
        ),
      ),
    ],
  );
}

Widget crruntBalCard(
  BuildContext context, {
  required String balance,
  required String point,
  required VoidCallback redeemNow,
}) {
  return Container(
    width: 220,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Color(0xFFBFBFBF)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          point,
          style: TextStyle(
            fontFamily: 'Sofia Pro',
            fontWeight: FontWeight.w400,
            fontSize: AppSizes.smallFont(context),
            color: Color(0xFF646363),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          balance,
          style: TextStyle(
            fontFamily: 'Sofia Pro',
            fontSize: AppSizes.mediumFont(context),
            fontWeight: FontWeight.w400,
            color: Color(0xFF000000),
          ),
        ),

        const SizedBox(height: 4),

        GestureDetector(
          onTap: redeemNow,
          child: Row(
            children: [
              Text(
                "Redeem Now",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppSizes.smallFont(context),
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0D80D4),
                  letterSpacing: 0.37,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF0D80D4)),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _loyaltyCard(
  BuildContext context, {
  String? cardNumber,
  String? expiry,
  String? cardHolderName,
  String? cvv,
}) {
  final width = MediaQuery.of(context).size.width;

  double cardWidth;
  if (width < 480) {
    cardWidth = width * 0.8;
  } else if (width < 900) {
    cardWidth = width * 0.5;
  } else {
    cardWidth = width * 0.25;
  }

  return Container(
    width: cardWidth,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        colors: [Color(0xFFEEA16A), Color(0xFF305F98)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ADRBank",
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.mediumFont(context),
          ),
        ),
        const Spacer(),
        if (cardNumber != null)
          Text(
            cardNumber,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              overflow: TextOverflow.ellipsis,
              color: Color(0xFFFFFFFF),
              fontSize: AppSizes.mediumFont(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        if (cardHolderName != null)
          Text(
            cardHolderName,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              overflow: TextOverflow.ellipsis,
              color: Color(0xFFFFFFFF),
              fontSize: AppSizes.mediumFont(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (expiry != null)
              Text(
                "Expiry Date\n$expiry",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.smallFont(context),
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            if (cvv != null)
              Text(
                "CVV\n$cvv",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppSizes.smallFont(context),
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            const Spacer(),
            SvgPicture.asset("assets/icons/MasterCard.svg", width: 38),
          ],
        ),
      ],
    ),
  );
}

Widget inputField({
  required String label,
  required String value,
  int maxLines = 1,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: "Inter",
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A4C8E),
        ),
      ),
      const SizedBox(height: 9),
      TextFormField(
        initialValue: value,
        maxLines: maxLines,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC6C6C6)),
          ),
        ),
      ),
      const SizedBox(height: 18),
    ],
  );
}

void payAndEarnDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.white.withOpacity(0.2),
    builder: (context) {
      return Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(color: Colors.transparent),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),

                  child: Padding(
                    padding: AppSizes.isDesktop(context)
                        ? EdgeInsetsGeometry.symmetric(
                            horizontal: 500,
                            vertical: 50,
                          )
                        : const EdgeInsets.all(22),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 73),
                          SvgPicture.asset('assets/icons/congrats.svg'),
                          const SizedBox(height: 18),

                          Text(
                            'Refer & Start Earning with Arouse Automotive',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: AppSizes.bodyFont(context),
                              color: Color(0xFF1A4C8E),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 11),
                          Text(
                            'Invite your friends to join and earn exciting rewards! Simply share your referral code, and when they sign up, you both get bonus points. The more friends you invite, the more you earn. Start sharing now and enjoy exclusive benefits!',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: AppSizes.smallFont(context),
                              color: Color(0xFF6D6D6D),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          buildBenefitCard(
                            title: 'Benefit Number 1',
                            subtitle:
                                'A very long description of the benefit that attracts customer',
                          ),
                          const SizedBox(height: 12),
                          buildBenefitCard(
                            title: 'Benefit Number 2',
                            subtitle:
                                'A very long description of the benefit that attracts customer',
                          ),
                          const SizedBox(height: 12),
                          buildBenefitCard(
                            title: 'Benefit Number 3',
                            subtitle:
                                'A very long description of the benefit that attracts customer',
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004C90),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(42),
                                ),
                              ),
                              child: const Text(
                                'Pay 449 & Start Earning Now!',
                                style: TextStyle(
                                  fontFamily: "DM Sans",
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF004C90),
                                  width: 1.4,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(42),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.play_circle_outline,
                                    size: 18,
                                    color: Color(0xFF004C90),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Watch Video',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF004C90),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget buildBenefitCard({required String title, required String subtitle}) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFFFFFFFF),
      border: Border.all(color: Color(0xFFDADADA), width: 0.49),
      borderRadius: BorderRadius.circular(5),
      boxShadow: [BoxShadow(color: Colors.grey.shade100)],
    ),
    child: ListTile(
      leading: SvgPicture.asset('assets/icons/booking_car.svg'),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: Color(0xFF1F384C),
          letterSpacing: 0.33,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w400,
          fontSize: 9,
          color: Color(0xFF3E3E3E),
        ),
      ),
    ),
  );
}

void enqueryStatusDialog(
  BuildContext context, {
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
}) {
  showDialog(
    context: context,
    builder: (context) {
      String? selectedValue = value; // 🔑 local dialog state

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Check Enquiry Status",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 21,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Select Month",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF6D6D6D),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // UNDERLINE
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
                            child: Container(
                              height: 2,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // DROPDOWN
                    DropdownButtonFormField<String>(
                      value: selectedValue,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFFD9D9D9),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFF1A4C8E),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      hint: const Text(
                        "Select",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      items: items
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontFamily: "Sofia Pro",
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF212224),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedValue = val; // ✅ update dialog
                        });
                        onChanged(val); // optional parent update
                      },
                    ),

                    const SizedBox(height: 17),

                    // DOWNLOAD BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (selectedValue == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select a month"),
                              ),
                            );
                            return;
                          }

                          final parsed = parseMonthYear(selectedValue!);

                          try {
                            await ReferAndEarnApi.downloadEnquiryReport(
                              month: parsed["month"]!,
                              year: parsed["year"]!,
                            );

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Report downloaded successfully"),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "No enquiries available for this period",
                                ),
                              ),
                            );
                          }
                        },
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
                          "Download Report",
                          style: TextStyle(
                            fontFamily: "DM Sans",
                            fontSize: 14,
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
    },
  );
}

Map<String, int> parseMonthYear(String value) {
  final parts = value.split(" ");
  final monthName = parts[0];
  final year = int.parse(parts[1]);

  const months = {
    "January": 1,
    "February": 2,
    "March": 3,
    "April": 4,
    "May": 5,
    "June": 6,
    "July": 7,
    "August": 8,
    "September": 9,
    "October": 10,
    "November": 11,
    "December": 12,
  };

  return {"month": months[monthName]!, "year": year};
}
