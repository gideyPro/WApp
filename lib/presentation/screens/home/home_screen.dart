import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../search/search_screen.dart';
import '../listing/listing_detail_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../settings/settings_screen.dart';

/// Home Screen - Search bar + featured/latest listings
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

  // Search state
  bool _isSearching = false;
  String _searchQuery = '';
  List<Listing> _searchResults = [];
  bool _isLoadingSearch = false;

  // Filter state
  String? _selectedType;
  String? _selectedListingType;
  String _selectedSort = 'newest';
  int? _selectedPriceMin;
  int? _selectedPriceMax;

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
        ref.read(listingsProvider.notifier).loadListings();
      }
    }
  }

  void _onScroll() {
    if (!_isSearching) {
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
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchResults = [];
      });
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoadingSearch = true;
      _searchQuery = query;
      _isSearching = true;
    });

    try {
      final filters = <String, dynamic>{
        'location': query,
        'sort': _selectedSort,
      };
      if (_selectedType != null) filters['type'] = _selectedType;
      if (_selectedListingType != null) filters['listing_type'] = _selectedListingType;
      if (_selectedPriceMin != null) filters['price_min'] = _selectedPriceMin;
      if (_selectedPriceMax != null) filters['price_max'] = _selectedPriceMax;

      final response = await ApiClient().dio.get(
        ApiConstants.listings,
        queryParameters: filters,
      );

      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        final listingsData = data is Map && data['data'] is List
            ? data['data'] as List
            : data is List ? data : [];
        setState(() {
          _searchResults = listingsData
              .map((json) => Listing.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoadingSearch = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSearch = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchResults = [];
    });
  }

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
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
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
                    Text(
                      l10n.searchFilters,
                      style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),

                    // Property Type
                    Text(l10n.searchPropertyType, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _buildFilterChips(
                      options: [
                        (null, l10n.searchFilterAll),
                        ('house', l10n.listingHouse),
                        ('land', l10n.listingLand),
                      ],
                      selected: _selectedType,
                      onSelect: (val) => setSheetState(() => _selectedType = val),
                    ),
                    const SizedBox(height: 16),

                    // Listing Type
                    Text(l10n.searchListingStatus, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _buildFilterChips(
                      options: [
                        (null, l10n.searchFilterAll),
                        ('sale', l10n.listingSale),
                        ('rental', l10n.listingRent),
                      ],
                      selected: _selectedListingType,
                      onSelect: (val) => setSheetState(() => _selectedListingType = val),
                    ),
                    const SizedBox(height: 16),

                    // Sort
                    Text(l10n.searchSortBy, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _buildFilterChips(
                      options: [
                        ('newest', l10n.searchSortNewest),
                        ('oldest', l10n.searchSortOldest),
                        ('price_low', l10n.searchSortPriceLow),
                        ('price_high', l10n.searchSortPriceHigh),
                      ],
                      selected: _selectedSort,
                      onSelect: (val) => setSheetState(() => _selectedSort = val!),
                    ),
                    const SizedBox(height: 24),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (_isSearching) {
                            _performSearch(_searchQuery);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: Text(l10n.searchApplyFilters),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFilterChips({
    required List<(String?, String)> options,
    required String? selected,
    required ValueChanged<String?> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final value = opt.$1;
        final label = opt.$2;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => onSelect(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent500 : context.cardBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.accent500 : context.divider,
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : context.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
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
                child: const Icon(Icons.workspace_premium_outlined, size: 32, color: AppColors.accent600),
              ),
              const SizedBox(height: 16),
              Text('Subscription Required', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('You need an active subscription to view property details and contact owners.', style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), side: BorderSide(color: AppColors.primary200), foregroundColor: context.textPrimary), child: const Text('Cancel'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13), backgroundColor: AppColors.accent600, foregroundColor: Colors.white), child: const Text('View Plans'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()));
    }
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(favoritesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
      body: Stack(
        children: [
          // Decorative background
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
          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Search bar header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SearchBarDelegate(
                  searchController: _searchController,
                  focusNode: _searchFocusNode,
                  isSearching: _isSearching,
                  searchQuery: _searchQuery,
                  onSearchChanged: _onSearchChanged,
                  onClear: _clearSearch,
                  onFilterTap: _showFilterSheet,
                ),
              ),

              // Search results or normal content
              if (_isSearching) ...[
                if (_isLoadingSearch)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_searchResults.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.primary300),
                          const SizedBox(height: 12),
                          Text(l10n.listingsNoResults, style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final listing = _searchResults[index];
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
                        childCount: _searchResults.length,
                      ),
                    ),
                  ),
              ] else ...[
                // Featured listings
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        _buildSectionHeader(context, l10n.listingsFeatured, isFeatured: true),
                        _buildFeaturedListings(featuredState),
                        _buildSectionHeader(context, l10n.listingsTitle, isFeatured: false),
                      ],
                    ),
                  ),
                ),
                // Latest listings
                _buildLatestListings(listingsState),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {bool isFeatured = false}) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFeatured ? l10n.homeFeaturedPremium.toUpperCase() : l10n.homeLatestRecently.toUpperCase(),
                style: AppTextStyles.eyebrow,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5, color: context.textPrimary),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(isFeatured: isFeatured), settings: const RouteSettings(name: '/search'))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.primary200),
              ),
              child: Text(l10n.homeViewAll, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary700)),
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
            child: SizedBox(width: 280, child: FeaturedListingCard(listing: null, isLoading: true)),
          ),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SizedBox(height: 80, child: Center(child: Text(AppLocalizations.of(context).listingsNoResults)));
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
            for (int i = 0; i < 3; i++) const PropertyListingCard(isLoading: true),
          ]),
        ),
      );
    }
    if (state.listings.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text(AppLocalizations.of(context).listingsNoResults)));
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == state.listings.length) {
              return const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator()));
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
}

/// Search Bar Header Delegate
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  _SearchBarDelegate({
    required this.searchController,
    required this.focusNode,
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.primary900 : AppColors.primary50,
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: context.divider),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, color: ThemeColors(context).iconSecondary, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: searchController,
                focusNode: focusNode,
                onChanged: onSearchChanged,
                style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).searchPlaceholder,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (searchQuery.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.close_rounded, color: ThemeColors(context).iconSecondary, size: 20),
                ),
              ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.tune_rounded, color: AppColors.accent600, size: 22),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 100;
  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return oldDelegate.isSearching != isSearching ||
        oldDelegate.searchQuery != searchQuery;
  }
}
