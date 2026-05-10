import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import 'common/wave_card.dart';

class PropertyListingCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton();

    return WaveCard(
      onTap: _handleTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      borderRadius: AppSpacing.borderRadiusXxl,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrice(context),
                const SizedBox(height: 10),
                _buildDescription(),
                const SizedBox(height: AppSpacing.md),
                _buildLocation(context),
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

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.zinc200), boxShadow: AppColors.shadowMd),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            AspectRatio(aspectRatio: 4 / 3, child: Container(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 22, width: 130, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 16, width: double.infinity, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        Hero(
          tag: 'listing_image_${listing?.id}',
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(
                imageUrl: listing?.mainThumbnailUrl ?? '',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppColors.navy100, child: const Icon(Icons.home_outlined, size: 64, color: AppColors.navy300)),
              ),
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.md, left: AppSpacing.md,
          child: Row(
            children: [
              if (listing?.isNew ?? false) _buildBadge(l10n.listingNew, AppColors.emerald500),
              if (listing?.isFeatured ?? false) Padding(padding: const EdgeInsets.only(left: AppSpacing.xs), child: _buildBadge(l10n.listingFeatured, AppColors.wave500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm)),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: Colors.white)),
    );
  }

  Widget _buildPrice(BuildContext context) {
    return Text(listing?.getLocalizedPrice(context) ?? AppLocalizations.of(context).listingPriceOnRequest, style: AppTextStyles.priceMedium);
  }

  Widget _buildDescription() {
    final description = listing?.description;
    return Text(description ?? '', style: AppTextStyles.bodySmall.copyWith(color: AppColors.zinc600), maxLines: 2, overflow: TextOverflow.ellipsis);
  }

  Widget _buildLocation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.wave500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(listing?.address?.getLocalizedAddress(context) ?? listing?.address?.region ?? l10n.listingUnknownLocation, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _buildFeatureChip(Icons.sell_outlined, listing?.listingType == ListingType.sale ? l10n.listingSale : l10n.listingRent),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.navy500),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class FeaturedListingCard extends StatelessWidget {
  final Listing? listing;
  final VoidCallback? onTap;

  const FeaturedListingCard({super.key, this.listing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return WaveCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: 24,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(flex: 2, child: _buildImageSection()),
          Expanded(flex: 3, child: Padding(padding: const EdgeInsets.all(16), child: Text(listing?.getLocalizedTitle(context) ?? '', style: AppTextStyles.titleSmall))),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
      child: SizedBox(
        width: 130, height: 140,
        child: CachedNetworkImage(imageUrl: listing?.mainThumbnailUrl ?? '', fit: BoxFit.cover),
      ),
    );
  }
}
