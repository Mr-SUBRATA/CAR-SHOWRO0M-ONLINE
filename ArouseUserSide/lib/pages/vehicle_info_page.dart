import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend/api/Vehicles/vehicle_info_api.dart';
import 'package:arouse_ecommerce_frontend/api/Vehicles/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/vehicle_info/C_vehicle_AppBar.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_brochure.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_feature.dart';
import 'package:arouse_ecommerce_frontend/components/Vehicle_info/vehicle_info_specification.dart';
import 'package:arouse_ecommerce_frontend/components/emi_calculator/Emi_Calculator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class VehicleInfoPage extends StatefulWidget {
  final String carId;
  final int selectedTab;
  const VehicleInfoPage({
    super.key,
    required this.selectedTab,
    required this.carId,
  });

  @override
  State<VehicleInfoPage> createState() => _VehicleInfoPageState();
}

class _VehicleInfoPageState extends State<VehicleInfoPage> {
  Map<String, dynamic>? car;
  Map<String, dynamic>? onRoadPrice;
  Map<String, dynamic>? selectedModel;
  List<Map<String, dynamic>>? allCars;
  String selectedCity = "saharanpur";
  List<String> cities = [];
  final Map<String, Color> colorNameMap = {
    'red': Colors.red,
    'blue': Colors.blue,
    'black': Colors.black,
    'white': Colors.white,
    'silver': Colors.grey,
    'grey': Colors.grey,
    'gray': Colors.grey,
    'yellow': Colors.yellow,
    'green': Colors.green,
    'orange': Colors.orange,
    'brown': Colors.brown,
  };

  List<Map<String, dynamic>> colorList = [];
  String? selectedColorName;
  Color selectedColor = Colors.transparent;

  double? downPayment; // 20% default
  double? loanAmount;
  Map<String, dynamic>? montlyEMI;

  @override
  void initState() {
    super.initState();
    getCar();
    getRtoPrice(selectedCity, widget.carId);
  }

  void getCar() async {
    var cars = await VehiclesApi.getAllCars();
    var carData = await VehicleInfoApi.getCarInfo(widget.carId);
    var carOnRoadPrice = await VehicleInfoApi.getOnRoadPrice(
      widget.carId,
      selectedCity,
    );
    final apiColors = List<String>.from(carData!['colors'] ?? []);
    final convertedColors = apiColors.map((name) {
      final key = name.toLowerCase().trim();
      return {
        "name": name,
        "color": colorNameMap[key] ?? Colors.grey, // fallback
      };
    }).toList();
    var city = await VehicleInfoApi().fetchRtoCities();
    downPayment = carData['price'] * 0.2;
    loanAmount = carData['price'] - downPayment;
    var emi = await VehicleInfoApi.calculateEMI(
      loanAmount.toString(),
      "9",
      "60",
    );
    // print(emi);
    setState(() {
      cities = city;
      selectedCity = cities[0];
      allCars = cars;
      onRoadPrice = carOnRoadPrice;
      car = carData;
      selectedModel = car!['modelName'];
      montlyEMI = emi;
      colorList = convertedColors;
      selectedColorName = colorList.isNotEmpty ? colorList.first['name'] : null;
      selectedColor = colorList.isNotEmpty
          ? colorList.first['color']
          : Colors.transparent;
    });

    // print(allCars);
    // print(carOnRoadPrice);
  }

  void getRtoPrice(String selectedCity, String carId) async {
    var carOnRoadPrice = await VehicleInfoApi.getOnRoadPrice(
      carId,
      selectedCity,
    );
    if (carOnRoadPrice != null) {
      setState(() {
        onRoadPrice = carOnRoadPrice;
      });
    }

    // print(allCars);
    // print(carOnRoadPrice);
  }

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int currentIndex = 0;
  int selectedTab = 0;

  final List<String> tabs = [
    "Available varients",
    "Features",
    "Safety",
    "Specification",
    "Brochure",
  ];

