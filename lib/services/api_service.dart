import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/business.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // Token JWT de Django (se obtiene después de Firebase login)
  String? _djangoToken;
  
  // Para Android Emulator usar 10.0.2.2, para Web usar localhost
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://10.0.2.2:8000/api';
    }
  }
  
  // Headers comunes
  Future<Map<String, String>> get headers async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  // Headers con autenticación (solo para endpoints que lo requieren)
  Future<Map<String, String>> get authHeaders async {
    // Si tenemos token de Django, usarlo
    if (_djangoToken != null) {
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_djangoToken',
      };
    }
    
    // Si no hay token, retornar headers sin autenticación
    // (Los endpoints públicos funcionan sin token)
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
  
  // Guardar token JWT de Django después del login
  void setDjangoToken(String token) {
    _djangoToken = token;
    if (kDebugMode) {
      print('✅ Token JWT guardado');
    }
  }
  
  // Limpiar token (logout)
  void clearToken() {
    _djangoToken = null;
    if (kDebugMode) {
      print('🗑️ Token limpiado');
    }
  }

  // ==================== NEGOCIOS ====================
  
  Future<List<Business>> getBusinesses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/'),
        headers: await headers,
      );
      
      if (kDebugMode) {
        print('🔍 ApiService.getBusinesses - Status: ${response.statusCode}');
        print('📦 Response: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        
        // Django puede devolver paginación con 'results' o directamente un array
        final List<dynamic> data = decoded is Map 
          ? (decoded['results'] as List? ?? [])
          : decoded as List;
        
        if (kDebugMode) {
          print('✅ Negocios parseados: ${data.length}');
        }
        
        return data.map((json) => Business.fromJson(json)).toList();
      } else {
        if (kDebugMode) {
          print('❌ Error obteniendo negocios: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en getBusinesses: $e');
      }
      return [];
    }
  }

  Future<Business?> getBusinessById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/$id/'),
        headers: await headers,
      );
      
      if (response.statusCode == 200) {
        return Business.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en getBusinessById: $e');
      }
      return null;
    }
  }

  Future<List<Business>> getNearbyBusinesses(double latitude, double longitude, double radiusKm) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/businesses/nearby/?lat=$latitude&lng=$longitude&radius=$radiusKm'),
        headers: await headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Business.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error en getNearbyBusinesses: $e');
      }
      return [];
    }
  }

  // ==================== PRODUCTOS ====================
  
  Future<List<Product>> getProducts({String? businessId, String? category}) async {
    try {
      String url = '$baseUrl/products/';
      List<String> params = [];
      
      if (businessId != null) params.add('business=$businessId');
      if (category != null) params.add('category=$category');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await headers,
      );
      
      if (kDebugMode) {
        print('🔍 ApiService.getProducts - Status: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        
        // Django puede devolver paginación con 'results' o directamente un array
        final List<dynamic> data = decoded is Map 
          ? (decoded['results'] as List? ?? [])
          : decoded as List;
        
        if (kDebugMode) {
          print('✅ Productos parseados: ${data.length}');
        }
        
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en getProducts: $e');
      }
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id/'),
        headers: await headers,
      );
      
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en getProductById: $e');
      }
      return null;
    }
  }

  // ==================== PEDIDOS ====================
  
  Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/'),
        headers: await headers,
      );
      
      if (kDebugMode) {
        print('🔍 ApiService.getOrders - Status: ${response.statusCode}');
        print('📦 Response: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        
        final orders = results.map((orderData) => Order.fromJson(orderData)).toList();
        
        if (kDebugMode) {
          print('✅ Pedidos parseados: ${orders.length}');
        }
        
        return orders;
      } else {
        if (kDebugMode) {
          print('❌ Error obteniendo pedidos: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en getOrders: $e');
      }
      return [];
    }
  }
  
  Future<List<Order>> getUserOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/customer/'),
        headers: await headers,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error en getUserOrders: $e');
      }
      return [];
    }
  }

  Future<Order?> createOrder(Order order) async {
    try {
      final jsonData = _orderToJson(order);
      
      if (kDebugMode) {
        print('🔵 Creando pedido en: $baseUrl/orders/');
        print('📦 Datos a enviar: ${json.encode(jsonData)}');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/orders/'),
        headers: await authHeaders,  // Usar headers con autenticación
        body: json.encode(jsonData),
      );
      
      if (kDebugMode) {
        print('📡 Status Code: ${response.statusCode}');
        print('📨 Response: ${response.body}');
      }
      
                  if (response.statusCode == 201) {
              final createdOrder = Order.fromJson(json.decode(response.body));
              if (kDebugMode) {
                print('✅ Pedido creado exitosamente');
              }
              return createdOrder;
            } else {
        if (kDebugMode) {
          print('❌ Error creando pedido: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en createOrder: $e');
      }
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status/'),
        headers: await headers,
        body: json.encode({'status': status}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error en updateOrderStatus: $e');
      }
      return false;
    }
  }

  // ==================== UTILIDADES ====================
  
  Map<String, dynamic> _orderToJson(Order order) {
    // Obtener businessId configurado o usar del primer producto
    String businessId = _currentBusinessId;
    
    if (businessId == '1' && order.products.isNotEmpty && _products.isNotEmpty) {
      try {
        final product = _products.firstWhere(
          (p) => p.id == order.products.first.productId,
        );
        businessId = product.businessId;
      } catch (e) {
        // Usar el businessId configurado
      }
    }
    
    // Calcular subtotal
    final subtotal = order.products.fold<double>(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    
    return {
      'business': businessId,
      'delivery_address': order.deliveryAddress,
      'items': order.products.map((item) => {
        'product': item.productId,
        'quantity': item.quantity,
      }).toList(),
      'subtotal': subtotal,
      'delivery_fee': 0.0,  // Por defecto sin costo de envío
      'tax': 0.0,  // Por defecto sin impuestos
    };
  }
  
  // Lista temporal de productos para obtener businessId
  List<Product> _products = [];
  
  Future<void> setProducts(List<Product> products) async {
    _products = products;
  }
  
  // Método para set business id para pedidos
  void setBusinessIdForOrder(String businessId) {
    _currentBusinessId = businessId;
  }
  
  String _currentBusinessId = '1';
}
