import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/api_v2_error.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/app_config.dart';
import 'package:wavemart/data/models/v2/home_feed.dart';
import 'package:wavemart/data/models/v2/listing_detail.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/models/v2/plan.dart';

import 'v2_fixtures.dart';

void main() {
  group('listings.index fixture', () {
    late Paginated<ListingSummary> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('listings.index.json'),
        ListingSummary.fromJson,
      );
    });

    test('parses cursor metadata', () {
      expect(page.items, hasLength(2));
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, isNotNull);
      expect(page.perPage, 2);
    });

    test('parses a priced house summary', () {
      final listing = page.items.first;

      expect(listing.id, 4821);
      expect(listing.kind, ListingKind.house);
      expect(listing.listingType, 'sale');
      expect(listing.title, contains('villa'));
      expect(listing.price.amount, 8500000);
      expect(listing.price.currency, 'ETB');
      expect(listing.price.negotiable, isFalse);
      expect(listing.location.isMasked, isTrue);
      expect(listing.location.zone, 'Bole');
      expect(listing.location.zoneLocalized, 'ቦሌ');
      expect(listing.coverImage?.url, contains('cover-4821.jpg'));
      expect(listing.imagesCount, 6);
      expect(listing.isFeatured, isTrue);
      expect(listing.createdAt, isNotNull);
    });

    test('keeps negotiable listings without an amount', () {
      final listing = page.items.last;

      expect(listing.kind, ListingKind.land);
      expect(listing.price.amount, isNull);
      expect(listing.price.negotiable, isTrue);
      expect(listing.hasCoverImage, isTrue);
    });
  });

  group('listings.show fixture', () {
    late ListingDetail detail;

    setUp(() {
      detail = ListingDetail.fromJson(loadV2Fixture('listings.show.json')['data']
          as Map<String, dynamic>);
    });

    test('parses description, gallery and attributes', () {
      expect(detail.id, 4821);
      expect(detail.description, contains('private garden'));
      expect(detail.images, hasLength(3));
      expect(detail.attributes.totalSquareMeters, 420);
      expect(detail.attributes.holdingType, 'Free Hold');
      expect(detail.attributes.hasDebtOrEncumbrance, isFalse);
    });

    test('parses type-specific details', () {
      expect(detail.details.bedrooms, 4);
      expect(detail.details.bathrooms, 4);
      expect(detail.details.areaSqm, 420);
      expect(detail.details.houseType, 'villa');
      expect(detail.details.yearBuilt, 2019);
      expect(detail.details.parkingAvailable, isTrue);
      expect(detail.details.raw['bedrooms'], 4);
    });

    test('parses holding details and video', () {
      expect(detail.holdingDetails.private?.taxPaidUntilYear, 2027);
      expect(detail.holdingDetails.lease, isNull);
      expect(detail.holdingDetails.cooperative, isNull);
      expect(detail.video.url, contains('video-4821.mp4'));
      expect(detail.video.blocked, isFalse);
    });

    test('parses seller and viewer state', () {
      expect(detail.seller.hidden, isFalse);
      expect(detail.seller.phone, '+251911234567');
      expect(detail.viewer.isOwner, isFalse);
      expect(detail.viewer.contactRevealed, isTrue);
      expect(detail.viewer.contactsRemaining, 47);
      expect(detail.viewer.interestStatus, 'contacted');
      expect(detail.similar, hasLength(1));
    });
  });

  group('home fixture', () {
    late HomeFeed feed;

    setUp(() {
      feed = HomeFeed.fromEnvelope(loadV2Fixture('home.json'));
    });

    test('parses all sections and generated_at', () {
      expect(feed.featured, hasLength(1));
      expect(feed.listings, hasLength(1));
      expect(feed.cars, hasLength(1));
      expect(feed.jobs, hasLength(1));
      expect(feed.generatedAt, isNotNull);
      expect(feed.isEmpty, isFalse);
    });

    test('parses mixed catalog kinds', () {
      expect(feed.featured.single.kind, ListingKind.house);
      expect(feed.listings.single.kind, ListingKind.land);
      expect(feed.cars.single.kind, ListingKind.car);
      expect(feed.jobs.single.kind, ListingKind.job);
      expect(feed.jobs.single.coverImage, isNull);
    });
  });

  group('plans fixture', () {
    late List<Plan> plans;

    setUp(() {
      final data = loadV2Fixture('plans.index.json')['data'] as List;
      plans = data
          .map((plan) => Plan.fromJson(Map<String, dynamic>.from(plan as Map)))
          .toList();
    });

    test('parses free and paid plans', () {
      expect(plans, hasLength(3));
      expect(plans.first.slug, 'free');
      expect(plans.first.isFree, isTrue);
      expect(plans.first.defaultCycle?.price, 0);
      expect(plans[1].slug, 'basic');
      expect(plans[1].isFree, isFalse);
    });

    test('cycles are authoritative', () {
      final basic = plans[1];

      expect(basic.cycles, hasLength(3));
      expect(basic.cycleForMonths(3)?.price, 1350);
      expect(basic.cycleForMonths(3)?.badge, 'Popular');
      expect(basic.defaultCycle?.months, 1);
      expect(basic.limits.listings, 5);
      expect(basic.features, contains('Full address details'));
    });

    test('premium discounts are visible per cycle', () {
      final premium = plans[2];
      final cycle = premium.cycleForMonths(1)!;

      expect(cycle.price, 1350);
      expect(cycle.originalPrice, 1500);
      expect(cycle.discountPercent, 10);
      expect(cycle.hasDiscount, isTrue);
    });
  });

  group('app-config fixture', () {
    test('parses update contract and flags', () {
      final config =
          AppConfig.fromJson(loadV2Fixture('app-config.json')['data']
              as Map<String, dynamic>);

      expect(config.apiVersion, 2);
      expect(config.minSupportedBuild, 42);
      expect(config.latestBuild, 45);
      expect(config.updateType, AppUpdateType.blocking);
      expect(config.subscriptionEnabled, isTrue);
      expect(config.currency, 'ETB');
      expect(config.isUpdateRequired(41), isTrue);
      expect(config.isUpdateRequired(42), isFalse);
      expect(config.isUpdateRecommended(3), isFalse);
    });
  });

  group('error fixture', () {
    test('parses code, message and field errors', () {
      final error = ApiV2Error.fromJson(
        loadV2Fixture('error.validation.json')['error'],
        statusCode: 422,
      );

      expect(error.code, ApiV2ErrorCodes.validationFailed);
      expect(error.isValidation, isTrue);
      expect(error.statusCode, 422);
      expect(error.fieldError('limit'), contains('greater than 50'));
      expect(error.allFieldMessages, hasLength(1));
    });
  });
}
