import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/v2/home_feed.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/v2_favorites_provider.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/v2/v2_listing_card.dart';

enum HomeCategory { all, property, vehicles, jobs }

extension HomeCategoryX on HomeCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case HomeCategory.all:
        return l10n.searchFilterAll;
      case HomeCategory.property:
        return l10n.listingSummaryProperty;
      case HomeCategory.vehicles:
        return l10n.listingCarPlural;
      case HomeCategory.jobs:
        return l10n.homeJobs;
    }
  }

  IconData get icon {
    switch (this) {
      case HomeCategory.all:
        return Icons.apps_rounded;
      case HomeCategory.property:
        return Icons.home_rounded;
      case HomeCategory.vehicles:
        return Icons.directions_car_rounded;
      case HomeCategory.jobs:
        return Icons.work_outline;
    }
  }
}

/// Home screen wired to the V2 `/v2/home` feed.
///
/// One request returns featured/listings/cars/jobs; the feed is cached
/// 60s with ETag for anonymous non-VIP viewers via [HomeService].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  HomeCategory _selectedCategory = HomeCategory.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeV2Provider.notifier).loadHome();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // V2 home feed is a single combined response; no pagination on home.
    // Keep the listener for future pull-to-load support.
  }

  void _onCategoryChanged(HomeCategory category) {
    if (category == _selectedCategory) return;
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
  }

  /// Filter the feed by category and optional search query.
  List<ListingSummary> _filteredListings(HomeV2State state) {
    if (state.feed == null) return const [];

    final all = <ListingSummary>[
      ...state.feed!.featured,
      ...state.feed!.listings,
      ...state.feed!.cars,
      ...state.feed!.jobs,
    ];

    // Deduplicate by id (featured may overlap with listings/cars/jobs).
    final seen = <int>{};
    final unique = <ListingSummary>[];
    for (final item in all) {
      if (seen.add(item.id)) unique.add(item);
    }

    return unique.where((listing) {
      switch (_selectedCategory) {
        case HomeCategory.all:
          break;
        case HomeCategory.property:
          if (listing.kind != ListingKind.house &&
              listing.kind != ListingKind.land) {
            return false;
          }
          break;
        case HomeCategory.vehicles:
          if (listing.kind != ListingKind.car) {
            return false;
          }
          break;
        case HomeCategory.jobs:
          if (listing.kind != ListingKind.job) {
            return false;
          }
          break;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!listing.title.toLowerCase().contains(q) &&
            !listing.location.shortLabel.toLowerCase().contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Route to the correct detail screen based on listing kind.
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

  bool _isFavorite(int listingId) {
    final favState = ref.watch(favoritesV2Provider);
    return favState.favorites.any((f) => f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }
    final success =
        await ref.read(favoritesV2Provider.notifier).toggle(listingId);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  bool _isToggling(int listingId) => false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeV2Provider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _greeting(l10n),
              style: AppTextStyles.caption.copyWith(
                color: context.theme.textMuted,
              ),
            ),
            Text(
              l10n.authWelcomeBack,
              style: AppTextStyles.title.copyWith(
                fontWeight: FontWeight.w800,
                color: context.theme.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeV2Provider.notifier).loadHome(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Search bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeSearchBarDelegate(
                controller: _searchController,
                query: _searchQuery,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
            ),

            // Category pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: HomeCategory.values.length,
                    itemBuilder: (context, index) {
                      final cat = HomeCategory.values[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _onCategoryChanged(cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient:
                                  isSelected ? AppColors.gradientAccent : null,
                              color: isSelected
                                  ? null
                                  : context.cardBg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : context.divider.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 15,
                                  color: isSelected
                                      ? Colors.white
                                      : context.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat.label(l10n),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            if (state.isLoading && state.feed == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null)
              _buildErrorSliver(l10n, state.errorMessage!)
            else
              ..._buildSections(l10n, state.feed!),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(AppLocalizations l10n, HomeFeed feed) {
    final filtered = _filteredListings(ref.read(homeV2Provider));

    final featured = feed.featured;
    final cars = feed.cars;
    final jobs = feed.jobs;
    final listings = feed.listings;

    final slivers = <Widget>[];

    // Featured section
    if (featured.isNotEmpty &&
        (_selectedCategory == HomeCategory.all ||
            _selectedCategory == HomeCategory.property)) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.listingsFeatured,
                      style: AppTextStyles.title.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.theme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _onCategoryChanged(HomeCategory.all),
                      child: Text(l10n.homeViewAll),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featured.length,
                    itemBuilder: (context, index) {
                      final listing = featured[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: SizedBox(
                          width: 260,
                          child: _buildFeaturedCard(listing),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 16)));
    }

    // Cars section
    if (cars.isNotEmpty &&
        (_selectedCategory == HomeCategory.all ||
            _selectedCategory == HomeCategory.vehicles)) {
      slivers.add(_buildSectionHeader(l10n.listingCarPlural));
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: _buildListingGrid(cars, l10n),
        ),
      );
    }

    // Jobs section
    if (jobs.isNotEmpty &&
        (_selectedCategory == HomeCategory.all ||
            _selectedCategory == HomeCategory.jobs)) {
      slivers.add(_buildSectionHeader(l10n.homeJobs));
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: _buildListingGrid(jobs, l10n),
        ),
      );
    }

    // General listings (property)
    if (listings.isNotEmpty &&
        (_selectedCategory == HomeCategory.all ||
            _selectedCategory == HomeCategory.property)) {
      slivers.add(_buildSectionHeader(l10n.listingsTitle));
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: _buildListingGrid(listings, l10n),
        ),
      );
    }

    // Fallback: show filtered results when a category is selected but
    // the dedicated section is empty (e.g., "property" picks up house/land
    // from the general listings feed).
    final filteredNonEmpty = filtered.isNotEmpty;
    final anySectionShown = featured.isNotEmpty ||
        cars.isNotEmpty ||
        jobs.isNotEmpty ||
        listings.isNotEmpty;

    if (filteredNonEmpty && !anySectionShown) {
      slivers.add(_buildSectionHeader(l10n.listingsTitle));
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: _buildListingGrid(filtered, l10n),
        ),
      );
    }

    if (slivers.isEmpty) {
      slivers.add(_buildEmptySliver(l10n));
    }

    return slivers;
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.w700,
            color: context.theme.textPrimary,
          ),
        ),
      ),
    );
  }

  SliverList _buildListingGrid(
    List<ListingSummary> listings,
    AppLocalizations l10n,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final listing = listings[index];
          final fav = _isFavorite(listing.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: V2ListingCard(
              listing: listing,
              isFavorite: fav,
              isTogglingFavorite: _isToggling(listing.id),
              onFavorite: () => _toggleFavorite(listing.id),
              onTap: () => _handleListingTap(listing),
              hideFavoriteButton: false,
            ),
          );
        },
        childCount: listings.length,
      ),
    );
  }

  Widget _buildFeaturedCard(ListingSummary listing) {
    final fav = _isFavorite(listing.id);
    return V2ListingCard(
      listing: listing,
      isFavorite: fav,
      isTogglingFavorite: _isToggling(listing.id),
      onFavorite: () => _toggleFavorite(listing.id),
      onTap: () => _handleListingTap(listing),
      hideFavoriteButton: false,
    );
  }

  Widget _buildErrorSliver(AppLocalizations l10n, String error) {
    return SliverFillRemaining(
      child: WaveMessageScreen.error(
        title: l10n.commonError,
        subtitle: error,
        onRetry: () => ref.read(homeV2Provider.notifier).loadHome(),
        isEmbedded: true,
      ),
    );
  }

  Widget _buildEmptySliver(AppLocalizations l10n) {
    return SliverFillRemaining(
      child: WaveEmptyState(
        icon: Icons.home_outlined,
        title: l10n.listingsNoResults,
        subtitle: l10n.searchNoResultsSubtitle,
        actionLabel: l10n.homeViewAll,
        onAction: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
          _onCategoryChanged(HomeCategory.all);
        },
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.commonGoodMorning;
    if (hour < 17) return l10n.commonGoodAfternoon;
    return l10n.commonGoodEvening;
  }
}

/// Persistent search bar for the home screen.
class _HomeSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  _HomeSearchBarDelegate({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.oceanicNavyDark : AppColors.stone50)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: context.divider.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardNavyDark : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.stone200,
                width: 0.9,
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.accent500,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white : AppColors.stone900,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.searchPlaceholder,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.stone400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(_HomeSearchBarDelegate oldDelegate) {
    return oldDelegate.query != query;
  }
}
