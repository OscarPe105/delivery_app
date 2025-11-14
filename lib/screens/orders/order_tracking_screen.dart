import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:provider/provider.dart';
import 'dart:async';

import '../../models/order.dart';
import '../../models/delivery.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../themes/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late Order _currentOrder;
  bool _isLoading = false;
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _startPolling();
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Poll cada 5 segundos para actualizar el estado
    _orderSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _fetchLatestOrder())
        .listen(
          (order) {
            if (mounted && order != null && order.id == _currentOrder.id) {
              setState(() {
                _currentOrder = order;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              debugPrint('Error polling order: $error');
            }
          },
        );
  }

  Future<Order?> _fetchLatestOrder() async {
    try {
      final doc = await firestore.FirebaseFirestore.instance
          .collection('orders')
          .doc(_currentOrder.id)
          .get();
      if (doc.exists) {
        return _orderFromFirestore(doc);
      }
    } catch (_) {}
    return null;
  }

  void _refreshOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await _fetchLatestOrder();
      if (mounted && order != null) {
        setState(() {
          _currentOrder = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar pedido')),
        );
      }
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Tu pedido está siendo procesado';
      case OrderStatus.inProgress:
        return 'El negocio está preparando tu pedido';
      case OrderStatus.delivered:
        return 'Tu pedido ha sido entregado. ¡Disfrútalo!';
      case OrderStatus.cancelled:
        return 'El pedido ha sido cancelado';
    }
  }

  int _getStepFromStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.inProgress:
        return 1;
      case OrderStatus.delivered:
        return 2;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Order _orderFromFirestore(
      firestore.DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final productsData = (data['products'] as List?) ?? [];
    final items = productsData.map((item) {
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
      products: items,
      total: _safeToDouble(data['total']),
      status: _statusFromString(data['status']?.toString()),
      createdAt: createdAt,
      deliveryAddress: data['deliveryAddress']?.toString() ?? '',
      displayNumber: data['displayNumber'] is int
          ? data['displayNumber'] as int
          : int.tryParse(data['displayNumber']?.toString() ?? ''),
      paymentMethod: data['paymentMethod']?.toString() ?? data['payment_method']?.toString(),
      driverId: data['driverId']?.toString() ?? data['driver_id']?.toString(),
      driverName: data['driverName']?.toString() ?? data['driver_name']?.toString(),
      deliveryStatus: data['deliveryStatus'] != null
          ? parseDeliveryStatus(data['deliveryStatus']?.toString())
          : null,
      assignedAt: _parseTimestamp(data['assignedAt']),
      deliveredAt: _parseTimestamp(data['deliveredAt']),
    );
  }

  OrderStatus _statusFromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'in_progress':
      case 'preparing':
      case 'confirmed':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  String _estimateDeliveryTime() {
    final now = DateTime.now();
    final diff = now.difference(_currentOrder.createdAt);
    
    if (_currentOrder.status == OrderStatus.delivered) {
      return 'Entregado';
    }
    
    if (_currentOrder.status == OrderStatus.cancelled) {
      return 'Cancelado';
    }
    
    // Estimación: 15-30 minutos desde la creación
    const baseMinutes = 20;
    final elapsedMinutes = diff.inMinutes;
    final remainingMinutes = (baseMinutes - elapsedMinutes).clamp(0, baseMinutes);
    
    if (remainingMinutes <= 0) {
      return 'Próximamente';
    }
    
    return 'Aprox. $remainingMinutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Pedido'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshOrder,
              tooltip: 'Actualizar',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información del pedido
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pedido #${_currentOrder.displayNumber ?? _currentOrder.id}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _estimateDeliveryTime(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_currentOrder.status == OrderStatus.cancelled) ...[
              // Estado cancelado
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red.shade700, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido Cancelado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatusDescription(_currentOrder.status),
                            style: TextStyle(
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Pasos de tracking
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Timeline
                    _buildTimelineStep(
                      step: 0,
                      currentStep: _getStepFromStatus(_currentOrder.status),
                      icon: Icons.pending_actions,
                      title: 'Confirmado',
                      description: 'Tu pedido ha sido recibido',
                    ),
                    _buildTimelineStep(
                      step: 1,
                      currentStep: _getStepFromStatus(_currentOrder.status),
                      icon: Icons.restaurant,
                      title: 'En Preparación',
                      description: 'El negocio está preparando tu pedido',
                    ),
                    _buildTimelineStep(
                      step: 2,
                      currentStep: _getStepFromStatus(_currentOrder.status),
                      icon: Icons.check_circle,
                      title: 'Entregado',
                      description: 'Tu pedido ha sido entregado',
                    ),
                  ],
                ),
              ),

              // Información adicional
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildDetailRow(
                      Icons.access_time,
                      'Hora del Pedido',
                      '${_currentOrder.createdAt.day}/${_currentOrder.createdAt.month}/${_currentOrder.createdAt.year} • ${_currentOrder.createdAt.hour}:${_currentOrder.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      'Dirección de Entrega',
                      _currentOrder.deliveryAddress,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Total',
                      '\$${_currentOrder.total.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),

              if ((_currentOrder.driverId ?? '').isNotEmpty)
                _buildDriverSection(),

              // Productos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._currentOrder.products.map((product) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 48,
                          height: 48,
                          child: _ProductImage(orderItem: product),
                        ),
                        title: Text(product.name),
                        subtitle: Text('${product.quantity}x'),
                        trailing: Text(
                          '\$${(product.price * product.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int step,
    required int currentStep,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isCompleted = step <= currentStep;
    final isCurrent = step == currentStep;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Línea vertical
        Column(
          children: [
            Container(
              width: 2,
              height: 40,
              color: isCompleted ? AppColors.primary : Colors.grey.shade300,
            ),
            // Círculo con ícono
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? (isCurrent ? AppColors.primary : Colors.green)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
                boxShadow: isCurrent ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ] : null,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            if (step < 2)
              Container(
                width: 2,
                height: 40,
                color: step < currentStep ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.black87 : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isCompleted ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverSection() {
    final driverName = (_currentOrder.driverName?.trim().isNotEmpty ?? false)
        ? _currentOrder.driverName!.trim()
        : 'Repartidor';
    final statusText = _describeDeliveryStatus(_currentOrder.deliveryStatus);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delivery_dining, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _withRole(driverName, 'Repartidor'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (statusText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _openChatWithDriver,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chatear con el repartidor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChatWithDriver() async {
    final driverId = _currentOrder.driverId;
    if (driverId == null || driverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay repartidor asignado a este pedido aún.')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para chatear con el repartidor.')),
      );
      return;
    }

    String rawCustomerName = currentUser.name;
    if (rawCustomerName.trim().isEmpty) {
      rawCustomerName = currentUser.email;
    }
    final formattedCustomerName = rawCustomerName.trim().isNotEmpty ? rawCustomerName.trim() : 'Cliente';
    final customerDisplayName = _withRole(formattedCustomerName, 'Cliente');
    final driverDisplayName = _withRole(_currentOrder.driverName, 'Repartidor');

    try {
      final conversationId = await ChatService().getOrCreateConversation(
        userId1: currentUser.id,
        userId2: driverId,
        user1Name: customerDisplayName,
        user2Name: driverDisplayName,
        user1Role: 'Cliente',
        user2Role: 'Repartidor',
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': conversationId,
          'recipientId': driverId,
          'recipientName': driverDisplayName,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el chat con el repartidor: $e')),
      );
    }
  }

  String? _describeDeliveryStatus(DeliveryStatus? status) {
    if (status == null) return null;
    switch (status) {
      case DeliveryStatus.pendingAssignment:
        return 'Esperando asignación de repartidor';
      case DeliveryStatus.assigned:
        return 'Repartidor asignado';
      case DeliveryStatus.pickedUp:
        return 'Pedido retirado por el repartidor';
      case DeliveryStatus.enRoute:
        return 'Pedido en camino';
      case DeliveryStatus.delivered:
        return 'Pedido entregado';
      case DeliveryStatus.cancelled:
        return 'Entrega cancelada';
    }
  }

  String _withRole(String? name, String role) {
    final trimmed = name?.trim() ?? '';
    final base = trimmed.isNotEmpty ? trimmed : role;
    return '$base ($role)';
  }
}

class _ProductImage extends StatelessWidget {
  final OrderItem orderItem;

  const _ProductImage({required this.orderItem});

  @override
  Widget build(BuildContext context) {
    if (orderItem.imageUrl != null && orderItem.imageUrl!.isNotEmpty) {
      return _buildImage(orderItem.imageUrl!);
    }

    return FutureBuilder<firestore.DocumentSnapshot<Map<String, dynamic>>>(
      future: firestore.FirebaseFirestore.instance
          .collection('products')
          .doc(orderItem.productId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _fallbackIcon();
        }

        final data = snapshot.data!.data();
        final imageUrl = data?['imageUrl']?.toString() ?? data?['image_url']?.toString();

        if (imageUrl == null || imageUrl.isEmpty) {
          return _fallbackIcon();
        }

        return _buildImage(imageUrl);
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
      ),
    );
  }

  Widget _fallbackIcon() {
    return CircleAvatar(
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.fastfood, color: AppColors.primary),
    );
  }
}

