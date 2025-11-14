import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/message.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener o crear conversación entre dos usuarios
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userId2,
    required String user1Name,
    required String user2Name,
    String? user1Role,
    String? user2Role,
    String? user1ImageUrl,
    String? user2ImageUrl,
  }) async {
    try {
      final conversationId = ConversationHelper.generateConversationId(userId1, userId2);
      
      // Verificar si la conversación ya existe
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();

      if (conversationDoc.exists) {
        final data = conversationDoc.data();
        final Map<String, dynamic> updates = {};

        if (user1Role != null && user1Role.isNotEmpty && (data?['participant1Role'] ?? '').toString().isEmpty) {
          updates['participant1Role'] = user1Role;
        }
        if (user2Role != null && user2Role.isNotEmpty && (data?['participant2Role'] ?? '').toString().isEmpty) {
          updates['participant2Role'] = user2Role;
        }

        if (updates.isNotEmpty) {
          await _firestore.collection('conversations').doc(conversationId).update(updates);
        }

        return conversationId;
      }

      // Crear nueva conversación
      await _firestore.collection('conversations').doc(conversationId).set({
        'participant1Id': userId1,
        'participant1Name': user1Name,
        'participant1ImageUrl': user1ImageUrl,
        if (user1Role != null) 'participant1Role': user1Role,
        'participant2Id': userId2,
        'participant2Name': user2Name,
        'participant2ImageUrl': user2ImageUrl,
        if (user2Role != null) 'participant2Role': user2Role,
        'unreadCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Conversation created: $conversationId');
      return conversationId;
    } catch (e) {
      debugPrint('❌ Error creating conversation: $e');
      rethrow;
    }
  }

  // Enviar un mensaje
  Future<Message> sendMessage({
    required String conversationId,
    required String recipientId,
    required String content,
    String messageType = 'text',
    String? imageUrl,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener información del remitente
      final senderDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final senderData = senderDoc.data();
      final senderName = senderData?['name'] ?? currentUser.displayName ?? 'Usuario';
      final senderImageUrl = senderData?['profileImage'];

      // Obtener información del destinatario
      // Primero intentar como usuario, si no existe, buscar como negocio
      var recipientDoc = await _firestore.collection('users').doc(recipientId).get();
      var recipientData = recipientDoc.data();
      var recipientName = recipientData?['name'] ?? 'Usuario';
      
      // Si no se encontró como usuario, buscar como negocio
      if (!recipientDoc.exists) {
        recipientDoc = await _firestore.collection('businesses').doc(recipientId).get();
        recipientData = recipientDoc.data();
        recipientName = recipientData?['name'] ?? 'Negocio';
      }

      // Crear mensaje
      final messageData = {
        'conversationId': conversationId,
        'senderId': currentUser.uid,
        'senderName': senderName,
        'senderImageUrl': senderImageUrl,
        'recipientId': recipientId,
        'recipientName': recipientName,
        'content': content,
        'messageType': messageType,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      final messageRef = await _firestore.collection('messages').add(messageData);

      // Actualizar conversación
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': messageData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Incrementar contador de no leídos para el destinatario
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      
      if (conversationDoc.exists) {
        final data = conversationDoc.data()!;
        final participant1Id = data['participant1Id'];
        final participant2Id = data['participant2Id'];
        final participant1Unread = data['participant1Unread'] ?? 0;
        final participant2Unread = data['participant2Unread'] ?? 0;

        if (recipientId == participant1Id) {
          await _firestore.collection('conversations').doc(conversationId).update({
            'participant1Unread': participant1Unread + 1,
          });
        } else if (recipientId == participant2Id) {
          await _firestore.collection('conversations').doc(conversationId).update({
            'participant2Unread': participant2Unread + 1,
          });
        }
      }

      final message = Message.fromJson({
        'id': messageRef.id,
        ...messageData,
        'timestamp': DateTime.now(),
      });

      debugPrint('✅ Message sent: ${messageRef.id}');
      return message;
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      rethrow;
    }
  }

  // Obtener mensajes de una conversación (stream en tiempo real)
  Stream<List<Message>> getMessages(String conversationId) {
    if (conversationId.isEmpty) {
      // Si aún no existe conversación, no hay mensajes que escuchar
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return Message.fromJson({
            'id': doc.id,
            ...data,
          });
        }).toList();

        // Ordenar manualmente por timestamp descendente (último mensaje primero)
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return messages;
      });
    } catch (e) {
      debugPrint('❌ Error getting messages: $e');
      return Stream.value([]);
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String conversationId, String currentUserId) async {
    if (conversationId.isEmpty) {
      // No hay conversación válida todavía
      return;
    }

    try {
      final batch = _firestore.batch();
      
      // Obtener mensajes no leídos
      final unreadMessages = await _firestore
          .collection('messages')
          .where('conversationId', isEqualTo: conversationId)
          .where('recipientId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Actualizar contador de conversación
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      
      if (conversationDoc.exists) {
        final data = conversationDoc.data()!;
        final participant1Id = data['participant1Id'];
        final participant2Id = data['participant2Id'];

        if (currentUserId == participant1Id) {
          await _firestore.collection('conversations').doc(conversationId).update({
            'participant1Unread': 0,
          });
        } else if (currentUserId == participant2Id) {
          await _firestore.collection('conversations').doc(conversationId).update({
            'participant2Unread': 0,
          });
        }
      }

      debugPrint('✅ Messages marked as read for conversation: $conversationId');
    } catch (e) {
      debugPrint('❌ Error marking messages as read: $e');
    }
  }

  // Obtener conversaciones del usuario actual (stream en tiempo real)
  // Usa dos consultas separadas para evitar índices compuestos
  Stream<List<Conversation>> getUserConversations(String userId) {
    try {
      // Stream 1: Conversaciones donde el usuario es participant1
      // Sin orderBy para evitar índices compuestos - ordenamos manualmente después
      final stream1 = _firestore
          .collection('conversations')
          .where('participant1Id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Conversation.fromJson({
            'id': doc.id,
            ...data,
            'unreadCount': data['participant1Unread'] ?? 0,
          });
        }).toList();
      });

      // Stream 2: Conversaciones donde el usuario es participant2
      // Sin orderBy para evitar índices compuestos - ordenamos manualmente después
      final stream2 = _firestore
          .collection('conversations')
          .where('participant2Id', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Conversation.fromJson({
            'id': doc.id,
            ...data,
            'unreadCount': data['participant2Unread'] ?? 0,
          });
        }).toList();
      });

      // Combinar ambos streams usando StreamController
      final controller = StreamController<List<Conversation>>();
      final Map<String, Conversation> conversationsMap = {};
      StreamSubscription<List<Conversation>>? subscription1;
      StreamSubscription<List<Conversation>>? subscription2;

      void emitCombined() {
        final combined = conversationsMap.values.toList();
        combined.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        controller.add(combined);
      }

      subscription1 = stream1.listen(
        (conversations1) {
          for (var conv in conversations1) {
            conversationsMap[conv.id] = conv;
          }
          emitCombined();
        },
        onError: (error) {
          debugPrint('❌ Error en stream1: $error');
          controller.addError(error);
        },
      );

      subscription2 = stream2.listen(
        (conversations2) {
          for (var conv in conversations2) {
            conversationsMap[conv.id] = conv;
          }
          emitCombined();
        },
        onError: (error) {
          debugPrint('❌ Error en stream2: $error');
          controller.addError(error);
        },
      );

      // Limpiar recursos cuando el stream se cancele
      controller.onCancel = () {
        subscription1?.cancel();
        subscription2?.cancel();
      };

      return controller.stream;
    } catch (e) {
      debugPrint('❌ Error getting conversations: $e');
      return Stream.value([]);
    }
  }

  // Obtener información de un usuario
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user info: $e');
      return null;
    }
  }

  // Enviar mensaje de sistema
  Future<void> sendSystemMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('messages').add({
        'conversationId': conversationId,
        'senderId': 'system',
        'senderName': 'Sistema',
        'recipientId': 'system',
        'recipientName': 'Sistema',
        'content': content,
        'messageType': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': true,
      });

      debugPrint('✅ System message sent');
    } catch (e) {
      debugPrint('❌ Error sending system message: $e');
    }
  }

  // Eliminar mensaje
  Future<bool> deleteMessage(String messageId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Verificar que el usuario es el remitente
      final messageDoc = await _firestore.collection('messages').doc(messageId).get();
      if (!messageDoc.exists) return false;

      final messageData = messageDoc.data()!;
      if (messageData['senderId'] != currentUser.uid) return false;

      // Eliminar mensaje
      await _firestore.collection('messages').doc(messageId).delete();

      debugPrint('✅ Message deleted: $messageId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      return false;
    }
  }
}


