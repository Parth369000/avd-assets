import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
const uuid = Uuid();

final Category = [
  "Table",
  "Chopping Table",
  "Base Platform",
  "Camera",
  "Battries",
  ];

final Owner = [
  "Avd",
  "HariPrabodham",
  "Hari Sumiran"
];

final Department = [
  "Kitchen",
  "Video",
  "Decoration"
];

final Location = [
  "PH Basement",
  "Rasoda Pachad",
  "Hostel Basement TT",
  "Hostel Basement Main",
  "Prathna Hall Room"
];

class Product{

  final String id;
  final String productName;
  final String description;
  final String category;
  final String owner;
  final String department;
  final String location;
  final int quantity;
  final String productImage;

  Product({
    required this.productName,
    required this.description,
    required this.category,
    required this.owner,
    required this.department,
    required this.location,
    required this.quantity,
    required this.productImage,
  }) : id = uuid.v4();


}




