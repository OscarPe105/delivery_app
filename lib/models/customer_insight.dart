class CustomerInsight {
  CustomerInsight({
    required this.customerId,
    required this.name,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpent,
    required this.cancellationRate,
    required this.loyaltyLevel,
    this.email,
    this.profileImage,
    this.lastOrderAt,
  });

  final String customerId;
  final String name;
  final int completedOrders;
  final int cancelledOrders;
  final double totalSpent;
  final double cancellationRate;
  final String loyaltyLevel;
  final String? email;
  final String? profileImage;
  final DateTime? lastOrderAt;

  int get totalOrders => completedOrders + cancelledOrders;

  bool get isExcellentClient => loyaltyLevel == 'Excelente cliente' || loyaltyLevel == 'Cliente VIP';

  CustomerInsight copyWith({
    String? name,
    int? completedOrders,
    int? cancelledOrders,
    double? totalSpent,
    double? cancellationRate,
    String? loyaltyLevel,
    String? email,
    String? profileImage,
    DateTime? lastOrderAt,
  }) {
    return CustomerInsight(
      customerId: customerId,
      name: name ?? this.name,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      lastOrderAt: lastOrderAt ?? this.lastOrderAt,
    );
  }
}
