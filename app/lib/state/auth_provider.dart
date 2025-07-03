// lib/state/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:momentum_app/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // When the app starts, try to load the token from storage
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return;
    }
    _token = prefs.getString('authToken');
    notifyListeners(); // Notify widgets that we are now authenticated
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.login(email: email, password: password);
      _token = result['access_token'];

      // Save the token to the device
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', _token!);

      _isLoading = false;
      notifyListeners(); // Notify widgets that login is complete
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Re-throw the exception so the UI can catch it
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    notifyListeners();
  }
}
