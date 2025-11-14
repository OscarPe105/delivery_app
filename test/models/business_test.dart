import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/models/business.dart';

void main() {
  group('Business Model Tests', () {
    test('creates business correctly with all fields', () {
      final business = Business(
        id: 'business123',
        name: 'Mi Restaurante',
        category: 'Restaurante',
        description: 'Comida deliciosa',
        address: 'Calle Principal 123',
        phone: '+504 2234-5678',
        latitude: 14.0723,
        longitude: -87.1921,
        rating: 4.5,
        imageUrl: 'https://example.com/restaurant.jpg',
        isActive: true,
        isOpen: true,
      );

      expect(business.id, equals('business123'));
      expect(business.name, equals('Mi Restaurante'));
      expect(business.latitude, equals(14.0723));
      expect(business.rating, equals(4.5));
      expect(business.isActive, isTrue);
    });

    test('creates business with nullable fields', () {
      final business = Business(
        id: 'business1',
        name: 'Negocio Test',
        category: 'Comida',
      );

      expect(business.description, isNull);
      expect(business.latitude, isNull);
      expect(business.rating, isNull);
      expect(business.isActive, isTrue); // Default
      expect(business.isOpen, isTrue); // Default
    });

    test('fromJson parses correctly', () {
      final json = {
        'id': 'business1',
        'name': 'Restaurante Ejemplo',
        'category': 'Restaurante',
        'description': 'Buen restaurante',
        'address': 'Calle Test',
        'phone': '12345678',
        'latitude': 14.0723,
        'longitude': -87.1921,
        'rating': 4.5,
        'image_url': 'https://example.com/image.jpg',
        'is_active': true,
        'is_open': true,
      };

      final business = Business.fromJson(json);

      expect(business.id, equals('business1'));
      expect(business.name, equals('Restaurante Ejemplo'));
      expect(business.latitude, equals(14.0723));
      expect(business.rating, equals(4.5));
    });

    test('toJson serializes correctly', () {
      final business = Business(
        id: 'business1',
        name: 'Mi Negocio',
        category: 'Comida',
        description: 'Descripción',
        latitude: 14.0723,
        longitude: -87.1921,
        isActive: true,
      );

      final json = business.toJson();

      expect(json['id'], equals('business1'));
      expect(json['name'], equals('Mi Negocio'));
      expect(json['latitude'], equals(14.0723));
      expect(json['isActive'], isTrue);
    });
  });
}



