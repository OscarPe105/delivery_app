import 'package:cloud_firestore/cloud_firestore.dart';

class Promotion {
  final String id;
  final String businessId;
  final String title;
  final String? description;
  final String productId;
  final String productName;
  final String? productImageUrl;
  final double discountPercent;
  final double? promotionalPrice;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Promotion({
    required this.id,
    required this.businessId,
    required this.title,
    required this.productId,
    required this.productName,
    required this.discountPercent,
    this.description,
    this.productImageUrl,
    this.promotionalPrice,
    this.startDate,
    this.endDate,
    this.isActive = true,
  });

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && startDate!.isAfter(now)) {
      return false;
    }
    if (endDate != null && endDate!.isBefore(now)) {
      return false;
    }
    return true;
  }

  Promotion copyWith({
    String? id,
    String? businessId,
    String? title,
    String? description,
    String? productId,
    String? productName,
    String? productImageUrl,
    double? discountPercent,
    double? promotionalPrice,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Promotion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      discountPercent: discountPercent ?? this.discountPercent,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Promotion.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is double) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt());
      }
      return null;
    }

    double parseDiscount(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return Promotion(
      id: id,
      businessId: map['businessId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImageUrl: map['productImageUrl']?.toString(),
      discountPercent: parseDiscount(map['discountPercent']),
      promotionalPrice: map['promotionalPrice'] is num
          ? (map['promotionalPrice'] as num).toDouble()
          : double.tryParse(map['promotionalPrice']?.toString() ?? ''),
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'title': title,
      'description': description,
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'discountPercent': discountPercent,
      if (promotionalPrice != null) 'promotionalPrice': promotionalPrice,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
      'isActive': isActive,
      'updatedAt': DateTime.now(),
    };
  }
}

