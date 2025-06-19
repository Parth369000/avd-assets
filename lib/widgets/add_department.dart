import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Screens/MainNavigationState.dart';
import '../controller/common_controller.dart';
import '../model/department_model.dart';
import '../model/location_model.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:http/http.dart' as http;

class AddDepartment extends StatefulWidget {
  List<Map<String, dynamic>>
      data; // Data with department, locations, and quantities
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];

  AddDepartment({
    super.key,
    required this.data,
    required this.locationList,
    required this.departmentList,
  });

  @override
  State<AddDepartment> createState() => _AddDepartmentState();
}

class _AddDepartmentState extends State<AddDepartment> {
  List<Map<String, dynamic>> departmentForms = [];
  int formCount = 0;
  static bool isLoading = true;
  Set<String> selectedDepartments = {};

  @override
  void initState() {
    super.initState();
    print('AddDepartment class called');
    if (widget.data.isEmpty) {
      _addNewDepartmentForm({});
    } else {
      for (var data in widget.data) {
        print('data: $data');
        _addNewDepartmentForm(data);
        print('data closed');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to add new department form with preselected 'dId' and locations with quantities
  void _addNewDepartmentForm(Map<String, dynamic> data) {
    final formKey = GlobalKey<_AddDepartmentFormState>();

    setState(() {
      departmentForms.add({
        "id": formCount,
        "key": formKey,
        "widget": AddDepartmentForm(
          key: formKey,
          preselectedDepartmentId: data.isEmpty ? null : data['dId'].toString(),
          preselectedLocations: data.isEmpty ? [] : data['locations'] ?? [],
          locationList: widget.locationList,
          departmentList: widget.departmentList,
          selectedDepartments: selectedDepartments,
          onDepartmentSelected: (oldValue, newValue) {
            setState(() {
              if (oldValue != null) selectedDepartments.remove(oldValue);
              if (newValue != null) selectedDepartments.add(newValue);
            });
          },
        ),
      });
      formCount++;
    });

    // else {
    //   setState(() {
    //     departmentForms.add({
    //       "id": formCount,
    //       "key": formKey,
    //       "widget": AddDepartmentForm(
    //         key: formKey,
    //         // Use ValueKey for uniqueness
    //         preselectedDepartmentId: data['dId'].toString(),
    //         preselectedLocations: data['locations'] ?? [],
    //         // Ensure it's a list
    //         departmentList: widget.departmentList,
    //         locationList: widget.locationList,
    //         selectedDepartments: selectedDepartment,
    //         onDepartmentSelected: (oldValue, newValue) {
    //           setState(() {
    //             if (oldValue != null) selectedDepartment.remove(oldValue);
    //             if (newValue != null) selectedDepartment.add(newValue);
    //           });
    //         },
    //       ),
    //     });
    //     formCount++;
    //   });
    // }
  }

  Future<void> _saveProduct() async {
    List<Map<String, dynamic>> submittedData = [];
    for (var form in departmentForms) {
      final formKey = form["key"] as GlobalKey<_AddDepartmentFormState>?;
      if (formKey != null) {
        final formState = formKey.currentState;
        if (formState != null) {
          final departmentData = formState.getDepartmentData();
          if (departmentData["dId"] != null &&
              departmentData["locations"].isNotEmpty) {
            submittedData.add(departmentData);
          }
        }
      }
    }
    Navigator.pop(context, submittedData);
    // // EasyLoading.show();
    // final Uri url = Uri.http('27.116.52.24:8054', '/editProduct');
    // var request = http.Request('POST', url);
    // request.headers["Content-Type"] = "application/json";
    // Map<String, dynamic> productData =  {
    //   "productId": widget.productId,
    //   "name": widget.name,
    //   "description": widget.description,
    //   "cid": int.parse(widget.selectedCategory!), // Ensure category ID is an integer
    //   // "dimension":"${widthController.text}*${breadthController.text}*${heightController.text}",
    //   "org":widget.selectedOrganization,
    //   "departments": submittedData.map((department) {
    //     return {
    //       "dId": department["dId"],
    //       "locations": (department["locations"] as List).map((location) {
    //         return {
    //           "lId": location["locationId"],
    //           "quantity": location["quantity"].toString(),
    //         };
    //       }).toList(),
    //     };
    //   }).toList()
    // };
    //
    // print(productData);
    // request.body = jsonEncode(productData);
    //
    // var response = await request.send();
    // var responseBody = await http.Response.fromStream(response);
    //
    // if (response.statusCode == 200) {
    //   var jsonResponse;
    //
    //   try {
    //     jsonResponse = jsonDecode(responseBody.body);
    //   } catch (e) {
    //     print('JSON Decode Error: $e');
    //     print('Response Body: ${responseBody.body}');
    //     return;
    //   }
    //
    //   if (jsonResponse != null &&
    //       jsonResponse.containsKey('data') &&
    //       jsonResponse['data'] != null) {
    //     var data = jsonResponse['data'];
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Product Added successfully')),
    //     );
    //     // print('Product added with ID: ${int.tryParse(data["productId"])}');
    //     print(productData);
    //   } else {
    //     print(
    //         'Response JSON does not contain "data" key or is null: $jsonResponse');
    //   }
    // } else {
    //   print('Request failed with status code: ${response.statusCode}');
    //   print('Response Body: ${responseBody.body}');
    // }
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => MainNavigation()),
    // );
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
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25, 50, 16, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: departmentForms.map((form) {
                    return Container(
                      key: ValueKey(form["id"]),
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Departments",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (departmentForms.length > 1) {
                                        departmentForms.remove(form);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "At least one department is required"),
                                          ),
                                        );
                                      }
                                    });
                                  }),
                            ],
                          ),
                          form["widget"],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  if (departmentForms.length >= widget.departmentList.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You cannot add more than ${widget.departmentList.length} departments.",
                        ),
                      ),
                    );
                  } else {
                    _addNewDepartmentForm({});
                  }
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                label: Text(
                  "Add Another Department",
                  style: TextStyle(fontSize: 18, color: Colors.blue),
                ),
              ),
              SizedBox(height: 20),
              // Row(
              //   children: [
              //     ElevatedButton.icon(
              //       onPressed: () {
              //         Navigator.pop(context);
              //       },
              //       icon: Icon(
              //         Icons.send,
              //         color: background,
              //         size: 18, // Adjusted icon size
              //       ),
              //       label: Text("Cancel",
              //           style: TextStyle(
              //               fontSize: 25,
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold)),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.redAccent,
              //         padding: const EdgeInsets.symmetric(vertical: 16),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //     ),
              //     SizedBox(width: 10),
              //     ElevatedButton.icon(
              //       onPressed: _saveProduct,
              //       icon: Icon(
              //         Icons.send,
              //         color: background,
              //         size: 18, // Adjusted icon size
              //       ),
              //       label: Text("Submit",
              //           style: TextStyle(
              //               fontSize: 25,
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold)),
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.blue,
              //         padding: const EdgeInsets.symmetric(vertical: 16),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 18, // Reduced size for better fit
                    ),
                    label: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Adjusted font size for better alignment
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15), // Increased horizontal padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _saveProduct,
                    icon: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18, // Adjusted icon size
                    ),
                    label: Text(
                      "Submit",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Adjusted font size for consistency
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary1,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
}

