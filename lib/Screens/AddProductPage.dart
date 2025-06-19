import 'dart:convert';
// import 'package:avd_assets/Screens/MainNavigationState.dart';
import 'package:animate_do/animate_do.dart';
import 'package:avd_assets/Screens/MainNavigationState.dart';
import 'package:avd_assets/controller/product_controller.dart';
import 'package:avd_assets/model/product_model.dart';
import 'package:flutter/material.dart';
import 'package:avd_assets/model/category_model.dart';
import 'package:avd_assets/controller/common_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/department_model.dart';
import '../model/location_model.dart';
import '../widgets/add_department.dart';
import 'package:http/http.dart' as http;
import 'package:avd_assets/model/colors.dart';
import 'package:avd_assets/widgets/image_picker_screen.dart';
import 'homepage.dart';
import 'package:avd_assets/controller/image_picker_controller.dart';

class ProductInputScreen extends StatefulWidget {
  const ProductInputScreen({super.key});

  @override
  _ProductInputScreenState createState() => _ProductInputScreenState();
}

class _ProductInputScreenState extends State<ProductInputScreen> {
  List<productModel> productList = [];
  String height = "";
  String length = "";
  String breadth = "";
  String dimensions = "";
  late productController controller;
  bool isLoading = true;
  final ImagePickerController imagePickerController =
      Get.put(ImagePickerController());
  List<Category> categoryList = [];
  List<Map<String, dynamic>> DepartmentData = [];
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];
  List<String> organizations = ['AVD', 'HariPrabodham', 'HariSumiran'];
  String? selectedCategory;
  final TextEditingController _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  String? selectedOrganization;
  bool isNameUnique = true;
  // Assuming you already have a list of existing product names.
  // This might come from your product list (converted to lowercase for consistency).
  List<String> existingProductNames = [];
  final CommonController commonController = CommonController();

  @override
  void initState() {
    controller = Get.put<productController>(productController());
    getProducts();
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      if(mounted) {
        setState(() {
          getInitializeData();
          print(productList.length);
          isLoading = false;
        });
      }
    });
    _productNameController.addListener(_checkProductName);
  }

  void _checkProductName() {
    final enteredName = _productNameController.text.trim().toLowerCase();
    setState(() {
      // If nothing is entered, consider it unique.
      isNameUnique = enteredName.isEmpty || !existingProductNames.contains(enteredName);
      print('isNameUnique: ${isNameUnique}');
    });
  }

  void getInitializeData() async {
    await getDepartmentsData();
    await getLocationsData();
    await getCategories();
  }

  Future<void> getProducts() async {
    controller.getProduct();
    setState(() {
      productList = controller.productList;
      existingProductNames = productList.map((p) => p.name!.trim().toLowerCase()).toList();
    });
  }

  Future<void> getDepartmentsData() async {
    String userRole = "";
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        userRole = prefs.getString("role") ?? "";
      });
    try {
      List<dynamic> departments = await commonController.fetchData('dept');
      setState(() {
        departmentList = departments
            .map((department) => getDept.fromJson(department))
            .toList();

        switch(userRole){
          case "KDept":
            departmentList = departmentList.where((dept) => dept.name == 'Kitchen').toList();
            break;
          case "VDept":
            departmentList = departmentList.where((dept) => dept.name == 'Video').toList();
            break;
          case "DDept":
            departmentList = departmentList.where((dept) => dept.name == 'Decoration').toList();
            break;
          case "Admin":
            departmentList = departmentList;
            break;
        }
      });
    } catch (e) {
      print(e);
    }
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
  }

  final _formKey = GlobalKey<FormState>();
  bool isOwnerSelected = false;
  void _addDepartment() async {
    if (_productNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedCategory == null ||
        selectedOrganization == null) {
      Get.snackbar(
        'Error', // Title
        'Please fill all the fields', // Message
        snackPosition: SnackPosition.TOP, // Position of snackbar
        backgroundColor: Colors.black,
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      // name: _productNameController.text,
      // desciption: _descriptionController.text,
      // selectedCategory: selectedCategory!,
      // selectedOrganization: selectedOrganization!,
      // DepartmentData.clear();
      final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
          // useSafeArea: true,
          context: context,
          isScrollControlled: true,
          builder: (ctx) => AddDepartment(
              data: DepartmentData,
              locationList: locationList,
              departmentList: departmentList));
      if (result != null) {
        setState(() {
          DepartmentData = result;
          print('getting data ${DepartmentData.toList()}');
        });
      }
    }
  }

  Widget _departmentListView(
      List<Map<String, dynamic>> departmentData,
      List<dynamic> departmentList,
      List<dynamic> locationList,
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
      List<dynamic> departmentList,
      List<dynamic> locationList,
      Color primary,
      Color secondary) {
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
                  final locationName = locationList
                      .firstWhere(
                          (loc) => loc.lId.toString() == location['locationId'])
                      .name;
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

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

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

  Future<void> _submitData() async {
    try {
      final Uri url = Uri.http('27.116.52.24:8054', '/addProductWithStorage');

      var request = http.MultipartRequest('POST', url);
      request.headers["Content-Type"] = "multipart/form-data";

      if (selectedCategory == '1') {
        dimensions = "${length}*${breadth}*${height}";
      }

      print("Selected Category: $selectedCategory");
      print("Formatted Dimensions: $dimensions");

      // Constructing product data
      Map<String, dynamic> productData = {
        "name": _productNameController.text,
        "description": _descriptionController.text,
        "cid": int.parse(selectedCategory!),
        "dimensions": dimensions,
        "org": selectedOrganization!,
        "departments": DepartmentData!.map((department) {
          return {
            "dId": department["dId"],
            "locations": (department["locations"] as List).map((location) {
              return {
                "lId": location["locationId"],
                "quantity": location["quantity"].toString(),
              };
            }).toList(),
          };
        }).toList(),
        "images": imagePickerController.selectedImages.map((image) => image.path).toList(), // Image paths
      };

      print("Product Data: $productData");

      // Convert product data to JSON and add as a text field
      request.fields['productData'] = jsonEncode(productData);

      // Add images to the request
      for (var image in imagePickerController.selectedImages) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
        print('Added file: ${image.path}');
      }

      // Send the request
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
          print('Product added with ID: ${data["productId"]}');
        } else {
          print('Response JSON does not contain "data" key or is null: $jsonResponse');
        }
      } else {
        print('Request failed with status code: ${response.statusCode}');
        print('Response Body: ${responseBody.body}');
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) => MainNavigation()));
    } catch (e) {
      print('Error: $e');
    }
  }


  // Future<void> _submitData() async {
  //   try {
  //     // EasyLoading.show();
  //     final Uri url = Uri.http('27.116.52.24:8054', '/addProductWithStorage');
  //     var request = http.Request('POST', url);
  //     request.headers["Content-Type"] = "application/json";
  //     if (selectedCategory == '1') {
  //       dimensions = "${length}*${breadth}*${height}";
  //     }
  //     // Now you can use `dimensions` wherever needed (e.g., saving to DB, displaying)
  //     print("Selected Category: $selectedCategory");
  //     print("Formatted Dimensions: $dimensions");
  //     Map<String, dynamic> productData = {
  //       "name": _productNameController.text,
  //       "description": _descriptionController.text,
  //       "cid": int.parse(selectedCategory!),
  //       "dimensions": dimensions,
  //       "org": selectedOrganization!,
  //       "departments": DepartmentData!.map((department) {
  //         return {
  //           "dId": department["dId"],
  //           "locations": (department["locations"] as List).map((location) {
  //             return {
  //               "lId": location["locationId"],
  //               "quantity": location["quantity"].toString(),
  //             };
  //           }).toList(),
  //         };
  //       }).toList(),
  //     };
  //     print(productData);
  //     request.body = jsonEncode(productData);
  //
  //     var response = await request.send();
  //     var responseBody = await http.Response.fromStream(response);
  //
  //     if (response.statusCode == 200) {
  //       var jsonResponse;
  //
  //       try {
  //         jsonResponse = jsonDecode(responseBody.body);
  //       } catch (e) {
  //         print('JSON Decode Error: $e');
  //         print('Response Body: ${responseBody.body}');
  //         return;
  //       }
  //
  //       if (jsonResponse != null &&
  //           jsonResponse.containsKey('data') &&
  //           jsonResponse['data'] != null) {
  //         var data = jsonResponse['data'];
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Product Added successfully')),
  //         );
  //         print('Product added with ID: ${data["productId"]}');
  //         print(productData);
  //       } else {
  //         print(
  //             'Response JSON does not contain "data" key or is null: $jsonResponse');
  //       }
  //     } else {
  //       print('Request failed with status code: ${response.statusCode}');
  //       print('Response Body: ${responseBody.body}');
  //     }
  //
  //     Navigator.push(context,
  //         MaterialPageRoute(builder: (context) => MainNavigation()));
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  //
  // }

  Future _showSaveDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Do you want to Add Product?',style: TextStyle(fontSize: 18),),
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
              onPressed: _submitData,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary1, secondary2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        onTap: () async {
                          print("Pick Images button tapped");
                          await imagePickerController.pickImages();
                        },
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            color: primary1.withOpacity(0.1),
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
                Obx(() {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: imagePickerController.selectedImages.length,
                    itemBuilder: (context, index) {
                      final image = imagePickerController.selectedImages[index];
                      return Stack(
                        children: [
                          Image.file(image, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.remove_circle_outline_sharp,
                                  color: secondary),
                              onPressed: () {
                                imagePickerController.removeImage(index);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
                const SizedBox(height: 20),
                // Product Name Field
                TextFormField(
                  controller: _productNameController,

                  style: TextStyle(color: primary, fontSize: 16),
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
                    if (!isNameUnique) {
                      return "Product name must be unique";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                // Display a live message.
                if (_productNameController.text.isNotEmpty)
                  Text(
                    isNameUnique ? "Name is available" : "Name is already taken",
                    style: TextStyle(
                      color: isNameUnique ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 15),
                // Description Field
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: primary, fontSize: 16),
                  maxLines: 2,
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
                  selectedCategory,
                  categoryList,
                  'cId',
                      (value) {
                    setState(() {
                      selectedCategory = value;
                      print(selectedCategory);
                      print(imagePickerController.selectedImages.toList());
                    });
                  },
                  'Select Category',
                ),

                // Show inputs in a row if selectedCategory is 1
                if (selectedCategory == '1') ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Length Input
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Length",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              length = value;
                              print(length);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Breadth Input
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Breadth",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              breadth = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Height Input
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Height",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              height = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                // Select Owner Dropdown
                _buildDropDownFormField(
                    selectedOrganization, organizations, null, (value) {
                  setState(() {
                    selectedOrganization = value;
                    print("new ${selectedOrganization}");
                  });
                }, 'Select Organizations'),
                const SizedBox(height: 20),
                // Add Department Button
                OutlinedButton(
                  onPressed: _addDepartment,
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      foregroundColor: textcolor,
                      side: BorderSide(color: primary1, width: 2)),
                  child: const Text(
                    'Add Department',
                    style: TextStyle(color: primary, fontSize: 16),
                  ),
                ),
                // const SizedBox(height: 20),
                SizedBox(
                  height: DepartmentData.length == 2 ? 420 : DepartmentData.length == 3 ? 550 : 220,
                  child: _departmentListView(DepartmentData, departmentList,
                      locationList, Color(0xFF02405E), Color(0xFF0485C4)),
                ),
                ElevatedButton.icon(
                  // onPressed: () {},
                  onPressed: () {
                    if(_productNameController.text.isEmpty ||
                        _descriptionController.text.isEmpty ||
                        selectedCategory == null ||
                        selectedOrganization == null|| isNameUnique == false ||
                      DepartmentData.isEmpty
                    ){
                      Get.snackbar(
                        'Error', // Title
                        'Please fill all the fields & Name is Unique', // Message
                        snackPosition: SnackPosition.TOP, // Position of snackbar
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        colorText: Colors.white,
                        duration: Duration(seconds: 2),
                      );
                    }
                    else {
                      _showSaveDialog();
                    }
                  },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
