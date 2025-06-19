import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:http/http.dart' as http;

class CommonController{
  final storage = GetStorage();
  Future<List<dynamic>> fetchData(String table) async {
    final Uri url = Uri.http('27.116.52.24:8054', '/getData');

    try {
        Map<String, dynamic> body = {
          'table': table,
        };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return jsonResponse['data'] ?? [];
      } else {
        throw Exception('Failed to fetch $table data with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $table data: $e');
    }
  }

}
