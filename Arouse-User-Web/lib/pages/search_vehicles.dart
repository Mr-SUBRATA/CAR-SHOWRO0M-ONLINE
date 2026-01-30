import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend_web/api/compare_car_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/compare_car.dart';
import 'package:arouse_ecommerce_frontend_web/pages/vehicle_view_info.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';

class SearchedVehicles extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> vehicles;
  final String query;

  const SearchedVehicles({
    super.key,
    required this.vehicles,
    required this.query,
  });

  @override
  State<SearchedVehicles> createState() => _SearchedVehiclesState();
}

class _SearchedVehiclesState extends State<SearchedVehicles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: widget.vehicles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No vehicles found'));
            }

            final vehicleList = snapshot.data!;

            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;

                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth < 500) {
                  crossAxisCount = 2;
                }
                final width = MediaQuery.of(context).size.width;

                double aspectRatio;

                if (width < 360) {
                  aspectRatio = 0.45; // very small phones
                } else if (width < 480) {
                  aspectRatio = 0.52; // small phones
                } else if (width < 640) {
                  aspectRatio = 0.70; // normal phones
                } else if (width < 840) {
                  aspectRatio = 0.8; // large phones / small tablets
                } else if (width < 1100) {
                  aspectRatio = 0.8; // tablets / small laptop
                } else if (width < 1400) {
                  aspectRatio = 0.8; // desktop
                } else {
                  aspectRatio = 0.9; // large desktop / wide display
                }

                return GridView.builder(
                  itemCount: vehicleList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final vehicle = vehicleList[index];

                    return VehicleCardGrid(
                      vehicle: vehicle,
                      onTap: () {
                        //print(vehicle['_id']);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VehicleViewInfo(
                              carId: vehicle['_id'],
                              selectedTab: 0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class VehicleCardGrid extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const VehicleCardGrid({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  Uint8List? getImageBytes(dynamic imageData) {
    try {
      if (imageData != null &&
          imageData["data"] != null &&
          imageData["data"]["data"] != null) {
        return Uint8List.fromList(List<int>.from(imageData["data"]["data"]));
      }
    } catch (e) {
      print("Image parse error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? imageBytes = getImageBytes(
      (vehicle["images"] != null && vehicle["images"].isNotEmpty)
          ? vehicle["images"][0]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Color(0xFFE2E2E2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,

          children: [
            // Car Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: imageBytes != null
                        ? Image.memory(
                            imageBytes,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                  ),
                ),

                // Featured Ribbon (if exists)
                if (vehicle["isFeatured"] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "FEATURED",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,

                children: [
                  // Car Name
                  Text(
                    vehicle['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppSizes.smallFont(context),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    "₹ ${vehicle['price']}",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D80D4),
                      fontSize: AppSizes.smallFont(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Specs Chips Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int chipsPerRow = AppSizes.screenWidth(context) < 600
                          ? 2
                          : 3; // << responsive chips

                      double chipWidth =
                          (constraints.maxWidth - 12) / chipsPerRow;

                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _specChip(
                            context,
                            Icons.local_gas_station,
                            vehicle["fuelType"] ?? "Fuel",
                          ),
                          _specChip(
                            context,
                            Icons.settings,
                            vehicle["transmission"] ?? "Automatic",
                          ),
                          if (vehicle["type"] != null)
                            _specChip(
                              context,
                              Icons.car_crash,
                              vehicle["type"],
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 220,
                    maxWidth: AppSizes.screenWidth(context) < 480
                        ? AppSizes.screenWidth(context) * 0.9
                        : AppSizes.screenWidth(context) < 900
                        ? 320
                        : 380,
                    minHeight: AppSizes.screenWidth(context) < 600 ? 44 : 52,
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      List<dynamic> carList = await CompareCarApi.addToCompare(
                        vehicle['_id'],
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CompareCar(selectedCarsFromPrev: carList),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004C90),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Add to Compare',
                      style: TextStyle(
                        fontFamily: "DM Sans",
                        fontSize: AppSizes.buttonFont(context),
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: AppSizes.smallFont(context))),
        ],
      ),
    );
  }
}
