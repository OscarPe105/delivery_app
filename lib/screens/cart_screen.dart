import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart';
import '../models/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunityStoreProvider>(context);
    final cartItems = provider.cartItems;
    final cartTotal = provider.cartTotal;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                _showClearCartDialog(context, provider);
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartList(context, cartItems, provider),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildCheckoutBar(context, cartTotal),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos de los negocios locales',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
    BuildContext context, 
    List<CartItem> cartItems,
    CommunityStoreProvider provider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];
        return _buildCartItem(context, cartItem, provider);
      },
    );
  }

  // Corregir la definición de _buildCartItem para aceptar provider
  Widget _buildCartItem(
    BuildContext context, 
    CartItem cartItem,
    CommunityStoreProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Negocio: ${cartItem.businessName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${cartItem.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: () {
                              if (cartItem.quantity > 1) {
                                provider.updateCartItemQuantity(
                                  cartItem.id,
                                  cartItem.quantity - 1,
                                );
                              } else {
                                provider.removeFromCart(cartItem.id);
                              }
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: () {
                              provider.updateCartItemQuantity(
                                cartItem.id, 
                                cartItem.quantity + 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Implementar checkout
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Proceder al Pago',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CommunityStoreProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar tu carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.of(context).pop();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}