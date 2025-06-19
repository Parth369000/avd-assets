// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:http/http.dart' as http;
//
// Future<void> submitProductData(BuildContext context) async {
//   try {
//     EasyLoading.show(status: 'Submitting...');
//
//     final Uri url = Uri.http('27.116.52.24:8054', '/addProductWithStorage');
//     var request = http.Request('POST', url);
//     request.headers["Content-Type"] = "application/json";
//
//     Map<String, dynamic> productData = {
//       "name": productNameController.text,
//       "description": descriptionController.text,
//       "cid": int.tryParse(selectedCategory ?? "0") ?? 0,
//       "dimension": "${widthController.text}*${breadthController.text}*${heightController.text}",
//       "org": selectedOrganization,
//       "departments": departmentLocationQuantityList.map((department) {
//         return {
//           "dId": department["departmentId"],
//           "locations": department["locations"].map((location) {
//             return {
//               "lId": location["locationId"],
//               "quantity": int.tryParse(location["quantity"].text) ?? 0,
//             };
//           }).toList(),
//         };
//       }).toList(),
//     };
//
//     request.body = jsonEncode(productData);
//     var response = await request.send();
//
//     if (response.statusCode == 200) {
//       var responseBody = await http.Response.fromStream(response);
//       var jsonResponse = jsonDecode(responseBody.body);
//       var data = jsonResponse['data'];
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Product added successfully')),
//       );
//       await addImages();
//       print('Product added with ID: ${data["productId"]}');
//     } else {
//       print('Request failed with status code: ${response.statusCode}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to add product. Code: ${response.statusCode}')),
//       );
//     }
//   } catch (e) {
//     print('Error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error occurred: $e')),
//     );
//   } finally {
//     EasyLoading.dismiss();
//   }
// }
