import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/v2/api_v2_client.dart';
import '../../data/models/v2/app_config.dart';
import '../../data/services/v2/address_service.dart';
import '../../data/services/v2/app_config_service.dart';
import '../../data/services/v2/auth_service.dart';
import '../../data/services/v2/catalog_service.dart';
import '../../data/services/v2/conversation_service.dart';
import '../../data/services/v2/favorite_service.dart';
import '../../data/services/v2/help_service.dart';
import '../../data/services/v2/home_service.dart';
import '../../data/services/v2/kyc_service.dart';
import '../../data/services/v2/listing_media_service.dart';
import '../../data/services/v2/notification_service.dart';
import '../../data/services/v2/order_service.dart';
import '../../data/services/v2/owner_listing_service.dart';
import '../../data/services/v2/payment_service.dart';
import '../../data/services/v2/plan_service.dart';
import '../../data/services/v2/profile_service.dart';
import '../../data/services/v2/promotion_service.dart';
import '../../data/services/v2/subscription_service.dart';
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

final subscriptionV2ServiceProvider = Provider<SubscriptionServiceV2>((ref) {
  return SubscriptionServiceV2(client: ref.watch(apiV2ClientProvider));
});

final paymentV2ServiceProvider = Provider<PaymentServiceV2>((ref) {
  return PaymentServiceV2(client: ref.watch(apiV2ClientProvider));
});

final kycV2ServiceProvider = Provider<KycServiceV2>((ref) {
  return KycServiceV2(client: ref.watch(apiV2ClientProvider));
});

final helpV2ServiceProvider = Provider<HelpServiceV2>((ref) {
  return HelpServiceV2(client: ref.watch(apiV2ClientProvider));
});

final orderV2ServiceProvider = Provider<OrderServiceV2>((ref) {
  return OrderServiceV2(client: ref.watch(apiV2ClientProvider));
});

final conversationV2ServiceProvider = Provider<ConversationServiceV2>((ref) {
  return ConversationServiceV2(client: ref.watch(apiV2ClientProvider));
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

final ownerListingServiceProvider = Provider<OwnerListingService>((ref) {
  return OwnerListingService(client: ref.watch(apiV2ClientProvider));
});

final listingMediaV2ServiceProvider = Provider<ListingMediaServiceV2>((ref) {
  return ListingMediaServiceV2(client: ref.watch(apiV2ClientProvider));
});

final promotionV2ServiceProvider = Provider<PromotionServiceV2>((ref) {
  return PromotionServiceV2(client: ref.watch(apiV2ClientProvider));
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
