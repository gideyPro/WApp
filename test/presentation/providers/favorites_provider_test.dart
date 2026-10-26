import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/data/services/favorite_service.dart';
import 'package:wavemart/presentation/providers/listing_providers.dart';

class _FakeFavoriteService extends FavoriteService {
  _FakeFavoriteService(this.responses);

  final Map<int, FavoriteResponse> responses;
  final List<int> requestedPages = [];

  @override
  Future<FavoriteResponse> getFavorites({int page = 1, int perPage = 50}) async {
    requestedPages.add(page);
    return responses[page] ??
        const FavoriteResponse(success: false, message: 'Missing page');
  }
}

Listing _listing(int id) => Listing.fromJson({
      'id': id,
      'listing_type': 'sale',
      'property_type': 'house',
      'status': 'active',
    });

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('loadFavorites aggregates every page', () async {
    final fake = _FakeFavoriteService({
      1: FavoriteResponse(
        success: true,
        listings: [_listing(1), _listing(2)],
        currentPage: 1,
        totalPages: 3,
        total: 5,
      ),
      2: FavoriteResponse(
        success: true,
        listings: [_listing(3), _listing(4)],
        currentPage: 2,
        totalPages: 3,
        total: 5,
      ),
      3: FavoriteResponse(
        success: true,
        listings: [_listing(5)],
        currentPage: 3,
        totalPages: 3,
        total: 5,
      ),
    });
    final container = ProviderContainer(overrides: [
      favoriteServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    await container.read(favoritesProvider.notifier).loadFavorites();

    final state = container.read(favoritesProvider);
    expect(state.favorites.map((listing) => listing.id), [1, 2, 3, 4, 5]);
    expect(state.total, 5);
    expect(fake.requestedPages, [1, 2, 3]);
  });

  test('loadFavorites keeps partial results when a later page fails', () async {
    final fake = _FakeFavoriteService({
      1: FavoriteResponse(
        success: true,
        listings: [_listing(1), _listing(2)],
        currentPage: 1,
        totalPages: 2,
        total: 2,
      ),
      2: const FavoriteResponse(success: false, message: 'Network error'),
    });
    final container = ProviderContainer(overrides: [
      favoriteServiceProvider.overrideWithValue(fake),
    ]);
    addTearDown(container.dispose);

    await container.read(favoritesProvider.notifier).loadFavorites();

    final state = container.read(favoritesProvider);
    expect(state.isLoading, isFalse);
    expect(state.favorites.map((listing) => listing.id), [1, 2]);
    expect(state.total, 2);
    expect(fake.requestedPages, [1, 2]);
  });
}
