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
    final mainParts = [kebele, woreda, zone, region]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    
    String base = mainParts.join(', ');
    if (specificLocation != null && specificLocation!.isNotEmpty) {
      if (base.isNotEmpty) {
        return '$base - $specificLocation';
      }
      return specificLocation!;
    }
    return base;
  }

  String get shortAddress {
    final mainParts = [kebele, woreda, zone]
        .where((e) => e != null && e.isNotEmpty)
        .toList();
    
    String base = mainParts.join(', ');
    if (specificLocation != null && specificLocation!.isNotEmpty) {
      if (base.isNotEmpty) {
        return '$base - $specificLocation';
      }
      return specificLocation!;
    }
    return base;
  }

  /// Get address string localized for the current app locale
  /// [cache] - Optional map of English names to localized names fetched from API
  String getLocalizedAddress(BuildContext context, [Map<String, String>? cache, bool isRestricted = false]) {
    final locale = Localizations.localeOf(context).languageCode;

    // Helper to get name from cache or fallback to original
    String? translate(String? original) {
      if (original == null || original.isEmpty) return null;
      if (locale == 'en') return original;
      return cache?[original] ?? original;
    }

    // Use localized values only when not in English locale.
    String? localizedOr(String? field, String? localized) =>
        (locale != 'en' && localized != null) ? localized : translate(field);
        
    String? r = localizedOr(region, regionLocalized);
    String? z = localizedOr(zone, zoneLocalized);
    String? w = localizedOr(woreda, woredaLocalized);
    String? k = localizedOr(kebele, kebeleLocalized);
    String? s = localizedOr(specificLocation, specificLocationLocalized);

    // Order: Kebele, Woreda, Zone, Region - Special Location
    // If restricted, show only Zone and Region
    final List<String?> mainComponents = isRestricted 
        ? [z, r] 
        : [k, w, z, r];
    
    final parts = mainComponents
        .where((e) => e != null && e.isNotEmpty)
        .map((e) => e!)
        .toList();
    
    if (parts.isEmpty && (s == null || s.isEmpty || isRestricted)) return '';
    
    String base = parts.join(', ');
    
    // Add Special Location with a dash if not restricted
    if (!isRestricted && s != null && s.isNotEmpty) {
      if (base.isNotEmpty) {
        return '$base - $s';
      }
      return s;
    }
    
    return base;
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
