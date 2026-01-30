import 'dart:typed_data';
import 'package:arouse_ecommerce_frontend/api/Home/home_api.dart';
import 'package:arouse_ecommerce_frontend/api/Vehicles/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend/components/Book_test_drive/book_test_drive.dart';
import 'package:arouse_ecommerce_frontend/components/compare_cars/twoCarsCompare.dart';
import 'package:arouse_ecommerce_frontend/pages/blog_detail_screen.dart';
import 'package:arouse_ecommerce_frontend/pages/search_vehicles.dart';
import 'package:arouse_ecommerce_frontend/pages/menu_screen.dart';
import 'package:arouse_ecommerce_frontend/pages/vehicle_info_page.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../api/Home/blog_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List blogs = [];
  bool isLoading = true;
  List<Map<String, dynamic>>? carsData;
  List<Map<String, dynamic>> allCars = []; // full API data
  List<String> brands = [];
  List<Map<String, dynamic>> featuredCars = [];

  String? selectedBrand;
  String? selectedModel;

  @override
  void initState() {
    super.initState();
    loadBlogs();
    getCars();
    fetchCarsData();
  }

  Future<void> getCars() async {
    var car = await VehiclesApi.getAllCars();
    for (var c in car) {
      if (c["isFeatured"]) {
        featuredCars.add(c);
      }
    }
    setState(() {
      carsData = car;
    });
    //print('featuredCars: $featuredCars');
  }

  Future<void> fetchCarsData() async {
    setState(() {
      brands = allCars.map((v) => v['brand'] as String).toSet().toList();
    });
  }

  void loadBlogs() async {
    blogs = await BlogApi.getAllBlog();
    //print(blogs);
    setState(() => isLoading = false);
  }

  Uint8List? getImageBytes(Map<String, dynamic> blog) {
    try {
      if (blog["image"] != null &&
          blog["image"]["data"] != null &&
          blog["image"]["data"]["data"] != null) {
        List<int> bytes = List<int>.from(blog["image"]["data"]["data"]);
        return Uint8List.fromList(bytes);
      }
    } catch (e) {
      print("Failed to parse image: $e");
    }
    return null;
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

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMMM yyyy').format(parsedDate); // 05 December 2025
  }

  late Future<List<Map<String, dynamic>>> searchResults;

  @override
  void dispose() {
    super.dispose();
  }

  final List<Map<String, String>> reviews = [
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque.",
    },
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque.",
    },
    {
      "name": "Neil",
      "date": "30th May 2023",
      "image": "assets/Home_Images/Customers_say_Images/ladyImage.jpeg",
      "review":
          "Lorem ipsum dolor sit amet consectetur. Diam nec faucibus molestie tortor mi. Orci risus turpis sagittis blandit id. Suspendisse enim pellentesque diam et orci nam pharetra dignissim. Netus dui dapibus quis porttitor eget tristique consectetur. Quisque eu at scelerisque scelerisque. Curabitur tempor consectetur ut neque.",
    },
  ];

  CarouselSliderController innerCarouselController = CarouselSliderController();
  int innerCurrentPage = 0;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    bool isWebOrDesktop = screenWidth >= 1024;

    // Dynamic Sizing
    double imageSize = isWebOrDesktop
        ? 40
        : isTablet
        ? 30
        : screenWidth * 0.075;
    double iconSize = isWebOrDesktop
        ? 30
        : isTablet
        ? 20
        : screenWidth * 0.08;
    double fontSize = isWebOrDesktop
        ? 20
        : isTablet
        ? 18
        : screenWidth * 0.03 + 4;
    double spacing = isWebOrDesktop
        ? 10
        : isTablet
        ? 8
        : screenWidth * 0.01;

    return Scaffold(
      appBar: AppBar(
        elevation: 5.0,
        shadowColor: Colors.grey,
        leading: Padding(
          padding: EdgeInsets.all(screenHeight * 0.015),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Image.asset('assets/menu.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image.png',
              height: imageSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: spacing),
            Text(
              'AROUSE',
              style: TextStyle(
                color: Color(0xFF004C90),
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DMSans",
              ),
            ),
            SizedBox(width: spacing),
            Text(
              'AUTOMOTIVE',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                fontFamily: "DMSans",
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(spacing),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: Image.asset('assets/wishlist.png', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: screenHeight * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double searchBarHeight = isWebOrDesktop
                      ? screenHeight * 0.09
                      : isTablet
                      ? screenHeight * 0.07
                      : screenHeight * 0.06;

                  double searchIconSize = searchBarHeight * 0.6;

                  return SizedBox(
                    height: searchBarHeight,
                    child: SearchAnchor(
                      builder: (context, controller) {
                        return GestureDetector(
                          child: SearchBar(
                            controller: controller,
                            hintText:
                                "Search by Make, Model, Price Range, or Specs",
                            hintStyle: MaterialStateProperty.all(
                              TextStyle(
                                color: Colors.grey,
                                fontSize: isWebOrDesktop
                                    ? 18
                                    : isTablet
                                    ? 16
                                    : screenWidth * 0.04,
                                fontFamily: "DMSans",
                              ),
                            ),
                            onSubmitted: (query) async {
                              searchResults = HomeApi.searchCar(query);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SearchedVehicles(
                                    vehicles: searchResults,
                                    query: query,
                                  ),
                                ),
                              );
                            },
                            leading: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Image.asset(
                                'assets/search.png',
                                height: searchIconSize,
                                color: const Color.fromARGB(255, 28, 7, 7),
                              ),
                            ),
                            overlayColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            shadowColor: MaterialStateProperty.all(
                              Colors.transparent,
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              Colors.white,
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  isWebOrDesktop ? 15 : 10,
                                ),
                                side: const BorderSide(
                                  color: Color.fromRGBO(233, 233, 233, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      suggestionsBuilder: (context, controller) {
                        return [Container()]; // return an empty list of widgets
                      },
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
                vertical: MediaQuery.of(context).size.height * 0.01,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double screenWidth = constraints.maxWidth;
                    double imageHeight = screenWidth > 600
                        ? MediaQuery.of(context).size.height * 0.8
                        : MediaQuery.of(context).size.height * 0.35;

                    double textFontSize = screenWidth > 600
                        ? 50
                        : screenWidth * 0.1;
                    double buttonFontSize = screenWidth > 600
                        ? 18
                        : screenWidth * 0.035;
                    double buttonPaddingH = screenWidth > 600
                        ? 20
                        : screenWidth * 0.05;
                    double buttonPaddingV = screenWidth > 600
                        ? 14
                        : MediaQuery.of(context).size.height * 0.015;

                    return Stack(
                      children: [
                        SizedBox(
                          height: imageHeight,
                          width: double.infinity,
                          child: Image.asset(
                            "assets/carbackground.jpeg",
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          left: screenWidth > 800
                              ? MediaQuery.of(context).size.width * 0.08
                              : MediaQuery.of(context).size.width * 0.05,
                          bottom: MediaQuery.of(context).size.height * 0.05,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Find Your \nPerfect Car",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: textFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "DMSans",
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
                              ),

                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: buttonPaddingH,
                                    vertical: buttonPaddingV,
                                  ),
                                  textStyle: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontFamily: "DMSans",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: Text(
                                  "Explore More",
                                  style: TextStyle(color: Color(0xFF004C90)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;

                      double titleFontSize = screenWidth > 600
                          ? 40
                          : screenWidth * 0.08;
                      double buttonFontSize = screenWidth > 600
                          ? 18
                          : screenWidth * 0.04;
                      double iconSize = screenWidth > 600
                          ? 35
                          : screenWidth * 0.06;

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.00,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Cars',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                fontFamily: "DMSans",
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchedVehicles(
                                      vehicles: Future.value(featuredCars),
                                      query: "Featured Cars",
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Color.fromRGBO(0, 147, 255, 1),
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "DMSans",
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.01),
                                  Icon(
                                    Icons.arrow_outward,
                                    color: Color.fromRGBO(0, 147, 255, 1),
                                    size: iconSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  Divider(
                    color: Color.fromRGBO(219, 219, 219, 1),
                    thickness: MediaQuery.of(context).size.width * 0.005,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                  Stack(
                    children: [
                      featuredCars.isEmpty
                          ? Center(child: CircularProgressIndicator())
                          : CarouselSlider(
                              carouselController: innerCarouselController,
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.height > 600
                                    ? MediaQuery.of(context).size.height * 0.55
                                    : MediaQuery.of(context).size.height * 0.95,
                                autoPlay: false,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration: Duration(
                                  milliseconds: 1000,
                                ),
                                enableInfiniteScroll: false,
                                enlargeCenterPage: false,
                                viewportFraction: 1.0,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    innerCurrentPage = index;
                                  });
                                },
                              ),
                              items: featuredCars.map((car) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    double padding =
                                        constraints.maxWidth * 0.025;
                                    double buttonPadding =
                                        constraints.maxWidth * 0.03;
                                    double buttonHeight =
                                        constraints.maxHeight * 0.05;
                                    double fontSizeFactor =
                                        MediaQuery.of(context).size.width > 800
                                        ? 1.2
                                        : 1.0;

                                    return Container(
                                      padding: EdgeInsets.all(padding),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          width: 2,
                                          color: Color.fromRGBO(
                                            233,
                                            233,
                                            233,
                                            1,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (getCarImageBytes(car) != null)
                                            Stack(
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Image.memory(
                                                    getCarImageBytes(car)!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 0,
                                                  right: padding,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Twocarscompare(),
                                                        ),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.grey,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal:
                                                                buttonPadding,
                                                            vertical:
                                                                buttonHeight *
                                                                0.3,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          "assets/compare.png",
                                                          width: 20,
                                                          height: 20,
                                                          fit: BoxFit.contain,
                                                        ),
                                                        SizedBox(
                                                          width: padding * 0.5,
                                                        ),
                                                        Text(
                                                          "Add To Compare",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "DMSans",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  top:
                                                      constraints.maxHeight *
                                                      0.18,
                                                  left:
                                                      constraints.maxWidth *
                                                          0.5 -
                                                      60,
                                                  child: GestureDetector(
                                                    onTap: () {},
                                                    child: SvgPicture.asset(
                                                      "assets/icons/360_view.svg",
                                                      width:
                                                          constraints.maxWidth *
                                                          0.25,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(
                                            height:
                                                constraints.maxHeight * 0.03,
                                          ),
                                          Flexible(
                                            child: Text(
                                              car["name"] ?? "",
                                              style: TextStyle(
                                                fontSize:
                                                    constraints.maxWidth *
                                                    0.05 *
                                                    fontSizeFactor,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                constraints.maxHeight * 0.02,
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Starting at",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                    .maxWidth *
                                                                0.04 *
                                                                fontSizeFactor -
                                                            0.9,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.05,
                                                    ),
                                                    Text(
                                                      car["price"]!.toString(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                .maxWidth *
                                                            0.03 *
                                                            fontSizeFactor,
                                                        fontFamily: "DMSans",
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Onwards On-Road",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                .maxWidth *
                                                            0.03 *
                                                            fontSizeFactor,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    Text(
                                                      "price Mumbai",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                .maxWidth *
                                                            0.03 *
                                                            fontSizeFactor,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    constraints.maxWidth * 0.01,
                                              ),
                                              Container(
                                                color: Color.fromRGBO(
                                                  219,
                                                  219,
                                                  219,
                                                  1,
                                                ),
                                                height:
                                                    constraints.maxHeight *
                                                    0.18,
                                                width:
                                                    constraints.maxWidth *
                                                    0.005,
                                              ),
                                              SizedBox(
                                                width:
                                                    constraints.maxWidth * 0.02,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Engine Options",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                    .maxWidth *
                                                                0.04 *
                                                                fontSizeFactor -
                                                            0.9,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.05,
                                                    ),
                                                    Image.asset(
                                                      "assets/diesel.webp",
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.03,
                                                      width:
                                                          constraints.maxWidth *
                                                          0.1,
                                                      color: Colors.black,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.02,
                                                    ),
                                                    Text(
                                                      car["fuelType"]!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                .maxWidth *
                                                            0.03 *
                                                            fontSizeFactor,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    constraints.maxWidth * 0.02,
                                              ),
                                              Container(
                                                color: Color.fromRGBO(
                                                  219,
                                                  219,
                                                  219,
                                                  1,
                                                ),
                                                height:
                                                    constraints.maxHeight *
                                                    0.18,
                                                width:
                                                    constraints.maxWidth *
                                                    0.005,
                                              ),
                                              SizedBox(
                                                width:
                                                    constraints.maxWidth * 0.02,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Transmission",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                    .maxWidth *
                                                                0.04 *
                                                                fontSizeFactor -
                                                            0.9,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    Text(
                                                      "Available",
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                    .maxWidth *
                                                                0.04 *
                                                                fontSizeFactor -
                                                            0.9,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.02,
                                                    ),

                                                    Image.asset(
                                                      "assets/manuel.png",
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.03,
                                                      width:
                                                          constraints.maxWidth *
                                                          0.1,
                                                      color: Colors.black,
                                                      fit: BoxFit.contain,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          constraints
                                                              .maxHeight *
                                                          0.02,
                                                    ),
                                                    Text(
                                                      car["transmission"]!,
                                                      style: TextStyle(
                                                        fontSize:
                                                            constraints
                                                                .maxWidth *
                                                            0.03 *
                                                            fontSizeFactor,
                                                        fontFamily: "DMSans",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                                constraints.maxHeight * 0.02,
                                          ),
                                          Divider(
                                            color: Color.fromRGBO(
                                              219,
                                              219,
                                              219,
                                              1,
                                            ),
                                            thickness: 2.0,
                                          ),
                                          SizedBox(
                                            height:
                                                constraints.maxHeight * 0.02,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: Color(0xFF004C90),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VehicleInfoPage(
                                                            selectedTab: 0,
                                                            carId: car["_id"],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        buttonHeight * 0.5,
                                                  ),
                                                  child: Text(
                                                    "Learn More",
                                                    style: TextStyle(
                                                      fontSize:
                                                          constraints.maxWidth *
                                                          0.04 *
                                                          fontSizeFactor,
                                                      color: Color(0xFF004C90),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(
                                                    0xFF004C90,
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BookTestDrive(),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        buttonHeight * 0.5,
                                                  ),
                                                  child: Text(
                                                    'Book a Test Drive',
                                                    style: TextStyle(
                                                      fontSize:
                                                          constraints.maxWidth *
                                                          0.04 *
                                                          fontSizeFactor,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),

                      if (innerCurrentPage >= 0)
                        Positioned(
                          left: -10,
                          top: 170,
                          child: FloatingActionButton(
                            heroTag: 'carousel_prev',
                            onPressed: () {
                              innerCarouselController.animateToPage(
                                innerCurrentPage - 1,
                                curve: Curves.ease,
                              );
                            },
                            backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                            mini: true,
                            child: const Icon(
                              Icons.arrow_back_ios_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (innerCurrentPage <= featuredCars.length - 1)
                        Positioned(
                          right: -10,
                          top: 170,
                          child: FloatingActionButton(
                            heroTag: 'carousel_next',
                            onPressed: () {
                              innerCarouselController.animateToPage(
                                innerCurrentPage + 1,
                              );
                            },
                            backgroundColor: Color.fromRGBO(26, 76, 142, 1),
                            mini: true,
                            child: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = MediaQuery.of(context).size.width;
                      double screenHeight = MediaQuery.of(context).size.height;

                      double imageSize;
                      if (screenWidth > 1200) {
                        imageSize = (screenWidth / 6) - 100;
                      } else if (screenWidth > 600) {
                        imageSize = (screenWidth / 6) - 100;
                      } else {
                        imageSize = (screenWidth / 3) - 60;
                      }
                      imageSize = imageSize.clamp(30.0, 200.0);

                      return Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Similar Brands',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: screenWidth * 0.06,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    children: [
                                      Text(
                                        'Show all Brands',
                                        style: TextStyle(
                                          color: Color.fromRGBO(0, 147, 255, 1),
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_outward,
                                        color: Color.fromRGBO(0, 147, 255, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              color: Color.fromRGBO(219, 219, 219, 1),
                              thickness: 2.0,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Wrap(
                                spacing: screenWidth * 0.05,
                                runSpacing: screenHeight * 0.02,
                                children: [
                                  buildBrandCard(
                                    context,
                                    logo: "assets/audi.jpeg",
                                    title: "Audi",
                                  ),
                                  buildBrandCard(
                                    context,
                                    logo: "assets/bmw.jpeg",
                                    title: "BMW",
                                  ),
                                  buildBrandCard(
                                    context,
                                    logo: "assets/ford.jpeg",
                                    title: "Ford",
                                  ),
                                  buildBrandCard(
                                    context,
                                    logo: "assets/mercedes.jpeg",
                                    title: "Mercedes Benz",
                                  ),
                                  buildBrandCard(
                                    context,
                                    logo: "assets/peugeot.jpeg",
                                    title: "Peugeot",
                                  ),
                                  buildBrandCard(
                                    context,
                                    logo: "assets/volkswagan.jpeg",
                                    title: "Volkswagan",
                                  ),
                                ],
                              ),
                            ),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double screenWidth = MediaQuery.of(
                                  context,
                                ).size.width;
                                double imageWidth = screenWidth * 0.9;
                                double imageHeight = imageWidth * 9 / 16;
                                double playButtonSize = screenWidth * 0.12;
                                double sectionSpacing = screenWidth * 0.05;
                                double fontSizeTitle = screenWidth * 0.06;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: sectionSpacing),
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: Image.asset(
                                            "assets/videoImage.jpeg",
                                            width: imageWidth,
                                            height: imageHeight,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: playButtonSize / 2,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.8),
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: playButtonSize * 0.6,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: screenWidth * 0.9,
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(238, 241, 251, 1),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Buying a car has never been this easy.",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.06,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                            SizedBox(height: sectionSpacing),
                                            Text(
                                              "We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of options.",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                color: Colors.grey[700],
                                                fontFamily: "DMSans",
                                              ),
                                            ),
                                            SizedBox(height: sectionSpacing),
                                            Column(
                                              children: [
                                                buildBulletPoint(
                                                  context,
                                                  "We are the UK's largest provider, with more patrols in more places",
                                                ),
                                                buildBulletPoint(
                                                  context,
                                                  "You get 24/7 roadside assistance",
                                                ),
                                                buildBulletPoint(
                                                  context,
                                                  "We fix 4 out of 5 cars at the roadside",
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: sectionSpacing),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookTestDrive(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color(
                                                  0xFF004C90,
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.05,
                                                  vertical: screenWidth * 0.03,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    "Book a test drive",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: sectionSpacing,
                                                  ),
                                                  Icon(
                                                    Icons.arrow_outward,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: sectionSpacing),
                                    Table(
                                      columnWidths: {
                                        0: FlexColumnWidth(),
                                        1: FlexColumnWidth(),
                                      },
                                      border: TableBorder(
                                        horizontalInside: BorderSide(
                                          color: Color.fromRGBO(
                                            219,
                                            219,
                                            219,
                                            1,
                                          ),
                                          width: 1,
                                        ),
                                        verticalInside: BorderSide(
                                          color: Color.fromRGBO(
                                            219,
                                            219,
                                            219,
                                            1,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      children: [
                                        TableRow(
                                          children: [
                                            buildStatBox(
                                              context,
                                              "836M",
                                              "CARS FOR SALE",
                                            ),
                                            buildStatBox(
                                              context,
                                              "738M",
                                              "DEALER REVIEWS",
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            buildStatBox(
                                              context,
                                              "100M",
                                              "VISITORS PER DAY",
                                            ),
                                            buildStatBox(
                                              context,
                                              "238M",
                                              "VERIFIED DEALERS",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: sectionSpacing),
                                    Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Why Choose Us?",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeTitle,
                                              fontFamily: "DMSans",
                                            ),
                                          ),
                                          Divider(
                                            thickness: 2,
                                            color: Color.fromRGBO(
                                              219,
                                              219,
                                              219,
                                              1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double screenWidth = MediaQuery.of(
                                          context,
                                        ).size.width;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/financialOffer.png",
                                                  height: screenWidth * 0.15,
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.06,
                                                ),
                                                Text(
                                                  "Special Financing Offers",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.04,
                                                ),
                                                Text(
                                                  "Our stress-free finance department that can find financial solutions to save you money.",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 30),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/dealership.png",
                                                  height: screenWidth * 0.15,
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.06,
                                                ),
                                                Text(
                                                  "Trusted Car Dealership",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.04,
                                                ),
                                                Text(
                                                  "Our stress-free finance department that can find financial solutions to save you money.",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 30),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/transparent.png",
                                                  height: screenWidth * 0.15,
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.06,
                                                ),
                                                Text(
                                                  "Transparent Pricing",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: "DMSans",
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.04,
                                                ),
                                                Text(
                                                  "Our stress-free finance department that can find financial solutions to save you money.",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 30),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image.asset(
                                                  "assets/expertCar.png",
                                                  height: screenWidth * 0.15,
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.06,
                                                ),
                                                Text(
                                                  "Expert Car Service",
                                                  style: TextStyle(
                                                    fontSize:
                                                        screenWidth * 0.045,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: screenWidth * 0.04,
                                                ),
                                                Text(
                                                  "Our stress-free finance department that can find financial solutions to save you money.",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontSize:
                                                        screenWidth * 0.035,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          double textSize =
                                              constraints.maxWidth > 600
                                              ? 28
                                              : 24;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "What our customers say",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: textSize,
                                                  fontFamily: "DMSans",
                                                ),
                                              ),
                                              Divider(
                                                thickness: 2,
                                                color: Color.fromRGBO(
                                                  219,
                                                  219,
                                                  219,
                                                  1,
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 30),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double iconSize =
                                            constraints.maxWidth > 600
                                            ? 40
                                            : 30;
                                        double textSize =
                                            constraints.maxWidth > 600
                                            ? 22
                                            : 18;
                                        double spacing =
                                            constraints.maxWidth > 600 ? 15 : 8;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: iconSize,
                                                    color: Color.fromRGBO(
                                                      241,
                                                      217,
                                                      0,
                                                      1,
                                                    ),
                                                  ),
                                                  SizedBox(width: spacing),
                                                  Text(
                                                    "4.5 · 306 reviews",
                                                    style: TextStyle(
                                                      fontSize: textSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                        31,
                                                        56,
                                                        76,
                                                        1,
                                                      ),
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0.0,
                                      ),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          double containerHeight =
                                              constraints.maxWidth > 600
                                              ? 320
                                              : 290;
                                          double containerWidth =
                                              constraints.maxWidth > 600
                                              ? 400
                                              : 370;
                                          double imageSize =
                                              constraints.maxWidth > 600
                                              ? 75
                                              : 65;
                                          double textSize =
                                              constraints.maxWidth > 600
                                              ? 22
                                              : 20;
                                          double dateSize =
                                              constraints.maxWidth > 600
                                              ? 16
                                              : 14;
                                          double reviewTextSize =
                                              constraints.maxWidth > 600
                                              ? 16
                                              : 14;

                                          return CarouselSlider(
                                            options: CarouselOptions(
                                              height: containerHeight,
                                              autoPlay: true,
                                              enlargeCenterPage: false,
                                              enableInfiniteScroll: false,
                                              viewportFraction:
                                                  constraints.maxWidth > 600
                                                  ? 0.7
                                                  : 0.9,
                                            ),
                                            items: reviews.map((review) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  10.0,
                                                ),
                                                child: Container(
                                                  height: containerHeight,
                                                  width: containerWidth,
                                                  child: DottedBorder(
                                                    //    borderType:
                                                    //      BorderType.RRect,
                                                    //    radius:
                                                    //    const Radius.circular(
                                                    //    10,
                                                    //   ),
                                                    //       strokeWidth: 2.5,
                                                    //  dashPattern: [20, 5],
                                                    // color:
                                                    //     const Color.fromRGBO(
                                                    //       196,
                                                    //       196,
                                                    //       196,
                                                    //       1,
                                                    //     ),
                                                    child: Container(
                                                      height: containerHeight,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 15.0,
                                                            vertical: 10,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      50,
                                                                    ),
                                                                child: Image.asset(
                                                                  review["image"]!,
                                                                  height:
                                                                      imageSize,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    review["name"]!,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          textSize,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          "DMSans",
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    review["date"]!,
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          dateSize,
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            139,
                                                                            139,
                                                                            139,
                                                                            1,
                                                                          ),
                                                                      fontFamily:
                                                                          "DMSans",
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Expanded(
                                                            child: RichText(
                                                              text: TextSpan(
                                                                style: TextStyle(
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        62,
                                                                        62,
                                                                        62,
                                                                        1,
                                                                      ),
                                                                  fontSize:
                                                                      reviewTextSize,
                                                                  fontFamily:
                                                                      "DMSans",
                                                                ),
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        review["review"],
                                                                  ),
                                                                  const TextSpan(
                                                                    text:
                                                                        " View More",
                                                                    style: TextStyle(
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            13,
                                                                            128,
                                                                            212,
                                                                            1,
                                                                          ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          "DMSans",
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ),

                                    SizedBox(height: 10),
                                    Divider(
                                      color: Color.fromRGBO(219, 219, 219, 1),
                                      thickness: 2,
                                    ),
                                    SizedBox(height: 10),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double fontSize =
                                            constraints.maxWidth > 600
                                            ? 22
                                            : 20;
                                        double paddingLeft =
                                            constraints.maxWidth > 600
                                            ? 40.0
                                            : 30.0;
                                        double paddingRight =
                                            constraints.maxWidth > 600
                                            ? 15.0
                                            : 10.0;
                                        double iconSize =
                                            constraints.maxWidth > 600
                                            ? 24.0
                                            : 20.0;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: paddingLeft,
                                                    right: paddingRight,
                                                  ),
                                                  child: Text(
                                                    "Show All Reviews",
                                                    style: TextStyle(
                                                      fontSize: fontSize,
                                                      color: Color.fromRGBO(
                                                        0,
                                                        147,
                                                        255,
                                                        1,
                                                      ),
                                                      fontFamily: "DMSans",
                                                    ),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: iconSize,
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    SizedBox(height: 30),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double fontSize =
                                            constraints.maxWidth > 600
                                            ? 28
                                            : 25;
                                        double paddingValue =
                                            constraints.maxWidth > 600
                                            ? 20.0
                                            : 10.0;

                                        return Padding(
                                          padding: EdgeInsets.all(paddingValue),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Latest Blog Posts",
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "DMSans",
                                                ),
                                              ),
                                              Divider(
                                                color: Color.fromRGBO(
                                                  219,
                                                  219,
                                                  219,
                                                  1,
                                                ),
                                                thickness: 2,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),

                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double screenWidth =
                                            constraints.maxWidth;
                                        double imageHeight = screenWidth > 600
                                            ? 300
                                            : 240;
                                        double textSize = screenWidth > 600
                                            ? 20
                                            : 18;
                                        double buttonPadding = screenWidth > 600
                                            ? 25
                                            : 20;

                                        return blogs.isEmpty
                                            ? Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : Padding(
                                                padding: EdgeInsets.all(0),
                                                child: CarouselSlider(
                                                  options: CarouselOptions(
                                                    height: screenWidth > 600
                                                        ? 420
                                                        : 370,
                                                    autoPlay: false,
                                                    autoPlayInterval: Duration(
                                                      seconds: 3,
                                                    ),
                                                    autoPlayAnimationDuration:
                                                        Duration(
                                                          milliseconds: 800,
                                                        ),
                                                    enlargeCenterPage: false,
                                                    enableInfiniteScroll: true,
                                                    viewportFraction:
                                                        screenWidth > 600
                                                        ? 0.8
                                                        : 0.9,
                                                  ),
                                                  items: blogs.map((blog) {
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                child:
                                                                    getImageBytes(
                                                                          blog,
                                                                        ) !=
                                                                        null
                                                                    ? Image.memory(
                                                                        getImageBytes(
                                                                          blog,
                                                                        )!,
                                                                        height:
                                                                            imageHeight,
                                                                        width: double
                                                                            .infinity,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      )
                                                                    : Image.asset(
                                                                        "assets/placeholder.png",
                                                                        height:
                                                                            imageHeight,
                                                                        width: double
                                                                            .infinity,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                              ),
                                                              Positioned(
                                                                top: 5,
                                                                left: 5,
                                                                child: ElevatedButton(
                                                                  onPressed:
                                                                      () {},
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .black,
                                                                    padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          buttonPadding,
                                                                      vertical:
                                                                          8,
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    blog["title"] ??
                                                                        "",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          textSize -
                                                                          3,
                                                                      fontFamily:
                                                                          "DMSans",
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      5.0,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  blog["author"] ??
                                                                      "Unknown",
                                                                  style: TextStyle(
                                                                    color:
                                                                        Color.fromRGBO(
                                                                          5,
                                                                          11,
                                                                          32,
                                                                          1,
                                                                        ),
                                                                    fontFamily:
                                                                        "DMSans",
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Icon(
                                                                  Icons.circle,
                                                                  size: 8,
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        225,
                                                                        225,
                                                                        225,
                                                                        1,
                                                                      ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  formatDate(
                                                                    blog['updatedAt'] ??
                                                                        "",
                                                                  ),
                                                                  style: TextStyle(
                                                                    color:
                                                                        Color.fromRGBO(
                                                                          5,
                                                                          11,
                                                                          32,
                                                                          1,
                                                                        ),
                                                                    fontFamily:
                                                                        "DMSans",
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) => BlogDetailsScreen(
                                                                        blog:
                                                                            blog,
                                                                      ),
                                                                ),
                                                              );
                                                            },
                                                            child: Text(
                                                              blog["excerpt"] ??
                                                                  " ",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    textSize,
                                                                color:
                                                                    Color.fromRGBO(
                                                                      5,
                                                                      11,
                                                                      32,
                                                                      1,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily:
                                                                    "DMSans",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              );
                                      },
                                    ),

                                    SizedBox(height: 20),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double screenWidth =
                                            constraints.maxWidth;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                              233,
                                              242,
                                              255,
                                              1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth > 600 ? 50 : 40,
                                              top: screenWidth > 600 ? 60 : 50,
                                              bottom: screenWidth > 600
                                                  ? 50
                                                  : 40,
                                              right: screenWidth > 600
                                                  ? 50
                                                  : 40,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Are You Looking \nFor a Car?",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: screenWidth > 600
                                                        ? 20
                                                        : 16.73,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 0,
                                                      ),
                                                  child: Text(
                                                    "We are committed to providing our customers with exceptional service.",
                                                    style: TextStyle(
                                                      fontFamily: "DMSans",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          screenWidth > 600
                                                          ? 14
                                                          : 12.36,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Color.fromRGBO(
                                                              26,
                                                              76,
                                                              142,
                                                              1,
                                                            ),
                                                        foregroundColor:
                                                            Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              1,
                                                            ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  screenWidth >
                                                                      600
                                                                  ? 20
                                                                  : 15,
                                                              vertical:
                                                                  screenWidth >
                                                                      600
                                                                  ? 18
                                                                  : 15,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Get Started",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  screenWidth >
                                                                      600
                                                                  ? 14
                                                                  : 11.36,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "DMSans",
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_outward_sharp,
                                                            size:
                                                                screenWidth >
                                                                    600
                                                                ? 24
                                                                : 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.1,
                                                    ),
                                                    Image.asset(
                                                      "assets/Home_Images/Footer_Images/lookingCar.png",
                                                      height: screenWidth > 600
                                                          ? 100
                                                          : 75,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 20),
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        double screenWidth =
                                            constraints.maxWidth;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(
                                              255,
                                              233,
                                              243,
                                              1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: screenWidth > 600 ? 50 : 40,
                                              top: screenWidth > 600 ? 60 : 50,
                                              bottom: screenWidth > 600
                                                  ? 50
                                                  : 40,
                                              right: screenWidth > 600
                                                  ? 50
                                                  : 40,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Best place for \ncar financing",
                                                  style: TextStyle(
                                                    fontFamily: "DMSans",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: screenWidth > 600
                                                        ? 20
                                                        : 16.73,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 0,
                                                      ),
                                                  child: Text(
                                                    "We are committed to providing our customers with exceptional service.",
                                                    style: TextStyle(
                                                      fontFamily: "DMSans",
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize:
                                                          screenWidth > 600
                                                          ? 14
                                                          : 12.36,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {},
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Color.fromRGBO(
                                                              5,
                                                              11,
                                                              32,
                                                              1,
                                                            ),
                                                        foregroundColor:
                                                            Color.fromRGBO(
                                                              255,
                                                              255,
                                                              255,
                                                              1,
                                                            ),
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  screenWidth >
                                                                      600
                                                                  ? 20
                                                                  : 15,
                                                              vertical:
                                                                  screenWidth >
                                                                      600
                                                                  ? 18
                                                                  : 15,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Get Started",
                                                            style: TextStyle(
                                                              fontSize:
                                                                  screenWidth >
                                                                      600
                                                                  ? 14
                                                                  : 11.36,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontFamily:
                                                                  "DMSans",
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_outward_sharp,
                                                            size:
                                                                screenWidth >
                                                                    600
                                                                ? 24
                                                                : 20,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: screenWidth * 0.1,
                                                    ),
                                                    Image.asset(
                                                      "assets/Home_Images/Footer_Images/carFinance.png",
                                                      height: screenWidth > 600
                                                          ? 100
                                                          : 80,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 30),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
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

Widget buildBrandCard(
  BuildContext context, {
  required String logo,
  required String title,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchedVehicles(
            vehicles: HomeApi.searchCar(title),
            query: title,
          ),
        ),
      );
    },
    child: Container(
      width: 80,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Color.fromRGBO(233, 233, 233, 1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Image.asset(logo, fit: BoxFit.contain),
            Text(title, style: TextStyle(fontFamily: "DMSans")),
          ],
        ),
      ),
    ),
  );
}

Widget buildBulletPoint(BuildContext context, String text) {
  double screenWidth = MediaQuery.of(context).size.width;
  return ListTile(
    leading: Icon(
      Icons.check_circle,
      color: Color(0xFF004C90),
      size: screenWidth * 0.05,
    ),
    title: Text(
      text,
      style: TextStyle(fontSize: screenWidth * 0.035, fontFamily: "DMSans"),
    ),
    contentPadding: EdgeInsets.zero,
  );
}

Widget buildStatBox(BuildContext context, String number, String label) {
  double screenWidth = MediaQuery.of(context).size.width;
  return Container(
    padding: EdgeInsets.symmetric(
      vertical: screenWidth * 0.05,
      horizontal: screenWidth * 0.02,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: screenWidth * 0.06,
            fontWeight: FontWeight.w700,
            fontFamily: "DMSans",
          ),
        ),
        SizedBox(height: screenWidth * 0.015),
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(5, 11, 32, 1),
            fontFamily: "DMSans",
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
