class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
