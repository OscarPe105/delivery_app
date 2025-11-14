/// 👤 PANTALLA DE PERFIL DEL CLIENTE
/// 
/// Esta pantalla muestra y gestiona la información del perfil del usuario.
/// Funcionalidades principales:
/// - Header con información del usuario y avatar
/// - Menú de opciones de cuenta (billetera, historial, favoritos)
/// - Gestión de direcciones de entrega
/// - Configuración de la aplicación
/// - Opción de cerrar sesión con confirmación
/// 
/// @author Sistema de Delivery Comunitario
/// @version 1.0.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_storage_service.dart';
import '../orders_screen.dart';
import '../favorites_screen.dart';
import '../address_management_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  bool _isUpdatingPhoto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      if (authProvider.user != null) {
        customerProvider.loadMyOrders(authProvider.user!.id);
      }
    });
  }

  Future<void> _refreshProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerProvider = Provider.of<CustomerProvider>(context, listen: false);

    if (authProvider.user == null) {
      return;
    }

    await Future.wait([
      customerProvider.loadMyOrders(authProvider.user!.id),
      authProvider.refreshCurrentUserData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          child: ListView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const SizedBox(height: 16),
              _buildProfileHeader(authProvider, customerProvider),
              const SizedBox(height: 20),
              _buildStatsOverview(customerProvider),
              const SizedBox(height: 20),
              _buildMenuOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider, CustomerProvider customerProvider) {
    final user = authProvider.user;
    final loyalty = customerProvider.loyaltyLevel;
    final loyaltyColor = _loyaltyColor(loyalty);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      decoration: BoxDecoration(
        gradient: ThemeProvider.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: ThemeProvider.primaryColor.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mi perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _openEditProfile(authProvider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar perfil'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: user?.profileImage != null && user!.profileImage!.isNotEmpty
                    ? NetworkImage(user.profileImage!)
                    : null,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: (user?.profileImage == null || user!.profileImage!.isEmpty)
                    ? const Icon(Icons.person, size: 56, color: Colors.white)
                    : null,
              ),
              if (_isUpdatingPhoto)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(52),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.6),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUpdatingPhoto ? null : () => _changeProfilePhoto(authProvider),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: ThemeProvider.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            user != null && user.name.isNotEmpty ? user.name : 'Cliente',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (user?.email != null && user!.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
          if (user?.phone != null && user!.phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              user.phone,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Chip(
            backgroundColor: loyaltyColor.withValues(alpha: 0.2),
            label: Text(
              loyalty,
              style: TextStyle(
                color: loyaltyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          const SizedBox(height: 8),
          Text(
            _loyaltyDescription(loyalty),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          if (customerProvider.lastOrderDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Último pedido: ${_formatDate(customerProvider.lastOrderDate!)}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsOverview(CustomerProvider provider) {
    final delivered = provider.deliveredOrders;
    final cancelled = provider.cancelledOrders;
    final totalSpent = provider.totalDeliveredSpent;
    final cancellationRate = (provider.cancellationRate * 100).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pedidos completados',
                  value: delivered.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Cancelaciones',
                  value: cancelled.toString(),
                  icon: Icons.cancel_outlined,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Gastado en entregados',
                  value: '\$${totalSpent.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: ThemeProvider.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Tasa de cancelación',
                  value: '${cancellationRate.toStringAsFixed(0)}%',
                  icon: Icons.percent,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          if (provider.ordersError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.ordersError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          _buildMenuTile(
            icon: Icons.history,
            title: 'Historial de Compras',
            subtitle: 'Consulta tus órdenes anteriores',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.favorite,
            title: 'Mis Favoritos',
            subtitle: 'Negocios y productos que guardaste',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.location_on,
            title: 'Direcciones de entrega',
            subtitle: 'Añade o edita tus ubicaciones',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressManagementScreen()),
              );
            },
          ),
          _buildMenuTile(
            icon: Icons.store,
            title: 'Registrar mi negocio',
            subtitle: 'Únete como vendedor en la plataforma',
            onTap: () => Navigator.pushNamed(context, '/business/onboarding'),
          ),
          _buildMenuTile(
            icon: Icons.exit_to_app,
            title: 'Cerrar sesión',
            subtitle: 'Salir de tu cuenta actual',
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.12)
                : ThemeProvider.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
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
            fontSize: 13,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  Future<void> _changeProfilePhoto(AuthProvider authProvider) async {
    final user = authProvider.user;
    if (user == null) return;

    final storageService = FirebaseStorageService();
    final image = await storageService.showImageSourceDialog(context);
    if (image == null) return;

    setState(() {
      _isUpdatingPhoto = true;
    });

    final uploadUrl = await storageService.uploadUserProfileImage(user.id, image);

    if (!mounted) return;

    if (uploadUrl == null) {
      setState(() {
        _isUpdatingPhoto = false;
      });
      _showSnackBar('No pudimos subir tu foto. Intenta nuevamente.', color: Colors.redAccent);
      return;
    }

    final success = await authProvider.updateUserProfile(photoUrl: uploadUrl);

    if (!mounted) return;

    setState(() {
      _isUpdatingPhoto = false;
    });

    _showSnackBar(
      success ? 'Tu foto de perfil se actualizó correctamente.' : 'No se pudo actualizar tu perfil.',
      color: success ? Colors.green : Colors.redAccent,
    );
  }

  void _openEditProfile(AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actualizar perfil',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Número de teléfono',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              FocusScope.of(context).unfocus();
                              setModalState(() => isSaving = true);
                              final success = await authProvider.updateUserProfile(
                                displayName: nameController.text,
                                phone: phoneController.text,
                              );
                              if (!mounted) return;
                              if (!context.mounted) return;
                              setModalState(() => isSaving = false);
                              if (success) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                if (!mounted) return;
                                _showSnackBar('Tu perfil se actualizó correctamente.');
                              } else {
                                if (!mounted) return;
                                _showSnackBar(
                                  'No se pudo actualizar tu perfil. Intenta más tarde.',
                                  color: Colors.redAccent,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeProvider.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Color _loyaltyColor(String loyalty) {
    switch (loyalty.toLowerCase()) {
      case 'cliente vip':
        return Colors.purple;
      case 'excelente cliente':
        return Colors.green;
      case 'en observación':
        return Colors.orange;
      default:
        return ThemeProvider.primaryColor;
    }
  }

  String _loyaltyDescription(String loyalty) {
    switch (loyalty.toLowerCase()) {
      case 'cliente vip':
        return 'Eres de los mejores clientes de la comunidad. ¡Gracias por tu fidelidad!';
      case 'excelente cliente':
        return 'Mantienes un excelente historial de pedidos. Sigue así y pronto serás VIP.';
      case 'en observación':
        return 'Hemos detectado varias cancelaciones. Intenta completar más pedidos.';
      default:
        return 'Sigue ordenando para desbloquear beneficios y mejorar tu nivel.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

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
                Navigator.pushReplacementNamed(context, '/');
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
