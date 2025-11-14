import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/models/message.dart';

void main() {
  group('Message Model Tests', () {
    test('creates message correctly with all fields', () {
      final message = Message(
        id: 'msg123',
        conversationId: 'conv456',
        senderId: 'user789',
        senderName: 'Juan Pérez',
        senderImageUrl: 'https://example.com/user.jpg',
        recipientId: 'user101',
        recipientName: 'María García',
        content: 'Hola, cómo estás?',
        messageType: 'text',
        timestamp: DateTime(2025, 1, 31, 12, 0, 0),
        isRead: false,
      );

      expect(message.id, equals('msg123'));
      expect(message.conversationId, equals('conv456'));
      expect(message.senderId, equals('user789'));
      expect(message.content, equals('Hola, cómo estás?'));
      expect(message.isValidType, isTrue);
    });

    test('creates message with minimal required fields', () {
      final message = Message(
        id: 'msg1',
        conversationId: 'conv1',
        senderId: 'user1',
        senderName: 'Sender',
        recipientId: 'user2',
        recipientName: 'Recipient',
        content: 'Test message',
        timestamp: DateTime.now(),
      );

      expect(message.content, equals('Test message'));
      expect(message.messageType, equals('text'));
      expect(message.isRead, isFalse);
      expect(message.senderImageUrl, isNull);
    });

    test('validates message type correctly', () {
      final validTextMessage = Message(
        id: '1', conversationId: 'c1', senderId: 's1',
        senderName: 'S', recipientId: 'r1',
        recipientName: 'R', content: 'Test',
        messageType: 'text',
        timestamp: DateTime.now(),
      );
      expect(validTextMessage.isValidType, isTrue);

      final validImageMessage = Message(
        id: '2', conversationId: 'c1', senderId: 's1',
        senderName: 'S', recipientId: 'r1',
        recipientName: 'R', content: 'Test',
        messageType: 'image',
        timestamp: DateTime.now(),
      );
      expect(validImageMessage.isValidType, isTrue);

      final validSystemMessage = Message(
        id: '3', conversationId: 'c1', senderId: 's1',
        senderName: 'S', recipientId: 'r1',
        recipientName: 'R', content: 'Test',
        messageType: 'system',
        timestamp: DateTime.now(),
      );
      expect(validSystemMessage.isValidType, isTrue);

      final invalidMessage = Message(
        id: '4', conversationId: 'c1', senderId: 's1',
        senderName: 'S', recipientId: 'r1',
        recipientName: 'R', content: 'Test',
        messageType: 'invalid',
        timestamp: DateTime.now(),
      );
      expect(invalidMessage.isValidType, isFalse);
    });

    test('copyWith creates new instance with updated values', () {
      final original = Message(
        id: '1',
        conversationId: 'c1',
        senderId: 's1',
        senderName: 'Sender',
        recipientId: 'r1',
        recipientName: 'Recipient',
        content: 'Original',
        timestamp: DateTime.now(),
        isRead: false,
      );

      final updated = original.copyWith(
        content: 'Updated',
        isRead: true,
      );

      expect(updated.content, equals('Updated'));
      expect(updated.isRead, isTrue);
      expect(updated.id, equals('1'));
    });

    test('toJson and fromJson work correctly', () {
      final message = Message(
        id: 'msg123',
        conversationId: 'conv456',
        senderId: 'user789',
        senderName: 'Sender',
        recipientId: 'user101',
        recipientName: 'Recipient',
        content: 'Test message',
        timestamp: DateTime(2025, 1, 31, 12, 0, 0),
        isRead: true,
        readAt: DateTime(2025, 1, 31, 12, 5, 0),
      );

      final json = message.toJson();
      expect(json['id'], equals('msg123'));
      expect(json['content'], equals('Test message'));
      expect(json['messageType'], equals('text'));

      final restored = Message.fromJson(json);
      expect(restored.id, equals('msg123'));
      expect(restored.content, equals('Test message'));
      expect(restored.isRead, isTrue);
    });
  });

  group('Conversation Model Tests', () {
    test('creates conversation correctly', () {
      final lastMessage = Message(
        id: 'msg1', conversationId: 'conv1',
        senderId: 's1', senderName: 'Sender',
        recipientId: 'r1', recipientName: 'Recipient',
        content: 'Last message',
        timestamp: DateTime.now(),
      );

      final conversation = Conversation(
        id: 'conv123',
        participant1Id: 'user1',
        participant1Name: 'User One',
        participant2Id: 'user2',
        participant2Name: 'User Two',
        lastMessage: lastMessage,
        unreadCount: 3,
        updatedAt: DateTime.now(),
      );

      expect(conversation.id, equals('conv123'));
      expect(conversation.unreadCount, equals(3));
      expect(conversation.lastMessage, isNotNull);
    });

    test('getOtherParticipant returns correct info', () {
      final conversation = Conversation(
        id: 'conv1',
        participant1Id: 'user1',
        participant1Name: 'User One',
        participant2Id: 'user2',
        participant2Name: 'User Two',
        updatedAt: DateTime.now(),
      );

      final other1 = conversation.getOtherParticipant('user1');
      expect(other1['id'], equals('user2'));
      expect(other1['name'], equals('User Two'));

      final other2 = conversation.getOtherParticipant('user2');
      expect(other2['id'], equals('user1'));
      expect(other2['name'], equals('User One'));
    });
  });

  group('ConversationHelper Tests', () {
    test('generates consistent conversation ID', () {
      final id1 = ConversationHelper.generateConversationId('user1', 'user2');
      final id2 = ConversationHelper.generateConversationId('user2', 'user1');

      expect(id1, equals(id2));
      expect(id1, equals('conv_user1_user2'));
    });

    test('verifies same conversation correctly', () {
      const conversationId = 'conv_user1_user2';
      
      final isSame1 = ConversationHelper.isSameConversation(
        'user1', 'user2', conversationId
      );
      expect(isSame1, isTrue);

      final isSame2 = ConversationHelper.isSameConversation(
        'user2', 'user1', conversationId
      );
      expect(isSame2, isTrue);

      final isDifferent = ConversationHelper.isSameConversation(
        'user1', 'user3', conversationId
      );
      expect(isDifferent, isFalse);
    });
  });
}


