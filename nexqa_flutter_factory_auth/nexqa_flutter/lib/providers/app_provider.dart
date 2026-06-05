import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/paint_color.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<PaintColor> _paintColors = [];

  List<Product> get products => _products;
  int get totalProducts => _products.length;
  int get passedCount => _products.where((p) => p.status == 'passed').length;
  int get rejectedCount => _products.where((p) => p.status == 'rejected').length;
  List<Product> get passedProducts => _products.where((p) => p.status == 'passed').toList();
  List<Product> get rejectedProducts => _products.where((p) => p.status == 'rejected').toList();

  List<PaintColor> get paintColors => _paintColors;
  int get totalColors => _paintColors.length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // Load products
    final data = prefs.getStringList('products') ?? [];
    _products = data
        .map((s) => Product.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.inspectedAt.compareTo(a.inspectedAt));

    // Load paint colors
    final colorData = prefs.getStringList('paint_colors') ?? [];
    _paintColors = colorData
        .map((s) => PaintColor.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifyListeners();
  }

  /// جلب سجل الألوان من الخادم ودمجه مع المحفوظات المحلية
  Future<void> syncColorsFromServer() async {
    try {
      final result = await ApiService.getColorHistory();
      if (result['success'] != true) return;

      final List<dynamic> serverHistory = result['history'] ?? [];
      final existingIds = _paintColors.map((c) => c.id).toSet();

      final newColors = <PaintColor>[];
      for (final item in serverHistory) {
        final id = item['id'] as String? ?? '';
        if (existingIds.contains(id)) continue; // already have it locally

        newColors.add(PaintColor(
          id: id,
          imageBytes: null, // صور الخادم لا تُحمّل لتوفير البيانات
          hexCode: item['hex_code'] as String? ?? '#000000',
          r: item['r'] as int? ?? 0,
          g: item['g'] as int? ?? 0,
          b: item['b'] as int? ?? 0,
          colorName: item['color_name'] as String? ?? '',
          recipeMarkdown: item['recipe_markdown'] as String? ?? '',
          createdAt: DateTime.tryParse(item['created_at'] ?? '') ?? DateTime.now(),
        ));
      }

      if (newColors.isNotEmpty) {
        _paintColors = [..._paintColors, ...newColors];
        _paintColors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        // حفظ النتيجة المدمجة محلياً
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          'paint_colors',
          _paintColors.map((c) => jsonEncode(c.toJson())).toList(),
        );
        notifyListeners();
      }
    } catch (_) {
      // الفشل الصامت — الأولوية دائماً للبيانات المحلية
    }
  }

  Future<void> addProduct(Product product) async {
    _products.insert(0, product);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'products',
      _products.map((p) => jsonEncode(p.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> addPaintColor(PaintColor color) async {
    _paintColors.insert(0, color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'paint_colors',
      _paintColors.map((c) => jsonEncode(c.toJson())).toList(),
    );
    notifyListeners();
  }

  Future<void> clearAll() async {
    _products = [];
    _paintColors = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('products');
    await prefs.remove('paint_colors');
    notifyListeners();
  }
}
