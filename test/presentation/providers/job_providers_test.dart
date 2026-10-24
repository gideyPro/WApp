import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/data/services/job_service.dart';
import 'package:wavemart/presentation/providers/job_providers.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.responder);

  final ResponseBody Function(RequestOptions options) responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return responder(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('home feed isolation', () {
    test(
        'homeJobListingsProvider does not share state with jobListingsProvider',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final listNotifier = container.read(jobListingsProvider.notifier);
      final homeNotifier = container.read(homeJobListingsProvider.notifier);

      expect(identical(listNotifier, homeNotifier), isFalse);
    });
  });

  group('JobDetailNotifier.revealContact', () {
    test('reveals contact and decrements remaining job contact quota',
        () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, contains('/jobs/202/reveal-contact'));
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'contact': '+251922334455',
            'name': 'Hiring Manager',
            'already_revealed': false,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final jobService = JobService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          jobServiceProvider.overrideWithValue(jobService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(jobDetailProvider.notifier);

      // Pre-seed an unrevealed job listing with 2 job contact views remaining
      final initialListing = Listing(
        id: 202,
        propertyType: PropertyType.job,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 2,
        contactMax: 3,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      expect(notifier.state.listing!.contactRevealed, isFalse);
      expect(notifier.state.listing!.contactRemaining, equals(2));
      expect(notifier.state.listing!.revealedContact, isNull);

      final result = await notifier.revealContact(202);

      expect(result, isNotNull);
      expect(result!['contact'], equals('+251922334455'));
      expect(result['name'], equals('Hiring Manager'));

      // Check state is updated and remaining count decremented
      final updatedListing = notifier.state.listing!;
      expect(updatedListing.contactRevealed, isTrue);
      expect(updatedListing.revealedContact, equals('+251922334455'));
      expect(updatedListing.revealedName, equals('Hiring Manager'));
      expect(updatedListing.sellerPhone, equals('+251922334455'));
      expect(updatedListing.contactRemaining, equals(1));
    });

    test('does not decrement quota when already_revealed is true', () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'contact': '+251922334455',
            'name': 'Hiring Manager',
            'already_revealed': true,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final jobService = JobService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          jobServiceProvider.overrideWithValue(jobService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(jobDetailProvider.notifier);

      final initialListing = Listing(
        id: 202,
        propertyType: PropertyType.job,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 2,
        contactMax: 3,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      final result = await notifier.revealContact(202);

      expect(result, isNotNull);
      expect(result!['already_revealed'], isTrue);
      expect(notifier.state.listing!.contactRevealed, isTrue);
      // Quota MUST NOT be decremented because already revealed
      expect(notifier.state.listing!.contactRemaining, equals(2));
    });

    test('returns error when job contact views exhausted', () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': false,
            'message': 'You have used all contact views for this period.',
          }),
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final jobService = JobService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          jobServiceProvider.overrideWithValue(jobService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(jobDetailProvider.notifier);

      final initialListing = Listing(
        id: 202,
        propertyType: PropertyType.job,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 0,
        contactMax: 3,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      final result = await notifier.revealContact(202);

      expect(result, isNotNull);
      expect(result!.containsKey('error'), isTrue);
      expect(notifier.state.listing!.contactRevealed, isFalse);
      expect(notifier.state.listing!.contactRemaining, equals(0));
    });
  });
}
