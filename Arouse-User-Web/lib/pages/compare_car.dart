import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/footer_section.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/test_drive_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/widgets/car_selector_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

class CompareCar extends StatefulWidget {
  final List<dynamic> selectedCarsFromPrev;

  const CompareCar({super.key, required this.selectedCarsFromPrev});

  @override
  State<CompareCar> createState() => _CompareCarState();
}

class _CompareCarState extends State<CompareCar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const int MAX_CARS = 4; // Maximum cars for comparison
  
  List<String> selectedCarIds = [];
  List<Map<String, dynamic>> selectedCars = [];
  // Store selected variant info for each car (null if no variant selected)
  List<Map<String, dynamic>?> selectedVariants = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    selectedCarIds = widget.selectedCarsFromPrev.cast<String>();

    loadSelectedCars();
  }

  Future<void> loadSelectedCars() async {
    List<Map<String, dynamic>> temp = [];
    List<Map<String, dynamic>?> tempVariants = [];

    for (final id in selectedCarIds) {
      final car = await VehiclesApi.getCarInfo(id);
      if (car != null) {
        temp.add(car);
        tempVariants.add(null);
      }
    }

    setState(() {
      selectedCars = temp;
      selectedVariants = tempVariants;
      isLoading = false;
    });
  }

  void addCar(Map<String, dynamic> car, Map<String, dynamic>? variant) {
    if (selectedCarIds.length >= MAX_CARS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum $MAX_CARS cars can be compared')),
      );
      return;
    }

    // Create a unique key for car+variant combination
    final carId = car["_id"];
    final variantName = variant?["name"];
    final uniqueKey = variantName != null ? '$carId-$variantName' : carId;

    if (!selectedCarIds.contains(uniqueKey)) {
      setState(() {
        selectedCarIds.add(uniqueKey);
        selectedCars.add(car);
        selectedVariants.add(variant);
      });
    }
  }

  void removeCar(int index) {
    setState(() {
      selectedCarIds.removeAt(index);
      selectedCars.removeAt(index);
      selectedVariants.removeAt(index);
    });
  }

  void openCarPicker() {
    showDialog(
      context: context,
      builder: (context) => CarSelectorDialog(
        alreadySelectedIds: selectedCarIds,
        onCarSelected: (car, variant) {
          addCar(car, variant);
        },
      ),
    );
  }

  String _getDisplayName(int index) {
    final car = selectedCars[index];
    final variant = selectedVariants[index];
    if (variant != null) {
      return '${car["name"]} ${variant["name"]}';
    }
    return car["name"] ?? '';
  }

  String _getDisplayPrice(int index) {
    final car = selectedCars[index];
    final variant = selectedVariants[index];
    final price = variant?["price"] ?? car["price"];
    return price != null ? '₹$price Onwards' : 'Price N/A';
  }

  Map<String, dynamic> _getSpecs(int index) {
    final car = selectedCars[index];
    final variant = selectedVariants[index];
    // Prefer variant specs, fallback to car specs
    return variant?["specifications"] ?? car["specifications"] ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CAppbar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 768;
          final isTablet =
              constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCompareTitle(),
                        style: TextStyle(
                          fontSize: AppSizes.mediumFont(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Compare specifications, features, and prices of cars",
                        style: TextStyle(
                          fontSize: AppSizes.smallFont(context),
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildCarGrid(isMobile, isTablet),
                ),
                const SizedBox(height: 40),
                if (selectedCars.length >= 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: isMobile ? _accordionView() : _tabView(),
                  ),
                const SizedBox(height: 60),
                const FooterSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCompareTitle() {
    if (selectedCars.length < 2) return "Compare Cars";
    if (selectedCars.length == 2) {
      return "${_getDisplayName(0)} vs ${_getDisplayName(1)}";
    }
    return "Comparing ${selectedCars.length} Cars";
  }

  Widget _buildCarGrid(bool isMobile, bool isTablet) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < selectedCars.length; i++) ...[
            if (i > 0) _vsBadge(),
            _carCard(isMobile, isTablet, i),
          ],
          if (selectedCars.length < MAX_CARS) ...[
            if (selectedCars.isNotEmpty) _vsBadge(),
            _addCarCard(isMobile),
          ],
        ],
      ),
    );
  }

  Widget _carCard(bool isMobile, bool isTablet, int index) {
    final car = selectedCars[index];
    final variant = selectedVariants[index];

    double maxWidth = isMobile
        ? 280
        : isTablet
            ? 320
            : 280;

    Uint8List? imageBytes;
    
    // Try variant images first, then car images
    if (variant != null && variant["images"] != null && variant["images"].isNotEmpty) {
      imageBytes = getImageBytes(variant["images"][0]);
    }
    if (imageBytes == null && car["images"] != null && car["images"].isNotEmpty) {
      imageBytes = getImageBytes(car["images"][0]);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E2E2)),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageBytes != null
                        ? Image.memory(imageBytes, fit: BoxFit.cover)
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.directions_car, size: 50),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getDisplayName(index),
                  style: TextStyle(
                    fontSize: AppSizes.bodyFont(context),
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DM Sans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  car["engine"] ?? "",
                  style: TextStyle(
                    fontSize: AppSizes.smallFont(context),
                    fontWeight: FontWeight.w400,
                    fontFamily: 'DM Sans',
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.local_gas_station, size: 20),
                        Text(
                          variant?["fuelType"] ?? car["fuelType"] ?? "",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        const Icon(Icons.settings, size: 20),
                        Text(
                          variant?["transmission"] ?? car["transmission"] ?? "",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _getDisplayPrice(index),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => TestDriveDialog(),
                        );
                      },
                      child: const Text(
                        'Book Test Drive',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: Color(0xFF1A4C8E),
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/icons/arrow_up.svg',
                      color: const Color(0xFF1A4C8E),
                      height: 14,
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () => removeCar(index),
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addCarCard(bool isMobile) {
    return GestureDetector(
      onTap: openCarPicker,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: isMobile ? 260 : 280),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 40, color: Color(0xFF1A4C8E)),
                const SizedBox(height: 10),
                const Text("Add Another Car"),
                Text(
                  "${selectedCars.length}/$MAX_CARS selected",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _vsBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFEDEDED),
        ),
        alignment: Alignment.center,
        child: const Text("VS", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _tabView() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Specifications"),
            Tab(text: "Features"),
            Tab(text: "Brochure"),
            Tab(text: "Colours"),
            Tab(text: "Reviews"),
          ],
        ),
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _tabController,
            children: [
              _specifications(),
              _listCompare("features"),
              const Center(child: Text("Brochure Content")),
              _listCompare("colors"),
              const Center(child: Text("Reviews Content")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accordionView() {
    return Column(
      children: [
        _expansionTile("Specifications", _specifications()),
        _expansionTile("Features", _listCompare("features")),
        _expansionTile("Colours", _listCompare("colors")),
      ],
    );
  }

  Widget _specifications() {
    if (selectedCars.length < 2) {
      return const Center(child: Text("Select at least two cars to compare"));
    }

    String joinList(dynamic value) {
      if (value == null) return "-";
      if (value is List) return value.join("\n");
      return value.toString();
    }

    final specKeys = ["overview", "dimension", "wheels", "technology", "performance"];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF7F7F7)),
          columns: [
            const DataColumn(label: Text('Spec', style: TextStyle(fontWeight: FontWeight.bold))),
            ...List.generate(
              selectedCars.length,
              (i) => DataColumn(
                label: Text(
                  _getDisplayName(i),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          rows: specKeys.map((key) {
            return DataRow(
              cells: [
                DataCell(Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600))),
                ...List.generate(selectedCars.length, (i) {
                  final specs = _getSpecs(i);
                  return DataCell(
                    Text(
                      joinList(specs[key]),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _listCompare(String key) {
    if (selectedCars.length < 2) {
      return const Center(child: Text("Select at least two cars"));
    }

    // Get all unique values across all cars
    final allValues = <String>{};
    for (int i = 0; i < selectedCars.length; i++) {
      final car = selectedCars[i];
      final variant = selectedVariants[i];
      final list = variant?[key] ?? car[key];
      if (list is List) {
        allValues.addAll(list.map((e) => e.toString()));
      }
    }

    if (allValues.isEmpty) {
      return Center(child: Text("No $key available"));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(const Color(0xFFF7F7F7)),
        columns: [
          DataColumn(label: Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))),
          ...List.generate(
            selectedCars.length,
            (i) => DataColumn(
              label: Text(
                _getDisplayName(i),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
        rows: allValues.map((value) {
          return DataRow(
            cells: [
              DataCell(Text(value)),
              ...List.generate(selectedCars.length, (i) {
                final car = selectedCars[i];
                final variant = selectedVariants[i];
                final list = variant?[key] ?? car[key];
                final has = list is List && list.contains(value);
                return DataCell(
                  Icon(
                    has ? Icons.check_circle : Icons.cancel,
                    color: has ? Colors.green : Colors.red.shade300,
                    size: 20,
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _expansionTile(String title, Widget child) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [Padding(padding: const EdgeInsets.all(12), child: child)],
    );
  }
}
