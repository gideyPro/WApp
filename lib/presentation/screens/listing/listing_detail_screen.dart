import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/v2/api_v2_error.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/v2/listing_detail.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/v2_favorites_provider.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/v2/v2_listing_card.dart';

/// Listing Detail Screen wired to V2 `/v2/listings/{id}`.
///
/// Owners see moderation state and affordances (edit/submit/delete/feature).
/// Public viewers see catalog data only — never moderation state.
class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  Timer? _videoPollTimer;
  bool _isFavoriteToggling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoPollTimer?.cancel();
    super.dispose();
  }

  Widget _buildSkeletonLoader() {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: context.shimmerBase,
              highlightColor: context.shimmerHighlight,
              child: Column(
                children: [
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
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: context.shimmerHighlight),
                  ),
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Shimmer.fromColors(
                baseColor: context.shimmerBase,
                highlightColor: context.shimmerHighlight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.shimmerHighlight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 14,
                          width: 200,
                          decoration: BoxDecoration(
                            color: context.shimmerHighlight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(12),
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
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
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
    return WaveMessageScreen.error(
      title: l10n.listingsLoadError,
      subtitle: message,
      onRetry: () {
        ref.invalidate(listingDetailV2Provider(widget.listingId));
      },
      isEmbedded: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailAsync = ref.watch(listingDetailV2Provider(widget.listingId));

    return detailAsync.when(
      data: (detail) => _buildContent(context, l10n, detail),
      loading: () => _buildSkeletonLoader(),
      error: (error, stack) => _buildErrorView(
        error is ApiV2Exception ? error.message : l10n.commonError,
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, AppLocalizations l10n, ListingDetail detail) {
    final viewer = detail.viewer;
    final isOwner = viewer.isOwner;
    final isFavorite = viewer.isFavorite;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(detail),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.error : Colors.white,
                ),
                onPressed: () => _toggleFavorite(detail, isFavorite),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareListing(detail, l10n),
              ),
            ],
          ),
          SliverPadding(
            padding: AppSpacing.paddingLg,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Price + Title
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.title,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: context.theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatPrice(l10n, detail),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent600,
                            ),
                          ),
                          if (detail.price.isRecurring &&
                              detail.price.period != null)
                            Text(
                              '/ ${detail.price.period}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.theme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Badges row
                Row(
                  children: [
                    if (detail.isFeatured)
                      _buildBadge(context, l10n.listingsFeatured,
                          AppColors.accent500, Colors.white),
                    if (detail.isFeatured) const SizedBox(width: 8),
                    if (detail.isVip)
                      _buildBadge(context, 'VIP', AppColors.vip, Colors.white),
                    if (detail.isVip) const SizedBox(width: 8),
                    _buildBadge(
                      context,
                      detail.listingType == 'rental'
                          ? l10n.listingForRent
                          : l10n.listingForSale,
                      detail.listingType == 'rental'
                          ? AppColors.primary600
                          : AppColors.accent500,
                      Colors.white,
                    ),
                    const Spacer(),
                    if (detail.price.negotiable)
                      _buildBadge(context, 'Negotiable', AppColors.stone500,
                          Colors.white),
                  ],
                ),
                const SizedBox(height: 16),

                // Location
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
                        detail.location.shortLabel.isEmpty
                            ? l10n.listingUnknownLocation
                            : detail.location.shortLabel,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: context.theme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                if (detail.description != null &&
                    detail.description!.isNotEmpty) ...[
                  Text(
                    l10n.listingsDescription,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Details (attributes + type-specific details)
                _buildDetailsSection(context, l10n, detail),
                const SizedBox(height: 24),

                // Holding type
                if (!detail.holdingDetails.isEmpty) ...[
                  Text(
                    l10n.listingsHoldingType,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildHoldingRow(context, detail),
                  const SizedBox(height: 24),
                ],

                // Video section
                if (detail.video.hasUrl || detail.video.blocked) ...[
                  _buildVideoSection(context, l10n, detail),
                  const SizedBox(height: 24),
                ],

                // Owner actions
                if (isOwner) ...[
                  _buildOwnerActions(context, l10n, detail, isOwner),
                  const SizedBox(height: 24),
                ],

                // Similar listings
                if (detail.similar.isNotEmpty) ...[
                  Text(
                    l10n.listingsSimilarListings,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: detail.similar.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final similar = detail.similar[index];
                        return SizedBox(
                          width: 200,
                          child: V2ListingCard(
                            listing: similar,
                            isFavorite: similar.isFavorite,
                            isTogglingFavorite: false,
                            hideFavoriteButton: false,
                            onTap: () => context.push(
                              _routeForKind(similar.kind, similar.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(ListingDetail detail) {
    final images = detail.images;
    if (images.isEmpty) {
      return Container(
        color: AppColors.primary100,
        child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return CachedNetworkImage(
              imageUrl: image.url!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (_, __) => Container(color: AppColors.primary100),
              errorWidget: (_, __, ___) =>
                  const Center(child: Icon(Icons.image_not_supported)),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: i == 0 ? 0.9 : 0.4,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsSection(
      BuildContext context, AppLocalizations l10n, ListingDetail detail) {
    final attrs = detail.attributes;
    final details = detail.details;
    final rows = <Widget>[];

    if (attrs.totalSquareMeters != null && attrs.totalSquareMeters! > 0) {
      rows.add(_buildDetailRow(
        context,
        l10n.listingUnitM2(smartDecimal(attrs.totalSquareMeters!)),
        Icons.square_foot,
      ));
    }

    if (details.bedrooms != null && details.bedrooms! > 0) {
      rows.add(_buildDetailRow(
        context,
        l10n.listingsBedrooms(details.bedrooms!),
        Icons.bed,
      ));
    }

    if (details.bathrooms != null && details.bathrooms! > 0) {
      rows.add(_buildDetailRow(
        context,
        l10n.listingsBathrooms(details.bathrooms!),
        Icons.bathtub,
      ));
    }

    if (details.areaSqm != null && details.areaSqm! > 0) {
      rows.add(_buildDetailRow(
        context,
        l10n.listingUnitM2(smartDecimal(details.areaSqm!)),
        Icons.square_foot,
      ));
    }

    if (details.houseType != null && details.houseType!.isNotEmpty) {
      rows.add(_buildDetailRow(context, details.houseType!, Icons.home));
    }

    if (details.make != null && details.model != null) {
      rows.add(_buildDetailRow(
        context,
        '${details.year != null ? details.year! : ''} ${details.make!} ${details.model!}',
        Icons.directions_car,
      ));
    }

    if (details.companyName != null && details.companyName!.isNotEmpty) {
      rows.add(_buildDetailRow(context, details.companyName!, Icons.business));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.listingsKeyFeatures,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rows,
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.theme.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.theme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingRow(BuildContext context, ListingDetail detail) {
    final holding = detail.holdingDetails;
    String label = '';
    IconData icon = Icons.handshake;

    if (holding.private != null) {
      label = 'Free Hold';
      icon = Icons.security;
    } else if (holding.lease != null) {
      label = 'Lease Hold';
      icon = Icons.schedule;
    } else if (holding.cooperative != null) {
      label = 'Cooperative';
      icon = Icons.people;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.divider.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.theme.textMuted),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.theme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection(
      BuildContext context, AppLocalizations l10n, ListingDetail detail) {
    if (detail.video.blocked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Row(
          children: [
            const Icon(Icons.videocam_off, color: AppColors.primary400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Video not available',
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: detail.video.url!,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => Container(color: AppColors.primary100),
            errorWidget: (_, __, ___) => Container(
              color: AppColors.primary100,
              child: const Icon(Icons.video_library),
            ),
          ),
          const Positioned(
            bottom: 8,
            left: 8,
            child: Icon(Icons.play_circle, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context, AppLocalizations l10n,
      ListingDetail detail, bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owner Actions',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (isOwner)
              _buildActionButton(
                context,
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () => _editListing(detail),
              ),
            if (isOwner)
              _buildActionButton(
                context,
                icon: Icons.publish_outlined,
                label: 'Submit',
                onTap: () => _confirmSubmit(detail, l10n),
              ),
            if (isOwner)
              _buildActionButton(
                context,
                icon: Icons.delete_outline,
                label: 'Delete',
                color: AppColors.error,
                onTap: () => _confirmDelete(detail, l10n),
              ),
            if (detail.isFeatured == false)
              _buildActionButton(
                context,
                icon: Icons.workspace_premium_outlined,
                label: 'Feature',
                color: AppColors.accent500,
                onTap: () => _featureListing(detail, l10n),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.accent500,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatPrice(AppLocalizations l10n, ListingDetail detail) {
    final price = detail.price;
    if (price.amount == null) {
      return _missingPriceLabel(detail, l10n);
    }
    final base = l10n.listingsPriceFixed(smartDecimal(price.amount!));
    return base;
  }

  String _missingPriceLabel(ListingSummary listing, AppLocalizations l10n) {
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

  String _routeForKind(ListingKind kind, int id) {
    switch (kind) {
      case ListingKind.car:
        return '/cars/$id';
      case ListingKind.job:
        return '/jobs/$id';
      case ListingKind.house:
      case ListingKind.land:
      case ListingKind.unknown:
        return '/listings/$id';
    }
  }

  Future<void> _toggleFavorite(ListingDetail detail, bool isFavorite) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }

    if (_isFavoriteToggling) return;
    setState(() => _isFavoriteToggling = true);

    try {
      final success =
          await ref.read(favoritesV2Provider.notifier).toggle(detail.id);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (isFavorite ? l10n.favoritesRemoved : l10n.favoritesAdded)
                  : l10n.commonError,
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFavoriteToggling = false);
      }
    }
  }

  Future<void> _shareListing(
      ListingDetail detail, AppLocalizations l10n) async {
    final shareText = '''
${detail.title}
${_formatPrice(l10n, detail)}
${detail.description?.isNotEmpty == true ? '\n${detail.description}' : ''}

${l10n.shareListingTitle}
''';

    await Share.share(
      shareText,
      subject: '${l10n.shareListingMessage}${detail.title}',
    );
  }

  Future<void> _editListing(ListingDetail detail) async {
    final editRoute = switch (detail.kind) {
      ListingKind.car => '/cars/${detail.id}/edit',
      ListingKind.job => '/jobs/${detail.id}/edit',
      ListingKind.house => '/listings/${detail.id}/edit',
      ListingKind.land => '/listings/${detail.id}/edit',
      ListingKind.unknown => '/listings/${detail.id}/edit',
    };

    final result = await context.push<bool>(editRoute);
    if (!mounted) return;
    if (result == true) {
      ref.invalidate(listingDetailV2Provider(widget.listingId));
    }
  }

  Future<void> _confirmDelete(
      ListingDetail detail, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listingDeleteConfirmTitle),
        content: Text(l10n.listingDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(ownerListingServiceProvider).delete(detail.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Listing deleted'),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmSubmit(
      ListingDetail detail, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Listing'),
        content: const Text('Submit this listing for moderation review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent500),
            child: Text(l10n.listingSubmit),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(ownerListingServiceProvider).submit(detail.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Listing submitted'),
            backgroundColor: AppColors.success),
      );
      ref.invalidate(listingDetailV2Provider(widget.listingId));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.commonError), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _featureListing(
      ListingDetail detail, AppLocalizations l10n) async {
    try {
      final result =
          await ref.read(promotionV2ServiceProvider).feature(detail.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.isFeatured ? 'Featured' : l10n.commonError),
            backgroundColor:
                result.isFeatured ? AppColors.success : AppColors.error,
          ),
        );
        ref.invalidate(listingDetailV2Provider(widget.listingId));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.commonError),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}
