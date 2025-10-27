class Business {
  final String id;
  final String name;
  final String category;
  final String? description;
  final String? address;
  final String? phone;
  final double? latitude;  // Nueva propiedad
  final double? longitude; // Nueva propiedad
  final double? rating;
  final String? imageUrl;
  final bool isActive;
  final bool isOpen;
  final List<String>? tags;

  Business({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.address,
    this.phone,
    this.latitude,
    this.longitude,
    this.rating,
    this.imageUrl,
    this.isActive = true,
    this.isOpen = true,
    this.tags,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category_name']?.toString() ?? json['category']?.toString() ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
      isOpen: json['is_open'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isOpen': isOpen,
      'tags': tags,
    };
  }
}