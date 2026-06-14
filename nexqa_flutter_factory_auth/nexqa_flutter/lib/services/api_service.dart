import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ── عنوان الخادم الإنتاجي على Railway ────────────────────────────
  /// رابط الـ Backend المنشور على Railway.com
  /// سيُحدَّث تلقائياً بعد أول deployment
  static const String _productionUrl =
      'https://nexqa-engine-production.up.railway.app';

  /// وضع التطوير المحلي (شبكة منزلية)
  static const String _devIp = '192.168.100.6';
  static const int _devPort = 5001;

  // القيم الافتراضية تستخدم الرابط الإنتاجي
  static String _customUrl = _productionUrl;
  static bool _useCustom = false;

  /// الرابط الفعلي المستخدم
  static String get baseUrl => _useCustom ? _customUrl : _productionUrl;

  /// تحميل إعدادات الخادم من SharedPreferences
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_url');
    if (saved != null && saved.isNotEmpty) {
      _customUrl = saved;
      _useCustom = true;
    } else {
      _useCustom = false;
    }
  }

  /// حفظ عنوان مخصص (للاختبار المحلي من شاشة الإعدادات)
  static Future<void> saveCustomUrl(String url) async {
    _customUrl = url.trim();
    _useCustom = _customUrl.isNotEmpty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _customUrl);
  }

  /// إعادة الضبط للرابط الإنتاجي
  static Future<void> resetToProduction() async {
    _useCustom = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
  }

  // للتوافق مع شاشة الإعدادات القديمة
  static Future<void> saveSettings(String ip, int port) async {
    final url = ip.startsWith('http') ? ip : 'http://$ip:$port';
    await saveCustomUrl(url);
  }

  static String get currentIp =>
      _useCustom ? _customUrl : _productionUrl;
  static int get currentPort => _useCustom ? _devPort : 443;

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
