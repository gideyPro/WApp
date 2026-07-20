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
import 'common/wave_liquid_glass.dart';

class CarListingCard extends ConsumerWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;
  final bool hideFavoriteButton;
  final List<Widget>? imageOverlayActions;

  const CarListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.isTogglingFavorite = false,
    this.isLoading = false,
    this.hideFavoriteButton = false,
    this.imageOverlayActions,
  });

  void _handleTap() {
    if (onTap != null) {
      HapticFeedback.lightImpact();
      onTap!();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) return _buildSkeleton(context);

    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
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
                _buildTitle(context),
                const SizedBox(height: 6),
                _buildPrice(context),
                const SizedBox(height: 10),
                _buildDescription(context),
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
                _buildFeatures(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return LiquidGlass(
      borderRadius: 4,
      blur: 20,
      margin: const EdgeInsets.only(bottom: 16),
      child: Shimmer.fromColors(
        baseColor: context.shimmerBase,
        highlightColor: context.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  color: context.shimmerBase,
                  child: Center(
                    child: Icon(Icons.directions_car,
                        size: 40, color: context.theme.textMuted),
                  ),
                ),
              ),
            ),
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBlock(context, 22, 180),
                  const SizedBox(height: 6),
                  _skeletonBlock(context, 22, 120),
                  const SizedBox(height: 8),
                  _skeletonBlock(context, 16, double.infinity),
                  const SizedBox(height: 6),
                  _skeletonBlock(context, 14, 200),
                  const SizedBox(height: 8),
                  _skeletonBlock(context, 14, 180),
                  const SizedBox(height: 6),
                  _skeletonBlock(context, 12, 70),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _skeletonChip(context, 70),
                      const SizedBox(width: 8),
                      _skeletonChip(context, 50),
                      const SizedBox(width: 8),
                      _skeletonChip(context, 60),
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

  Widget _skeletonBlock(BuildContext context, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _skeletonChip(BuildContext context, double width) {
    return Container(
      height: 22,
      width: width,
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        Hero(
          tag: 'car_image_${listing?.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: context.shimmerBase,
                  highlightColor: context.shimmerHighlight,
                  child: Container(
                    color: context.shimmerBase,
                    child: Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 40,
                        color: context.theme.textMuted,
                      ),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(
                    Icons.directions_car_outlined,
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

        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          child: Row(
            children: [
              if (listing?.status == ListingStatus.frozen)
                _buildBadge(l10n.statusFrozen, AppColors.error),
              if (listing?.isNew ?? false)
                _buildBadge(l10n.listingNew, AppColors.primary600),
              if (listing?.isFeatured ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: _buildBadge(l10n.listingFeatured, AppColors.accent600),
                ),
              if (listing?.isVip ?? false)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.xs),
                  child: _buildBadge(l10n.vipBadge, AppColors.vip),
                ),
            ],
          ),
        ),

        if (imageOverlayActions != null)
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: imageOverlayActions!,
            ),
          )
        else if (!hideFavoriteButton)
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
                  Icons.directions_car,
                  size: 14,
                  color: context.textPrimary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Vehicle',
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

  Widget _buildTitle(BuildContext context) {
    return Text(
      listing?.carTitle ?? '',
      style: AppTextStyles.priceMedium,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      listing?.getLocalizedPrice(context) ??
          AppLocalizations.of(context).listingPriceOnRequest,
      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final description = listing?.description;
    if (description == null || description.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      description,
      style:
          AppTextStyles.bodySmall.copyWith(color: context.theme.textSecondary),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);

    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    final location = listing?.address?.getLocalizedAddress(context, cache, isRestricted) ??
        listing?.address?.region ??
        l10n.listingUnknownLocation;
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 14,
          color: context.theme.iconSecondary,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  location,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRestricted) ...[
                const SizedBox(width: 4),
                Icon(Icons.lock_outline, size: 10, color: context.theme.textMuted),
              ],
            ],
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
    return Row(
      children: [
        if (listing?.carYear != null)
          _buildFeatureChip(Icons.calendar_today, '${listing!.carYear}'),
        if (listing?.carMileageKm != null)
          _buildFeatureChip(Icons.speed, '${listing!.carMileageKm!.toInt()} km'),
        if (listing?.carTransmission != null)
          _buildFeatureChip(Icons.settings, listing!.carTransmission!),
        const Spacer(),
        const Icon(
          Icons.visibility_outlined,
          size: 16,
          color: AppColors.primary400,
        ),
        const SizedBox(width: 4),
        Text(
          '${listing?.viewCount ?? 0}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
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
      ),
    );
  }
}
