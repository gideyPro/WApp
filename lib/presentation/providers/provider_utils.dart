import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';
import 'listing_provider.dart';

void clearCachedProviders(WidgetRef ref) {
  ref.invalidate(profileProvider);
  ref.invalidate(kycStatusProvider);
  ref.invalidate(subscriptionProvider);
  ref.invalidate(favoritesProvider);
  ref.invalidate(notificationsProvider);
  ref.invalidate(listingsProvider);
  ref.invalidate(featuredListingsProvider);
  ref.invalidate(vipListingsProvider);
  ref.invalidate(searchResultsProvider);
}
