// controllers/login_controller.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  final String apiUrl = 'http://27.116.52.24:8054/login';
  final storage = GetStorage();

  Future<bool> login(String mobile, String password) async {
    final Map<String, dynamic> data = {'mobile': mobile, 'password': password};

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);
        final token = jsonResponse['data']['token'];
        final role = jsonResponse['data']['role'];
        await storage.write('cookie', token);
        print(jsonResponse);
        final prefs = await SharedPreferences.getInstance();
        print(jsonResponse['data']['name']);
        print(jsonResponse['data']['mobile']);
        print(jsonResponse['data']['role']);
        await prefs.setString("name", jsonResponse['data']['name']);
        await prefs.setString("mobile", jsonResponse['data']['mobile']);
        await prefs.setString("role", jsonResponse['data']['role']);
        await storage.write('role',role );
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }
}