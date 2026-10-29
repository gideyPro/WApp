import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/v2_favorites_provider.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../widgets/v2/v2_listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';

/// Favorites Screen - wired to the cursor-paginated v2 favorites feed.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final Set<int> _togglingFavorites = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesV2Provider.notifier).loadFavorites();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(favoritesV2Provider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _removeFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    final success =
        await ref.read(favoritesV2Provider.notifier).remove(listingId);
    if (mounted) {
      setState(() => _togglingFavorites.remove(listingId));
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).favoritesRemoved),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  /// Cars and jobs have their own detail routes; everything else is a listing.
  void _handleListingTap(ListingSummary listing) {
    switch (listing.kind) {
      case ListingKind.car:
        context.push('/cars/${listing.id}');
      case ListingKind.job:
        context.push('/jobs/${listing.id}');
      case ListingKind.house:
      case ListingKind.land:
      case ListingKind.unknown:
        context.push('/listings/${listing.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesV2Provider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        centerTitle: false,
        title: Text(AppLocalizations.of(context).favoritesTitle),
        actions: [
          if (state.favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${state.total}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.accent600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(FavoritesV2State state) {
    if (state.isLoading && state.favorites.isEmpty) {
      return ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: 5,
        itemBuilder: (context, index) => const V2ListingCardSkeleton(),
      );
    }

    // Error state
    if (state.errorMessage != null && state.favorites.isEmpty) {
      return WaveMessageScreen.error(
        title: AppLocalizations.of(context).errorLoadingFavorites,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(favoritesV2Provider.notifier).loadFavorites();
        },
        isEmbedded: true,
      );
    }

    // Empty state
    if (state.favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(favoritesV2Provider.notifier).loadFavorites(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: WaveEmptyState(
                icon: Icons.favorite_border,
                title: AppLocalizations.of(context).favoritesEmpty,
                subtitle: AppLocalizations.of(context).favoritesEmptySubtitle,
                actionLabel:
                    AppLocalizations.of(context).commonBrowseProperties,
                onAction: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  ref.read(selectedTabProvider.notifier).state = 0;
                },
              ),
            ),
          ],
        ),
      );
    }

    // Favorites list
    return RefreshIndicator(
      onRefresh: () => ref.read(favoritesV2Provider.notifier).loadFavorites(),
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingLg,
        itemCount: state.favorites.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.favorites.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final listing = state.favorites[index];
          return V2ListingCard(
            listing: listing,
            hideFavoriteButton: true,
            onTap: () => _handleListingTap(listing),
            imageOverlayActions: [_buildRemoveButton(listing.id)],
          );
        },
      ),
    );
  }

  /// X remove button overlaid on the card's top-right corner.
  Widget _buildRemoveButton(int listingId) {
    return GestureDetector(
      onTap: _isToggling(listingId) ? null : () => _removeFavorite(listingId),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: _isToggling(listingId)
            ? const Padding(
                padding: EdgeInsets.all(9),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.close, size: 18, color: Colors.white),
      ),
    );
  }
}