  // Convert backend binary → Uint8List
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CVehicleAppbar(),
      body: (car == null || onRoadPrice == null)
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 55,
                        width: screenWidth,
                        child: Image.asset(
                          'assets/carbackground.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 18,
                        left: screenWidth * 0.3,
                        child: Text(
                          'Find Your Perfect Car',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      car!['name'],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        letterSpacing: 1.94,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModelChangeDialog(
                        context,
                        carList: allCars!.toList(),
                        onModelSelected: (selectedCar) async {
                          // get car full data
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleInfoPage(
                                selectedTab: 0,
                                carId: selectedCar['_id'],
                              ),
                            ),
                            (route) => false, // remove all previous pages
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Change Model',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D80D4),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      CarouselSlider(
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          viewportFraction: 1.0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                        ),
                        items: car!['images'].map<Widget>((img) {
                          return Image.memory(
                            getImageBytes(img)!,
                            fit: BoxFit.contain,
                          );
                        }).toList(),
                      ),
                      Positioned(
                        top: 10,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {},
                          child: SvgPicture.asset('assets/icons/360_view.svg'),
                        ),
                      ),
                      // LEFT BUTTON
                      Positioned(
                        left: 5,
                        top: 80,
                        child: GestureDetector(
                          onTap: () {
                            _carouselController.previousPage();
                          },
                          child: Container(
                            width: 26,
                            height: 41,
                            decoration: BoxDecoration(
                              color: Color(0xFF1A4C8E),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // RIGHT BUTTON
                      Positioned(
                        right: 5,
                        top: 80,
                        child: GestureDetector(
                          onTap: () {
                            _carouselController.nextPage();
                          },
                          child: Container(
                            width: 26,
                            height: 41,
                            decoration: BoxDecoration(
                              color: Color(0xFF1A4C8E),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Starting from Rs. ${onRoadPrice!['onRoadPrice']}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1.05,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'On-Road Price, $selectedCity',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF464646),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                showCityChangeDialog(
                                  context,
                                  cityList: cities,
                                  onCitySelected: (city) async {
                                    final newPrice =
                                        await VehicleInfoApi.getOnRoadPrice(
                                          car!['_id'],
                                          city,
                                        );
                                    setState(() {
                                      selectedCity = city;
                                      onRoadPrice = newPrice;
                                    });
                                  },
                                );
                              },
                              child: Text(
                                'Change city',
                                style: TextStyle(
                                  color: Color(0xFF0D80D4),
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Color(0xFF0D80D4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exterior Color',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF3E3E3E),
                                ),
                              ),
                              SizedBox(height: 9),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1F1F1),
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: Color(0xFFDFDFDF)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: (car!['colors'].isEmpty)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          child: Text(
                                            "Colors Not Available",
                                            style: TextStyle(
                                              fontFamily: 'DM Sans',
                                              fontSize: 13,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : DropdownButton<Map<String, dynamic>>(
                                          value: selectedColorName == null
                                              ? null
                                              : colorList.firstWhere(
                                                  (c) =>
                                                      c["name"] ==
                                                      selectedColorName,
                                                ),
                                          hint: Text("Select Color"),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Colors.black,
                                          ),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() {
                                              selectedColorName = value["name"];
                                              selectedColor = value["color"];
                                            });
                                          },

                                          items: colorList.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 23,
                                                    height: 23,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          item["color"], // must be Color type
                                                      border: Border.all(
                                                        color: Colors.black12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text(
                                                    item["name"],
                                                    style: TextStyle(
                                                      fontFamily: 'DM Sans',
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.2),
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_list_alt,
                                color: Color(0xFF0D80D4),
                                size: 18,
                              ),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.61,
                                  color: Color(0xFF0D80D4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        children: List.generate(tabs.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: CScrolableButton(
                              label: tabs[index],
                              isSelected: selectedTab == index,
                              onTap: () {
                                setState(() => selectedTab = index);

                                if (index == 0) {
                                  // Features
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VehicleInfoPage(
                                        selectedTab: 0,
                                        carId: car!['_id'],
                                      ),
                                    ),
                                  );
                                } else if (index == 1) {
                                  // Features
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VehicleInfoFeature(
                                        carData: car ?? {},
                                        selectedTab: 1,
                                      ),
                                    ),
                                  );
                                } else if (index == 2) {
                                  //Safety
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ,));
                                } else if (index == 3) {
                                  // Specifications
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VehicleInfoSpecification(
                                        selectedTab: 3,
                                        carData: car ?? {},
                                      ),
                                    ),
                                  );
                                } else if (index == 4) {
                                  // Brouchure
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VehicleInfoBrochure(
                                        selectedTab: 4,
                                        carData: car ?? {},
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 28),
                  car!['variants'].isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Variants Not Available",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                            ),
                            child: Row(
                              children: [
                                for (var v in car!['variants'])
                                  carPriceCard(
                                    title: v["name"] ?? "Unknown Variant",
                                    exShowroom: "₹${v["price"] ?? 0}",
                                    onRoad: "₹${(v["price"] ?? 0)}",
                                    onViewBreakup: () {},
                                  ),
                              ],
                            ),
                          ),
                        ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View varients',
                            style: const TextStyle(
                              fontFamily: "DM Sans",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0D80D4),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF0D80D4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          var res = await VehiclesApi().createBooking(
                            bookingDate: DateTime.now().toIso8601String(),
                            vehicleId: car!['_id'],
                            amountPaid: downPayment ?? 0,
                            branch: selectedCity,
                          );

                          SnackBar snackBar = SnackBar(
                            content: Text(
                              res['message'] ?? "Booking successful!",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004C90),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/book_online.svg",
                              width: 15,
                              height: 15,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Book Online',
                              style: const TextStyle(
                                fontFamily: "DM Sans",
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: const Text(
                      "Vehicle Info",
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF3E3E3E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        vehicleInfoItem(
                          icon: Icons.settings,
                          label: "Engine Type",
                          value: car!['engineType'] ?? " N/A",
                        ),
                        vehicleInfoItem(
                          icon: Icons.speed,
                          label: "Displacement (cc)",
                          value: car!['displacement'] ?? " N/A",
                        ),
                        vehicleInfoItem(
                          icon: Icons.bolt,
                          label: "Max. Power (ps/rpm)",
                          value: car!['maxPower'] ?? " N/A",
                        ),
                        vehicleInfoItem(
                          icon: Icons.flash_on,
                          label: "Max. Torque (kgm/rpm)",
                          value: car!['maxTorque'] ?? " N/A",
                        ),
                        vehicleInfoItem(
                          icon: Icons.local_gas_station,
                          label: "Fuel Type",
                          value: car!['fuelType'],
                        ),
                        vehicleInfoItem(
                          icon: Icons.settings_applications,
                          label: "Transmission Type",
                          value: car!['transmission'],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Text(
                      'EMI Options for the selected model',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      children: [
                        Text(
                          'Rs. ${(montlyEMI!['emi'] ?? 0).toStringAsFixed(0)} EMI For 5 Years',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmiCalculator(emiFiveYears: montlyEMI),
                              ),
                            );
                          },
                          child: Text(
                            'EMI Calculator',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF0D80D4),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Color(0xFF0D80D4),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
    );
  }
}

Widget vehicleInfoItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    children: [
      CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, size: 20),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
            ),
          ],
        ),
      ),
    ],
  );
}

