import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;
  int get totalProducts => _products.length;
  int get passedCount => _products.where((p) => p.status == 'passed').length;
  int get rejectedCount => _products.where((p) => p.status == 'rejected').length;
  List<Product> get passedProducts => _products.where((p) => p.status == 'passed').toList();
  List<Product> get rejectedProducts => _products.where((p) => p.status == 'rejected').toList();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('products') ?? [];
    _products = data
        .map((s) => Product.fromJson(jsonDecode(s)))
        .toList()
      ..sort((a, b) => b.inspectedAt.compareTo(a.inspectedAt));
    notifyListeners();
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

  Future<void> clearAll() async {
    _products = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('products');
    notifyListeners();
  }
}
