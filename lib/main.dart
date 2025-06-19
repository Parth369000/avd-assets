// import 'package:avd_assets/Screens/Settings.dart';
// import 'package:avd_assets/Screens/splash_screen.dart';
import 'package:avd_assets/controller/login_controller.dart';
import 'package:avd_assets/model/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:avd_assets/Screens/ProductProvider.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:provider/provider.dart';
import 'package:avd_assets/Screens/homepage.dart';
import 'package:avd_assets/widgets/products.dart';
import 'package:avd_assets/Screens/MainNavigationState.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/splash_screen.dart';
import 'controller/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _loginStatusFuture;
  @override
  void initState() {
    super.initState();
    _loginStatusFuture = _checkLoginStatus();
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  final ThemeController themeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loginStatusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        } else {
          bool isLoggedIn = snapshot.data ?? false;
          return Obx(() {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeController.isDarkMode.value ? darkTheme : lightTheme,
              home: isLoggedIn ? MainNavigation() : LoginPage(),
            );
          });
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {

  bool isPasswordShown = false;
  bool isLoading = false;
  TextEditingController mobileController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final LoginController _controller = LoginController();
  String apiUrl = 'http://27.116.52.24:8054/login';

  @override
  void initState() {
    // setState(() {
    //   apiUrl = singletonData.apiUrl;
    // });
    super.initState();
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  onLogin() async {
    setState(() {
      isLoading = true;
    });

    final success = await _controller.login(
      mobileController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      await _saveLoginStatus();
      final prefs = await SharedPreferences.getInstance();
      // await prefs.setStringList("name", );
      Get.offAll(() => MainNavigation());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            showCloseIcon: true,
            content: Text("Please Enter Correct Login and Password."),
            backgroundColor: primary,
            duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context,constraints){
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    // Add the image above "Assets" text
                                    CircleAvatar(
                                      radius: 100,
                                      backgroundImage: AssetImage('assets/avd(1).png'),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'AVD Assets',
                                      style:
                                      TextStyle(fontWeight: FontWeight.bold, fontSize: 40,
                                      color: primary,
                                      ),
                                    ),
                                    // const Text(
                                    //   'Enter your credential to login',
                                    //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    // ),
                                  ],
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  width: deviceWidth * 0.8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        height: deviceHeight * 0.08,
                                        child: TextFormField(
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: primary1
                                          ),
                                          controller: mobileController,
                                          keyboardType: TextInputType.phone,
                                          textInputAction: TextInputAction.next,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                            hintText: 'Mobile No',
                                            fillColor: secondary.withOpacity(0.1),
                                            filled: true,
                                            prefixIcon: const Icon(Icons.person,color: primary1,),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        height: deviceHeight * 0.08,
                                        child: TextFormField(
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: primary1
                                          ),
                                          controller: passwordController,
                                          textInputAction: TextInputAction.done,
                                          obscureText: !isPasswordShown,
                                          // onFieldSubmitted: (v) => onLogin(),
                                          decoration: InputDecoration(
                                            suffixIcon: Material(
                                              color: Colors.transparent,
                                              child: IconButton(
                                                onPressed: onPassShowClicked,
                                                icon: Icon(
                                                  isPasswordShown ? Icons.visibility : Icons.visibility_off,
                                                  color: primary1,
                                                )
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            hintText: 'Password',
                                            fillColor: secondary.withOpacity(0.1),
                                            filled: true,
                                            prefixIcon: const Icon(Icons.password,color:primary1,),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      ElevatedButton(
                                        onPressed: (){
                                          if(mobileController.text.length == 10){
                                            onLogin();
                                          }
                                          else{
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Mobile Number Must be 10 digit."),
                                                backgroundColor: primary,
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                        // onPressed: () async {
                                        //   final prefs = await SharedPreferences.getInstance();
                                        //   await prefs.setBool('isLoggedIn', true);
                                        //
                                        //   setState(() {});
                                        //
                                        //   Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => MainNavigation()),
                                        //   );
                                        // },
                                        style: ElevatedButton.styleFrom(

                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          backgroundColor: primary,
                                        ),
                                        child: const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),

            );
          },

        ),
      ),
    );
  }
}
