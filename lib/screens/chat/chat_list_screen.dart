import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/chat_service.dart';
import '../../widgets/message_bubble.dart';
import '../../models/message.dart';
import '../../models/business.dart';
import '../../themes/app_colors.dart';
import '../../providers/community_store_provider.dart';
import '../community_store_screen.dart';
import '../business_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mensajes'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Debes iniciar sesión para ver tus mensajes'),
        ),
      );
    }

    final chatService = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: chatService.getUserConversations(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherParticipant = conversation.getOtherParticipant(currentUser.uid);

              return ConversationListItem(
                conversation: conversation,
                currentUserId: currentUser.uid,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'conversationId': conversation.id,
                      'recipientId': otherParticipant['id'],
                      'recipientName': otherParticipant['name'],
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartConversationDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text(
          'Nuevo Mensaje',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No tienes conversaciones',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Inicia una conversación con un negocio o usuario',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Botón para buscar negocios
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CommunityStoreScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.store),
                label: const Text('Ver Negocios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botón para iniciar conversación
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showStartConversationDialog(context),
                icon: const Icon(Icons.add_comment),
                label: const Text('Buscar para Chatear'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartConversationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _StartConversationBottomSheet(),
    );
  }

  // ignore: unused_element
  Future<void> _startChatWithBusiness(BuildContext context, Business business) async {
    debugPrint('🔍 Iniciando chat con negocio: ${business.name}');
    debugPrint('🔍 Business ID: ${business.id}');
    debugPrint('🔍 Business ownerId inicial: ${business.ownerId}');
    
    String? recipientId = business.ownerId;
    
    // Si el ownerId es un número (ID legado), necesitamos buscar el Firebase UID
    if (recipientId != null && recipientId.isNotEmpty) {
      // Verificar si es un ID numérico (ID legado)
      final isNumericId = int.tryParse(recipientId) != null;
      
      if (isNumericId) {
        debugPrint('⚠️ ownerId es numérico (ID legado), buscando Firebase UID...');
        recipientId = null; // Resetear para buscar en Firestore
      } else if (recipientId.length < 20) {
        // Firebase UIDs tienen al menos 28 caracteres, si es muy corto, probablemente es un ID legado
        debugPrint('⚠️ ownerId parece ser un ID legado, buscando Firebase UID...');
        recipientId = null;
      }
    }
    
    // Si no hay ownerId válido, buscar en Firestore
    if (recipientId == null || recipientId.isEmpty) {
      try {
        debugPrint('🔍 Buscando negocio en Firestore con ID: ${business.id}');
        
        // Intentar 1: Buscar por ID del documento
        var businessDoc = await FirebaseFirestore
            .instance
            .collection('businesses')
            .doc(business.id)
            .get();
        
        if (businessDoc.exists) {
          final data = businessDoc.data();
          recipientId = data?['ownerId']?.toString();
          debugPrint('✅ Negocio encontrado por ID, ownerId: $recipientId');
        } else {
          debugPrint('⚠️ No se encontró negocio con ID ${business.id}, buscando por nombre...');
          
          // Intentar 2: Buscar por nombre
          final businessesQuery = await FirebaseFirestore
              .instance
              .collection('businesses')
              .where('name', isEqualTo: business.name)
              .limit(1)
              .get();
          
          if (businessesQuery.docs.isNotEmpty) {
            final doc = businessesQuery.docs.first;
            final data = doc.data();
            recipientId = data['ownerId']?.toString();
            debugPrint('✅ Negocio encontrado por nombre, ownerId: $recipientId');
          } else {
            debugPrint('⚠️ No se encontró negocio por nombre: ${business.name}');
            
            // Intentar 3: Buscar por django_id si existe
            if (business.id.isNotEmpty) {
              final djangoIdQuery = await FirebaseFirestore
                  .instance
                  .collection('businesses')
                  .where('django_id', isEqualTo: business.id)
                  .limit(1)
                  .get();
              
              if (djangoIdQuery.docs.isNotEmpty) {
                final doc = djangoIdQuery.docs.first;
                final data = doc.data();
                recipientId = data['ownerId']?.toString();
                debugPrint('✅ Negocio encontrado por django_id, ownerId: $recipientId');
              }
            }
          }
        }
        
        // Si encontramos un ownerId pero es numérico, buscar el usuario en Firestore
        if (recipientId != null && int.tryParse(recipientId) != null) {
          debugPrint('⚠️ ownerId es numérico, buscando usuario en Firestore con django_id: $recipientId');
          
          final userQuery = await FirebaseFirestore
              .instance
              .collection('users')
              .where('django_id', isEqualTo: recipientId)
              .limit(1)
              .get();
          
          if (userQuery.docs.isNotEmpty) {
            recipientId = userQuery.docs.first.id; // El ID del documento es el Firebase UID
            debugPrint('✅ Usuario encontrado, Firebase UID: $recipientId');
          } else {
            debugPrint('❌ No se encontró usuario con django_id: $recipientId');
            recipientId = null;
          }
        }
        
      } catch (e) {
        debugPrint('❌ Error buscando ownerId: $e');
      }
    }
    
    // Validar que el recipientId sea un Firebase UID válido
    final isValidFirebaseUid = recipientId != null && 
                                recipientId.isNotEmpty && 
                                recipientId.length >= 20 &&
                                int.tryParse(recipientId) == null; // No debe ser numérico
    
    debugPrint('🔍 Resultado final - recipientId: $recipientId');
    debugPrint('🔍 ¿Es válido?: $isValidFirebaseUid');
    
    if (isValidFirebaseUid) {
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': '',
          'recipientId': recipientId,
          'recipientName': business.name,
        },
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se puede iniciar chat: El dueño del negocio "${business.name}" no tiene cuenta de Firebase configurada.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _StartConversationBottomSheet extends StatefulWidget {
  const _StartConversationBottomSheet();

  @override
  State<_StartConversationBottomSheet> createState() =>
      _StartConversationBottomSheetState();
}

class _StartConversationBottomSheetState
    extends State<_StartConversationBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Business> _filteredBusinesses = [];
  bool _isLoading = false;

  Future<void> _startChatWithBusinessFromSheet(BuildContext context, Business business) async {
    debugPrint('🔍 Iniciando chat con negocio: ${business.name}');
    debugPrint('🔍 Business ID: ${business.id}');
    debugPrint('🔍 Business ownerId inicial: ${business.ownerId}');
    
    String? recipientId = business.ownerId;
    
    // Si el ownerId es un número (ID legado), necesitamos buscar el Firebase UID
    if (recipientId != null && recipientId.isNotEmpty) {
      // Verificar si es un ID numérico (ID legado)
      final isNumericId = int.tryParse(recipientId) != null;
      
      if (isNumericId) {
        debugPrint('⚠️ ownerId es numérico (ID legado), buscando Firebase UID...');
        recipientId = null; // Resetear para buscar en Firestore
      } else if (recipientId.length < 20) {
        // Firebase UIDs tienen al menos 28 caracteres, si es muy corto, probablemente es un ID legado
        debugPrint('⚠️ ownerId parece ser un ID legado, buscando Firebase UID...');
        recipientId = null;
      }
    }
    
    // Si no hay ownerId válido, buscar en Firestore
    if (recipientId == null || recipientId.isEmpty) {
      try {
        debugPrint('🔍 Buscando negocio en Firestore con ID: ${business.id}');
        
        // Intentar 1: Buscar por ID del documento
        var businessDoc = await FirebaseFirestore
            .instance
            .collection('businesses')
            .doc(business.id)
            .get();
        
        if (businessDoc.exists) {
          final data = businessDoc.data();
          recipientId = data?['ownerId']?.toString();
          debugPrint('✅ Negocio encontrado por ID, ownerId: $recipientId');
        } else {
          debugPrint('⚠️ No se encontró negocio con ID ${business.id}, buscando por nombre...');
          
          // Intentar 2: Buscar por nombre
          final businessesQuery = await FirebaseFirestore
              .instance
              .collection('businesses')
              .where('name', isEqualTo: business.name)
              .limit(1)
              .get();
          
          if (businessesQuery.docs.isNotEmpty) {
            final doc = businessesQuery.docs.first;
            final data = doc.data();
            recipientId = data['ownerId']?.toString();
            debugPrint('✅ Negocio encontrado por nombre, ownerId: $recipientId');
          } else {
            debugPrint('⚠️ No se encontró negocio por nombre: ${business.name}');
            
            // Intentar 3: Buscar por django_id si existe
            if (business.id.isNotEmpty) {
              final djangoIdQuery = await FirebaseFirestore
                  .instance
                  .collection('businesses')
                  .where('django_id', isEqualTo: business.id)
                  .limit(1)
                  .get();
              
              if (djangoIdQuery.docs.isNotEmpty) {
                final doc = djangoIdQuery.docs.first;
                final data = doc.data();
                recipientId = data['ownerId']?.toString();
                debugPrint('✅ Negocio encontrado por django_id, ownerId: $recipientId');
              }
            }
          }
        }
        
        // Si encontramos un ownerId pero es numérico, buscar el usuario en Firestore
        if (recipientId != null && int.tryParse(recipientId) != null) {
          debugPrint('⚠️ ownerId es numérico, buscando usuario en Firestore con django_id: $recipientId');
          
          final userQuery = await FirebaseFirestore
              .instance
              .collection('users')
              .where('django_id', isEqualTo: recipientId)
              .limit(1)
              .get();
          
          if (userQuery.docs.isNotEmpty) {
            recipientId = userQuery.docs.first.id; // El ID del documento es el Firebase UID
            debugPrint('✅ Usuario encontrado, Firebase UID: $recipientId');
          } else {
            debugPrint('❌ No se encontró usuario con django_id: $recipientId');
            recipientId = null;
          }
        }
        
      } catch (e) {
        debugPrint('❌ Error buscando ownerId: $e');
      }
    }
    
    // Validar que el recipientId sea un Firebase UID válido
    final isValidFirebaseUid = recipientId != null && 
                                recipientId.isNotEmpty && 
                                recipientId.length >= 20 &&
                                int.tryParse(recipientId) == null; // No debe ser numérico
    
    debugPrint('🔍 Resultado final - recipientId: $recipientId');
    debugPrint('🔍 ¿Es válido?: $isValidFirebaseUid');
    
    if (isValidFirebaseUid) {
      if (!context.mounted) return;
      Navigator.pop(context);
      if (!context.mounted) return;
      Navigator.pushNamed(
        context,
        '/chat',
        arguments: {
          'conversationId': '',
          'recipientId': recipientId,
          'recipientName': business.name,
        },
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se puede iniciar chat: El dueño del negocio "${business.name}" no tiene cuenta de Firebase configurada.',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _searchController.addListener(_filterBusinesses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBusinesses() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<CommunityStoreProvider>(context, listen: false);
    await provider.loadBusinesses();
    setState(() {
      _filteredBusinesses = provider.businesses;
      _isLoading = false;
    });
  }

  void _filterBusinesses() {
    final query = _searchController.text.toLowerCase();
    final provider = Provider.of<CommunityStoreProvider>(context, listen: false);
    
    setState(() {
      if (query.isEmpty) {
        _filteredBusinesses = provider.businesses;
      } else {
        _filteredBusinesses = provider.businesses.where((business) {
          return business.name.toLowerCase().contains(query) ||
              (business.description?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Iniciar Conversación',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar negocios...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Businesses list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredBusinesses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_outlined,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No hay negocios disponibles'
                                    : 'No se encontraron negocios',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredBusinesses.length,
                          itemBuilder: (context, index) {
                            final business = _filteredBusinesses[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    business.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(
                                  business.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  business.description ?? 'Sin descripción',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      color: Colors.grey[600],
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BusinessDetailScreen(business: business),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline),
                                      color: AppColors.primary,
                                      onPressed: () => _startChatWithBusinessFromSheet(context, business),
                                    ),
                                  ],
                                ),
                                onTap: () => _startChatWithBusinessFromSheet(context, business),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}


