import '../../../core/utils/type_utils.dart';

/// One entry in the locale-aware address cascade.
///
/// Regions, zones and woredas have no row id; kebeles carry the address id
/// needed when creating a listing.
class AddressOption {
  final int? id;
  final String name;

  const AddressOption({this.id, required this.name});

  bool get hasId => id != null;

  factory AddressOption.fromJson(Map<String, dynamic> json) {
    return AddressOption(
      id: TypeUtils.safeInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}
