import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:avd_assets/model/colors.dart';

import '../controller/common_controller.dart';
import '../model/category_model.dart';
import '../model/department_model.dart';
import '../model/location_model.dart';

class FilterPage extends StatefulWidget {
  List<Category> categoryList = [];
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];
  FilterPage({
    super.key,
    required this.categoryList,
    required this.departmentList,
    required this.locationList,
  });

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  double _priceRange = 50;
  String _selectedSort = 'Newest';

  // Change from single selection to multiple selections.
  List<String> selectedCategories = [];
  List<String> selectedDepartments = [];
  List<String> selectedLocations = [];

  // This list will store locations based on the union of selected departments.
  List<GetLocation> departmentWiseLocations = [];

  final CommonController commonController = CommonController();

  @override
  void initState() {
    _loadSavedFilters();
    super.initState();
  }
  Future<void> _loadSavedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCategories = prefs.getStringList("categories") ?? [];
    final savedDepartments = prefs.getStringList("department") ?? [];
    final savedLocations = prefs.getStringList("locations") ?? [];
    setState(() {
      selectedCategories = savedCategories;
      selectedDepartments = savedDepartments;
      selectedLocations = savedLocations;
      _updateDepartmentWiseLocations();
      print('Selected Categories: ${selectedCategories.toList()}');
      print('Selected Departments: ${selectedDepartments.toList()}');
      print('Selected Locations: ${selectedLocations.toList()}');
    });
  }

  // Update the union of locations based on all selected departments.
  void _updateDepartmentWiseLocations() {
    // Get the IDs of the selected departments.
    List<String> selectedDeptIds = widget.departmentList
        .where((dept) => selectedDepartments.contains(dept.name))
        .map((dept) => dept.dId.toString())
        .toList();
    setState(() {
      departmentWiseLocations = widget.locationList
          .where((location) => selectedDeptIds.contains(location.dId.toString()))
          .toList();
    });
  }

  Future<void> saveSelectedFilters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("categories", selectedCategories);
    await prefs.setStringList("locations", selectedLocations);
    await prefs.setStringList("department", selectedDepartments);
  }

  // A helper widget to display text with animation.
  _builtext(String name) {
    return Text(
      name,
      style: TextStyle(
          color: Color(0xFF0188B3), fontSize: 18, fontWeight: FontWeight.bold),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 1, end: 0);
  }

  // Generic widget to build a wrap of ChoiceChips for multiple selection.
  _buildWrap<T>(List<T> items, List<String> selectedItems, Function(String, int?) onSelected) {
    return Wrap(
      spacing: 8.0,
      children: items.map((item) {
        // Determine the name and id based on the type.
        String name;
        int? id;
        if (item is Category) {
          name = item.name;
          id = null;
        } else if (item is getDept) {
          name = item.name;
          id = item.dId;
        } else if (item is GetLocation) {
          name = item.name;
          id = item.dId;
        } else {
          name = item.toString();
          id = null;
        }

        bool isSelected = selectedItems.contains(name);
        return ChoiceChip(
          label: Text(name,
              style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF0188B3))),
          selected: isSelected,
          selectedColor: Color(0xFF0485C4),
          backgroundColor: Colors.white,
          onSelected: (selected) {
            onSelected(name, id);
          },
        ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Add a gradient background.
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text('Filter Products', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Reset all filters.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: primary),
              ),
              onPressed: () {
                setState(() {
                  selectedCategories.clear();
                  selectedDepartments.clear();
                  selectedLocations.clear();
                  departmentWiseLocations.clear();
                });
              },
              child: Icon(
                Icons.refresh_sharp,
                color: primary,
                size: 25,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _builtext('Category'),
            SizedBox(height: 20),
            // Multiple selection for categories.
            _buildWrap(widget.categoryList, selectedCategories, (name, id) {
              setState(() {
                if (selectedCategories.contains(name)) {
                  selectedCategories.remove(name);
                } else {
                  selectedCategories.add(name);
                }
              });
            }),
            SizedBox(height: 20),
            _builtext('Department'),
            SizedBox(height: 20),
            // Multiple selection for departments.
            _buildWrap(widget.departmentList, selectedDepartments, (name, id) {
              setState(() {
                if (selectedDepartments.contains(name)) {
                  selectedDepartments.remove(name);
                } else {
                  selectedDepartments.add(name);
                }
                // Update the union of locations based on current departments.
                _updateDepartmentWiseLocations();
                // Clear selected locations that are no longer in the union.
                selectedLocations = selectedLocations
                    .where((loc) => departmentWiseLocations
                    .any((dLoc) => dLoc.name == loc))
                    .toList();
              });
            }),
            SizedBox(height: 20),
            _builtext('Locations'),
            SizedBox(height: 20),
            // Multiple selection for locations based on selected departments.
            _buildWrap(departmentWiseLocations, selectedLocations, (name, id) {
              setState(() {
                if (selectedLocations.contains(name)) {
                  selectedLocations.remove(name);
                } else {
                  selectedLocations.add(name);
                }
              });
            }),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () async {
                await saveSelectedFilters();
                // Return the selected filters.
                print("Selected Departments ${selectedDepartments.toList()}");
                print("Selected Categorys ${selectedCategories.toList()}");
                print("Selected Locations ${selectedLocations.toList()}");
                Navigator.pop(context, {
                  "categories": selectedCategories,
                  "locations": selectedLocations,
                  "department": selectedDepartments,
                });
              },
              child: Center(
                child: Text('Apply Filters',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ).animate().fadeIn(duration: 100.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }
}
