/**
 * 📋 PANTALLA DE MIS PEDIDOS
 * 
 * Esta pantalla muestra el historial completo de pedidos del usuario.
 * Funcionalidades principales:
 * - Lista de todos los pedidos realizados
 * - Información detallada de cada pedido (productos, total, fecha)
 * - Estados de pedidos con indicadores visuales
 * - Opción de reordenar pedidos entregados
 * - Mensaje cuando no hay pedidos con botón para ir a la tienda
 * 
 * @author Sistema de Delivery Comunitario
 * @version 1.0.0
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';  // 👤 Gestión de datos del cliente
import '../providers/theme_provider.dart';     // 🎨 Gestión de temas
import '../models/order.dart';                // 📦 Modelo de datos de pedido

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // 🔄 Cargar pedidos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerProvider>(context, listen: false).loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeProvider.backgroundColor, // 🎨 Color de fondo
      // 📱 BARRA SUPERIOR
      appBar: AppBar(
        title: Text(
          'Mis Pedidos',
          style: TextStyle(
            color: ThemeProvider.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ThemeProvider.cardColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: ThemeProvider.primaryColor,
        ),
      ),
      // 📱 CUERPO PRINCIPAL
      body: Consumer<CustomerProvider>(
        builder: (context, customerProvider, child) {
          final orders = customerProvider.myOrders; // 📋 Lista de pedidos
          
          // 🚫 SI NO HAY PEDIDOS - Mostrar mensaje y botón para ir a la tienda
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🛍️ ÍCONO DE BOLSA DE COMPRAS
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ThemeProvider.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: ThemeProvider.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 📝 MENSAJE PRINCIPAL
                  Text(
                    'No tienes pedidos realizados',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: ThemeProvider.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 📝 MENSAJE SECUNDARIO
                  Text(
                    'Explora nuestra tienda y realiza tu primer pedido',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeProvider.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // 🛒 BOTÓN PARA IR A LA TIENDA
                  ElevatedButton.icon(
                    onPressed: () {
                      // 🔙 Volver atrás para que el usuario pueda navegar a la tienda
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.store_rounded),
                    label: const Text('Explorar Tienda'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          
          // 📋 LISTA DE PEDIDOS - Si hay pedidos, mostrarlos en una lista
          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index]; // 📦 Pedido actual
              // 🃏 TARJETA DE PEDIDO
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📝 ENCABEZADO: ID DEL PEDIDO Y ESTADO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pedido #${order.id}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ThemeProvider.primaryTextColor,
                            ),
                          ),
                          _buildStatusChip(order.status), // 🏷️ Chip de estado
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 📅 INFORMACIÓN DE FECHA Y DIRECCIÓN
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ThemeProvider.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ⏰ FECHA DEL PEDIDO
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: ThemeProvider.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Fecha: ${order.createdAt.toString().substring(0, 16)}',
                                  style: TextStyle(
                                    color: ThemeProvider.secondaryTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // 📍 DIRECCIÓN DE ENTREGA
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: ThemeProvider.secondaryTextColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Dirección: ${order.deliveryAddress}',
                                    style: TextStyle(
                                      color: ThemeProvider.secondaryTextColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      // 📦 LISTA DE PRODUCTOS
                      Text(
                        'Productos:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ThemeProvider.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 🔄 MAPEO DE PRODUCTOS EN EL PEDIDO
                      ...order.products.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.name}',
                                style: TextStyle(
                                  color: ThemeProvider.primaryTextColor,
                                ),
                              ),
                            ),
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: ThemeProvider.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      // 💰 TOTAL DEL PEDIDO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ThemeProvider.primaryTextColor,
                            ),
                          ),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ThemeProvider.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      // 🔄 BOTÓN DE REORDENAR (solo para pedidos entregados)
                      if (order.status == OrderStatus.delivered) ...[  
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // 🚧 Funcionalidad en desarrollo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Función de reordenar próximamente'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Volver a Pedir'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Pendiente';
        icon = Icons.access_time_rounded;
        break;
      case OrderStatus.inProgress:
        color = ThemeProvider.primaryColor;
        text = 'En proceso';
        icon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Entregado';
        icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelado';
        icon = Icons.cancel_rounded;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}