class AddDepartmentForm extends StatefulWidget {
  final String? preselectedDepartmentId; // Pass the preselected dId
  final List<Map<String, dynamic>>
      preselectedLocations; // Locations and quantities
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];
  final Set<String> selectedDepartments;
  final Function(String? oldValue, String? newValue) onDepartmentSelected;

  AddDepartmentForm({
    super.key,
    required this.preselectedDepartmentId,
    required this.preselectedLocations, // Accept preselected locations and quantities
    required this.locationList,
    required this.departmentList,
    required this.selectedDepartments,
    required this.onDepartmentSelected,
  });

  @override
  _AddDepartmentFormState createState() => _AddDepartmentFormState();
}

class _AddDepartmentFormState extends State<AddDepartmentForm> {
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];
  List<GetLocation> departmentWiseLocations = [];
  String? selectedDepartment;
  Map<String, TextEditingController> quantityControllers = {};
  List<Map<String, dynamic>> addedLocations = [];
  List<getDept> availableDepartments = [];

  static bool isLoading = true;

  @override
  // void initState() {
  //   super.initState();
  //
  //   departmentList = widget.departmentList;
  //   locationList = widget.locationList;
  //   print('AddDepartmentForm called');
  //   selectedDepartment = widget.preselectedDepartmentId;
  //   addedLocations = widget.preselectedLocations;
  //   departmentWiseLocations = locationList
  //       .where((location) => location.dId.toString() == selectedDepartment)
  //       .toList();
  //   print(departmentWiseLocations);
  //   if (widget.preselectedDepartmentId != null) {
  //     selectedDepartment = widget.preselectedDepartmentId;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       widget.onDepartmentSelected(null, selectedDepartment);
  //     });
  //   }
  //   availableDept();
  //   // Initialize controllers for preselected locations
  //   for (var location in addedLocations) {
  //     print('location: $location');
  //     quantityControllers[location["locationId"].toString()] =
  //         TextEditingController(text: location["quantity"].toString());
  //     print(
  //         'Quantity: ${quantityControllers[location["locationId"].toString()]}');
  //   }
  //   // Future.delayed(Duration(seconds: 3), () {
  //   //   setState(() {
  //   //     isLoading = false;
  //   //   });
  //   // });
  //
  //   print(quantityControllers.toString());
  // }
  @override
  void initState() {
    super.initState();

    departmentList = widget.departmentList;
    locationList = widget.locationList;
    print('AddDepartmentForm called');
    selectedDepartment = widget.preselectedDepartmentId;
    addedLocations = widget.preselectedLocations;
    departmentWiseLocations = locationList
        .where((location) => location.dId.toString() == selectedDepartment)
        .toList();
    print(departmentWiseLocations);

    if (widget.preselectedDepartmentId != null &&
        widget.preselectedDepartmentId!.isNotEmpty) {
      selectedDepartment = widget.preselectedDepartmentId;
      // Only call parent's callback if it’s not already added
      if (!widget.selectedDepartments.contains(selectedDepartment)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDepartmentSelected(null, selectedDepartment);
        });
      }
    }
    availableDept();

    // Initialize controllers for preselected locations
    for (var location in addedLocations) {
      print('location: $location');
      quantityControllers[location["locationId"].toString()] =
          TextEditingController(text: location["quantity"].toString());
      print(
          'Quantity: ${quantityControllers[location["locationId"].toString()]}');
    }

    print(quantityControllers.toString());
  }

  void availableDept() {
    availableDepartments = departmentList.where((dept) {
      String deptId = dept.toJson()['dId'].toString();
      // Allow this department if it is NOT selected in any other form,
      // or if it's the one already selected in THIS form.
      return (!widget.selectedDepartments.contains(deptId)) ||
          (selectedDepartment == deptId);
    }).toList();
  }

  Widget _buildDropDownFormField(String? value, List items, String? Ids,
      void Function(String?)? onChanged, String labelText) {
    return DropdownButtonFormField<String>(
      value: value,
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
        prefixIcon: const Icon(Icons.category, color: secondary),
        filled: true,
        fillColor: secondary.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Map<String, dynamic> getDepartmentData() {
    // for (var loc in addedLocations) {
    //   loc["quantity"] =
    //       int.tryParse(quantityControllers[loc["locationId"]]?.text ?? "1") ?? 1;
    // }
    return {
      "dId": selectedDepartment,
      "locations": addedLocations,
    };
  }

  void _addLocation(String locationId) {
    if (addedLocations.any((loc) => loc["locationId"] == locationId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Location already added. Update the quantity instead.")),
      );
    } else {
      setState(() {
        addedLocations.add({"locationId": locationId, "quantity": ""});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    availableDept();
    return Column(
      children: [
        // DropdownButtonFormField<String>(
        //   borderRadius: BorderRadius.circular(10),
        //   value: selectedDepartment,
        //   items: availableDepartments.map((item) {
        //     String? itemId;
        //     String? itemName;
        //
        //     itemId = item.toJson()['dId'].toString();
        //     itemName = item.name;
        //
        //     return DropdownMenuItem(
        //       value: itemId,
        //       child: Text(itemName!),
        //     );
        //   }).toList(),
        //   onChanged: (value) {
        //     String? oldValue = selectedDepartment;
        //     setState(() {
        //       selectedDepartment = value;
        //       departmentWiseLocations = locationList
        //           .where((location) => location.dId.toString() == value)
        //           .toList();
        //       addedLocations.clear();
        //     });
        //     widget.onDepartmentSelected(oldValue, value);
        //     availableDept();
        //   },
        //   decoration: InputDecoration(
        //     labelText: 'select department',
        //     prefixIcon: const Icon(Icons.category, color: secondary),
        //     filled: true,
        //     fillColor: secondary.withOpacity(0.1),
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(10),
        //       borderSide: BorderSide.none,
        //     ),
        //   ),
        // ),
        DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(10),
          value: selectedDepartment,
          items: availableDepartments.map((item) {
            String itemId = item.toJson()['dId'].toString();
            String itemName = item.name;
            return DropdownMenuItem(
              value: itemId,
              child: Text(itemName),
            );
          }).toList(),
          onChanged: (value) {
            String? oldValue = selectedDepartment;
            setState(() {
              selectedDepartment = value;
              departmentWiseLocations = locationList
                  .where((location) => location.dId.toString() == value)
                  .toList();
              addedLocations.clear();
            });
            widget.onDepartmentSelected(oldValue, value);
            availableDept();
          },
          decoration: InputDecoration(
            labelText: 'Select Department',
            prefixIcon: const Icon(Icons.category, color: secondary),
            filled: true,
            fillColor: secondary.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: 15),
        _buildDropDownFormField(
            departmentWiseLocations.isNotEmpty
                ? departmentWiseLocations.first.lId.toString()
                : null,
            departmentWiseLocations,
            "lId", (value) {
          setState(() {
            if (value != null) {
              _addLocation(value);
            }
          });
        }, "Select Location"),
        SizedBox(
          height: 20,
        ),
        Column(
          children: addedLocations.map((location) {
            print("Searching for locationId: ${location['locationId']}");
            print(
                "Available locations: ${locationList.map((loc) => loc.lId).toList()}");

            String locationName = locationList
                .firstWhere(
                  (item) =>
                      item.lId.toString() == location['locationId'].toString(),
                )
                .name;

            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "$locationName : ",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: location['quantity'].toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          location['quantity'] = int.tryParse(value) ?? 1;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "Quantity",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    addedLocations.remove(location);
                  });
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
