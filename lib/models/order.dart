import 'delivery.dart';
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
  final String? imageUrl;
  
  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product']?.toString() ?? json['productId']?.toString() ?? '',
      name: json['product_name'] ?? json['name'] ?? '',
      price: _safeToDouble(json['price']),
      quantity: json['quantity'] ?? 1,
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'quantity': quantity,
      if (imageUrl != null) 'image_url': imageUrl,
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
  final int? displayNumber;
  final String? paymentMethod;
  final String? driverId;
  final String? driverName;
  final DeliveryStatus? deliveryStatus;
  final DateTime? assignedAt;
  final DateTime? deliveredAt;
  
  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.products,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.deliveryAddress,
    this.displayNumber,
    this.paymentMethod,
    this.driverId,
    this.driverName,
    this.deliveryStatus,
    this.assignedAt,
    this.deliveredAt,
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
    int? displayNumber,
    String? paymentMethod,
    String? driverId,
    String? driverName,
    DeliveryStatus? deliveryStatus,
    DateTime? assignedAt,
    DateTime? deliveredAt,
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
      displayNumber: displayNumber ?? this.displayNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      assignedAt: assignedAt ?? this.assignedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
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
      displayNumber: _parseDisplayNumber(json['display_number'] ?? json['displayNumber']),
      paymentMethod: json['payment_method']?.toString() ?? json['paymentMethod']?.toString(),
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString(),
      driverName: json['driverName']?.toString() ?? json['driver_name']?.toString(),
      deliveryStatus: _parseDeliveryStatus(json['deliveryStatus']?.toString()),
      assignedAt: _parseDate(json['assignedAt']),
      deliveredAt: _parseDate(json['deliveredAt']),
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

  static int? _parseDisplayNumber(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DeliveryStatus? _parseDeliveryStatus(String? status) {
    if (status == null) return null;
    return parseDeliveryStatus(status);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
