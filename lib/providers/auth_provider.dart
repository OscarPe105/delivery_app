import 'package:flutter/material.dart';

enum UserType { business, customer }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.customer;
  String _userId = '';

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  String get userId => _userId;

  Future<bool> login(String email, String password, UserType type) async {
    // Simulación de autenticación para el MVP
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userType = type;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password, UserType type) async {
    // Simulación de registro para el MVP
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userType = type;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userId = '';
    notifyListeners();
  }
}