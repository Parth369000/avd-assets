import 'dart:convert';
import 'package:avd_assets/model/product_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class productController extends GetxController {
  var productList = <productModel>[].obs;
  var filterProductList = <productModel>[].obs;
  TextEditingController searchController = TextEditingController();

   var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
     getProduct();
     searchController.addListener(_filterProducts);
}

  // void getProduct() async {
  //   String productUrl = "http://27.116.52.24:8054/getProducts";
  //   try {
  //     final response = await http.post(Uri.parse(productUrl));
  //     print('API Response: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final List result = jsonDecode(response.body)['data'];
  //       // Map the results and sort alphabetically by product name.
  //       var products = result.map((e) => productModel.fromJson(e)).toList();
  //       products.sort((a, b) =>
  //           (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
  //       productList.value = products;
  //       print('Sorted product count: ${productList.value.length}');
  //       // print('Product List: ${productList.length}');
  //     } else {
  //       print('Error: ${response.statusCode}');
  //       Get.snackbar(
  //         'Error Loading data!',
  //         'Server responded: ${response.statusCode}:${response.reasonPhrase}',
  //       );
  //     }
  //   } catch (e) {
  //     print('Exception: $e');
  //     Get.snackbar('Error', 'An error occurred: $e');
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  void getProduct() async {
    String productUrl = "http://27.116.52.24:8054/getProducts";
    try {
      final response = await http.post(Uri.parse(productUrl));
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body)['data'];
        var products = result.map((e) => productModel.fromJson(e)).toList();
        products.sort((a, b) =>
            (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));

        // Get the user's role from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? userRole = prefs.getString("role");

        switch(userRole){
          case 'KDept':
            products = products.where((product) {
              return product.storage!.any((storage) => storage.department.toString() == 'Kitchen');
            }).toList();
            break;
          case 'VDept':
            products = products.where((product) {
              return product.storage!.any((storage) => storage.department.toString() == 'Video');
            }).toList();
            break;
          case 'DDept':
            products = products.where((product) {
              return product.storage!.any((storage) => storage.department.toString() == 'Decoration');
            }).toList();
            break;
          // case 'Admin':
          //   products = result.map((e) => productModel.fromJson(e)).toList();
          //   break;
          // default:
          //   products = result.map((e) => productModel.fromJson(e)).toList();
          //   break;
        }

        productList.value = products;
        print('Sorted product count: ${productList.value.length}');
      } else {
        print('Error: ${response.statusCode}');
        Get.snackbar(
          'Error Loading data!',
          'Server responded: ${response.statusCode}:${response.reasonPhrase}',
        );
      }
    } catch (e) {
      print('Exception: $e');
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _filterProducts() async {
    String query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filterProductList.value = []; // Set empty list when no query
    } else {
      var filtered = productList.where((product) {
        return product.name?.toLowerCase().contains(query) ?? false;
      }).toList();
      // Sort the filtered products alphabetically
      filtered.sort((a, b) =>
          (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase()));
      final prefs = await SharedPreferences.getInstance();
      String? userRole = prefs.getString("role");

      switch(userRole){
        case 'KDept':
          filtered = filtered.where((product) {
            return product.storage!.any((storage) => storage.department.toString() == 'Kitchen');
          }).toList();
          break;
        case 'VDept':
          filtered = filtered.where((product) {
            return product.storage!.any((storage) => storage.department.toString() == 'Video');
          }).toList();
          break;
        case 'DDept':
          filtered = filtered.where((product) {
            return product.storage!.any((storage) => storage.department.toString() == 'Decoration');
          }).toList();
          break;
        case 'Admin':
          filtered = filtered;
          break;
        default:
          filtered = filtered;
          break;
      }

      filterProductList.value = filtered;

      print('Sorted filtered product count: ${filterProductList.value.length}');
    }
  }
}
