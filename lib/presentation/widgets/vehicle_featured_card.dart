import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/car_data.dart';
import '../../data/models/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import 'common/wave_card.dart';

class VehicleFeaturedCard extends ConsumerWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;

  const VehicleFeaturedCard({
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
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadgesRow(context),
                  const SizedBox(height: 8),
                  _buildPrice(context),
                  const SizedBox(height: 4),
                  _buildTitle(context),
                  const SizedBox(height: 8),
                  _buildSpecs(context),
                  const SizedBox(height: 6),
                  _buildLocation(context, ref),
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
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 32,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(
                    Icons.directions_car_outlined,
                    size: 36,
                    color: AppColors.primary300,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isTogglingFavorite ? null : onFavorite,
                child: Container(
                  padding: const EdgeInsets.all(6),
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
    final isRent = listing?.listingType == ListingType.rental;
    final cat = listing?.carVehicleCategory;
    return Row(
      children: [
        if (cat != null && cat.isNotEmpty) ...[
          _buildBadge(vehicleCategoryLabel(cat, l10n), AppColors.primary600),
          const SizedBox(width: 4),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isRent ? AppColors.accent600 : AppColors.emerald600,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isRent ? l10n.listingForRent : l10n.listingForSale,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 4),
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

  Widget _buildTitle(BuildContext context) {
    final title = listing?.carTitle;
    if (title == null || title.isEmpty) return const SizedBox.shrink();
    return Text(
      title,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.theme.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSpecs(BuildContext context) {
    final chips = <Widget>[];
    final mileage = listing?.carMileageKm;
    final bodyType = listing?.carBodyType;
    final condition = listing?.carCondition;

    if (mileage != null) {
      final unit = listing?.carVehicleCategory == 'construction_equipment' ? ' hrs' : ' km';
      chips.add(_specChip(
        Icons.speed_rounded,
        '${mileage.toStringAsFixed(0)}$unit',
      ));
    }
    if (bodyType != null) {
      chips.add(const SizedBox(width: 6));
      chips.add(_specChip(Icons.directions_car_rounded, bodyType));
    }
    if (condition != null && chips.isEmpty) {
      chips.add(const SizedBox(width: 6));
      chips.add(_specChip(Icons.build_outlined, condition));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Row(children: chips);
  }

  Widget _specChip(IconData icon, String label) {
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
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
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
                  child: Container(color: context.shimmerBase),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _skeletonBlock(context, 50, 18),
                        const SizedBox(width: 6),
                        _skeletonBlock(context, 60, 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _skeletonBlock(context, 100, 18),
                    const SizedBox(height: 6),
                    _skeletonBlock(context, 120, 12),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _skeletonBlock(context, 60, 14),
                        const SizedBox(width: 8),
                        _skeletonBlock(context, 50, 14),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _skeletonBlock(context, 100, 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonBlock(BuildContext context, double width, double height) {
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
