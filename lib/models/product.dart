class Product {
  static const Object _undefined = Object();

  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String businessId;
  final bool available;
  final bool isPopular;
  final int stock;
  final String? firestoreBusinessId;
  final double? promotionalPrice;
  final double? promotionalDiscountPercent;
  final String? promotionId;
  final DateTime? promotionEndDate;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.businessId,
    this.available = true,
    this.isPopular = false,
    this.stock = 0,
    this.firestoreBusinessId,
    this.promotionalPrice,
    this.promotionalDiscountPercent,
    this.promotionId,
    this.promotionEndDate,
  });
  
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? businessId,
    bool? available,
    bool? isPopular,
    int? stock,
    String? firestoreBusinessId,
    Object? promotionalPrice = _undefined,
    Object? promotionalDiscountPercent = _undefined,
    Object? promotionId = _undefined,
    Object? promotionEndDate = _undefined,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      businessId: businessId ?? this.businessId,
      available: available ?? this.available,
      isPopular: isPopular ?? this.isPopular,
      stock: stock ?? this.stock,
      firestoreBusinessId: firestoreBusinessId ?? this.firestoreBusinessId,
      promotionalPrice: identical(promotionalPrice, _undefined)
          ? this.promotionalPrice
          : promotionalPrice as double?,
      promotionalDiscountPercent: identical(promotionalDiscountPercent, _undefined)
          ? this.promotionalDiscountPercent
          : promotionalDiscountPercent as double?,
      promotionId: identical(promotionId, _undefined)
          ? this.promotionId
          : promotionId as String?,
      promotionEndDate: identical(promotionEndDate, _undefined)
          ? this.promotionEndDate
          : promotionEndDate as DateTime?,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    int parseStock(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      imageUrl: json['imageUrl'] ?? json['image_url'],
      businessId: json['business']?.toString() ?? '',
      available: json['available'] ?? true,
      isPopular: json['is_popular'] ?? json['isPopular'] ?? false,
      stock: parseStock(json['stock'] ?? json['available_stock'] ?? json['inventory']),
      firestoreBusinessId: json['businessFirestoreId']?.toString() ?? json['business_firestore_id']?.toString(),
      promotionalPrice: json['promotionalPrice'] != null
          ? double.tryParse(json['promotionalPrice'].toString())
          : null,
      promotionalDiscountPercent: json['promotionalDiscountPercent'] != null
          ? double.tryParse(json['promotionalDiscountPercent'].toString())
          : null,
      promotionId: json['promotionId']?.toString(),
      promotionEndDate: json['promotionEndDate'] != null
          ? DateTime.tryParse(json['promotionEndDate'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl ?? '',
      'business': businessId,
      'available': available,
      'is_popular': isPopular,
      'stock': stock,
      'businessFirestoreId': firestoreBusinessId,
      if (promotionalPrice != null) 'promotionalPrice': promotionalPrice,
      if (promotionalDiscountPercent != null)
        'promotionalDiscountPercent': promotionalDiscountPercent,
      if (promotionId != null) 'promotionId': promotionId,
      if (promotionEndDate != null) 'promotionEndDate': promotionEndDate!.toIso8601String(),
    };
  }
}
