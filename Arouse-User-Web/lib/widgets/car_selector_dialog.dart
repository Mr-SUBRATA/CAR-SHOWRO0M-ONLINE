import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:arouse_ecommerce_frontend_web/api/vehicles_api.dart';

/// A hierarchical car selector dialog with Brand → Model → Variant flow
/// Similar to CarWale's car selection experience
class CarSelectorDialog extends StatefulWidget {
  final List<String> alreadySelectedIds;
  final Function(Map<String, dynamic> selectedCar, Map<String, dynamic>? selectedVariant) onCarSelected;

  const CarSelectorDialog({
    super.key,
    required this.alreadySelectedIds,
    required this.onCarSelected,
  });

  @override
  State<CarSelectorDialog> createState() => _CarSelectorDialogState();
}

class _CarSelectorDialogState extends State<CarSelectorDialog> {
  // Selection states
  int _currentStep = 0; // 0: Brand, 1: Model, 2: Variant
  String? _selectedBrand;
  Map<String, dynamic>? _selectedModel;
  
  // Data
  List<Map<String, dynamic>> allCars = [];
  List<String> brands = [];
  List<Map<String, dynamic>> filteredModels = [];
  List<dynamic> variants = [];
  
  // Filters
  Set<String> selectedFuelFilters = {};
  Set<String> selectedTransFilters = {};
  final List<String> fuelOptions = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
  final List<String> transOptions = ['Manual', 'Automatic'];

  // Search
  String _searchQuery = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      allCars = await VehiclesApi.getAllCars();
      
