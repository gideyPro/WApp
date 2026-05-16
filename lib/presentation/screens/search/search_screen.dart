import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../providers/listing_provider.dart';
import '../../providers/app_providers.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../listing/listing_detail_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../settings/settings_screen.dart';
import '../../../data/models/listing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';

/// Modern Search & Filter Screen
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialType;
  final String? initialListingType;
  final bool isFeatured;

  const SearchScreen({
    super.key,
    this.initialType,
    this.initialListingType,
    this.isFeatured = false,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<int> _togglingFavorites = {};

  String? _selectedType; // 'house', 'land', or null for all
  String? _selectedListingType; // 'sale', 'rental', or null for all
  String _selectedSort = 'newest';
  int? _selectedPriceMin;
  int? _selectedPriceMax;
  String? _selectedPriceLabel;
  bool _isFeaturedFilter = false;
  Map<String, dynamic> _activeFilters = {};
  bool _hasSearched = false;
  bool _rentalEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadSettings();
    _applyInitialFilters();
  }

  void _applyInitialFilters() {
    final widget = this.widget;
    if (widget.initialType != null) {
      setState(() => _selectedType = widget.initialType);
    }
    if (widget.initialListingType != null) {
      setState(() => _selectedListingType = widget.initialListingType);
    }
    if (widget.isFeatured) {
      setState(() {
        _isFeaturedFilter = true;
        _activeFilters = {..._activeFilters, 'is_featured': 'true'};
      });
      _performSearch();
    }
  }

  Future<void> _loadSettings() async {
    try {
      final response =
          await ApiClient().dio.get(ApiConstants.apiBase + '/settings');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data['data'];
        if (data is Map) {
          setState(() {
            _rentalEnabled = data['rental_enabled'] == true;
          });
        }
      }
    } catch (_) {
      // Silently fail - default to rental disabled
    }
  }

  void _onScroll() {
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    _activeFilters = {};
    if (_isFeaturedFilter) {
      _activeFilters['is_featured'] = true;
    }
    if (query.isNotEmpty) _activeFilters['location'] = query;
    if (_selectedType != null) _activeFilters['type'] = _selectedType;
    if (_selectedListingType != null)
      _activeFilters['listing_type'] = _selectedListingType;
    _activeFilters['sort'] = _selectedSort;

    // Price range filter
    if (_selectedPriceMin != null)
      _activeFilters['price_min'] = _selectedPriceMin!;
    if (_selectedPriceMax != null)
      _activeFilters['price_max'] = _selectedPriceMax!;

    setState(() => _hasSearched = true);
    ref.read(searchResultsProvider.notifier).loadListings(filters: _activeFilters);
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
    // Reset the provider to initial state
    ref.invalidate(searchResultsProvider);
  }

  /// Remove a filter, re-search with remaining filters, or reset if none left
  void _removeFilterAndCheck(VoidCallback onRemove) {
    onRemove();
    if (_hasActiveFilters) {
      // Still have filters, re-search with remaining ones
      _performSearch();
    } else if (_hasSearched) {
      // No filters left, reset to welcome state
      setState(() => _hasSearched = false);
    }
  }

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedListingType != null ||
      _selectedSort != 'newest' ||
      _selectedPriceLabel != null ||
      _isFeaturedFilter ||
      _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final listingsState = ref.watch(searchResultsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
      body: Column(
        children: [
          // Search Header
          _buildSearchHeader(),

          // Active Filter Chips
          if (_hasActiveFilters) _buildActiveFilterChips(),

          // Results
          Expanded(
            child: _hasSearched
                ? _buildResults(listingsState)
                : _buildWelcomeState(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.sheetBg,
        boxShadow: AppColors.shadowSm,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios, size: 16,
                    color: context.iconPrimary),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
              // Unified search container
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: context.inputBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.divider),
                  ),
                  child: Row(
                    children: [
                      // Search icon + input
                      Expanded(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Icon(Icons.search,
                                  size: 18, color: context.textMuted),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: l10n.searchPlaceholder,
                                  border: InputBorder.none,
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 0),
                                  isDense: true,
                                ),
                                style: TextStyle(fontSize: 14,
                                    color: context.textPrimary),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (_) => _performSearch(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Vertical divider
                      Container(width: 1, height: 24, color: context.divider),
                      // Filter button
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: InkWell(
                          onTap: _showFilterModal,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? AppColors.accent50
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.tune,
                              size: 20,
                              color: _hasActiveFilters
                                  ? AppColors.accent600
                                  : context.textMuted,
                            ),
                          ),
                        ),
                      ),
                      // Vertical divider
                      Container(width: 1, height: 24, color: context.divider),
                      // Search button
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: InkWell(
                          onTap: _performSearch,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.accent500,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                            child: const Icon(Icons.search,
                                size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedType != null)
              _filterChip(
                _selectedType == 'house' ? l10n.listingHouse : l10n.listingLand,
                () => _removeFilterAndCheck(
                    () => setState(() => _selectedType = null)),
              ),
            if (_selectedListingType != null)
              _filterChip(
                _selectedListingType == 'sale' ? l10n.listingForSale : l10n.listingForRent,
                () => _removeFilterAndCheck(
                    () => setState(() => _selectedListingType = null)),
              ),
            if (_selectedPriceLabel != null)
              _filterChip(
                _getLocalizedPriceLabel(_selectedPriceLabel!),
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
                    const Icon(Icons.close, size: 14, color: AppColors.primary600),
                    const SizedBox(width: 4),
                    Text(
                      l10n.searchClearAll,
                      style: const TextStyle(
                          fontSize: 12,
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

  String _getLocalizedPriceLabel(String label) {
    final l10n = AppLocalizations.of(context);
    switch (label) {
      case 'Under 5M': return l10n.searchUnder5M;
      case '5M-10M': return l10n.search5M10M;
      case '10M-50M': return l10n.search10M50M;
      case '50M-100M': return l10n.search50M100M;
      case '100M+': return l10n.search100MPlus;
      default: return label;
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
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent700),
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

  Widget _buildWelcomeState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 80, color: AppColors.primary200),
          const SizedBox(height: 24),
          Text(
            l10n.searchFindProperty,
            style: AppTextStyles.headline4.copyWith(
              fontWeight: FontWeight.w800,
              color: context.theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              l10n.searchWelcomeSubtitle,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          // Popular Searches
          Text(
            l10n.searchPopular,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _popularSearchChip(l10n.listingHouses, () {
                setState(() => _selectedType = 'house');
                _performSearch();
              }),
              _popularSearchChip(l10n.listingLands, () {
                setState(() => _selectedType = 'land');
                _performSearch();
              }),
              _popularSearchChip(l10n.listingForSale, () {
                setState(() => _selectedListingType = 'sale');
                _performSearch();
              }),
              if (_rentalEnabled)
                _popularSearchChip(l10n.listingForRent, () {
                  setState(() => _selectedListingType = 'rental');
                  _performSearch();
                }),
              _popularSearchChip(l10n.listingsFeatured, () {
                setState(() => _isFeaturedFilter = true);
                _performSearch();
              }),
              _popularSearchChip(l10n.searchUnder5M, () {
                setState(() {
                  _selectedPriceLabel = 'Under 5M';
                  _selectedPriceMin = 0;
                  _selectedPriceMax = 5000000;
                });
                _performSearch();
              }),
              _popularSearchChip(l10n.search5M10M, () {
                setState(() {
                  _selectedPriceLabel = '5M-10M';
                  _selectedPriceMin = 5000000;
                  _selectedPriceMax = 10000000;
                });
                _performSearch();
              }),
              _popularSearchChip(l10n.search10M50M, () {
                setState(() {
                  _selectedPriceLabel = '10M-50M';
                  _selectedPriceMin = 10000000;
                  _selectedPriceMax = 50000000;
                });
                _performSearch();
              }),
              _popularSearchChip(l10n.search50M100M, () {
                setState(() {
                  _selectedPriceLabel = '50M-100M';
                  _selectedPriceMin = 50000000;
                  _selectedPriceMax = 100000000;
                });
                _performSearch();
              }),
              _popularSearchChip(l10n.search100MPlus, () {
                setState(() {
                  _selectedPriceLabel = '100M+';
                  _selectedPriceMin = 100000000;
                  _selectedPriceMax = null;
                });
                _performSearch();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _popularSearchChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.primary200),
        ),
        child: Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary700),
        ),
      ),
    );
  }

  void _handleListingTap(Listing listing) {
    final subState = ref.read(subscriptionProvider);
    final settingsAsync = ref.read(appSettingsProvider);
    final user = ref.read(profileProvider).user;
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => true, // Default to true if not loaded
    );

    // Skip check if: 
    // 1. User is owner
    // 2. Staff
    // 3. Subscriptions disabled
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
              const Text(
                'Subscription Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'You need an active subscription to view property details and contact owners.',
                style: TextStyle(color: AppColors.primary500),
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
                        side: BorderSide(color: AppColors.primary200),
                        foregroundColor: AppColors.primary600,
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
        MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
      );
    }
  }

  Widget _buildResults(ListingsState state) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading && state.listings.isEmpty) {
      return _buildSkeletonList(5);
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return WaveMessageScreen.error(
        title: 'Search Error',
        subtitle: state.errorMessage!,
        onRetry: _performSearch,
        isEmbedded: true,
      );
    }

    if (state.listings.isEmpty) {
      return WaveEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.searchNoResultsTitle,
        subtitle: l10n.searchNoResultsSubtitle,
        actionLabel: l10n.searchClearAll,
        onAction: _clearAllFilters,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.searchFoundCount(state.total),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary500),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount:
                    state.listings.length + (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
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
              ),
              if (state.isLoading && state.listings.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    color: AppColors.zinc50.withValues(alpha: 0.7),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.zinc200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Container(color: AppColors.zinc200),
                  ),
                ),
                Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 20, width: 120, color: AppColors.zinc200),
                      const SizedBox(height: 10),
                      Container(
                          height: 16,
                          width: double.infinity,
                          color: AppColors.zinc200),
                      const SizedBox(height: 8),
                      Container(
                          height: 14, width: 180, color: AppColors.zinc200),
                      const SizedBox(height: 14),
                      Row(children: [
                        Container(
                            height: 20, width: 60, color: AppColors.zinc200),
                        const SizedBox(width: 8),
                        Container(
                            height: 20, width: 45, color: AppColors.zinc200),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final l10n = AppLocalizations.of(context);
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.searchFilters,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedType = null;
                              _selectedListingType = null;
                              _selectedSort = 'newest';
                              _selectedPriceLabel = null;
                              _selectedPriceMin = null;
                              _selectedPriceMax = null;
                            });
                          },
                          child: Text(l10n.searchReset,
                               style: const TextStyle(color: AppColors.primary500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Property Type
                    Text(l10n.searchPropertyType,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      (l10n.searchFilterAll, null, _selectedType == null),
                      (l10n.listingHouse, 'house', _selectedType == 'house'),
                      (l10n.listingLand, 'land', _selectedType == 'land'),
                    ], (v) {
                      setModalState(() => _selectedType = v);
                    }),

                    const SizedBox(height: 16),

                    // Listing Status (only if rental enabled)
                    if (_rentalEnabled) ...[
                      Text(l10n.searchListingStatus,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      _modalChipRow([
                        (l10n.searchFilterAll, null, _selectedListingType == null),
                        (l10n.listingForSale, 'sale', _selectedListingType == 'sale'),
                        (
                          l10n.listingForRent,
                          'rental',
                          _selectedListingType == 'rental'
                        ),
                      ], (v) {
                        setModalState(() => _selectedListingType = v);
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Price Range
                    Text(l10n.searchPriceRange,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      (l10n.searchFilterAny, null, _selectedPriceLabel == null),
                      (
                        l10n.searchUnder5M,
                        'Under 5M',
                        _selectedPriceLabel == 'Under 5M'
                      ),
                      (l10n.search5M10M, '5M-10M', _selectedPriceLabel == '5M-10M'),
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
                      (l10n.search100MPlus, '100M+', _selectedPriceLabel == '100M+'),
                    ], (v) {
                      setModalState(() => _setPriceFilter(v as String?));
                    }),

                    const SizedBox(height: 16),

                    // Sort By (last)
                    Text(l10n.searchSortBy,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    _modalChipRow([
                      (l10n.searchSortNewest, 'newest', _selectedSort == 'newest'),
                      (l10n.searchSortOldest, 'oldest', _selectedSort == 'oldest'),
                      (l10n.searchSortPriceLow, 'price_low', _selectedSort == 'price_low'),
                      (
                        l10n.searchSortPriceHigh,
                        'price_high',
                        _selectedSort == 'price_high'
                      ),
                    ], (v) {
                      setModalState(() => _selectedSort = v as String);
                    }),

                    const SizedBox(height: 24),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  Widget _modalChipRow(
      List<(String, dynamic, bool)> chips, void Function(dynamic) onSelected) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((chip) {
        final (label, value, isSelected) = chip;
        return GestureDetector(
          onTap: () => onSelected(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent500 : AppColors.primary50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primary700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isFavorite(int listingId) {
    final favState = ref.read(favoritesProvider);
    return favState.favorites.any((f) => f.id == listingId);
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  Future<void> _toggleFavorite(int listingId) async {
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }
}
