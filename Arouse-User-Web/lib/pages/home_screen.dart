import 'dart:typed_data';
import 'package:flutter/services.dart';

import 'package:arouse_ecommerce_frontend_web/api/home_api.dart';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_scrolable_button.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/blog_post.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/featured_car_card.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/footer_section.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/test_drive_dialog.dart';
import 'package:arouse_ecommerce_frontend_web/components/home/why_choose_us_card.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_colors.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/pages/all_blogs_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/blog_details_screen.dart';
import 'package:arouse_ecommerce_frontend_web/pages/search_vehicles.dart';
import 'package:arouse_ecommerce_frontend_web/utils/app_preferences.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List blogs = [];
  bool isLoading = true;
  List<Map<String, dynamic>> featuredCars = [];
  String selectedCity = "New Delhi";
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    loadBlogs();
    getCars();
    loadCity();
    loadAllCarsForSearch();

    AuthService.instance.refresh();

    searchController.addListener(_onSearchTextChanged);
    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        // Delay hiding suggestions to allow tap on list item
        Future.delayed(Duration(milliseconds: 200), () {
            if (!searchFocusNode.hasFocus) _hideSuggestions();
        });
      }
    });

    searchFocusNode.onKeyEvent = (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          if (searchSuggestions.isNotEmpty) {
            setState(() {
              selectedIndex = (selectedIndex + 1) % searchSuggestions.length;
              searchController.text = searchSuggestions[selectedIndex];
              searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
            });
            return KeyEventResult.handled;
          }
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          if (searchSuggestions.isNotEmpty) {
            setState(() {
                selectedIndex = (selectedIndex - 1 + searchSuggestions.length) % searchSuggestions.length;
                searchController.text = searchSuggestions[selectedIndex];
                searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
            });
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    };
  }

  void loadAllCarsForSearch() async {
    final cars = await VehiclesApi.getAllCars();
    setState(() {
      allCars = cars;
    });
  }

  void loadCity() async {
    selectedCity = await AppPreferences.getSelectedCity();
    var city = await VehiclesApi().fetchRtoCities();

    setState(() {
      cities = city;
    });
    // print(selectedCity);
  }

  void onCitySelected(String city) async {
    await AppPreferences.setSelectedCity(city);

    setState(() {
      selectedCity = city;
    });
  }

  // login state handled by AuthService
  Future<void> getCars() async {
    var car = await VehiclesApi.getAllCars();
    for (var c in car) {
      if (c["isFeatured"]) {
        featuredCars.add(c);
      }
      setState(() {});
    }

    //print('featuredCars: $featuredCars');
  }

  void loadBlogs() async {
    blogs = await HomeApi().getAllBlog();
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

  String formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd MMMM yyyy').format(parsedDate);
  }

  TextEditingController searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> searchResults;
  List<Map<String, dynamic>> allCars = [];
  List<String> searchSuggestions = [];
  FocusNode searchFocusNode = FocusNode();
  bool showSuggestions = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _searchBarKey = GlobalKey();
  int selectedIndex = -1;

  @override
  void dispose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    searchFocusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        searchSuggestions = [];
        showSuggestions = false;
        selectedIndex = -1;
      });
      _hideSuggestions();
      return;
    }

    // Generate suggestions from all cars
    Set<String> suggestions = {};
    
    for (var car in allCars) {
      final brand = car['brandName']?.toString().toLowerCase() ?? '';
      final model = car['name']?.toString().toLowerCase() ?? '';
      
      if (brand.startsWith(query)) {
        suggestions.add(car['brandName'] ?? '');
      }
      
      if (model.startsWith(query)) {
        suggestions.add(car['name'] ?? '');
      }
      
      // Check variants
      final variants = car['variants'] as List<dynamic>?;
      if (variants != null) {
        for (var variant in variants) {
          final variantName = variant['name']?.toString().toLowerCase() ?? '';
          if (variantName.startsWith(query)) {
            suggestions.add(variant['name'] ?? '');
          }
        }
      }
    }

    setState(() {
      searchSuggestions = suggestions.take(6).toList();
      showSuggestions = suggestions.isNotEmpty;
    });

    if (showSuggestions) {
      _showSuggestions();
    } else {
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      showSuggestions = false;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox?;
    var size = renderBox?.size ?? Size(AppSizes.screenWidth(context) * 0.4, 50);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: searchSuggestions.length,
                separatorBuilder: (context, index) => Divider(height: 1),
                itemBuilder: (context, index) {
                  return Container(
                    color: selectedIndex == index ? Colors.grey.shade100 : Colors.transparent,
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      title: Text(
                        searchSuggestions[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'DM Sans',
                          fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        searchController.text = searchSuggestions[index];
                        _hideSuggestions();
                        searchCar(searchSuggestions[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  int selectedTab = 0;

  final List<String> tabs = ["All", "Sedans", "Hatchback", "SUV's", "MUV's"];
  void searchCar(String query) {
    searchResults = HomeApi.searchCar(query);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchedVehicles(
          vehicles: searchResults,
          query: searchController.text,
        ),
      ),
    );
  }

  void openLocationDialog(BuildContext context) {
    String searchText = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final filtered = cities
                .where(
                  (e) => e.toLowerCase().contains(searchText.toLowerCase()),
                )
                .toList();

            return Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Search box
                    TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search your city",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => searchText = v),
                    ),

                    const SizedBox(height: 10),

                    /// List
                    SizedBox(
                      height: 350,
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final city = filtered[index];

                          return ListTile(
                            title: Text(city),
                            onTap: () {
                              onCitySelected(city);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openLanguageDialog(BuildContext context) {
    final languages = ["English", "Hindi"];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(16),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Language",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...languages.map(
                  (e) => ListTile(
                    title: Text(e),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),

      backgroundColor: const Color(0xFF071224),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: AppSizes.isDesktop(context)
                      ? AppSizes.screenHeight(context) * 0.9
                      : AppSizes.isTablet(context)
                      ? AppSizes.screenHeight(context) * 0.7
                      : AppSizes.screenHeight(context) * 0.5,
                  width: AppSizes.screenWidth(context),
                  child: Image.asset(
                    "assets/carbackground.jpeg",
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.45)),
                ),

                Positioned(
                  left: 20,
                  right: 20,
                  top: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Location Button
                      InkWell(
                        onTap: () => openLocationDialog(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFFFFFFFF),
                            ),
                            SizedBox(width: 4),
                            Text(
                              selectedCity,
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.63,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down, // dropdown icon
                              color: Color(0xFFFFFFFF),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 20),

                      /// Language Button
                      InkWell(
                        onTap: () => openLanguageDialog(context),
                        child: Row(
                          children: const [
                            Icon(Icons.language, color: Color(0xFFFFFFFF)),
                            SizedBox(width: 4),
                            Text(
                              "English",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0.63,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down, // dropdown icon
                              color: Color(0xFFFFFFFF),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CAppbar(),
                    ),
                  ),
                ),
                Positioned(
                  bottom: AppSizes.isDesktop(context)
                      ? 200
                      : AppSizes.isTablet(context)
                      ? 80
                      : 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      if (!AppSizes.isMobile(context))
                        Text(
                          "Find Your Perfect Car",
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: AppSizes.extraLargeFont(context),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),

                      /// Search Bar (Responsive)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = AppSizes.isMobile(context);
                          final isTablet = AppSizes.isTablet(context);
                          final isDesktop = AppSizes.isDesktop(context);

                          double barWidth;

                          if (isDesktop) {
                            barWidth = AppSizes.screenWidth(context) * 0.4;
                          } else if (isTablet) {
                            barWidth = AppSizes.screenWidth(context) * 0.6;
                          } else {
                            barWidth = AppSizes.screenWidth(context) * 0.9;
                          }

                          return CompositedTransformTarget(
                            link: _layerLink,
                            child: Container(
                              key: _searchBarKey, // Added Key
                              width: barWidth,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 14 : 24,
                                vertical: isMobile ? 4 : 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      focusNode: searchFocusNode,
                                      decoration: InputDecoration(
                                        hintText: "Search brand, model...",
                                        hintStyle: TextStyle(
                                          fontSize: isMobile ? 12 : 14,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      onSubmitted: (value) {
                                        if (value.isNotEmpty) {
                                          _hideSuggestions();
                                          searchCar(value);
                                        }
                                      },
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      if (searchController.text.isNotEmpty) {
                                        _hideSuggestions();
                                        searchCar(searchController.text);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A4C8E),
                                      shape: const StadiumBorder(),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobile ? 10 : 18,
                                        vertical: isMobile ? 8 : 12,
                                      ),
                                    ),
                                    child: isMobile
                                        ? const Icon(
                                            Icons.search,
                                            color: Colors.white,
                                          )
                                        : Row(
                                            children: const [
                                              Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Search",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'DM Sans',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -90),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF9FBFC),
                  borderRadius: BorderRadius.circular(
                    AppSizes.isDesktop(context)
                        ? 100
                        : AppSizes.isTablet(context)
                        ? 80
                        : 50,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      spreadRadius: 2,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.screenWidth(context) * 0.01,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Featured Cars',
                                  style: TextStyle(
                                    color: Color(0xFF404040),
                                    fontSize: AppSizes.titleFont(context),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
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
                                          color: AppColors.textButtoTextColor,
                                          fontSize: AppSizes.buttonFontSize(
                                            context,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "DMSans",
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            AppSizes.screenWidth(context) *
                                            0.01,
                                      ),
                                      Icon(
                                        Icons.arrow_outward,
                                        color: AppColors.textButtoTextColor,
                                        size: AppSizes.iconMedium(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            children: List.generate(tabs.length, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 30.0),
                                child: CScrolableButton(
                                  label: tabs[index],
                                  isSelected: selectedTab == index,
                                  onTap: () {
                                    setState(() {
                                      selectedTab = index;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      Container(height: 1.5, color: Color(0xFFBDBDBD)),

                      SizedBox(height: AppSizes.screenHeight(context) * 0.03),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          double aspectRatio;

                          if (constraints.maxWidth < 450) {
                            crossAxisCount = 3;
                            aspectRatio = 0.8;
                          } else if (constraints.maxWidth < 600) {
                            crossAxisCount = 4;
                            aspectRatio = 1.0;
                          } else if (constraints.maxWidth < 800) {
                            crossAxisCount = 4;
                            aspectRatio = 1.2;
                          } else if (constraints.maxWidth < 1024) {
                            crossAxisCount = 4;
                            aspectRatio = 1.6;
                          } else {
                            crossAxisCount = 5;
                            aspectRatio = 3;
                          }

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: aspectRatio,
                            children: [
                              buildCompanyCard(
                                onTap: () => searchCar("Hyundai"),
                                label: "Hyundai",
                                logo: "assets/hyundai_logo.png",
                                context,
                              ),
                              buildCompanyCard(
                                onTap: () => searchCar("Kia"),
                                label: "Kia",
                                logo: "assets/kia_logo.png",
                                context,
                              ),
                              buildCompanyCard(
                                onTap: () => searchCar("Ford"),
                                label: "Ford",
                                logo: "assets/ford_logo.jpeg",
                                context,
                              ),
                              buildCompanyCard(
                                onTap: () => searchCar("Maruti Suzuki"),
                                label: "Maruti Suzuki",
                                logo: "assets/maruti_logo.png",
                                context,
                              ),
                              buildCompanyCard(
                                onTap: () => searchCar("Volkswagen"),
                                label: "Volkswagen",
                                logo: "assets/volkswagan_logo.jpeg",
                                context,
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      featuredCars.isNotEmpty
                          ? CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: true,
                                enlargeCenterPage: false,
                                viewportFraction: AppSizes.isMobile(context)
                                    ? 1.0
                                    : 0.6,
                                height: AppSizes.screenWidth(context) < 450
                                    ? AppSizes.screenHeight(context) * 0.5
                                    : AppSizes.screenWidth(context) < 600
                                    ? AppSizes.screenHeight(context) * 0.55
                                    : AppSizes.screenWidth(context) < 800
                                    ? AppSizes.screenHeight(context) * 0.46
                                    : AppSizes.screenWidth(context) < 1000
                                    ? AppSizes.screenHeight(context) * 0.55
                                    : AppSizes.screenWidth(context) < 1200
                                    ? AppSizes.screenHeight(context) * 0.6
                                    : AppSizes.screenWidth(context) < 1500
                                    ? AppSizes.screenHeight(context) * 0.7
                                    : AppSizes.screenHeight(context) * 0.8,
                              ),
                              items: featuredCars
                                  .map((c) => FeaturedCarCard(car: c))
                                  .toList(),
                            )
                          : Center(child: CircularProgressIndicator()),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      Text(
                        'Explore Brands',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: AppSizes.titleFont(context),
                          fontWeight: FontWeight.w700,
                          fontFamily: "DM Sans",
                        ),
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          double aspectRatio;
                          if (constraints.maxWidth < 450) {
                            crossAxisCount = 3;
                            aspectRatio = 0.7;
                          } else if (constraints.maxWidth < 600) {
                            crossAxisCount = 4;
                            aspectRatio = 0.8;
                          } else if (constraints.maxWidth < 800) {
                            crossAxisCount = 4;
                            aspectRatio = 1.0;
                          } else if (constraints.maxWidth < 1080) {
                            crossAxisCount = 4;
                            aspectRatio = 1.2;
                          } else if (constraints.maxWidth < 1400) {
                            crossAxisCount = 4;
                            aspectRatio = 1.4;
                          } else {
                            crossAxisCount = 5;
                            aspectRatio = 1.4;
                          }
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: aspectRatio,
                            children: [
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Hyundai"),
                                label: "Hyundai",
                                logo: "assets/hyundai_logo.png",
                              ),
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Kia"),
                                label: "Kia",
                                logo: "assets/kia_logo.png",
                              ),
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Ford"),
                                label: "Ford",
                                logo: "assets/ford_logo.jpeg",
                              ),
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Skoda"),
                                label: "Skoda",
                                logo: "assets/skoda_logo.png",
                              ),
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Maruti Suzuki"),
                                label: "Maruti Suzuki",
                                logo: "assets/maruti_logo.png",
                              ),
                              buildExploreBrandCompanyCard(
                                context,
                                onTap: () => searchCar("Volkswagen"),
                                label: "Volkswagen",
                                logo: "assets/volkswagan_logo.jpeg",
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          bool isMobile = constraints.maxWidth < 900;

                          double videoHeight = isMobile ? 420 : 693;

                          return Column(
                            children: [
                              if (isMobile) _videoSection(videoHeight),

                              if (isMobile) _textSection(context),

                              if (!isMobile)
                                SizedBox(
                                  height: videoHeight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _videoSection(videoHeight),
                                      ),
                                      Container(
                                        width: 867,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEEF1FB),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 80,
                                          ),
                                          child: _textSection(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.03),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount;
                          double aspectRatio;

                          if (constraints.maxWidth < 600) {
                            aspectRatio = 1.5;
                            crossAxisCount = 2; // 📱 small screen → 2 per row
                          } else if (constraints.maxWidth < 1080) {
                            aspectRatio = 2.0;
                            crossAxisCount = 3;
                          } else {
                            aspectRatio = 2.5;
                            crossAxisCount = 4; // 🖥️ large screen → 4 per row
                          }

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio:
                                aspectRatio, // keeps items wider than tall
                            children: [
                              _statItem(context, '836M', 'CARS FOR SALE'),
                              _statItem(context, '738M', 'DEALER REVIEWS'),
                              _statItem(context, '100M', 'VISITORS PER DAY'),
                              _statItem(context, '238M', 'VERIFIED DEALERS'),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.03),
                      Divider(),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.04),
                      Text(
                        'Why Choose Us?',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.titleFont(context),
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 40),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double aspectRatio;
                          int crossAxisCount;

                          if (constraints.maxWidth < 400) {
                            aspectRatio = 1.2;
                            crossAxisCount = 1; // 📱 small screen → 2 per row
                          } else if (constraints.maxWidth < 600) {
                            aspectRatio = 2.0;
                            crossAxisCount = 1; // 📊 medium screen → 3 per row
                          } else if (constraints.maxWidth < 800) {
                            aspectRatio = 1.5;
                            crossAxisCount = 2; // 📊 medium screen → 3 per row
                          } else if (constraints.maxWidth < 1100) {
                            aspectRatio = 1.2;
                            crossAxisCount = 3; // 📊 medium screen → 3 per row
                          } else {
                            aspectRatio = 1.2;
                            crossAxisCount = 4; // 🖥️ large screen → 4 per row
                          }

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio:
                                aspectRatio, // keeps cards balanced
                            children: [
                              WhyChooseUsCard(
                                icon: 'assets/icons/f1.svg',
                                label: 'Special Financing Offers',
                                subtitle1:
                                    'Our stress-free finance department that can',
                                subtitle2:
                                    'find financial solutions to save you money.',
                              ),
                              WhyChooseUsCard(
                                icon: 'assets/icons/f2.svg',
                                label: 'Trusted Car Dealership',
                                subtitle1:
                                    'Our stress-free finance department that can',
                                subtitle2:
                                    'find financial solutions to save you money.',
                              ),
                              WhyChooseUsCard(
                                icon: 'assets/icons/f3.svg',
                                label: 'Transparent Pricing',
                                subtitle1:
                                    'Our stress-free finance department that can',
                                subtitle2:
                                    'find financial solutions to save you money.',
                              ),
                              WhyChooseUsCard(
                                icon: 'assets/icons/f4.svg',
                                label: 'Expert Car Service',
                                subtitle1:
                                    'Our stress-free finance department that can',
                                subtitle2:
                                    'find financial solutions to save you money.',
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;
                          bool isMobile = screenWidth < 600;

                          if (isMobile) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What our customers say',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: AppSizes.titleFont(context),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Rated 4.7 / 5 based on 28,370 reviews Showing our 4 & 5 star reviews',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: AppSizes.smallFont(context),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'What our customers say',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: AppSizes.titleFont(context),
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    'Rated 4.7 / 5 based on 28,370 reviews Showing our 4 & 5 star reviews',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontWeight: FontWeight.w400,
                                      fontSize: AppSizes.smallFont(context),
                                      color: AppColors.primaryColor,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 30),

                      // ✅ Image + review details responsive
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;
                          bool isMobile = screenWidth < 600;
                          bool isTablet =
                              screenWidth >= 600 && screenWidth < 1024;

                          if (isMobile) {
                            // 📱 Mobile → stacked, image full width
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/customer.png',
                                  width: double.infinity, // 🔑 full width
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 20),
                                _reviewDetails(context),
                                const SizedBox(height: 20),
                                _arrowButton(),
                              ],
                            );
                          } else if (isTablet) {
                            // 📊 Tablet → row with medium image
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'assets/customer.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: _reviewDetails(context),
                                ),
                                const SizedBox(width: 20),
                                _arrowButton(),
                              ],
                            );
                          } else {
                            // 🖥️ Desktop → row with fixed image size
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  'assets/customer.png',
                                  width: 320,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 80),
                                Expanded(child: _reviewDetails(context)),
                                const SizedBox(width: 40),
                                _arrowButton(),
                              ],
                            );
                          }
                        },
                      ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Latest Blog Posts',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: AppSizes.titleFont(context),
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AllBlogsScreen(allBlogs: blogs),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    color: AppColors.textButtoTextColor,
                                    fontSize: AppSizes.buttonFontSize(context),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "DMSans",
                                  ),
                                ),
                                SizedBox(
                                  width: AppSizes.screenWidth(context) * 0.01,
                                ),
                                Icon(
                                  Icons.arrow_outward,
                                  color: AppColors.textButtoTextColor,
                                  size: AppSizes.iconMedium(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSizes.screenHeight(context) * 0.03),

                      // ✅ Blog cards horizontally scrollable
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : blogs.isEmpty
                          ? const Text("No blogs found")
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: blogs.map<Widget>((blog) {
                                  Uint8List? imageBytes = getImageBytes(blog);

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: BlogPost(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BlogDetailsScreen(
                                                  blog: blog,
                                                  allBlogs: blogs,
                                                ),
                                          ),
                                        );
                                      },
                                      carImageBytes: imageBytes,
                                      buttonLabel: blog["category"] ?? "Blog",
                                      title: blog["title"] ?? "No Title",
                                      date: formatDate(blog["createdAt"] ?? ""),
                                      user: blog["author"] ?? "Admin",
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                      SizedBox(height: AppSizes.screenHeight(context) * 0.05),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // bool showTwoCards =
                          //     constraints.maxWidth > 1024; // desktop only

                          return Wrap(
                            spacing: 30,
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: [
                              bottomGettingStartedCard(
                                context,
                                buttonColor: 0xFF1A4C8E,
                                cardColor: 0xFFE9F2FF,
                                label: "Are You Looking For a Car ?",
                                subtitle:
                                    "We are committed to providing our customers with exceptional service.",
                                icon: "assets/icons/bottomCard1.svg",
                              ),
                              bottomGettingStartedCard(
                                context,
                                buttonColor: 0xFF050B20,
                                cardColor: 0xFFFFE9F3,
                                label: "Best place for car financing",
                                subtitle:
                                    "We are committed to providing our customers with exceptional service.",
                                icon: "assets/icons/bottomCard2.svg",
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            FooterSection(),
          ],
        ),
      ),
    );
  }
}

Widget _statItem(BuildContext context, String value, String label) {
  double screenWidth = MediaQuery.of(context).size.width;
  bool isMobile = screenWidth < 600;
  bool isTablet = screenWidth >= 600 && screenWidth < 1100;

  double valueFontSize = isMobile
      ? 20
      : isTablet
      ? 24
      : 28;
  double labelFontSize = isMobile
      ? 12
      : isTablet
      ? 14
      : 16;

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: valueFontSize,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: labelFontSize,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    ),
  );
}

Widget _videoSection(double videoHeight) {
  return SizedBox(
    height: videoHeight,
    width: double.infinity,

    child: Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/videoImage.jpeg',
          width: double.infinity,
          height: videoHeight,
          fit: BoxFit.cover,
        ),
        Container(
          height: 80,
          width: 80,
          decoration: const BoxDecoration(
            color: Color(0XFFFFFFFF),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/video_pause.svg',
            fit: BoxFit.scaleDown,
          ),
        ),
      ],
    ),
  );
}

Widget _textSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buying a car has never been this easy.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.titleFont(context),
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'We are committed to providing our customers with exceptional service, competitive pricing, and a wide range of.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: AppSizes.bodyFont(context),
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(height: 22),

        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/right_tick.svg'),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We are the UK’s largest provider, with more patrols in more places',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: AppSizes.bodyFont(context),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 45),
        SizedBox(
          width: 206,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TestDriveDialog(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004C90),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Book a test Drive',
                  style: TextStyle(
                    fontFamily: "DM Sans",
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                const SizedBox(width: 12),
                SvgPicture.asset('assets/icons/arrow_up.svg'),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _reviewDetails(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            height: 25,
            width: 40,
            decoration: BoxDecoration(
              color: Color(0xFFE1C03F),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Center(
              child: Text(
                "5.0",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 17),
      Text(
        'Ali TUFAN',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.bodyFont(context),
          color: AppColors.primaryColor,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Designer',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.smallFont(context),
          color: AppColors.primaryColor,
        ),
      ),
      SizedBox(height: 35),
      Text(
        'Id suggest Macklin Motors Nissan Glasgow South to a friend because I had great service from my salesman Patrick and all of the team.',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.mediumFont(context),
          height: 1.4,
          color: AppColors.primaryColor,
        ),
      ),
    ],
  );
}

