import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/buyer_order.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';

import 'v2_fixtures.dart';

void main() {
  group('orders.index fixture', () {
    late Paginated<BuyerOrder> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('orders.index.json'),
        BuyerOrder.fromJson,
      );
    });

    test('parses cursor metadata', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.perPage, 20);
    });

    test('parses the request, ranges and exact address', () {
      final order = page.items.single;

      expect(order.id, 1204);
      expect(order.type, ListingKind.house);
      expect(order.listingType, 'sale');
      expect(order.isRental, isFalse);
      expect(order.status, BuyerOrderStatus.active);
      expect(order.canCancel, isTrue);
      expect(order.description, contains('family house'));

      expect(order.budget.min, 1000000);
      expect(order.budget.max, 5000000);
      expect(order.budget.isEmpty, isFalse);
      expect(order.area.min, 120);
      expect(order.area.max, 400);

      expect(order.holdingType, 'Free Hold');
      expect(order.facingDirection, 'north');
      expect(order.hasAddress, isTrue);
      expect(order.address?.region, 'Addis Ababa');
      expect(order.address?.zone, 'Bole');
      expect(order.address?.woreda, 'Woreda 03');
      expect(
        order.address?.displayAddress,
        'Addis Ababa, Bole, Woreda 03, Kebele 05',
      );

      expect(order.suggestionsCount, 2);
      expect(order.unreadSuggestionsCount, 1);
      expect(order.hasSuggestions, isTrue);
      expect(order.hasUnreadSuggestions, isTrue);
      expect(order.createdAt?.toUtc(), DateTime.utc(2026, 10, 29, 8));
    });
  });

  group('orders.show fixture', () {
    test('parses a single request', () {
      final order = BuyerOrder.fromJson(
        loadV2Fixture('orders.show.json')['data'] as Map<String, dynamic>,
      );

      expect(order.id, 1204);
      expect(order.status, BuyerOrderStatus.active);
      expect(order.budget.max, 5000000);
      expect(order.address?.kebele, 'Kebele 05');
      expect(order.updatedAt?.toUtc(), DateTime.utc(2026, 10, 29, 8));
    });
  });

  group('orders.suggestions.index fixture', () {
    late Paginated<OrderSuggestion> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('orders.suggestions.index.json'),
        OrderSuggestion.fromJson,
      );
    });

    test('parses the suggestion and its listing summary', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.perPage, 20);

      final suggestion = page.items.single;
      expect(suggestion.id, 9001);
      expect(suggestion.orderId, 1204);
      expect(suggestion.status, OrderSuggestionStatus.pending);
      expect(suggestion.status.isPending, isTrue);
      expect(suggestion.stage, 'new');
      expect(suggestion.adminNotes, 'Matches your budget and area.');
      expect(suggestion.hasNotes, isTrue);
      expect(suggestion.isRead, isFalse);
      expect(suggestion.readAt, isNull);
      expect(suggestion.canAccept, isTrue);
      expect(suggestion.canDecline, isTrue);
      expect(suggestion.hasListing, isTrue);

      final listing = suggestion.listing!;
      expect(listing.id, 4821);
      expect(listing.kind, ListingKind.house);
      expect(listing.title, contains('villa'));
      expect(listing.price.amount, 8500000);
      expect(listing.location.isMasked, isTrue);
    });
  });

  group('order helpers', () {
    test('parses status wire values and defaults', () {
      expect(BuyerOrderStatus.parse('fulfilled'), BuyerOrderStatus.fulfilled);
      expect(BuyerOrderStatus.parse('cancelled').isCancelled, isTrue);
      expect(BuyerOrderStatus.parse('expired'), BuyerOrderStatus.unknown);
      expect(OrderSuggestionStatus.parse('accepted').isPending, isFalse);
      expect(OrderSuggestionStatus.parse(null), OrderSuggestionStatus.unknown);

      final empty = BuyerOrder.fromJson(const {});
      expect(empty.type, ListingKind.unknown);
      expect(empty.status, BuyerOrderStatus.unknown);
      expect(empty.canCancel, isFalse);
      expect(empty.budget.isEmpty, isTrue);
      expect(empty.area.isEmpty, isTrue);
      expect(empty.hasAddress, isFalse);
      expect(empty.hasSuggestions, isFalse);
      expect(empty.description, '');
    });

    test('parses string ranges and a declined suggestion', () {
      final order = BuyerOrder.fromJson({
        'id': 7,
        'type': 'land',
        'listing_type': 'rental',
        'status': 'active',
        'description': 'A plot for a small farm.',
        'budget': {'min': '250000.50', 'max': null},
        'area': {'min': '300', 'max': '900'},
        'address': null,
      });

      expect(order.type, ListingKind.land);
      expect(order.isRental, isTrue);
      expect(order.budget.min, 250000.50);
      expect(order.budget.max, isNull);
      expect(order.budget.hasMax, isFalse);
      expect(order.area.max, 900);

      final suggestion = OrderSuggestion.fromJson({
        'id': 11,
        'order_id': 7,
        'listing': null,
        'status': 'declined',
        'stage': 'lost',
        'admin_notes': null,
        'is_read': true,
        'read_at': '2026-10-29T09:00:00Z',
        'can_accept': false,
        'can_decline': false,
      });

      expect(suggestion.hasListing, isFalse);
      expect(suggestion.hasNotes, isFalse);
      expect(suggestion.status, OrderSuggestionStatus.declined);
      expect(suggestion.isRead, isTrue);
      expect(suggestion.readAt?.toUtc(), DateTime.utc(2026, 10, 29, 9));
      expect(suggestion.canAccept, isFalse);
    });

    test('builds the address label when full_address is missing', () {
      final address = OrderAddress.fromJson({
        'id': 3,
        'region': 'Addis Ababa',
        'zone': 'Yeka',
        'woreda': 'Woreda 08',
        'kebele': null,
      });

      expect(address.displayAddress, 'Addis Ababa, Yeka, Woreda 08');
      expect(address.id, 3);
    });
  });
}
