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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      rating: json['rating']?.toDouble(),
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      isOpen: json['isOpen'] ?? true,
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