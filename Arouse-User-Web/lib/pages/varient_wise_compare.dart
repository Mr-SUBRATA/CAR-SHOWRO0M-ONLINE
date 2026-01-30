import 'package:arouse_ecommerce_frontend_web/common_widgets/C_AppBar.dart';
import 'package:arouse_ecommerce_frontend_web/common_widgets/C_Drawer.dart';
import 'package:arouse_ecommerce_frontend_web/constants/app_sizes.dart';
import 'package:arouse_ecommerce_frontend_web/utils/auth_service.dart'
    show AuthService;
import 'package:flutter/material.dart';

class VariantsWiseCompare extends StatelessWidget {
  final List<dynamic> variants;
  final String carName;
  const VariantsWiseCompare({super.key, required this.variants, required this.carName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CAppbar(),
      endDrawer: ValueListenableBuilder<bool>(
        valueListenable: AuthService.instance.isLoggedIn,
        builder: (_, loggedIn, __) => CDrawer(isLoggedIn: loggedIn),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.isDesktop(context) ? 40.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 46),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1A4C8E), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(46),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '< < Back',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: AppSizes.smallFont(context),
                    color: const Color(0xFF1A4C8E),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                '$carName Variants (${variants.length})',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: AppSizes.titleFont(context),
                ),
              ),
              const SizedBox(height: 37),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  final isDesktop = maxW >= 1100;
                  final isTablet = maxW >= 700 && maxW < 1100;
                  final crossCount = isDesktop ? 3 : (isTablet ? 2 : 1);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: variants.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                                mainAxisExtent: isDesktop
                                    ? 560
                                    : (isTablet ? 640 : 760),
                              ),
                          itemBuilder: (context, index) {
                            final v = variants[index];
                            return VariantCard(
                              title: v["name"] ?? 'Variant',
                              transmission: v["transmission"] ?? '',
                              fuel: v["fuelType"] ?? '',
                              price: v.containsKey('price') && v['price'] != null
                                  ? '₹ ${(v["price"] / 100000).toStringAsFixed(2)} Lakhs*'
                                  : 'Price N/A',
                              features: _getTopFeatures(v),
                              showRightDivider:
                                  isDesktop && index < variants.length - 1,
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
      ),
    );
  }
}

/// Helper function to extract top features from variant data
/// Uses safety features and technology specs as the source
List<String> _getTopFeatures(Map<String, dynamic> variant) {
  List<String> topFeatures = [];
  
  // Add safety features (these are already string arrays)
  if (variant['safety'] != null && variant['safety'] is List) {
    topFeatures.addAll(List<String>.from(variant['safety']));
  }
  
  // Add technology specs from specifications
  if (variant['specifications'] != null) {
    final specs = variant['specifications'];
    if (specs['technology'] != null && specs['technology'] is List) {
      topFeatures.addAll(List<String>.from(specs['technology']));
    }
    // Also add overview specs if not enough features
    if (topFeatures.length < 5 && specs['overview'] != null && specs['overview'] is List) {
      for (var item in specs['overview']) {
        if (!topFeatures.contains(item.toString())) {
          topFeatures.add(item.toString());
        }
      }
    }
  }
  
  return topFeatures;
}

class VariantCard extends StatelessWidget {
  final String title;
  final String transmission;
  final String fuel;
  final String price;
  final List<String> features;
  final bool showRightDivider;

  const VariantCard({
    super.key,
    required this.title,
    required this.transmission,
    required this.fuel,
    required this.price,
    required this.features,
    this.showRightDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: AppSizes.bodyFont(context),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.settings,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            transmission,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 2,
                            height: 20,
                            color: Colors.grey.shade100,
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.local_gas_station,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            fuel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Price: $price",
                        style: TextStyle(
                          fontSize: AppSizes.smallFont(context),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 2),
                      const SizedBox(height: 12),
                      Text(
                        "Top Features",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontFamily: 'DM Sans',
                          fontSize: AppSizes.smallFont(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(right: 6),
                          child: ScrollConfiguration(
                            behavior: const _NoGlowScrollBehavior(),
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: features.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final f = features[i];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFDD2E2E),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: TextStyle(
                                          fontSize: AppSizes.smallFont(context),
                                          height: 1.25,
                                          fontFamily: 'DM Sans',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showRightDivider)
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 18),
                  color: const Color(0xFFEEEEEE),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) => child;
}
