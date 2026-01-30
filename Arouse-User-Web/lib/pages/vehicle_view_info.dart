import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend_web/api/compare_car_api.dart';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/components/EMI_calculator/emi_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/booking_cart.dart';
import 'package:arouse_ecommerce_frontend_web/pages/compare_car.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_brochur.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_feature.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_safety.dart';
import 'package:arouse_ecommerce_frontend_web/pages/variant_specifications.dart';
import 'package:arouse_ecommerce_frontend_web/pages/price_breakup.dart';
import 'package:arouse_ecommerce_frontend_web/pages/varient_wise_compare.dart';
import 'package:arouse_ecommerce_frontend_web/utils/app_preferences.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

Uint8List? getImageBytes(dynamic imageData) {
  try {
    final raw = imageData?["data"]?["data"];

    if (raw is List) {
      return Uint8List.fromList(raw.cast<int>());
    }
  } catch (e) {
    debugPrint("Image parse error: $e");
  }
  return null;
}

class VehicleViewInfo extends StatefulWidget {
  final String carId;
  final int selectedTab;
  const VehicleViewInfo({
    super.key,
    required this.carId,
    required this.selectedTab,
  });

  @override
  State<VehicleViewInfo> createState() => _VehicleViewInfoState();
}

class _VehicleViewInfoState extends State<VehicleViewInfo> {
  Map<String, dynamic>? car;
  Map<String, dynamic>? onRoadPrice;
  Map<String, dynamic>? selectedModel;
  List<Map<String, dynamic>>? allCars;
  List<Map<String, dynamic>> similarCars = [];
  bool isLoadingSimilarCars = true;
  List<String> cities = [];

  String selectedCity = "";

  double? downPayment; // 20% default
  double? loanAmount;
  Map<String, dynamic>? montlyEMI;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // First load city
    selectedCity = await AppPreferences.getSelectedCity();

    // Fetch city list from API
    cities = await VehiclesApi().fetchRtoCities();
    setState(() {}); // update UI with city