      // Extract unique brands
      final brandSet = <String>{};
      for (var car in allCars) {
        if (car['brand'] != null && car['brand'].toString().isNotEmpty) {
          brandSet.add(car['brand'].toString());
        }
      }
      brands = brandSet.toList()..sort();
      
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading cars: $e');
      setState(() => isLoading = false);
    }
  }

  void _selectBrand(String brand) {
    setState(() {
      _selectedBrand = brand;
      filteredModels = allCars
          .where((car) => car['brand']?.toString().toLowerCase() == brand.toLowerCase())
          .where((car) => !widget.alreadySelectedIds.contains(car['_id']))
          .toList();
      _currentStep = 1;
      _searchQuery = '';
    });
  }

  void _selectModel(Map<String, dynamic> model) {
    setState(() {
      _selectedModel = model;
      variants = model['variants'] ?? [];
      selectedFuelFilters.clear();
      selectedTransFilters.clear();
      
      if (variants.isEmpty) {
        // No variants, select the car directly
        widget.onCarSelected(model, null);
        Navigator.pop(context);
      } else {
        _currentStep = 2;
        _searchQuery = '';
      }
    });
  }

  void _selectVariant(Map<String, dynamic> variant) {
    widget.onCarSelected(_selectedModel!, variant);
    Navigator.pop(context);
  }

  void _toggleFuelFilter(String fuel) {
    setState(() {
      if (selectedFuelFilters.contains(fuel)) {
        selectedFuelFilters.remove(fuel);
      } else {
        selectedFuelFilters.add(fuel);
      }
    });
  }

  void _toggleTransFilter(String trans) {
    setState(() {
      if (selectedTransFilters.contains(trans)) {
        selectedTransFilters.remove(trans);
      } else {
        selectedTransFilters.add(trans);
      }
    });
  }

  void _goBack() {
    setState(() {
      if (_currentStep == 2) {
        _currentStep = 1;
        _selectedModel = null;
        variants = [];
      } else if (_currentStep == 1) {
        _currentStep = 0;
        _selectedBrand = null;
        filteredModels = [];
      }
      _searchQuery = '';
    });
  }

  Uint8List? _getImageBytes(dynamic imageData) {
    try {
      if (imageData != null &&
          imageData["data"] != null &&
          imageData["data"]["data"] != null) {
        return Uint8List.fromList(List<int>.from(imageData["data"]["data"]));
      }
    } catch (e) {
      debugPrint("Image parse error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (_currentStep) {
      case 0:
        title = 'Select Brand';
        break;
      case 1:
        title = 'Select Model';
        break;
      case 2:
        title = 'Select Variant';
        break;
      default:
        title = 'Select Car';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A4C8E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _goBack,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedBrand != null)
                  Text(
                    _currentStep == 1 
                        ? _selectedBrand! 
                        : '$_selectedBrand > ${_selectedModel?['name'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    // Hide search bar if in variant step to save space for filters, or keep it?
    // User requested filters *and* search usually works alongside. 
    // CarWale has filters below search/tabs.
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        controller: TextEditingController(text: _searchQuery)
          ..selection = TextSelection.fromPosition(TextPosition(offset: _searchQuery.length)),
        decoration: InputDecoration(
          hintText: _currentStep == 0
              ? 'Search brands...'
              : _currentStep == 1
                  ? 'Search models...'
                  : 'Search variants...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => setState(() => _searchQuery = ''),
              )
            : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildBrandList();
      case 1:
        return _buildModelList();
      case 2:
        return _buildVariantList();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBrandList() {
    final filtered = brands
        .where((b) => b.toLowerCase().contains(_searchQuery))
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No brands found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final brand = filtered[index];
        final modelCount = allCars.where((c) => c['brand'] == brand).length;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF1A4C8E).withOpacity(0.1),
            child: Text(
              brand[0].toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF1A4C8E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(brand, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('$modelCount model${modelCount > 1 ? 's' : ''}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectBrand(brand),
        );
      },
    );
  }

  Widget _buildModelList() {
    final filtered = filteredModels
        .where((m) => (m['name'] ?? '').toString().toLowerCase().contains(_searchQuery))
        .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No models found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final model = filtered[index];
        final imageBytes = _getImageBytes(
          (model["images"] != null && model["images"].isNotEmpty)
              ? model["images"][0]
              : null,
        );
        final variantCount = (model['variants'] as List?)?.length ?? 0;
        final price = model['price'];

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 45,
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.directions_car),
                    ),
            ),
          ),
          title: Text(model['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (price != null)
                Text(
                  '₹${(price / 100000).toStringAsFixed(2)} Lakh onwards',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              Text(
                '$variantCount variant${variantCount > 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _selectModel(model),
        );
      },
    );
  }

  Widget _buildVariantList() {
    // 1. Filter Logic
    final filtered = variants.where((v) {
      final matchesSearch = (v['name'] ?? '').toString().toLowerCase().contains(_searchQuery);
      
      // Fuel Filter (OR logic within fuel if multiple selected, usually)
      final fuel = (v['fuelType'] ?? '').toString();
      final matchesFuel = selectedFuelFilters.isEmpty || 
          selectedFuelFilters.any((f) => fuel.toLowerCase().contains(f.toLowerCase()));
          
      // Transmission Filter
      final trans = (v['transmission'] ?? '').toString();
      final matchesTrans = selectedTransFilters.isEmpty ||
          selectedTransFilters.any((t) => trans.toLowerCase().contains(t.toLowerCase()));

      return matchesSearch && matchesFuel && matchesTrans;
    }).toList();

    return Column(
      children: [
        // 2. Filter UI Area
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ...fuelOptions.map((f) => _buildFilterChip(f, selectedFuelFilters.contains(f), () => _toggleFuelFilter(f))),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Colors.grey.shade300), // Separator
              const SizedBox(width: 8),
              ...transOptions.map((t) => _buildFilterChip(t, selectedTransFilters.contains(t), () => _toggleTransFilter(t))),
            ],
          ),
        ),
        
        const Divider(height: 1),

        // 3. Variant List
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No variants match your filters'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final variant = filtered[index];
                    final price = variant['price'];
                    final fuel = variant['fuelType'] ?? '';
                    final trans = variant['transmission'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          variant['name'] ?? 'Variant',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A4C8E),
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              _buildSpecTag(fuel),
                              const SizedBox(width: 8),
                              _buildSpecTag(trans),
                              const SizedBox(width: 8),
                              if (price != null)
                                Text(
                                  '₹${(price / 100000).toStringAsFixed(2)} Lakh',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF1A4C8E), size: 28),
                        onTap: () => _selectVariant(variant),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F0FE) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF1A4C8E) : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A4C8E) : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecTag(String text) {
    if (text.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
      ),
    );
  }
}
