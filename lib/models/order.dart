enum OrderStatus { pending, inProgress, delivered, cancelled }

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  
  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class Order {
  final String id;
  final String customerId;
  final String customerName;
  final List<OrderItem> products;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String deliveryAddress;
  
  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.products,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
  });
  
  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    List<OrderItem>? products,
    double? total,
    OrderStatus? status,
    DateTime? createdAt,
    String? deliveryAddress,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      products: products ?? this.products,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }
}