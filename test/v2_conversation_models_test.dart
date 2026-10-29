import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/conversation.dart';

import 'v2_fixtures.dart';

void main() {
  group('conversations.index fixture', () {
    late Paginated<ChatConversation> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('conversations.index.json'),
        ChatConversation.fromJson,
      );
    });

    test('parses the thread and unread counter', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.perPage, 20);

      final conversation = page.items.single;
      expect(conversation.id, 88);
      expect(conversation.type, 'direct');
      expect(conversation.isDirect, isTrue);
      expect(conversation.hasListing, isFalse);
      expect(conversation.isAboutListing, isFalse);
      expect(conversation.unreadCount, 2);
      expect(conversation.hasUnread, isTrue);
      expect(conversation.title, 'Sara Tesfaye');
      expect(conversation.otherParticipant?.initials, 'ST');
      expect(conversation.otherParticipant?.hasAvatar, isFalse);
      expect(conversation.lastMessage?.isMine, isTrue);
      expect(conversation.lastMessage?.isRead, isFalse);
      expect(
        conversation.lastMessageAt?.toUtc(),
        DateTime.utc(2026, 10, 29, 10, 15),
      );
    });
  });

  group('conversation.show fixture', () {
    test('parses listing context and the other side message', () {
      final conversation = ChatConversation.fromJson(
        loadV2Fixture('conversation.show.json')['data'] as Map<String, dynamic>,
      );

      expect(conversation.id, 88);
      expect(conversation.isAboutListing, isTrue);
      expect(conversation.listing?.id, 4821);
      expect(conversation.listing?.title, contains('villa'));
      expect(conversation.listing?.location.isMasked, isTrue);
      expect(conversation.unreadCount, 1);

      final last = conversation.lastMessage!;
      expect(last.body, 'Yes, it is still available.');
      expect(last.isMine, isFalse);
      expect(last.sender?.id, 502);
      expect(last.sender?.displayName, 'Sara Tesfaye');
    });
  });

  group('messages.index fixture', () {
    late Paginated<ChatMessage> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('messages.index.json'),
        ChatMessage.fromJson,
      );
    });

    test('parses messages and sender details', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);

      final message = page.items.single;
      expect(message.id, 772);
      expect(message.conversationId, 88);
      expect(message.body, 'Yes, it is still available.');
      expect(message.senderId, 502);
      expect(message.sender?.initials, 'ST');
      expect(message.isMine, isFalse);
      expect(message.isRead, isFalse);
      expect(message.readAt, isNull);
      expect(message.createdAt?.toUtc(), DateTime.utc(2026, 10, 29, 10, 20));
    });
  });

  group('chat helpers', () {
    test('defaults missing payloads safely', () {
      final conversation = ChatConversation.fromJson(const {});
      expect(conversation.type, 'direct');
      expect(conversation.unreadCount, 0);
      expect(conversation.hasUnread, isFalse);
      expect(conversation.hasListing, isFalse);
      expect(conversation.title, '');
      expect(conversation.lastMessage, isNull);

      final message = ChatMessage.fromJson(const {});
      expect(message.body, '');
      expect(message.isMine, isFalse);
      expect(message.hasSender, isFalse);

      final participant = ConversationParticipant.fromJson({
        'id': 9,
        'first_name': 'Liya',
        'last_name': 'Bekele',
      });
      expect(participant.displayName, 'Liya Bekele');
      expect(participant.name, '');
    });

    test('parses a read receipt and a read message', () {
      final receipt = ConversationReadReceipt.fromJson({
        'conversation_id': 88,
        'marked_read': 2,
        'unread_count': 0,
        'read_at': '2026-10-29T10:30:00Z',
      });

      expect(receipt.conversationId, 88);
      expect(receipt.markedRead, 2);
      expect(receipt.unreadCount, 0);
      expect(receipt.readAt?.toUtc(), DateTime.utc(2026, 10, 29, 10, 30));

      final message = ChatMessage.fromJson({
        'id': 773,
        'conversation_id': 88,
        'body': 'See you then.',
        'sender_id': 501,
        'sender': null,
        'is_mine': true,
        'is_read': true,
        'read_at': '2026-10-29T10:31:00Z',
        'created_at': '2026-10-29T10:30:00Z',
      });

      expect(message.isMine, isTrue);
      expect(message.isRead, isTrue);
      expect(message.readAt, isNotNull);
      expect(message.hasSender, isFalse);
    });
  });
}
