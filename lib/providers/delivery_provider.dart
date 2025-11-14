import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delivery.dart';
import '../models/driver_profile.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

class DeliveryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Delivery> _businessDeliveries = [];
  final List<Delivery> _availableDeliveries = [];
  final List<Delivery> _driverDeliveries = [];

  DriverProfile? _driverProfile;
  bool _isLoading = false;
  String? _lastError;

  List<Delivery> get businessDeliveries => List.unmodifiable(_businessDeliveries);
  List<Delivery> get availableDeliveries => List.unmodifiable(_availableDeliveries);
  List<Delivery> get driverDeliveries => List.unmodifiable(_driverDeliveries);
  DriverProfile? get driverProfile => _driverProfile;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  Future<void> loadDeliveriesForBusiness(String businessId) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection('deliveries')
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();

      _businessDeliveries
        ..clear()
        ..addAll(snapshot.docs.map(Delivery.fromFirestore));
    } catch (e) {
      _handleError('Error cargando entregas del negocio', e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadAvailableDeliveries() async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection('deliveries')
          .where('status', isEqualTo: DeliveryStatus.pendingAssignment.firestoreValue)
          .orderBy('createdAt')
          .get();

      _availableDeliveries
        ..clear()
        ..addAll(snapshot.docs.map(Delivery.fromFirestore));
    } catch (e) {
      _handleError('Error cargando entregas disponibles', e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadDriverDeliveries(String driverId) async {
    try {
      _setLoading(true);
      final snapshot = await _firestore
          .collection('deliveries')
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      _driverDeliveries
        ..clear()
        ..addAll(snapshot.docs.map(Delivery.fromFirestore));
    } catch (e) {
      _handleError('Error cargando entregas del repartidor', e);
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadDriverProfile(String driverUid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('drivers').doc(driverUid).get();
      if (doc.exists) {
        _driverProfile = DriverProfile.fromFirestore(doc);
      } else {
        // Crear perfil base si no existe
        _driverProfile = DriverProfile(
          id: driverUid,
          uid: driverUid,
          name: '',
          email: '',
          phone: '',
          availability: DriverAvailabilityStatus.offline,
        );
        await _firestore.collection('drivers').doc(driverUid).set(_driverProfile!.toFirestore());
      }
      notifyListeners();
    } catch (e) {
      _handleError('Error cargando perfil del repartidor', e);
    }
  }

  Future<void> updateDriverAvailability(
    String driverUid,
    DriverAvailabilityStatus availability,
  ) async {
    try {
      await _firestore.collection('drivers').doc(driverUid).update({
        'availability': availability.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (_driverProfile != null && _driverProfile!.uid == driverUid) {
        _driverProfile = _driverProfile!.copyWith(availability: availability);
        notifyListeners();
      }
    } catch (e) {
      _handleError('No se pudo actualizar la disponibilidad', e);
    }
  }

  Future<bool> assignDeliveryToDriver({
    required String deliveryId,
    required String driverUid,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      final ref = _firestore.collection('deliveries').doc(deliveryId);
      await ref.update({
        'driverId': driverUid,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': DeliveryStatus.assigned.firestoreValue,
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await ref.get();
      final data = snapshot.data();
      final orderId = data?['orderId']?.toString();
      if (orderId != null && orderId.isNotEmpty) {
        final orderRef = _firestore.collection('orders').doc(orderId);
        final orderDoc = await orderRef.get();
        await orderRef.update({
          'driverId': driverUid,
          'driverName': driverName,
          'driverPhone': driverPhone,
          'deliveryStatus': DeliveryStatus.assigned.firestoreValue,
          'assignedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _ensureAssignmentChats(
          orderSnapshot: orderDoc,
          driverUid: driverUid,
          driverName: driverName,
          driverPhone: driverPhone,
        );
      }

      await loadDriverDeliveries(driverUid);
      await loadAvailableDeliveries();
      return true;
    } catch (e) {
      _handleError('No se pudo asignar la entrega', e);
      return false;
    }
  }

  Future<bool> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus status,
    String? driverUid,
    String? orderId,
  }) async {
    try {
      final updates = {
        'status': status.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (status == DeliveryStatus.delivered) {
        updates['completedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('deliveries').doc(deliveryId).update(updates);

      if (orderId != null) {
        final orderUpdates = <String, dynamic>{
          'deliveryStatus': status.firestoreValue,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (status == DeliveryStatus.delivered) {
          orderUpdates['status'] = 'delivered';
          orderUpdates['deliveredAt'] = FieldValue.serverTimestamp();
        } else if (status == DeliveryStatus.pickedUp || status == DeliveryStatus.enRoute) {
          orderUpdates['status'] = 'in_progress';
        }

        await _firestore.collection('orders').doc(orderId).update(orderUpdates);
      }

      if (driverUid != null) {
        await loadDriverDeliveries(driverUid);
      }
      return true;
    } catch (e) {
      _handleError('No se pudo actualizar el estado de la entrega', e);
      return false;
    }
  }

  Future<void> _ensureAssignmentChats({
    required DocumentSnapshot<Map<String, dynamic>>? orderSnapshot,
    required String driverUid,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      final chatService = ChatService();

      final orderData = orderSnapshot?.data() ?? {};
      final customerId = orderData['customerId']?.toString() ?? '';
      final customerName = orderData['customerName']?.toString() ?? 'Cliente';
      final businessId = orderData['businessFirestoreId']?.toString().isNotEmpty == true
          ? orderData['businessFirestoreId'].toString()
          : orderData['businessId']?.toString() ?? '';
      final businessName = orderData['businessName']?.toString() ?? '';
      final paymentMethod = orderData['paymentMethod']?.toString();

      final driverDisplayName = _displayNameWithRole(
        driverName ?? _driverProfile?.name ?? await _resolveUserName(driverUid),
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

      if (businessId.isNotEmpty) {
        final businessDoc = await _firestore.collection('businesses').doc(businessId).get();
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
      _handleError('No se pudo preparar el chat de la entrega', e);
    }
  }

  Future<String?> _resolveUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final name = data?['name']?.toString();
        if (name != null && name.trim().isNotEmpty) {
          return name.trim();
        }
      }
    } catch (e) {
      _handleError('Error obteniendo nombre de usuario', e);
    }
    return null;
  }

  String _displayNameWithRole(String? baseName, String role) {
    final trimmed = baseName?.trim() ?? '';
    final name = trimmed.isNotEmpty ? trimmed : role;
    return '$name ($role)';
  }

  Delivery? getDeliveryByOrder(String orderId) {
    try {
      return [
        ..._businessDeliveries,
        ..._driverDeliveries,
        ..._availableDeliveries,
      ].firstWhere((delivery) => delivery.orderId == orderId);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _businessDeliveries.clear();
    _availableDeliveries.clear();
    _driverDeliveries.clear();
    _driverProfile = null;
    _lastError = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _handleError(String contextMessage, Object error) {
    _lastError = '$contextMessage: $error';
    if (kDebugMode) {
      debugPrint('❌ $contextMessage: $error');
    }
  }
}

