import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:avd_assets/model/colors.dart'; // Import the colors

class ThemeController extends GetxController {


  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeTheme(isDarkMode.value ? darkTheme : lightTheme);
  }
}

final ThemeData lightTheme = ThemeData(
  primaryColor: primary,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    // backgroundColor: primary,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.light(
    primary: primary,
    secondary: secondary,
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: textcolor,
    onSurface: textcolor,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: textcolor),
    bodyMedium: TextStyle(color: textcolor),
  ),
);

final ThemeData darkTheme = ThemeData(
  primaryColor: primary,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: primary,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.dark(
    primary: primary,
    secondary: secondary,
    background: Colors.black,
    surface: Colors.black,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: textcolor,
    onSurface: textcolor,
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: textcolor),
    bodyMedium: TextStyle(color: textcolor),
  ),
);