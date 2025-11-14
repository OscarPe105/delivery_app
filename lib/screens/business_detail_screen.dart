import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/community_store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/business.dart';
import '../models/product.dart';
import '../models/promotion.dart';
import '../themes/app_colors.dart';
import '../widgets/optimized_image.dart';
import '../widgets/business_map_widget.dart';
import '../services/chat_service.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Business business;
  final String? initialProductId;
  
  const BusinessDetailScreen({super.key, required this.business, this.initialProductId});
  
  String _formatCurrency(double value) => '${String.fromCharCode(36)}${value.toStringAsFixed(2)}';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final currentUser = authProvider.user;
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              if (currentUser == null) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión para enviar mensajes.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              String? recipientId = business.ownerId;
              
              // Si el ownerId parece ser un ID numérico legado (no Firebase UID),
              // necesitamos buscar el Firebase UID correspondiente
              if (recipientId != null && recipientId.isNotEmpty) {
                // Verificar si es un ID numérico (probablemente legado)
                // Los Firebase UIDs son strings alfanuméricos largos, no números simples
                final isNumericId = int.tryParse(recipientId) != null && recipientId.length < 10;
                
                if (isNumericId) {
                  // Es un ID numérico legado, buscar el Firebase UID en Firestore
                  try {
                    // Buscar usuarios en Firestore que tengan este ID legado
                    // Primero intentar buscar directamente por el ID en el documento
                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(recipientId)
                        .get();
                    
                    if (userDoc.exists) {
                      // El documento existe con ese ID, usarlo
                      recipientId = userDoc.id;
                    } else {
                      // Buscar en la colección de usuarios por el campo django_id o similar
                      final usersQuery = await FirebaseFirestore.instance
                          .collection('users')
                          .where('django_id', isEqualTo: int.parse(recipientId))
                          .limit(1)
                          .get();
                      
                      if (usersQuery.docs.isNotEmpty) {
                        recipientId = usersQuery.docs.first.id;
                      } else {
                        // Si no encontramos, intentar buscar el negocio en Firestore
                        final businessDoc = await FirebaseFirestore.instance
                            .collection('businesses')
                            .where('django_id', isEqualTo: business.id)
                            .limit(1)
                            .get();
                        
                        if (businessDoc.docs.isNotEmpty) {
                          final data = businessDoc.docs.first.data();
                          recipientId = data['ownerId']?.toString();
                        }
                      }
                    }
                  } catch (e) {
                    debugPrint('Error buscando Firebase UID para ownerId: $e');
                  }
                }
              }
              
              // Si aún no hay ownerId, intentar buscarlo en Firestore por nombre
              if (recipientId == null || recipientId.isEmpty) {
                try {
                  final businessDoc = await FirebaseFirestore.instance
                      .collection('businesses')
                      .doc(business.id)
                      .get();
                  
                  if (businessDoc.exists) {
                    final data = businessDoc.data();
                    recipientId = data?['ownerId']?.toString();
                  }
                  
                  // Si aún no encontramos, buscar por nombre
                  if (recipientId == null || recipientId.isEmpty) {
                    final businessesQuery = await FirebaseFirestore.instance
                        .collection('businesses')
                        .where('name', isEqualTo: business.name)
                        .limit(1)
                        .get();
                    
                    if (businessesQuery.docs.isNotEmpty) {
                      final data = businessesQuery.docs.first.data();
                      recipientId = data['ownerId']?.toString();
                    }
                  }
                } catch (e) {
                  debugPrint('Error buscando ownerId en Firestore: $e');
                }
              }
              
              // Si encontramos un ownerId válido (Firebase UID), usar. Si no, mostrar error
              if (recipientId != null && recipientId.isNotEmpty && recipientId.length > 10) {
                try {
                  final conversationId = await ChatService().getOrCreateConversation(
                    userId1: currentUser.id,
                    userId2: recipientId,
                    user1Name: currentUser.name,
                    user2Name: business.name,
                    user1ImageUrl: currentUser.profileImage,
                    user2ImageUrl: business.imageUrl,
                  );

                  if (!navigator.mounted) return;

                  navigator.pushNamed(
                    '/chat',
                    arguments: {
                      'conversationId': conversationId,
                      'recipientId': recipientId,
                      'recipientName': business.name,
                    },
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('No se pudo abrir el chat: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } else {
                // Si no hay ownerId válido, no podemos iniciar el chat
                if (!context.mounted) return;
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede iniciar chat: El dueño del negocio no está disponible en el sistema.\n'
                      'Por favor, contacta al negocio por teléfono o espera a que complete su registro.',
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del negocio
            SizedBox(
              height: 250,
              width: double.infinity,
              child: BusinessImage(
                imageUrl: business.imageUrl,
                width: double.infinity,
                height: 250,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
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
                  
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        business.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        business.isOpen ? 'Abierto ahora' : 'Cerrado',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (business.address != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            business.address!,
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  if (business.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.grey, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          business.phone!,
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/reviews/business',
                              arguments: {
                                'businessId': business.id,
                                'businessName': business.name,
                              },
                            );
                          },
                          icon: const Icon(Icons.reviews),
                          label: const Text('Ver Reseñas'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/reviews/create',
                              arguments: {
                                'businessId': business.id,
                                'businessName': business.name,
                              },
                            );
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Dejar Reseña'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Mapa del negocio
                  const Text(
                    'Ubicación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  BusinessMapWidget(
                    business: business,
                    height: 200,
                    showInfoWindow: true,
                    allowInteraction: true,
                    onTap: () {
                      // Navegar a vista expandida del mapa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BusinessMapExpanded(
                            business: business,
                          ),
                        ),
                      );
                    },
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
                      final products = provider
                          .getProductsByBusiness(business.id)
                          .where((product) => product.available)
                          .toList();

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
                          final promotion =
                              provider.getPromotionForProduct(product.id);
                          return _buildProductCard(
                            context,
                            product,
                            provider,
                            promotion,
                            product.id == initialProductId,
                          );
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
  
  Widget _buildProductCard(
    BuildContext context,
    Product product,
    CommunityStoreProvider provider,
    Promotion? promotion, [
    bool highlight = false,
  ]) {
    final originalPriceText = _formatCurrency(product.price);
    final promoPriceText = promotion != null && promotion.promotionalPrice != null
        ? _formatCurrency(promotion.promotionalPrice!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.primary : Colors.grey[200]!,
          width: highlight ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            imageUrl: product.imageUrl,
            size: 80,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (promotion != null)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Promo',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        provider.isProductFavorite(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: provider.isProductFavorite(product.id)
                            ? Colors.red
                            : Colors.grey[500],
                      ),
                      onPressed: () => provider.toggleProductFavorite(product.id),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (promoPriceText != null)
                      Text(
                        originalPriceText,
                        style: const TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13,
                        ),
                      ),
                    if (promoPriceText != null) const SizedBox(width: 6),
                    Text(
                      promoPriceText ?? originalPriceText,
                      style: TextStyle(
                        color: promoPriceText != null ? Colors.redAccent : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              provider.addToCart(product, quantity: 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} agregado al carrito'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

// Widget para el mapa expandido del negocio
class BusinessMapExpanded extends StatelessWidget {
  final Business business;
  
  const BusinessMapExpanded({super.key, required this.business});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${business.name} - Ubicación'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BusinessMapWidget(
        business: business,
        height: double.infinity,
        showInfoWindow: true,
        allowInteraction: true,
      ),
    );
  }
}
