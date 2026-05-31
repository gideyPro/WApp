import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../listing/listing_detail_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';

/// Favorites Screen - Wired to favoritesProvider
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final Set<int> _togglingFavorites = {};

  @override
  void initState() {
    super.initState();
    // Load favorites on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  Future<void> _removeFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    final success =
        await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) {
      setState(() => _togglingFavorites.remove(listingId));
      if (success) {
        WaveToast.showSuccess(context, AppLocalizations.of(context).favoritesRemoved);
      }
    }
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  void _handleListingTap(dynamic listing) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listing.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoritesProvider);

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
                '${state.favorites.length}',
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

  Widget _buildBody(FavoritesState state) {
    // Loading state - show skeleton cards
    if (state.isLoading) {
      return _buildSkeletonList(5);
    }

    // Error state
    if (state.errorMessage != null) {
      return WaveMessageScreen.error(
        title: AppLocalizations.of(context).errorLoadingFavorites,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(favoritesProvider.notifier).loadFavorites();
        },
        isEmbedded: true,
      );
    }

    // Empty state
    if (state.favorites.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(favoritesProvider.notifier).loadFavorites(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: WaveEmptyState(
                icon: Icons.favorite_border,
                title: AppLocalizations.of(context).favoritesEmpty,
                subtitle: AppLocalizations.of(context).favoritesEmptySubtitle,
                actionLabel: AppLocalizations.of(context).commonBrowseProperties,
                onAction: () {
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
      onRefresh: () => ref.read(favoritesProvider.notifier).loadFavorites(),
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: state.favorites.length,
      itemBuilder: (context, index) {
        final listing = state.favorites[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              PropertyListingCard(
                listing: listing,
                hideFavoriteButton: true,
                onTap: () => _handleListingTap(listing),
              ),
              // X remove button on top-right of card
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: _isToggling(listing.id)
                      ? null
                      : () => _removeFavorite(listing.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: _isToggling(listing.id)
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.close,
                            size: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
    );
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: AppSpacing.paddingLg,
      itemCount: count,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: PropertyListingCard(isLoading: true),
        );
      },
    );
  }
}
