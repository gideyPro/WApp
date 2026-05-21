import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../listing/listing_detail_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../settings/settings_screen.dart';

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

  String? _selectedType;
  String? _selectedListingType;
  String _selectedSort = 'newest';
  int? _selectedPriceMin;
  int? _selectedPriceMax;
  String? _selectedPriceLabel;
  bool _isFeaturedFilter = false;
  Map<String, dynamic> _activeFilters = {};
  bool _hasSearched = false;
  bool _rentalEnabled = false;

  late AnimationController _headerAnimationController;
  late Animation<double> _fadeAnimation;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(featuredListingsProvider.notifier).loadFeaturedListings();
      ref.read(listingsProvider.notifier).loadListings();
      ref.read(authStateProvider.notifier).loadUser();
      _lastLoadTime = DateTime.now();
      _headerAnimationController.forward();
      _loadSettings();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadSettings() async {
    try {
      final response =
          await ApiClient().dio.get('${ApiConstants.apiBase}/settings');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map && mounted) {
          setState(() {
            _rentalEnabled = data['rental_enabled'] == true;
          });
        }
      }
    } catch (_) {}
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
        ref.read(listingsProvider.notifier).loadListings();
      }
    }
  }

  void _onScroll() {
    if (_hasSearched) {
      final state = ref.read(searchResultsProvider);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !state.isLoadingMore &&
          state.hasMore) {
        ref.read(searchResultsProvider.notifier).loadListings(
              page: state.currentPage + 1,
              filters: _activeFilters,
            );
      }
    } else {
      final state = ref.read(listingsProvider);
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !state.isLoading &&
          !state.isLoadingMore &&
          state.hasMore) {
        ref
            .read(listingsProvider.notifier)
            .loadListings(page: state.currentPage + 1);
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
    super.dispose();
  }

  // --- Search ---

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty && !_hasSearched) {
      setState(() {
        _hasSearched = false;
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    _activeFilters = {};
    if (_isFeaturedFilter) {
      _activeFilters['is_featured'] = true;
    }
    if (query.isNotEmpty) _activeFilters['location'] = query;
    if (_selectedType != null) _activeFilters['type'] = _selectedType;
    if (_selectedListingType != null) {
      _activeFilters['listing_type'] = _selectedListingType;
    }
    _activeFilters['sort'] = _selectedSort;
    if (_selectedPriceMin != null) {
      _activeFilters['price_min'] = _selectedPriceMin;
    }
    if (_selectedPriceMax != null) {
      _activeFilters['price_max'] = _selectedPriceMax;
    }

    setState(() => _hasSearched = true);
    ref.read(searchResultsProvider.notifier).loadListings(filters: _activeFilters);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasSearched = false;
    });
    ref.invalidate(searchResultsProvider);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedListingType = null;
      _selectedSort = 'newest';
      _selectedPriceMin = null;
      _selectedPriceMax = null;
      _selectedPriceLabel = null;
      _isFeaturedFilter = false;
      _activeFilters = {};
      _hasSearched = false;
      _searchController.clear();
    });
    ref.invalidate(searchResultsProvider);
  }

  void _removeFilterAndCheck(VoidCallback onRemove) {
    onRemove();
    if (_hasActiveFilters) {
      _performSearch();
    } else if (_hasSearched) {
      setState(() => _hasSearched = false);
      ref.invalidate(searchResultsProvider);
    }
  }

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedListingType != null ||
      _selectedSort != 'newest' ||
      _selectedPriceLabel != null ||
      _isFeaturedFilter ||
      _searchController.text.isNotEmpty;

  // --- Filter Sheet ---

  void _showFilterSheet() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.searchFilters,
                          style: AppTextStyles.title.copyWith(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedType = null;
                              _selectedListingType = null;
                              _selectedSort = 'newest';
                              _selectedPriceLabel = null;
                              _selectedPriceMin = null;
                              _selectedPriceMax = null;
                              _isFeaturedFilter = false;
                            });
                          },
                          child: Text(
                            l10n.searchReset,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primary500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Property Type
                    Text(
                      l10n.searchPropertyType,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _modalChipRow(
                      options: [
                        (l10n.searchFilterAll, null, _selectedType == null),
                        (l10n.listingHouse, 'house', _selectedType == 'house'),
                        (l10n.listingLand, 'land', _selectedType == 'land'),
                      ],
                      onSelected: (v) =>
                          setModalState(() => _selectedType = v as String?),
                    ),
                    const SizedBox(height: 16),

                    // Listing Status
                    if (_rentalEnabled) ...[
                      Text(
                        l10n.searchListingStatus,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      _modalChipRow(
                        options: [
                          (
                            l10n.searchFilterAll,
                            null,
                            _selectedListingType == null
                          ),
                          (
                            l10n.listingForSale,
                            'sale',
                            _selectedListingType == 'sale'
                          ),
                          (
                            l10n.listingForRent,
                            'rental',
                            _selectedListingType == 'rental'
                          ),
                        ],
                        onSelected: (v) => setModalState(
                            () => _selectedListingType = v as String?),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Featured filter
                    Text(
                      l10n.listingsFeatured,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _modalChipRow(
                      options: [
                        (l10n.searchFilterAll, null, !_isFeaturedFilter),
                        (l10n.listingsFeatured, true, _isFeaturedFilter),
                      ],
                      onSelected: (v) =>
                          setModalState(() => _isFeaturedFilter = v == true),
                    ),
                    const SizedBox(height: 16),

                    // Price Range
                    Text(
                      l10n.searchPriceRange,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _modalChipRow(
                      options: [
                        (
                          l10n.searchFilterAny,
                          null,
                          _selectedPriceLabel == null
                        ),
                        (
                          l10n.searchUnder5M,
                          'Under 5M',
                          _selectedPriceLabel == 'Under 5M'
                        ),
                        (
                          l10n.search5M10M,
                          '5M-10M',
                          _selectedPriceLabel == '5M-10M'
                        ),
                        (
                          l10n.search10M50M,
                          '10M-50M',
                          _selectedPriceLabel == '10M-50M'
                        ),
                        (
                          l10n.search50M100M,
                          '50M-100M',
                          _selectedPriceLabel == '50M-100M'
                        ),
                        (
                          l10n.search100MPlus,
                          '100M+',
                          _selectedPriceLabel == '100M+'
                        ),
                      ],
                      onSelected: (v) =>
                          setModalState(() => _setPriceFilter(v as String?)),
                    ),
                    const SizedBox(height: 16),

                    // Sort By
                    Text(
                      l10n.searchSortBy,
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    _modalChipRow(
                      options: [
                        (
                          l10n.searchSortNewest,
                          'newest',
                          _selectedSort == 'newest'
                        ),
                        (
                          l10n.searchSortOldest,
                          'oldest',
                          _selectedSort == 'oldest'
                        ),
                        (
                          l10n.searchSortPriceLow,
                          'price_low',
                          _selectedSort == 'price_low'
                        ),
                        (
                          l10n.searchSortPriceHigh,
                          'price_high',
                          _selectedSort == 'price_high'
                        ),
                      ],
                      onSelected: (v) =>
                          setModalState(() => _selectedSort = v as String),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _performSearch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(
                          l10n.searchApplyFilters,
                          style: AppTextStyles.bodyLargePlus
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _modalChipRow({
    required List<(String, dynamic, bool)> options,
    required void Function(dynamic) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((chip) {
        final (label, value, isSelected) = chip;
        return GestureDetector(
          onTap: () => onSelected(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected ? AppColors.accent500 : AppColors.primary50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : AppColors.primary700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _setPriceFilter(String? label) {
    _selectedPriceLabel = label;
    switch (label) {
      case 'Under 5M':
        _selectedPriceMin = 0;
        _selectedPriceMax = 5000000;
        break;
      case '5M-10M':
        _selectedPriceMin = 5000000;
        _selectedPriceMax = 10000000;
        break;
      case '10M-50M':
        _selectedPriceMin = 10000000;
        _selectedPriceMax = 50000000;
        break;
      case '50M-100M':
        _selectedPriceMin = 50000000;
        _selectedPriceMax = 100000000;
        break;
      case '100M+':
        _selectedPriceMin = 100000000;
        _selectedPriceMax = null;
        break;
      default:
        _selectedPriceMin = null;
        _selectedPriceMax = null;
    }
  }

  // --- Favorite ---

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any((f) => f is Listing && f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  void _handleListingTap(Listing listing) {
    final subState = ref.read(subscriptionProvider);
    final settingsAsync = ref.read(appSettingsProvider);
    final user = ref.read(profileProvider).user;
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => true,
    );

    final isOwner = user != null && listing.userId == user.id;
    if (!isOwner && subscriptionEnabled && !subState.canCreateListing) {
      _showSubscriptionRequiredDialog();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listingId: listing.id),
      ),
    );
  }

  Future<void> _showSubscriptionRequiredDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_outlined,
                    size: 32, color: AppColors.accent600),
              ),
              const SizedBox(height: 16),
              Text('Subscription Required',
                  style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'You need an active subscription to view property details and contact owners.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: context.theme.divider),
                        foregroundColor: context.theme.textPrimary,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.accent500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: const Text('View Plans'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const SubscriptionPlansScreen()),
      );
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final searchState = ref.watch(searchResultsProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(favoritesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          CustomScrollView(
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
                  onSearchChanged: _onSearchChanged,
                  onSubmitted: (_) => _performSearch(),
                  onClear: _clearSearch,
                  onFilterTap: _showFilterSheet,
                ),
              ),

              if (_hasActiveFilters)
                SliverToBoxAdapter(
                  child: _buildActiveFilterChips(l10n),
                ),

              if (_hasSearched)
                _buildSearchResults(searchState, l10n)
              else ...[
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                            l10n.listingsFeatured, isFeatured: true),
                        _buildFeaturedListings(featuredState),
                        _buildSectionHeader(l10n.listingsTitle),
                      ],
                    ),
                  ),
                ),
                _buildLatestListings(listingsState),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChips(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.cardBg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedType != null)
              _filterChip(
                _selectedType == 'house'
                    ? l10n.listingHouse
                    : l10n.listingLand,
                () => _removeFilterAndCheck(
                    () => setState(() => _selectedType = null)),
              ),
            if (_selectedListingType != null)
              _filterChip(
                _selectedListingType == 'sale'
                    ? l10n.listingForSale
                    : l10n.listingForRent,
                () => _removeFilterAndCheck(
                    () => setState(() => _selectedListingType = null)),
              ),
            if (_selectedPriceLabel != null)
              _filterChip(
                _getLocalizedPriceLabel(_selectedPriceLabel!, l10n),
                () => _removeFilterAndCheck(() => setState(() {
                      _selectedPriceLabel = null;
                      _selectedPriceMin = null;
                      _selectedPriceMax = null;
                    })),
              ),
            if (_searchController.text.isNotEmpty)
              _filterChip(
                '${l10n.searchPlaceholder.split('...').first}: ${_searchController.text}',
                () {
                  _searchController.clear();
                  _removeFilterAndCheck(() {});
                },
              ),
            if (_isFeaturedFilter)
              _filterChip(
                l10n.listingsFeatured,
                () => _removeFilterAndCheck(
                    () => setState(() => _isFeaturedFilter = false)),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary200),
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

  String _getLocalizedPriceLabel(String label, AppLocalizations l10n) {
    switch (label) {
      case 'Under 5M':
        return l10n.searchUnder5M;
      case '5M-10M':
        return l10n.search5M10M;
      case '10M-50M':
        return l10n.search10M50M;
      case '50M-100M':
        return l10n.search50M100M;
      case '100M+':
        return l10n.search100MPlus;
      default:
        return label;
    }
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.accent200),
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
              child: const Icon(Icons.close,
                  size: 14, color: AppColors.accent600),
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
        child: WaveMessageScreen.error(
          title: 'Search Error',
          subtitle: state.errorMessage!,
          onRetry: _performSearch,
          isEmbedded: true,
        ),
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
              child: PropertyListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => _handleListingTap(listing),
              ),
            );
          },
          childCount:
              state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildSkeletonResults(int count) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(isLoading: true),
            );
          },
          childCount: count,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isFeatured = false}) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isFeatured
                ? l10n.homeFeaturedPremium.toUpperCase()
                : l10n.homeLatestRecently.toUpperCase(),
            style: AppTextStyles.eyebrow,
          ),
          const SizedBox(height: 4),
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

  Widget _buildFeaturedListings(ListingsState state) {
    if (state.isLoading) {
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
              child:
                  FeaturedListingCard(listing: null, isLoading: true),
            ),
          ),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child:
              Text(AppLocalizations.of(context).listingsNoResults),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.listings.length,
        itemBuilder: (context, index) {
          final listing = state.listings[index];
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
    );
  }

  Widget _buildLatestListings(ListingsState state) {
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
          child:
              Text(AppLocalizations.of(context).listingsNoResults),
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
          childCount:
              state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final dynamic user;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool hasActiveFilters;
  final String searchQuery;
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
    required this.onSearchChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
                            _getGreeting(),
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
                      _buildProfileAvatar(context),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: context.cardBg.withValues(alpha: isDark ? 0.8 : 0.9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: hasActiveFilters
                            ? AppColors.accent500.withValues(alpha: 0.5)
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.05)),
                        width: 1.5,
                      ),
                      boxShadow: AppColors.shadowPremium,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: hasActiveFilters
                              ? AppColors.accent500
                              : context.theme.iconSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            focusNode: focusNode,
                            onChanged: onSearchChanged,
                            onSubmitted: onSubmitted,
                            style: AppTextStyles.bodyLarge
                                .copyWith(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: l10n.searchPlaceholder,
                              hintStyle: AppTextStyles.bodyMedium
                                  .copyWith(color: context.textSecondary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: onClear,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.close_rounded,
                                color: context.theme.iconSecondary,
                                size: 20,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return Container(
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
        child: user != null
            ? Text(
                user.initials,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const Icon(Icons.person_rounded, color: Colors.white, size: 24),
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
              color: hasActiveFilters
                  ? AppColors.accent500
                  : AppColors.primary400,
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
