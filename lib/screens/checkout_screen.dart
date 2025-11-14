import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item.dart';
import '../models/order.dart' as models;
import '../models/delivery.dart';
import '../services/notification_service.dart';
import '../themes/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'orders/order_receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _deliveryAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  String? _selectedPaymentMethod = 'Efectivo';
  bool _isPickup = true;

  final List<String> _paymentMethods = [
    'Efectivo',
    'Tarjeta de Crédito',
    'Tarjeta de Débito',
  ];

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (!_isPickup && !_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<CommunityStoreProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartItems = provider.cartItems;

    if (cartItems.isEmpty) {
      _showError('Tu carrito está vacío');
      return;
    }

    // Validar que todos los productos pertenezcan al mismo negocio
    final businessIds = cartItems
        .map((item) => item.businessId)
        .where((id) => id.isNotEmpty)
        .toSet();
    if (businessIds.length > 1) {
      _showError('No puedes combinar productos de distintos negocios en un mismo pedido.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final businessId = cartItems.isNotEmpty ? cartItems.first.businessId : null;
      final businessFirestoreId = cartItems.isNotEmpty ? cartItems.first.businessFirestoreId : null;
      final paymentMethod = _selectedPaymentMethod ?? 'Efectivo';

      // Crear el pedido
      final deliveryAddress = _isPickup
          ? 'Retiro en el negocio'
          : _deliveryAddressController.text.trim();

      final order = models.Order(
        id: '',
        customerId: authProvider.user?.id ?? '',
        customerName: authProvider.user?.name ?? authProvider.user?.email ?? 'Cliente',
        products: cartItems.map((item) {
          return models.OrderItem(
            productId: item.productId,
            name: item.productName,
            price: item.price,
            quantity: item.quantity,
            imageUrl: item.imageUrl,
          );
        }).toList(),
        total: provider.cartTotal,
        status: models.OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
      );

      // Crear pedido en la API o Firestore
      models.Order? createdOrder;

      if (businessId != null) {
        try {
          final firestore = FirebaseFirestore.instance;

          // Validar que el negocio esté activo y aceptando pedidos
          final businessDocId = businessFirestoreId?.isNotEmpty == true
              ? businessFirestoreId!
              : businessId;
          final businessDoc =
              await firestore.collection('businesses').doc(businessDocId).get();
          String businessName = '';
          String pickupAddress = '';
          if (businessDoc.exists) {
            final data = businessDoc.data() as Map<String, dynamic>;
            final isActive = data['isActive'] ?? data['is_active'] ?? true;
            final isOpen = data['isOpen'] ?? data['is_open'] ?? true;
            if (!(isActive && isOpen)) {
              _showError('Este negocio no está aceptando pedidos en este momento.');
              return;
            }
            businessName = data['name']?.toString() ?? '';
            pickupAddress = data['address']?.toString() ?? '';
          }

          final orderDoc = firestore.collection('orders').doc();
          
          await orderDoc.set({
            'customerId': authProvider.user?.id ?? '',
            'customerName': authProvider.user?.name ?? authProvider.user?.email ?? 'Cliente',
            'businessId': businessId,
            'businessFirestoreId': businessFirestoreId,
            'products': order.products.map((item) => {
              'productId': item.productId,
              'name': item.name,
              'price': item.price,
              'quantity': item.quantity,
              'imageUrl': item.imageUrl,
            }).toList(),
            'total': order.total,
            'status': 'pending',
            'deliveryAddress': order.deliveryAddress,
            'paymentMethod': paymentMethod,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'driverId': null,
            'driverName': null,
            'deliveryStatus': DeliveryStatus.pendingAssignment.firestoreValue,
            'businessName': businessName,
            'pickupAddress': pickupAddress,
          });
          
          // Crear objeto Order desde Firestore
          createdOrder = models.Order(
            id: orderDoc.id,
            customerId: authProvider.user?.id ?? '',
            customerName: authProvider.user?.name ?? authProvider.user?.email ?? 'Cliente',
            products: order.products,
            total: order.total,
            status: models.OrderStatus.pending,
            createdAt: DateTime.now(),
            deliveryAddress: order.deliveryAddress,
            paymentMethod: paymentMethod,
            deliveryStatus: DeliveryStatus.pendingAssignment,
          );
          
          if (kDebugMode) {
            debugPrint('✅ Pedido creado en Firestore como fallback');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('❌ Error creando pedido en Firestore: $e');
          }
        }
      }
      
      if (createdOrder != null) {
        // Limpiar carrito
        provider.clearCart();

        // Mostrar notificación de éxito
        if (mounted) {
          // Usar el servicio de notificaciones
          NotificationService.showOrderCreatedNotification(
            context, 
            createdOrder.id,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderReceiptScreen(order: createdOrder!),
            ),
          );
        }
      } else {
        _showError('Error al crear el pedido. Por favor intenta de nuevo.');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    NotificationService.showErrorNotification(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityStoreProvider>(context);
    final cartItems = provider.cartItems;
    final cartTotal = provider.cartTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmar Pedido'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isProcessing
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen del pedido
                    _buildSection(
                      title: 'Resumen del Pedido',
                      child: Column(
                        children: [
                          ...cartItems.map((item) => _buildOrderItem(item)),
                          const Divider(),
                          _buildTotalRow(cartTotal),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Tipo de pedido
                    _buildSection(
                      title: 'Tipo de Pedido',
                      child: Column(
                        children: [
                          _buildSelectableOption(
                            title: 'Retirar en el negocio',
                            selected: _isPickup,
                            onTap: () {
                              setState(() {
                                _isPickup = true;
                                _deliveryAddressController.clear();
                              });
                            },
                          ),
                          _buildSelectableOption(
                            title: 'Entrega a domicilio',
                            selected: !_isPickup,
                            onTap: () {
                              setState(() {
                                _isPickup = false;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Dirección de entrega
                    _isPickup
                        ? _buildSection(
                            title: 'Retiro en el Negocio',
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Este pedido se recogerá directamente en el negocio.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Presenta tu comprobante o número de pedido al momento de retirarlo.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : _buildSection(
                            title: 'Dirección de Entrega',
                            child: TextFormField(
                              controller: _deliveryAddressController,
                              decoration: const InputDecoration(
                                hintText: 'Ingresa la dirección de entrega',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (_isPickup) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa una dirección de entrega';
                                }
                                return null;
                              },
                            ),
                          ),

                    const SizedBox(height: 24),

                    // Método de pago
                    _buildSection(
                      title: 'Método de Pago',
                      child: Column(
                        children: _paymentMethods.map((method) {
                          final isSelected = _selectedPaymentMethod == method;
                          return _buildSelectableOption(
                            title: method,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botón de confirmar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Pedido',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSelectableOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? AppColors.primary : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppColors.primary : Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Imagen
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported),
          ),
          const SizedBox(width: 12),
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity}x \$${item.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Total del item
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(0)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(double total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${total.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
