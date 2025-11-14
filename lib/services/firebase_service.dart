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
      
      // Configurar Analytics (evitar 404 en web cuando no hay config de Analytics)
      if (!kIsWeb) {
        await analytics.setAnalyticsCollectionEnabled(true);
      }

      // Configurar Messaging
      await _setupMessaging();
      
      if (kDebugMode) {
        debugPrint('Firebase inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error inicializando Firebase: $e');
      }
      rethrow;
    }
  }

  /// Configurar Firebase Messaging
  static Future<void> _setupMessaging() async {
    try {
      // Solicitar permisos para notificaciones
      NotificationSettings settings;
      if (kIsWeb) {
        settings = await messaging.requestPermission();
      } else {
        settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      if (kDebugMode) {
        switch (settings.authorizationStatus) {
          case AuthorizationStatus.authorized:
            debugPrint('Usuario autorizó las notificaciones');
            break;
          case AuthorizationStatus.provisional:
            debugPrint('Usuario autorizó las notificaciones provisionales');
            break;
          default:
            debugPrint('Usuario denegó las notificaciones');
        }
      }

      // Obtener token FCM (usar VAPID en web)
      String? token = await messaging.getToken(
        vapidKey: kIsWeb ? _webVapidKey : null,
      );
      if (token != null) {
        if (kDebugMode) {
          debugPrint('📱 Token FCM: $token');
        }
        // Guardar token en SharedPreferences o enviar al backend
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error configurando messaging: $e');
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
        debugPrint('Error obteniendo token FCM: $e');
      }
      return null;
    }
  }

  /// Suscribirse a un tópico
  static Future<void> subscribeToTopic(String topic) async {
    try {
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint(' Suscripciones a tópicos no son compatibles en web');
        }
        return;
      }
      await messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        debugPrint('Suscrito al tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' Error suscribiéndose al tópico $topic: $e');
      }
    }
  }

  /// Desuscribirse de un tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (kIsWeb) {
        if (kDebugMode) {
          debugPrint(' Desuscripciones a tópicos no son compatibles en web');
        }
        return;
      }
      await messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        debugPrint(' Desuscrito del tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' Error desuscribiéndose del tópico $topic: $e');
      }
    }
  }

  /// Registrar evento en Analytics
  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    try {
      await analytics.logEvent(name: name, parameters: parameters);
      if (kDebugMode) {
        debugPrint(' Evento Analytics: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' Error registrando evento Analytics: $e');
      }
    }
  }

  /// Configurar usuario en Analytics
  static Future<void> setUserId(String userId) async {
    try {
      await analytics.setUserId(id: userId);
      if (kDebugMode) {
        debugPrint(' Usuario configurado en Analytics: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' Error configurando usuario en Analytics: $e');
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
        debugPrint(' Propiedades de usuario configuradas: $properties');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(' Error configurando propiedades de usuario: $e');
      }
    }
  }
}

// VAPID key para notificaciones web (provista por el usuario)
const String _webVapidKey =
    'BEBmZEF5QDOX41JPuZBoovAlWqlYUwhvYehEycFPCcXG7-R6qcHYCLbmD28N9SQ0ZMW916IKKPotuWm6J-FLBC4';
