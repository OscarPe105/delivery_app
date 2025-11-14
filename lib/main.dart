// 🚀 ARCHIVO PRINCIPAL DE LA APLICACIÓN
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Este archivo es el punto de entrada de la aplicación y configura los proveedores y temas
// 🔐 Importar proveedores para gestión de estado
import 'providers/auth_provider.dart';         // Autenticación
import 'providers/business_provider.dart';     // Negocios
import 'providers/community_store_provider.dart'; // Tienda comunitaria
import 'providers/customer_provider.dart';     // Cliente
import 'providers/review_provider.dart';       // Reviews
import 'providers/delivery_provider.dart';     // Repartidores
import 'providers/theme_provider.dart';        // Tema
import 'themes/app_theme.dart';               // Tema centralizado
// 📱 Importar pantallas
import 'screens/auth/user_type_router.dart';        // Router de tipos de usuario
import 'screens/auth/register_screen.dart';         // Pantalla de registro
import 'screens/search_screen.dart';            // Pantalla de búsqueda
import 'screens/test_screen.dart';              // Pantalla de prueba
import 'screens/business/business_onboarding_screen.dart';
import 'screens/business/business_dashboard_screen.dart';
import 'screens/business_detail_screen.dart';
import 'screens/firebase_test_screen.dart';
import 'screens/admin/add_coordinates_screen.dart';
import 'screens/reviews/business_reviews_screen.dart';
import 'screens/reviews/create_review_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/favorites_screen.dart';
import 'services/firebase_service.dart';
import 'services/firebase_messaging_service.dart';
import 'models/business.dart';
import 'models/product.dart';

// FUNCIÓN PRINCIPAL
// Punto de entrada de la aplicación
void main() async {
  // INICIALIZAR FLUTTER BINDING PRIMERO
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAR FIREBASE
  await FirebaseService.initialize();
  
  // INICIALIZAR FIREBASE MESSAGING
  await FirebaseMessagingService().initialize();
  
  // Google Maps se configura automáticamente con la API key en AndroidManifest.xml
  // No es necesario configurar nada adicional aquí
  
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
        ChangeNotifierProvider(create: (_) => ReviewProvider()),      // Reviews
        ChangeNotifierProvider(create: (_) => DeliveryProvider()),    // Entregas
      ],
      // 📱 CONFIGURACIÓN DE LA APLICACIÓN
      // Escucha cambios en ThemeProvider y AuthProvider
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          return MaterialApp(
            title: 'Delivery Comunitario',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // 🔀 RUTAS NOMBRADAS
            routes: {
              '/': (context) => const UserTypeRouter(), // Usar el router de tipos de usuario
              '/register': (context) => const RegisterScreen(),
              '/search': (context) => const SearchScreen(),
              '/test': (context) => const TestScreen(),
              '/firebase-test': (context) => const FirebaseTestScreen(),
              '/business/onboarding': (context) => const BusinessOnboardingScreen(),
              '/business/dashboard': (context) => const BusinessDashboardScreen(),
              '/favorites': (context) => const FavoritesScreen(),
              '/business-detail': (context) {
                final args = ModalRoute.of(context)!.settings.arguments;
                final storeProvider = Provider.of<CommunityStoreProvider>(context, listen: false);

                Business? business;
                String? productId;

                if (args is Business) {
                  business = args;
                } else if (args is Map<String, dynamic>) {
                  if (args['business'] is Business) {
                    business = args['business'] as Business;
                  } else if (args['businessId'] is String) {
                    business = storeProvider.getBusinessById(args['businessId'] as String);
                  }
                  if (args['productId'] is String) {
                    productId = args['productId'] as String;
                  }
                }

                if (business != null) {
                  return BusinessDetailScreen(business: business, initialProductId: productId);
                }

                throw ArgumentError('Se requiere un negocio válido para /business-detail');
              },
              '/product-detail': (context) {
                final args = ModalRoute.of(context)!.settings.arguments;
                final storeProvider = Provider.of<CommunityStoreProvider>(context, listen: false);

                Business? business;
                String? productId;

                if (args is Map<String, dynamic>) {
                  if (args['business'] is Business) {
                    business = args['business'] as Business;
                  } else if (args['businessId'] is String) {
                    business = storeProvider.getBusinessById(args['businessId'] as String);
                  }
                  if (args['productId'] is String) {
                    productId = args['productId'] as String;
                  } else if (args['product'] is Product) {
                    productId = (args['product'] as Product).id;
                  }
                }

                if (business != null) {
                  storeProvider.loadProductsByBusiness(business.id);
                  return BusinessDetailScreen(
                    business: business,
                    initialProductId: productId,
                  );
                }

                throw ArgumentError('Argumentos inválidos para /product-detail');
              },
              '/admin/add-coordinates': (context) => const AddCoordinatesScreen(),
              '/reviews/business': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
                return BusinessReviewsScreen(
                  businessId: args['businessId']!,
                  businessName: args['businessName']!,
                );
              },
              '/reviews/create': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                return CreateReviewScreen(
                  businessId: args['businessId'] as String,
                  businessName: args['businessName'] as String,
                  orderId: args['orderId'] as String?,
                );
              },
              '/chat/list': (context) => const ChatListScreen(),
              '/chat': (context) {
                final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                return ChatScreen(
                  conversationId: args['conversationId'] as String? ?? '',
                  recipientId: args['recipientId'] as String? ?? '',
                  recipientName: args['recipientName'] as String? ?? 'Negocio',
                );
              },
            },
            initialRoute: '/',
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
