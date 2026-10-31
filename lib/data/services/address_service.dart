import '../../core/network/api_client.dart';
import '../../core/network/error_handler.dart';
import '../../core/network/v2/api_v2_client.dart';
import '../models/address.dart';
import 'v2/address_service.dart';

/// Service for Ethiopian address hierarchy (cascading dropdowns) backed by V2 API.
class AddressService {
  final AddressServiceV2 _v2;

  AddressService({ApiClient? apiClient, AddressServiceV2? v2Service})
      : _v2 = v2Service ??
            AddressServiceV2(
              client:
                  apiClient != null ? ApiV2Client(apiClient: apiClient) : null,
            );

  Future<AddressResponse> getRegions({String locale = 'en'}) async {
    try {
      final list = await _v2.regions(locale: locale);
      final regions = list.map((opt) => Address(region: opt.name)).toList();
      return AddressResponse(success: true, regions: regions);
    } catch (e) {
      return AddressResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<AddressResponse> getZones({
    required String region,
    String locale = 'en',
  }) async {
    try {
      final list = await _v2.zones(region, locale: locale);
      final zones = list.map((opt) => Address(zone: opt.name)).toList();
      return AddressResponse(success: true, zones: zones);
    } catch (e) {
      return AddressResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<AddressResponse> getWoredas({
    required String region,
    required String zone,
    String locale = 'en',
  }) async {
    try {
      final list = await _v2.woredas(region, zone, locale: locale);
      final woredas = list.map((opt) => Address(woreda: opt.name)).toList();
      return AddressResponse(success: true, woredas: woredas);
    } catch (e) {
      return AddressResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }

  Future<AddressResponse> getKebeles({
    required String region,
    required String zone,
    required String woreda,
    String locale = 'en',
  }) async {
    try {
      final list = await _v2.kebeles(region, zone, woreda, locale: locale);
      final kebeles = list
          .map((opt) => Address(
                id: opt.id,
                kebele: opt.name,
              ))
          .toList();
      return AddressResponse(success: true, kebeles: kebeles);
    } catch (e) {
      return AddressResponse(
        success: false,
        message: ApiErrorHandler.getMessage(e),
      );
    }
  }
}

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
