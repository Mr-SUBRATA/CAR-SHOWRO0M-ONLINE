import 'package:arouse_ecommerce_frontend_web/api/contact_us_api.dart';
import 'package:arouse_ecommerce_frontend_web/api/profile_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_colors.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';

class HelpAndSupport extends StatefulWidget {
  const HelpAndSupport({super.key});

  @override
  State<HelpAndSupport> createState() => _HelpAndSupportState();
}

class _HelpAndSupportState extends State<HelpAndSupport> {
  final List<String> menuItems = [
    "FAQ's",
    "Contact Us",
    "Terms & Conditions",
    "Privacy Policy",
    "Refund Policy",
  ];

  @override
  initState() {
    super.initState();
    getUserDetails();
  }

  int selectedIndex = 0;
  String? selectedSubject = "Loyalty Card";
  Map<String, dynamic>? user;

  TextEditingController message = TextEditingController();

  void getUserDetails() async {
    var userData = await ProfileApi().getCurrentUser();
    setState(() {
      user = userData;
    });
  }

  void submitContactForm() async {
    await ContactUsApi().contactUs(
      context,
      name: user!['name'],
      email: user!['email'],
      subject: selectedSubject!,
      message: message.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  child: AppSizes.isDesktop(context)
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftPanel(context),
                            const SizedBox(width: 40),
                            Expanded(child: _buildRightPanel()),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLeftPanel(context),
                            const SizedBox(height: 20),
                            _buildRightPanel(),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// LEFT PANEL
  Widget _buildLeftPanel(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(menuItems.length, (index) {
          final bool isSelected = index == selectedIndex;

          return InkWell(
            onTap: () => setState(() => selectedIndex = index),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: isSelected ? AppColors.buttoColor : Colors.black54,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      menuItems[index],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.buttoColor
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// RIGHT PANEL WRAPPER
  Widget _buildRightPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      // 🔥 Important part
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _getRightSectionContent(),
      ),
    );
  }

  /// DYNAMIC CONTENT
  Widget _getRightSectionContent() {
    switch (selectedIndex) {
      case 0:
        return _faqSection();
      case 1:
        return _contactUsSection();
      case 2:
        return _termsSection();
      case 3:
        return _privacySection();
      case 4:
        return _refundSection();
      default:
        return const SizedBox();
    }
  }

  // -----------------------------
  // CONTACT US SECTION (UPDATED)
  // -----------------------------
  Widget _contactUsSection() {
    final List<String> subjects = [
      "Loyalty Card",
      "Test Drive",
      "General Enquiry",
      "Vehicle Booking",
      "Complaint",
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Get in touch with us"),
            const SizedBox(height: 8),

            const Text(
              "Lorem ipsum dolor sit amet consectetur. Posuere sed odio elementum nunc volutpat egestas nunc ridiculus leo. "
              "Proin cras aenean eget sapien.",
              style: TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 22),

            /// PHONE + EMAIL
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                _contactIconTile(icon: Icons.phone, text: "+91 91117 94447"),
                _contactIconTile(
                  icon: Icons.email_outlined,
                  text: "info@arouseindia.com",
                ),
              ],
            ),

            const SizedBox(height: 22),

            /// SUBJECT DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSubject,
                  items: subjects
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedSubject = value!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// MESSAGE LABEL
            const Text(
              "Message",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            /// MESSAGE BOX
            Container(
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: message,
                maxLines: 6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Write your message here...",
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// SEND BUTTON RESPONSIVE WIDTH
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: GestureDetector(
                  onTap: () {
                    if (user == null) return;

                    if (message.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Message cannot be empty"),
                        ),
                      );
                      return;
                    }

                    if (selectedSubject == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a subject"),
                        ),
                      );
                      return;
                    }

                    // optional loader
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    submitContactForm();

                    Navigator.pop(context); // close loader

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Message sent successfully"),
                      ),
                    );

                    message.clear();
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.buttoColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  /// BLUE ROUND ICON STYLE (UPDATED)
  Widget _contactIconTile({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.buttoColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  //------------------ other sections ------------------

  Widget _faqSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title("FAQ's"),
      const SizedBox(height: 16),
      _question("Lorem ipsum dolor sit amet consectetur ?"),
      const SizedBox(height: 10),
      _paragraph(),
    ],
  );

  Widget _termsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title("Terms & Conditions"),
      const SizedBox(height: 12),
      _paragraph(),
    ],
  );

  Widget _privacySection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title("Privacy Policy"),
      const SizedBox(height: 12),
      _paragraph(),
    ],
  );

  Widget _refundSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _title("Refund Policy"),
      const SizedBox(height: 12),
      _paragraph(),
    ],
  );

  /// REUSABLE UI
  Widget _title(String t) => Text(
    t,
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  );

  Widget _question(String t) => Text(
    t,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );

  Widget _paragraph() => const Text(
    "Lorem ipsum dolor sit amet consectetur. Posuere sed odio elementum nunc volutpat egestas nunc ridiculus leo. "
    "Proin cras aenean eget sapien.",
    textAlign: TextAlign.justify,
  );
}
