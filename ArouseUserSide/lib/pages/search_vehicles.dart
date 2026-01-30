import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend/pages/vehicle_info_page.dart';
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
      appBar: CAppbar(screenName: widget.query),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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

            return GridView.builder(
              itemCount: vehicleList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final vehicle = vehicleList[index];

                return VehicleCardGrid(
                  vehicle: vehicle,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleInfoPage(
                        selectedTab: 0,
                        carId: vehicle['_id'],
                      ),
                    ),
                  ),
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

  /// Convert backend binary → Uint8List
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
    print(vehicle);

    Uint8List? imageBytes = getImageBytes(
      (vehicle["images"] != null && vehicle["images"].isNotEmpty)
          ? vehicle["images"][0]
          : null,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDFDFDF)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle['name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "₹ ${vehicle['price']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D80D4),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    children: [
                      const Icon(Icons.local_gas_station, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        vehicle["fuelType"] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.settings, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        vehicle["transmission"] ?? '',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
