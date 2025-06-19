import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Screens/MainNavigationState.dart';
import '../controller/common_controller.dart';
import '../model/department_model.dart';
import '../model/location_model.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:http/http.dart' as http;

class EditDepartment extends StatefulWidget {
  List<Map<String, dynamic>> data; // Data with department, locations, and quantities
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];


  EditDepartment({
    super.key,
    required this.data,
    required this.locationList,
    required this.departmentList,
  });

  @override
  State<EditDepartment> createState() => _EditDepartmentState();
}

class _EditDepartmentState extends State<EditDepartment> {
  List<Map<String, dynamic>> departmentForms = [];
  int formCount = 0;
  static bool isLoading = true;
  Set<String> selectedDepartments = {};

  @override
  void initState() {
    super.initState();
    print('Edit Department class called');
    // Initialize the department forms based on the incoming data
    for (var data in widget.data) {
      print('data: $data');
      _addNewDepartmentForm(data);
      print('data closed');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to add new department form with preselected 'dId' and locations with quantities
  void _addNewDepartmentForm(Map<String, dynamic> data) {
    final formKey = GlobalKey<_EditDepartmentFormState>();

    setState(() {
      // For new forms (empty data), you can pass a null preselectedDepartmentId.
      // Otherwise, use the provided data.
      departmentForms.add({
        "id": formCount,
        "key": formKey,
        "widget": EditDepartmentForm(
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
  }

  Future<void> _saveProduct() async {
    List<Map<String, dynamic>> submittedData = [];

    // Loop through each form's data
    for (var form in departmentForms) {
      final formKey = form["key"] as GlobalKey<_EditDepartmentFormState>?;
      if (formKey != null) {
        final formState = formKey.currentState;
        if (formState != null) {
          final departmentData = formState.getDepartmentData();
          // Check if the department data has a valid dId and non-empty locations list
          if (departmentData["dId"] != null &&
              (departmentData["locations"] as List).isNotEmpty) {
            // Loop through each location in the form to check quantity
            bool missingQuantity = false;
            for (var loc in departmentData["locations"]) {
              // Check if quantity is null, an empty string, or consists only of whitespace.
              if (loc["quantity"] == null ||
                  loc["quantity"].toString().trim().isEmpty) {
                missingQuantity = true;
                break;
              }
            }
            if (missingQuantity) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Please add a quantity for selected location.")),
              );
              return; // Exit the function without saving
            }
            submittedData.add(departmentData);
          }
        }
      }
    }
    Navigator.pop(context, submittedData);
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
                                      if(departmentForms.length > 1){
                                        departmentForms.remove(form);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("At least one department is required"),
                                          ),
                                        );
                                      }
                                    });
                                  }
                              ),
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
                  // Prevent adding more forms than available departments.
                  if (departmentForms.length >= widget.departmentList.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "You cannot add more than ${widget.departmentList.length} departments."),
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
              Row(
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
                          vertical: 15
                      ), // Increased horizontal padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton.icon(
                    onPressed: _saveProduct,
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 22,
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
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
  }
}

class EditDepartmentForm extends StatefulWidget {
  final String? preselectedDepartmentId; // Pass the preselected dId
  final List<Map<String, dynamic>> preselectedLocations; // Locations and quantities
  List<GetLocation> locationList = [];
  List<getDept> departmentList = [];
  final Set<String> selectedDepartments;
  final Function(String? oldValue,String? newValue) onDepartmentSelected;
  EditDepartmentForm({
    super.key,
    required this.preselectedDepartmentId,
    required this.preselectedLocations, // Accept preselected locations and quantities
    required this.locationList,
    required this.departmentList,
    required this.selectedDepartments,
    required this.onDepartmentSelected,
  });

  @override
  _EditDepartmentFormState createState() => _EditDepartmentFormState();
}

class _EditDepartmentFormState extends State<EditDepartmentForm> {
  List<getDept> departmentList = [];
  List<GetLocation> locationList = [];
  List<GetLocation> departmentWiseLocations = [];
  String? selectedDepartment;
  Map<String, TextEditingController> quantityControllers = {};
  List<Map<String, dynamic>> addedLocations = [];
  List<getDept> availableDepartments = [];
  static bool isLoading = true;
  @override
  void initState() {
    super.initState();
    departmentList = widget.departmentList;
    locationList = widget.locationList;
    print('AddDepartmentForm called');
    selectedDepartment = widget.preselectedDepartmentId;
    addedLocations = widget.preselectedLocations;
    departmentWiseLocations = locationList.where((location) => location.dId.toString() == selectedDepartment).toList();
    print(departmentWiseLocations);

    if (selectedDepartment != null &&
        !widget.selectedDepartments.contains(selectedDepartment)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onDepartmentSelected(null, selectedDepartment);
      });
    }
    availableDept();
    for (var location in addedLocations) {
      print('location: $location');
      quantityControllers[location["locationId"].toString()] =
          TextEditingController(text: location["quantity"].toString());
      print('Quantity: ${quantityControllers[location["locationId"].toString()]}');
    }
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isLoading = false;
      });
    });

    print(quantityControllers);

  }

  void availableDept(){
    availableDepartments = departmentList.where((dept) {
      String deptId = dept.toJson()['dId'].toString();
      return (!widget.selectedDepartments.contains(deptId)) || (selectedDepartment == deptId);
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
    return Column(
      children: [
        DropdownButtonFormField<String>(
          borderRadius: BorderRadius.circular(10),
          value: selectedDepartment,
          items: availableDepartments.map((item) {
            String? itemId;
            String? itemName;

            itemId = item.toJson()['dId'].toString();
            itemName = item.name;

            return DropdownMenuItem(
              value: itemId,
              child: Text(itemName!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDepartment = value;
              departmentWiseLocations = locationList.where((location) => location.dId.toString() == value).toList();
              addedLocations.clear();
            });
          },
          decoration: InputDecoration(
            labelText: 'select department',
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
        SizedBox(height: 20,),
        Column(
          children: addedLocations.map((location) {
            print("Searching for locationId: ${location['locationId']}");
            print("Available locations: ${locationList.map((loc) => loc.lId).toList()}");

            String locationName = locationList.firstWhere(
                  (item) => item.lId.toString() == location['locationId'].toString(),
            ).name;

            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      "$locationName : ",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: quantityControllers[location['locationId'].toString()],
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