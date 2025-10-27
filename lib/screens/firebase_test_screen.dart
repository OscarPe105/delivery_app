import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/firebase_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/firebase_messaging_service.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final _authService = FirebaseAuthService();
  final _storageService = FirebaseStorageService();
  final _messagingService = FirebaseMessagingService();
  
  String _status = 'Inicializando...';
  String _fcmToken = '';
  String _userInfo = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    setState(() => _status = 'Inicializando Firebase...');
    
    try {
      // Verificar si Firebase está inicializado
      final firebaseService = FirebaseService();
      if (firebaseService.isInitialized) {
        setState(() => _status = '✅ Firebase inicializado correctamente');
        
        // Obtener token FCM
        _fcmToken = await FirebaseService.getFCMToken() ?? 'No disponible';
        
        // Verificar usuario actual
        final user = FirebaseService.auth.currentUser;
        if (user != null) {
          _userInfo = 'Usuario: ${user.email} (${user.uid})';
        } else {
          _userInfo = 'No hay usuario autenticado';
        }
        
        setState(() {});
      } else {
        setState(() => _status = '❌ Firebase no inicializado');
      }
    } catch (e) {
      setState(() => _status = '❌ Error: $e');
    }
  }

  Future<void> _testFirestore() async {
    setState(() => _status = 'Probando Firestore...');
    
    try {
      await FirebaseService.firestore.collection('test').doc('connection').set({
        'message': 'Conexión exitosa desde Flutter',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      setState(() => _status = '✅ Firestore funcionando correctamente');
    } catch (e) {
      setState(() => _status = '❌ Error Firestore: $e');
    }
  }

  Future<void> _testStorage() async {
    setState(() => _status = 'Probando Firebase Storage...');
    
    try {
      // Crear un archivo de prueba
      final testData = 'Test data from Flutter app';
      final ref = FirebaseService.storage.ref().child('test/test-file.txt');
      
      await ref.putString(testData);
      final downloadUrl = await ref.getDownloadURL();
      
      setState(() => _status = '✅ Storage funcionando: $downloadUrl');
    } catch (e) {
      setState(() => _status = '❌ Error Storage: $e');
    }
  }

  Future<void> _testAuth() async {
    setState(() => _status = 'Probando autenticación...');
    
    try {
      // Crear usuario de prueba
      final result = await _authService.signUpWithEmail(
        email: 'test@example.com',
        password: 'password123',
        name: 'Usuario Prueba',
        phone: '+1234567890',
        userType: 'customer',
      );
      
      if (result['success']) {
        setState(() => _status = '✅ Autenticación funcionando');
        _userInfo = 'Usuario: ${result['user'].email} (${result['user'].id})';
      } else {
        setState(() => _status = '❌ Error Auth: ${result['error']}');
      }
    } catch (e) {
      setState(() => _status = '❌ Error Auth: $e');
    }
  }

  Future<void> _testMessaging() async {
    setState(() => _status = 'Probando Cloud Messaging...');
    
    try {
      await _messagingService.initialize();
      setState(() => _status = '✅ Cloud Messaging inicializado');
    } catch (e) {
      setState(() => _status = '❌ Error Messaging: $e');
    }
  }

  Future<void> _testAnalytics() async {
    setState(() => _status = 'Probando Analytics...');
    
    try {
      await FirebaseService.logEvent('firebase_test', parameters: {
        'test_type': 'integration_test',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      
      setState(() => _status = '✅ Analytics funcionando');
    } catch (e) {
      setState(() => _status = '❌ Error Analytics: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      setState(() {
        _userInfo = 'No hay usuario autenticado';
        _status = 'Usuario deslogueado';
      });
    } catch (e) {
      setState(() => _status = '❌ Error logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Estado actual
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado de Firebase',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    Text('Token FCM: $_fcmToken'),
                    const SizedBox(height: 8),
                    Text(_userInfo),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botones de prueba
            ElevatedButton.icon(
              onPressed: _testFirestore,
              icon: const Icon(Icons.cloud),
              label: const Text('Probar Firestore'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testStorage,
              icon: const Icon(Icons.storage),
              label: const Text('Probar Storage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testAuth,
              icon: const Icon(Icons.login),
              label: const Text('Probar Autenticación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testMessaging,
              icon: const Icon(Icons.notifications),
              label: const Text('Probar Messaging'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton.icon(
              onPressed: _testAnalytics,
              icon: const Icon(Icons.analytics),
              label: const Text('Probar Analytics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botón de logout
            if (FirebaseService.auth.currentUser != null)
              ElevatedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Información del proyecto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Proyecto Firebase',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Proyecto ID: delivery-app-15f53'),
                    const Text('Storage Bucket: delivery-app-15f53.firebasestorage.app'),
                    const Text('Sender ID: 397640943349'),
                    const Text('App ID: 1:397640943349:android:46f26f58525316e2a5a7bc'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
