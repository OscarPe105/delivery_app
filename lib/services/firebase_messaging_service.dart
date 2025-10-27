import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Token FCM
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Inicializar el servicio de mensajería
  Future<void> initialize() async {
    try {
      // Configurar notificaciones locales
      await _setupLocalNotifications();

      // Solicitar permisos
      await _requestPermissions();

      // Obtener token FCM
      await _getFCMToken();

      // Configurar manejadores de mensajes
      _setupMessageHandlers();

      if (kDebugMode) {
        print('✅ Firebase Messaging inicializado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando Firebase Messaging: $e');
      }
    }
  }

  /// Configurar notificaciones locales
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Solicitar permisos de notificación
  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
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
        print('✅ Permisos de notificación autorizados');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('✅ Permisos de notificación provisionales autorizados');
      }
    } else {
      if (kDebugMode) {
        print('❌ Permisos de notificación denegados');
      }
    }
  }

  /// Obtener token FCM
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        if (kDebugMode) {
          print('📱 Token FCM obtenido: $_fcmToken');
        }
        
        // TODO: Enviar token al backend Django
        await _sendTokenToBackend(_fcmToken!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo token FCM: $e');
      }
    }
  }

  /// Configurar manejadores de mensajes
  void _setupMessageHandlers() {
    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Manejar mensajes cuando la app está en segundo plano pero abierta
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Manejar mensajes cuando la app se abre desde una notificación
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });

    // Manejar cambios en el token
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) {
        print('🔄 Token FCM actualizado: $newToken');
      }
      _sendTokenToBackend(newToken);
    });
  }

  /// Manejar mensaje en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 Mensaje recibido en primer plano: ${message.messageId}');
    }

    // Mostrar notificación local
    await _showLocalNotification(message);
  }

  /// Manejar mensaje cuando se abre la app desde notificación
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 App abierta desde notificación: ${message.messageId}');
    }

    // Navegar a la pantalla correspondiente
    _navigateFromNotification(message.data);
  }

  /// Manejar mensaje inicial
  Future<void> _handleInitialMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('📨 Mensaje inicial: ${message.messageId}');
    }

    // Navegar a la pantalla correspondiente
    _navigateFromNotification(message.data);
  }

  /// Manejar tap en notificación local
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('📨 Notificación local tocada: ${response.payload}');
    }

    // Procesar payload si existe
    if (response.payload != null) {
      // TODO: Navegar según el payload
    }
  }

  /// Mostrar notificación local
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'delivery_app_channel',
      'Delivery App Notifications',
      channelDescription: 'Notificaciones de la app de delivery',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nueva notificación',
      message.notification?.body ?? 'Tienes una nueva notificación',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  /// Navegar desde notificación
  void _navigateFromNotification(Map<String, dynamic> data) {
    String type = data['type'] ?? '';
    
    switch (type) {
      case 'order_update':
        // TODO: Navegar a pantalla de pedido
        break;
      case 'new_order':
        // TODO: Navegar a pantalla de pedidos del negocio
        break;
      case 'order_status_update':
        // TODO: Navegar a pantalla de seguimiento de pedido
        break;
      default:
        // TODO: Navegar a pantalla principal
        break;
    }
  }

  /// Enviar token al backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      // TODO: Implementar envío del token al backend Django
      // await ApiService().updateFCMToken(token);
      
      if (kDebugMode) {
        print('📤 Token enviado al backend: $token');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error enviando token al backend: $e');
      }

    }

  }

  /// Suscribirse a tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('✅ Suscrito al tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error suscribiéndose al tópico $topic: $e');
      }
    }
  }

  /// Desuscribirse de tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('✅ Desuscrito del tópico: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error desuscribiéndose del tópico $topic: $e');
      }
    }

  }

  /// Suscribirse a notificaciones de pedidos
  Future<void> subscribeToOrderNotifications(String userId) async {
    await subscribeToTopic('user_$userId');
  }

  /// Suscribirse a notificaciones de negocio
  Future<void> subscribeToBusinessNotifications(String businessId) async {
    await subscribeToTopic('business_$businessId');
  }

  /// Desuscribirse de notificaciones de pedidos
  Future<void> unsubscribeFromOrderNotifications(String userId) async {
    await unsubscribeFromTopic('user_$userId');
  }

  /// Desuscribirse de notificaciones de negocio
  Future<void> unsubscribeFromBusinessNotifications(String businessId) async {
    await unsubscribeFromTopic('business_$businessId');
  }
}
