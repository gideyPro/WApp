import '../../../core/network/v2/api_v2_client.dart';
import '../../../core/network/v2/api_v2_constants.dart';
import '../../models/v2/address_option.dart';

/// Locale-aware address cascade.
///
/// `locale` is `en`, `am` or `ti`; the backend reads the matching table.
class AddressServiceV2 {
  final ApiV2Client _client;

  AddressServiceV2({ApiV2Client? client}) : _client = client ?? ApiV2Client();

  Future<List<AddressOption>> regions({String locale = 'en'}) {
    return _options(
      ApiV2Constants.addressRegions,
      query: {'locale': locale},
    );
  }

  Future<List<AddressOption>> zones(
    String region, {
    String locale = 'en',
  }) {
    return _options(
      ApiV2Constants.addressZones,
      query: {'region': region, 'locale': locale},
    );
  }

  Future<List<AddressOption>> woredas(
    String region,
    String zone, {
    String locale = 'en',
  }) {
    return _options(
      ApiV2Constants.addressWoredas,
      query: {'region': region, 'zone': zone, 'locale': locale},
    );
  }

  Future<List<AddressOption>> kebeles(
    String region,
    String zone,
    String woreda, {
    String locale = 'en',
  }) {
    return _options(
      ApiV2Constants.addressKebeles,
      query: {
        'region': region,
        'zone': zone,
        'woreda': woreda,
        'locale': locale,
      },
    );
  }

  Future<List<AddressOption>> _options(
    String path, {
    required Map<String, dynamic> query,
  }) {
    return _client.getList(
      path,
      parse: AddressOption.fromJson,
      query: query,
    );
  }
}
