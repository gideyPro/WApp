import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/car_providers.dart';
import '../../widgets/featured_listing_card.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/vehicle_listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import 'filter_sheet.dart';

enum HomeCategory { property, vehicles }

extension HomeCategoryX on HomeCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case HomeCategory.property: return l10n.listingSummaryProperty;
      case HomeCategory.vehicles: return l10n.listingCarPlural;
    }
  }

  IconData get icon {
    switch (this) {
      case HomeCategory.property: return Icons.home_rounded;
      case HomeCategory.vehicles: return Icons.directions_car_rounded;
    }
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, RouteAware {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Set<int> _togglingFavorites = {};
  Timer? _debounceTimer;
  DateTime? _lastLoadTime;

  UnifiedFilterValues _filterValues = const UnifiedFilterValues();
  bool _hasSearched = false;
  bool _isAutoRefreshing = false;
  HomeCategory _selectedCategory = HomeCategory.property;

  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _refreshPillController;
  late Animation<double> _refreshPillAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _refreshPillController = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _refreshPillAnimation = CurvedAnimation(
      parent: _refreshPillController,
      curve: Curves.easeOutCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
      if (ref.read(subscriptionProvider).canViewVip) {
        ref.read(vipListingsProvider.notifier).loadVipListings();
      }
      ref.read(listingsProvider.notifier).loadListings();
      ref.read(authStateProvider.notifier).loadUser();
      ref.read(favoritesProvider.notifier).loadFavorites();
      _lastLoadTime = DateTime.now();
      _headerAnimationController.forward();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    if (mounted) {
      final now = DateTime.now();
      final shouldReload = _lastLoadTime == null ||
          now.difference(_lastLoadTime!).inSeconds > 30;
      if (shouldReload) {
        _lastLoadTime = now;
        _runAutoRefresh();
      }
    }
  }

  Future<void> _runAutoRefresh() async {
    if (_isAutoRefreshing) return;
    setState(() => _isAutoRefreshing = true);
    _refreshPillController.forward();
    try {
      await ref.read(listingsProvider.notifier).loadListings();
    } finally {
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 350));
        if (mounted) {
          _refreshPillController.reverse();
          setState(() => _isAutoRefreshing = false);
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    _lastLoadTime = DateTime.now();
    final futures = <Future<void>>[
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings(),
      ref.read(listingsProvider.notifier).loadListings(),
      ref.read(favoritesProvider.notifier).loadFavorites(),
    ];
    if (ref.read(subscriptionProvider).canViewVip) {
      futures.add(ref.read(vipListingsProvider.notifier).loadVipListings());
    }
    if (_selectedCategory == HomeCategory.vehicles) {
      futures.add(ref.read(carListingsProvider.notifier).loadListings());
    }
    await Future.wait(futures);
  }

  void _onCategoryChanged(HomeCategory category) {
    if (category == _selectedCategory) return;
    _searchController.clear();
    setState(() {
      _selectedCategory = category;
      _hasSearched = false;
      _filterValues = UnifiedFilterValues(category: category);
    });
    ref.invalidate(searchResultsProvider);
    if (category == HomeCategory.vehicles) {
      final notifier = ref.read(carListingsProvider.notifier);
      notifier.reset();
      notifier.loadListings();
    }
  }

  void _handleFilterTap() async {
    final result = await showModalBottomSheet<UnifiedFilterValues>(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialValues: _filterValues,
        showCategoryToggle: true,
      ),
    );
    if (result != null) {
      setState(() => _filterValues = result);
      _performSearch();
    }
  }

  Widget _buildCategoryPills(AppLocalizations l10n) {
    const categories = HomeCategory.values;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => _onCategoryChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppColors.gradientAccent
                        : null,
                    color: isSelected ? null : context.cardBg.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : context.divider.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 15,
                        color: isSelected ? Colors.white : context.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label(l10n),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCarListings() {
    final state = ref.watch(carListingsProvider);
    final l10n = AppLocalizations.of(context);
    final header = _buildSectionHeader(
      l10n.listingCarPlural,
      eyebrow: l10n.homeLatestRecently.toUpperCase(),
    );

    if (state.isLoading && state.listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            header,
            for (int i = 0; i < 3; i++)
              const VehicleListingCard(isLoading: true),
          ]),
        ),
      );
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          children: [
            header,
            Expanded(
              child: Center(
                child: TextButton.icon(
                  onPressed: () => ref.read(carListingsProvider.notifier).loadListings(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.commonRetryMessage),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          children: [
            header,
            Expanded(
              child: WaveEmptyState(
                icon: Icons.directions_car_outlined,
                title: l10n.listingsNoResults,
                subtitle: 'No vehicle listings available',
              ),
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) return header;
            final i = index - 1;
            if (i == state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[i];
            final fav = _isFavorite(listing.id);
            return VehicleListingCard(
              listing: listing,
              isFavorite: fav,
              isTogglingFavorite: _isToggling(listing.id),
              onFavorite: () => _toggleFavorite(listing.id),
              onTap: () => context.push('/cars/${listing.id}'),
            );
          },
          childCount: 1 + state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    if (_hasSearched) {
      if (_selectedCategory == HomeCategory.vehicles) {
        final state = ref.read(carListingsProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(carListingsProvider.notifier).loadListings(
            page: state.currentPage + 1,
            filters: _filterValues.toQueryParams(),
          );
        }
      } else {
        final state = ref.read(searchResultsProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(searchResultsProvider.notifier).loadListings(
            page: state.currentPage + 1,
            filters: _filterValues.toQueryParams(),
          );
        }
      }
    } else {
      if (_selectedCategory == HomeCategory.vehicles) {
        final state = ref.read(carListingsProvider);
        if (!state.isLoading && !state.isLoadingMore && state.hasMore) {
          ref.read(carListingsProvider.notifier).loadListings(
            page: state.currentPage + 1,
          );
        }
      } else {
        final state = ref.read(listingsProvider);
        if (!state.isLoading && !state.isLoadingMore && state.hasMore) {
          ref.read(listingsProvider.notifier).loadListings(
            page: state.currentPage + 1,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _headerAnimationController.dispose();
    _refreshPillController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (_hasSearched) {
        if (_filterValues.hasAnyFilter) {
          _performSearch();
        } else {
          setState(() => _hasSearched = false);
          if (_selectedCategory == HomeCategory.vehicles) {
            ref.read(carListingsProvider.notifier).loadListings();
          } else {
            ref.invalidate(searchResultsProvider);
          }
        }
      } else {
        setState(() => _hasSearched = false);
      }
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    final filters = _filterValues.toQueryParams();
    if (query.isNotEmpty) filters['location'] = query;

    setState(() => _hasSearched = true);

    if (_selectedCategory == HomeCategory.vehicles) {
      ref.read(carListingsProvider.notifier).loadListings(
        filters: filters.isNotEmpty ? filters : null,
      );
    } else {
      ref.read(searchResultsProvider.notifier).loadListings(
        filters: filters.isNotEmpty ? filters : null,
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _filterValues = UnifiedFilterValues(category: _selectedCategory);
    });
    if (_selectedCategory == HomeCategory.vehicles) {
      ref.read(carListingsProvider.notifier).loadListings();
    } else {
      ref.invalidate(searchResultsProvider);
    }
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filterValues = UnifiedFilterValues(category: _selectedCategory);
      _hasSearched = false;
    });
    if (_selectedCategory == HomeCategory.vehicles) {
      ref.read(carListingsProvider.notifier).loadListings();
    } else {
      ref.invalidate(searchResultsProvider);
    }
  }

  void _removeFilterAndCheck(VoidCallback onRemove) {
    onRemove();
    if (_filterValues.hasAnyFilter) {
      _performSearch();
    } else if (_hasSearched) {
      setState(() => _hasSearched = false);
      if (_selectedCategory == HomeCategory.vehicles) {
        ref.read(carListingsProvider.notifier).loadListings();
      } else {
        ref.invalidate(searchResultsProvider);
      }
    }
  }

  bool get _hasActiveFilters =>
      _filterValues.hasAnyFilter ||
      _searchController.text.isNotEmpty;



  bool _isFavorite(int listingId) {
    final favState = ref.watch(favoritesProvider);
    return favState.favorites.any((f) => f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  void _handleListingTap(Listing listing) {
    context.push('/listings/${listing.id}');
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);
    final vipState = ref.watch(vipListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(favoritesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchState = _selectedCategory == HomeCategory.vehicles && _hasSearched
        ? ref.watch(carListingsProvider)
        : ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -60,
            width: 280,
            height: 280,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent500.withValues(alpha: 0.15),
                      AppColors.accent500.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _onRefresh,
            displacement: 80,
            color: AppColors.accent500,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    user: ref.watch(profileProvider).user,
                    searchController: _searchController,
                    focusNode: _searchFocusNode,
                    hasActiveFilters: _hasActiveFilters,
                    searchQuery: _searchController.text,
                    unreadCount: ref.watch(unreadCountProvider),
                    onSearchChanged: _onSearchChanged,
                    onSubmitted: (_) => _performSearch(),
                    onClear: _clearSearch,
                    onFilterTap: _handleFilterTap,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRefreshPill(),
                ),
                if (_hasActiveFilters)
                  SliverToBoxAdapter(
                    child: _buildActiveFilterChips(l10n),
                  ),
                if (!_hasSearched)
                  SliverToBoxAdapter(
                    child: _buildCategoryPills(l10n),
                  ),
                if (_hasSearched)
                  _buildSearchResults(searchState, l10n)
                else if (_selectedCategory == HomeCategory.vehicles)
                  _buildCarListings()
                else ...[
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(l10n.listingsFeatured),
                          _buildFeaturedListings(featuredState, vipState),
                          _buildSectionHeader(l10n.listingsTitle,
                              eyebrow: l10n.homeLatestRecently.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  _buildLatestListings(listingsState),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(AppLocalizations l10n) {
    final v = _filterValues;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.cardBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedCategory == HomeCategory.property) ...[
              if (v.propertyType != null)
                _filterChip(
                  v.propertyType == 'house' ? l10n.listingHouse : l10n.listingLand,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = UnifiedFilterValues(
                      category: _selectedCategory,
                      priceMin: v.priceMin,
                      priceMax: v.priceMax,
                      sort: v.sort,
                      location: v.location,
                      listingType: v.listingType,
                      isFeatured: v.isFeatured,
                    );
                  })),
                ),
              if (v.listingType != null)
                _filterChip(
                  v.listingType == 'sale' ? l10n.listingForSale : l10n.listingForRent,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = UnifiedFilterValues(
                      category: _selectedCategory,
                      priceMin: v.priceMin,
                      priceMax: v.priceMax,
                      sort: v.sort,
                      location: v.location,
                      propertyType: v.propertyType,
                      isFeatured: v.isFeatured,
                    );
                  })),
                ),
              if (v.isFeatured)
                _filterChip(
                  l10n.listingsFeatured,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = UnifiedFilterValues(
                      category: _selectedCategory,
                      priceMin: v.priceMin,
                      priceMax: v.priceMax,
                      sort: v.sort,
                      location: v.location,
                      propertyType: v.propertyType,
                      listingType: v.listingType,
                    );
                  })),
                ),
            ] else ...[
              if (v.make != null)
                _filterChip('${l10n.listingMake}: ${v.make}',
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('make');
                  })),
                ),
              if (v.model != null)
                _filterChip('${l10n.listingModel}: ${v.model}',
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('model');
                  })),
                ),
              if (v.yearMin != null || v.yearMax != null)
                _filterChip('${l10n.listingYear}: ${v.yearMin ?? ''}-${v.yearMax ?? ''}',
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('year_min');
                  })),
                ),
              if (v.transmission != null)
                _filterChip(v.transmission!,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('transmission');
                  })),
                ),
              if (v.fuelType != null)
                _filterChip(v.fuelType!,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('fuel_type');
                  })),
                ),
              if (v.bodyType != null)
                _filterChip(v.bodyType!,
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('body_type');
                  })),
                ),
              if (v.mileageMax != null)
                _filterChip('${l10n.listingMileageMax}: ${v.mileageMax}',
                  () => _removeFilterAndCheck(() => setState(() {
                    _filterValues = v.clearField('mileage_max');
                  })),
                ),
            ],
            if (v.priceMin != null || v.priceMax != null)
              _filterChip(
                v.priceMin != null && v.priceMax != null
                    ? 'ETB ${v.priceMin} - ETB ${v.priceMax}'
                    : v.priceMin != null
                        ? 'ETB ${v.priceMin}+'
                        : 'Up to ETB ${v.priceMax}',
                () => _removeFilterAndCheck(() => setState(() {
                  _filterValues = UnifiedFilterValues(
                    category: _selectedCategory,
                    sort: v.sort,
                    location: v.location,
                    propertyType: v.propertyType,
                    listingType: v.listingType,
                    isFeatured: v.isFeatured,
                    make: v.make,
                    model: v.model,
                    yearMin: v.yearMin,
                    yearMax: v.yearMax,
                    mileageMax: v.mileageMax,
                    transmission: v.transmission,
                    fuelType: v.fuelType,
                    bodyType: v.bodyType,
                  );
                })),
              ),
            if (_searchController.text.isNotEmpty)
              _filterChip(
                _searchController.text,
                () {
                  _searchController.clear();
                  _removeFilterAndCheck(() {});
                },
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.primary400.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                children: [
                  const Icon(Icons.close,
                      size: 14, color: AppColors.primary600),
                  const SizedBox(width: 4),
                  Text(
                    l10n.searchClearAll,
                    style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary600),
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

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent500.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.accent500.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.accent700),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child:
                  const Icon(Icons.close, size: 14, color: AppColors.accent600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(ListingsState state, AppLocalizations l10n) {
    if (state.isLoading && state.listings.isEmpty) {
      return _buildSkeletonResults(5);
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Center(child: _buildPullToRefreshHint()),
      );
    }

    if (state.listings.isEmpty) {
      return SliverFillRemaining(
        child: WaveEmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.searchNoResultsTitle,
          subtitle: l10n.searchNoResultsSubtitle,
          actionLabel: l10n.searchClearAll,
          onAction: _clearAllFilters,
        ),
      );
    }

    final isVehicle = _selectedCategory == HomeCategory.vehicles;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[index];
            final fav = _isFavorite(listing.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: isVehicle
                  ? VehicleListingCard(
                      listing: listing,
                      isFavorite: fav,
                      isTogglingFavorite: _isToggling(listing.id),
                      onFavorite: () => _toggleFavorite(listing.id),
                      onTap: () => context.push('/cars/${listing.id}'),
                    )
                  : PropertyListingCard(
                      listing: listing,
                      isFavorite: fav,
                      isTogglingFavorite: _isToggling(listing.id),
                      onFavorite: () => _toggleFavorite(listing.id),
                      onTap: () => _handleListingTap(listing),
                    ),
            );
          },
          childCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildSkeletonResults(int count) {
    final isVehicle = _selectedCategory == HomeCategory.vehicles;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: isVehicle
                  ? const VehicleListingCard(isLoading: true)
                  : const PropertyListingCard(isLoading: true),
            );
          },
          childCount: count,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? eyebrow,
    Color? eyebrowColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow,
              style: AppTextStyles.eyebrow.copyWith(
                color: eyebrowColor,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            title,
            style: AppTextStyles.title.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListings(
    ListingsState featuredState,
    ListingsState vipState,
  ) {
    final l10n = AppLocalizations.of(context);
    final subState = ref.watch(subscriptionProvider);
    final canViewVip = subState.canViewVip;

    // Merge featured + VIP listings, deduplicated by ID
    final merged = <Listing>[
      ...featuredState.listings,
      if (canViewVip)
        ...vipState.listings.where(
          (v) => !featuredState.listings.any((f) => f.id == v.id),
        ),
    ];

    if (featuredState.errorMessage != null && merged.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildPullToRefreshHint(),
      );
    }
    if (featuredState.isLoading && merged.isEmpty) {
      return SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) => const Padding(
            padding: EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: FeaturedListingCard(listing: null, isLoading: true),
            ),
          ),
        ),
      );
    }
    if (merged.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(l10n.listingsNoResults),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: merged.length,
              itemBuilder: (context, index) {
                final listing = merged[index];
                final fav = _isFavorite(listing.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 280,
                    child: FeaturedListingCard(
                      listing: listing,
                      isFavorite: fav,
                      isTogglingFavorite: _isToggling(listing.id),
                      onFavorite: () => _toggleFavorite(listing.id),
                      onTap: () => _handleListingTap(listing),
                    ),
                  ),
                );
              },
            ),
          ),
          // Inline VIP teaser for non-subscribers
          if (!canViewVip && !subState.isLoading && subState.errorMessage == null)
            _buildVipTeaser(),
        ],
      ),
    );
  }

  Widget _buildVipTeaser() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => context.push('/subscriptions'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.vip.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppColors.vip.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.diamond, size: 16, color: AppColors.vip),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.vipTeaserCta,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.vip,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.vip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshPill() {
    final l10n = AppLocalizations.of(context);
    return SizeTransition(
      sizeFactor: _refreshPillAnimation,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _refreshPillAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent500.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent500.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accent500),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.homeRefreshing,
                style: const TextStyle(
                  color: AppColors.accent500,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestListings(ListingsState state) {
    if (state.errorMessage != null && state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildPullToRefreshHint(),
          ),
        ),
      );
    }
    if (state.isLoading && state.listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 3; i++)
              const PropertyListingCard(isLoading: true),
          ]),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(AppLocalizations.of(context).listingsNoResults),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[index];
            final fav = _isFavorite(listing.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => _handleListingTap(listing),
              ),
            );
          },
          childCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildPullToRefreshHint() {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.swap_vert_rounded, size: 32, color: context.textMuted),
        const SizedBox(height: 8),
        Text(
          l10n.commonRetryMessage,
          style: AppTextStyles.bodySmall.copyWith(color: context.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final dynamic user;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool hasActiveFilters;
  final String searchQuery;
  final int unreadCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  _SearchBarDelegate({
    this.user,
    required this.searchController,
    required this.focusNode,
    required this.hasActiveFilters,
    required this.searchQuery,
    this.unreadCount = 0,
    required this.onSearchChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
  });

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.commonGoodMorning;
    if (hour < 17) return l10n.commonGoodAfternoon;
    return l10n.commonGoodEvening;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Calculate dynamic values based on scroll
    // 0.0 at max extent, 1.0 at min extent
    final progress = shrinkOffset / (maxExtent - minExtent);
    final clampedProgress = progress.clamp(0.0, 1.0);

    // Greeting row opacity: fades out early
    final greetingOpacity = (1.0 - clampedProgress * 2).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.primary900 : AppColors.primary50)
            .withValues(alpha: clampedProgress),
        boxShadow: [
          if (clampedProgress > 0.5)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Personalized Greeting Row (Fades out on scroll)
            if (greetingOpacity > 0)
              Opacity(
                opacity: greetingOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(l10n),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: context.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            user != null
                                ? user.firstName
                                : l10n.authWelcomeBack,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      _buildNotificationBell(context),
                    ],
                  ),
                ),
              ),

            // Modern Glass Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8 + (4 * (1.0 - clampedProgress)),
                16,
                12,
              ),
              child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primary800 : Colors.white)
                          .withValues(alpha: isDark ? 0.85 : 0.95),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (isDark ? Colors.white : AppColors.primary900)
                            .withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 12),
                          child: Icon(
                            Icons.search_rounded,
                            color: AppColors.accent500,
                            size: 24,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            focusNode: focusNode,
                            onChanged: onSearchChanged,
                            onSubmitted: onSubmitted,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.searchPlaceholder,
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: context.textSecondary,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          IconButton(
                            onPressed: onClear,
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.theme.divider,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: context.theme.iconSecondary,
                                size: 14,
                              ),
                            ),
                          ),
                        VerticalDivider(
                          color: context.divider,
                          indent: 16,
                          endIndent: 16,
                          width: 1,
                        ),
                        _buildFilterButton(),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.gradientHero,
          boxShadow: AppColors.shadowMd,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: unreadCount > 0
              ? Badge(
                  label: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: unreadCount > 99 ? 8 : 10,
                    ),
                  ),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                )
              : const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: onFilterTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: double.infinity,
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? AppColors.accent500.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 24,
              color:
                  hasActiveFilters ? AppColors.accent500 : AppColors.primary400,
            ),
            if (hasActiveFilters)
              Positioned(
                top: 14,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 170;

  @override
  double get minExtent => 90;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return oldDelegate.hasActiveFilters != hasActiveFilters ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.user != user;
  }
}
