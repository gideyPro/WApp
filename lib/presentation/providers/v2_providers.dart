import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_client.dart';
import '../../data/models/v2/app_config.dart';
import '../../data/services/v2/address_service.dart';
import '../../data/services/v2/app_config_service.dart';
import '../../data/services/v2/auth_service.dart';
import '../../data/services/v2/catalog_service.dart';
import '../../data/services/v2/favorite_service.dart';
import '../../data/services/v2/home_service.dart';
import '../../data/services/v2/notification_service.dart';
import '../../data/services/v2/plan_service.dart';
import '../../data/services/v2/profile_service.dart';
import 'app_providers.dart';

/// Transport shared by every v2 service. Reuses [apiClientProvider] so v1 and
/// v2 requests share authentication, locale and 401 handling.
final apiV2ClientProvider = Provider<ApiV2Client>((ref) {
  return ApiV2Client(apiClient: ref.watch(apiClientProvider));
});

final appConfigServiceProvider = Provider<AppConfigService>((ref) {
  return AppConfigService(client: ref.watch(apiV2ClientProvider));
});

final catalogServiceProvider = Provider<CatalogService>((ref) {
  return CatalogService(client: ref.watch(apiV2ClientProvider));
});

final planServiceProvider = Provider<PlanService>((ref) {
  return PlanService(client: ref.watch(apiV2ClientProvider));
});

final authV2ServiceProvider = Provider<AuthServiceV2>((ref) {
  return AuthServiceV2(client: ref.watch(apiV2ClientProvider));
});

final profileV2ServiceProvider = Provider<ProfileServiceV2>((ref) {
  return ProfileServiceV2(client: ref.watch(apiV2ClientProvider));
});

final favoriteV2ServiceProvider = Provider<FavoriteServiceV2>((ref) {
  return FavoriteServiceV2(client: ref.watch(apiV2ClientProvider));
});

final notificationV2ServiceProvider = Provider<NotificationServiceV2>((ref) {
  return NotificationServiceV2(client: ref.watch(apiV2ClientProvider));
});

final addressV2ServiceProvider = Provider<AddressServiceV2>((ref) {
  return AddressServiceV2(client: ref.watch(apiV2ClientProvider));
});

final homeServiceProvider = Provider<HomeService>((ref) {
  final service = HomeService(client: ref.watch(apiV2ClientProvider));
  ref.onDispose(service.clearCache);
  return service;
});

/// Boot-time config. Widgets watch this to apply feature flags and the
/// force-update gate.
final appConfigProvider = FutureProvider<AppConfig>((ref) {
  return ref.watch(appConfigServiceProvider).fetch();
});
