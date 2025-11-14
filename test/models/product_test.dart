import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('creates product correctly with all fields', () {
      final product = Product(
        id: 'prod123',
        name: 'Hamburguesa Especial',
        description: 'Hamburguesa con queso y papas',
        price: 18.50,
        businessId: 'business456',
        available: true,
        isPopular: true,
        imageUrl: 'https://example.com/burger.jpg',
      );

      expect(product.id, equals('prod123'));
      expect(product.name, equals('Hamburguesa Especial'));
      expect(product.price, equals(18.50));
      expect(product.available, isTrue);
      expect(product.isPopular, isTrue);
    });

    test('creates product with default values', () {
      final product = Product(
        id: 'prod1',
        name: 'Producto Test',
        description: 'Descripción',
        price: 10.0,
        businessId: 'business1',
      );

      expect(product.available, isTrue); // Default
      expect(product.isPopular, isFalse); // Default
      expect(product.imageUrl, isNull); // Default
    });

    test('copyWith works correctly', () {
      final original = Product(
        id: 'prod1',
        name: 'Pizza',
        description: 'Pizza mediana',
        price: 20.0,
        businessId: 'business1',
      );

      final updated = original.copyWith(
        price: 25.0,
        available: false,
      );

      expect(updated.price, equals(25.0));
      expect(updated.available, isFalse);
      expect(updated.name, equals('Pizza')); // No cambió
      expect(updated.id, equals('prod1')); // No cambió
    });
  });
}



