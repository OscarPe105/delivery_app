class Review {
  final String id;
  final String businessId;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final int rating; // 1-5 estrellas
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String>? imageUrls; // Imágenes opcionales del review
  final String? orderId; // Opcional: ID del pedido relacionado
  final String? businessReply; // Respuesta del negocio
  final DateTime? businessReplyAt; // Fecha de respuesta del negocio

  Review({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.imageUrls,
    this.orderId,
    this.businessReply,
    this.businessReplyAt,
  });

  // Validar que el rating esté entre 1 y 5
  bool get isValidRating => rating >= 1 && rating <= 5;

  factory Review.fromJson(Map<String, dynamic> json) {
    // Convertir Timestamp de Firestore a DateTime
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is DateTime) return timestamp;
      if (timestamp is String) return DateTime.tryParse(timestamp);
      // Para Firestore Timestamp
      try {
        return timestamp.toDate();
      } catch (e) {
        return null;
      }
    }

    return Review(
      id: json['id']?.toString() ?? '',
      businessId: json['businessId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'] ?? '',
      userImageUrl: json['userImageUrl'],
      rating: json['rating'] != null 
          ? (json['rating'] is int 
              ? json['rating'] 
              : int.tryParse(json['rating'].toString()) ?? 0)
          : 0,
      comment: json['comment'],
      createdAt: parseTimestamp(json['createdAt']) ?? DateTime.now(),
      updatedAt: parseTimestamp(json['updatedAt']),
      imageUrls: json['imageUrls'] != null 
          ? List<String>.from(json['imageUrls']) 
          : null,
      orderId: json['orderId'],
      businessReply: json['businessReply'],
      businessReplyAt: parseTimestamp(json['businessReplyAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrls': imageUrls,
      'orderId': orderId,
      'businessReply': businessReply,
      'businessReplyAt': businessReplyAt?.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? businessId,
    String? userId,
    String? userName,
    String? userImageUrl,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imageUrls,
    String? orderId,
    String? businessReply,
    DateTime? businessReplyAt,
  }) {
    return Review(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrls: imageUrls ?? this.imageUrls,
      orderId: orderId ?? this.orderId,
      businessReply: businessReply ?? this.businessReply,
      businessReplyAt: businessReplyAt ?? this.businessReplyAt,
    );
  }

  @override
  String toString() {
    final commentPreview = comment != null && comment!.isNotEmpty 
        ? comment!.substring(0, comment!.length > 50 ? 50 : comment!.length)
        : '';
    return 'Review(id: $id, businessId: $businessId, rating: $rating, comment: $commentPreview...)';
  }
}

// Clase helper para calcular estadísticas de reviews
class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {rating: count}

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStatistics.fromReviews(List<Review> reviews) {
    if (reviews.isEmpty) {
      return ReviewStatistics(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {},
      );
    }

    // Calcular promedio
    final totalRating = reviews.fold<double>(
      0.0,
      (sum, review) => sum + review.rating,
    );
    final averageRating = totalRating / reviews.length;

    // Distribución de ratings
    final ratingDistribution = <int, int>{};
    for (var review in reviews) {
      ratingDistribution[review.rating] = 
          (ratingDistribution[review.rating] ?? 0) + 1;
    }

    return ReviewStatistics(
      averageRating: averageRating,
      totalReviews: reviews.length,
      ratingDistribution: ratingDistribution,
    );
  }

  // Porcentaje de reviews con cada rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  @override
  String toString() {
    return 'ReviewStatistics(average: $averageRating, total: $totalReviews)';
  }
}

