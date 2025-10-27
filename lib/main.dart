// 🚀 ARCHIVO PRINCIPAL DE LA APLICACIÓN
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // Comentado temporalmente
// Este archivo es el punto de entrada de la aplicación y configura los proveedores y temas
// 🔐 Importar proveedores para gestión de estado
import 'providers/auth_provider.dart';         // Autenticación
import 'providers/business_provider.dart';     // Negocios
import 'providers/community_store_provider.dart'; // Tienda comunitaria
import 'providers/customer_provider.dart';     // Cliente
import 'providers/theme_provider.dart';        // Tema
// 📱 Importar pantallas
import 'screens/auth/user_type_router.dart';        // Router de tipos de usuario
import 'screens/search_screen.dart';            // Pantalla de búsqueda
import 'screens/test_screen.dart';              // Pantalla de prueba
import 'screens/business/business_registration_screen.dart'; // 📝 Pantalla de registro de negocio
import 'screens/business/business_onboarding_screen.dart';
import 'screens/business/business_dashboard_screen.dart';
import 'screens/firebase_test_screen.dart';
import 'services/firebase_service.dart';

// FUNCIÓN PRINCIPAL
// Punto de entrada de la aplicación
void main() async {
  // INICIALIZAR FLUTTER BINDING PRIMERO
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAR FIREBASE
  await FirebaseService.initialize();
  
  // CONFIGURAR MAPBOX OPTIONS DESPUÉS DE INICIALIZAR BINDING (comentado temporalmente)
  // MapboxOptions.setAccessToken(MapboxConfig.accessToken);
  
  runApp(const DeliveryApp());
}

// 📱 CLASE PRINCIPAL DE LA APLICACIÓN
class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 📊 PROVEEDORES DE ESTADO
      // Configuración de todos los proveedores para gestión de estado global
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),      // Tema
        ChangeNotifierProvider(create: (_) => AuthProvider()),        // Autenticación
        ChangeNotifierProvider(create: (_) => BusinessProvider()),    // Negocios
        ChangeNotifierProvider(create: (_) => CommunityStoreProvider()), // Tienda
        ChangeNotifierProvider(create: (_) => CustomerProvider()),    // Cliente
      ],
      // 📱 CONFIGURACIÓN DE LA APLICACIÓN
      // Escucha cambios en ThemeProvider y AuthProvider
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'Delivery Comunitario',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // 🔀 RUTAS NOMBRADAS
            routes: {
              '/': (context) => const UserTypeRouter(), // Usar el router de tipos de usuario
              '/search': (context) => const SearchScreen(),
              '/test': (context) => const TestScreen(),
              '/firebase-test': (context) => const FirebaseTestScreen(),
              '/business/register': (context) => const BusinessRegistrationScreen(),
              '/business/onboarding': (context) => const BusinessOnboardingScreen(),
              '/business/dashboard': (context) => const BusinessDashboardScreen(),
            },
            initialRoute: '/',
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