    // Then call other APIs
    await getCar();
    await getRtoPrice(selectedCity, widget.carId);
    await getSimilarCars();
  }

  void loadCity() async {
    selectedCity = await AppPreferences.getSelectedCity();
    setState(() {});
  }

  void onCitySelected(String city) async {
    await AppPreferences.setSelectedCity(city);

    setState(() {
      selectedCity = city;
    });
  }

  Future<void> getCar() async {
    var cars = await VehiclesApi.getAllCars();
    var carData = await VehiclesApi.getCarInfo(widget.carId);
    var carOnRoadPrice = await VehiclesApi.getOnRoadPrice(
      widget.carId,
      selectedCity,
    );

    if (carData != null) {
      downPayment = carData['price'] * 0.2;
      loanAmount = carData['price'] - downPayment;
      var emi = await VehiclesApi.calculateEMI(
        loanAmount.toString(),
        "9",
        "60",
      );
      // print(emi);
      setState(() {
        allCars = cars;
        onRoadPrice = carOnRoadPrice;
        car = carData;
        selectedModel = car!['modelName'];
        montlyEMI = emi;
      });
    }
    //print(carData);

    // print(allCars);
    // print(carOnRoadPrice);
  }

  Future<void> getRtoPrice(String selectedCity, String carId) async {
    var carOnRoadPrice = await VehiclesApi.getOnRoadPrice(carId, selectedCity);
    onCitySelected(selectedCity);
    if (carOnRoadPrice != null) {
      setState(() {
        onRoadPrice = carOnRoadPrice;
      });
    }

    // print(allCars);
    // print(carOnRoadPrice);
  }

  Future<void> getSimilarCars() async {
    setState(() => isLoadingSimilarCars = true);

    var similar = await VehiclesApi.similarCars(widget.carId);

    setState(() {
      similarCars = similar;
      isLoadingSimilarCars = false;
    });
    // print(similarCars);
  }

  String selectedName = "Red";
  Color selectedColor = Colors.red;
  int selectedTab = 0;

  final List<Map<String, dynamic>> colorList = [
    {"name": "Red", "color": Colors.red},
    {"name": "Blue", "color": Colors.blue},
    {"name": "Black", "color": Colors.black},
    {"name": "White", "color": Colors.white},
  ];
  final List<String> tabs = [
    "Available varients",
    "Features",
    "Safety",
    "Specification",
    "Brochure",
  ];

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: AppSizes.screenHeight(context) * 0.3,
                  width: AppSizes.screenWidth(context),
                  child: Image.asset(
                    'assets/carbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),

                // Overlay gradient optional (keeps text readable)
                Container(
                  height: AppSizes.screenHeight(context) * 0.3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Centered text for all screens
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Find Your Perfect Car',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.isDesktop(context)
                            ? AppSizes.extraLargeFont(context)
                            : AppSizes.titleFont(context),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  tabs.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: CScrolableButton(
                      label: tabs[index],
                      isSelected: selectedTab == index,
                      onTap: () {
                        setState(() {
                          selectedTab = index;
                        });
                        if (index == 0) {
                          // Features
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VehicleViewInfo(
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
                              builder: (_) => VariantFeature(
                                carData: car ?? {},
                                selectedTab: 1,
                              ),
                            ),
                          );
                        } else if (index == 2) {
                          //Safety
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VariantSafety(
                                carData: car ?? {},
                                selectedTab: 2,
                              ),
                            ),
                          );
                        } else if (index == 3) {
                          // Specifications
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VariantSpecifications(
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
                              builder: (_) => VariantBrochur(
                                selectedTab: 4,
                                carData: car ?? {},
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizes.screenHeight(context) * 0.02),
            car == null || onRoadPrice == null
                ? Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: AppSizes.screenWidth(context) > 1200
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: LeftCarSection(
                                  selectedModel: selectedModel,
                                  car: car,
                                  allCars: allCars,
                                ),
                              ),
                              const SizedBox(width: 30),
                              SizedBox(
                                width: AppSizes.screenWidth(context) * 0.4,
                                child: _rightSide(
                                  context,
                                  car,
                                  onRoadPrice,
                                  cities,
                                  selectedCity,
                                  (city) {
                                    getRtoPrice(city, widget.carId);
                                    setState(() {
                                      selectedCity = city;
                                    });
                                  },
                                  montlyEMI,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LeftCarSection(
                                selectedModel: selectedModel,
                                car: car,
                                allCars: allCars,
                              ),
                              const SizedBox(height: 30),
                              _rightSide(
                                context,
                                car,
                                onRoadPrice,
                                cities,
                                selectedCity,
                                (city) {
                                  getRtoPrice(city, widget.carId);
                                  setState(() {
                                    selectedCity = city;
                                  });
                                },
                                montlyEMI,
                              ),
                            ],
                          ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Similar',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: AppSizes.bodyFont(context),
                  color: Color(0xFF6D6D6D),
                ),
              ),
            ),
            SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(width: 10, height: 2, color: Color(0xFFBDBDBD)),
                  Container(width: 129, height: 2.4, color: Color(0xFF004C90)),

                  Expanded(
                    child: Container(height: 2, color: Color(0xFFBDBDBD)),
                  ),
                ],
              ),
            ),
            isLoadingSimilarCars
                ? Center(child: const CircularProgressIndicator())
                : similarCars.isEmpty
                ? Center(child: const Text("No Similar Cars"))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;

                        // number of columns based on available width
                        final crossCount = maxW > 1200
                            ? 4
                            : (maxW > 900 ? 3 : (maxW > 600 ? 2 : 1));

                        // choose a sensible card height based on width (tweak these values to your taste)
                        double cardHeight;
                        if (maxW > 1200) {
                          cardHeight = 360;
                        } else if (maxW > 900) {
                          cardHeight = 360;
                        } else if (maxW > 600) {
                          cardHeight = 380;
                        } else {
                          cardHeight = 420;
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          itemCount: similarCars.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                mainAxisExtent: cardHeight,
                              ),
                          itemBuilder: (context, index) {
                            final c = similarCars[index];
                            return SimilarCarCard(
                              image: c["image"]!,
                              title: c["title"]!,
                              model: c["model"]!,
                              price: c["price"]!,
                              onRoad: c["onRoad"]!,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// LEFT SIDE (Car Image + Specifications)

class LeftCarSection extends StatefulWidget {
  final Map<String, dynamic>? selectedModel;
  final Map<String, dynamic>? car;
  final List<Map<String, dynamic>>? allCars;

  const LeftCarSection({
    super.key,
    required this.selectedModel,
    required this.car,
    required this.allCars,
  });

  @override
  State<LeftCarSection> createState() => _LeftCarSectionState();
}

class _LeftCarSectionState extends State<LeftCarSection> {
  final List<String> images = [
    "assets/redCar.png",
    "assets/redCar.png",
    "assets/redCar.png",
  ];
  String selectedName = "Red";
  Color selectedColor = Colors.red;
  int selectedTab = 0;

  int currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final List<Map<String, dynamic>> colorList = [
    {"name": "Red", "color": Colors.red},
    {"name": "Blue", "color": Colors.blue},
    {"name": "Black", "color": Colors.black},
    {"name": "White", "color": Colors.white},
  ];

  @override
  Widget build(BuildContext context) {
    double imageHeight = AppSizes.isDesktop(context)
        ? 420
        : (AppSizes.isTablet(context) ? 360 : 260);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.car!['name'],
              style: TextStyle(
                fontFamily: "DM Sans",
                fontSize: AppSizes.mediumFont(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {
                showModelChangeDialog(
                  context,
                  carList: widget.allCars!.toList(),
                  onModelSelected: (model) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleViewInfo(
                          selectedTab: 0,
                          carId: model['_id'],
                        ),
                      ),
                      (route) => false, // remove all previous pages
                    );
                  },
                );
              },
              child: Text(
                "Change Model >>",
                style: TextStyle(
                  color: Color(0xFF1A4C8E),
                  fontFamily: 'DM Sans',
                  fontSize: AppSizes.smallFont(context),
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            showBrandChangeDialog(
    	      context,
	      carList: widget.allCars!.toList(),
	      onBrandSelected: (brand) {
	        // Filter cars by brand and show model selector
		final brandCars = widget.allCars!
		    .where((c) => c['brand'] == brand)
		    .toList();
		                  
		showModelChangeDialog(
		  context,
		  carList: brandCars,
		  onModelSelected: (model) {
		    Navigator.pushAndRemoveUntil(
		      context,
		      MaterialPageRoute(
		        builder: (context) => VehicleViewInfo(
                          selectedTab: 0,
                          carId: model['_id'],
                        ),
                      ),
                      (route) => false,
                    );
                  },
                );
              },
            );
          },
          child: Text(
            "Change Brand >>",
            style: TextStyle(
              color: Color(0xFF1A4C8E),
              fontFamily: 'DM Sans',
              fontSize: AppSizes.smallFont(context),
            ),
          ),
        ),
        const SizedBox(height: 10),

        /// CAROUSEL
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CarouselSlider(
                carouselController: _carouselController,
                items: widget.car!['images'].map<Widget>((img) {
                  final bytes = getImageBytes(img);

                  if (bytes == null) {
                    return const Icon(Icons.broken_image, size: 80);
                  }

                  return Image.memory(
                    bytes,
                    height: imageHeight,
                    width: MediaQuery.sizeOf(context).width * 0.6,
                    fit: BoxFit.cover,
                  );
                }).toList(),

                options: CarouselOptions(
                  height: imageHeight,
                  viewportFraction: 1,
                  autoPlay: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),

              /// Left button
              Positioned(
                left: 5,
                child: _arrowBtn(Icons.arrow_back_ios_new, () {
                  _carouselController.previousPage();
                }),
              ),

              /// Right button
              Positioned(
                right: 5,
                child: _arrowBtn(Icons.arrow_forward_ios, () {
                  _carouselController.nextPage();
                }),
              ),

              /// 360 ICON
              Positioned(
                top: 10,
                right: 0,
                child: SvgPicture.asset("assets/icons/360_view.svg"),
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
                        child: DropdownButton<Map<String, dynamic>>(
                          value: colorList.firstWhere(
                            (c) => c["name"] == selectedName,
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.black,
                          ),
                          isExpanded: true,

                          onChanged: (value) {
                            setState(() {
                              selectedName = value!["name"];
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
                                      color: item["color"],

                                      border: Border.all(color: Colors.black12),
                                    ),
                                  ),

                                  SizedBox(width: 12),
                                  Text(
                                    item["name"],
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 13,
                                      letterSpacing: 0.33,
                                      fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Vehicle Info",
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              fontSize: AppSizes.mediumFont(context),
              color: Color(0xFF3E3E3E),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxis = constraints.maxWidth < 600 ? 1 : 2;

              return GridView.count(
                crossAxisCount: crossAxis,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: constraints.maxWidth < 600 ? 4 : 2.6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  vehicleInfoItem(
                    icon: Icons.settings,
                    label: "Engine Type",
                    value: widget.car!['engineType'] ?? "No Engine Type",
                  ),
                  vehicleInfoItem(
                    icon: Icons.speed,
                    label: "Displacement (cc)",
                    value: widget.car!['displacement'] ?? "No Displacement",
                  ),
                  vehicleInfoItem(
                    icon: Icons.bolt,
                    label: "Max. Power (ps/rpm)",
                    value: widget.car!['maxPower'] ?? "No Max Power",
                  ),
                  vehicleInfoItem(
                    icon: Icons.flash_on,
                    label: "Max. Torque (kgm/rpm)",
                    value: widget.car!['maxTorque'] ?? "No Torque",
                  ),
                  vehicleInfoItem(
                    icon: Icons.local_gas_station,
                    label: "Fuel Type",
                    value: widget.car!['fuelType'] ?? "No Fuel Type",
                  ),
                  vehicleInfoItem(
                    icon: Icons.settings_applications,
                    label: "Transmission Type",
                    value: widget.car!['transmission'] ?? "No Transmission",
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget vehicleInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(
                  fontSize: AppSizes.bodyFont(context),
                  color: Colors.grey.shade600,
                  fontFamily: 'DM Sans',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: AppSizes.bodyFont(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1A4C8E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

Widget _rightSide(
  BuildContext context,
  final Map<String, dynamic>? car,
  final Map<String, dynamic>? onRoadPrice,
  List<String>? cities,
  final String selectedCity,
  Function(String city) onCityChanged,
  Map<String, dynamic>? montlyEMI,
) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final bool isMobile = constraints.maxWidth < 700;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E4E4)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Starting Price
            /// Price Range Logic
            Builder(
              builder: (context) {
                if (car!['variants'] == null || car['variants'].isEmpty) {
                  return Text(
                    "Starting from Rs. ${onRoadPrice!['onRoadPrice']}",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: AppSizes.mediumFont(context),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }

                // Calculate Range
                List<dynamic> vars = car['variants'];
                double minP = double.maxFinite;
                double maxP = 0.0;
                
                for(var v in vars) {
                  double p = (v['price'] ?? 0).toDouble();
                  if(p < minP) minP = p;
                  if(p > maxP) maxP = p;
                }
                
                if (maxP == 0) { // Safety check
                   return Text(
                    "Starting from Rs. ${onRoadPrice!['onRoadPrice']}",
                    style: TextStyle(
                      fontFamily: "Inter",
                      fontSize: AppSizes.mediumFont(context),
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }

                return Text(
                  "Rs. ${(minP/100000).toStringAsFixed(2)} - ${(maxP/100000).toStringAsFixed(2)} Lakh",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: AppSizes.mediumFont(context),
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            /// On-Road Price + Change City
            Wrap(
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'On-Road Price, $selectedCity',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF464646),
                    fontSize: AppSizes.smallFont(context),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    showCityChangeDialog(
                      context,
                      cityList: cities ?? [],
                      onCitySelected: (city) {
                        onCityChanged(city);
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change City',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0D80D4),
                          fontSize: AppSizes.smallFont(context),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF0D80D4),
                        size: AppSizes.iconSmall(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Variants Header + Buttons
            Wrap(
              runSpacing: 6,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Variants Available',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3E3E3E),
                    fontSize: AppSizes.smallFont(context),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VariantsWiseCompare(variants: car!['variants'], carName: '${car!['brand']} ${car!['name']}'),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View variant Comparison',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0D80D4),
                          fontSize: AppSizes.smallFont(context),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF0D80D4),
                        size: AppSizes.iconSmall(context),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_alt,
                        color: Color(0xFF0D80D4),
                        size: AppSizes.iconSmall(context),
                      ),
                      Text(
                        'Filter',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF0D80D4),
                          fontSize: AppSizes.smallFont(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (car!['variants'].isEmpty)
              Center(child: Text('No Variants Available')),

            /// Variant Tiles
            for (var v in car['variants'])
              _variantTile(
                context,
                title: v['name'],
                price: "₹${(v["price"] ?? 0)}",
                onRoadPrice: "₹${((v["price"] ?? 0) * 1.14 + 2000).toStringAsFixed(0)}", // Rough estimate for list view
                onViewBreakup: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PriceBreakupPage(
                        carName: car['name'] ?? '',
                        variantName: v['name'] ?? '',
                        exShowroomPrice: (v['price'] ?? 0).toDouble(),
                        city: selectedCity,
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 25),

            /// EMI Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FB),
                border: Border.all(color: Color(0xFFF8F8F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMI Options for the selected model',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: AppSizes.smallFont(context),
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Rs. ${(montlyEMI!['emi'] ?? 0).toStringAsFixed(0)} EMI for 5 Years",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizes.bodyFont(context),
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const EmiDialog(),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EMI Calculator',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                fontSize: AppSizes.smallFont(context),
                                color: Color(0xFF0D80D4),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF0D80D4),
                              size: AppSizes.iconSmall(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// Bottom Buttons
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 700; // breakpoint

                if (isMobile) {
                  // Stack buttons vertically on mobile
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          List<dynamic> carList =
                              await CompareCarApi.addToCompare(car['_id']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompareCar(selectedCarsFromPrev: carList),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 19),
                          side: const BorderSide(
                            color: Color(0xFF004C90),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/compare.svg'),
                            const SizedBox(width: 6),
                            Text(
                              'Add to Compare',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.buttonFontSize(context),
                                color: Color(0xFF1A4C8E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingCart(carData: car),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF004C90),
                          padding: const EdgeInsets.symmetric(vertical: 19),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/icons/book_online.svg'),
                            const SizedBox(width: 6),
                            Text(
                              'Book online',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.buttonFontSize(context),
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  // Keep buttons in a row on large screens
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            List<dynamic> carList =
                                await CompareCarApi.addToCompare(car['_id']);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CompareCar(selectedCarsFromPrev: carList),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 19),
                            side: const BorderSide(
                              color: Color(0xFF004C90),
                              width: 1.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/compare.svg'),
                              const SizedBox(width: 6),
                              Text(
                                'Add to Compare',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.buttonFontSize(context),
                                  color: Color(0xFF1A4C8E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookingCart(carData: car),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004C90),
                            padding: const EdgeInsets.symmetric(vertical: 19),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/book_online.svg'),
                              const SizedBox(width: 6),
                              Text(
                                'Book online',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppSizes.buttonFontSize(context),
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}

/// Small Widget for Specs
class _SpecTile extends StatelessWidget {
  final String label, value;
  const _SpecTile({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 20,
          color: Color(0xFF004C90),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label\n$value",
            style: const TextStyle(fontFamily: "DM Sans", fontSize: 14),
          ),
        ),
      ],
    );
  }
}

/// Small Widget for Variant Price
Widget _variantTile(
  BuildContext context, {
  required String title,
  required String price,
  required String onRoadPrice,
  required VoidCallback onViewBreakup,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    width: AppSizes.isDesktop(context)
        ? AppSizes.screenWidth(context) * 0.4
        : AppSizes.screenWidth(context) * 0.9,

    decoration: BoxDecoration(border: Border.all(color: Color(0xFFC6C6C6))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'DM Sans',
            fontSize: AppSizes.bodyFont(context),
            color: Color(0xFF3E3E3E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          price,
          style: TextStyle(
            fontSize: AppSizes.smallFont(context),
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '*On-road price - Rs. $onRoadPrice',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: AppSizes.smallFont(context),
                color: Color(0xFf295800),
              ),
            ),
            TextButton(
              onPressed: onViewBreakup,
              child: Row(
                children: [
                  Text(
                    'view price Breakup',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: AppSizes.smallFont(context),
                      color: Color(0xFF0D80D4),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF0D80D4),
                    size: AppSizes.iconSmall(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class SimilarCarCard extends StatelessWidget {
  final String image;
  final String title;
  final String model;
  final String price;
  final String onRoad;

  const SimilarCarCard({
    super.key,
    required this.image,
    required this.title,
    required this.model,
    required this.price,
    required this.onRoad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth(context) * 0.3,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Car Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                height: AppSizes.screenHeight(context) * 0.15,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppSizes.screenHeight(context) * 0.001),

            /// Title
            Text(
              title,
              style: const TextStyle(
                fontFamily: "DM Sans",
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: AppSizes.screenHeight(context) * 0.0001),

            /// Subtitle / Model
            Text(
              model,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B6B6B)),
            ),

            SizedBox(height: AppSizes.screenHeight(context) * 0.001),
            Row(
              children: [
                SvgPicture.asset('assets/icons/fuel.svg'),
                SizedBox(width: AppSizes.screenWidth(context) * 0.01),
                SvgPicture.asset('assets/icons/manual.svg'),
              ],
            ),
            SizedBox(height: AppSizes.screenHeight(context) * 0.001),

            /// Price
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF004C90),
              ),
            ),
            Text(
              onRoad,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
            ),

            SizedBox(height: AppSizes.screenHeight(context) * 0.001),

            /// Book Button
            TextButton(
              onPressed: () {},
              child: Row(
                children: [
                  Text('Book Test drive'),
                  SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/arrow_up.svg',
                    color: Color(0xFF000000),
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

// --- Generic Selection Helper ---
void _showSelectionDialog<T>(
  BuildContext context, {
  required String title,
  required String searchHint,
  required List<T> items,
  required String Function(T) labelBuilder,
  String Function(T)? subtitleBuilder,
  required Function(T) onItemSelected,
}) {
  TextEditingController searchController = TextEditingController();
  List<T> filteredItems = items;
  T? selectedItem;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 500, // Fixed width for better look
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredItems = items.where((item) {
                        return labelBuilder(item).toLowerCase().contains(value.toLowerCase());
                      }).toList();
                    });
                  },
                ),
                const SizedBox(height: 15),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: filteredItems.isEmpty 
                    ? const Center(child: Text("No items found"))
                    : ListView.separated(
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return RadioListTile<T>(
                            title: Text(labelBuilder(item)),
                            subtitle: subtitleBuilder != null 
                                ? Text(subtitleBuilder(item)) 
                                : null,
                            value: item,
                            groupValue: selectedItem,
                            onChanged: (val) => setState(() => selectedItem = val),
                            activeColor: const Color(0xFF1A4C8E),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedItem == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            onItemSelected(selectedItem as T);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A4C8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Apply", style: TextStyle(fontSize: 16)),
                  ),
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
  _showSelectionDialog<Map<String, dynamic>>(
    context,
    title: "Select Model",
    searchHint: "Search Model",
    items: carList,
    labelBuilder: (car) => car["name"],
    subtitleBuilder: (car) => car["type"] ?? "",
    onItemSelected: onModelSelected,
  );
}

void showBrandChangeDialog(
  BuildContext context, {
  required List<Map<String, dynamic>> carList,
  required Function(String selectedBrand) onBrandSelected,
}) {
  // Extract unique brands
  final Set<String> brands = {};
  for (var car in carList) {
    if (car['brand'] != null) {
      brands.add(car['brand'].toString());
    }
  }
  List<String> allBrands = brands.toList()..sort();

  _showSelectionDialog<String>(
    context,
    title: "Select Brand",
    searchHint: "Search Brand",
    items: allBrands,
    labelBuilder: (brand) => brand,
    onItemSelected: onBrandSelected,
  );
}

