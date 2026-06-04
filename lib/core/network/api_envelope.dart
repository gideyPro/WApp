import 'package:flutter/foundation.dart';

/// Centralized parser for the inconsistent JSON envelopes returned by the
/// Laravel backend. The backend returns responses in several different shapes
/// depending on the endpoint:
///
///   1. Bare list:                       [ {...}, {...} ]
///   2. Wrapped list:                    { "data": [ ... ] }
///   3. Paginated wrapped:               { "data": { "data": [ ... ], "current_page": 1, ... } }
///   4. Resource-style:                  { "data": { "listings": [ ... ] } }
///   5. Paginator inside resource:       { "data": { "notifications": { "data": [ ... ] } } }
///   6. Direct key:                      { "plans": [ ... ] }
///
/// Error envelopes vary similarly: `message`, `error`, or `errors` keys.
///
/// Rather than reimplementing the unwrap logic in every service, all services
/// route through [ApiEnvelope]. The union of every previously-private helper
/// is preserved, so no service's behavior changes.
class ApiEnvelope {
  ApiEnvelope._();

  /// Extract a list from any of the known envelope shapes.
  ///
  /// [itemKeys] is the set of inner list keys this endpoint uses. Defaults
  /// to `['items']`. Pass endpoint-specific keys like
  /// `['listings', 'items']` for `/listings`, or
  /// `['plans', 'items', 'subscriptions']` for `/subscriptions`.
  ///
  /// Returns an empty list when nothing matches. Never throws.
  static List<dynamic> extractList(
    dynamic raw, {
    List<String> itemKeys = const ['items'],
  }) {
    if (raw == null) return const [];
    if (raw is List) return raw;
    if (raw is! Map) return const [];

    // 1. raw.data is a list directly
    final dataField = raw['data'];
    if (dataField is List) return dataField;

    // 2. resource-style: raw.data.<itemKey> is a list, or paginator with nested data
    if (dataField is Map) {
      // 2a. raw.data.data (double-wrapped)
      if (dataField['data'] is List) return dataField['data'] as List;

      // 2b. raw.data.<itemKey>
      for (final key in itemKeys) {
        final v = dataField[key];
        if (v is List) return v;
        // 2c. raw.data.<itemKey>.data (paginator inside resource)
        if (v is Map && v['data'] is List) return v['data'] as List;
      }
    }

    // 3. raw.<itemKey> (top-level non-data key)
    for (final key in itemKeys) {
      if (raw[key] is List) return raw[key] as List;
    }

    // 4. last-ditch fallback: if raw.data is a Map, surface its values.
    //    Preserves the legacy behavior of favorite_service / lead_service.
    if (dataField is Map) return dataField.values.toList();

    return const [];
  }

  /// Extract a single Map (the "data object") for single-record responses
  /// such as User, Lead, Payment, Conference, Order.
  ///
  /// Tries in order:
  ///   - raw (if Map)
  ///   - raw['data'] (if Map)
  ///   - raw['data'] (if Map) then raw['data']['<innerKey>']
  ///   - returns `{}` when nothing matches
  static Map<String, dynamic> extractData(
    dynamic raw, {
    String? innerKey,
  }) {
    if (raw is! Map) return const {};
    if (raw['data'] is Map) {
      final dataField = raw['data'] as Map;
      if (innerKey != null && dataField[innerKey] is Map) {
        return Map<String, dynamic>.from(dataField[innerKey] as Map);
      }
      return Map<String, dynamic>.from(dataField);
    }
    return Map<String, dynamic>.from(raw);
  }

  /// Extract a human-readable message from any of the error envelope shapes.
  /// Tries `message` → `error` → `errors` (in that order). If [raw] is a
  /// String, returns it as-is. Falls back to [defaultMessage].
  static String extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map) {
      final m = raw['message'] ?? raw['error'] ?? raw['errors'];
      if (m != null) return m.toString();
      return defaultMessage;
    }
    if (raw is String && raw.isNotEmpty) return raw;
    return defaultMessage;
  }

  /// Extract a destination string (used by OTP flow responses).
  /// Returns null when absent.
  static String? extractDestination(dynamic raw) {
    if (raw is Map && raw['destination'] != null) {
      return raw['destination'].toString();
    }
    return null;
  }

  /// Safely parse an int from any of: int, double, numeric String.
  /// Returns null on failure (no silent coercion to 0).
  static int? safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Like [safeInt] but returns [defaultValue] on failure.
  static int safeIntOr(dynamic value, int defaultValue) {
    return safeInt(value) ?? defaultValue;
  }

  /// Safely parse a double from any of: double, int, numeric String.
  /// Returns null on failure.
  static double? safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  /// Extract pagination metadata (current_page, last_page, total) from a
  /// paginator envelope. Looks under `raw['data']` first (Laravel paginator
  /// convention), then falls back to [raw] root.
  ///
  /// [fallbackPage] is returned for currentPage when the field is missing
  /// or zero (caller typically passes the page they requested).
  static PaginationMeta extractPagination(
    dynamic raw, {
    int fallbackPage = 1,
  }) {
    if (raw is! Map) {
      return PaginationMeta(currentPage: fallbackPage);
    }

    Map? source = raw['data'] is Map ? raw['data'] as Map : raw;

    final currentPage = safeInt(source['current_page']);
    final lastPage = safeInt(source['last_page']);
    final total = safeInt(source['total']) ?? 0;

    return PaginationMeta(
      currentPage: (currentPage != null && currentPage > 0)
          ? currentPage
          : fallbackPage,
      totalPages: (lastPage != null && lastPage > 0) ? lastPage : 1,
      total: total,
    );
  }

  /// Debug-only: log the raw envelope shape to help diagnose new endpoints.
  /// No-op in release.
  static void debugLog(String tag, dynamic raw) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[$tag] envelope: $raw');
    }
  }
}

/// Pagination metadata extracted from a Laravel paginator response.
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int total;

  const PaginationMeta({
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
  });
}
