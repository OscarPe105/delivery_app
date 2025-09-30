import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_store_provider.dart';
import '../models/business.dart';
import '../models/product.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Business business;
  
  const BusinessDetailScreen({super.key, required this.business});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
        backgroundColor: const Color(0xFFE8B86D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del negocio
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(business.imageUrl ?? 'https://via.placeholder.com/400x250?text=Sin+Imagen'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Información del negocio
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    business.description ?? 'Sin descripción disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating y información
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        business.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          business.address ?? 'Dirección no disponible',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Productos
                  const Text(
                    'Nuestros Productos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Consumer<CommunityStoreProvider>(
                    builder: (context, provider, child) {
                      final products = provider.getProductsByBusiness(business.id);
                      
                      if (products.isEmpty) {
                        return const Center(
                          child: Text(
                            'No hay productos disponibles',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductCard(context, product, provider);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductCard(BuildContext context, Product product, CommunityStoreProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE8B86D),
                    ),
                  ),
                ],
              ),
            ),
            
            // Botón agregar al carrito
            ElevatedButton(
              onPressed: () {
                provider.addToCart(product, quantity: 1); // Cambiar de (product, 1) a (product, quantity: 1)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} agregado al carrito'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8B86D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}