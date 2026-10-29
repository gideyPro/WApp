import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/home_feed.dart';

/// Loads the combined home payload with a short-lived ETag cache.
///
/// The backend only caches anonymous non-VIP responses, so pass
/// [useCache] = false for signed-in viewers.
class HomeService {
  final ApiV2Client _client;

  HomeFeed? _cached;
  String? _cachedEtag;
  DateTime? _cachedAt;

  static const Duration _maxAge = Duration(seconds: 60);

  HomeService({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  /// Returns the fresh feed, or the cached feed when the server replies 304.
  Future<HomeFeed> fetch({
    bool useCache = true,
    bool forceRefresh = false,
  }) async {
    final cached = _cached;
    final cachedAt = _cachedAt;

    if (useCache &&
        !forceRefresh &&
        cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _maxAge) {
      return cached;
    }

    final etag = useCache && !forceRefresh ? _cachedEtag : null;
    final document = await _client.fetch(
      ApiV2Constants.home,
      etag: etag,
    );

    if (document.notModified && cached != null) {
      _cachedAt = DateTime.now();
      return cached;
    }

    final feed = HomeFeed.fromEnvelope(document.data);
    if (useCache) {
      _cached = feed;
      _cachedEtag = document.etag;
      _cachedAt = DateTime.now();
    }

    return feed;
  }

  void clearCache() {
    _cached = null;
    _cachedEtag = null;
    _cachedAt = null;
  }
}
