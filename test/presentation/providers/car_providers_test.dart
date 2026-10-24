import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_client.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/data/services/car_service.dart';
import 'package:wavemart/presentation/providers/car_providers.dart';

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
        'homeCarListingsProvider does not share state with carListingsProvider',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final listNotifier = container.read(carListingsProvider.notifier);
      final homeNotifier = container.read(homeCarListingsProvider.notifier);

      expect(identical(listNotifier, homeNotifier), isFalse);
    });
  });

  group('CarDetailNotifier.revealContact', () {
    test('reveals contact and decrements remaining vehicle contact quota',
        () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        expect(options.method, 'POST');
        expect(options.path, contains('/cars/101/reveal-contact'));
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'contact': '+251911223344',
            'name': 'Seller Name',
            'already_revealed': false,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final carService = CarService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          carServiceProvider.overrideWithValue(carService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(carDetailProvider.notifier);

      // Pre-seed an unrevealed car listing with 3 vehicle contact views remaining
      final initialListing = Listing(
        id: 101,
        propertyType: PropertyType.car,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 3,
        contactMax: 5,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      expect(notifier.state.listing!.contactRevealed, isFalse);
      expect(notifier.state.listing!.contactRemaining, equals(3));
      expect(notifier.state.listing!.revealedContact, isNull);

      final result = await notifier.revealContact(101);

      expect(result, isNotNull);
      expect(result!['contact'], equals('+251911223344'));
      expect(result['name'], equals('Seller Name'));

      // Check state is updated and remaining count decremented
      final updatedListing = notifier.state.listing!;
      expect(updatedListing.contactRevealed, isTrue);
      expect(updatedListing.revealedContact, equals('+251911223344'));
      expect(updatedListing.revealedName, equals('Seller Name'));
      expect(updatedListing.sellerPhone, equals('+251911223344'));
      expect(updatedListing.contactRemaining, equals(2));
    });

    test('does not decrement quota when already_revealed is true', () async {
      final apiClient = ApiClient();
      apiClient.dio.httpClientAdapter = _StubAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'contact': '+251911223344',
            'name': 'Seller Name',
            'already_revealed': true,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final carService = CarService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          carServiceProvider.overrideWithValue(carService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(carDetailProvider.notifier);

      final initialListing = Listing(
        id: 101,
        propertyType: PropertyType.car,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 3,
        contactMax: 5,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      final result = await notifier.revealContact(101);

      expect(result, isNotNull);
      expect(result!['already_revealed'], isTrue);
      expect(notifier.state.listing!.contactRevealed, isTrue);
      // Quota MUST NOT be decremented because already revealed
      expect(notifier.state.listing!.contactRemaining, equals(3));
    });

    test('returns error when vehicle contact views exhausted', () async {
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

      final carService = CarService(apiClient: apiClient);
      final container = ProviderContainer(
        overrides: [
          carServiceProvider.overrideWithValue(carService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(carDetailProvider.notifier);

      final initialListing = Listing(
        id: 102,
        propertyType: PropertyType.car,
        listingType: ListingType.sale,
        userId: 99,
        status: ListingStatus.active,
        contactRevealed: false,
        contactRemaining: 0,
        contactMax: 5,
        createdAt: DateTime.now(),
      );
      notifier.updateListingInline(initialListing);

      final result = await notifier.revealContact(102);

      expect(result, isNotNull);
      expect(result!['error'], contains('all contact views'));
      expect(notifier.state.listing!.contactRevealed, isFalse);
    });
  });
}
