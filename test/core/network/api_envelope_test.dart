import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_envelope.dart';

void main() {
  group('ApiEnvelope.extractData', () {
    test('returns data field when present', () {
      final raw = {
        'success': true,
        'data': {'id': 1, 'name': 'foo'},
        'message': 'ok',
      };
      final data = ApiEnvelope.extractData(raw);
      expect(data, {'id': 1, 'name': 'foo'});
    });

    test('returns root map when data field missing', () {
      final raw = {'id': 1, 'name': 'foo'};
      final data = ApiEnvelope.extractData(raw);
      expect(data, {'id': 1, 'name': 'foo'});
    });

    test('returns inner key under data when specified', () {
      final raw = {
        'data': {
          'verification': {'status': 'pending'},
        },
      };
      final data = ApiEnvelope.extractData(raw, innerKey: 'verification');
      expect(data, {'status': 'pending'});
    });

    test('returns empty map when raw is null', () {
      expect(ApiEnvelope.extractData(null), <String, dynamic>{});
    });

    test('returns empty map when raw is not a Map', () {
      expect(ApiEnvelope.extractData('a string'), <String, dynamic>{});
      expect(ApiEnvelope.extractData(42), <String, dynamic>{});
      expect(ApiEnvelope.extractData([]), <String, dynamic>{});
    });

    test('falls back to data map when inner key is absent', () {
      // The inner key is only returned when it is a Map; otherwise the helper
      // returns the whole `data` map (preserves caller's map-shape tolerance).
      final raw = {'data': {'other': 'x'}};
      expect(
        ApiEnvelope.extractData(raw, innerKey: 'verification'),
        {'other': 'x'},
      );
    });

    test('falls back to root map when data is null', () {
      final raw = {'data': null};
      expect(ApiEnvelope.extractData(raw), {'data': null});
    });

    test('falls back to root map when data is not a Map', () {
      final raw = {'data': 'plain string'};
      expect(ApiEnvelope.extractData(raw), {'data': 'plain string'});
    });
  });

  group('ApiEnvelope.extractList', () {
    test('extracts from data with default item key', () {
      final raw = {
        'data': {
          'items': [
            {'id': 1},
            {'id': 2},
          ],
        },
      };
      final list = ApiEnvelope.extractList(raw, itemKeys: const ['items']);
      expect(list, hasLength(2));
      expect(list[0], {'id': 1});
    });

    test('falls back to data when it is a List', () {
      final raw = {
        'data': [
          {'id': 1},
        ],
      };
      final list = ApiEnvelope.extractList(raw, itemKeys: const ['items']);
      expect(list, hasLength(1));
    });

    test('falls back to root when data field is missing', () {
      final raw = [
        {'id': 1},
      ];
      final list = ApiEnvelope.extractList(raw, itemKeys: const ['items']);
      expect(list, hasLength(1));
    });

    test('tries item keys in order', () {
      final raw = {
        'data': {
          'listings': [
            {'id': 99},
          ],
        },
      };
      final list = ApiEnvelope.extractList(
        raw,
        itemKeys: const ['listings', 'items'],
      );
      expect(list, hasLength(1));
      expect(list[0]['id'], 99);
    });

    test('unwraps paginator nested under resource key', () {
      final raw = {
        'data': {
          'notifications': {
            'data': [
              {'id': 1},
            ],
            'current_page': 1,
          },
        },
      };
      final list = ApiEnvelope.extractList(
        raw,
        itemKeys: const ['notifications'],
      );
      expect(list, hasLength(1));
    });

    test('returns data values as last-ditch fallback when items key absent', () {
      // Preserves legacy behavior of favorite_service / lead_service: when
      // raw.data is a Map without the expected item key, surface its values
      // so callers can still pick up their shape (e.g. a list nested by name).
      final raw = {
        'data': {
          'other': 'value',
        },
      };
      final list = ApiEnvelope.extractList(raw, itemKeys: const ['items']);
      expect(list, ['value']);
    });

    test('returns empty list when raw is null', () {
      expect(
        ApiEnvelope.extractList(null, itemKeys: const ['items']),
        isEmpty,
      );
    });

    test('returns empty list when raw is not a Map', () {
      expect(
        ApiEnvelope.extractList('not a map', itemKeys: const ['items']),
        isEmpty,
      );
    });
  });

  group('ApiEnvelope.extractMessage', () {
    test('returns message field', () {
      final raw = {'message': 'Saved'};
      expect(ApiEnvelope.extractMessage(raw, 'fallback'), 'Saved');
    });

    test('falls back to error field', () {
      final raw = {'error': 'Boom'};
      expect(ApiEnvelope.extractMessage(raw, 'fallback'), 'Boom');
    });

    test('falls back to errors field', () {
      final raw = {'errors': 'Oops'};
      expect(ApiEnvelope.extractMessage(raw, 'fallback'), 'Oops');
    });

    test('returns default when no message field present', () {
      final raw = {'data': {}};
      expect(
        ApiEnvelope.extractMessage(raw, 'fallback'),
        'fallback',
      );
    });

    test('returns default when raw is null', () {
      expect(ApiEnvelope.extractMessage(null, 'fallback'), 'fallback');
    });

    test('returns default when raw is not a Map', () {
      expect(ApiEnvelope.extractMessage(42, 'fallback'), 'fallback');
    });

    test('returns default when message is null', () {
      final raw = {'message': null};
      expect(ApiEnvelope.extractMessage(raw, 'fallback'), 'fallback');
    });

    test('accepts raw String as the message', () {
      expect(
        ApiEnvelope.extractMessage('plain error string', 'fallback'),
        'plain error string',
      );
    });
  });

  group('ApiEnvelope.extractDestination', () {
    test('returns destination string when present', () {
      final raw = {'destination': '+251911000000'};
      expect(ApiEnvelope.extractDestination(raw), '+251911000000');
    });

    test('returns null when destination is absent', () {
      expect(ApiEnvelope.extractDestination({'foo': 'bar'}), isNull);
    });

    test('returns null when raw is null', () {
      expect(ApiEnvelope.extractDestination(null), isNull);
    });

    test('returns null when raw is not a Map', () {
      expect(ApiEnvelope.extractDestination('not a map'), isNull);
    });
  });

  group('ApiEnvelope.safeInt', () {
    test('returns int as-is', () {
      expect(ApiEnvelope.safeInt(42), 42);
    });

    test('coerces double to int', () {
      expect(ApiEnvelope.safeInt(42.7), 42);
    });

    test('parses numeric String', () {
      expect(ApiEnvelope.safeInt('42'), 42);
    });

    test('returns null for non-numeric String', () {
      expect(ApiEnvelope.safeInt('not a number'), isNull);
    });

    test('returns null for null', () {
      expect(ApiEnvelope.safeInt(null), isNull);
    });

    test('handles num (subclass of int/double)', () {
      expect(ApiEnvelope.safeInt(42.0 as num), 42);
    });
  });

  group('ApiEnvelope.safeIntOr', () {
    test('returns value when parseable', () {
      expect(ApiEnvelope.safeIntOr(42, 0), 42);
    });

    test('returns default on failure', () {
      expect(ApiEnvelope.safeIntOr('not a number', 99), 99);
    });

    test('returns default on null', () {
      expect(ApiEnvelope.safeIntOr(null, 99), 99);
    });
  });

  group('ApiEnvelope.safeDouble', () {
    test('returns double as-is', () {
      expect(ApiEnvelope.safeDouble(42.5), 42.5);
    });

    test('coerces int to double', () {
      expect(ApiEnvelope.safeDouble(42), 42.0);
    });

    test('parses numeric String', () {
      expect(ApiEnvelope.safeDouble('42.5'), 42.5);
    });

    test('returns null for non-numeric String', () {
      expect(ApiEnvelope.safeDouble('not a number'), isNull);
    });

    test('returns null for null', () {
      expect(ApiEnvelope.safeDouble(null), isNull);
    });
  });

  group('ApiEnvelope.extractPagination', () {
    test('reads pagination from data envelope (Laravel paginator)', () {
      final raw = {
        'data': {
          'items': [],
          'current_page': 3,
          'last_page': 10,
          'per_page': 20,
          'total': 200,
        },
      };
      final meta = ApiEnvelope.extractPagination(raw);
      expect(meta.currentPage, 3);
      expect(meta.totalPages, 10);
      expect(meta.total, 200);
    });

    test('falls back to root when no data envelope', () {
      final raw = {
        'current_page': 1,
        'last_page': 5,
        'per_page': 15,
        'total': 75,
      };
      final meta = ApiEnvelope.extractPagination(raw);
      expect(meta.currentPage, 1);
      expect(meta.totalPages, 5);
      expect(meta.total, 75);
    });

    test('returns fallback defaults when no pagination fields present', () {
      final raw = {'data': {'items': []}};
      final meta = ApiEnvelope.extractPagination(raw, fallbackPage: 2);
      expect(meta.currentPage, 2);
      expect(meta.totalPages, 1);
      expect(meta.total, 0);
    });

    test('returns fallback default when raw is null', () {
      final meta = ApiEnvelope.extractPagination(null, fallbackPage: 4);
      expect(meta.currentPage, 4);
      expect(meta.totalPages, 1);
    });

    test('returns fallback default when raw is not a Map', () {
      final meta = ApiEnvelope.extractPagination('string', fallbackPage: 4);
      expect(meta.currentPage, 4);
    });

    test('coerces numeric fields from String', () {
      final raw = {
        'current_page': '2',
        'last_page': 5,
        'per_page': 20,
        'total': 100,
      };
      final meta = ApiEnvelope.extractPagination(raw);
      expect(meta.currentPage, 2);
      expect(meta.totalPages, 5);
    });
  });
}
