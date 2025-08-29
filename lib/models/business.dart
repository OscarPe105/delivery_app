class Business {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String address;
  final String phone;
  final double rating;
  final List<String> specialties;
  final bool isLocal;
  final String ownerName;
  final String story;
  final String deliveryTime;
  final double deliveryFee;
  
  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.address,
    required this.phone,
    this.rating = 0.0,
    this.specialties = const [],
    this.isLocal = true,
    required this.ownerName,
    required this.story,
    this.deliveryTime = '30-45 min',
    this.deliveryFee = 3000.0,
  });
  
  Business copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    String? address,
    String? phone,
    double? rating,
    List<String>? specialties,
    bool? isLocal,
    String? ownerName,
    String? story,
    String? deliveryTime,
    double? deliveryFee,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      specialties: specialties ?? this.specialties,
      isLocal: isLocal ?? this.isLocal,
      ownerName: ownerName ?? this.ownerName,
      story: story ?? this.story,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }
}