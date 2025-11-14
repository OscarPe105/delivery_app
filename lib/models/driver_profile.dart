import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverAvailabilityStatus {
  offline,
  available,
  busy,
  suspended,
}

DriverAvailabilityStatus parseDriverAvailability(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'available':
      return DriverAvailabilityStatus.available;
    case 'busy':
      return DriverAvailabilityStatus.busy;
    case 'suspended':
      return DriverAvailabilityStatus.suspended;
    default:
      return DriverAvailabilityStatus.offline;
  }
}

extension DriverAvailabilityExtension on DriverAvailabilityStatus {
  String get firestoreValue {
    switch (this) {
      case DriverAvailabilityStatus.available:
        return 'available';
      case DriverAvailabilityStatus.busy:
        return 'busy';
      case DriverAvailabilityStatus.suspended:
        return 'suspended';
      case DriverAvailabilityStatus.offline:
        return 'offline';
    }
  }

  bool get isActive => this == DriverAvailabilityStatus.available;
}

class DriverProfile {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String? vehicleType;
  final String? vehiclePlate;
  final DriverAvailabilityStatus availability;
  final double rating;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final DateTime? lastDeliveryAt;

  DriverProfile({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.availability,
    this.photoUrl,
    this.vehicleType,
    this.vehiclePlate,
    this.rating = 0,
    this.completedDeliveries = 0,
    this.cancelledDeliveries = 0,
    this.lastDeliveryAt,
  });

  DriverProfile copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    String? vehicleType,
    String? vehiclePlate,
    DriverAvailabilityStatus? availability,
    double? rating,
    int? completedDeliveries,
    int? cancelledDeliveries,
    DateTime? lastDeliveryAt,
  }) {
    return DriverProfile(
      id: id,
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      availability: availability ?? this.availability,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      rating: rating ?? this.rating,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      cancelledDeliveries: cancelledDeliveries ?? this.cancelledDeliveries,
      lastDeliveryAt: lastDeliveryAt ?? this.lastDeliveryAt,
    );
  }

  factory DriverProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DriverProfile(
      id: doc.id,
      uid: data['uid']?.toString() ?? doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? data['profileImage']?.toString(),
      vehicleType: data['vehicleType']?.toString(),
      vehiclePlate: data['vehiclePlate']?.toString(),
      availability: parseDriverAvailability(data['availability']?.toString()),
      rating: _safeToDouble(data['rating']),
      completedDeliveries: _safeToInt(data['completedDeliveries']),
      cancelledDeliveries: _safeToInt(data['cancelledDeliveries']),
      lastDeliveryAt: _toDate(data['lastDeliveryAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'vehicleType': vehicleType,
      'vehiclePlate': vehiclePlate,
      'availability': availability.firestoreValue,
      'rating': rating,
      'completedDeliveries': completedDeliveries,
      'cancelledDeliveries': cancelledDeliveries,
      if (lastDeliveryAt != null) 'lastDeliveryAt': Timestamp.fromDate(lastDeliveryAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static double _safeToDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static int _safeToInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

