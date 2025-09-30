// 🚀 ARCHIVO PRINCIPAL DE LA APLICACIÓN
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart'; // ✅ Comentado temporalmente
// Este archivo es el punto de entrada de la aplicación y configura los proveedores y temas
// 🔐 Importar proveedores para gestión de estado
import 'providers/auth_provider.dart';         // 🔑 Autenticación
import 'providers/business_provider.dart';     // 🏪 Negocios
import 'providers/community_store_provider.dart'; // 🛒 Tienda comunitaria
import 'providers/customer_provider.dart';     // 👤 Cliente
import 'providers/theme_provider.dart';        // 🎨 Tema
import 'config/mapbox_config.dart'; // ✅ Agregar esta importación
// 📱 Importar pantallas
import 'screens/main_navigation.dart';          // 🧭 Navegación principal
import 'screens/auth/login_screen.dart';        // 🔑 Pantalla de inicio de sesión
import 'screens/search_screen.dart';            // 🔍 Pantalla de búsqueda
import 'screens/test_screen.dart';              // 🧪 Pantalla de prueba

// 🚀 FUNCIÓN PRINCIPAL
// Punto de entrada de la aplicación
void main() {
  // ✅ INICIALIZAR FLUTTER BINDING PRIMERO
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ CONFIGURAR MAPBOX OPTIONS DESPUÉS DE INICIALIZAR BINDING (comentado temporalmente)
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),      // 🎨 Tema
        ChangeNotifierProvider(create: (_) => AuthProvider()),        // 🔑 Autenticación
        ChangeNotifierProvider(create: (_) => BusinessProvider()),    // 🏪 Negocios
        ChangeNotifierProvider(create: (_) => CommunityStoreProvider()), // 🛒 Tienda
        ChangeNotifierProvider(create: (_) => CustomerProvider()),    // 👤 Cliente
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
              '/': (context) => authProvider.isAuthenticated 
                  ? MainNavigation()  // ✅ Removido 'const'
                  : LoginScreen(),
              '/main': (context) => MainNavigation(),  // ✅ Removido 'const'
              '/login': (context) => LoginScreen(),
              '/search': (context) => const SearchScreen(),
              '/test': (context) => const TestScreen(),
            },
            initialRoute: '/',
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
