import 'dart:convert';

import 'package:avd_assets/Screens/MainNavigationState.dart';
import 'package:avd_assets/controller/common_controller.dart';
import 'package:avd_assets/model/category_model.dart';
import 'package:avd_assets/model/department_model.dart';
import 'package:avd_assets/model/location_model.dart';
import 'package:avd_assets/widgets/edit_department.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX for state management

import 'package:avd_assets/model/product_model.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:avd_assets/Screens/EditProductDetailsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailPage extends StatefulWidget {
  final productModel? nproduct;
  const ProductDetailPage({required this.nproduct});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  String userRole = "";
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<GetLocation> locationList = [];
  List<Category> categoryList = [];
  List<getDept> departmentList = [];
  bool showGeneralDetails = true;
  final CommonController commonController = CommonController();
  String? productName;
  String? description;
  String? selectedCategory;
  String? selectedOrganization;
  List<Map<String, dynamic>> departmentData = [];

  @override
  void initState() {
    // print(widget.nproduct.);
    super.initState();
    getDepartmentsData();
    getLocationsData();
    getCategories();
    productName = widget.nproduct?.name.toString();
    description = widget.nproduct?.description;
    selectedCategory = widget.nproduct?.cid.toString();
    selectedOrganization = widget.nproduct?.org;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    getUserRole();
    _controller.forward();
  }

  void toggleDetails() {
    setState(() {
      showGeneralDetails = !showGeneralDetails;
      if (showGeneralDetails) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  Future<void> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString("role") ?? "";
    });
  }

  Future<void> getCategories() async {
    try {
      List<dynamic> categories = await commonController.fetchData('category');
      setState(() {
        categoryList =
            categories.map((category) => Category.fromJson(category)).toList();
        print(categoryList.length);
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
    print(categoryList.length);
  }

  Future<void> getDepartmentsData() async {
    try {
      List<dynamic> departments = await commonController.fetchData('dept');
      setState(() {
        departmentList = departments
            .map((department) => getDept.fromJson(department))
            .toList();
      });
    } catch (e) {
      print(e);
    }
    print(departmentList.length);
  }

  Future<void> getLocationsData() async {
    try {
      List<dynamic> locations = await commonController.fetchData('location');
      setState(() {
        locationList = locations
            .map((location) => GetLocation.fromJson(location))
            .toList();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> deleteProductById(String productId) async {
    // String? cookie = storage.read('cookie');
    // if (cookie == null) {
    //   print('No cookie found');
    //   return;
    // }

    final response = await http.post(
      Uri.parse('http://27.116.52.24:8054/deleteProductById'),
      headers: {
        'Content-Type': 'application/json',

      },
      body: json.encode({'productId': productId}),
    );

    if (response.statusCode == 200) {
      if (context.mounted) {
        Get.offAll(
            const MainNavigation(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 200));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product Deleted successfully')),
        );
        // Navigator.of(context).pop(); // Close the dialog
      }
    } else {
      // Show error message in case of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: ${response.body}')),
      );
    }
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteProductById(widget.nproduct!.productId.toString());
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void fetchDepartment() {
    departmentData.clear();
    for (var storage in widget.nproduct!.storage ?? []) {
      if (storage == null) continue; // Safety check

      int? matchingDeartmentId;
      try {
        matchingDeartmentId = departmentList
            .firstWhere((dept) => dept.name.toString() == storage.department)
            .dId;
        print("dId: ${matchingDeartmentId}");
        // matchingDepartment = departmentList
        //     .firstWhere((dept) =>
        // dept.name == storage.department)
        //     .dId;
      } catch (e) {
        matchingDeartmentId = null;
      }

      Map<String, dynamic> locationData;
      try {
        locationData = {
          'locationId': locationList
              .firstWhere((loc) => loc.name == storage.location)
              .lId,
          'quantity': storage.quantity.toString(),
        };
      } catch (e) {
        locationData = {
          'locationId': null,
          'quantity': storage.quantity.toString(),
        };
      }

      // Check if department already exists in the list
      var existingDept;

      try {
        existingDept = departmentData.firstWhere(
              (dept) => dept['dId'] == matchingDeartmentId,
        );
      } catch (e) {
        existingDept = null;
      }

      if (existingDept != null) {
        // Add location data to the existing department
        existingDept['locations'].add(locationData);
      } else {
        // Create a new entry for this department
        departmentData.add({
          'dId': matchingDeartmentId,
          'locations': [locationData],
        });
      }
    }
  }

  void _assignProductPage() {
    fetchDepartment();
    Get.to(() =>
        EditDepartment(
          data: departmentData,
          locationList: locationList,
          departmentList: departmentList,));
  }


  Widget _floatingactionbutton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: primary1,
      overlayColor: Colors.black,
      foregroundColor: Colors.white,
      overlayOpacity: 0.3,
      spacing: 12,
      spaceBetweenChildren: 8,
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      children: [
        if(userRole == "Admin")
          SpeedDialChild(
            label: "Edit Product",
            labelStyle: const TextStyle(fontSize: 16),
            child: const Icon(Icons.edit, color: Colors.white),
            backgroundColor: secondary,
            onTap: () {
              print(widget.nproduct);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    EditProductDetailsPage(product: widget.nproduct!,
                        departmentList: departmentList,
                        locationList: locationList,
                        categoryList: categoryList)),
              );
            },
          ),
        // SpeedDialChild(
        //   label: "Assign Item",
        //   labelStyle: const TextStyle(fontSize: 16),
        //   child: const Icon(Icons.assignment, color: Colors.white),
        //   backgroundColor: secondary,
        //   onTap: () {
        //     print("Assign Item tapped");
        //     _assignProductPage();
        //   },
        // ),
        SpeedDialChild(
          label: "Delete",
          labelStyle: const TextStyle(fontSize: 16),
          child: const Icon(Icons.delete, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () => _showAlertDialog(), // Corrected function call
        ),
        // SpeedDialChild(
        //   label: "Add Purchase Details",
        //   labelStyle: const TextStyle(fontSize: 16),
        //   child: const Icon(Icons.shopping_cart, color: Colors.white),
        //   backgroundColor: secondary,
        //   onTap: () {
        //     print("Add Purchase Details tapped");
        //   },
        // ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Obx to reactively rebuild the widget

    return Scaffold(
      backgroundColor: primary1,
      // Set background color based on theme

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),

      ),
      body: Column(
        children: [
          // SizedBox(
          //   height: MediaQuery.of(context).size.height * 0.38,
          //   width: double.infinity,
          //   child: Hero(
          //     tag: 'product_${widget.nproduct!.productId}',
          //     child: Stack(
          //       fit: StackFit.expand,
          //       children: [
          //         CarouselSlider(
          //           items: widget.nproduct!.images!.map((imageUrl) {
          //             return Image.network(
          //               "http://27.116.52.24:8054$imageUrl",
          //               fit: BoxFit.cover,
          //               width: double.infinity,
          //             );
          //           }).toList(),
          //           options: CarouselOptions(
          //             autoPlay: true,
          //             enlargeCenterPage: true,
          //             viewportFraction: 1.0,
          //             onPageChanged: (index, reason) {
          //               setState(() {
          //                 _currentIndex = index;
          //               });
          //             },
          //           ),
          //         ),
          //         // Gradient overlay
          //         Container(
          //           decoration: BoxDecoration(
          //             gradient: LinearGradient(
          //               begin: Alignment.topCenter,
          //               end: Alignment.bottomCenter,
          //               colors: [
          //                 Colors.transparent,
          //                 Colors.black.withOpacity(0.7),
          //               ],
          //               stops: const [0.6, 1.0],
          //             ),
          //           ),
          //         ),
          //         // Dots indicator
          //         Positioned(
          //           bottom: 10,
          //           left: 0,
          //           right: 0,
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: widget.nproduct!.images!.asMap().entries.map((entry) {
          //               return GestureDetector(
          //                 onTap: () => setState(() => _currentIndex = entry.key),
          //                 child: Container(
          //                   width: _currentIndex == entry.key ? 10 : 8,
          //                   height: _currentIndex == entry.key ? 10 : 8,
          //                   margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //                   decoration: BoxDecoration(
          //                     shape: BoxShape.circle,
          //                     color: _currentIndex == entry.key
          //                         ? Colors.white
          //                         : Colors.grey,
          //                   ),
          //                 ),
          //               );
          //             }).toList(),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(
          //   height: MediaQuery
          //       .of(context)
          //       .size
          //       .height * 0.38,
          //   width: double.infinity,
          //   child: Hero(
          //     tag: 'product_${widget.nproduct!.productId}',
          //     child: Stack(
          //       fit: StackFit.expand,
          //       children: [
          //         Image.network(
          //     "http://27.116.52.24:8054${widget.nproduct!.images![2]}",
          //           fit: BoxFit.cover,
          //         ),
          //         Container(
          //           decoration: BoxDecoration(
          //             gradient: LinearGradient(
          //               begin: Alignment.topCenter,
          //               end: Alignment.bottomCenter,
          //               colors: [
          //                 Colors.transparent,
          //                 Colors.black.withOpacity(0.7),
          //               ],
          //               stops: const [0.6, 1.0],
          //             ),
          //           ),.
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Hero(
            tag: widget.nproduct!.name.toString(),
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.38,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                aspectRatio: 16 / 9,
              ),
              items: widget.nproduct?.images!.map((imagePath) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("http://27.116.52.24:8054${imagePath}"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17, vertical: 12),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.nproduct!.name.toString()}  ',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: primary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Category :  ${widget.nproduct!.categoryName
                                  .toString()}',
                              style: TextStyle(
                                  color: secondary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),

                          const SizedBox(height: 16.0),

                          // Toggle Buttons
                          // Toggle Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ToggleButtons(
                                isSelected: [showGeneralDetails, !showGeneralDetails],
                                onPressed: (index) {
                                  setState(() {
                                    showGeneralDetails = index == 0;
                                    _controller.forward(from: 0); // Restart animation
                                  });
                                },
                                borderRadius: BorderRadius.circular(10),
                                selectedColor: Colors.white,
                                fillColor: primary,
                                color: textcolor,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      "General Details",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      "Storage Details",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16.0),

                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 800),
                            transitionBuilder: (widget, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                                  child: widget,
                                ),
                              );
                            },
                            child: showGeneralDetails
                                ? Column(
                              key: ValueKey('general'),
                              children: [
                                _buildDetailCard(
                                  icon: Icons.person,
                                  title: 'Organization',
                                  value: widget.nproduct!.org.toString(),
                                  iconColor: primary1,
                                  bgColor: primary1.withOpacity(0.1),
                                ),
                                _buildDetailCard(
                                  icon: Icons.description,
                                  title: 'Description',
                                  value: widget.nproduct!.description.toString(),
                                  iconColor: primary1,
                                  bgColor: primary1.withOpacity(0.1),
                                ),
                                _buildDetailCard(
                                  icon: Icons.business,
                                  title: 'Dimensions',
                                  value: widget.nproduct!.dimensions == null
                                      ? '-'
                                      : widget.nproduct!.dimensions.toString(),
                                  iconColor: primary1,
                                  bgColor: primary1.withOpacity(0.1),
                                ),
                                _buildDetailCard(
                                  icon: Icons.inventory,
                                  title: 'Quantity',
                                  value: widget.nproduct!.quantity.toString(),
                                  iconColor: primary1,
                                  bgColor: primary1.withOpacity(0.1),
                                ),
                              ],
                            )
                                : Column(
                              key: ValueKey('storage'),
                              children: widget.nproduct!.storage?.map((storage) {
                                return _buildDetailCard(
                                  icon: Icons.store,
                                  title: storage.department!,
                                  value: "Location: ${storage.location} \nQty: ${storage.quantity}",
                                  iconColor: primary1,
                                  bgColor: primary1.withOpacity(0.1),
                                );
                              }).toList() ??
                                  [],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _floatingactionbutton(),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget _buildDetailCard({
//   required IconData icon,
//   required String title,
//   required String value,
// }) {
//   return Container(
//     margin: const EdgeInsets.only(bottom: 16.0),
//     padding: const EdgeInsets.all(16.0),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16.0),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.1),
//           spreadRadius: 1,
//           blurRadius: 5,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             color: secondary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Icon(icon, color: secondary),
//         ),
//         const SizedBox(width: 16.0),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 15.0,
//                 color: primary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4.0),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 15.0,
//                 fontWeight: FontWeight.w500,
}
