import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/models/cart_item.dart';

void main() {
  group('CartItem Tests', () {
    test('calculate total correctly', () {
      final cartItem = CartItem(
        id: '1',
        productId: 'prod1',
        productName: 'Hamburguesa',
        price: 15.99,
        quantity: 2,
        businessId: 'business1',
        businessName: 'Mi Restaurant',
      );

      expect(cartItem.total, equals(31.98)); // 15.99 * 2
    });

    test('copyWith creates new instance with updated values', () {
      final original = CartItem(
        id: '1',
        productId: 'prod1',
        productName: 'Pizza',
        price: 20.0,
        quantity: 1,
        businessId: 'business1',
        businessName: 'Pizzeria',
      );

      final updated = original.copyWith(quantity: 3);

      expect(updated.quantity, equals(3));
      expect(updated.total, equals(60.0)); // 20.0 * 3
      expect(updated.id, equals('1')); // ID no cambió
    });

    test('toJson and fromJson work correctly', () {
      final cartItem = CartItem(
        id: '123',
        productId: 'prod456',
        productName: 'Taco',
        price: 10.50,
        quantity: 5,
        imageUrl: 'https://example.com/taco.jpg',
        businessId: 'business789',
        businessName: 'Taqueria',
      );

      final json = cartItem.toJson();
      expect(json['id'], equals('123'));
      expect(json['price'], equals(10.50));
      expect(json['quantity'], equals(5));

      final restored = CartItem.fromJson(json);
      expect(restored.id, equals('123'));
      expect(restored.productName, equals('Taco'));
      expect(restored.total, equals(52.5)); // 10.50 * 5
    });
  });
}

