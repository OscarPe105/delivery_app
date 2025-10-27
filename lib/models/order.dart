enum OrderStatus { pending, inProgress, delivered, cancelled }

// Helper function to safely convert string/dynamic to double
double _safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']?.toString() ?? json['productId']?.toString() ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      price: _safeToDouble(json['price']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
    };
  }
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

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      customerId: json['customer']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      products: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
      total: _safeToDouble(json['total']),
      status: _parseOrderStatus(json['status']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      deliveryAddress: json['delivery_address']?.toString() ?? '',
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    if (status == null) return OrderStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}