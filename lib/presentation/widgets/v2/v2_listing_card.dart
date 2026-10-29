import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../common/wave_card.dart';

/// Catalog card fed by the v2 [ListingSummary] projection.
///
/// Sits beside the legacy cards while screens migrate; the visual language
/// matches [PropertyListingCard] so lists do not jump between designs.
class V2ListingCard extends StatelessWidget {
  final ListingSummary listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final bool hideFavoriteButton;
  final List<Widget>? imageOverlayActions;

  const V2ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.hideFavoriteButton = false,
    this.imageOverlayActions,
  });

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 16,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrice(context),
                const SizedBox(height: 8),
                Text(
                  listing.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: context.theme.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.location.shortLabel.isEmpty
                            ? AppLocalizations.of(context)
                                .listingUnknownLocation
                            : listing.location.shortLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.theme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    // Jobs are never sold or rented; show only the kind chip.
                    if (listing.kind != ListingKind.job) ...[
                      _buildChip(
                        context,
                        listing.isRental
                            ? AppLocalizations.of(context).listingForRent
                            : AppLocalizations.of(context).listingForSale,
                        AppColors.primary600,
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildChip(
                      context,
                      _kindLabel(context),
                      AppColors.accent600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: listing.hasCoverImage
                ? CachedNetworkImage(
                    imageUrl: listing.coverImage!.url!,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    memCacheHeight: 300,
                    placeholder: (_, __) => _imagePlaceholder(context),
                    errorWidget: (_, __, ___) => _imagePlaceholder(context),
                  )
                : _imagePlaceholder(context),
          ),
        ),
        if (listing.hasCoverImage)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 72,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Row(
            children: [
              if (listing.isFeatured)
                _buildBadge(
                  AppLocalizations.of(context).listingFeatured,
                  AppColors.amber,
                ),
              if (listing.isVip) ...[
                const SizedBox(width: 6),
                _buildBadge(
                  AppLocalizations.of(context).vipBadge,
                  AppColors.accent600,
                ),
              ],
            ],
          ),
        ),
        if (imageOverlayActions != null)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Row(children: imageOverlayActions!),
          ),
        if (!hideFavoriteButton)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _buildFavoriteButton(),
          ),
        if (listing.imagesCount > 1)
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.imagesCount}',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color:
          context.theme.isDark ? AppColors.cardNavyLight : AppColors.primary50,
      child: Center(
        child: Icon(
          _kindIcon,
          size: 56,
          color: context.theme.textMuted,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: isTogglingFavorite ? null : onFavorite,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: isTogglingFavorite
            ? const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite ? AppColors.error : Colors.white,
              ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    final price = listing.price;
    final l10n = AppLocalizations.of(context);

    if (price.amount == null) {
      return Text(
        _missingPriceLabel(l10n),
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.accent600,
          fontWeight: FontWeight.w700,
        ),
      );
    }

    final base = l10n.listingsPriceFixed(smartDecimal(price.amount!));
    final period = price.isRecurring ? _periodLabel(context, price.period) : '';

    return Text(
      period.isEmpty ? base : '$base $period',
      style: AppTextStyles.titleSmall.copyWith(
        color: AppColors.accent600,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  /// Matches the legacy card wording: cars and jobs are negotiable, rentals
  /// without a price are "Per Agreement", and sales are "Price on Request".
  String _missingPriceLabel(AppLocalizations l10n) {
    switch (listing.kind) {
      case ListingKind.car:
        return listing.isRental
            ? l10n.carRentalPriceNegotiable
            : l10n.listingPriceOnRequest;
      case ListingKind.job:
        return l10n.carRentalPriceNegotiable;
      case ListingKind.house:
      case ListingKind.land:
      case ListingKind.unknown:
        return listing.isRental
            ? l10n.listingPricePerAgreement
            : l10n.listingPriceOnRequest;
    }
  }

  String _periodLabel(BuildContext context, String? period) {
    final l10n = AppLocalizations.of(context);

    switch (period) {
      case 'day':
        return l10n.listingPerDay;
      case 'month':
        return l10n.listingPerMonth;
      case 'year':
        return l10n.listingPerYear;
      case 'week':
        return '/ week';
      default:
        return period == null ? l10n.listingPerMonth : '/ $period';
    }
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  IconData get _kindIcon {
    switch (listing.kind) {
      case ListingKind.house:
        return Icons.home_rounded;
      case ListingKind.land:
        return Icons.landscape_outlined;
      case ListingKind.car:
        return Icons.directions_car_rounded;
      case ListingKind.job:
        return Icons.work_outline;
      case ListingKind.unknown:
        return Icons.apartment_rounded;
    }
  }

  String _kindLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (listing.kind) {
      case ListingKind.house:
      case ListingKind.land:
        return l10n.listingSummaryProperty;
      case ListingKind.car:
        return l10n.listingCarPlural;
      case ListingKind.job:
        return l10n.homeJobs;
      case ListingKind.unknown:
        return l10n.searchFilterAll;
    }
  }
}

/// Skeleton card matching [V2ListingCard] while a page loads.
class V2ListingCardSkeleton extends StatelessWidget {
  const V2ListingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 16,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
      child: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(color: context.shimmerBase),
            ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _block(context, 22, 130),
                  const SizedBox(height: 8),
                  _block(context, 16, double.infinity),
                  const SizedBox(height: 6),
                  _block(context, 14, 200),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _block(context, 22, 55),
                      const SizedBox(width: 8),
                      _block(context, 22, 55),
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

  Widget _block(BuildContext context, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
