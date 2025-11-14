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
  final String? ownerId; // ID del dueño del negocio

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
    this.ownerId,
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
      ownerId: json['ownerId']?.toString() ??
          json['ownerUid']?.toString() ??
          json['owner_uid']?.toString() ??
          json['owner']?.toString(),
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
      'ownerId': ownerId,
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? address,
    String? phone,
    double? latitude,
    double? longitude,
    double? rating,
    String? imageUrl,
    bool? isActive,
    bool? isOpen,
    List<String>? tags,
    String? ownerId,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isOpen: isOpen ?? this.isOpen,
      tags: tags ?? this.tags,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
