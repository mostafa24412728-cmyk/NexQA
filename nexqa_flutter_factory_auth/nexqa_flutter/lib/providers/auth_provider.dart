import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _factoryNameKey = 'auth_factory_name';
  static const _passwordKey = 'auth_password';
  static const _sessionKey = 'auth_is_logged_in';

  String? _factoryName;
  bool _isAuthenticated = false;

  String? get factoryName => _factoryName;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _factoryName = prefs.getString(_factoryNameKey);
    _isAuthenticated = prefs.getBool(_sessionKey) ?? false;
    notifyListeners();
  }

  Future<void> signUp({
    required String factoryName,
    required String password,
  }) async {
    final cleanFactoryName = factoryName.trim();
    if (cleanFactoryName.length < 2) {
      throw Exception('Please enter the factory name.');
    }
    if (password.length < 4) {
      throw Exception('Password must be at least 4 characters.');
    }

    final prefs = await SharedPreferences.getInstance();
    
    // Call Backend
    final response = await ApiService.signUp(cleanFactoryName, password);
    if (response['success'] == false) {
      throw Exception(response['message'] ?? 'Signup failed');
    }

    await prefs.setString(_factoryNameKey, cleanFactoryName);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_sessionKey, true);

    _factoryName = cleanFactoryName;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signIn({
    required String factoryName,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Call Backend
    final response = await ApiService.login(factoryName, password);
    if (response['success'] == false) {
      throw Exception(response['message'] ?? 'Login failed');
    }

    await prefs.setString(_factoryNameKey, factoryName);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_sessionKey, true);
    
    _factoryName = factoryName;
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    _isAuthenticated = false;
    notifyListeners();
  }
}
