import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:avd_assets/Screens/MainNavigationState.dart';
import 'package:avd_assets/Screens/ProductDetailPage.dart';
import 'package:avd_assets/model/product_model.dart';
import 'package:avd_assets/widgets/add_department.dart';
import 'package:avd_assets/widgets/edit_department.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:avd_assets/model/colors.dart';
import '../controller/common_controller.dart';
import '../model/category_model.dart';
import '../model/department_model.dart';
import '../model/location_model.dart';
// import '../model/product.dart';
// import 'package:provider/provider.dart';
// import 'package:avd_assets/Screens/ProductProvider.dart';

class EditProductDetailsPage extends StatefulWidget {
  final productModel product;
  final List<getDept> departmentList;
  final List<GetLocation> locationList;
  final List<Category> categoryList;

  const EditProductDetailsPage(
      {Key? key,
      required this.product,
      required this.departmentList,
      required this.locationList,
      required this.categoryList})
      : super(key: key);

  @override
  State<EditProductDetailsPage> createState() => _EditProductDetailsPageState();
}

class _EditProductDetailsPageState extends State<EditProductDetailsPage> {
  static bool isLoading = true;
  // static const Color primary = Color(0xFF02405E);
  // static const Color secondary = Color(0xFF0485C4);
  // static const Color textcolor = Color(0xFF0188B3);
  String? productName;
  String? description;
  // List<Category> categoryList = [];
  // List<GetLocation> locationList = [];
  // List<getDept> departmentList = [];
  String? selectedOrganization;
  String? selectedCategory;
  List<String> organizations = ['AVD', 'HariPrabodham', 'HariSumiran'];
  final _formKey = GlobalKey<FormState>();
  // bool isOwnerSelected = false;
  final CommonController commonController = CommonController();
  List? listOfStorage;
  // List<Map<String, dynamic>>? locationlist;
  List<Map<String, dynamic>> departmentData = [];
  @override
  void initState() {
    // initializeData();
    super.initState();

    // print(jsonEncode(widget.product.toJson()));
    // print(departmentList);
    // print(locationList);

    //Initialize the fields with the current product details
    productName = widget.product.name.toString();
    description = widget.product.description;
    selectedCategory = widget.product.cid.toString();
    selectedOrganization = widget.product.org;
    // print(jsonEncode(widget.product));
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
        fetchDepartment();
      });
    });
    // print('DepartmentList: ${departmentList.toList()}');
    // print('LocationList: ${locationList.toList()}');
    // Final structured departmentData list

    // department = widget.product.department;
    // location = widget.product.location;
    // quantity = widget.product.quantity;
  }

  void fetchDepartment() async {
    departmentData.clear();
    for (var storage in widget.product!.storage ?? []) {
      if (storage == null) continue; // Safety check

      int? matchingDeartmentId;
      try {
        matchingDeartmentId = await widget.departmentList
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
        locationData = await {
          'locationId': widget.locationList
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
        existingDept = await departmentData.firstWhere(
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
    print(departmentData.toList());
  }

  Widget _departmentListView(
      List<Map<String, dynamic>> departmentData,
      List<getDept> departmentList,
      List<GetLocation> locationList,
      Color primary,
      Color secondary) {
    return Column(
      children: [
        for (int index = 0; index < departmentData.length; index++) ...[
          _buildDepartmentCard(departmentData[index], departmentList,
              locationList, primary, secondary),
          SizedBox(height: 10), // Space between items
        ]
      ],
    );
  }

  Widget _buildDepartmentCard(
      Map<String, dynamic> data,
      List<getDept> departmentList,
      List<GetLocation> locationList,
      Color primary,
      Color secondary,
      ) {
    final departmentName = departmentList
        .firstWhere((doc) => doc.dId.toString() == data['dId'].toString())
        .name;
    final locations = data['locations'] as List<dynamic>;

    return FadeInUp(
      duration: Duration(milliseconds: 400),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department Name
              Row(
                children: [
                  Icon(Icons.apartment, color: primary, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      departmentName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(thickness: 1, color: Colors.grey[300]),
              // Locations List
              Column(
                children: locations.map((location) {
                  final locationName = locationList.firstWhere(
                        (loc) =>
                    loc.lId.toString() ==
                        location['locationId'].toString(),
                  ).name;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: secondary, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationName,
                            style: TextStyle(
                                fontSize: 16,
                                color: secondary,
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Qty: ${location['quantity']}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Widget _buildDepartmentCard(
  //     Map<String, dynamic> data,
  //     List<getDept> departmentList,
  //     List<GetLocation> locationList,
  //     Color primary,
  //     Color secondary,
  //     ) {
  //   final departmentName = departmentList
  //       .firstWhere((doc) => doc.dId.toString() == data['dId'].toString())
  //       .name;
  //   final locations = data['locations'] as List<dynamic>;
  //
  //   return FadeInUp(
  //     duration: Duration(milliseconds: 400),
  //     child: Card(
  //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(15),
  //       ),
  //       elevation: 6,
  //       child: Padding(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Department Name
  //             Row(
  //               children: [
  //                 Icon(Icons.apartment, color: primary, size: 22),
  //                 SizedBox(width: 8),
  //                 Expanded(
  //                   child: Text(
  //                     departmentName,
  //                     style: TextStyle(
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 18,
  //                       color: primary,
  //                     ),
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 10),
  //             Divider(thickness: 1, color: Colors.grey[300]),
  //             // Locations List
  //             Column(
  //               children: locations.map((location) {
  //                 // Ensure both sides of the comparison are the same type.
  //                 final locationName = locationList
  //                     .firstWhere(
  //                       (loc) =>
  //                   loc.lId == location['locationId'], // comparing ints
  //                 )
  //                     .name;
  //                 return Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 6.0),
  //                   child: Row(
  //                     children: [
  //                       Icon(Icons.location_on, color: secondary, size: 20),
  //                       SizedBox(width: 8),
  //                       Expanded(
  //                         child: Text(
  //                           locationName,
  //                           style: TextStyle(
  //                               fontSize: 16,
  //                               color: secondary,
  //                               fontWeight: FontWeight.w500),
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                       SizedBox(width: 10),
  //                       Text(
  //                         "Qty: ${location['quantity']}",
  //                         style: TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                             color: primary),
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }).toList(),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // void _saveChanges() {
  // if (_formKey.currentState!.validate()) {
  //   _formKey.currentState!.save();
  // Handle saving the updated product details (e.g., send to the backend or update state)
  // final updatedProduct =
  //   Product(
  //     productName: productName,
  //     productImage: widget.product.productImage,
  //     description: description,
  //     category: category,
  //     owner: owner,
  //     department: department,
  //     location: location,
  //     quantity: quantity,
  //   );

  // Provider.of<ProductProvider>(context, listen: false)
  //     .updateProduct(widget.product.id, updatedProduct);

  // Navigator.pushAndRemoveUntil(
  //   context,
  //   MaterialPageRoute(builder: (_) => ProductDetailPage(product: updatedProduct)),
  //       (route) => false,
  // );
  //   }
  // }

  // @override
  // void dispose() {
  //   _productNameController.dispose();
  //   _descriptionController.dispose();
  //   _quantityController.dispose();
  //   super.dispose();
  // }

  // void _handleOrgSelection(String? newOwner) {
  //   if (selectedOrganization != null && isOwnerSelected) {
  //     // If there is already an owner selected, show an alert
  //     // _showOwnerAlert();
  //     setState(() {
  //       selectedOrganization = selectedOrganization;
  //       print("old ${selectedOrganization}");
  //     });
  //   } else {
  //     setState(() {
  //       isOwnerSelected = true;
  //       selectedOrganization = newOwner;
  //       print("new ${selectedOrganization}");
  //     });
  //   }
  // }

  Widget _buildDropDownFormField(String? value, List items, String? Ids,
      void Function(String?)? onChanged, String labelText) {
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(color: primary, fontSize: 16),
      borderRadius: BorderRadius.circular(10),
      items: items.map((item) {
        String? itemId;
        String? itemName;
        if (Ids == null) {
          itemId = item;
          itemName = item;
        } else {
          itemId = item.toJson()[Ids].toString();
          itemName = item.name;
        }

        return DropdownMenuItem(
          value: itemId,
          child: Text(itemName!),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: const Icon(
          Icons.category,
          color: primary1,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary1),
        ),
      ),
    );
  }

  void _updateData() async {
    final Uri url = Uri.http('27.116.52.24:8054', '/editProduct');
    var request = http.Request('POST', url);
    request.headers["Content-Type"] = "application/json";
    Map<String, dynamic> productData =  {
      "productId": widget.product.productId,
      "name": productName,
      "description": description,
      "cid": int.parse(selectedCategory!), // Ensure category ID is an integer
      // "dimension":"${widthController.text}*${breadthController.text}*${heightController.text}",
      "org":selectedOrganization,
      "departments": departmentData.map((department) {
        return {
          "dId": department["dId"],
          "locations": (department["locations"] as List).map((location) {
            return {
              "lId": location["locationId"],
              "quantity": location["quantity"].toString(),
            };
          }).toList(),
        };
      }).toList()
    };

    print(productData);
    request.body = jsonEncode(productData);

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      var jsonResponse;

      try {
        jsonResponse = jsonDecode(responseBody.body);
      } catch (e) {
        print('JSON Decode Error: $e');
        print('Response Body: ${responseBody.body}');
        return;
      }

      if (jsonResponse != null &&
          jsonResponse.containsKey('data') &&
          jsonResponse['data'] != null) {
        var data = jsonResponse['data'];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product Added successfully')),
        );
        // print('Product added with ID: ${int.tryParse(data["productId"])}');
        print(productData);
      } else {
        print(
            'Response JSON does not contain "data" key or is null: $jsonResponse');
      }
    } else {
      print('Request failed with status code: ${response.statusCode}');
      print('Response Body: ${responseBody.body}');
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainNavigation()),
    );
  }

  Future _showSaveDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to Update Product?',style: TextStyle(fontSize: 18),),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('This is an alert dialog message.'),
                // Text('Do you want to save product?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: _updateData,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: const Center(
          child: CupertinoActivityIndicator(
              radius: 20.0, color: CupertinoColors.activeBlue),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Edit Product",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40.0, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primary1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle image selection
                        },
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: primary1.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: primary1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Choose Image",
                        style: TextStyle(color: textcolor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Product Name Field
                TextFormField(
                  enabled: false,
                  initialValue: productName,
                  onChanged: (value) {
                    productName = value;
                  },
                  style: TextStyle(color: primary, fontSize: 16),
                  // controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: "Product Name",
                    prefixIcon: const Icon(
                      Icons.label,
                      color: primary1,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primary1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter product name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Description Field
                TextFormField(
                  initialValue: description,
                  style: TextStyle(color: primary, fontSize: 16),
                  onChanged: (value) {
                    description = value;
                  },
                  // controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: const Icon(
                      Icons.description,
                      color: primary1,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: primary1),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Select Category Dropdown

                _buildDropDownFormField(
                    selectedCategory, widget.categoryList, 'cId', (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                }, 'Select Category'),
                const SizedBox(height: 15),
                // Select Owner Dropdown
                _buildDropDownFormField(
                    selectedOrganization, organizations, null, (value) {
                  // _handleOrgSelection(value);
                  selectedOrganization = value;
                }, 'Select Organizations'),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () async {
                    // fetchDepartment();
                    // print('name: ${productName}');
                    // print('desciption: ${description}');
                    // print('selectedCategory: ${selectedCategory!}');
                    // print('selectedOrganization: ${selectedOrganization!}');
                    // print("Fetched Department:  ${departmentData}");
                    final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
                      // useSafeArea: true,
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => EditDepartment(
                            data: departmentData,
                            locationList: widget.locationList,
                            departmentList: widget.departmentList));
                    if (result != null) {
                      setState(() {
                        departmentData = result;
                        print('getting data ${departmentData.toList()}');
                      });
                    }
                    // fetchDepartment();
                    // print(departmentData);
                    // print(departmentList);
                  },
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      foregroundColor: textcolor,
                      side: BorderSide(color: primary1, width: 2)),
                  child: const Text(
                    'Edit Department',
                    style: TextStyle(color: primary, fontSize: 16),
                  ),
                ),
                if (!isLoading)
                  SizedBox(
                    height: departmentData.length == 2
                        ? 420
                        : departmentData.length == 3
                            ? 550
                            : 220,
                    child: _departmentListView(
                        departmentData,
                        widget.departmentList,
                        widget.locationList,
                        Color(0xFF02405E),
                        Color(0xFF0485C4)),
                  ),
                ElevatedButton.icon(
                  // onPressed: () {},
                  onPressed: () => _showSaveDialog(),
                  label: Text("Submit",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 125),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

// Departments List
//               if (departmentData.isNotEmpty) ...[
//                 const Text(
//                   "Departments",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: departmentData.length,
//                   itemBuilder: (context, index) {
//                     var department = departmentData[index];
//                     return Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(10.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Department ID: ${department["dId"]}",
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(height: 5),
//                             if (department["locations"] != null)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: List.generate(
//                                   department["locations"].length,
//                                       (locIndex) {
//                                     var location = department["locations"][locIndex];
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 4.0),
//                                       child: Text(
//                                         "Location ID: ${location["locationId"] ?? "N/A"}, Quantity: ${location["quantity"]}",
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//
//               // Add Department Button
//
//               const SizedBox(height: 20),
//
//               // Departments List
//               // ${department!["departmentId"]}
              ],
            ),
          ),
        ),
      );
    }
  }
}
