import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/delivery.dart';
import '../../models/order.dart';
import '../../models/driver_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/delivery_provider.dart';
import '../../themes/app_colors.dart';
import '../orders/order_receipt_screen.dart';
import '../../services/chat_service.dart';

class DriverDeliveryDetailScreen extends StatefulWidget {
  const DriverDeliveryDetailScreen({
    super.key,
    required this.delivery,
    this.fromAvailableList = false,
  });

  final Delivery delivery;
  final bool fromAvailableList;

  @override
  State<DriverDeliveryDetailScreen> createState() => _DriverDeliveryDetailScreenState();
}

class _DriverDeliveryDetailScreenState extends State<DriverDeliveryDetailScreen> {
  late Delivery _delivery;
  late Future<Order?> _orderFuture;
  String? _customerId;
  String? _customerName;
  String? _businessOwnerId;
  String? _businessOwnerName;
  String? _businessId;
  String? _businessName;

  @override
  void initState() {
    super.initState();
    _delivery = widget.delivery;
    _orderFuture = _fetchOrder();
  }

  Future<Order?> _fetchOrder() async {
    try {
      final doc =
          await firestore.FirebaseFirestore.instance.collection('orders').doc(_delivery.orderId).get();
      if (!doc.exists) return null;
      final data = doc.data() ?? {};

      _customerId = data['customerId']?.toString();
      _customerName = data['customerName']?.toString();
      _businessId = data['businessFirestoreId']?.toString().isNotEmpty == true
          ? data['businessFirestoreId']?.toString()
          : data['businessId']?.toString();
      _businessName = data['businessName']?.toString();

      try {
        if (_businessId != null && _businessId!.isNotEmpty) {
          final businessDoc = await firestore.FirebaseFirestore.instance
              .collection('businesses')
              .doc(_businessId!)
              .get();
          if (businessDoc.exists) {
            final businessData = businessDoc.data() ?? {};
            _businessName ??= businessData['name']?.toString();
            _businessOwnerId = businessData['ownerUid']?.toString() ?? businessData['ownerId']?.toString();

            if (_businessOwnerId != null && _businessOwnerId!.isNotEmpty) {
              final ownerDoc = await firestore.FirebaseFirestore.instance
                  .collection('users')
                  .doc(_businessOwnerId!)
                  .get();
              if (ownerDoc.exists) {
                _businessOwnerName = ownerDoc.data()?['name']?.toString();
              }
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error obteniendo datos del negocio para el chat: $e');
      }

      if (mounted) {
        setState(() {});
      }

      final productsRaw = (data['products'] as List?) ?? [];
      final products = productsRaw.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return OrderItem(
          productId: map['productId']?.toString() ?? map['product']?.toString() ?? '',
          name: map['name']?.toString() ?? map['productName']?.toString() ?? '',
          price: _safeToDouble(map['price']),
          quantity: map['quantity'] is int
              ? map['quantity'] as int
              : int.tryParse(map['quantity']?.toString() ?? '') ?? 1,
          imageUrl: map['imageUrl']?.toString() ?? map['image_url']?.toString(),
        );
      }).toList();

      final createdAtRaw = data['createdAt'];
      DateTime createdAt;
      if (createdAtRaw is firestore.Timestamp) {
        createdAt = createdAtRaw.toDate();
      } else if (createdAtRaw is DateTime) {
        createdAt = createdAtRaw;
      } else if (createdAtRaw is String) {
        createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
      } else {
        createdAt = DateTime.now();
      }

      return Order(
        id: doc.id,
        customerId: data['customerId']?.toString() ?? '',
        customerName: data['customerName']?.toString() ?? '',
        products: products,
        total: _safeToDouble(data['total']),
        status: OrderStatus.pending,
        createdAt: createdAt,
        deliveryAddress: data['deliveryAddress']?.toString() ?? '',
        displayNumber: data['displayNumber'] is int
            ? data['displayNumber'] as int
            : int.tryParse(data['displayNumber']?.toString() ?? ''),
        paymentMethod:
            data['paymentMethod']?.toString() ?? data['payment_method']?.toString(),
      );
    } catch (e) {
      debugPrint('❌ Error cargando pedido ${_delivery.orderId}: $e');
      return null;
    }
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: r'$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de entrega'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Order?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _orderFuture = _fetchOrder();
              });
              await _orderFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(formatter),
                const SizedBox(height: 16),
                if (order != null) ...[
                  _buildSectionTitle('Cliente'),
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: order.customerName.isEmpty ? 'Cliente sin nombre' : order.customerName,
                    subtitle: 'Pedido #${order.displayNumber ?? order.id.substring(0, 6)}',
                  ),
                  if (order.deliveryAddress.isNotEmpty)
                    _buildInfoTile(
                      icon: Icons.place_outlined,
                      title: 'Dirección de entrega',
                      subtitle: order.deliveryAddress,
                    ),
                  if ((order.paymentMethod ?? '').isNotEmpty)
                    _buildInfoTile(
                      icon: Icons.payment_outlined,
                      title: 'Método de pago',
                      subtitle: order.paymentMethod!,
                    ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Productos'),
                  ...order.products.map((item) => _buildProductTile(item, formatter)),
                  const SizedBox(height: 16),
                  _buildTotalTile(formatter.format(order.total)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderReceiptScreen(order: order),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('Ver comprobante'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCommunicationSection(),
                ] else
                  _buildEmptyState(
                    icon: Icons.receipt_long,
                    message: 'No pudimos cargar la información del pedido.',
                  ),
                const SizedBox(height: 24),
                _buildSectionTitle('Acciones'),
                _buildActionsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(NumberFormat formatter) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido ${_delivery.orderId.substring(0, _delivery.orderId.length > 6 ? 6 : _delivery.orderId.length)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Creado: ${dateFormat.format(_delivery.createdAt)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(_delivery.status),
              const Spacer(),
              Text(
                formatter.format(_delivery.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.store_mall_directory, 'Retiro', _delivery.pickupAddress),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.navigation, 'Entrega', _delivery.dropoffAddress),
        ],
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

  Widget _buildInfoTile({required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(OrderItem item, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cantidad: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatter.format(item.price * item.quantity),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalTile(String total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total del pedido',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            total,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
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
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
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

  Widget _buildActionsSection() {
    final authProvider = context.read<AuthProvider>();
    final driverId = authProvider.user?.id;
    final isAssignedToMe = driverId != null && _delivery.driverId == driverId;

    if (_delivery.status == DeliveryStatus.delivered) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        message: 'Entrega completada. ¡Gracias por tu trabajo!',
      );
    }

    if (widget.fromAvailableList && !isAssignedToMe) {
      return ElevatedButton.icon(
        onPressed: _handleTakeDelivery,
        icon: const Icon(Icons.task_alt_outlined),
        label: const Text('Tomar este pedido'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
    }

    if (!isAssignedToMe) {
      return _buildEmptyState(
        icon: Icons.lock_outline,
        message: 'Este pedido está asignado a otro repartidor.',
      );
    }

    final List<Widget> buttons = [];

    if (_delivery.status == DeliveryStatus.assigned) {
      buttons.add(
        _buildActionButton(
          label: 'Marcar como retirado',
          icon: Icons.shopping_bag_outlined,
          color: AppColors.primary,
          onPressed: () => _updateStatus(DeliveryStatus.pickedUp),
        ),
      );
    } else if (_delivery.status == DeliveryStatus.pickedUp) {
      buttons.add(
        _buildActionButton(
          label: 'Marcar en ruta',
          icon: Icons.route_outlined,
          color: Colors.deepPurple,
          onPressed: () => _updateStatus(DeliveryStatus.enRoute),
        ),
      );
    } else if (_delivery.status == DeliveryStatus.enRoute) {
      buttons.add(
        _buildActionButton(
          label: 'Entrega completada',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF10B981),
          onPressed: () => _updateStatus(DeliveryStatus.delivered),
        ),
      );
    }

    if (buttons.isEmpty) {
      return _buildEmptyState(
        icon: Icons.info_outline,
        message: 'No hay acciones disponibles en este momento.',
      );
    }

    return Column(
      children: buttons
          .map((button) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: button,
              ))
          .toList(),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _handleTakeDelivery() async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();
    final driver = authProvider.user;
    if (driver == null) return;

    final profile = deliveryProvider.driverProfile;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await deliveryProvider.assignDeliveryToDriver(
      deliveryId: _delivery.id,
      driverUid: driver.id,
      driverName: profile?.name.isNotEmpty == true ? profile!.name : null,
      driverPhone: profile?.phone.isNotEmpty == true ? profile!.phone : null,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Pedido asignado correctamente.' : 'No se pudo tomar el pedido.',
        ),
      ),
    );

    if (success) {
      setState(() {
        _delivery = _delivery.copyWith(
          status: DeliveryStatus.assigned,
          driverId: driver.id,
          driverName: profile?.name,
          driverPhone: profile?.phone,
        );
      });
      await _refreshLists();
      if (!mounted) return;
    }
  }

  Future<void> _updateStatus(DeliveryStatus status) async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();
    final driver = authProvider.user;
    if (driver == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await deliveryProvider.updateDeliveryStatus(
      deliveryId: _delivery.id,
      status: status,
      driverUid: driver.id,
      orderId: _delivery.orderId,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Estado actualizado.' : 'No se pudo actualizar el estado.',
        ),
      ),
    );

    if (success) {
      setState(() {
        _delivery = _delivery.copyWith(status: status);
      });
      await _refreshLists();
      if (status == DeliveryStatus.delivered) {
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _refreshLists() async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();
    final driver = authProvider.user;
    if (driver == null) return;

    await deliveryProvider.loadDriverDeliveries(driver.id);
    await deliveryProvider.loadAvailableDeliveries();
  }

  Widget _buildCommunicationSection() {
    final List<Widget> buttons = [];

    if (_customerId != null && _customerId!.isNotEmpty) {
      buttons.add(
        _buildChatButton(
          label: 'Chatear con cliente',
          icon: Icons.person_outline,
          onPressed: _openChatWithCustomer,
        ),
      );
    }

    if (_businessOwnerId != null && _businessOwnerId!.isNotEmpty) {
      buttons.add(
        _buildChatButton(
          label: 'Chatear con negocio',
          icon: Icons.store_mall_directory_outlined,
          onPressed: _openChatWithBusiness,
        ),
      );
    }

    if (buttons.isEmpty) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        message: 'No hay información de contacto disponible para este pedido.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons
          .map(
            (button) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: button,
            ),
          )
          .toList(),
    );
  }

  Widget _buildChatButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openChatWithCustomer() async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();
    final driver = authProvider.user;
    if (driver == null || _customerId == null || _customerId!.isEmpty) {
      return;
    }

    final driverDisplayName = _withRole(
      _resolveDriverName(deliveryProvider.driverProfile, driver.name),
      'Repartidor',
    );
    final customerDisplayName = _withRole(_customerName, 'Cliente');

    try {
      final conversationId = await ChatService().getOrCreateConversation(
        userId1: driver.id,
        userId2: _customerId!,
        user1Name: driverDisplayName,
        user2Name: customerDisplayName,
        user1Role: 'Repartidor',
        user2Role: 'Cliente',
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'recipientId': _customerId!,
          'recipientName': customerDisplayName,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar el chat con el cliente: $e'),
        ),
      );
    }
  }

