import 'dart:convert';
import 'dart:io';

/// Loads a canonical payload copied from `WaveMart/docs/api-v2/fixtures`.
///
/// The backend's fixture contract test verifies these files against live
/// responses; the Flutter tests verify the models accept the same files.
Map<String, dynamic> loadV2Fixture(String name) {
  final file = File('test/fixtures/api_v2/$name');
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map) {
    throw StateError('$name does not contain a JSON object');
  }
  return Map<String, dynamic>.from(decoded);
}
