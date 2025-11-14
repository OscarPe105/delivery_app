import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/models/review.dart';

void main() {
  group('Review Model Tests', () {
    test('creates review correctly with all fields', () {
      final review = Review(
        id: 'review123',
        businessId: 'business456',
        userId: 'user789',
        userName: 'Juan Pérez',
        userImageUrl: 'https://example.com/user.jpg',
        rating: 5,
        comment: 'Excelente servicio!',
        createdAt: DateTime(2025, 1, 31),
        orderId: 'order101',
        imageUrls: ['https://example.com/photo1.jpg'],
      );

      expect(review.id, equals('review123'));
      expect(review.businessId, equals('business456'));
      expect(review.rating, equals(5));
      expect(review.comment, equals('Excelente servicio!'));
      expect(review.isValidRating, isTrue);
    });

    test('creates review with minimal required fields', () {
      final review = Review(
        id: 'review1',
        businessId: 'business1',
        userId: 'user1',
        userName: 'Test User',
        rating: 4,
        createdAt: DateTime(2025, 1, 31),
      );

      expect(review.rating, equals(4));
      expect(review.isValidRating, isTrue);
      expect(review.comment, isNull);
      expect(review.userImageUrl, isNull);
    });

    test('validates rating correctly', () {
      final validReview = Review(
        id: '1',
        businessId: 'b1',
        userId: 'u1',
        userName: 'User',
        rating: 3,
        createdAt: DateTime.now(),
      );
      expect(validReview.isValidRating, isTrue);

      final invalidLowReview = Review(
        id: '2',
        businessId: 'b1',
        userId: 'u1',
        userName: 'User',
        rating: 0,
        createdAt: DateTime.now(),
      );
      expect(invalidLowReview.isValidRating, isFalse);

      final invalidHighReview = Review(
        id: '3',
        businessId: 'b1',
        userId: 'u1',
        userName: 'User',
        rating: 6,
        createdAt: DateTime.now(),
      );
      expect(invalidHighReview.isValidRating, isFalse);
    });

    test('copyWith creates new instance with updated values', () {
      final original = Review(
        id: '1',
        businessId: 'b1',
        userId: 'u1',
        userName: 'User',
        rating: 3,
        createdAt: DateTime.now(),
        comment: 'Original comment',
      );

      final updated = original.copyWith(
        rating: 5,
        comment: 'Updated comment',
      );

      expect(updated.rating, equals(5));
      expect(updated.comment, equals('Updated comment'));
      expect(updated.id, equals('1'));
      expect(updated.businessId, equals('b1'));
    });

    test('toJson and fromJson work correctly', () {
      final review = Review(
        id: 'review123',
        businessId: 'business456',
        userId: 'user789',
        userName: 'Test User',
        rating: 4,
        comment: 'Good service',
        createdAt: DateTime(2025, 1, 31, 12, 0, 0),
        updatedAt: DateTime(2025, 1, 31, 13, 0, 0),
      );

      final json = review.toJson();
      expect(json['id'], equals('review123'));
      expect(json['rating'], equals(4));
      expect(json['comment'], equals('Good service'));

      final restored = Review.fromJson(json);
      expect(restored.id, equals('review123'));
      expect(restored.rating, equals(4));
      expect(restored.comment, equals('Good service'));
    });
  });

  group('ReviewStatistics Tests', () {
    test('calculates average rating correctly', () {
      final reviews = [
        Review(
          id: '1', businessId: 'b1', userId: 'u1',
          userName: 'User 1', rating: 5,
          createdAt: DateTime.now(),
        ),
        Review(
          id: '2', businessId: 'b1', userId: 'u2',
          userName: 'User 2', rating: 4,
          createdAt: DateTime.now(),
        ),
        Review(
          id: '3', businessId: 'b1', userId: 'u3',
          userName: 'User 3', rating: 3,
          createdAt: DateTime.now(),
        ),
      ];

      final stats = ReviewStatistics.fromReviews(reviews);
      expect(stats.averageRating, equals(4.0));
      expect(stats.totalReviews, equals(3));
    });

    test('handles empty reviews list', () {
      final stats = ReviewStatistics.fromReviews([]);
      expect(stats.averageRating, equals(0.0));
      expect(stats.totalReviews, equals(0));
    });

    test('calculates rating distribution', () {
      final reviews = [
        Review(
          id: '1', businessId: 'b1', userId: 'u1',
          userName: 'User 1', rating: 5,
          createdAt: DateTime.now(),
        ),
        Review(
          id: '2', businessId: 'b1', userId: 'u2',
          userName: 'User 2', rating: 5,
          createdAt: DateTime.now(),
        ),
        Review(
          id: '3', businessId: 'b1', userId: 'u3',
          userName: 'User 3', rating: 4,
          createdAt: DateTime.now(),
        ),
      ];

      final stats = ReviewStatistics.fromReviews(reviews);
      expect(stats.ratingDistribution[5], equals(2));
      expect(stats.ratingDistribution[4], equals(1));
      expect(stats.getPercentageForRating(5), closeTo(66.67, 0.1));
    });
  });
}

