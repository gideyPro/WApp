import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import '../../core/network/error_handler.dart';
import '../models/address.dart';

/// Service for Ethiopian address hierarchy (cascading dropdowns)
/// Supports locale-based address retrieval for Amharic/Tigrinya
class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get all regions
  /// API returns simple string array: ["Tigray", "Amhara", ...]
  /// [locale] - language code: 'en', 'am', 'ti'
  Future<AddressResponse> getRegions({String locale = 'en'}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.regions,
        queryParameters: {'locale': locale},
      );

      if (response.statusCode == 200) {
        final regionNames = ApiEnvelope.extractList(response.data)
            .whereType<String>()
            .toList();

        final regions =
            regionNames.map((name) => Address(region: name)).toList();
        return AddressResponse(success: true, regions: regions);
      }

      return AddressResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch regions'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get zones by region
  /// API returns simple string array: ["Central", "Eastern", ...]
  Future<AddressResponse> getZones({
    required String region,
    String locale = 'en',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.zones,
        queryParameters: {'region': region, 'locale': locale},
      );

      if (response.statusCode == 200) {
        final zoneNames = ApiEnvelope.extractList(response.data)
            .whereType<String>()
            .toList();

        final zones = zoneNames.map((name) => Address(zone: name)).toList();
        return AddressResponse(success: true, zones: zones);
      }

      return AddressResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch zones'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get woredas by region and zone
  /// API returns simple string array: ["01", "02", ...]
  Future<AddressResponse> getWoredas({
    required String region,
    required String zone,
    String locale = 'en',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.woredas,
        queryParameters: {
          'region': region,
          'zone': zone,
          'locale': locale,
        },
      );

      if (response.statusCode == 200) {
        final woredaNames = ApiEnvelope.extractList(response.data)
            .whereType<String>()
            .toList();

        final woredas =
            woredaNames.map((name) => Address(woreda: name)).toList();
        return AddressResponse(success: true, woredas: woredas);
      }

      return AddressResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch woredas'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get kebeles by region, zone, and woreda
  /// API returns array of {id, kebele}: [{id: 1, kebele: "Kebele 01"}, ...]
  Future<AddressResponse> getKebeles({
    required String region,
    required String zone,
    required String woreda,
    String locale = 'en',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.kebeles,
        queryParameters: {
          'region': region,
          'zone': zone,
          'woreda': woreda,
          'locale': locale,
        },
      );

      if (response.statusCode == 200) {
        final kebeles = ApiEnvelope.extractList(response.data)
            .whereType<Map>()
            .map((m) => Address(
                  id: m['id'] as int?,
                  kebele: m['kebele'] as String?,
                ))
            .where((a) => a.kebele != null && a.kebele!.isNotEmpty)
            .toList();

        return AddressResponse(success: true, kebeles: kebeles);
      }

      return AddressResponse(
        success: false,
        message: ApiEnvelope.extractMessage(response.data, 'Failed to fetch kebeles'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return AddressResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }
}

/// Response wrapper for address operations
class AddressResponse {
  final bool success;
  final String message;
  final List<Address> regions;
  final List<Address> zones;
  final List<Address> woredas;
  final List<Address> kebeles;

  const AddressResponse({
    required this.success,
    this.message = '',
    this.regions = const [],
    this.zones = const [],
    this.woredas = const [],
    this.kebeles = const [],
  });

  @override
  String toString() =>
      'AddressResponse(success: $success, regions: ${regions.length})';
}
