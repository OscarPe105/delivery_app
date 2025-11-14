import 'package:cloud_firestore/cloud_firestore.dart';

enum DeliveryStatus {
  pendingAssignment,
  assigned,
  pickedUp,
  enRoute,
  delivered,
  cancelled,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get firestoreValue {
    switch (this) {
      case DeliveryStatus.pendingAssignment:
        return 'pending_assignment';
      case DeliveryStatus.assigned:
        return 'assigned';
      case DeliveryStatus.pickedUp:
        return 'picked_up';
      case DeliveryStatus.enRoute:
        return 'en_route';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
    }
  }

  bool get isTerminal {
    return this == DeliveryStatus.delivered || this == DeliveryStatus.cancelled;
  }
}

DeliveryStatus parseDeliveryStatus(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'assigned':
      return DeliveryStatus.assigned;
    case 'picked_up':
    case 'pickedup':
      return DeliveryStatus.pickedUp;
    case 'en_route':
    case 'enroute':
      return DeliveryStatus.enRoute;
    case 'delivered':
      return DeliveryStatus.delivered;
    case 'cancelled':
    case 'canceled':
      return DeliveryStatus.cancelled;
    default:
      return DeliveryStatus.pendingAssignment;
  }
}

class Delivery {
  final String id;
  final String orderId;
  final String businessId;
  final String? driverId;
  final DeliveryStatus status;
  final String pickupAddress;
  final String dropoffAddress;
  final double total;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? completedAt;
  final String? driverName;
  final String? driverPhone;

  Delivery({
    required this.id,
    required this.orderId,
    required this.businessId,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.total,
    required this.createdAt,
    this.driverId,
    this.assignedAt,
    this.completedAt,
    this.driverName,
    this.driverPhone,
  });

  Delivery copyWith({
    String? id,
    String? orderId,
    String? businessId,
    String? driverId,
    DeliveryStatus? status,
    String? pickupAddress,
    String? dropoffAddress,
    double? total,
    DateTime? createdAt,
    DateTime? assignedAt,
    DateTime? completedAt,
    String? driverName,
    String? driverPhone,
  }) {
    return Delivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      businessId: businessId ?? this.businessId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
    );
  }

  factory Delivery.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdAt = _timestampToDate(data['createdAt']);
    final assignedAt = _timestampToDate(data['assignedAt']);
    final completedAt = _timestampToDate(data['completedAt']);

    return Delivery(
      id: doc.id,
      orderId: data['orderId']?.toString() ?? '',
      businessId: data['businessId']?.toString() ?? '',
      driverId: data['driverId']?.toString(),
      status: parseDeliveryStatus(data['status']?.toString()),
      pickupAddress: data['pickupAddress']?.toString() ?? '',
      dropoffAddress: data['dropoffAddress']?.toString() ?? '',
      total: _safeDouble(data['total']),
      createdAt: createdAt ?? DateTime.now(),
      assignedAt: assignedAt,
      completedAt: completedAt,
      driverName: data['driverName']?.toString(),
      driverPhone: data['driverPhone']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      'businessId': businessId,
      'driverId': driverId,
      'status': status.firestoreValue,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'total': total,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      if (assignedAt != null) 'assignedAt': Timestamp.fromDate(assignedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static double _safeDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

