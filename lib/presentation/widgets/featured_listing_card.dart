import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import 'common/wave_card.dart';

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
    if (isLoading || listing == null) return _buildSkeleton(context);

    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildImageSection(context)),

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
                  _buildDescription(context),
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

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
      child: SizedBox(
        width: 130,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: context.shimmerBase,
                  highlightColor: context.shimmerHighlight,
                  child: Container(
                    color: context.shimmerBase,
                    child: Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: context.theme.textMuted,
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
        if (listing?.isVip == true)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildBadge(l10n.vipBadge, AppColors.vip),
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

  Widget _buildDescription(BuildContext context) {
    final description = listing?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 11,
        color: context.theme.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    
    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: AppColors.primary500,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  listing?.address?.getLocalizedAddress(context, cache, isRestricted) ??
                      listing?.address?.region ??
                      l10n.listingUnknownLocation,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRestricted) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock_outline, size: 10, color: Colors.white70),
              ],
            ],
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

  Widget _buildSkeleton(BuildContext context) {
    return WaveCard(
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
      child: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(4)),
                child: SizedBox(
                  width: 130,
                  height: double.infinity,
                  child: Container(
                    color: context.shimmerBase,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _featuredSkeletonBlock(context, 50, 18),
                        const SizedBox(width: 6),
                        _featuredSkeletonBlock(context, 60, 18),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _featuredSkeletonBlock(context, 100, 18),
                    const SizedBox(height: 6),
                    _featuredSkeletonBlock(context, 120, 12),
                    const SizedBox(height: 10),
                    _featuredSkeletonBlock(context, 100, 12),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _featuredSkeletonBlock(context, 45, 16),
                        const SizedBox(width: 6),
                        _featuredSkeletonBlock(context, 40, 16),
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

  Widget _featuredSkeletonBlock(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
