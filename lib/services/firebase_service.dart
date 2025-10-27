import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Instancias de Firebase
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  // Estado de inicialización
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Inicializar Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseService()._isInitialized = true;
      
      // Configurar Analytics
      await analytics.setAnalyticsCollectionEnabled(true);
      
      // Configurar Messaging
      await _setupMessaging();
      
      if (kDebugMode) {
        print('Firebase inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando Firebase: $e');
      }
      rethrow;
    }
  }

  /// Configurar Firebase Messaging
  static Future<void> _setupMessaging() async {
    try {
      // En web, messaging requiere service worker que no está configurado
      // Solo configurar en Android/iOS
      if (kIsWeb) {
        if (kDebugMode) {
          print('Messaging no configurado en web');
        }
        return;
      }
      
      // Solicitar permisos para notificaciones
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) {
          print('Usuario autorizó las notificaciones');
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (kDebugMode) {
          print('Usuario autorizó las notificaciones provisionales');
        }
      } else {
        if (kDebugMode) {
          print('Usuario denegó las notificaciones');
        }
      }

      // Obtener token FCM
      String? token = await messaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print('📱 Token FCM: $token');
        }
        // Guardar token en SharedPreferences o enviar al backend
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error configurando messaging: $e');
      }
      // No relanzar el error, solo loguear
    }
  }

  /// Obtener token FCM del dispositivo
  static Future<String?> getFCMToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error obteniendo token FCM: $e');
      }
      return null;
    }
  }

  /// Suscribirse a un tópico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Suscrito al tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print(' Error suscribiéndose al tópico $topic: $e');
      }
    }
  }

  /// Desuscribirse de un tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print(' Desuscrito del tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print(' Error desuscribiéndose del tópico $topic: $e');
      }
    }
  }

  /// Registrar evento en Analytics
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        print(' Evento Analytics: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        print(' Error registrando evento Analytics: $e');
      }
    }
  }

  /// Configurar usuario en Analytics
  static Future<void> setUserId(String userId) async {
    try {
      await analytics.setUserId(id: userId);
      if (kDebugMode) {
        print(' Usuario configurado en Analytics: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print(' Error configurando usuario en Analytics: $e');
      }
    }
  }

  /// Configurar propiedades de usuario en Analytics
  static Future<void> setUserProperties({
    String? userType,
    String? phone,
  }) async {
    try {
      Map<String, String> properties = {};
      if (userType != null) properties['user_type'] = userType;
      if (phone != null) properties['phone'] = phone;
      
      // await analytics.setUserProperties(properties: properties);
      if (kDebugMode) {
        print(' Propiedades de usuario configuradas: $properties');
      }
    } catch (e) {
      if (kDebugMode) {
        print(' Error configurando propiedades de usuario: $e');
      }
    }
  }
}
