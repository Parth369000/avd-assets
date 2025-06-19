// import 'package:flutter/material.dart';
// import 'package:avd_assets/model/product.dart';
//
// class ProductProvider with ChangeNotifier {
//   final List<Product> _products = [
//     Product(
//       productName: "Tapelu",
//       description: "svsfvf",
//       category: "Chopping Table",
//       owner: "Avd",
//       department: "Kitchen",
//       location: "Rasoda Pachad",
//       quantity: 2,
//       productImage: "assets/1.jpg",
//     ),
//     Product(
//       productName: "Tapelu",
//       description: "svsfvf",
//       category: "Chopping Table",
//       owner: "Avd",
//       department: "Kitchen",
//       location: "Rasoda Pachad",
//       quantity: 2,
//       productImage: "assets/1.jpg",
//     ),
//     Product(
//       productName: "Tapelu",
//       description: "svsfvf",
//       category: "Chopping Table",
//       owner: "Avd",
//       department: "Kitchen",
//       location: "Rasoda Pachad",
//       quantity: 2,
//       productImage: "assets/1.jpg",
//     ),
//
//   ];
//
//   List<Product> get products => List.unmodifiable(_products);
//
//   void addProduct(Product product) {
//     _products.add(product);
//     notifyListeners();
//   }
//
//   void updateProduct(String id, Product updatedProduct) {
//     final index = _products.indexWhere((product) => product.id == id);
//     if (index != -1) {
//       _products[index] = updatedProduct;
//       notifyListeners();
//     }
//   }
//
//   void deleteProduct(String id) {
//     _products.removeWhere((product) => product.id == id);
//     notifyListeners();
//   }
// }
