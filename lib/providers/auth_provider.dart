import 'package:flutter/material.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum UserType { business, customer }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.customer;
  String _userId = '';
  User? _currentUser;
  String? _token;
  String? get token => _token;
  
  // Servicio de Firebase
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  String get userId => _userId;
  User? get currentUser => _currentUser;
  User? get user => _currentUser; // Agregar este getter
  
  Future<bool> login(String email, String password, [UserType? type]) async {
    try {
      // Intentar login con Django API
      final apiService = ApiService();
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['tokens']?['access'];
        
        if (token != null) {
          // Guardar token en ApiService
          apiService.setDjangoToken(token);
          
          _isAuthenticated = true;
          _userId = data['user']?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          _token = token;
          
          // Obtener datos del usuario
          final userData = data['user'];
          _currentUser = User(
            id: _userId,
            name: userData['name'] ?? 'Usuario',
            email: email,
            phone: userData['phone'] ?? '',
          );
          
          // Detectar automáticamente si el usuario tiene un negocio registrado
          await _detectUserType();
          
          // Guardar en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setBool('is_authenticated', true);
          
          notifyListeners();
          return true;
        }
      }
      
      // Si falla Django, usar mock (fallback)
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userType = type ?? UserType.customer; // Usar tipo pasado o cliente por defecto
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        _currentUser = User(
          id: _userId,
          name: 'Usuario Demo',
          email: email,
          phone: '+50361600151',
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error en login Django: $e');
      
      // Fallback a mock en caso de error
      if (email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userType = type ?? UserType.customer; // Usar tipo pasado o cliente por defecto
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        _currentUser = User(
          id: _userId,
          name: 'Usuario Demo',
          email: email,
          phone: '+50361600151',
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    }
  }

  /// Detecta automáticamente si el usuario tiene un negocio registrado
  Future<void> _detectUserType() async {
    try {
      if (_token == null) {
        _userType = UserType.customer;
        return;
      }

      // Verificar si el usuario tiene un negocio registrado
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/businesses/my-business/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // El usuario tiene un negocio registrado
        _userType = UserType.business;
        debugPrint('Usuario detectado como dueño de negocio');
      } else if (response.statusCode == 404) {
        // El usuario no tiene negocio registrado
        _userType = UserType.customer;
        debugPrint('Usuario detectado como cliente');
      } else {
        // Error en la consulta, asumir cliente por defecto
        _userType = UserType.customer;
        debugPrint('Error al detectar tipo de usuario, usando cliente por defecto');
      }
    } catch (e) {
      debugPrint('Error al detectar tipo de usuario: $e');
      // En caso de error, asumir cliente por defecto
      _userType = UserType.customer;
    }
  }

  Future<bool> register(String name, String email, String password, UserType type) async {
    try {
      // Intentar registro con Django API
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'user_type': type == UserType.business ? 'business' : 'customer',
        }),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['tokens']?['access'];
        
        if (token != null) {
          _isAuthenticated = true;
          _userType = type;
          _userId = data['user']?['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
          _token = token;
          
          // Obtener datos del usuario
          final userData = data['user'];
          _currentUser = User(
            id: _userId,
            name: userData['name'] ?? name,
            email: email,
            phone: userData['phone'] ?? '+50300000000',
          );
          
          // Guardar en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setBool('is_authenticated', true);
          
          notifyListeners();
          return true;
        }
      }
      
      // Si falla Django, usar mock (fallback)
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userType = type;
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        _currentUser = User(
          id: _userId,
          name: name,
          email: email,
          phone: '+50300000000',
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error en registro Django: $e');
      
      // Fallback a mock en caso de error
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        _isAuthenticated = true;
        _userType = type;
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        _currentUser = User(
          id: _userId,
          name: name,
          email: email,
          phone: '+50300000000',
        );
        
        notifyListeners();
        return true;
      }
      
      return false;
    }
  }

  Future<bool> loginWithApi(String email, String password) async {
    try {
      // Usar Firebase Authentication
      final result = await _firebaseAuth.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (result['success'] == true) {
        _isAuthenticated = true;
        _userType = UserType.customer;
        _userId = result['user']?.id ?? '';
        _currentUser = result['user'];
        _token = await _firebaseAuth.currentUser?.getIdToken();
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token ?? '');
        await prefs.setBool('is_authenticated', true);
        
        notifyListeners();
        return true;
      } else {
        // Mostrar error si es necesario
        print('Error de login: ${result['error']}');
        return false;
      }
    } catch (e) {
      print('Error en login: $e');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    try {
      // Usar Firebase Authentication con Google
      final result = await _firebaseAuth.signInWithGoogle();
      
      if (result['success'] == true) {
        _isAuthenticated = true;
        _userType = UserType.customer;
        _userId = result['user']?.id ?? '';
        _currentUser = result['user'];
        _token = await _firebaseAuth.currentUser?.getIdToken();
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token ?? '');
        await prefs.setBool('is_authenticated', true);
        
        notifyListeners();
        return true;
      } else {
        print('Error de login con Google: ${result['error']}');
        return false;
      }
    } catch (e) {
      print('Error en login con Google: $e');
      return false;
    }
  }

  void logout() async {
    try {
      // Cerrar sesión en Firebase
      await _firebaseAuth.signOut();
      
      _isAuthenticated = false;
      _userId = '';
      _currentUser = null;
      _token = null;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.setBool('is_authenticated', false);
    } catch (e) {
      print('Error en logout: $e');
    }
  }
}