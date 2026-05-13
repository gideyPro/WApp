import 'package:flutter/material.dart';

/// Address Model - Ethiopian hierarchical address system
class Address {
  final int? id;
  final String? region;
  final String? zone;
  final String? woreda;
  final String? kebele;
  final String? specificLocation;

  // Localized fields (when available from API)
  final String? regionLocalized;
  final String? zoneLocalized;
  final String? woredaLocalized;
  final String? kebeleLocalized;
  final String? specificLocationLocalized;

  Address({
    this.id,
    this.region,
    this.zone,
    this.woreda,
    this.kebele,
    this.specificLocation,
    this.regionLocalized,
    this.zoneLocalized,
    this.woredaLocalized,
    this.kebeleLocalized,
    this.specificLocationLocalized,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: _safeInt(json['id']),
      region: json['region'],
      zone: json['zone'],
      woreda: json['woreda'],
      kebele: json['kebele'],
      specificLocation: json['specific_location'],
      // Extract localized fields if present in API response
      regionLocalized: json['region_localized'] ??
          json['region_amharic'] ??
          json['region_tigrinya'],
      zoneLocalized: json['zone_localized'] ??
          json['zone_amharic'] ??
          json['zone_tigrinya'],
      woredaLocalized: json['woreda_localized'] ??
          json['woreda_amharic'] ??
          json['woreda_tigrinya'],
      kebeleLocalized: json['kebele_localized'] ??
          json['kebele_amharic'] ??
          json['kebele_tigrinya'],
      specificLocationLocalized: json['specific_location_localized'] ??
          json['specific_location_amharic'] ??
          json['specific_location_tigrinya'],
    );
  }

  /// Safely convert dynamic value to int
  static int? _safeInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    if (value is bool) return value ? 1 : 0;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'zone': zone,
      'woreda': woreda,
      'kebele': kebele,
      'specific_location': specificLocation,
      'region_localized': regionLocalized,
      'zone_localized': zoneLocalized,
      'woreda_localized': woredaLocalized,
      'kebele_localized': kebeleLocalized,
      'specific_location_localized': specificLocationLocalized,
    };
  }

  String get fullAddress {
    final parts = [region, zone, woreda, kebele, specificLocation]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get shortAddress {
    final parts = [zone, kebele, specificLocation]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String? get localizedRegion {
    if (regionLocalized != null) return regionLocalized;
    // Map common regions if localization is missing from API
    final r = region?.toLowerCase();
    if (r == 'tigray') return 'ትግራይ';
    if (r == 'amhara') return 'አማራ';
    if (r == 'oromia') return 'ኦሮሚያ';
    if (r == 'addis ababa') return 'አዲስ አበባ';
    return region;
  }

  /// Get address string localized for the current app locale
  String getLocalizedAddress(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    // Use localized values if available
    String? r = regionLocalized ?? region;
    String? z = zoneLocalized ?? zone;
    String? w = woredaLocalized ?? woreda;
    String? k = kebeleLocalized ?? kebele;
    String? s = specificLocationLocalized ?? specificLocation;

    // If it's English, we just return the standard join
    if (locale == 'en') {
      final parts = [z, w, k, s]
          .where((e) => e != null && e.isNotEmpty)
          .toList();
      return parts.isEmpty ? (region ?? '') : parts.join(', ');
    }

    // For AM/TI, if localized fields are null, the backend didn't provide them.
    // However, we want to at least show the available parts.
    final parts = [z, w, k, s]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    
    if (parts.isEmpty) return r ?? '';
    
    // Append region at the end if it exists and isn't already the only part
    if (r != null && r.isNotEmpty) {
      parts.add(r);
    }
    
    return parts.join(', ');
  }

  @override
  String toString() => 'Address($fullAddress)';
}

/// Region model for cascading dropdowns
class Region {
  final int id;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Region({
    required this.id,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Zone model
class Zone {
  final int id;
  final int regionId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Zone({
    required this.id,
    required this.regionId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'],
      regionId: json['region_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Woreda model
class Woreda {
  final int id;
  final int zoneId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Woreda({
    required this.id,
    required this.zoneId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Woreda.fromJson(Map<String, dynamic> json) {
    return Woreda(
      id: json['id'],
      zoneId: json['zone_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}

/// Kebele model
class Kebele {
  final int id;
  final int woredaId;
  final String name;
  final String nameAmharic;
  final String nameTigrinya;

  Kebele({
    required this.id,
    required this.woredaId,
    required this.name,
    required this.nameAmharic,
    required this.nameTigrinya,
  });

  factory Kebele.fromJson(Map<String, dynamic> json) {
    return Kebele(
      id: json['id'],
      woredaId: json['woreda_id'],
      name: json['name'],
      nameAmharic: json['name_amharic'] ?? '',
      nameTigrinya: json['name_tigrinya'] ?? '',
    );
  }
}
