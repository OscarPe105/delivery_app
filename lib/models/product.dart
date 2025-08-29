class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String businessId;
  final bool available;
  final bool isPopular;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
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
}