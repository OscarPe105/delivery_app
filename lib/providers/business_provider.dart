import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';

class BusinessProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<Order> _orders = [];
  
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  
  // Método para agregar un producto al catálogo
  void addProduct(Product product) {
    _products.add(product);
    notifyListeners();
  }
  
  // Método para actualizar un producto
  void updateProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }
  
  // Método para eliminar un producto
  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
  
  // Método para actualizar el estado de un pedido
  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      notifyListeners();
    }
  }
  
  // Método para cargar pedidos (simulado para MVP)
  void loadOrders() {
    // Simulación de carga de pedidos para el MVP
    _orders.clear();
    _orders.addAll([
      Order(
        id: 'order1',
        customerId: 'customer1',
        customerName: 'Juan Pérez',
        products: [
          OrderItem(productId: 'prod1', name: 'Hamburguesa', price: 5.99, quantity: 2),
          OrderItem(productId: 'prod2', name: 'Papas fritas', price: 2.50, quantity: 1),
        ],
        total: 14.48,
        status: OrderStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        deliveryAddress: 'Calle Principal #123',
      ),
      Order(
        id: 'order2',
        customerId: 'customer2',
        customerName: 'María López',
        products: [
          OrderItem(productId: 'prod3', name: 'Pizza', price: 8.99, quantity: 1),
        ],
        total: 8.99,
        status: OrderStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        deliveryAddress: 'Avenida Central #456',
      ),
    ]);
    notifyListeners();
  }
}