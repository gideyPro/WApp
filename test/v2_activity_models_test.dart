import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/address_option.dart';
import 'package:wavemart/data/models/v2/app_notification.dart';
import 'package:wavemart/data/models/v2/favorite_state.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';

import 'v2_fixtures.dart';

void main() {
  group('favorites.index fixture', () {
    late Paginated<ListingSummary> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('favorites.index.json'),
        ListingSummary.fromJson,
      );
    });

    test('parses the final page metadata', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.perPage, 20);
    });

    test('marks the listing as favorited', () {
      final listing = page.items.single;

      expect(listing.id, 4821);
      expect(listing.kind, ListingKind.house);
      expect(listing.isFavorite, isTrue);
      expect(listing.location.isMasked, isTrue);
    });
  });

  group('favorite state', () {
    test('parses a create response', () {
      final state = FavoriteState.fromJson({
        'listing_id': 4821,
        'favorited': true,
        'favorites_count': 7,
      });

      expect(state.listingId, 4821);
      expect(state.favorited, isTrue);
      expect(state.favoritesCount, 7);
    });

    test('parses an idempotent remove response', () {
      final state = FavoriteState.fromJson({
        'listing_id': 4821,
        'favorited': false,
        'favorites_count': 0,
      });

      expect(state.favorited, isFalse);
      expect(state.favoritesCount, 0);
    });
  });

  group('notifications.index fixture', () {
    late Paginated<AppNotification> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('notifications.index.json'),
        AppNotification.fromJson,
      );
    });

    test('parses the collection envelope', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
    });

    test('parses a listing notification', () {
      final notification = page.items.single;

      expect(notification.id, 321);
      expect(notification.type, 'listing_update');
      expect(notification.title, 'Your listing is live');
      expect(notification.message, contains('villa'));
      expect(notification.isRead, isFalse);
      expect(notification.isUnread, isTrue);
      expect(notification.readAt, isNull);
      expect(notification.listingId, 4821);
      expect(notification.conversationId, isNull);
      expect(notification.actionUrl, contains('/listings/4821'));
      expect(notification.createdAt?.toUtc(), DateTime.utc(2026, 10, 29, 9));
    });
  });

  group('notification helpers', () {
    test('exposes the wire filter values', () {
      expect(NotificationFilter.all.wireValue, 'all');
      expect(NotificationFilter.unread.wireValue, 'unread');
      expect(NotificationFilter.read.wireValue, 'read');
    });

    test('parses unread counters', () {
      final counters = NotificationCounters.fromJson({
        'notifications': 4,
        'messages': 2,
      });

      expect(counters.notifications, 4);
      expect(counters.messages, 2);
      expect(counters.total, 6);
    });

    test('parses a mark-read receipt', () {
      final receipt = NotificationReadReceipt.fromJson({
        'id': 321,
        'is_read': true,
        'read_at': '2026-10-29T09:05:00Z',
        'unread_count': 3,
      });

      expect(receipt.id, 321);
      expect(receipt.isRead, isTrue);
      expect(receipt.readAt?.toUtc(), DateTime.utc(2026, 10, 29, 9, 5));
      expect(receipt.unreadCount, 3);
    });

    test('parses a mark-all-read result', () {
      final result = MarkAllReadResult.fromJson({
        'updated': 4,
        'unread_count': 0,
      });

      expect(result.updated, 4);
      expect(result.unreadCount, 0);
    });

    test('copyWith flips the read state', () {
      final notification = AppNotification.fromJson({
        'id': 1,
        'type': 'system',
        'title': 'Welcome',
        'message': 'Hello',
        'is_read': false,
      });

      final read = notification.copyWith(
        isRead: true,
        readAt: DateTime.utc(2026, 10, 29),
      );

      expect(read.isRead, isTrue);
      expect(read.isUnread, isFalse);
      expect(read.readAt, DateTime.utc(2026, 10, 29));
      expect(read.data, isEmpty);
    });
  });

  group('addresses.regions fixture', () {
    test('parses parent options without ids', () {
      final data = loadV2Fixture('addresses.regions.json')['data'] as List;

      final options = data
          .map((item) => AddressOption.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      expect(options, hasLength(2));
      expect(options.map((option) => option.name), ['Addis Ababa', 'Oromia']);
      expect(options.every((option) => option.id == null), isTrue);
      expect(options.every((option) => !option.hasId), isTrue);
    });

    test('parses a kebele with an address id', () {
      final option = AddressOption.fromJson({'id': 42, 'name': 'Kebele 02'});

      expect(option.id, 42);
      expect(option.hasId, isTrue);
      expect(option.name, 'Kebele 02');
    });
  });
}
