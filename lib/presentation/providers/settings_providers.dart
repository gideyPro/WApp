import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../data/services/kyc_service.dart';
import '../../data/services/address_service.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/api_envelope.dart';
import 'theme_provider.dart';

final appSettingsProvider = FutureProvider<Map<String, dynamic>>((_) async {
  try {
    final response =
        await ApiClient().dio.get('${ApiConstants.apiBase}/settings');
    if (response.statusCode == 200 && response.data is Map) {
      return ApiEnvelope.extractData(response.data);
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
  return {'subscription_enabled': false};
});

/// KYC Provider
final kycServiceProvider = Provider<KycService>((ref) => KycService());
final kycStatusProvider =
    StateNotifierProvider<KycStatusNotifier, KycStatusState>((ref) {
  return KycStatusNotifier(ref.watch(kycServiceProvider));
});

class KycStatusNotifier extends StateNotifier<KycStatusState> {
  final KycService _kycService;
  KycStatusNotifier(this._kycService) : super(const KycStatusState.initial());

  Future<void> loadKycStatus() async {
    // Only set loading if not already loading to avoid flicker
    if (state.isLoading && state.status == 'none') {
      // Already in initial loading state
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    final response = await _kycService.getKycStatus();
    if (response.success) {
      state = KycStatusState.loaded(
        status: response.status,
        isVerified: response.isVerified,
        rejectionReason: response.rejectionReason,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.errorMessage ?? response.status,
        status: response.status,
      );
    }
  }
}

class KycStatusState {
  final bool isLoading;
  final String status;
  final bool isVerified;
  final String? rejectionReason;
  final String? submittedAt;
  final String? errorMessage;
  const KycStatusState(
      {required this.isLoading,
      this.status = 'none',
      this.isVerified = false,
      this.rejectionReason,
      this.submittedAt,
      this.errorMessage});
  const KycStatusState.initial()
      : isLoading = false,
        status = 'none',
        isVerified = false,
        rejectionReason = null,
        submittedAt = null,
        errorMessage = null;
  const KycStatusState.loaded(
      {this.status = 'none',
      this.isVerified = false,
      this.rejectionReason,
      this.submittedAt})
      : isLoading = false,
        errorMessage = null;
  KycStatusState copyWith(
      {bool? isLoading,
      String? status,
      bool? isVerified,
      String? rejectionReason,
      String? submittedAt,
      String? errorMessage}) {
    return KycStatusState(
        isLoading: isLoading ?? this.isLoading,
        status: status ?? this.status,
        isVerified: isVerified ?? this.isVerified,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        submittedAt: submittedAt ?? this.submittedAt,
        errorMessage: errorMessage);
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get hasError => status == 'error';
  bool get isNone => status == 'none' || status.isEmpty;
}

/// Address Provider
final addressServiceProvider =
    Provider<AddressService>((ref) => AddressService());
final regionsProvider = FutureProvider((ref) async {
  return ref.watch(addressServiceProvider).getRegions();
});
final zonesProvider = FutureProvider.family((ref, String region) async {
  return ref.watch(addressServiceProvider).getZones(region: region);
});
final woredasProvider =
    FutureProvider.family((ref, Map<String, String> params) async {
  return ref
      .watch(addressServiceProvider)
      .getWoredas(region: params['region']!, zone: params['zone']!);
});
final kebelesProvider =
    FutureProvider.family((ref, Map<String, String> params) async {
  return ref.watch(addressServiceProvider).getKebeles(
      region: params['region']!,
      zone: params['zone']!,
      woreda: params['woreda']!);
});

/// Global cache for localized address names
/// Structure: { 'en_name': 'localized_name' }
final addressCacheProvider = StateProvider<Map<String, String>>((ref) => {});

/// Locale Provider
final localeProvider =
    StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<LocaleState> {
  final Ref _ref;
  LocaleNotifier(this._ref) : super(const LocaleState.initial()) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    // Load from the shared preferences box (opened centrally in main.dart)
    final box = Hive.box(kPrefsBox);
    final savedLocale = box.get(PrefsKey.locale);

    if (savedLocale != null) {
      state = LocaleState.loaded(locale: Locale(savedLocale));
    } else {
      // Use system locale or default to English
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      const supportedLocales = ['en', 'am', 'ti'];

      if (supportedLocales.contains(systemLocale.languageCode)) {
        state = LocaleState.loaded(locale: systemLocale);
      } else {
        state = const LocaleState.loaded(locale: Locale('en'));
      }
    }

    // Sync to API Client
    if (state.locale != null) {
      ApiClient.currentLocale = state.locale!.languageCode;
      _warmupAddressCache();
    }
  }

  Future<void> setLocale(Locale locale) async {
    final box = Hive.box(kPrefsBox);
    await box.put(PrefsKey.locale, locale.languageCode);

    state = LocaleState.loaded(locale: locale);

    // Sync to API Client
    ApiClient.currentLocale = locale.languageCode;
    _warmupAddressCache();
  }

  /// Prefetch localized region/zone names to populate the cache
  Future<void> _warmupAddressCache() async {
    final locale = state.locale?.languageCode ?? 'en';
    if (locale == 'en') return;

    try {
      final service = _ref.read(addressServiceProvider);
      
      // 1. Fetch Regions
      final regResp = await service.getRegions(locale: 'en'); // Get EN keys
      final locRegResp = await service.getRegions(locale: locale); // Get Loc keys
      
      if (regResp.success && locRegResp.success) {
        final cache = {..._ref.read(addressCacheProvider)};
        final enNames = regResp.regions.map((r) => r.region).toList();
        final locNames = locRegResp.regions.map((r) => r.region).toList();
        
        for (int i = 0; i < enNames.length && i < locNames.length; i++) {
          if (enNames[i] != null && locNames[i] != null) {
            cache[enNames[i]!] = locNames[i]!;
          }
        }

        // 2. Fetch common Zones (optional but helpful for speed)
        // For brevity, we focus on regions first as they are most visible
        
        _ref.read(addressCacheProvider.notifier).state = cache;
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }
}

class LocaleState {
  final bool isLoading;
  final Locale? locale;
  final String? errorMessage;

  const LocaleState({
    required this.isLoading,
    this.locale,
    this.errorMessage,
  });

  const LocaleState.initial() : this(isLoading: true);
  const LocaleState.loaded({required this.locale})
      : isLoading = false,
        errorMessage = null;

  LocaleState copyWith({
    bool? isLoading,
    Locale? locale,
    String? errorMessage,
  }) {
    return LocaleState(
      isLoading: isLoading ?? this.isLoading,
      locale: locale ?? this.locale,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
