import 'package:flutter/material.dart';
import '../models/user.dart';

enum UserType { business, customer }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.customer;
  String _userId = '';
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  String get userId => _userId;
  User? get currentUser => _currentUser;
  User? get user => _currentUser; // ✅ Agregar este getter
  
  Future<bool> login(String email, String password, UserType type) async {
    // Simulación de autenticación para el MVP
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      _userType = type;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Crear usuario de ejemplo
      _currentUser = User(
        id: _userId,
        name: 'Roberto Efraín Velasco',
        email: email,
        phone: '+50361600151',
      );
      
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
      
      // Crear usuario con datos del registro
      _currentUser = User(
        id: _userId,
        name: name,
        email: email,
        phone: '+50300000000', // Teléfono por defecto
      );
      
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _userId = '';
    _currentUser = null;
    notifyListeners();
  }
}