Widget carPriceCard({
  required String title,
  required String exShowroom,
  required String onRoad,
  required VoidCallback onViewBreakup,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF3E3E3E),
          ),
        ),

        const SizedBox(height: 4),

        // Prices
        Text(
          "*Ex showroom price - Rs. $exShowroom",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: Color(0xFF8E8E8E),
          ),
        ),
        Text(
          "*On-road price - Rs. $onRoad",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF295800),
          ),
        ),

        const SizedBox(height: 4),

        // View price breakup
        GestureDetector(
          onTap: onViewBreakup,
          child: Text(
            "View price breakup",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF0D80D4),
              letterSpacing: 0.49,
            ),
          ),
        ),
      ],
    ),
  );
}

void showCityChangeDialog(
  BuildContext context, {
  required List<String> cityList,
  required Function(String selectedCity) onCitySelected,
}) {
  TextEditingController searchController = TextEditingController();
  List<String> filteredCities = cityList;
  String? selectedCity;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Select City",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),

                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search City",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredCities = cityList
                          .where(
                            (city) => city.toLowerCase().contains(
                              value.toLowerCase(),
                            ),
                          )
                          .toList();
                    });
                  },
                ),
                SizedBox(height: 15),

                SizedBox(
                  height: 280,
                  child: ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      return RadioListTile(
                        title: Text(city),
                        value: city,
                        groupValue: selectedCity,
                        onChanged: (val) {
                          setState(() => selectedCity = val);
                        },
                      );
                    },
                  ),
                ),

                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedCity == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          onCitySelected(selectedCity!);
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 45),
                  ),
                  child: Text("Apply"),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void showModelChangeDialog(
  BuildContext context, {
  required List<Map<String, dynamic>> carList,
  required Function(Map<String, dynamic> selectedCar) onModelSelected,
}) {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> filteredCars = carList;
  Map<String, dynamic>? selectedCar;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Model",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 15),

                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search Model",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCars = carList
                            .where(
                              (car) => car["name"].toLowerCase().contains(
                                value.toLowerCase(),
                              ),
                            )
                            .toList();
                      });
                    },
                  ),

                  SizedBox(height: 15),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: filteredCars.length,
                      itemBuilder: (context, index) {
                        final car = filteredCars[index];
                        return RadioListTile(
                          title: Text(car["name"]),
                          subtitle: Text(car["type"] ?? ""),
                          value: car,
                          groupValue: selectedCar,
                          onChanged: (val) {
                            setState(() => selectedCar = val);
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: selectedCar == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            onModelSelected(selectedCar!);
                          },
                    child: Text("Apply"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
