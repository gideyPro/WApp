import 'listing_summary.dart';

/// One-request payload for the home screen.
class HomeFeed {
  final List<ListingSummary> featured;
  final List<ListingSummary> listings;
  final List<ListingSummary> cars;
  final List<ListingSummary> jobs;
  final DateTime? generatedAt;

  const HomeFeed({
    this.featured = const [],
    this.listings = const [],
    this.cars = const [],
    this.jobs = const [],
    this.generatedAt,
  });

  bool get isEmpty =>
      featured.isEmpty && listings.isEmpty && cars.isEmpty && jobs.isEmpty;

  factory HomeFeed.fromJson(
    Map<String, dynamic> json, {
    DateTime? generatedAt,
  }) {
    return HomeFeed(
      featured: _summaries(json['featured']),
      listings: _summaries(json['listings']),
      cars: _summaries(json['cars']),
      jobs: _summaries(json['jobs']),
      generatedAt: generatedAt,
    );
  }

  /// Build from the full envelope so `meta.generated_at` is not lost.
  factory HomeFeed.fromEnvelope(Map<String, dynamic> envelope) {
    final rawData = envelope['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : const <String, dynamic>{};
    final rawMeta = envelope['meta'];
    final meta = rawMeta is Map ? rawMeta : const {};

    return HomeFeed.fromJson(
      data,
      generatedAt: _parseDate(meta['generated_at']),
    );
  }

  HomeFeed copyWith({DateTime? generatedAt}) {
    return HomeFeed(
      featured: featured,
      listings: listings,
      cars: cars,
      jobs: jobs,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  static List<ListingSummary> _summaries(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) =>
            ListingSummary.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
