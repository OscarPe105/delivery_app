/**
 * 👤 PANTALLA DE PERFIL DEL CLIENTE
 * 
 * Esta pantalla muestra y gestiona la información del perfil del usuario.
 * Funcionalidades principales:
 * - Header con información del usuario y avatar
 * - Menú de opciones de cuenta (billetera, historial, favoritos)
 * - Gestión de direcciones de entrega
 * - Configuración de la aplicación
 * - Opción de cerrar sesión con confirmación
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';      // 🔑 Datos del usuario autenticado
import '../../providers/customer_provider.dart'; // 👤 Gestión de datos del cliente
import '../../providers/theme_provider.dart';    // 🎨 Gestión de temas

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).loadMyOrders();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 SECCIÓN SUPERIOR CON DEGRADADO NARANJA
            _buildProfileHeader(authProvider, customerProvider),
            
            // 📋 ÁREA CENTRAL CON OPCIONES DE MENÚ
            Expanded(
              child: _buildMenuOptions(context),
            ),
          ],
        ),
      ),
    );
  }
  
  // 🎨 CONSTRUIR HEADER DEL PERFIL
  Widget _buildProfileHeader(AuthProvider authProvider, CustomerProvider customerProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeProvider.primaryColorDark,
            ThemeProvider.primaryColor,
            ThemeProvider.primaryColorLight,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 📱 BARRA DE ESTADO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3:14',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Icon(Icons.wifi, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Icon(Icons.battery_full, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      '58%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // 👤 AVATAR Y INFORMACIÓN DEL USUARIO
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              // ✅ Usar authProvider.user en lugar de authProvider.user
              // En la línea 113:
              authProvider.user?.name ?? 'Roberto Efraín Velasco', // ✅ Ya está correcto con el nuevo getter
              
              // En la línea 123:
            
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 📋 CONSTRUIR OPCIONES DE MENÚ
  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 📊 INDICADOR DE ARRASTRE
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            
            // 📋 OPCIONES DEL MENÚ
            Expanded(
              child: ListView(
                children: [
                  _buildMenuTile(
                    icon: Icons.wallet,
                    title: 'Mi Billetera',
                    subtitle: 'Gestiona tu saldo y métodos de pago',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.receipt_long,
                    title: 'Recargar Saldo',
                    subtitle: 'Añade fondos a tu cuenta',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.history,
                    title: 'Historial de Compras',
                    subtitle: 'Revisa tus pedidos anteriores',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.favorite,
                    title: 'Mis Favoritos',
                    subtitle: 'Productos y negocios que te gustan',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.location_on,
                    title: 'Direcciones de Entrega',
                    subtitle: 'Gestiona tus ubicaciones',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.settings,
                    title: 'Configuración',
                    subtitle: 'Ajustes de la aplicación',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.help,
                    title: 'Ayuda y Soporte',
                    subtitle: 'Obtén ayuda cuando la necesites',
                    onTap: () {},
                  ),
                  _buildMenuTile(
                    icon: Icons.exit_to_app,
                    title: 'Cerrar sesión',
                    subtitle: 'Salir de tu cuenta',
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 🔧 CONSTRUIR ELEMENTO DE MENÚ
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1)
                : ThemeProvider.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : ThemeProvider.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }
  
  // 🚪 MOSTRAR DIÁLOGO DE CERRAR SESIÓN
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}