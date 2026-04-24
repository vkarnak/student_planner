import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _error;

  bool _isLoading = false;

  String? get token => _token;
  bool get isAuth => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 🔐 LOGIN
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final t = await AuthService.login(email, password);

      if (t == null) {
        _error = "Invalid email or password";
        return false;
      }

      _token = t;
      ApiService.token = t;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', t);

      return true;
    } catch (e) {
      _error = "Server error";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🔁 AUTO LOGIN
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');

    if (savedToken != null) {
      _token = savedToken;
      ApiService.token = savedToken;
      notifyListeners();
    }
  }

  // 📝 REGISTER
  Future<bool> register(String email, String password, String name) async {
    _setLoading(true);
    _error = null;

    try {
      final success = await AuthService.register(email, password, name);

      if (!success) {
        _error = "Registration failed";
        return false;
      }

      // 🔥 АВТОЛОГИН
      return await login(email, password);
    } catch (e) {
      _error = "Server error";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    _token = null;
    ApiService.token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    notifyListeners();
  }

  // 🔧 helper
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
