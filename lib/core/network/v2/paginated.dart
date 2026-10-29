/// A cursor-paginated collection from the v2 API.
///
/// The wire shape is:
///
/// ```json
/// {
///   "data": [ ... ],
///   "meta": { "next_cursor": "...", "has_more": true, "per_page": 20 }
/// }
/// ```
class Paginated<T> {
  final List<T> items;

  /// Opaque cursor for the next page. Null when [hasMore] is false.
  final String? nextCursor;

  final bool hasMore;
  final int perPage;

  const Paginated({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.perPage = 0,
  });

  const Paginated.empty()
      : items = const [],
        nextCursor = null,
        hasMore = false,
        perPage = 0;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  /// Append a following page, keeping the latest cursor metadata.
  Paginated<T> append(Paginated<T> next) {
    return Paginated<T>(
      items: [...items, ...next.items],
      nextCursor: next.nextCursor,
      hasMore: next.hasMore,
      perPage: next.perPage,
    );
  }

  /// Map the items while preserving pagination metadata.
  Paginated<R> map<R>(R Function(T item) transform) {
    return Paginated<R>(
      items: items.map(transform).toList(growable: false),
      nextCursor: nextCursor,
      hasMore: hasMore,
      perPage: perPage,
    );
  }

  static Paginated<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> item) parse, {
    int fallbackPerPage = 0,
  }) {
    final rawItems = json['data'];
    if (rawItems is! List) {
      throw const FormatException('Expected a list at data');
    }

    final meta = json['meta'];
    final metaMap = meta is Map ? meta : const {};

    final rawCursor = metaMap['next_cursor'];
    final nextCursor =
        (rawCursor is String && rawCursor.isNotEmpty) ? rawCursor : null;

    final rawPerPage = metaMap['per_page'];
    final perPage = rawPerPage is int
        ? rawPerPage
        : int.tryParse(rawPerPage?.toString() ?? '') ?? fallbackPerPage;

    return Paginated<T>(
      items: rawItems
          .whereType<Map>()
          .map((item) => parse(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      nextCursor: nextCursor,
      hasMore: metaMap['has_more'] == true && nextCursor != null,
      perPage: perPage,
    );
  }
}
