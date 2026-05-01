import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for Web/iOS
  static String get baseUrl {
    // Chrome Web often works better with 'localhost' than '127.0.0.1' due to origin policies
    const String host = 'localhost'; 
    if (kIsWeb) return 'http://$host:5001';
    return 'http://10.0.2.2:5001';
  }


  static Future<Map<String, dynamic>> predict(String imagePath, {Uint8List? bytes}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/predict'));
      
      if (bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'upload.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> signUp(String factoryName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'factory_name': factoryName, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String factoryName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'factory_name': factoryName, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

