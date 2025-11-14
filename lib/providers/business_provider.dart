import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart' as models;
import '../models/promotion.dart';
import '../models/customer_insight.dart';
import '../services/firebase_storage_service.dart';
import '../models/delivery.dart';
import '../services/map_service.dart';
import '../models/driver_profile.dart';
import '../services/chat_service.dart';
import '../models/message.dart' show ConversationHelper;

class BusinessProvider with ChangeNotifier {
  final List<Product> _products = [];
  final List<models.Order> _orders = [];
  final Map<String, firestore.DocumentReference> _orderDocRefs = {};
  final List<Promotion> _promotions = [];
  final Map<String, firestore.DocumentReference> _promotionDocRefs = {};
  final List<CustomerInsight> _customerInsights = [];
  String? _cachedBusinessId;
  String? _cachedOwnerUid;
  String? _currentOwnerUid;
  
  List<Product> get products => _products;
  List<models.Order> get orders => _orders;
  List<Promotion> get promotions => List.unmodifiable(_promotions);
  List<CustomerInsight> get customerInsights => List.unmodifiable(_customerInsights);
  
  // Método para cargar productos desde Firestore
  Future<void> loadProducts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Usuario no autenticado, no se pueden cargar productos');
        }
        return;
      }

      _ensureOwnerContext(currentUser.uid);

      _products.clear();
      final db = firestore.FirebaseFirestore.instance;

      final businessId = await _getBusinessDocumentId(currentUser.uid);

      final Map<String, firestore.QueryDocumentSnapshot> productDocs = {};

      if (businessId != null) {
        final byBusiness = await db
            .collection('products')
            .where('businessId', isEqualTo: businessId)
            .get();
        for (final doc in byBusiness.docs) {
          productDocs[doc.id] = doc;
        }
      }

      final byOwner = await db
          .collection('products')
          .where('ownerUid', isEqualTo: currentUser.uid)
          .get();
      for (final doc in byOwner.docs) {
        productDocs[doc.id] = doc;
      }

      for (final doc in productDocs.values) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          String resolvedBusinessId = data['businessId']?.toString() ?? '';
          final ownerUid = data['ownerUid']?.toString() ?? currentUser.uid;

          if (resolvedBusinessId.isEmpty || resolvedBusinessId == ownerUid) {
            resolvedBusinessId = businessId ?? ownerUid;
          }

          final product = Product(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: _toDouble(data['price']),
            businessId: resolvedBusinessId,
            available: data['available'] ?? true,
            isPopular: data['isPopular'] ?? data['is_popular'] ?? false,
            imageUrl: data['imageUrl'] ?? data['image_url'],
            stock: _toInt(data['stock']),
            firestoreBusinessId: data['businessFirestoreId']?.toString() ?? doc.id,
          );

          _products.add(product);

          // Normalizar datos en Firestore para futuras lecturas
          final updates = <String, dynamic>{};
          if (data['businessId'] != resolvedBusinessId) {
            updates['businessId'] = resolvedBusinessId;
          }
          if (data['ownerUid'] != ownerUid) {
            updates['ownerUid'] = ownerUid;
          }
          if (_toInt(data['stock']) != product.stock) {
            updates['stock'] = product.stock;
          }
          if ((data['businessFirestoreId']?.toString() ?? doc.id) != product.firestoreBusinessId) {
            updates['businessFirestoreId'] = product.firestoreBusinessId;
          }
          if (updates.isNotEmpty) {
            await doc.reference.update(updates);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error parseando producto ${doc.id}: $e');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Productos cargados: ${_products.length}');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cargando productos: $e');
      }
    }
  }
  
  // Método para agregar un producto al catálogo
  void addProduct(Product product) {
    if (!_products.any((p) => p.id == product.id)) {
      _products.add(product);
      notifyListeners();
    }
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
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
  
  Future<bool> deleteProduct(Product product) async {
    try {
      final firestoreInstance = firestore.FirebaseFirestore.instance;
      await firestoreInstance.collection('products').doc(product.id).delete();

      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        try {
          await FirebaseStorageService().deleteImage(product.imageUrl!);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error eliminando imagen del producto: $e');
          }
        }
      }

      removeProduct(product.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error eliminando producto ${product.id}: $e');
      }
      return false;
    }
  }
  
  // Método para actualizar el estado de un pedido
  Future<void> updateOrderStatus(String orderId, models.OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final previous = _orders[index];
      _orders[index] = previous.copyWith(status: status);
      notifyListeners();

      final statusString = _statusToString(status);
      bool synced = false;

      final docRef = _orderDocRefs[orderId];
      if (docRef != null) {
        try {
          await docRef.update({
            'status': statusString,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
          });
          synced = true;
          final updatedOrder = await _syncDeliveryRecordForOrder(_orders[index], status, docRef);
          if (updatedOrder != null) {
            _orders[index] = updatedOrder;
            notifyListeners();
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ No se pudo actualizar estado en Firestore: $e');
          }
        }
      }

      if (!synced) {
        _orders[index] = previous;
        notifyListeners();
      }
    }
  }
  
  // Método para cargar pedidos (simulado para MVP)
  Future<void> loadOrders() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          debugPrint('⚠️ Usuario no autenticado, no se pueden cargar pedidos');
        }
        return;
      }

      final businessId = await _getBusinessDocumentId(currentUser.uid);
      final firestoreInstance = firestore.FirebaseFirestore.instance;

      final Map<String, firestore.QueryDocumentSnapshot> orderDocs = {};

      if (businessId != null) {
        final byBusiness = await firestoreInstance
            .collection('orders')
            .where('businessId', isEqualTo: businessId)
            .get();
        for (final doc in byBusiness.docs) {
          orderDocs[doc.id] = doc;
        }
      }

      // Fallback para pedidos antiguos que almacenaban el UID del dueño
      final byOwner = await firestoreInstance
          .collection('orders')
          .where('businessId', isEqualTo: currentUser.uid)
          .get();
      for (final doc in byOwner.docs) {
        orderDocs[doc.id] = doc;
      }

      final List<models.Order> fetchedOrders = [];
      _orderDocRefs.clear();

      for (final doc in orderDocs.values) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          final productsData = (data['products'] as List?) ?? [];
          final items = productsData.map((item) {
            final map = Map<String, dynamic>.from(item as Map);
            return models.OrderItem(
              productId: map['productId']?.toString() ?? map['product_id']?.toString() ?? '',
              name: map['name'] ?? map['productName'] ?? '',
              price: _toDouble(map['price']),
              quantity: _toInt(map['quantity'], fallback: 1),
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

          var order = models.Order(
            id: doc.id,
            customerId: data['customerId']?.toString() ?? '',
            customerName: data['customerName']?.toString() ?? '',
            products: items,
            total: _toDouble(data['total']),
            status: _parseOrderStatus(data['status']?.toString()),
            createdAt: createdAt,
            deliveryAddress: data['deliveryAddress']?.toString() ?? '',
            displayNumber: data['displayNumber'] is int
                ? data['displayNumber'] as int
                : int.tryParse(data['displayNumber']?.toString() ?? ''),
            paymentMethod: data['paymentMethod']?.toString() ??
                data['payment_method']?.toString(),
            driverId: data['driverId']?.toString(),
            driverName: data['driverName']?.toString(),
            deliveryStatus: data['deliveryStatus'] != null
                ? parseDeliveryStatus(data['deliveryStatus']?.toString())
                : null,
            assignedAt: _parseDate(data['assignedAt']),
            deliveredAt: _parseDate(data['deliveredAt']),
          );

          _orderDocRefs[doc.id] = doc.reference;

          if (order.status == models.OrderStatus.inProgress) {
            final updatedOrder =
                await _syncDeliveryRecordForOrder(order, order.status, doc.reference);
            if (updatedOrder != null) {
              order = updatedOrder;
            }
          }

          fetchedOrders.add(order);

          // Normalizar el businessId en el pedido
          final resolvedBusinessId = businessId ?? currentUser.uid;
          if (data['businessId'] != resolvedBusinessId) {
            await doc.reference.update({'businessId': resolvedBusinessId});
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('⚠️ Error parseando pedido ${doc.id}: $e');
          }
        }
      }

      fetchedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      for (var i = 0; i < fetchedOrders.length; i++) {
        if (fetchedOrders[i].displayNumber == null) {
          fetchedOrders[i] =
              fetchedOrders[i].copyWith(displayNumber: fetchedOrders.length - i);
        }
      }

      await _rebuildCustomerInsights(fetchedOrders);

      _orders
        ..clear()
        ..addAll(fetchedOrders);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cargando pedidos: $e');
      }
    }
  }

  Future<void> loadPromotions() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return;
      }

      final businessId = await _getBusinessDocumentId(currentUser.uid);
      if (businessId == null) {
        _promotions.clear();
        notifyListeners();
        return;
      }

      final firestoreInstance = firestore.FirebaseFirestore.instance;
      final snapshot = await firestoreInstance
          .collection('promotions')
          .where('businessId', isEqualTo: businessId)
          .get();

      _promotions
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          final promotion = Promotion.fromMap(data, doc.id);
          _promotionDocRefs[doc.id] = doc.reference;
          return promotion;
        }));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error cargando promociones: $e');
      }
    }
  }

  Future<Promotion?> createPromotion({
    required Product product,
    required String title,
    String? description,
    required double discountPercent,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      final businessId = await _getBusinessDocumentId(currentUser.uid) ?? currentUser.uid;

      final firestoreInstance = firestore.FirebaseFirestore.instance;

      final promotionalPrice = product.price * (1 - (discountPercent.clamp(0, 100) / 100));

      final data = {
        'businessId': businessId,
        'title': title,
        'description': description,
        'productId': product.id,
        'productName': product.name,
        'productImageUrl': product.imageUrl,
        'discountPercent': discountPercent,
        'promotionalPrice': double.parse(promotionalPrice.toStringAsFixed(2)),
        'startDate': startDate,
        'endDate': endDate,
        'isActive': true,
        'createdAt': firestore.FieldValue.serverTimestamp(),
      };

      final docRef = await firestoreInstance.collection('promotions').add(data);
      final promotion = Promotion(
        id: docRef.id,
        businessId: businessId,
        title: title,
        description: description,
        productId: product.id,
        productName: product.name,
        productImageUrl: product.imageUrl,
        discountPercent: discountPercent,
        promotionalPrice: double.parse(promotionalPrice.toStringAsFixed(2)),
        startDate: startDate,
        endDate: endDate,
        isActive: true,
      );

      _promotions.add(promotion);
      _promotionDocRefs[promotion.id] = docRef;
      notifyListeners();
      return promotion;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error creando promoción: $e');
      }
      return null;
    }
  }

  Future<bool> updatePromotion({
    required Promotion promotion,
    required String title,
    String? description,
    required double discountPercent,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final docRef = _promotionDocRefs[promotion.id];
      if (docRef == null) return false;

      final basePrice = promotion.promotionalPrice ??
          _products.firstWhere(
            (p) => p.id == promotion.productId,
            orElse: () => Product(
              id: promotion.productId,
              name: promotion.productName,
              description: promotion.description ?? '',
              price: promotion.promotionalPrice ?? 0,
              businessId: promotion.businessId,
            ),
          ).price;

      final promotionalPrice = basePrice * (1 - (discountPercent.clamp(0, 100) / 100));

      await docRef.update({
        'title': title,
        'description': description,
        'discountPercent': discountPercent,
        'promotionalPrice': double.parse(promotionalPrice.toStringAsFixed(2)),
        'startDate': startDate,
        'endDate': endDate,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      final index = _promotions.indexWhere((p) => p.id == promotion.id);
      if (index != -1) {
        _promotions[index] = promotion.copyWith(
          title: title,
          description: description,
          discountPercent: discountPercent,
          promotionalPrice: double.parse(promotionalPrice.toStringAsFixed(2)),
          startDate: startDate,
          endDate: endDate,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error actualizando promoción ${promotion.id}: $e');
      }
      return false;
    }
  }

  Future<bool> deletePromotion(String promotionId) async {
    try {
      final docRef = _promotionDocRefs[promotionId];
      if (docRef == null) return false;

      await docRef.delete();
      _promotions.removeWhere((promotion) => promotion.id == promotionId);
      _promotionDocRefs.remove(promotionId);
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error eliminando promoción $promotionId: $e');
      }
      return false;
    }
  }
 
  Future<String?> _getBusinessDocumentId(String ownerUid) async {
    if (_cachedBusinessId != null && _cachedOwnerUid == ownerUid) {
      return _cachedBusinessId;
    }

    try {
      final firestoreInstance = firestore.FirebaseFirestore.instance;
      final snapshot = await firestoreInstance
          .collection('businesses')
          .where('ownerUid', isEqualTo: ownerUid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _cachedBusinessId = snapshot.docs.first.id;
        _cachedOwnerUid = ownerUid;
      } else {
        _cachedBusinessId = null;
        _cachedOwnerUid = ownerUid;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ No se pudo obtener el negocio del usuario: $e');
      }
    }

    return _cachedBusinessId;
  }

  void _ensureOwnerContext(String ownerUid) {
    if (_currentOwnerUid == ownerUid) {
      return;
    }
    _currentOwnerUid = ownerUid;
    _cachedOwnerUid = ownerUid;
    _cachedBusinessId = null;
    _products.clear();
    _orders.clear();
    _orderDocRefs.clear();
    _promotions.clear();
    _promotionDocRefs.clear();
    notifyListeners();
  }

  void clearAll() {
    _cachedBusinessId = null;
    _cachedOwnerUid = null;
    _currentOwnerUid = null;
    _products.clear();
    _orders.clear();
    _orderDocRefs.clear();
    _promotions.clear();
    _promotionDocRefs.clear();
    notifyListeners();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? fallback;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is firestore.Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  models.OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return models.OrderStatus.pending;
      case 'in_progress':
      case 'preparing':
      case 'confirmed':
        return models.OrderStatus.inProgress;
      case 'delivered':
        return models.OrderStatus.delivered;
      case 'cancelled':
        return models.OrderStatus.cancelled;
      default:
        return models.OrderStatus.pending;
    }
  }

  String _statusToString(models.OrderStatus status) {
    switch (status) {
      case models.OrderStatus.pending:
        return 'pending';
      case models.OrderStatus.inProgress:
        return 'in_progress';
      case models.OrderStatus.delivered:
        return 'delivered';
      case models.OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  Future<void> refreshCustomerInsights() async {
    await _rebuildCustomerInsights(_orders);
    notifyListeners();
  }

  Future<Map<String, Map<String, dynamic>>> _fetchUserProfiles(
    Iterable<String> customerIds,
  ) async {
    final ids = customerIds.where((id) => id.isNotEmpty).toSet().toList();
    if (ids.isEmpty) {
      return {};
    }

    final db = firestore.FirebaseFirestore.instance;
    final Map<String, Map<String, dynamic>> results = {};

    try {
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, math.min(i + 10, ids.length));
        final snapshot = await db
            .collection('users')
            .where(firestore.FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snapshot.docs) {
          results[doc.id] = doc.data();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error recuperando perfiles de usuarios: $e');
      }
    }

    return results;
  }

  Future<void> _rebuildCustomerInsights(List<models.Order> sourceOrders) async {
    final Map<String, _CustomerStatsAccumulator> stats = {};

    for (final order in sourceOrders) {
      final customerId = order.customerId;
      if (customerId.isEmpty) {
        continue;
      }

      final accumulator = stats.putIfAbsent(
        customerId,
        () => _CustomerStatsAccumulator(name: order.customerName),
      );

      accumulator.registerOrder(order);
    }

    if (stats.isEmpty) {
      _customerInsights.clear();
      return;
    }

    final profiles = await _fetchUserProfiles(stats.keys);

    final List<CustomerInsight> insights = [];

    stats.forEach((customerId, accumulator) {
      final profile = profiles[customerId];
      final completed = accumulator.delivered;
      final cancelled = accumulator.cancelled;
      final totalOrders = accumulator.totalOrders;
      final cancellationRate = totalOrders > 0
          ? cancelled / totalOrders
          : 0.0;
      final loyaltyLevel = _calculateLoyaltyLevel(
        completed: completed,
        cancelled: cancelled,
        cancellationRate: cancellationRate,
        totalSpent: accumulator.totalSpent,
      );

      insights.add(
        CustomerInsight(
          customerId: customerId,
          name: profile?['name']?.toString().trim().isNotEmpty == true
              ? profile!['name'].toString()
              : accumulator.name,
          completedOrders: completed,
          cancelledOrders: cancelled,
          totalSpent: double.parse(accumulator.totalSpent.toStringAsFixed(2)),
          cancellationRate: double.parse(cancellationRate.toStringAsFixed(3)),
          loyaltyLevel: loyaltyLevel,
          email: profile?['email']?.toString(),
          profileImage: profile?['profileImage']?.toString(),
          lastOrderAt: accumulator.lastOrder,
        ),
      );
    });

    insights.sort((a, b) {
      final statusComparison = b.loyaltyLevel.compareTo(a.loyaltyLevel);
      if (statusComparison != 0) {
        return statusComparison;
      }

      final spendComparison = b.totalSpent.compareTo(a.totalSpent);
      if (spendComparison != 0) {
        return spendComparison;
      }

      final lastDateA = a.lastOrderAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final lastDateB = b.lastOrderAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return lastDateB.compareTo(lastDateA);
    });

    _customerInsights
      ..clear()
      ..addAll(insights);
  }

  String _calculateLoyaltyLevel({
    required int completed,
    required int cancelled,
    required double cancellationRate,
    required double totalSpent,
  }) {
    if (completed >= 10 && cancellationRate <= 0.05 && totalSpent >= 500) {
      return 'Cliente VIP';
    }
    if (completed >= 4 && cancellationRate <= 0.2) {
      return 'Excelente cliente';
    }
    if (completed + cancelled == 0) {
      return 'Nuevo cliente';
    }
    if (cancellationRate >= 0.5 || cancelled >= 3) {
      return 'En observación';
    }
    return 'Cliente frecuente';
  }

  Future<models.Order?> _syncDeliveryRecordForOrder(
    models.Order order,
    models.OrderStatus status,
    firestore.DocumentReference? orderDocRef,
  ) async {
    if (orderDocRef == null) return null;

    try {
      final firestoreInstance = firestore.FirebaseFirestore.instance;
      final deliveriesRef = firestoreInstance.collection('deliveries');
      final existing = await deliveriesRef.where('orderId', isEqualTo: order.id).limit(1).get();
      final existingDoc = existing.docs.isNotEmpty ? existing.docs.first : null;

      var updatedOrder = order;

      if (status == models.OrderStatus.inProgress) {
        firestore.DocumentReference? deliveryRef;
        Map<String, dynamic> orderData = {};

        final orderSnapshot = await orderDocRef.get();
        if (orderSnapshot.exists) {
          orderData = (orderSnapshot.data() as Map<String, dynamic>?) ?? {};
        }

        final businessInfo = await _resolveBusinessInfo(orderData);

        if (existingDoc != null) {
          deliveryRef = existingDoc.reference;
          await deliveryRef.update({
            'status': DeliveryStatus.pendingAssignment.firestoreValue,
            'updatedAt': firestore.FieldValue.serverTimestamp(),
            'pickupAddress': businessInfo['pickupAddress'],
            'businessName': businessInfo['businessName'],
            'dropoffAddress': order.deliveryAddress,
            'total': order.total,
            'customerName': order.customerName,
            'customerId': order.customerId,
            'paymentMethod': order.paymentMethod,
          });
        } else {
          final newDoc = await deliveriesRef.add({
            'orderId': order.id,
            'businessId': orderData['businessId']?.toString() ?? '',
            'status': DeliveryStatus.pendingAssignment.firestoreValue,
            'pickupAddress': businessInfo['pickupAddress'],
            'dropoffAddress': order.deliveryAddress,
            'total': order.total,
            'createdAt': firestore.FieldValue.serverTimestamp(),
            'driverId': null,
            'driverName': null,
            'driverPhone': null,
            'businessName': businessInfo['businessName'],
            'customerName': order.customerName,
            'customerId': order.customerId,
            'paymentMethod': order.paymentMethod,
          });
          deliveryRef = newDoc;
        }

        await orderDocRef.update({
          'deliveryStatus': DeliveryStatus.pendingAssignment.firestoreValue,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });

        updatedOrder = updatedOrder.copyWith(deliveryStatus: DeliveryStatus.pendingAssignment);

        final autoAssignedOrder = await _attemptAutomaticDriverAssignment(
          baseOrder: updatedOrder,
          orderDocRef: orderDocRef,
          deliveryRef: deliveryRef,
          orderSnapshotData: orderData,
        );
        if (autoAssignedOrder != null) {
          updatedOrder = autoAssignedOrder;
        }
      } else if (existingDoc != null) {
        DeliveryStatus deliveryStatus;
        switch (status) {
          case models.OrderStatus.delivered:
            deliveryStatus = DeliveryStatus.delivered;
            break;
          case models.OrderStatus.cancelled:
            deliveryStatus = DeliveryStatus.cancelled;
            break;
          default:
            deliveryStatus = DeliveryStatus.pendingAssignment;
        }

        final updates = {
          'status': deliveryStatus.firestoreValue,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        };
        if (deliveryStatus.isTerminal) {
          updates['completedAt'] = firestore.FieldValue.serverTimestamp();
        }

        await existingDoc.reference.update(updates);
        await orderDocRef.update({
          'deliveryStatus': deliveryStatus.firestoreValue,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });

        updatedOrder = updatedOrder.copyWith(deliveryStatus: deliveryStatus);
      }

      return updatedOrder == order ? null : updatedOrder;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ No se pudo sincronizar entrega para pedido ${order.id}: $e');
      }
      return null;
    }
  }

  Future<Map<String, String?>> _resolveBusinessInfo(Map<String, dynamic> orderData) async {
    String? pickupAddress = orderData['pickupAddress']?.toString();
    String? businessName = orderData['businessName']?.toString();
    final businessRefId = (orderData['businessFirestoreId']?.toString().isNotEmpty ?? false)
        ? orderData['businessFirestoreId'].toString()
        : orderData['businessId']?.toString();

    if (businessRefId != null && businessRefId.isNotEmpty) {
      try {
        final businessDoc = await firestore.FirebaseFirestore.instance
            .collection('businesses')
            .doc(businessRefId)
            .get();
        if (businessDoc.exists) {
          final Map<String, dynamic>? data = businessDoc.data();
          pickupAddress ??= data?['address']?.toString();
          businessName ??= data?['name']?.toString();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ No se pudo obtener datos del negocio $businessRefId: $e');
        }
      }
    }

    pickupAddress = pickupAddress != null && pickupAddress.isNotEmpty
        ? MapService.normalizeAddress(pickupAddress)
        : 'Dirección del negocio no disponible';
    return {
      'pickupAddress': pickupAddress,
      'businessName': businessName,
    };
  }

  Future<models.Order?> _attemptAutomaticDriverAssignment({
    required models.Order baseOrder,
    required firestore.DocumentReference orderDocRef,
    required firestore.DocumentReference deliveryRef,
    required Map<String, dynamic> orderSnapshotData,
  }) async {
    try {
      final deliverySnapshot = await deliveryRef.get();
      final deliveryData = deliverySnapshot.data() as Map<String, dynamic>? ?? {};
      final currentDriverId = deliveryData['driverId']?.toString() ?? '';
      if (currentDriverId.isNotEmpty) {
        final statusSource = deliveryData['status'] ?? deliveryData['deliveryStatus'];
        final deliveryStatus = statusSource != null
            ? parseDeliveryStatus(statusSource.toString())
            : DeliveryStatus.assigned;
        return baseOrder.copyWith(
          driverId: currentDriverId,
          driverName: deliveryData['driverName']?.toString(),
          deliveryStatus: deliveryStatus,
        );
      }

      final driversSnapshot = await firestore.FirebaseFirestore.instance
          .collection('drivers')
          .where('availability', isEqualTo: DriverAvailabilityStatus.available.firestoreValue)
          .get();

      if (driversSnapshot.docs.isEmpty) {
        return baseOrder;
      }

      final randomIndex = math.Random().nextInt(driversSnapshot.docs.length);
      final selectedDriverDoc = driversSnapshot.docs[randomIndex];
      final driverData = selectedDriverDoc.data();
      final driverUid = driverData['uid']?.toString() ?? selectedDriverDoc.id;

      if (driverUid.isEmpty) {
        return baseOrder;
      }

      final driverName = driverData['name']?.toString() ?? 'Repartidor';
      final driverPhone = driverData['phone']?.toString();

      await deliveryRef.update({
        'driverId': driverUid,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': DeliveryStatus.assigned.firestoreValue,
        'assignedAt': firestore.FieldValue.serverTimestamp(),
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      await orderDocRef.update({
        'driverId': driverUid,
        'driverName': driverName,
        if (driverPhone != null) 'driverPhone': driverPhone,
        'deliveryStatus': DeliveryStatus.assigned.firestoreValue,
        'assignedAt': firestore.FieldValue.serverTimestamp(),
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      await selectedDriverDoc.reference.update({
        'availability': DriverAvailabilityStatus.busy.firestoreValue,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      await _prepareAutomaticAssignmentChats(
        orderSnapshotData: orderSnapshotData,
        driverUid: driverUid,
        driverName: driverName,
        paymentMethod: baseOrder.paymentMethod,
      );

      return baseOrder.copyWith(
        driverId: driverUid,
        driverName: driverName,
        deliveryStatus: DeliveryStatus.assigned,
        assignedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ No se pudo asignar automáticamente un repartidor para ${baseOrder.id}: $e');
      }
      return baseOrder;
    }
  }

  Future<void> _prepareAutomaticAssignmentChats({
    required Map<String, dynamic> orderSnapshotData,
    required String driverUid,
    required String driverName,
    String? paymentMethod,
  }) async {
    try {
      final chatService = ChatService();
      final customerId = orderSnapshotData['customerId']?.toString() ?? '';
      final customerName = orderSnapshotData['customerName']?.toString() ?? 'Cliente';
      final driverDisplayName = _displayNameWithRole(
        driverName.isNotEmpty ? driverName : await _resolveUserName(driverUid),
        'Repartidor',
      );

      if (customerId.isNotEmpty) {
        final customerDisplayName = _displayNameWithRole(customerName, 'Cliente');
        await chatService.getOrCreateConversation(
          userId1: driverUid,
          userId2: customerId,
          user1Name: driverDisplayName,
          user2Name: customerDisplayName,
          user1Role: 'Repartidor',
          user2Role: 'Cliente',
        );
      }

      final businessId = orderSnapshotData['businessFirestoreId']?.toString().isNotEmpty == true
          ? orderSnapshotData['businessFirestoreId'].toString()
          : orderSnapshotData['businessId']?.toString() ?? '';
      final businessName = orderSnapshotData['businessName']?.toString() ?? '';

      if (businessId.isNotEmpty) {
        final businessDoc = await firestore.FirebaseFirestore.instance
            .collection('businesses')
            .doc(businessId)
            .get();
        final businessData = businessDoc.data() ?? {};
        var ownerId = businessData['ownerUid']?.toString() ?? '';
        if (ownerId.isEmpty) {
          ownerId = businessData['ownerId']?.toString() ?? '';
        }

        if (ownerId.isNotEmpty) {
          final resolvedOwnerName = await _resolveUserName(ownerId);
          final fallbackName = businessName.isNotEmpty ? businessName : 'Negocio';
          final ownerDisplayName = _displayNameWithRole(
            (resolvedOwnerName?.trim().isNotEmpty ?? false) ? resolvedOwnerName : fallbackName,
            'Dueño del negocio',
          );
          await chatService.getOrCreateConversation(
            userId1: driverUid,
            userId2: ownerId,
            user1Name: driverDisplayName,
            user2Name: ownerDisplayName,
            user1Role: 'Repartidor',
            user2Role: 'Dueño del negocio',
          );
        }
      }

      if (paymentMethod != null && paymentMethod.isNotEmpty && customerId.isNotEmpty) {
        await chatService.sendSystemMessage(
          conversationId: ConversationHelper.generateConversationId(driverUid, customerId),
          content: 'Método de pago: $paymentMethod',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ No se pudo preparar chats para la asignación automática: $e');
      }
    }
  }

  Future<String?> _resolveUserName(String userId) async {
    try {
      final userDoc =
          await firestore.FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final name = data?['name']?.toString();
        if (name != null && name.trim().isNotEmpty) {
          return name.trim();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error obteniendo nombre de usuario $userId: $e');
      }
    }
    return null;
  }

  String _displayNameWithRole(String? baseName, String role) {
    final trimmed = baseName?.trim() ?? '';
    final name = trimmed.isNotEmpty ? trimmed : role;
    return '$name ($role)';
  }
}

class _CustomerStatsAccumulator {
  _CustomerStatsAccumulator({required this.name});

  final String name;
  int delivered = 0;
  int cancelled = 0;
  int totalOrders = 0;
  double totalSpent = 0;
  DateTime? lastOrder;

  void registerOrder(models.Order order) {
    totalOrders += 1;

    if (order.status == models.OrderStatus.delivered) {
      delivered += 1;
      totalSpent += order.total;
    }

    if (order.status == models.OrderStatus.cancelled) {
      cancelled += 1;
    }

    if (lastOrder == null || order.createdAt.isAfter(lastOrder!)) {
      lastOrder = order.createdAt;
    }
  }
}
