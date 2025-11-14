class Message {
  final String id;
  final String conversationId; // ID único de la conversación
  final String senderId; // ID del remitente
  final String senderName; // Nombre del remitente
  final String? senderImageUrl; // Avatar del remitente
  final String recipientId; // ID del destinatario
  final String recipientName; // Nombre del destinatario
  final String content; // Contenido del mensaje
  final String messageType; // 'text', 'image', 'system'
  final String? imageUrl; // URL si es imagen
  final DateTime timestamp; // Fecha/hora del mensaje
  final bool isRead; // Si fue leído
  final DateTime? readAt; // Cuándo fue leído

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.recipientId,
    required this.recipientName,
    required this.content,
    this.messageType = 'text',
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
  });

  // Validar que el tipo de mensaje sea válido
  bool get isValidType => ['text', 'image', 'system'].contains(messageType);

  factory Message.fromJson(Map<String, dynamic> json) {
    // Convertir Timestamp de Firestore a DateTime
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is DateTime) return timestamp;
      if (timestamp is String) return DateTime.tryParse(timestamp);
      // Para Firestore Timestamp
      try {
        return timestamp.toDate();
      } catch (e) {
        return null;
      }
    }

    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? '',
      senderImageUrl: json['senderImageUrl'],
      recipientId: json['recipientId']?.toString() ?? '',
      recipientName: json['recipientName'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      imageUrl: json['imageUrl'],
      timestamp: parseTimestamp(json['timestamp']) ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      readAt: parseTimestamp(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'content': content,
      'messageType': messageType,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderImageUrl,
    String? recipientId,
    String? recipientName,
    String? content,
    String? messageType,
    String? imageUrl,
    DateTime? timestamp,
    bool? isRead,
    DateTime? readAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImageUrl: senderImageUrl ?? this.senderImageUrl,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  String toString() {
    final contentPreview = content.length > 30 
        ? '${content.substring(0, 30)}...' 
        : content;
    return 'Message(id: $id, from: $senderName, to: $recipientName, content: $contentPreview, type: $messageType)';
  }
}

// Clase helper para representar una conversación
class Conversation {
  final String id;
  final String participant1Id; // Usuario 1
  final String participant1Name;
  final String? participant1ImageUrl;
  final String? participant1Role;
  final String participant2Id; // Usuario 2
  final String participant2Name;
  final String? participant2ImageUrl;
  final String? participant2Role;
  final Message? lastMessage; // Último mensaje
  final int unreadCount; // Cantidad de mensajes no leídos
  final DateTime updatedAt; // Última actualización

  Conversation({
    required this.id,
    required this.participant1Id,
    required this.participant1Name,
    this.participant1ImageUrl,
    this.participant1Role,
    required this.participant2Id,
    required this.participant2Name,
    this.participant2ImageUrl,
    this.participant2Role,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  // Obtener información del otro participante basado en mi ID
  Map<String, dynamic> getOtherParticipant(String myId) {
    if (participant1Id == myId) {
      final displayName = _composeDisplayName(participant2Name, participant2Role);
      return {
        'id': participant2Id,
        'name': displayName,
        'imageUrl': participant2ImageUrl,
        'role': participant2Role,
      };
    } else {
      final displayName = _composeDisplayName(participant1Name, participant1Role);
      return {
        'id': participant1Id,
        'name': displayName,
        'imageUrl': participant1ImageUrl,
        'role': participant1Role,
      };
    }
  }

  String _composeDisplayName(String name, String? role) {
    final trimmedName = name.trim();
    final trimmedRole = role?.trim() ?? '';
    final hasName = trimmedName.isNotEmpty;
    final hasRole = trimmedRole.isNotEmpty;
    if (hasName && hasRole) {
      return '$trimmedName ($trimmedRole)';
    }
    if (hasName) {
      return trimmedName;
    }
    if (hasRole) {
      return trimmedRole;
    }
    return 'Usuario';
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return null;
      if (timestamp is DateTime) return timestamp;
      if (timestamp is String) return DateTime.tryParse(timestamp);
      try {
        return timestamp.toDate();
      } catch (e) {
        return null;
      }
    }

    return Conversation(
      id: json['id']?.toString() ?? '',
      participant1Id: json['participant1Id']?.toString() ?? '',
      participant1Name: json['participant1Name'] ?? '',
      participant1ImageUrl: json['participant1ImageUrl'],
      participant1Role: json['participant1Role']?.toString(),
      participant2Id: json['participant2Id']?.toString() ?? '',
      participant2Name: json['participant2Name'] ?? '',
      participant2ImageUrl: json['participant2ImageUrl'],
      participant2Role: json['participant2Role']?.toString(),
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: parseTimestamp(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant1Id': participant1Id,
      'participant1Name': participant1Name,
      'participant1ImageUrl': participant1ImageUrl,
      'participant1Role': participant1Role,
      'participant2Id': participant2Id,
      'participant2Name': participant2Name,
      'participant2ImageUrl': participant2ImageUrl,
      'participant2Role': participant2Role,
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participants: $participant1Name <-> $participant2Name)';
  }
}

// Helper para generar IDs de conversación consistentes
class ConversationHelper {
  // Generar ID de conversación basado en dos usuarios
  // Siempre genera el mismo ID sin importar el orden
  static String generateConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return 'conv_${sortedIds[0]}_${sortedIds[1]}';
  }

  // Verificar si dos IDs generan la misma conversación
  static bool isSameConversation(String userId1, String userId2, String conversationId) {
    return generateConversationId(userId1, userId2) == conversationId;
  }
}


