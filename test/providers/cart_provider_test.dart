import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/providers/community_store_provider.dart';
import 'package:delivery_app/models/product.dart';

void main() {
  group('Cart Provider Tests', () {
    late CommunityStoreProvider provider;
    late Product testProduct;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      provider = CommunityStoreProvider();
      testProduct = Product(
        id: 'prod1',
        name: 'Hamburguesa',
        description: 'Deliciosa hamburguesa',
        price: 15.99,
        businessId: 'business1',
        available: true,
      );
    });

    test('cart starts empty', () {
      expect(provider.cartItems.length, equals(0));
      expect(provider.cartTotal, equals(0.0));
      expect(provider.cartItemCount, equals(0));
    });

    test('addToCart adds product with quantity 1', () {
      provider.addToCart(testProduct);
      
      expect(provider.cartItems.length, equals(1));
      expect(provider.cartItems.first.productName, equals('Hamburguesa'));
      expect(provider.cartItems.first.quantity, equals(1));
    });

    test('addToCart increments quantity if product exists', () {
      provider.addToCart(testProduct);
      provider.addToCart(testProduct, quantity: 2);
      
      expect(provider.cartItems.length, equals(1)); // No duplicado
      expect(provider.cartItems.first.quantity, equals(3)); // 1 + 2
      expect(provider.cartTotal, equals(47.97)); // 15.99 * 3
    });

    test('addToCart with custom quantity', () {
      provider.addToCart(testProduct, quantity: 5);
      
      expect(provider.cartItems.first.quantity, equals(5));
      expect(provider.cartTotal, equals(79.95)); // 15.99 * 5
    });

    test('add different products creates multiple items', () {
      final product2 = Product(
        id: 'prod2',
        name: 'Pizza',
        description: 'Pizza grande',
        price: 20.0,
        businessId: 'business1',
        available: true,
      );

      provider.addToCart(testProduct);
      provider.addToCart(product2);
      
      expect(provider.cartItems.length, equals(2));
      expect(provider.cartTotal, equals(35.99)); // 15.99 + 20.0
    });

    test('removeFromCart removes item', () {
      provider.addToCart(testProduct);
      expect(provider.cartItems.length, equals(1));
      
      provider.removeFromCart(provider.cartItems.first.id);
      expect(provider.cartItems.length, equals(0));
      expect(provider.cartTotal, equals(0.0));
    });

    test('updateCartItemQuantity updates quantity correctly', () {
      provider.addToCart(testProduct);
      final itemId = provider.cartItems.first.id;
      
      provider.updateCartItemQuantity(itemId, 10);
      expect(provider.cartItems.first.quantity, equals(10));
      expect(provider.cartTotal, equals(159.90));
    });

    test('updateCartItemQuantity with 0 removes item', () {
      provider.addToCart(testProduct);
      final itemId = provider.cartItems.first.id;
      
      provider.updateCartItemQuantity(itemId, 0);
      expect(provider.cartItems.length, equals(0));
    });

    test('clearCart removes all items', () {
      provider.addToCart(testProduct);
      final product2 = Product(
        id: 'prod2',
        name: 'Taco',
        description: 'Taco',
        price: 5.0,
        businessId: 'business1',
        available: true,
      );
      provider.addToCart(product2);
      
      provider.clearCart();
      expect(provider.cartItems.length, equals(0));
      expect(provider.cartTotal, equals(0.0));
    });

    test('cartTotal calculates correctly with multiple items', () {
      provider.addToCart(testProduct, quantity: 2); // 15.99 * 2 = 31.98
      
      final product2 = Product(
        id: 'prod2',
        name: 'Pizza',
        description: 'Pizza',
        price: 25.0,
        businessId: 'business1',
        available: true,
      );
      provider.addToCart(product2, quantity: 3); // 25.0 * 3 = 75.0
      
      expect(provider.cartTotal, closeTo(106.98, 0.01));
      expect(provider.cartItemCount, equals(5)); // 2 + 3
    });
  });
}