  Future<void> _openChatWithBusiness() async {
    final authProvider = context.read<AuthProvider>();
    final deliveryProvider = context.read<DeliveryProvider>();
    final driver = authProvider.user;
    if (driver == null || _businessOwnerId == null || _businessOwnerId!.isEmpty) {
      return;
    }

    final driverDisplayName = _withRole(
      _resolveDriverName(deliveryProvider.driverProfile, driver.name),
      'Repartidor',
    );
    final businessOwnerDisplayName = _withRole(
      _businessOwnerName ?? _businessName ?? 'Negocio',
      'Dueño del negocio',
    );

    try {
      final conversationId = await ChatService().getOrCreateConversation(
        userId1: driver.id,
        userId2: _businessOwnerId!,
        user1Name: driverDisplayName,
        user2Name: businessOwnerDisplayName,
        user1Role: 'Repartidor',
        user2Role: 'Dueño del negocio',
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'recipientId': _businessOwnerId!,
          'recipientName': businessOwnerDisplayName,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar el chat con el negocio: $e'),
        ),
      );
    }
  }

  String _withRole(String? name, String role) {
    final trimmed = name?.trim() ?? '';
    final base = trimmed.isNotEmpty ? trimmed : role;
    return '$base ($role)';
  }

  String _resolveDriverName(DriverProfile? profile, String? fallbackName) {
    final profileName = profile?.name;
    if (profileName != null && profileName.trim().isNotEmpty) {
      return profileName.trim();
    }
    if (fallbackName != null && fallbackName.trim().isNotEmpty) {
      return fallbackName.trim();
    }
    return 'Repartidor';
  }
}

