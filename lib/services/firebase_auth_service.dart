import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream del usuario actual
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Usuario actual
  User? get currentUser => _auth.currentUser;

  /// Registro con email y contraseña
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔥 Iniciando creación de usuario en Firebase Auth');
      }
      
      // Crear usuario en Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ Usuario creado en Firebase Auth');
      }

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Error creando usuario');
      }

      // Actualizar perfil
      await user.updateDisplayName(name);
      
      if (kDebugMode) {
        debugPrint('✅ Display name actualizado');
      }
      
      await user.sendEmailVerification();
      
      if (kDebugMode) {
        debugPrint('✅ Email de verificación enviado');
      }

      // Crear documento en Firestore
      await _createUserDocument(user, {
        'name': name,
        'phone': phone,
        'userType': userType,
        'email': email,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('✅ Documento creado en Firestore');
      }

      // Guardar token FCM
      await _saveFCMToken(user.uid);

      if (kDebugMode) {
        debugPrint('✅ Token FCM guardado');
      }

      return {
        'success': true,
        'user': _convertToAppUser(user),
        'message': 'Usuario creado exitosamente',
      };
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      }
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Exception en signUpWithEmail: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'error': 'Error inesperado: ${e.toString()}',
      };
    }
  }

  /// Registro con email y contraseña (método simplificado para AuthProvider)
  Future<Map<String, dynamic>> createUserWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String userType,
  }) async {
    if (kDebugMode) {
      debugPrint('🔐 Creando usuario con Firebase Auth');
      debugPrint('📧 Email: $email');
      debugPrint('👤 Nombre: $displayName');
      debugPrint('🏷️ Tipo: $userType');
    }
    
    try {
      final result = await signUpWithEmail(
        email: email,
        password: password,
        name: displayName,
        phone: '+50300000000', // Teléfono por defecto
        userType: userType,
      );
      
      if (kDebugMode) {
        debugPrint('✅ Resultado del registro: ${result['success']}');
        if (result['success'] == false) {
          debugPrint('❌ Error: ${result['error']}');
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Excepción en createUserWithEmail: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'error': 'Error inesperado: ${e.toString()}',
      };
    }
  }

  /// Login con email y contraseña (método simplificado para AuthProvider)
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Login interno con email y contraseña
  Future<Map<String, dynamic>> _signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception('Error en el login');
      }

      // Actualizar último login en Firestore
      await _updateLastLogin(user.uid);

      // Guardar token FCM
      await _saveFCMToken(user.uid);

      return {
        'success': true,
        'user': _convertToAppUser(user),
        'message': 'Login exitoso',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error inesperado: ${e.toString()}',
      };
    }
  }


  /// Logout
  Future<void> signOut() async {
    try {
      // Remover token FCM del documento del usuario
      if (currentUser != null) {
        await _removeFCMToken(currentUser!.uid);
      }

      await _auth.signOut();
      
      // Limpiar datos locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      
      if (kDebugMode) {
        debugPrint('✅ Usuario deslogueado exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error en logout: $e');
      }
      rethrow;
    }
  }

  /// Enviar email de verificación
  Future<bool> sendEmailVerification() async {
    try {
      User? user = currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error enviando email de verificación: $e');
      }
      return false;
    }
  }

  /// Enviar email de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error enviando email de restablecimiento: $e');
      }
      return false;
    }
  }

  /// Actualizar perfil del usuario
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? phone,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) return false;

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      // Actualizar en Firestore
      Map<String, dynamic> updates = {};
      if (displayName != null) updates['name'] = displayName;
      if (photoURL != null) updates['profileImage'] = photoURL;
      if (phone != null) updates['phone'] = phone;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(updates);
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error actualizando perfil: $e');
      }
      return false;
    }
  }

  /// Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error obteniendo datos del usuario: $e');
      }
      return null;
    }

  }

  /// Crear documento de usuario en Firestore
  Future<void> _createUserDocument(User user, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  /// Actualizar último login
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  /// Guardar token FCM
  Future<void> _saveFCMToken(String uid) async {
    try {
      // TODO: Implementar obtención de token FCM
      String? fcmToken = await _getFCMToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': fcmToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error guardando token FCM: $e');
      }
    }
  }

  /// Remover token FCM
  Future<void> _removeFCMToken(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error removiendo token FCM: $e');
      }
    }

  }

  /// Obtener token FCM
  Future<String?> _getFCMToken() async {
    try {
      // TODO: Implementar obtención real del token FCM
      return 'mock-fcm-token';
    } catch (e) {
      return null;
    }
  }

  /// Convertir User de Firebase a User de la app
  app_user.User _convertToAppUser(User firebaseUser) {
    return app_user.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      phone: '', // Se obtendrá desde Firestore
      profileImage: firebaseUser.photoURL,
    );
  }

  /// Iniciar sesión con Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return {'success': false, 'error': 'Usuario canceló el login'};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Crear o actualizar usuario en Firestore
        await _createOrUpdateUserDocument(firebaseUser);
        
        return {
          'success': true,
          'user': _createUserFromFirebaseUser(firebaseUser),
        };
      } else {
        return {'success': false, 'error': 'Error al obtener usuario de Firebase'};
      }
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      // Manejo específico del error de compatibilidad
      if (e.toString().contains('PigeonUserDetails')) {
        return {'success': false, 'error': 'Error de compatibilidad con Google Sign-In. Intenta con email y contraseña.'};
      }
      return {'success': false, 'error': _getErrorMessage(e.toString())};
    }
  }

  /// Crear o actualizar documento de usuario en Firestore
  Future<void> _createOrUpdateUserDocument(User firebaseUser) async {
    try {
      final userData = {
        'id': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName ?? '',
        'phone': '', // Se puede obtener de datos adicionales
        'profileImage': firebaseUser.photoURL,
        'userType': 'customer',
        'isVerified': firebaseUser.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      };

      // Verificar si el usuario ya existe
      DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      
      if (doc.exists) {
        // Actualizar datos existentes
        final existingData = doc.data() as Map<String, dynamic>?;
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'name': firebaseUser.displayName ?? existingData?['name'] ?? '',
          'profileImage': firebaseUser.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Crear nuevo usuario
        await _firestore.collection('users').doc(firebaseUser.uid).set(userData);
      }
    } catch (e) {
      debugPrint('Error creando/actualizando usuario en Firestore: $e');
    }
  }

  /// Crear objeto User desde Firebase User
  app_user.User _createUserFromFirebaseUser(User firebaseUser) {
    return app_user.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email ?? '',
      email: firebaseUser.email ?? '',
      phone: '', // Se obtendrá desde Firestore
      profileImage: firebaseUser.photoURL,
    );
  }

  /// Obtener mensaje de error en español
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'email-already-in-use':
        return 'El email ya está en uso';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      default:
        return 'Error de autenticación: $errorCode';
    }
  }
}