Widget _arrowButton() {
  return Container(
    width: 60,
    height: 40,
    decoration: BoxDecoration(border: Border.all(color: Color(0xFFE9E9E9))),
    child: Icon(Icons.arrow_forward_ios),
  );
}

Widget bottomGettingStartedCard(
  BuildContext context, {
  required int buttonColor,
  required int cardColor,
  required String label,
  required String subtitle,
  required String icon,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  bool isMobile = screenWidth < 600;
  bool isTablet = screenWidth >= 600 && screenWidth < 1024;
  bool isDesktop = screenWidth >= 1024;

  // 🔑 Responsive sizing
  double cardWidth = isDesktop
      ? 500
      : isTablet
      ? 400
      : screenWidth * 0.9;

  EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: isDesktop
        ? 40
        : isTablet
        ? 32
        : 20,
    vertical: isDesktop
        ? 40
        : isTablet
        ? 32
        : 20,
  );

  double titleFontSize = isDesktop
      ? 26
      : isTablet
      ? 22
      : 18;
  double subtitleFontSize = isDesktop
      ? 16
      : isTablet
      ? 15
      : 14;

  return Container(
    width: cardWidth,
    padding: cardPadding,
    decoration: BoxDecoration(
      color: Color(cardColor),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: titleFontSize,
            color: const Color(0xFF050B20),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w400,
            fontSize: subtitleFontSize,
            color: const Color(0xFF050B20),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(buttonColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 🔑 prevents overflow
                  children: [
                    const Text(
                      'Get Started',
                      style: TextStyle(
                        fontFamily: "DM Sans",
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SvgPicture.asset('assets/icons/arrow_up.svg', height: 16),
                  ],
                ),
              ),
            ),
            SvgPicture.asset(icon, height: 48),
          ],
        ),
      ],
    ),
  );
}

