class Address {
  final String id;
  final String title;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final String? instructions;
  final bool isDefault;
  final DateTime createdAt;
  
  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.instructions,
    this.isDefault = false,
    required this.createdAt,
  });
  
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      fullAddress: json['fullAddress'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      instructions: json['instructions'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'instructions': instructions,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  Address copyWith({
    String? id,
    String? title,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? instructions,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      instructions: instructions ?? this.instructions,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}