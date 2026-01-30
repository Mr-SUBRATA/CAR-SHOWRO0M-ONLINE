import 'dart:typed_data';

import 'package:arouse_ecommerce_frontend/api/Home/compare_api.dart';
import 'package:arouse_ecommerce_frontend/common_widgets/C_AppBar.dart';
import 'package:flutter/material.dart';

class Twocarscompare extends StatefulWidget {
  const Twocarscompare({super.key});

  @override
  State<Twocarscompare> createState() => _TwocarscompareState();
}

class _TwocarscompareState extends State<Twocarscompare>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  //-------Specifications--------
  List<String> overview1 = [];
  List<String> overview2 = [];
  List<String> wheels1 = [];
  List<String> wheels2 = [];
  List<String> technology1 = [];
  List<String> technology2 = [];
  List<String> performance1 = [];
  List<String> performance2 = [];
  List<String> dimensions1 = [];
  List<String> dimensions2 = [];

  //---Feature----
  List<String> features1 = [];
  List<String> features2 = [];

  //--------------Colors---------
  List<String> colors1 = [];
  List<String> colors2 = [];

  List<Map<String, dynamic>> allCars = [];
  List<Map<String, dynamic>> selectedCars = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    loadCars();
  }

  Uint8List? getCarImageBytes(Map<String, dynamic> car) {
    try {
      if (car["images"] != null && car["images"].isNotEmpty) {
        var imageData = car["images"][0]["data"]["data"];
        List<int> bytes = List<int>.from(imageData);
        return Uint8List.fromList(bytes);
      }
    } catch (e) {
      print("Failed to parse car image: $e");
    }
    return null;
  }

  Future<void> loadCars() async {
    allCars =
        await CompareApi.getAllCars(); // returns List<Map<String, dynamic>>
    setState(() => isLoading = false);
  }

  void addCar(Map<String, dynamic> car) {
    if (!selectedCars.any((c) => c["_id"] == car["_id"])) {
      setState(() => selectedCars.add(car));
    }
    print("Selected Cars: $selectedCars");
  }

  void removeCar(Map<String, dynamic> car) {
    setState(() => selectedCars.removeWhere((c) => c["_id"] == car["_id"]));
  }

  void openCarPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: allCars.length,
          itemBuilder: (context, index) {
            final car = allCars[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 55,
                  height: 55,
                  child: (car["images"] != null && car["images"].isNotEmpty)
                      ? Image.memory(getCarImageBytes(car)!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey,
                          child: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              title: Text(car["name"] ?? ""),
              subtitle: Text(car["brand"] ?? ""),
              trailing: ElevatedButton(
                onPressed: () {
                  addCar(car);
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCars.length == 2) {
      overview1 = List<String>.from(
        selectedCars[0]["specifications"]["overview"],
      );
      overview2 = List<String>.from(
        selectedCars[1]["specifications"]["overview"],
      );

      wheels1 = List<String>.from(selectedCars[0]["specifications"]["wheels"]);
      wheels2 = List<String>.from(selectedCars[1]["specifications"]["wheels"]);
      technology1 = List<String>.from(
        selectedCars[0]["specifications"]["technology"],
      );
      technology2 = List<String>.from(
        selectedCars[1]["specifications"]["technology"],
      );
      performance1 = List<String>.from(
        selectedCars[0]["specifications"]["performance"],
      );
      performance2 = List<String>.from(
        selectedCars[1]["specifications"]["performance"],
      );
      dimensions1 = List<String>.from(
        selectedCars[0]["specifications"]["dimension"],
      );
      dimensions2 = List<String>.from(
        selectedCars[1]["specifications"]["dimension"],
      );

      //------------- Features---------------------------
      features1 = (selectedCars[0]["features"] as List)
          .map((f) => "${f["title"]}: ${f["caption"]}")
          .toList();

      features2 = (selectedCars[1]["features"] as List)
          .map((f) => "${f["title"]}: ${f["caption"]}")
          .toList();

      //---------------Colors---------------------
      colors1 = List<String>.from(selectedCars[0]["colors"]);
      colors2 = List<String>.from(selectedCars[1]["colors"]);
    }

    return Scaffold(
      appBar: CAppbar(screenName: "Compare Car"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  selectedCars.length < 2
                      ? const Text(
                          "Please add 2 Cars to compare",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              buildCarCard(selectedCars[0]),
                              const SizedBox(width: 10),
                              Image.asset(
                                "assets/Home_Images/Compare_Cars/vs.png",
                                height: 30,
                              ),
                              const SizedBox(width: 10),
                              buildCarCard(selectedCars[1]),
                            ],
                          ),
                        ),

                  const SizedBox(height: 20),

                  /// Add Car Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Color.fromRGBO(26, 76, 142, 1),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: openCarPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Color.fromRGBO(26, 76, 142, 1),
                          ),
                          const Text(
                            " Add Car",
                            style: TextStyle(
                              color: Color.fromRGBO(26, 76, 142, 1),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  if (selectedCars.length == 2)
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                labelColor: Color.fromRGBO(26, 76, 142, 1),
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: Color.fromRGBO(26, 76, 142, 1),
                                tabs: const [
                                  Tab(text: 'Specifications'),
                                  Tab(text: 'Features'),
                                  Tab(text: 'Brochure'),
                                  Tab(text: 'Colours'),
                                ],
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                          controller: _tabController,
                          children: [
                            /// SPECIFICATIONS TAB
                            SingleChildScrollView(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  compareSpecs(
                                    val1: overview1.join(", "),
                                    val2: overview2.join(", "),
                                  ),
                                  compareSpecs(
                                    val1: wheels1.join(", "),
                                    val2: wheels2.join(", "),
                                  ),
                                  compareSpecs(
                                    val1: performance1.join(", "),
                                    val2: performance2.join(", "),
                                  ),
                                  compareSpecs(
                                    val1: technology1.join(", "),
                                    val2: technology2.join(", "),
                                  ),
                                  compareSpecs(
                                    val1: dimensions1.join(", "),
                                    val2: dimensions2.join(", "),
                                  ),
                                ],
                              ),
                            ),

                            /// FEATURES TAB
                            SingleChildScrollView(
                              padding: EdgeInsets.all(12),
                              child: compareSpecs(
                                val1: features1.join(", "),
                                val2: features2.join(", "),
                              ),
                            ),

                            /// BROCHURE TAB
                            compareBrochure(),

                            /// COLOURS TAB
                            SingleChildScrollView(
                              padding: EdgeInsets.all(12),
                              child: compareSpecs(
                                val1: colors1.join(", "),
                                val2: colors2.join(", "),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget compareSpecs({required String val1, required String val2}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                val1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF686868),
                ),
              ),
            ),
            Container(width: 2, height: 50, color: Color(0xFFDBDBDB)),
            Expanded(
              child: Text(
                val2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xFF686868),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget compareBrochure() =>
      const Center(child: Text("Download brochures here"));

  Widget buildCarCard(Map<String, dynamic> car) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E5E5), width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.memory(
                    getCarImageBytes(car)!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => removeCar(car),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${car["name"]} – ${car["year"] ?? ""}",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),

                // Text(
                //   car["variants"]?[0]["specifications"]["overview"][0] ?? "",
                //   style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                // ),
                SizedBox(height: 10),

                // Fuel & Transmission icons
                Row(
                  children: [
                    Icon(Icons.local_gas_station, size: 18),
                    SizedBox(width: 6),
                    Text(car["fuelType"], style: TextStyle(fontSize: 12)),
                    SizedBox(width: 20),
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 6),
                    Text(car["transmission"], style: TextStyle(fontSize: 12)),
                  ],
                ),

                SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      "Rs. ${car["price"].toString()}",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "onwards",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                SizedBox(height: 3),

                Text(
                  "Off-Road Price, Mumbai",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
