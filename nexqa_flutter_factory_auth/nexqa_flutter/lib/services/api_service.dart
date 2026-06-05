import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── عنوان الخادم (قابل للتخصيص من الإعدادات) ──────────────────────
  static const String _defaultIp = '192.168.100.6';
  static const int _defaultPort = 5001;

  static String _serverIp = _defaultIp;
  static int _serverPort = _defaultPort;

  static String get baseUrl => 'http://$_serverIp:$_serverPort';

  /// تحميل إعدادات الخادم من SharedPreferences
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _serverIp = prefs.getString('server_ip') ?? _defaultIp;
    _serverPort = prefs.getInt('server_port') ?? _defaultPort;
  }

  /// حفظ إعدادات الخادم
  static Future<void> saveSettings(String ip, int port) async {
    _serverIp = ip;
    _serverPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', ip);
    await prefs.setInt('server_port', port);
  }

  static String get currentIp => _serverIp;
  static int get currentPort => _serverPort;

  // ── فحص جودة الخشب ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> predict(String imagePath,
      {Uint8List? bytes}) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/api/predict'));

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
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ── مختبر مزج الدهانات 🎨 ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getColorRecipe(
      Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/color-recipe'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'color_sample.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 40));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'خطأ في الخادم: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ── جلب سجل الألوان من الخادم 📋 ─────────────────────────────────
  static Future<Map<String, dynamic>> getColorHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/color-history'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'خطأ في الخادم: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ── فحص الاتصال بالخادم ──────────────────────────────────────────
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── المصادقة ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> signUp(
      String factoryName, String password) async {
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

  static Future<Map<String, dynamic>> login(
      String factoryName, String password) async {
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
