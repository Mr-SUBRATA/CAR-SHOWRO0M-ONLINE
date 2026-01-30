import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BookingDetails extends StatelessWidget {
  final Map<String, dynamic> booking;
  const BookingDetails({super.key, required this.booking});

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
            /// Header
            Container(
              padding: AppSizes.screenWidth(context) < 480
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                  : AppSizes.screenWidth(context) < 900
                  ? const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
                  : const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
              width: AppSizes.screenWidth(context),
              decoration: const BoxDecoration(color: Color(0xFF1A4C8E)),
              child: Text(
                'Booking Id: ${booking["bookingId"]}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.titleFont(context),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 26),

            /// MAIN LAYOUT
            LayoutBuilder(
              builder: (_, constraints) {
                final isSmall = constraints.maxWidth < 1080;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: isSmall
                      ? Column(
                          children: [
                            leftPanel(context, booking),
                            const SizedBox(height: 26),
                            RightPanel(booking: booking),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: leftPanel(context, booking),
                            ),
                            const SizedBox(width: 26),
                            Expanded(
                              flex: 4,
                              child: RightPanel(booking: booking),
                            ),
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

  /// LEFT PANEL
  Widget leftPanel(BuildContext context, final Map<String, dynamic> booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E2E2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Image.asset(
                  "assets/redCar.png",
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: AppSizes.screenHeight(context) * 0.4,
                ),
                Positioned(
                  top: AppSizes.screenHeight(context) * 0.25,
                  left: AppSizes.screenWidth(context) * 0.25,
                  child: SvgPicture.asset(
                    'assets/icons/360_view.svg',
                    height: AppSizes.iconLarge(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),

        /// Type / Branch / Billing
        infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field(
                context,
                label: "Type",
                value: booking['bookingType'] ?? "",
              ),
              SizedBox(height: 16),
              field(context, label: "Branch", value: booking['branch'] ?? ""),
              SizedBox(height: 16),
              field(
                context,
                label: "Billing Address Details",
                value: "D-62, 1st floor, Kirti Nagar, New Delhi - 110008",
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget field(
  BuildContext context, {
  required String label,
  required String value,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.bodyFont(context),
          color: Color(0xFF6D6D6D),
        ),
      ),
      const SizedBox(height: 14),
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(width: 129, height: 2.4, color: Color(0xFF004C90)),

            Expanded(child: Container(height: 2, color: Color(0xFFBDBDBD))),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Text(
        value,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.smallFont(context),
          color: Color(0xFF1A4C8E),
        ),
      ),
    ],
  );
}

class RightPanel extends StatefulWidget {
  final Map<String, dynamic> booking;
  const RightPanel({super.key, required this.booking});

  @override
  State<RightPanel> createState() => _RightPanelState();
}

class _RightPanelState extends State<RightPanel> {
  Color selectedColor = Colors.red;
  String selectedName = "Red";

  String formateDate(String raw) {
    // Parse to DateTime
    DateTime dt = DateTime.parse(raw);

    // Format as only date (yyyy-MM-dd)
    String formatted =
        "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Booking Status
        infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle("Booking Status", context),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 129,
                      height: 2.4,
                      color: Color(0xFF004C90),
                    ),
                    const SizedBox(height: 14),

                    Expanded(
                      child: Container(height: 2, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              bookingStatus(widget.booking['status'], context),

              const SizedBox(height: 18),
              sectionTitle("Booking Date", context),
              const SizedBox(height: 14),
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
                      child: Container(height: 2, color: Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                formateDate(widget.booking['bookingDate'] ?? ""),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: AppSizes.smallFont(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 26),

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
                      "Hyundai Creta",
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
                    AppSizes.screenWidth(context) > 1150
                        ? Row(
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
                          )
                        : Column(
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
                          "info@arouseindia.com",
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
                    widget.booking['amountPaid'].toString(),
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

Widget bookingStatus(String status, BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 8),
    width: AppSizes.isDesktop(context)
        ? AppSizes.screenWidth(context) * 0.4
        : AppSizes.screenWidth(context),
    decoration: BoxDecoration(
      color: status == "booked" || status == "deliverd"
          ? Color(0xFFC4E3D9)
          : Color(0xFFF9ECD5),
      borderRadius: BorderRadius.circular(27),
    ),
    child: Center(
      child: Text(
        status == "booked"
            ? "Booked"
            : status == "deliverd"
            ? "Deliverd"
            : "pending",
        style: TextStyle(color: Color(0xFF259A4A), fontWeight: FontWeight.w700),
      ),
    ),
  );
}

Widget sectionTitle(String title, BuildContext context) => Text(
  title,
  style: TextStyle(
    fontFamily: 'DM Sans',
    fontSize: AppSizes.bodyFont(context),
    fontWeight: FontWeight.w600,
    color: Color(0xFF6D6D6D),
  ),
);
