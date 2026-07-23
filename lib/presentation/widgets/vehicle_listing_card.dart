import 'dart:math' as math;

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
import 'common/wave_glass.dart';

class VehicleListingCard extends ConsumerStatefulWidget {
  final Listing? listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final bool isTogglingFavorite;
  final bool isLoading;
  final List<Widget>? imageOverlayActions;

  const VehicleListingCard({
    super.key,
    this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.isTogglingFavorite = false,
    this.isLoading = false,
    this.imageOverlayActions,
  });

  @override
  ConsumerState<VehicleListingCard> createState() =>
      _VehicleListingCardState();
}

class _VehicleListingCardState extends ConsumerState<VehicleListingCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _borderController;
  Animation<double>? _borderAnimation;

  @override
  void initState() {
    super.initState();
    _initBorderAnimation();
  }

  @override
  void didUpdateWidget(VehicleListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final was = oldWidget.listing?.isVip == true ||
        oldWidget.listing?.isFeatured == true;
    final now = widget.listing?.isVip == true ||
        widget.listing?.isFeatured == true;
    if (now != was) {
      _borderController?.dispose();
      _borderController = null;
      _borderAnimation = null;
      if (now) _initBorderAnimation();
    }
  }

  void _initBorderAnimation() {
    if (widget.listing?.isVip == true || widget.listing?.isFeatured == true) {
      _borderController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
      _borderAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        _borderController!,
      );
    }
  }

  @override
  void dispose() {
    _borderController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading || widget.listing == null) {
      return _buildSkeleton(context);
    }

    final card = _buildCardContent(context);
    final hasBorder = widget.listing?.isVip == true ||
        widget.listing?.isFeatured == true;

    if (hasBorder && _borderAnimation != null) {
      return AnimatedBuilder(
        animation: _borderAnimation!,
        builder: (_, child) => _buildAnimatedBorder(child!),
        child: card,
      );
    }

    return card;
  }

  Widget _buildAnimatedBorder(Widget child) {
    final isVip = widget.listing?.isVip == true;
    final baseColor = isVip ? AppColors.vip : AppColors.accent500;
    final value = _borderAnimation?.value ?? 0;
    final opacity = (math.sin(value) * 0.35 + 0.65).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: baseColor.withValues(alpha: opacity),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.5),
        child: child,
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 4,
      padding: EdgeInsets.zero,
      useLiquidGlass: false,
      child: Column(
        children: [
          _buildImageSection(context),
          _buildContentSection(context),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRent = widget.listing?.listingType == ListingType.rental;
    final vehicleCategory = widget.listing?.carVehicleCategory;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        child: SizedBox(
          width: double.infinity,
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: context.shimmerBase,
                  highlightColor: context.shimmerHighlight,
                  child: Container(
                    color: context.shimmerBase,
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 36,
                      color: context.theme.textMuted,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.primary100,
                  child: const Icon(
                    Icons.directions_car_outlined,
                    size: 40,
                    color: AppColors.primary300,
                  ),
                ),
              ),

              // Sale/Rent badge — top-left
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRent ? AppColors.accent600 : AppColors.emerald600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isRent ? l10n.listingForRent : l10n.listingForSale,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              // Favorite heart — top-right
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: widget.isTogglingFavorite ? null : widget.onFavorite,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isFavorite
                          ? Colors.red.withValues(alpha: 0.85)
                          : Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: widget.isTogglingFavorite
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              // Vehicle category badge — bottom-left
              if (vehicleCategory != null && vehicleCategory.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: WaveGlass(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIcon(vehicleCategory),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          vehicleCategoryLabel(vehicleCategory, l10n),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Owner action overlays
              if (widget.imageOverlayActions != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.imageOverlayActions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrice(context),
          const SizedBox(height: 6),
          _buildHairline(context),
          const SizedBox(height: 10),
          _buildTitle(context),
          const SizedBox(height: 8),
          _buildVehicleSpecs(context),
          const SizedBox(height: 6),
          _buildLocation(context),
    ],
      ),
    );
  }

  Widget _buildHairline(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 1,
      width: 40,
      color: isDark
          ? Colors.white.withValues(alpha: 0.15)
          : Colors.black.withValues(alpha: 0.1),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(
      widget.listing?.getLocalizedPrice(context) ??
          AppLocalizations.of(context).listingPriceOnRequest,
      style: AppTextStyles.priceMedium.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.listing?.carTitle ?? 'Vehicle',
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: context.theme.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildVehicleSpecs(BuildContext context) {
    final listing = widget.listing;
    final cat = listing?.carVehicleCategory;
    final chips = <Widget>[];

    if (cat != 'bicycle') {
      final year = listing?.carYear;
      if (year != null) {
        chips.add(_specChip(Icons.calendar_today_rounded, year.toString()));
      }
      final km = listing?.carMileageKm;
      if (km != null) {
        final unit = cat == 'construction_equipment' ? ' hrs' : ' km';
        chips.add(_specChip(Icons.speed_rounded, '${km.toStringAsFixed(0)}$unit'));
      }
    }
    if (cat == 'car' || cat == 'construction_equipment') {
      final bt = listing?.carBodyType;
      if (bt != null && bt.isNotEmpty) {
        chips.add(_specChip(Icons.directions_car_rounded, bt));
      }
    }
    final cond = listing?.carCondition;
    if (cond != null && chips.isEmpty) {
      chips.add(_specChip(Icons.build_outlined, cond));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: chips,
    );
  }

  Widget _specChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.primary400),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cache = ref.watch(addressCacheProvider);
    final subState = ref.watch(subscriptionProvider);
    final isRestricted = !subState.canSeeFullAddress;

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 13,
          color: AppColors.primary400,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.listing?.address?.getLocalizedAddress(context, cache, isRestricted) ??
                widget.listing?.address?.region ??
                l10n.listingUnknownLocation,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.primary400,
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
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'motorcycle': return Icons.motorcycle_rounded;
      case 'bicycle': return Icons.pedal_bike_rounded;
      case 'construction_equipment': return Icons.construction_rounded;
      default: return Icons.directions_car_rounded;
    }
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
              child: Container(
                width: double.infinity,
                height: 200,
                color: context.shimmerBase,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBlock(context, 140, 24),
                  const SizedBox(height: 8),
                  _skeletonBlock(context, 40, 1),
                  const SizedBox(height: 10),
                  _skeletonBlock(context, 180, 14),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _skeletonBlock(context, 70, 14),
                      const SizedBox(width: 12),
                      _skeletonBlock(context, 60, 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _skeletonBlock(context, 120, 12),
                ],
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
