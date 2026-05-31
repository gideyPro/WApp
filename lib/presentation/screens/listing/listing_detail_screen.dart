import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/models/subscription.dart';
import '../../widgets/common/wave_card.dart';
import '../../../../data/services/lead_service.dart';
import '../../../../data/services/listing_service.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../auth/otp_login_screen.dart';
import '../../widgets/video/video_player_widget.dart';
import '../../../../l10n/app_localizations.dart';
import '../subscriptions/subscription_plans_screen.dart';
import 'edit_listing_screen.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_dialog.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../video/full_screen_video_screen.dart';

/// Listing Detail Screen with skeleton loaders
class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Timer? _videoPollTimer;
  String? _precachedVideoUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(listingDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  @override
  void dispose() {
    _videoPollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startVideoPolling() {
    if (_videoPollTimer != null) return;
    _videoPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      ref.read(listingDetailProvider.notifier).refreshVideoStatus(widget.listingId);
    });
  }

  void _stopVideoPolling() {
    _videoPollTimer?.cancel();
    _videoPollTimer = null;
  }

  void _precacheVideo(Listing listing) {
    final vp = listing.videoProcessing;
    if (vp == null || vp.status != VideoProcessingStatus.ready) return;
    final url = listing.processedVideoUrl;
    if (url == null || url.isEmpty || url == _precachedVideoUrl) return;
    _precachedVideoUrl = url;
    CachedVideoPlayerPlus.preCacheVideo(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider);

    // Manage video processing polling based on current listing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.listing != null && state.listing!.isVideoBeingProcessed) {
        _startVideoPolling();
      } else {
        _stopVideoPolling();
      }
    });

    // Show skeleton while loading, error banner, or content
    if (state.isLoading) {
      return _buildSkeletonLoader();
    }

    if (state.errorMessage != null) {
      return _buildErrorView(state.errorMessage!);
    }

    if (state.listing == null) {
      return _buildNotFound();
    }

    return _buildContent(state.listing!);
  }

  Widget _buildSkeletonLoader() {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // Image skeleton
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: context.shimmerBase,
              highlightColor: context.shimmerHighlight,
              child: Column(
                children: [
                  // App bar skeleton
                  Container(
                    height: 56,
                    color: context.shimmerHighlight,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.shimmerBase,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  // Image skeleton
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: context.shimmerHighlight),
                  ),
                  // Page indicator skeleton
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.shimmerHighlight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content skeleton
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: context.shimmerBase,
                highlightColor: context.shimmerHighlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price + title
                    Container(
                      height: 28,
                      width: 160,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 18,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Badges skeleton
                    Row(
                      children: [
                        _skeletonChip(context, 50, 20),
                        const SizedBox(width: 8),
                        _skeletonChip(context, 65, 20),
                        const SizedBox(width: 8),
                        _skeletonChip(context, 55, 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Location skeleton
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.shimmerHighlight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: context.shimmerHighlight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    // Key features skeleton
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _skeletonChip(context, 80, 32),
                        const SizedBox(width: 8),
                        _skeletonChip(context, 90, 32),
                        const SizedBox(width: 8),
                        _skeletonChip(context, 70, 32),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description skeleton
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            height: 14,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: context.shimmerHighlight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonChip(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.shimmerHighlight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    final l10n = AppLocalizations.of(context);
    final isSubscriptionError = message.toLowerCase().contains('subscription');

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(
          isSubscriptionError
              ? l10n.subscriptionRequiredTitle
              : l10n.listingsTitle,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSubscriptionError
                    ? Icons.workspace_premium_rounded
                    : Icons.signal_wifi_off_rounded,
                size: 64,
                color: isSubscriptionError
                    ? AppColors.accent500
                    : ThemeColors(context).textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                isSubscriptionError
                    ? l10n.subscriptionRequiredTitle
                    : l10n.listingsLoadError,
                style: AppTextStyles.title,
              ),
              const SizedBox(height: 8),
              Text(
                isSubscriptionError
                    ? l10n.subscriptionRequiredDetailsSubtitle
                    : message,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.theme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isSubscriptionError)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionPlansScreen()),
                    );
                  },
                  icon: const Icon(Icons.star, size: 18),
                  label: Text(l10n.listingUpgradeNow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(listingDetailProvider.notifier)
                        .loadListing(widget.listingId);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.commonRetry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy950,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: WaveAppBar(title: Text(l10n.listingsTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 64, color: ThemeColors(context).iconSecondary),
              const SizedBox(height: 16),
              Text(l10n.listingsNotFound, style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                l10n.listingsNotFoundSubtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.theme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonOk),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Listing listing) {
    _precacheVideo(listing);
    final favState = ref.watch(favoritesProvider);
    final isFavorited = favState.favorites.any((f) => f.id == listing.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image Gallery Sliver
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(listing),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? AppColors.error : Colors.white,
                ),
                onPressed: () => _toggleFavorite(listing.id, isFavorited),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareListing(listing),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceAndTitle(listing),
                  const SizedBox(height: 16),
                  _buildBadges(listing),
                  const SizedBox(height: 8),
                  _buildLocation(listing),
                  const Divider(height: 32),
                  _buildKeyFeatures(listing),
                  const SizedBox(height: 24),
                  _buildAmenities(listing),
                  const SizedBox(height: 24),
                  _buildDescription(listing),
                  const SizedBox(height: 24),
                  _buildPropertyDetails(listing),
                  const SizedBox(height: 24),
                  _buildActionButtons(listing),
                  const SizedBox(height: 32),
                  _buildSimilarListings(listing),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    final images = listing.images;

    if (images.isEmpty) {
      return Container(
        color: context.cardBg,
        child: Center(
          child: Icon(Icons.image_not_supported,
              size: 64, color: context.textMuted),
        ),
      );
    }

    return Hero(
      tag: 'listing_image_${listing.id}',
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index].imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.primary100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(Icons.broken_image, size: 64),
                ),
              );
            },
          ),
          // Image counter + View count
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (listing.viewCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.viewCount}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (listing.viewCount > 0 && images.length > 1)
                  const SizedBox(width: 6),
                if (images.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${_currentImageIndex + 1}/${images.length}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndTitle(Listing listing) {
    final cache = ref.watch(addressCacheProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.getLocalizedPrice(context),
          style: AppTextStyles.headline2.copyWith(
            color: AppColors.emerald600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          listing.getLocalizedTitle(context, cache),
          style: AppTextStyles.headline4,
        ),
      ],
    );
  }

  Widget _buildBadges(Listing listing) {
    final l10n = AppLocalizations.of(context);

    // Calculate total rooms for houses
    final totalRooms = listing.totalRooms;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          listing.propertyType == PropertyType.house
              ? l10n.listingHouse.toUpperCase()
              : l10n.listingLand.toUpperCase(),
          AppColors.primary900,
        ),
        if (listing.listingType == ListingType.sale)
          _buildBadge(l10n.listingForSale.toUpperCase(), AppColors.emerald600)
        else
          _buildBadge(l10n.listingForRent.toUpperCase(), AppColors.accent600),
        if (listing.isFeatured)
          _buildBadge(l10n.listingFeatured.toUpperCase(), AppColors.accent500),
        if (listing.isVip)
          _buildBadge('VIP', AppColors.vip),
        if (listing.isNew)
          _buildBadge(l10n.listingNew.toUpperCase(), AppColors.warning),
        if (listing.status == ListingStatus.frozen)
          _buildBadge('FROZEN', AppColors.error),
        // Photo count badge
        if (listing.imageCount != null && listing.imageCount! > 0)
          _buildBadge(
            l10n.listingPhotosCount(listing.imageCount!),
            AppColors.primary700,
          ),
        // Total rooms count badge (for houses only)
        if (listing.propertyType == PropertyType.house && totalRooms > 0)
          _buildBadge(
            '$totalRooms ${l10n.listingTotalRooms.toLowerCase()}',
            AppColors.emerald700,
          ),
        // House type badge
        if (listing.propertyType == PropertyType.house &&
            listing.houseType != null &&
            listing.houseType!.isNotEmpty)
          _buildBadge(
            listing.houseType!.replaceAll('_', ' ').toUpperCase(),
            AppColors.stone700,
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAmenities(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final amenities = <Widget>[];

    if (listing.electricity) {
      amenities.add(_buildAmenityChip(
        Icons.bolt,
        l10n.listingElectricity,
      ));
    }
    if (listing.water) {
      amenities.add(_buildAmenityChip(
        Icons.water_drop,
        l10n.listingWater,
      ));
    }
    if (listing.parkingAvailable) {
      amenities.add(_buildAmenityChip(
        Icons.local_parking,
        l10n.listingParking,
      ));
    }
    if (listing.yearBuilt != null && listing.yearBuilt! > 0) {
      amenities.add(_buildAmenityChip(
        Icons.calendar_today,
        '${l10n.listingYearBuilt}: ${listing.yearBuilt}',
      ));
    }

    if (amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingAmenities, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities,
        ),
      ],
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent500),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    
    final subState = ref.watch(subscriptionProvider);
    final isRestricted = subState.subscription?.plan?.detailsAccess == DetailsAccess.discovery;

    final location = listing.address?.getLocalizedAddress(context, cache, isRestricted) ??
        l10n.listingUnknownLocation;

    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: AppColors.accent500),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  location,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary600,
                  ),
                ),
              ),
              if (isRestricted) ...[
                const SizedBox(width: 6),
                Icon(Icons.lock_outline, size: 14, color: context.theme.textMuted),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyFeatures(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final features = <Widget>[];

    // For houses: show rooms
    if (listing.propertyType == PropertyType.house) {
      if ((listing.bedrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.bed,
          label: l10n.listingsBedrooms(listing.bedrooms!),
        ));
      }
      if ((listing.bathrooms ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.bathtub,
          label: l10n.listingsBathrooms(listing.bathrooms!),
        ));
      }
      if ((listing.salons ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.weekend,
          label: l10n.listingsSalons(listing.salons!),
        ));
      }
      if ((listing.kitchens ?? 0) > 0) {
        features.add(_buildFeatureChip(
          icon: Icons.kitchen,
          label: l10n.listingKitchensCount(listing.kitchens!),
        ));
      }
    }

    // Square meters
    if (listing.totalSquareMeters != null && listing.totalSquareMeters! > 0) {
      features.add(_buildFeatureChip(
        icon: Icons.square_foot,
        label: l10n.listingUnitM2(listing.totalSquareMeters!.toInt()),
      ));
    }

    // Facing direction
    if (listing.facingDirection != null) {
      features.add(_buildFeatureChip(
        icon: Icons.compass_calibration,
        label: listing.getLocalizedFacingDirection(context),
      ));
    }

    // Holding type
    if (listing.holdingType != null) {
      features.add(_buildFeatureChip(
        icon: Icons.folder_copy,
        label: listing.getLocalizedHoldingType(context),
      ));
    }

    // Date posted
    final daysOld = DateTime.now().difference(listing.createdAt).inDays;
    String dateText;
    if (daysOld == 0) {
      dateText = l10n.listingToday;
    } else if (daysOld == 1) {
      dateText = l10n.listingYesterday;
    } else if (daysOld < 7) {
      dateText = l10n.listingDaysAgo(daysOld);
    } else if (daysOld < 30) {
      dateText = l10n.listingWeeksAgo((daysOld / 7).floor());
    } else {
      dateText = l10n.listingMonthsAgo((daysOld / 30).floor());
    }
    features.add(_buildFeatureChip(
      icon: Icons.access_time,
      label: dateText,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsKeyFeatures, style: AppTextStyles.title),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: features.isNotEmpty
              ? features
              : [Text(l10n.listingsNoFeatures, style: AppTextStyles.caption)],
        ),
      ],
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent500),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsDescription, style: AppTextStyles.title),
        const SizedBox(height: 8),
        Text(
          listing.description?.isNotEmpty == true
              ? listing.description!
              : l10n.listingsNoDescription,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.theme.textTertiary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyDetails(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final details = <Map<String, String>>[];

    if (listing.propertyType == PropertyType.land) {
      // For land: front area and side area
      if ((listing.frontAreaSqm ?? 0) > 0) {
        details.add({
          'label': l10n.listingsFrontArea,
          'value': l10n.listingUnitM2(listing.frontAreaSqm!.toInt())
        });
      }
      if ((listing.sideAreaSqm ?? 0) > 0) {
        details.add({
          'label': l10n.listingsSideArea,
          'value': l10n.listingUnitM2(listing.sideAreaSqm!.toInt())
        });
      }
    }

    if (listing.useType != null) {
      details.add({
        'label': l10n.listingsUseType,
        'value': listing.getLocalizedUseType(context)
      });
    }
    if (listing.holdingType != null) {
      details.add({
        'label': l10n.listingsHoldingType,
        'value': listing.getLocalizedHoldingType(context)
      });

      // Free Hold details
      if (listing.holdingType == 'Free Hold') {
        if (listing.taxPaidUntilYear != null) {
          details.add({
            'label': l10n.listingTaxPaid,
            'value': listing.taxPaidUntilYear.toString()
          });
        }
        if (listing.acquisitionType != null) {
          details.add({
            'label': l10n.listingAcquisition,
            'value': listing.getLocalizedAcquisitionType(context)
          });
        }
      }

      // Lease Hold details
      if (listing.holdingType == 'Lease Hold') {
        if (listing.leasedYear != null) {
          details.add({
            'label': l10n.listingLeasedYear,
            'value': listing.leasedYear.toString()
          });
        }
        if (listing.leasePricePerSqm != null) {
          details.add({
            'label': l10n.listingLeasePrice,
            'value': '${listing.leasePricePerSqm!.toInt()} ETB'
          });
        }
        if (listing.annualPayment != null) {
          details.add({
            'label': l10n.listingAnnualPayment,
            'value': '${listing.annualPayment!.toInt()} ETB'
          });
        }
        if (listing.buildType != null) {
          details.add(
              {'label': l10n.listingBuildType, 'value': listing.buildType!});
        }
      }

      // Cooperative details
      if (listing.holdingType == 'Cooperative') {
        if (listing.cooperativeName != null) {
          details.add({
            'label': l10n.listingCooperativeName,
            'value': listing.cooperativeName!
          });
        }
        if (listing.cooperativeCode != null) {
          details.add({
            'label': l10n.listingCooperativeCode,
            'value': listing.cooperativeCode!
          });
        }
        if (listing.buildingStatus != null) {
          details.add({
            'label': l10n.listingBuildingStatus,
            'value': listing.buildingStatus == 'Finished'
                ? l10n.listingFinished
                : l10n.listingUnfinished
          });
        }
      }
    }
    if (listing.facingDirection != null) {
      details.add({
        'label': l10n.listingsFacing,
        'value': listing.getLocalizedFacingDirection(context)
      });
    }
    if (listing.priceRevisionPossible) {
      details.add(
          {'label': l10n.searchPriceRange, 'value': l10n.listingsNegotiable});
    }
    if (listing.hasDebtOrEncumbrance) {
      final debtAmount = listing.debtAmount;
      final amount = debtAmount != null
          ? l10n.listingsEncumbranceYes(debtAmount.toInt())
          : l10n.listingsYes;
      details.add({'label': l10n.listingsEncumbrance, 'value': amount});
    }
    bool hasVideo = (listing.videoUrl != null && listing.videoUrl!.isNotEmpty) || listing.videoBlocked;
    bool hasVideoProcessing = listing.hasVideoProcessing;
    bool vipBlocked = listing.vipBlocked;

    if (details.isEmpty && !hasVideo && !hasVideoProcessing && !vipBlocked) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasVideo) _buildVideoSection(listing),
        if (vipBlocked) _buildVipBlockedSection(listing),
        Text(l10n.listingsPropertyDetails, style: AppTextStyles.title),
        const SizedBox(height: 12),
        WaveCard(
          isGlass: true,
          showBorder: false,
          padding: EdgeInsets.zero,
          child: Column(
            children: details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: AppSpacing.paddingLg,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detail['label']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                        Text(
                          detail['value']!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < details.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, size: 20, color: AppColors.accent500),
              const SizedBox(width: 8),
              Text(l10n.listingsVideoTour, style: AppTextStyles.title),
              if (listing.videoProcessing != null && listing.videoProcessing!.status != VideoProcessingStatus.none) ...[
                const SizedBox(width: 8),
                _buildVideoStatusBadge(listing.videoProcessing!.status),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildVideoContent(listing),
        ],
      ),
    );
  }

  Widget _buildVipBlockedSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: UpgradeCard(
        icon: Icons.diamond_outlined,
        iconColor: AppColors.vip,
        title: l10n.listingUpgradeToVip,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        buttonLabel: l10n.ordersUpgradePlan,
      ),
    );
  }

  Widget _buildVideoStatusBadge(VideoProcessingStatus status) {
    final (Color bg, Color fg, String text) = switch (status) {
      VideoProcessingStatus.pending ||
      VideoProcessingStatus.processing =>
        (AppColors.warningLight, AppColors.warning, 'Processing'),
      VideoProcessingStatus.ready =>
        (AppColors.successLight, AppColors.success, 'Ready'),
      VideoProcessingStatus.failed =>
        (AppColors.errorLight, AppColors.error, 'Failed'),
      VideoProcessingStatus.none =>
        (AppColors.successLight, AppColors.success, 'Available'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildVideoContent(Listing listing) {
    final l10n = AppLocalizations.of(context);
    
    if (listing.videoBlocked) {
      return UpgradeCard(
        icon: Icons.workspace_premium_outlined,
        iconColor: AppColors.accent500,
        title: l10n.subscriptionVideoUpgrade,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        buttonLabel: l10n.ordersUpgradePlan,
      );
    }

    final vp = listing.videoProcessing;

    if (vp == null) {
      return VideoPlayerWidget(
        videoUrl: listing.videoUrl!,
        autoPlay: false,
        looping: false,
        title: l10n.listingsVideoTour,
      );
    }

    return switch (vp.status) {
      VideoProcessingStatus.pending ||
      VideoProcessingStatus.processing =>
        _buildProcessingIndicator(),
      VideoProcessingStatus.ready => Column(
          children: [
            VideoPlayerWidget(
              videoUrl: listing.processedVideoUrl ?? listing.videoUrl!,
              thumbnailUrl: vp.thumbnailUrl,
              autoPlay: false,
              looping: false,
              title: l10n.listingsVideoTour,
            ),
            const SizedBox(height: 8),
            _buildViewOriginalLink(listing.videoUrl!),
          ],
        ),
      VideoProcessingStatus.failed => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoPlayerWidget(
              videoUrl: listing.videoUrl!,
              thumbnailUrl: vp.thumbnailUrl,
              autoPlay: false,
              looping: false,
              title: l10n.listingsVideoTour,
            ),
            if (vp.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  vp.errorMessage!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                ),
              ),
          ],
        ),
      VideoProcessingStatus.none => VideoPlayerWidget(
          videoUrl: listing.videoUrl!,
          thumbnailUrl: vp.thumbnailUrl,
          autoPlay: false,
          looping: false,
          title: l10n.listingsVideoTour,
        ),
    };
  }

  Widget _buildProcessingIndicator() {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.listingsVideoOptimizing,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewOriginalLink(String originalUrl) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullScreenVideoScreen(videoUrl: originalUrl),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.listingsViewOriginal,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.accent500,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, size: 14, color: AppColors.accent500),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(int listingId, bool isFavorited) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
        );
      }
      return;
    }

    final success =
        await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final msg = isFavorited ? l10n.favoritesRemoved : l10n.favoritesAdded;
      if (success) {
        WaveToast.showSuccess(context, msg);
      } else {
        WaveToast.showError(context, msg);
      }
    }
  }

  Future<void> _shareListing(Listing listing) async {
    final shareText = '''
${listing.getLocalizedTitle(context)}
${listing.getLocalizedPrice(context)}
${listing.description?.isNotEmpty == true ? '\n${listing.description}' : ''}

Shared from WaveMart - Ethiopia's Premier Real Estate Marketplace
''';

    await Share.share(
      shareText,
      subject:
          'Check out this property on WaveMart: ${listing.getLocalizedTitle(context)}',
    );
  }

  Future<void> _editListing(Listing listing) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditListingScreen(listing: listing)),
    );
    if (result == true && mounted) {
      ref.read(listingDetailProvider.notifier).loadListing(listing.id);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.showConfirm(
      context: context,
      title: l10n.listingDeleteConfirmTitle,
      message: l10n.listingDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.deleteListing(listing.id);
      if (result.success && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _vipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.show<bool>(
      context: context,
      title: l10n.markAsVipTitle,
      message: l10n.markAsVipMessage,
      type: DialogType.confirm,
      actions: [
        WaveButton(
          text: l10n.commonCancel,
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        WaveButton(
          text: l10n.markAsVip,
          variant: ButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.vipListing(listing.id);
      if (result.success && mounted) {
        WaveToast.showSuccess(context, result.message);
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        WaveToast.showError(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _featureListing(Listing listing) async {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canFeatureListing) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.show<bool>(
      context: context,
      title: '${l10n.listingFeatureThis}?',
      message: 'Your listing will be featured on the home page and search results for 30 days.',
      type: DialogType.confirm,
      actions: [
        WaveButton(
          text: l10n.commonCancel,
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        WaveButton(
          text: l10n.listingFeatureNow,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.featureListing(listing.id);
      if (result.success && mounted) {
        WaveToast.showSuccess(context, result.message);
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        WaveToast.showError(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _unfeatureListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.showConfirm(
      context: context,
      title: 'Unfeature Listing?',
      message: 'Your listing will no longer appear as featured. You can feature it again later.',
      confirmLabel: 'Unfeature',
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.unfeatureListing(listing.id);
      if (result.success && mounted) {
        WaveToast.showSuccess(context, result.message);
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        WaveToast.showError(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _unvipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.showConfirm(
      context: context,
      title: 'Remove VIP Status?',
      message: 'Your listing will no longer be a VIP listing. You can mark it as VIP again later.',
      confirmLabel: 'Remove VIP',
      cancelLabel: l10n.commonCancel,
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.unvipListing(listing.id);
      if (result.success && mounted) {
        WaveToast.showSuccess(context, result.message);
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        WaveToast.showError(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Widget _buildActionButtons(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subState = ref.read(subscriptionProvider);

    // Check if current user is the owner
    final authState = ref.read(authStateProvider);
    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;

    final interestStatus = listing.userInterestStatus;
    final hasInterest = interestStatus != null;

    return WaveCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      isGlass: !isDark,
      color: isDark ? AppColors.primary800 : null,
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          // Owner action buttons
          if (isOwner) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editListing(listing),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(l10n.commonEdit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.theme.divider),
                      foregroundColor:
                          isDark ? AppColors.primary300 : AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteListing(listing),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text(l10n.commonDelete),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Feature toggle
            if (listing.isFeaturedActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      l10n.listingUpgradeToFeature.replaceFirst('Feature', 'Featured'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _unfeatureListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: Text(
                        'Unfeature',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.stone500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              subState.canFeatureListing
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _featureListing(listing),
                        icon: const Icon(Icons.workspace_premium_outlined, size: 20),
                        label: Text(l10n.listingFeatureThis),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.accent500),
                          foregroundColor: AppColors.accent500,
                        ),
                      ),
                    )
                  : UpgradeCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.accent500,
                      title: l10n.listingUpgradeToFeature,
                      subtitle: l10n.subscriptionRequiredFeatureSubtitle,
                    ),
            const SizedBox(height: 12),
            // VIP toggle
            if (listing.isVipActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.vip.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.vip.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.vip),
                    const SizedBox(width: 8),
                    Text(
                      l10n.markAsVip,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.vip,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _unvipListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: Text(
                        'Un-VIP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.stone500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _vipListing(listing),
                  icon: const Icon(Icons.diamond_outlined, size: 20),
                  label: Text(l10n.markAsVip),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.vip),
                    foregroundColor: AppColors.vip,
                  ),
                ),
              ),
          ],
          // Interest button - show status for all users
          Row(
            children: [
              if (!isOwner && !hasInterest)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: listing.interestBlocked
                      ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()))
                      : () => _submitInterest(listing.id),
                    icon: Icon(listing.interestBlocked ? Icons.lock_outline : Icons.handyman_outlined, size: 20),
                    label: Text(listing.interestBlocked ? l10n.upgradeToContact : l10n.listingsImInterested),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.accent500),
                      foregroundColor: AppColors.accent600,
                    ),
                  ),
                ),
              if (!isOwner && hasInterest)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _getInterestStatusColor(listing.userInterestStatus)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _getInterestStatusColor(listing.userInterestStatus),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getInterestStatusIcon(listing.userInterestStatus),
                          size: 20,
                          color: _getInterestStatusColor(
                              listing.userInterestStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getInterestStatusText(
                              listing.userInterestStatus, l10n),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getInterestStatusColor(
                                listing.userInterestStatus),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Contact reveal section — only when plan supports it
          if (!isOwner && listing.userContactHidden && !listing.contactRevealed && !listing.interestBlocked) ...[
            const SizedBox(height: 12),
            if (listing.contactMax > 0)
              _buildContactRevealSection(listing)
            else
              _buildContactUpgradeSection(listing),
          ],
          // Revealed contact info (non-owner, already revealed)
          if (!isOwner && listing.contactRevealed) ...[
            const SizedBox(height: 12),
            _buildRevealedContactSection(listing),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRevealSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent500.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent500.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 28, color: AppColors.accent600),
          const SizedBox(height: 8),
          Text(l10n.listingsRevealContact, style: AppTextStyles.title.copyWith(fontSize: 14)),
          if (listing.contactMax > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.listingsContactViewsRemaining(listing.contactRemaining, listing.contactMax),
              style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRevealingContact ? null : () => _revealContact(listing.id),
              icon: _isRevealingContact
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.visibility_outlined, size: 18),
              label: Text(_isRevealingContact ? l10n.listingsRevealing : l10n.listingsRevealContact),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUpgradeSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return UpgradeCard(
      icon: Icons.lock_outline,
      iconColor: AppColors.accent500,
      title: l10n.upgradeToContact,
      subtitle: l10n.subscriptionRequiredDetailsSubtitle,
      buttonLabel: l10n.listingViewPlans,
    );
  }

  Widget _buildRevealedContactSection(Listing listing) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 28, color: AppColors.success),
          const SizedBox(height: 8),
          Text(
            _revealedName?.isNotEmpty == true ? _revealedName! : l10n.listingsSeller,
            style: AppTextStyles.title.copyWith(fontSize: 14, color: AppColors.success),
          ),
          const SizedBox(height: 8),
          if (_revealedContact?.isNotEmpty == true)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.stone500),
                const SizedBox(width: 6),
                SelectableText(
                  _revealedContact!,
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
              ],
            ),
        ],
      ),
    );
  }

  bool _isRevealingContact = false;
  String? _revealedContact;
  String? _revealedName;

  Future<void> _revealContact(int listingId) async {
    setState(() => _isRevealingContact = true);
    try {
      final listingService = ListingService();
      final response = await listingService.revealContact(listingId);
      if (response.success && mounted) {
        setState(() {
          _revealedContact = response.contact;
          _revealedName = response.name;
        });
        // Reload listing to get contactRevealed=true
        ref.read(listingDetailProvider.notifier).loadListing(listingId);
      } else if (mounted) {
        WaveToast.showError(context, response.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    } finally {
      if (mounted) setState(() => _isRevealingContact = false);
    }
  }

  Future<void> _submitInterest(int listingId, [String? message]) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);

    try {
      final service = LeadService();
      final response = await service.expressInterest(
        listingId: listingId,
        message: message?.isNotEmpty == true
            ? message
            : l10n.listingsDefaultInterestMessage,
      );

      if (response.success) {
        if (mounted) {
          WaveToast.showSuccess(context, response.message);
          ref.read(listingDetailProvider.notifier).loadListing(listingId);
        }
      } else {
        if (mounted) {
          WaveToast.showError(context, response.message);
        }
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, l10n.commonError);
      }
    }
  }

  Color _getInterestStatusColor(String? status) {
    switch (status) {
      case 'new':
        return AppColors.warning;
      case 'won':
        return AppColors.emerald600;
      case 'lost':
        return AppColors.error;
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getInterestStatusIcon(String? status) {
    switch (status) {
      case 'new':
        return Icons.hourglass_empty;
      case 'won':
        return Icons.check_circle;
      case 'lost':
        return Icons.cancel;
      default:
        return Icons.trending_up;
    }
  }

  String _getInterestStatusText(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'new':
        return l10n.listingsInterestPending;
      case 'won':
        return l10n.listingsInterestAccepted;
      case 'lost':
        return l10n.listingsInterestRejected;
      default:
        return status ?? '';
    }
  }

  Widget _buildSimilarListings(Listing listing) {
    final l10n = AppLocalizations.of(context);
    final similarAsync = ref.watch(similarListingsProvider(listing.id));

    return similarAsync.when(
      data: (response) {
        final listings = response.listings;
        if (listings.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            const SizedBox(height: 24),
            Text(l10n.listingsSimilarListings, style: AppTextStyles.title),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final similar = listings[index];
                  return SizedBox(
                    width: 200,
                    child: _buildSimilarCard(similar),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSimilarCard(Listing similar) {
    final l10n = AppLocalizations.of(context);
    final imageUrl = similar.images.isNotEmpty
        ? similar.images.first.imageUrl
        : '';
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailScreen(listingId: similar.id),
          ),
        );
      },
      child: WaveCard(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primary100,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      color: AppColors.primary100,
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      similar.getLocalizedTitle(context, ref.watch(addressCacheProvider)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      similar.getLocalizedPrice(context),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.emerald600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (similar.totalSquareMeters != null && similar.totalSquareMeters! > 0)
                      Text(
                        l10n.listingUnitM2(similar.totalSquareMeters!.toInt()),
                        style: AppTextStyles.caption.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
