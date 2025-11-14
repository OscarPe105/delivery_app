import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/providers/community_store_provider.dart';

// Este test requiere acceso a métodos públicos del provider
// y simulación de datos para probar los filtros
// Por ahora, se omite ya que requiere mocking complejo

void main() {
  group('Filter Tests', () {
    test('provider initialized correctly', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      
      // Verificar valores iniciales
      expect(provider.selectedCategory, equals('all'));
      expect(provider.searchQuery, equals(''));
      expect(provider.businesses.length, equals(0));
      expect(provider.products.length, equals(0));
    });

    test('setSearchQuery updates query', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      provider.setSearchQuery('pizza');
      expect(provider.searchQuery, equals('pizza'));
    });

    test('setCategory updates category', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      provider.setCategory('Restaurante');
      expect(provider.selectedCategory, equals('Restaurante'));
    });

    test('setPriceRange updates range', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      provider.setPriceRange(10.0, 50.0);
      expect(provider.minPrice, equals(10.0));
      expect(provider.maxPrice, equals(50.0));
    });

    test('toggleAvailableOnly toggles state', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      expect(provider.showOnlyAvailable, isFalse);
      provider.toggleAvailableOnly();
      expect(provider.showOnlyAvailable, isTrue);
      provider.toggleAvailableOnly();
      expect(provider.showOnlyAvailable, isFalse);
    });

    test('togglePopularOnly toggles state', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      expect(provider.showOnlyPopular, isFalse);
      provider.togglePopularOnly();
      expect(provider.showOnlyPopular, isTrue);
      provider.togglePopularOnly();
      expect(provider.showOnlyPopular, isFalse);
    });

    test('clearFilters resets all filters', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final provider = CommunityStoreProvider();
      
      // Establecer algunos filtros
      provider.setSearchQuery('test');
      provider.setCategory('Restaurante');
      provider.setPriceRange(20.0, 50.0);
      provider.toggleAvailableOnly();
      
      // Limpiar
      provider.clearFilters();
      
      expect(provider.searchQuery, equals(''));
      expect(provider.selectedCategory, equals('all'));
      expect(provider.minPrice, equals(0));
      expect(provider.maxPrice, equals(1000));
      expect(provider.showOnlyAvailable, isFalse);
      expect(provider.showOnlyPopular, isFalse);
    });
  });
}

