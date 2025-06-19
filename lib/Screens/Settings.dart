import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avd_assets/controller/theme_controller.dart';
import '../main.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ThemeController themeController = Get.find();
  late String name = "";
  late String mobile = "";
  late String role = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    print(name);
    print(mobile);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      mobile = prefs.getString("mobile") ?? "";
      role = prefs.getString("role") ?? "";

      switch(role){
        case "admin":
          role = "Admin";
          break;
        case "KDept":
          role = "Kitchen Department";
          break;
        case "VDept":
          role = "Video Department";
          break;
        case "DDept":
          role = "Decoration Department";
          break;
      }
    });
  }

  Future<void> _clearLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    name = prefs.getString("name") ?? "";
    mobile = prefs.getString("mobile") ?? "";
    role = prefs.getString("role") ?? "";
  }

  void onLogout() async {
    await _clearLoginStatus();
    Get.offAll(() => LoginPage());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,color: primary,),
            onPressed: () => onLogout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'profilePic',
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/avd.jpg'),
                ),
              ),
              SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Text(
                          name!,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF405D72),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          mobile!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Color(0xFF758694),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          role!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Color(0xFF758694),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 30),
              
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}