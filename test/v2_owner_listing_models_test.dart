import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/models/v2/owner_listing.dart';

import 'v2_fixtures.dart';

void main() {
  group('my-listings.index fixture', () {
    late Paginated<OwnerListing> page;

    setUp(() {
      page = Paginated.fromJson(
        loadV2Fixture('my-listings.index.json'),
        OwnerListing.fromJson,
      );
    });

    test('parses the final page metadata', () {
      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.nextCursor, isNull);
      expect(page.perPage, 20);
    });

    test('parses moderation state and owner affordances', () {
      final listing = page.items.single;

      expect(listing.id, 101);
      expect(listing.kind, ListingKind.house);
      expect(listing.status, OwnerListingStatus.active);
      expect(listing.isDraft, isFalse);
      expect(listing.isLocked, isFalse);
      expect(listing.title, 'Spacious family house');
      expect(listing.price.amount, 8500000);
      expect(listing.location.displayZone, 'ቦሌ');
      expect(listing.imagesCount, 4);
      expect(listing.canEdit, isFalse);
      expect(listing.canEditMedia, isFalse);
      expect(listing.canSubmit, isFalse);
      expect(listing.canDelete, isTrue);
      expect(listing.nextEditAt?.toUtc(), DateTime.utc(2026, 11, 12, 8));
      expect(listing.video.status, VideoStateStatus.none);
      expect(listing.video.hasVideo, isFalse);
    });
  });

  group('owner listing status', () {
    test('parses every wire value', () {
      expect(OwnerListingStatus.parse('draft'), OwnerListingStatus.draft);
      expect(OwnerListingStatus.parse('pending'), OwnerListingStatus.pending);
      expect(OwnerListingStatus.parse('active'), OwnerListingStatus.active);
      expect(OwnerListingStatus.parse('rejected'), OwnerListingStatus.rejected);
      expect(OwnerListingStatus.parse('frozen'), OwnerListingStatus.frozen);
      expect(OwnerListingStatus.parse('sold'), OwnerListingStatus.unknown);
      expect(OwnerListingStatus.parse(null), OwnerListingStatus.unknown);
    });

    test('marks drafts and rejected listings editable', () {
      expect(OwnerListingStatus.draft.isEditable, isTrue);
      expect(OwnerListingStatus.rejected.isEditable, isTrue);
      expect(OwnerListingStatus.pending.isEditable, isFalse);
      expect(OwnerListingStatus.active.isEditable, isFalse);
      expect(OwnerListingStatus.draft.isPublished, isFalse);
      expect(OwnerListingStatus.active.isPublished, isTrue);
    });
  });

  group('video state', () {
    test('parses a processing job', () {
      final state = VideoState.fromJson({
        'status': 'processing',
        'url': 'https://cdn.test/listings/videos/tour.mp4',
        'thumbnail_url': 'https://cdn.test/listings/videos/tour.jpg',
        'error_message': null,
        'uploaded_at': '2026-10-29T09:00:00Z',
      });

      expect(state.status, VideoStateStatus.processing);
      expect(state.status.isBusy, isTrue);
      expect(state.status.hasVideo, isTrue);
      expect(state.isReady, isFalse);
      expect(state.thumbnailUrl, contains('tour.jpg'));
      expect(state.uploadedAt?.toUtc(), DateTime.utc(2026, 10, 29, 9));
    });

    test('parses a ready video and a failure', () {
      final ready = VideoState.fromJson({
        'status': 'ready',
        'url': 'https://cdn.test/tour.mp4',
      });
      expect(ready.isReady, isTrue);

      final failed = VideoState.fromJson({
        'status': 'failed',
        'url': null,
        'error_message': 'Transcode failed',
      });
      expect(failed.status, VideoStateStatus.failed);
      expect(failed.isReady, isFalse);
      expect(failed.errorMessage, 'Transcode failed');
    });
  });

  group('promotion state', () {
    test('parses a featured response', () {
      final state = PromotionState.fromJson({
        'listing_id': 101,
        'is_featured': true,
        'featured_until': '2026-11-28T08:00:00Z',
        'is_vip': false,
      });

      expect(state.listingId, 101);
      expect(state.isFeatured, isTrue);
      expect(state.isVip, isFalse);
      expect(state.featuredUntil?.toUtc(), DateTime.utc(2026, 11, 28, 8));
    });

    test('treats a missing body as inactive', () {
      final state = PromotionState.fromJson(const {});

      expect(state.listingId, 0);
      expect(state.isFeatured, isFalse);
      expect(state.isVip, isFalse);
      expect(state.featuredUntil, isNull);
    });
  });

  group('media asset', () {
    test('parses a site plan id and url', () {
      final asset = MediaAsset.fromJson({
        'id': 7,
        'url': 'https://cdn.test/site-plan.jpg',
      });

      expect(asset.id, 7);
      expect(asset.hasUrl, isTrue);
      expect(MediaAsset.fromJson(const {}).hasUrl, isFalse);
    });
  });
}
