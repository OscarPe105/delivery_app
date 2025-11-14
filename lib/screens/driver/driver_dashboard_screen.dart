import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../models/delivery.dart';
import '../../models/driver_profile.dart';
import '../../themes/app_colors.dart';
import 'driver_delivery_detail_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final deliveryProvider = context.read<DeliveryProvider>();
      if (authProvider.user != null) {
        deliveryProvider.loadDriverProfile(authProvider.user!.id);
        deliveryProvider.loadDriverDeliveries(authProvider.user!.id);
        deliveryProvider.loadAvailableDeliveries();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Panel de Repartidor'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final deliveryProvider = context.read<DeliveryProvider>();
              deliveryProvider.clear();
              authProvider.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.driverDeliveries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.user != null) {
                await provider.loadDriverDeliveries(authProvider.user!.id);
                await provider.loadAvailableDeliveries();
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileCard(provider),
                const SizedBox(height: 16),
                _buildSectionTitle('Entregas asignadas'),
                if (provider.driverDeliveries.isEmpty)
                  _buildEmptyState(
                    icon: Icons.delivery_dining,
                    message: 'Aún no tienes entregas asignadas',
                  )
                else
                  ...provider.driverDeliveries
                      .map(
                        (delivery) => _DeliveryCard(
                          delivery: delivery,
                          onTap: () => _openDeliveryDetail(delivery, fromAvailable: false),
                        ),
                      ),
                const SizedBox(height: 24),
                _buildSectionTitle('Entregas disponibles'),
                if (provider.availableDeliveries.isEmpty)
                  _buildEmptyState(
                    icon: Icons.pending_actions,
                    message: 'No hay entregas disponibles por el momento',
                  )
                else
                  ...provider.availableDeliveries
                      .map(
                        (delivery) => _DeliveryCard(
                          delivery: delivery,
                          isAvailable: true,
                          onTap: () => _openDeliveryDetail(delivery, fromAvailable: true),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(DeliveryProvider provider) {
    final profile = provider.driverProfile;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(
              Icons.motorcycle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.name.isNotEmpty == true ? profile!.name : 'Repartidor Ready2Go',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entregas completadas: ${profile?.completedDeliveries ?? 0}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: profile?.availability.isActive == true
                          ? const Color(0xFF10B981)
                          : Colors.orange,
                      size: 10,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile?.availability.isActive == true ? 'Disponible' : 'Sin conexión',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (profile != null)
                      Switch.adaptive(
                        value: profile.availability.isActive,
                        activeTrackColor: AppColors.primary,
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => AppColors.primary,
                        ),
                        onChanged: (value) async {
                          final authProvider = context.read<AuthProvider>();
                          final deliveryProvider = context.read<DeliveryProvider>();
                          final driver = authProvider.user;
                          if (driver == null) return;

                          final newStatus = value
                              ? DriverAvailabilityStatus.available
                              : DriverAvailabilityStatus.offline;
                          await deliveryProvider.updateDriverAvailability(
                            driver.id,
                            newStatus,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _openDeliveryDetail(Delivery delivery, {required bool fromAvailable}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DriverDeliveryDetailScreen(
          delivery: delivery,
          fromAvailableList: fromAvailable,
        ),
      ),
    );

    if (!mounted) return;
    if (result == true || result == null) {
      final authProvider = context.read<AuthProvider>();
      final driver = authProvider.user;
      if (driver != null) {
        final deliveryProvider = context.read<DeliveryProvider>();
        await deliveryProvider.loadDriverDeliveries(driver.id);
        await deliveryProvider.loadAvailableDeliveries();
      }
    }
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.delivery,
    this.isAvailable = false,
    this.onTap,
  });

  final Delivery delivery;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido ${delivery.orderId.substring(0, delivery.orderId.length > 6 ? 6 : delivery.orderId.length)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                _buildStatusChip(delivery.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.store_mall_directory, 'Retiro', delivery.pickupAddress),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.navigation, 'Entrega', delivery.dropoffAddress),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${delivery.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (isAvailable)
                  ElevatedButton(
                    onPressed: () => _assignDelivery(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tomar pedido'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(DeliveryStatus status) {
    Color color;
    String label;

    switch (status) {
      case DeliveryStatus.pendingAssignment:
        color = Colors.orange;
        label = 'Pendiente';
        break;
      case DeliveryStatus.assigned:
        color = Colors.blueGrey;
        label = 'Asignado';
        break;
      case DeliveryStatus.pickedUp:
        color = Colors.blueAccent;
        label = 'Retirado';
        break;
      case DeliveryStatus.enRoute:
        color = Colors.deepPurple;
        label = 'En ruta';
        break;
      case DeliveryStatus.delivered:
        color = const Color(0xFF10B981);
        label = 'Entregado';
        break;
      case DeliveryStatus.cancelled:
        color = Colors.redAccent;
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _assignDelivery(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();

    final driver = authProvider.user;
    if (driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión nuevamente para tomar entregas.')),
      );
      return;
    }

    final driverProfile = deliveryProvider.driverProfile;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    bool success = false;
    try {
      success = await deliveryProvider.assignDeliveryToDriver(
        deliveryId: delivery.id,
        driverUid: driver.id,
        driverName: driverProfile?.name.isNotEmpty == true ? driverProfile!.name : null,
        driverPhone: driverProfile?.phone.isNotEmpty == true ? driverProfile!.phone : null,
      );
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Entrega asignada correctamente.'
                : 'No se pudo asignar la entrega. Intenta de nuevo.',
          ),
        ),
      );
    }
  }
}

