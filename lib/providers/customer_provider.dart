import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/order.dart';

class CustomerProvider with ChangeNotifier {
  final List<Product> _searchResults = [];
  final List<Order> _myOrders = [];
  final List<Product> _cart = [];
  bool _isLoadingOrders = false;
  String? _ordersError;
  
  List<Product> get searchResults => _searchResults;
  List<Order> get myOrders => _myOrders;
  List<Product> get cart => _cart;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;
  
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.price);

  int get totalOrders => _myOrders.length;
  int get deliveredOrders => _myOrders.where((o) => o.status == OrderStatus.delivered).length;
  int get cancelledOrders => _myOrders.where((o) => o.status == OrderStatus.cancelled).length;
  double get totalDeliveredSpent => _myOrders
      .where((o) => o.status == OrderStatus.delivered)
      .fold(0.0, (sum, order) => sum + order.total);
  double get cancellationRate {
    final total = deliveredOrders + cancelledOrders;
    if (total == 0) return 0;
    return cancelledOrders / total;
  }

  DateTime? get lastOrderDate {
    if (_myOrders.isEmpty) return null;
    return _myOrders.map((o) => o.createdAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  String get loyaltyLevel {
    final completed = deliveredOrders;
    final cancelled = cancelledOrders;
    final rate = cancellationRate;
    final spent = totalDeliveredSpent;

    if (completed >= 10 && rate <= 0.05 && spent >= 500) {
      return 'Cliente VIP';
    }
    if (completed >= 4 && rate <= 0.2) {
      return 'Excelente cliente';
    }
    if (completed == 0 && cancelled == 0) {
      return 'Nuevo cliente';
    }
    if (rate >= 0.5 || cancelled >= 3) {
      return 'En observación';
    }
    return 'Cliente frecuente';
  }
  
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
        imageUrl: null,
        businessId: 'business1',
      ),
      Product(
        id: 'prod2',
        name: 'Papas Fritas',
        description: 'Crujientes papas fritas con sal',
        price: 2.50,
        imageUrl: null,
        businessId: 'business1',
      ),
      Product(
        id: 'prod3',
        name: 'Pizza Margarita',
        description: 'Pizza tradicional con salsa de tomate, queso mozzarella y albahaca',
        price: 8.99,
        imageUrl: null,
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
  
  Future<void> loadMyOrders(String customerId) async {
    if (customerId.isEmpty) return;

    _isLoadingOrders = true;
    _ordersError = null;
    notifyListeners();

    try {
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('orders')
          .where('customerId', isEqualTo: customerId)
          .get();

      final orders = snapshot.docs.map((doc) {
        final data = doc.data();

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
          customerId: data['customerId']?.toString() ?? customerId,
          customerName: data['customerName']?.toString() ?? '',
          products: items,
          total: _safeToDouble(data['total']),
          status: _statusFromString(data['status']?.toString()),
          createdAt: createdAt,
          deliveryAddress: data['deliveryAddress']?.toString() ?? '',
          displayNumber: data['displayNumber'] is int
              ? data['displayNumber'] as int
              : int.tryParse(data['displayNumber']?.toString() ?? ''),
          paymentMethod: data['paymentMethod']?.toString() ??
              data['payment_method']?.toString(),
        );
      }).toList();

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (var i = 0; i < orders.length; i++) {
        if (orders[i].displayNumber == null) {
          orders[i] = orders[i].copyWith(displayNumber: orders.length - i);
        }
      }

      _myOrders
        ..clear()
        ..addAll(orders);
    } catch (e, stackTrace) {
      _ordersError = 'No pudimos cargar tus pedidos. Intenta nuevamente.';
      if (kDebugMode) {
        debugPrint('❌ Error cargando pedidos del cliente: $e');
        debugPrint(stackTrace.toString());
      }
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
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
}
