import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_messaging_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

enum UserType { customer, business, driver }

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  UserType _userType = UserType.customer;
  String _userId = '';
  User? _currentUser;
  String? _firebaseIdToken;
  String? _lastError;
  String? get token => _firebaseIdToken;
  String? get firebaseIdToken => _firebaseIdToken;
  String? get lastError => _lastError;
  
  // Servicio de Firebase
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  bool get isAuthenticated => _isAuthenticated;
  UserType get userType => _userType;
  String get userId => _userId;
  User? get currentUser => _currentUser;
  User? get user => _currentUser;
  
  Future<bool> login(String email, String password, [UserType? type]) async {
    try {
      debugPrint('🔐 Iniciando login con Firebase: $email');
      
      // USAR SOLO FIREBASE AUTHENTICATION
      final result = await _firebaseAuth.signInWithEmail(
        email: email,
        password: password,
      );
      
      debugPrint('✅ Resultado de Firebase: ${result['success']}');
      
      if (result['success'] == true) {
        _isAuthenticated = true;
        _userId = result['user']?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        _currentUser = result['user'];
        _firebaseIdToken = await _firebaseAuth.currentUser?.getIdToken();
        
        if (kDebugMode) {
          debugPrint('✅ Firebase ID Token obtenido: ${_firebaseIdToken?.substring(0, 20)}...');
        }
        
        // Detectar automáticamente si el usuario tiene un negocio registrado
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('user_id', _userId);
        if (_firebaseIdToken != null) {
          await prefs.setString('firebase_id_token', _firebaseIdToken!);
        }
        
        // Detectar automáticamente si el usuario tiene un negocio registrado
        await _detectUserType();

        // Hidratar datos adicionales del perfil desde Firestore
        await _hydrateCurrentUserFromFirestore();
        
        // Suscribirse a notificaciones push
        try {
          final messagingService = FirebaseMessagingService();
          if (_userType == UserType.business) {
            // Si es dueño de negocio, buscar el businessId y suscribirse
            final firestore = FirebaseFirestore.instance;
            final businessQuery = await firestore
                .collection('businesses')
                .where('ownerUid', isEqualTo: _userId)
                .limit(1)
                .get();
            if (businessQuery.docs.isNotEmpty) {
              final businessId = businessQuery.docs.first.id;
              await messagingService.subscribeToBusinessNotifications(businessId);
            }
          } else if (_userType == UserType.driver) {
            await messagingService.subscribeToDriverNotifications(_userId);
          } else {
            // Si es cliente, suscribirse a notificaciones de pedidos
            await messagingService.subscribeToOrderNotifications(_userId);
          }
        } catch (e) {
          debugPrint('⚠️ Error suscribiéndose a notificaciones: $e');
        }
        
        debugPrint('✅ Login exitoso, tipo de usuario: $_userType');
        
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ Error de login Firebase: ${result['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error en login Firebase: $e');
      
      // Fallback a mock en caso de error
      debugPrint('⚠️ Usando fallback mock para login');
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
        
        debugPrint('✅ Login mock exitoso');
        
        notifyListeners();
        return true;
      }
      
      return false;
    }
  }

  /// Detecta automáticamente si el usuario tiene un negocio registrado
  /// Verifica la información almacenada en Firestore
  Future<void> _detectUserType() async {
    try {
      final currentFirebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser == null) {
        _userType = UserType.customer;
        return;
      }

      final firestore = FirebaseFirestore.instance;
      UserType detectedType = UserType.customer;

      try {
        final userDoc = await firestore.collection('users').doc(currentFirebaseUser.uid).get();
        final userTypeValue = userDoc.data()?['userType']?.toString();
        detectedType = _mapStringToUserType(userTypeValue);
      } catch (e) {
        debugPrint('⚠️ Error consultando documento de usuario: $e');
      }

      if (detectedType == UserType.customer) {
        try {
          final businessQuery = await firestore
              .collection('businesses')
              .where('ownerUid', isEqualTo: currentFirebaseUser.uid)
              .limit(1)
              .get();

          if (businessQuery.docs.isNotEmpty) {
            detectedType = UserType.business;
            debugPrint('✅ Negocio encontrado en Firestore');
          }
        } catch (e) {
          debugPrint('⚠️ Error consultando negocios: $e');
        }
      }

      _userType = detectedType;
      debugPrint('👤 Tipo de usuario detectado: $_userType');
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error al detectar tipo de usuario: $e');
      // En caso de error, asumir cliente por defecto
      _userType = UserType.customer;
      notifyListeners();
    }
  }

  /// Actualiza el tipo de usuario manualmente (útil después de registrar un negocio)
  void setUserType(UserType type) {
    if (_userType != type) {
      _userType = type;
      debugPrint('👤 Tipo de usuario actualizado a: $type');
      notifyListeners();
    }
  }

  /// Verifica y actualiza el tipo de usuario (útil después de operaciones críticas)
  Future<void> refreshUserType() async {
    await _detectUserType();
  }

  Future<bool> register(String name, String email, String password, UserType type) async {
    try {
      // USAR SOLO FIREBASE AUTHENTICATION
      final result = await _firebaseAuth.createUserWithEmail(
        email: email,
        password: password,
        displayName: name,
        userType: _userTypeToString(type),
      );
      
      if (result['success'] == true) {
        _lastError = null; // Limpiar error previo
        _isAuthenticated = true;
        _userType = type;
        _userId = result['user']?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
        _currentUser = result['user'];
        _firebaseIdToken = await _firebaseAuth.currentUser?.getIdToken();
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('user_id', _userId);
        if (_firebaseIdToken != null) {
          await prefs.setString('firebase_id_token', _firebaseIdToken!);
        }

        await _hydrateCurrentUserFromFirestore();

        if (type == UserType.driver) {
          try {
            await FirebaseFirestore.instance.collection('drivers').doc(_userId).set({
              'uid': _userId,
              'name': name,
              'email': email,
              'phone': '',
              'availability': 'offline',
              'completedDeliveries': 0,
              'cancelledDeliveries': 0,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          } catch (e) {
            debugPrint('⚠️ Error creando perfil de repartidor: $e');
          }
        }

        notifyListeners();
        return true;
      } else {
        _lastError = result['error'] as String?;
        debugPrint('Error de registro Firebase: $_lastError');
        return false;
      }
    } catch (e) {
      debugPrint('Error en registro Firebase: $e');
      
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
    return login(email, password);
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
        _firebaseIdToken = await _firebaseAuth.currentUser?.getIdToken();
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('user_id', _userId);
        if (_firebaseIdToken != null) {
          await prefs.setString('firebase_id_token', _firebaseIdToken!);
        }
        notifyListeners();
        return true;
      } else {
        debugPrint('Error de login con Google: ${result['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error en login con Google: $e');
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
      _firebaseIdToken = null;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('firebase_id_token');
      await prefs.setBool('is_authenticated', false);
    } catch (e) {
      debugPrint('Error en logout: $e');
    }
  }

  Future<bool> updateUserProfile({
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    final trimmedName = displayName?.trim();
    final trimmedPhone = phone?.trim();

    final success = await _firebaseAuth.updateProfile(
      displayName: trimmedName?.isNotEmpty == true ? trimmedName : null,
      photoURL: photoUrl,
      phone: trimmedPhone,
    );

    if (success && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: trimmedName?.isNotEmpty == true ? trimmedName : null,
        phone: trimmedPhone ?? _currentUser!.phone,
        profileImage: photoUrl ?? _currentUser!.profileImage,
      );
      notifyListeners();
    }

    return success;
  }

  Future<void> refreshCurrentUserData() async {
    await _hydrateCurrentUserFromFirestore();
  }

  Future<void> _hydrateCurrentUserFromFirestore() async {
    final current = _currentUser;
    if (current == null || current.id.isEmpty) {
      return;
    }

    try {
      final data = await _firebaseAuth.getUserData(current.id);
      if (data == null) {
        return;
      }

      final fetchedName = data['name']?.toString();
      final fetchedPhone = data['phone']?.toString();
      final fetchedImage = data['profileImage']?.toString();

      final updatedUser = current.copyWith(
        name: fetchedName != null && fetchedName.isNotEmpty ? fetchedName : current.name,
        phone: fetchedPhone != null && fetchedPhone.isNotEmpty ? fetchedPhone : current.phone,
        profileImage: fetchedImage?.isNotEmpty == true ? fetchedImage : current.profileImage,
      );

      if (updatedUser.name != current.name ||
          updatedUser.phone != current.phone ||
          updatedUser.profileImage != current.profileImage) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ No se pudo obtener el perfil del usuario: $e');
      }
    }
  }

  String _userTypeToString(UserType type) {
    switch (type) {
      case UserType.business:
        return 'business';
      case UserType.driver:
        return 'driver';
      case UserType.customer:
        return 'customer';
    }
  }

  UserType _mapStringToUserType(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'business':
        return UserType.business;
      case 'driver':
        return UserType.driver;
      case 'customer':
        return UserType.customer;
    }
    return UserType.customer;
  }
}
