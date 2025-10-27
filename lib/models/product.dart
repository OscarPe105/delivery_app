class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String businessId;
  final bool available;
  final bool isPopular;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.businessId,
    this.available = true,
    this.isPopular = false,
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
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      imageUrl: json['image_url'],
      businessId: json['business']?.toString() ?? '',
      available: json['available'] ?? true,
      isPopular: json['is_popular'] ?? false,
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
    };
  }
}