import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../models/order.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Cargar pedidos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProvider>(context, listen: false).loadOrders();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Negocio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
  
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const OrdersTab();
      case 1:
        return const ProductsTab();
      case 2:
        return const StatsTab();
      default:
        return const OrdersTab();
    }
  }
}

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<BusinessProvider>(context).orders;
    
    if (orders.isEmpty) {
      return const Center(
        child: Text('No hay pedidos disponibles'),
      );
    }
    
    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pedido #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _buildStatusChip(order.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Cliente: ${order.customerName}'),
                Text('Dirección: ${order.deliveryAddress}'),
                const Divider(),
                ...order.products.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.name}'),
                      Text('\$${item.price.toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (order.status == OrderStatus.pending)
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<BusinessProvider>(context, listen: false)
                              .updateOrderStatus(order.id, OrderStatus.inProgress);
                        },
                        child: const Text('Aceptar'),
                      ),
                    if (order.status == OrderStatus.inProgress)
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<BusinessProvider>(context, listen: false)
                              .updateOrderStatus(order.id, OrderStatus.delivered);
                        },
                        child: const Text('Entregado'),
                      ),
                    if (order.status == OrderStatus.pending)
                      TextButton(
                        onPressed: () {
                          Provider.of<BusinessProvider>(context, listen: false)
                              .updateOrderStatus(order.id, OrderStatus.cancelled);
                        },
                        child: const Text('Rechazar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case OrderStatus.pending:
        color = Colors.orange;
        text = 'Pendiente';
        break;
      case OrderStatus.inProgress:
        color = Colors.blue;
        text = 'En proceso';
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        text = 'Entregado';
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        text = 'Cancelado';
        break;
    }
    
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }
}

class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Gestión de Productos'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para agregar un nuevo producto
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad en desarrollo')),
              );
            },
            child: const Text('Agregar Producto'),
          ),
        ],
      ),
    );
  }
}

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Estadísticas y Análisis (En desarrollo)'),
    );
  }
}