import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../services/notification_service.dart';
import '../themes/app_colors.dart';

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final provider = Provider.of<CommunityStoreProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartItems = provider.cartItems;

      if (cartItems.isEmpty) {
        _showError('Tu carrito está vacío');
        return;
      }

      // Crear el pedido
      final order = Order(
        id: '',
        customerId: authProvider.user?.id ?? '',
        customerName: authProvider.user?.name ?? authProvider.user?.email ?? 'Cliente',
        products: cartItems.map((item) {
          return OrderItem(
            productId: item.productId,
            name: item.productName,
            price: item.price,
            quantity: item.quantity,
          );
        }).toList(),
        total: provider.cartTotal,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        deliveryAddress: _deliveryAddressController.text.trim(),
      );

      // Crear pedido en la API
      final apiService = ApiService();
      final createdOrder = await apiService.createOrder(order);

      if (createdOrder != null) {
        // Limpiar carrito
        provider.clearCart();

        // Mostrar notificación de éxito
        if (mounted) {
          Navigator.of(context).pop(); // Cerrar checkout
          Navigator.of(context).pop(); // Cerrar carrito
          
          // Usar el servicio de notificaciones
          NotificationService.showOrderCreatedNotification(
            context, 
            createdOrder.id,
          );
        }
      } else {
        _showError('Error al crear el pedido');
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

                    // Dirección de entrega
                    _buildSection(
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
                          return RadioListTile<String>(
                            title: Text(method),
                            value: method,
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value;
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
                color: Colors.black.withOpacity(0.05),
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
