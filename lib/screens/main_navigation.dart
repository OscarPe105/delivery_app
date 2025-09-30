// 🧭 NAVEGACIÓN PRINCIPAL DE LA APLICACIÓN
// Este archivo controla la barra de navegación inferior y el drawer lateral
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

// 📱 Importar todas las pantallas

// 📱 Importar todas las pantallas
import 'customer/customer_home_screen.dart';           // 🏠 Pantalla de inicio principal
import 'customer/customer_profile_screen.dart';       // 👤 Pantalla de perfil
import 'community_store_screen.dart';        // 🏪 Pantalla de tienda
import 'orders_screen.dart';                 // 📋 Pantalla de pedidos
import 'profile_screen.dart';                 // 👤 Pantalla de perfil mejorada
import 'favorites_screen.dart';               // ❤️ Pantalla de favoritos
import 'notifications_screen.dart';           // 🔔 Pantalla de notificaciones

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // 📍 Índice de la pestaña actual (0 = Inicio, 1 = Tienda, 2 = Pedidos, 3 = Perfil)
  int _currentIndex = 0;

  // 📱 Lista de pantallas correspondientes a cada pestaña
    final List<Widget> _screens = [
    const CustomerHomeScreen(),           // 🏠 Pestaña 0: Inicio principal
    const CommunityStoreScreen(), // 🏪 Pestaña 1: Tienda
    const OrdersScreen(),         // 📋 Pestaña 2: Mis Pedidos
    const CustomerProfileScreen(),        // 👤 Pestaña 3: Perfil
  ];

  // 🍔 MÉTODO PARA CONSTRUIR EL DRAWER (Menú lateral)
  Widget _buildDrawer(BuildContext context, ThemeProvider themeProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 🎨 ENCABEZADO DEL DRAWER
          DrawerHeader(
            decoration: BoxDecoration(
              color: ThemeProvider.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mi Barrio App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Delivery Comunitario',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 🏠 OPCIÓN INICIO
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              setState(() {
                _currentIndex = 0; // Cambiado de _selectedIndex a _currentIndex
              });
              Navigator.pop(context);
            },
          ),
          // 🛒 OPCIÓN TIENDA
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Tienda'),
            onTap: () {
              setState(() {
                _currentIndex = 1; // Cambiado de _selectedIndex a _currentIndex
              });
              Navigator.pop(context);
            },
          ),
          // 📋 OPCIÓN MIS PEDIDOS
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Mis Pedidos'),
            onTap: () {
              setState(() {
                _currentIndex = 2; // Cambiado de _selectedIndex a _currentIndex
              });
              Navigator.pop(context);
            },
          ),
          // 👤 OPCIÓN PERFIL
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              setState(() {
                _currentIndex = 3; // Cambiado de _selectedIndex a _currentIndex
              });
              Navigator.pop(context);
            },
          ),
          const Divider(),
          // ❤️ OPCIÓN FAVORITOS
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: const Text('Favoritos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          // 🔔 OPCIÓN NOTIFICACIONES
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Notificaciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const Divider(),
          // ⚙️ OPCIÓN CONFIGURACIÓN
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuración'),
            onTap: () {
              // Navegar a configuración
              Navigator.pop(context);
            },
          ),
          // 🚪 OPCIÓN CERRAR SESIÓN
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Cerrar Sesión'),
            onTap: () {
              // Lógica para cerrar sesión
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundColor, // 🏠 Color de fondo
      
      // 📱 CUERPO PRINCIPAL - Muestra la pantalla actual
      body: IndexedStack(
        index: _currentIndex,    // 📍 Pantalla actual
        children: _screens,      // 📱 Lista de pantallas
      ),
      
      // 📍 BARRA DE NAVEGACIÓN INFERIOR
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ThemeProvider.cardColor,    // 🏠 Fondo blanco
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // 🌫️ Sombra ligera
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),    // 🔘 Esquina superior izquierda redondeada
            topRight: Radius.circular(24),   // 🔘 Esquina superior derecha redondeada
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,     // 📍 Pestaña actual
            onTap: (index) {                // 👆 Al tocar una pestaña
              setState(() {
                _currentIndex = index;       // 🔄 Cambiar pestaña actual
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: ThemeProvider.cardColor,        // 🏠 Fondo
            selectedItemColor: ThemeProvider.primaryColor,   // 🧡 Color de pestaña seleccionada
            unselectedItemColor: ThemeProvider.secondaryTextColor, // 📝 Color de pestaña no seleccionada
            selectedFontSize: 12,           // 📏 Tamaño de fuente seleccionada
            unselectedFontSize: 10,         // 📏 Tamaño de fuente no seleccionada
            elevation: 0,                   // 🚫 Sin sombra
            
            // 📍 PESTAÑAS DE NAVEGACIÓN
            items: const [
              // 🏠 PESTAÑA INICIO
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),     // 🏠 Ícono no seleccionado
                activeIcon: Icon(Icons.home_rounded), // 🏠 Ícono seleccionado
                label: 'Inicio',                     // 📝 Etiqueta
              ),
              // 🏪 PESTAÑA TIENDA
              BottomNavigationBarItem(
                icon: Icon(Icons.store_outlined),     // 🏪 Ícono no seleccionado
                activeIcon: Icon(Icons.store_rounded), // 🏪 Ícono seleccionado
                label: 'Tienda',                      // 📝 Etiqueta
              ),
              // 📋 PESTAÑA MIS PEDIDOS
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),     // 📋 Ícono no seleccionado
                activeIcon: Icon(Icons.receipt_long_rounded), // 📋 Ícono seleccionado
                label: 'Mis Pedidos',                        // 📝 Etiqueta
              ),
              // 👤 PESTAÑA PERFIL
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),  // 👤 Ícono no seleccionado
                activeIcon: Icon(Icons.person_rounded),     // 👤 Ícono seleccionado
                label: 'Perfil',                           // 📝 Etiqueta
              ),
            ],
          ),
        ),
      ),
      
      // 🍔 DRAWER LATERAL (Menú hamburguesa) - Disponible en todas las pestañas
      drawer: _buildDrawer(context, themeProvider),
    );
  }
}
  
  List<BottomNavigationBarItem> _getNavigationItems(bool isBusinessUser) {
    if (isBusinessUser) {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Panel'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Productos'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ];
    } else {
      return [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Pedidos'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ];
    }
  }
