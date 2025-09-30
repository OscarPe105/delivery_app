import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/business.dart'; // ✅ Agregar esta importación

class BusinessProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<Order> _orders = [];
  final List<Business> _businesses = []; // ✅ Agregar esta lista
  
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Business> get businesses => _businesses; // ✅ Agregar este getter
  
  // ✅ Agregar este método
  void loadBusinesses() {
    // Simulación de carga de negocios para el MVP
    _businesses.clear();
    _businesses.addAll([
      Business(
        id: 'business1',
        name: 'Restaurante El Buen Sabor',
        category: 'Restaurante',
        description: 'Comida tradicional hondureña',
        address: 'Barrio El Centro, Tegucigalpa',
        phone: '+50422345678',
        rating: 4.5,
        imageUrl: 'assets/images/restaurant1.jpg',
      ),
      Business(
        id: 'business2',
        name: 'Pizzería Don Mario',
        category: 'Pizzería',
        description: 'Las mejores pizzas de la ciudad',
        address: 'Colonia Palmira, Tegucigalpa',
        phone: '+50422987654',
        rating: 4.2,
        imageUrl: 'assets/images/pizza1.jpg',
      ),
      Business(
        id: 'business3',
        name: 'Farmacia San José',
        category: 'Farmacia',
        description: 'Medicamentos y productos de salud',
        address: 'Barrio La Granja, Tegucigalpa',
        phone: '+50422111222',
        rating: 4.8,
        imageUrl: 'assets/images/pharmacy1.jpg',
      ),
    ]);
    notifyListeners();
  }
  
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