import '../../core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../presentation/providers/app_providers.dart';
import 'common/wave_card.dart';
import 'common/wave_glass.dart';

/// Property Listing Card Widget
class PropertyListingCard extends ConsumerWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;
  final bool hideFavoriteButton;

  const PropertyListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.isLoading = false,
    this.hideFavoriteButton = false,
  });

  void _handleTap() {
    if (onTap != null) {
      HapticFeedback.lightImpact();
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) return _buildSkeleton();

    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrice(context),
                const SizedBox(height: 10),

                _buildDescription(),
                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildLocation(context, ref)),
                    _buildDatePosted(context),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                const Divider(height: 1),
                const SizedBox(height: 16),

                // Features Row
                _buildFeatures(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary200),
        boxShadow: AppColors.shadowMd,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Icon(Icons.home_rounded,
                        size: 40, color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 22,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _skeletonChip(55),
                      const SizedBox(width: 8),
                      _skeletonChip(55),
                      const SizedBox(width: 8),
                      _skeletonChip(45),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonChip(double width) {
    return Container(
      height: 22,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        // Main Image (Using Thumbnail)
        Hero(
          tag: 'listing_image_${listing?.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 64,
                    color: AppColors.primary300,
                  ),
                ),
                imageBuilder: (context, imageProvider) => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay (web style)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Badges Overlay
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Row(
            children: [
              if (listing?.isNew ?? false)
                _buildBadge(l10n.listingNew, AppColors.primary600),
              if (listing?.isFeatured ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: _buildBadge(l10n.listingFeatured, AppColors.accent600),
                ),
            ],
          ),
        ),

        // Favorite Button
        if (!hideFavoriteButton)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: GestureDetector(
              onTap: isTogglingFavorite ? null : onFavorite,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isFavorite
                      ? Colors.red.withValues(alpha: 0.95)
                      : Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isTogglingFavorite
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: Colors.white,
                      ),
              ),
            ),
          ),

        // Image Count Badge
        if ((listing?.imageCount ?? 0) > 1)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.md + 36,
            child: WaveGlass(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library,
                      size: 12, color: context.textPrimary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${listing?.imageCount ?? 0}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: context.textPrimary),
                  ),
                ],
              ),
            ),
          ),

        // Property Type Badge (bottom-left, glass overlay)
        Positioned(
          bottom: AppSpacing.sm,
          left: AppSpacing.sm,
          child: WaveGlass(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  listing?.propertyType == PropertyType.house
                      ? Icons.home
                      : Icons.landscape,
                  size: 14,
                  color: context.textPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  listing?.propertyType == PropertyType.house
                      ? l10n.listingHouse
                      : l10n.listingLand,
                  style: AppTextStyles.badge.copyWith(
                    color: context.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      listing?.getLocalizedPrice(context) ??
          AppLocalizations.of(context).listingPriceOnRequest,
      style: AppTextStyles.priceMedium,
    );
  }

  Widget _buildDescription() {
    final description = listing?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    final location = listing?.address?.getLocalizedAddress(context, cache) ??
        listing?.address?.region ??
        l10n.listingUnknownLocation;
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: AppColors.primary500,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePosted(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = listing?.createdAt;
    if (date == null) return const SizedBox.shrink();
    final daysOld = DateTime.now().difference(date).inDays;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 12, color: AppColors.primary300),
        const SizedBox(width: 4),
        Text(
          dateText,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary500),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isHouse = listing?.propertyType == PropertyType.house;
    return Row(
      children: [
        if (isHouse) ...[
          if ((listing?.bedrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bed_outlined, '${listing?.bedrooms}'),
          if ((listing?.bathrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bathtub_outlined, '${listing?.bathrooms}'),
          if ((listing?.salons ?? 0) > 0)
            _buildFeatureChip(Icons.weekend_outlined, '${listing?.salons}'),
        ] else ...[
          _buildFeatureChip(
            Icons.square_foot_outlined,
            l10n.listingUnitM2(listing?.totalSquareMeters?.toInt() ?? 0),
          ),
        ],
        const SizedBox(width: 8),
        _buildFeatureChip(
          Icons.sell_outlined,
          listing?.listingType == ListingType.sale
              ? l10n.listingSale
              : l10n.listingRent,
        ),
        const Spacer(),
        Icon(
          Icons.visibility_outlined,
          size: 16,
          color: AppColors.primary400,
        ),
        const SizedBox(width: 4),
        Text(
          '${(DateTime.now().millisecondsSinceEpoch % 100).toInt() + 20}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary500),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Featured Listing Card - Horizontal layout with image on the left
class FeaturedListingCard extends ConsumerWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;

  const FeaturedListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.isTogglingFavorite = false,
    this.isLoading = false,
  });

  void _handleTap() {
    if (onTap != null) {
      HapticFeedback.lightImpact();
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading || listing == null) return _buildSkeleton();

    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section (Left)
          Expanded(flex: 2, child: _buildImageSection()),

          // Content Section (Right)
          Expanded(
            flex: 3,
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  _buildBadgesRow(context),
                  const SizedBox(height: 10),

                  // Price
                  _buildPrice(context),
                  const SizedBox(height: 6),

                  // Description
                  _buildDescription(),
                  const SizedBox(height: 10),

                  // Location
                  _buildLocation(context, ref),
                  const SizedBox(height: 8),

                  // Features Row
                  _buildFeatures(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
      child: SizedBox(
        width: 130,
        height: double.infinity,
        child: Stack(
          children: [
            // Main Image (Using Thumbnail)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey[200]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: AppColors.primary300,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(
                    Icons.home_outlined,
                    size: 36,
                    color: AppColors.primary300,
                  ),
                ),
              ),
            ),

            // Favorite Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isTogglingFavorite ? null : onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm - 2),
                  decoration: BoxDecoration(
                    color: isFavorite
                        ? Colors.red.withValues(alpha: 0.85)
                        : Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: isTogglingFavorite
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        // Property Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary600,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                listing?.propertyType == PropertyType.house
                    ? Icons.home
                    : Icons.landscape,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 3),
              Text(
                listing?.propertyType == PropertyType.house
                    ? l10n.listingHouse
                    : l10n.listingLand,
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        if (listing?.isNew == true)
          _buildBadge(l10n.listingNew, AppColors.primary600),
        if (listing?.isFeatured == true)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildBadge(l10n.listingFeatured, AppColors.accent600),
          ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      listing?.getLocalizedPrice(context) ??
          AppLocalizations.of(context).listingPriceOnRequest,
      style: AppTextStyles.priceMedium.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    final description = listing?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 11,
        color: AppColors.primary600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: AppColors.primary500,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            listing?.address?.getLocalizedAddress(context, cache) ??
                listing?.address?.region ??
                l10n.listingUnknownLocation,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isHouse = listing?.propertyType == PropertyType.house;
    return Row(
      children: [
        if (isHouse) ...[
          if ((listing?.bedrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bed_outlined, '${listing?.bedrooms}'),
          if ((listing?.bathrooms ?? 0) > 0)
            _buildFeatureChip(Icons.bathtub_outlined, '${listing?.bathrooms}'),
        ] else ...[
          _buildFeatureChip(
            Icons.square_foot_outlined,
            l10n.listingUnitM2(listing?.totalSquareMeters?.toInt() ?? 0),
          ),
        ],
        const SizedBox(width: 4),
        _buildFeatureChip(
          Icons.sell_outlined,
          listing?.listingType == ListingType.sale
              ? l10n.listingSale
              : l10n.listingRent,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary400),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return WaveCard(
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton (left)
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(4)),
                child: SizedBox(
                  width: 130,
                  height: double.infinity,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),
            // Content skeleton (right)
            Expanded(
              flex: 3,
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 60,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 18,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 40,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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