Widget buildCompanyCard(
  BuildContext context, {
  required String logo,
  required String label,
  required VoidCallback onTap,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  bool isDesktop = screenWidth >= 1024;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E9E9), width: 1.15),
          borderRadius: BorderRadius.circular(18),
        ),
        // 🔑 Prevent oversized box: wrap content tightly
        constraints: const BoxConstraints(
          minWidth: 120,
          maxWidth: 180, // keeps it compact on desktop
        ),
        child: isDesktop
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(logo, height: 40, width: 40),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF050B20),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    logo,
                    height: screenWidth < 480
                        ? 32
                        : 36, // 🔑 smaller logo on very small screens
                    width: screenWidth < 480 ? 32 : 36,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth < 480
                          ? 12
                          : 14, // 🔑 smaller font on very small screens
                      color: const Color(0xFF050B20),
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    ),
  );
}

Widget buildExploreBrandCompanyCard(
  BuildContext context, {
  required String logo,
  required String label,
  required VoidCallback onTap,
}) {
  double screenWidth = MediaQuery.of(context).size.width;
  bool isMobile = screenWidth < 600;
  bool isTablet = screenWidth >= 600 && screenWidth < 1024;

  // Scale sizes based on screen type
  double logoSize = isMobile
      ? 36
      : isTablet
      ? 44
      : 70;
  double fontSize = isMobile
      ? 14
      : isTablet
      ? 16
      : 20;
  EdgeInsets padding = isMobile
      ? const EdgeInsets.symmetric(vertical: 16, horizontal: 16)
      : isTablet
      ? const EdgeInsets.symmetric(vertical: 24, horizontal: 24)
      : const EdgeInsets.symmetric(vertical: 30, horizontal: 30);

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9E9E9), width: 1.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              logo,
              height: logoSize,
              width: logoSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                fontSize: fontSize,
                color: const Color(0xFF050B20),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
