import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/order.dart';

class CustomerProvider with ChangeNotifier {
  final List<Product> _searchResults = [];
  final List<Order> _myOrders = [];
  final List<Product> _cart = [];
  
  List<Product> get searchResults => _searchResults;
  List<Order> get myOrders => _myOrders;
  List<Product> get cart => _cart;
  
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.price);
  
  // Método para buscar productos (simulado para MVP)
  void searchProducts(String query) {
    // Simulación de búsqueda para el MVP
    _searchResults.clear();
    _searchResults.addAll([
      Product(
        id: 'prod1',
        name: 'Hamburguesa Clásica',
        description: 'Deliciosa hamburguesa con carne, lechuga, tomate y queso',
        price: 5.99,
        imageUrl: 'https://via.placeholder.com/150',
        businessId: 'business1',
      ),
      Product(
        id: 'prod2',
        name: 'Papas Fritas',
        description: 'Crujientes papas fritas con sal',
        price: 2.50,
        imageUrl: 'https://via.placeholder.com/150',
        businessId: 'business1',
      ),
      Product(
        id: 'prod3',
        name: 'Pizza Margarita',
        description: 'Pizza tradicional con salsa de tomate, queso mozzarella y albahaca',
        price: 8.99,
        imageUrl: 'https://via.placeholder.com/150',
        businessId: 'business2',
      ),
    ]);
    notifyListeners();
  }
  
  // Método para agregar un producto al carrito
  void addToCart(Product product) {
    _cart.add(product);
    notifyListeners();
  }
  
  // Método para eliminar un producto del carrito
  void removeFromCart(String productId) {
    _cart.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
  
  // Método para vaciar el carrito
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
  
  // Método para realizar un pedido
  Future<bool> placeOrder(String address) async {
    if (_cart.isEmpty) return false;
    
    // Simulación de creación de pedido para el MVP
    final newOrder = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      customerId: 'customer_id',
      customerName: 'Cliente Actual',
      products: _cart.map((p) => OrderItem(
        productId: p.id,
        name: p.name,
        price: p.price,
        quantity: 1,
      )).toList(),
      total: cartTotal,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      deliveryAddress: address,
    );
    
    _myOrders.add(newOrder);
    clearCart();
    return true;
  }
  
  // Método para cargar los pedidos del cliente (simulado para MVP)
  void loadMyOrders() {
    // Simulación de carga de pedidos para el MVP
    _myOrders.clear();
    _myOrders.addAll([
      Order(
        id: 'order1',
        customerId: 'customer_id',
        customerName: 'Cliente Actual',
        products: [
          OrderItem(productId: 'prod1', name: 'Hamburguesa', price: 5.99, quantity: 2),
          OrderItem(productId: 'prod2', name: 'Papas fritas', price: 2.50, quantity: 1),
        ],
        total: 14.48,
        status: OrderStatus.delivered,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        deliveryAddress: 'Mi dirección #123',
      ),
    ]);
    notifyListeners();
  }
}