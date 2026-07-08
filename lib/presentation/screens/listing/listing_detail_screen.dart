import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing.dart';
import '../../widgets/common/wave_card.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../widgets/common/wave_common_widgets.dart';
import 'widgets/listing_gallery.dart';
import 'widgets/listing_detail_sections.dart';
import 'widgets/listing_action_buttons.dart';

/// Listing Detail Screen with skeleton loaders
class ListingDetailScreen extends ConsumerStatefulWidget {
  final int listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
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
      return _buildErrorView(
        state.errorMessage!,
        isSubscriptionGate: state.requiresSubscription,
      );
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

  Widget _buildErrorView(
    String message, {
    bool isSubscriptionGate = false,
  }) {
    final l10n = AppLocalizations.of(context);

    if (isSubscriptionGate) {
      return WaveMessageScreen(
        type: WaveMessageType.warning,
        title: l10n.subscriptionRequiredTitle,
        subtitle: l10n.subscriptionRequiredDetailsSubtitle,
        actionLabel: l10n.listingUpgradeNow,
        onAction: () => context.pushReplacement('/subscriptions'),
      );
    }

    return WaveMessageScreen.error(
      title: l10n.listingsLoadError,
      subtitle: message,
      onRetry: () {
        ref
            .read(listingDetailProvider.notifier)
            .loadListing(widget.listingId);
      },
    );
  }

  Widget _buildNotFound() {
    final l10n = AppLocalizations.of(context);
    return WaveMessageScreen.empty(
      title: l10n.listingsNotFound,
      subtitle: l10n.listingsNotFoundSubtitle,
      onAction: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildContent(Listing listing) {
    _precacheVideo(listing);
    final favState = ref.watch(favoritesProvider);
    final isFavorited = favState.favorites.any((f) => f.id == listing.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ListingGallery(listing: listing),
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

          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListingDetailSections(listing: listing),
                  const SizedBox(height: 32),
                  ListingActionButtons(listing: listing),
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

  // Removed _buildImageGallery, _buildPriceAndTitle, _buildBadges, _buildBadge,
  // _buildAmenities, _buildAmenityChip, _buildLocation, _buildKeyFeatures,
  // _buildFeatureChip, _buildDescription, _buildPropertyDetails, _buildVideoSection,
  // _buildVipBlockedSection, _buildVideoStatusBadge, _buildVideoContent,
  // _buildProcessingIndicator, _buildViewOriginalLink - moved to ListingDetailSections

  Future<void> _toggleFavorite(int listingId, bool isFavorited) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }

    final success =
        await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final msg = isFavorited ? l10n.favoritesRemoved : l10n.favoritesAdded;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _shareListing(Listing listing) async {
    final shareText = '''
${listing.getLocalizedTitle(context)}
${listing.getLocalizedPrice(context)}
${listing.description?.isNotEmpty == true ? '\n${listing.description}' : ''}

${AppLocalizations.of(context).shareListingTitle}
''';

    await Share.share(
      shareText,
      subject:
          '${AppLocalizations.of(context).shareListingMessage}${listing.getLocalizedTitle(context)}',
    );
  }

  // Removed _editListing, _deleteListing, _vipListing, _unvipListing,
  // _featureListing, _unfeatureListing, _buildActionButtons,
  // _buildContactRevealSection, _buildContactUpgradeSection,
  // _buildRevealedContactSection, _launchUrl, _isRevealingContact,
  // _revealedContact, _revealedName, _revealContact, _submitInterest,
  // _getInterestStatusColor, _getInterestStatusIcon, _getInterestStatusText
  // - moved to ListingActionButtons / ListingContactForm

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
        context.pushReplacement('/listings/${similar.id}');
      },
      child: WaveCard(
        useLiquidGlass: true,
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
