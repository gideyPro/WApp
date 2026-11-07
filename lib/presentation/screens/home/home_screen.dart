import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/car_data.dart';
import '../../../data/job_data.dart';
import '../../../data/models/listing.dart';
import '../../../data/models/job_seeker_profile.dart';
import '../../../data/models/v2/buyer_order.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/car_providers.dart';
import '../../providers/job_providers.dart';
import '../../widgets/featured_listing_card.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/vehicle_listing_card.dart';
import '../../widgets/vehicle_featured_card.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../jobs/widgets/job_listing_card.dart';
import '../job_seekers/widgets/job_seeker_card.dart';
import '../../providers/job_seeker_providers.dart';
import '../../providers/v2_order_provider.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../widgets/status_helpers.dart';
import 'widgets/public_order_card.dart';
import 'filter_sheet.dart';

enum HomeCategory { property, vehicles, jobs, orders, all }

enum JobsSection { listings, seekers }

enum ListingTypeSection { sale, rent }

enum AllSection { all, sale, rent }

enum OrdersSection { all, property, vehicles }

extension HomeCategoryX on HomeCategory {
  String label(AppLocalizations l10n) {
    switch (this) {
      case HomeCategory.property:
        return l10n.listingSummaryProperty;
      case HomeCategory.vehicles:
        return l10n.listingCarPlural;
      case HomeCategory.jobs:
        return l10n.homeJobs;
      case HomeCategory.orders:
        return l10n.ordersTitle;
      case HomeCategory.all:
        return l10n.searchFilterAll;
    }
  }

  IconData get icon {
    switch (this) {
      case HomeCategory.property:
        return Icons.home_rounded;
      case HomeCategory.vehicles:
        return Icons.directions_car_rounded;
      case HomeCategory.jobs:
        return Icons.work_outline;
      case HomeCategory.orders:
        return Icons.receipt_long_rounded;
      case HomeCategory.all:
        return Icons.apps_rounded;
    }
  }
}

extension OrdersSectionX on OrdersSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case OrdersSection.all:
        return l10n.searchFilterAll;
      case OrdersSection.property:
        return l10n.listingSummaryProperty;
      case OrdersSection.vehicles:
        return l10n.listingCarPlural;
    }
  }

  IconData get icon {
    switch (this) {
      case OrdersSection.all:
        return Icons.apps_rounded;
      case OrdersSection.property:
        return Icons.home_work_outlined;
      case OrdersSection.vehicles:
        return Icons.directions_car_outlined;
    }
  }

  /// Coarse browse filter understood by `/api/v2/orders/browse`.
  ///
  /// `property` groups house + land; `vehicle` maps to car requests. The old
  /// `type` filter is too narrow for the Property tab (it would hide land).
  String? get browseCategory {
    switch (this) {
      case OrdersSection.all:
        return null;
      case OrdersSection.property:
        return 'property';
      case OrdersSection.vehicles:
        return 'vehicle';
    }
  }
}

extension JobsSectionX on JobsSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case JobsSection.listings:
        return l10n.homeJobs;
      case JobsSection.seekers:
        return l10n.homeSeekers;
    }
  }

  IconData get icon {
    switch (this) {
      case JobsSection.listings:
        return Icons.work_outline;
      case JobsSection.seekers:
        return Icons.person_search_outlined;
    }
  }
}

extension ListingTypeSectionX on ListingTypeSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case ListingTypeSection.sale:
        return l10n.listingSale;
      case ListingTypeSection.rent:
        return l10n.listingRent;
    }
  }

  IconData get icon {
    switch (this) {
      case ListingTypeSection.sale:
        return Icons.sell_outlined;
      case ListingTypeSection.rent:
        return Icons.key_outlined;
    }
  }

  String get wireValue => this == ListingTypeSection.sale ? 'sale' : 'rental';
}

extension AllSectionX on AllSection {
  String label(AppLocalizations l10n) {
    switch (this) {
      case AllSection.all:
        return l10n.searchFilterAll;
      case AllSection.sale:
        return l10n.listingSale;
      case AllSection.rent:
        return l10n.listingRent;
    }
  }

  IconData get icon {
    switch (this) {
      case AllSection.all:
        return Icons.apps_rounded;
      case AllSection.sale:
        return Icons.sell_outlined;
      case AllSection.rent:
        return Icons.key_outlined;
    }
  }

  String? get wireValue {
    switch (this) {
      case AllSection.all:
        return null;
      case AllSection.sale:
        return 'sale';
      case AllSection.rent:
        return 'rental';
    }
  }
}

sealed class _AllFeedItem {
  DateTime get createdAt;
}

class _ListingFeedItem extends _AllFeedItem {
  final Listing listing;
  _ListingFeedItem(this.listing);

  @override
  DateTime get createdAt => listing.createdAt;
}

class _SeekerFeedItem extends _AllFeedItem {
  final JobSeekerProfile profile;
  _SeekerFeedItem(this.profile);

  @override
  DateTime get createdAt =>
      profile.createdAt ??
      profile.updatedAt ??
      DateTime.fromMillisecondsSinceEpoch(0);
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

  UnifiedFilterValues _filterValues = const UnifiedFilterValues(
    category: HomeCategory.property,
    listingType: 'sale',
  );
  bool _hasSearched = false;
  bool _isAutoRefreshing = false;
  HomeCategory _selectedCategory = HomeCategory.property;
  ListingTypeSection _listingTypeSection = ListingTypeSection.sale;
  AllSection _allSection = AllSection.all;
  JobsSection _jobsSection = JobsSection.listings;
  OrdersSection _ordersSection = OrdersSection.all;

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
      ref.read(listingsProvider.notifier).loadListings(
            filters: {'listing_type': 'sale'},
          );
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
      _reloadCurrentFeed();
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
      ref.read(favoritesProvider.notifier).loadFavorites(),
    ];
    if (ref.read(subscriptionProvider).canViewVip) {
      futures.add(ref.read(vipListingsProvider.notifier).loadVipListings());
    }
    if (_selectedCategory == HomeCategory.vehicles) {
      futures.add(ref.read(homeCarListingsProvider.notifier).loadListings(
            filters: {'listing_type': _listingTypeSection.wireValue},
          ));
    } else if (_selectedCategory == HomeCategory.jobs) {
      if (_jobsSection == JobsSection.seekers) {
        futures.add(
            ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles());
      } else {
        futures.add(ref.read(homeJobListingsProvider.notifier).loadListings());
      }
    } else if (_selectedCategory == HomeCategory.orders) {
      // Pull-to-refresh must re-run the active query, not reset the feed to
      // the unfiltered browse list.
      futures.add(ref.read(homeOrdersProvider.notifier).loadOrders(
            category: _ordersSection.browseCategory,
            location: _ordersLocationQuery,
            budgetMin: _filterValues.priceMin?.toDouble(),
            budgetMax: _filterValues.priceMax?.toDouble(),
          ));
    } else if (_selectedCategory == HomeCategory.all) {
      final filters = _allSection == AllSection.all
          ? null
          : {'listing_type': _allSection.wireValue};
      futures.add(
          ref.read(listingsProvider.notifier).loadListings(filters: filters));
      futures.add(ref
          .read(homeCarListingsProvider.notifier)
          .loadListings(filters: filters));
      if (_allSection == AllSection.all) {
        futures.add(ref.read(homeJobListingsProvider.notifier).loadListings());
        futures.add(
            ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles());
      }
    } else {
      // HomeCategory.property
      futures.add(ref.read(listingsProvider.notifier).loadListings(
            filters: {'listing_type': _listingTypeSection.wireValue},
          ));
    }
    await Future.wait(futures);
  }

  void _onCategoryChanged(HomeCategory category) {
    if (category == _selectedCategory) return;
    _searchController.clear();
    setState(() {
      _selectedCategory = category;
      _hasSearched = false;
      _filterValues = UnifiedFilterValues(
        category: category,
        listingType: category == HomeCategory.all
            ? _allSection.wireValue
            : (category == HomeCategory.jobs || category == HomeCategory.orders)
                ? null
                : _listingTypeSection.wireValue,
        forSeekers: category == HomeCategory.jobs &&
            _jobsSection == JobsSection.seekers,
      );
    });
    ref.invalidate(searchResultsProvider);
    _reloadCurrentFeed();
  }

  void _onJobsSectionChanged(JobsSection section) {
    if (section == _jobsSection) return;
    _searchController.clear();
    setState(() {
      _jobsSection = section;
      _hasSearched = false;
      _filterValues = UnifiedFilterValues(
        category: HomeCategory.jobs,
        forSeekers: section == JobsSection.seekers,
      );
    });
    ref.invalidate(searchResultsProvider);
    if (section == JobsSection.seekers) {
      ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles();
    } else {
      ref.read(homeJobListingsProvider.notifier).loadListings();
    }
  }

  void _onOrdersSectionChanged(OrdersSection section) {
    if (section == _ordersSection) return;
    _searchController.clear();
    setState(() {
      _ordersSection = section;
      _hasSearched = false;
    });
    ref.invalidate(searchResultsProvider);
    _reloadCurrentFeed();
  }

  void _onListingTypeSectionChanged(ListingTypeSection section) {
    if (section == _listingTypeSection) return;
    _searchController.clear();
    setState(() {
      _listingTypeSection = section;
      _hasSearched = false;
      _filterValues = _filterValues.copyWith(
        category: _selectedCategory,
        listingType: section.wireValue,
      );
    });
    ref.invalidate(searchResultsProvider);
    _reloadCurrentFeed();
  }

  void _onAllSectionChanged(AllSection section) {
    if (section == _allSection) return;
    _searchController.clear();
    setState(() {
      _allSection = section;
      _hasSearched = false;
      _filterValues = _filterValues.copyWith(
        category: HomeCategory.all,
        listingType: section.wireValue,
      );
    });
    ref.invalidate(searchResultsProvider);
    _reloadCurrentFeed();
  }

  void _handleFilterTap() async {
    final prepared = _filterValues.copyWith(
      category: _selectedCategory,
      listingType: _selectedCategory == HomeCategory.all
          ? _allSection.wireValue
          : _selectedCategory == HomeCategory.jobs ||
                  _selectedCategory == HomeCategory.orders
              ? null
              : _listingTypeSection.wireValue,
      forSeekers: _selectedCategory == HomeCategory.jobs &&
          _jobsSection == JobsSection.seekers,
    );
    final result = await showModalBottomSheet<UnifiedFilterValues>(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialValues: prepared,
        showCategoryToggle: true,
      ),
    );
    if (result == null) return;

    final noOp = result == prepared;
    setState(() {
      _filterValues = result;
      _selectedCategory = result.category;
      if (result.category == HomeCategory.jobs) {
        _jobsSection =
            result.forSeekers ? JobsSection.seekers : JobsSection.listings;
      } else if (result.category == HomeCategory.all) {
        if (result.listingType == 'sale') {
          _allSection = AllSection.sale;
        } else if (result.listingType == 'rental') {
          _allSection = AllSection.rent;
        } else {
          _allSection = AllSection.all;
        }
      } else if (result.category == HomeCategory.orders) {
        // Orders only expose a budget range; no listing-type section applies.
      } else {
        if (result.listingType == 'rental') {
          _listingTypeSection = ListingTypeSection.rent;
        } else {
          _listingTypeSection = ListingTypeSection.sale;
        }
      }
    });
    if (noOp) return;
    _performSearch();
  }

  Widget _buildCategoryPills(AppLocalizations l10n) {
    const categories = HomeCategory.values;
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = cat == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _onCategoryChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8.5),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? (isDark
                            ? AppColors.gradientAccent
                            : AppColors.gradientPrimary)
                        : null,
                    color: isSelected
                        ? null
                        : context.cardBg.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.accent500
                                      : AppColors.primary900)
                                  .withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
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
                        color:
                            isSelected ? Colors.white : context.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cat.label(l10n),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color:
                              isSelected ? Colors.white : context.textPrimary,
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

  /// Option A: Docked Segmented Capsule for Sub-Tabs
  Widget _buildSegmentedSubTabs<T>({
    required List<T> items,
    required T selectedItem,
    required String Function(T) label,
    required IconData Function(T) icon,
    required ValueChanged<T> onSelected,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardNavyDark
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFCBD5E1),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final isSelected = item == selectedItem;
              return GestureDetector(
                onTap: () => onSelected(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.cardNavyLight : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : const Color(0xFFCBD5E1).withValues(alpha: 0.5),
                            width: 0.6,
                          )
                        : Border.all(color: Colors.transparent, width: 0.6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 4,
                              offset: const Offset(0, 1.5),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.accent500,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4.5),
                      ],
                      Icon(
                        icon(item),
                        size: 12.5,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.primary900)
                            : context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        label(item),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : AppColors.primary900)
                              : context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsSectionPills() {
    final l10n = AppLocalizations.of(context);
    return _buildSegmentedSubTabs<JobsSection>(
      items: JobsSection.values,
      selectedItem: _jobsSection,
      label: (s) => s.label(l10n),
      icon: (s) => s.icon,
      onSelected: _onJobsSectionChanged,
    );
  }

  Widget _buildOrdersSectionPills() {
    final l10n = AppLocalizations.of(context);
    return _buildSegmentedSubTabs<OrdersSection>(
      items: OrdersSection.values,
      selectedItem: _ordersSection,
      label: (s) => s.label(l10n),
      icon: (s) => s.icon,
      onSelected: _onOrdersSectionChanged,
    );
  }

  Widget _buildListingTypeSectionPills() {
    final l10n = AppLocalizations.of(context);
    return _buildSegmentedSubTabs<ListingTypeSection>(
      items: ListingTypeSection.values,
      selectedItem: _listingTypeSection,
      label: (s) => s.label(l10n),
      icon: (s) => s.icon,
      onSelected: _onListingTypeSectionChanged,
    );
  }

  Widget _buildAllSectionPills() {
    final l10n = AppLocalizations.of(context);
    return _buildSegmentedSubTabs<AllSection>(
      items: AllSection.values,
      selectedItem: _allSection,
      label: (s) => s.label(l10n),
      icon: (s) => s.icon,
      onSelected: _onAllSectionChanged,
    );
  }

  Widget _buildCarLatestSliver(ListingsState state, AppLocalizations l10n) {
    final isRental = _listingTypeSection == ListingTypeSection.rent;
    final carListings = state.listings
        .where((l) =>
            l.propertyType == PropertyType.car &&
            l.listingType == (isRental ? ListingType.rental : ListingType.sale))
        .toList();

    if (state.isLoading && carListings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 3; i++)
              const VehicleListingCard(isLoading: true),
          ]),
        ),
      );
    }

    if (state.errorMessage != null && carListings.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(homeCarListingsProvider.notifier).loadListings(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.commonRetryMessage),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (carListings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_outlined,
                    size: 64, color: context.textMuted),
                const SizedBox(height: 16),
                Text(l10n.messageEmptySubtitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: context.textMuted)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == carListings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = carListings[index];
            final fav = _isFavorite(listing.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: VehicleListingCard(
                listing: listing,
                isFavorite: fav,
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => context.push('/cars/${listing.id}'),
              ),
            );
          },
          childCount: carListings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Map<String, dynamic>? _buildSearchFilters() {
    final effectiveValues = _filterValues.category != _selectedCategory
        ? _filterValues.copyWith(category: _selectedCategory)
        : _filterValues;
    final filters = <String, dynamic>{...effectiveValues.toQueryParams()};
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      filters[_selectedCategory == HomeCategory.jobs ? 'search' : 'location'] =
          query;
    }
    if (_selectedCategory == HomeCategory.all) {
      filters['include_all_types'] = true;
      if (_allSection != AllSection.all) {
        filters['listing_type'] = _allSection.wireValue;
      }
    } else if (_selectedCategory == HomeCategory.property ||
        _selectedCategory == HomeCategory.vehicles) {
      filters['listing_type'] = _listingTypeSection.wireValue;
    }
    return filters.isEmpty ? null : filters;
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }

    if (_hasSearched) {
      final filters = _buildSearchFilters();
      if (_selectedCategory == HomeCategory.orders) {
        _loadOrdersFeed(append: true, search: true);
      } else if (_selectedCategory == HomeCategory.jobs &&
          _jobsSection == JobsSection.seekers) {
        final state = ref.read(homeJobSeekerProfilesProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles(
                page: state.currentPage + 1,
                filters: filters,
              );
        }
      } else if (_selectedCategory == HomeCategory.vehicles) {
        final state = ref.read(homeCarListingsProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(homeCarListingsProvider.notifier).loadListings(
                page: state.currentPage + 1,
                filters: filters,
              );
        }
      } else if (_selectedCategory == HomeCategory.jobs) {
        final state = ref.read(homeJobListingsProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(homeJobListingsProvider.notifier).loadListings(
                page: state.currentPage + 1,
                filters: filters,
              );
        }
      } else {
        final state = ref.read(searchResultsProvider);
        if (!state.isLoadingMore && state.hasMore) {
          ref.read(searchResultsProvider.notifier).loadListings(
                page: state.currentPage + 1,
                filters: filters,
              );
        }
      }
    } else {
      if (_selectedCategory == HomeCategory.vehicles) {
        final carState = ref.read(homeCarListingsProvider);
        if (!carState.isLoading &&
            !carState.isLoadingMore &&
            carState.hasMore) {
          ref.read(homeCarListingsProvider.notifier).loadListings(
                page: carState.currentPage + 1,
                filters: {'listing_type': _listingTypeSection.wireValue},
              );
        }
      } else if (_selectedCategory == HomeCategory.jobs) {
        if (_jobsSection == JobsSection.seekers) {
          final seekerState = ref.read(homeJobSeekerProfilesProvider);
          if (!seekerState.isLoading &&
              !seekerState.isLoadingMore &&
              seekerState.hasMore) {
            ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles(
                  page: seekerState.currentPage + 1,
                );
          }
        } else {
          final jobState = ref.read(homeJobListingsProvider);
          if (!jobState.isLoading &&
              !jobState.isLoadingMore &&
              jobState.hasMore) {
            ref.read(homeJobListingsProvider.notifier).loadListings(
                  page: jobState.currentPage + 1,
                );
          }
        }
      } else if (_selectedCategory == HomeCategory.all) {
        final filters = _allSection == AllSection.all
            ? null
            : {'listing_type': _allSection.wireValue};

        final propState = ref.read(listingsProvider);
        if (!propState.isLoading &&
            !propState.isLoadingMore &&
            propState.hasMore) {
          ref.read(listingsProvider.notifier).loadListings(
                page: propState.currentPage + 1,
                filters: filters,
              );
        }
        final carState = ref.read(homeCarListingsProvider);
        if (!carState.isLoading &&
            !carState.isLoadingMore &&
            carState.hasMore) {
          ref.read(homeCarListingsProvider.notifier).loadListings(
                page: carState.currentPage + 1,
                filters: filters,
              );
        }
        if (_allSection == AllSection.all) {
          final jobState = ref.read(homeJobListingsProvider);
          if (!jobState.isLoading &&
              !jobState.isLoadingMore &&
              jobState.hasMore) {
            ref.read(homeJobListingsProvider.notifier).loadListings(
                  page: jobState.currentPage + 1,
                );
          }
          final seekerState = ref.read(homeJobSeekerProfilesProvider);
          if (!seekerState.isLoading &&
              !seekerState.isLoadingMore &&
              seekerState.hasMore) {
            ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles(
                  page: seekerState.currentPage + 1,
                );
          }
        }
      } else if (_selectedCategory == HomeCategory.orders) {
        final orderState = ref.read(homeOrdersProvider);
        if (!orderState.isLoading &&
            !orderState.isLoadingMore &&
            orderState.hasMore) {
          _loadOrdersFeed(append: true);
        }
      } else {
        // HomeCategory.property
        final propState = ref.read(listingsProvider);
        if (!propState.isLoading &&
            !propState.isLoadingMore &&
            propState.hasMore) {
          ref.read(listingsProvider.notifier).loadListings(
                page: propState.currentPage + 1,
                filters: {'listing_type': _listingTypeSection.wireValue},
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

  void _reloadCurrentFeed() {
    if (_selectedCategory == HomeCategory.vehicles) {
      ref.read(homeCarListingsProvider.notifier).loadListings(
            filters: {'listing_type': _listingTypeSection.wireValue},
          );
    } else if (_selectedCategory == HomeCategory.jobs) {
      if (_jobsSection == JobsSection.seekers) {
        ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles();
      } else {
        ref.read(homeJobListingsProvider.notifier).loadListings();
      }
    } else if (_selectedCategory == HomeCategory.orders) {
      _loadOrdersFeed();
    } else if (_selectedCategory == HomeCategory.all) {
      final filters = _allSection == AllSection.all
          ? null
          : {'listing_type': _allSection.wireValue};
      ref.read(listingsProvider.notifier).loadListings(filters: filters);
      ref.read(homeCarListingsProvider.notifier).loadListings(filters: filters);
      if (_allSection == AllSection.all) {
        ref.read(homeJobListingsProvider.notifier).loadListings();
        ref.read(homeJobSeekerProfilesProvider.notifier).loadProfiles();
      }
    } else {
      // HomeCategory.property
      ref.read(listingsProvider.notifier).loadListings(
            filters: {'listing_type': _listingTypeSection.wireValue},
          );
    }
    ref.invalidate(searchResultsProvider);
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
          _reloadCurrentFeed();
        }
      }
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    if (query.isEmpty && !_filterValues.hasAnyFilter) {
      if (_hasSearched) {
        setState(() => _hasSearched = false);
        _reloadCurrentFeed();
      }
      return;
    }

    setState(() => _hasSearched = true);
    final activeFilters = _buildSearchFilters();

    if (_selectedCategory == HomeCategory.orders) {
      _loadOrdersFeed(search: true);
    } else if (_selectedCategory == HomeCategory.jobs &&
        _jobsSection == JobsSection.seekers) {
      ref
          .read(homeJobSeekerProfilesProvider.notifier)
          .loadProfiles(filters: activeFilters);
    } else if (_selectedCategory == HomeCategory.vehicles) {
      ref
          .read(homeCarListingsProvider.notifier)
          .loadListings(filters: activeFilters);
    } else if (_selectedCategory == HomeCategory.jobs) {
      ref
          .read(homeJobListingsProvider.notifier)
          .loadListings(filters: activeFilters);
    } else {
      ref
          .read(searchResultsProvider.notifier)
          .loadListings(filters: activeFilters);
    }
  }

  /// Load (or extend) the public orders feed.
  ///
  /// Browse mode only applies the coarse section filter. Search mode adds the
  /// typed location and the budget range stored in [UnifiedFilterValues], which
  /// the backend expects as `budget_min` / `budget_max`.
  void _loadOrdersFeed({bool append = false, bool search = false}) {
    final notifier = ref.read(homeOrdersProvider.notifier);
    final category = _ordersSection.browseCategory;
    final location = search ? _ordersLocationQuery : null;
    final budgetMin = search ? _filterValues.priceMin?.toDouble() : null;
    final budgetMax = search ? _filterValues.priceMax?.toDouble() : null;

    if (append) {
      notifier.loadMore(
        category: category,
        location: location,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
      );
    } else {
      notifier.loadOrders(
        category: category,
        location: location,
        budgetMin: budgetMin,
        budgetMax: budgetMax,
      );
    }
  }

  String? get _ordersLocationQuery {
    final typed = _searchController.text.trim();
    if (typed.isNotEmpty) return typed;

    final stored = _filterValues.location?.trim();
    return stored == null || stored.isEmpty ? null : stored;
  }

  void _clearSearch() {
    _searchController.clear();
    if (_filterValues.hasAnyFilter) {
      _performSearch();
    } else {
      setState(() {
        _hasSearched = false;
      });
      _reloadCurrentFeed();
    }
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filterValues = UnifiedFilterValues(
        category: _selectedCategory,
        forSeekers: _selectedCategory == HomeCategory.jobs &&
            _jobsSection == JobsSection.seekers,
      );
      _hasSearched = false;
    });
    _reloadCurrentFeed();
  }

  void _removeFilterAndCheck(VoidCallback onRemove) {
    onRemove();
    if (_filterValues.hasAnyFilter || _searchController.text.isNotEmpty) {
      _performSearch();
    } else if (_hasSearched) {
      setState(() => _hasSearched = false);
      _reloadCurrentFeed();
    }
  }

  bool get _hasActiveFilters =>
      _filterValues.hasAnyFilter || _searchController.text.isNotEmpty;

  bool _isFavorite(int listingId) {
    final favState = ref.watch(favoritesProvider);
    return favState.favorites.any((f) => f.id == listingId);
  }

  Future<void> _toggleFavorite(int listingId) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }
    setState(() => _togglingFavorites.add(listingId));
    await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) setState(() => _togglingFavorites.remove(listingId));
  }

  bool _isToggling(int listingId) => _togglingFavorites.contains(listingId);

  void _handleListingTap(Listing listing) {
    if (listing.propertyType == PropertyType.car) {
      context.push('/cars/${listing.id}');
    } else {
      context.push('/listings/${listing.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredListingsProvider);
    final vipState = ref.watch(vipListingsProvider);
    final listingsState = ref.watch(listingsProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(favoritesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final carState = ref.watch(homeCarListingsProvider);
    final jobState = ref.watch(homeJobListingsProvider);
    final seekerState = ref.watch(homeJobSeekerProfilesProvider);
    final ordersState = ref.watch(homeOrdersProvider);
    final isSeekerSearch = _hasSearched &&
        _selectedCategory == HomeCategory.jobs &&
        _jobsSection == JobsSection.seekers;
    final searchState =
        _selectedCategory == HomeCategory.vehicles && _hasSearched
            ? carState
            : _selectedCategory == HomeCategory.jobs && _hasSearched
                ? jobState
                : ref.watch(searchResultsProvider);
    final canBrowseAll = _selectedCategory == HomeCategory.all && !_hasSearched;
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.oceanicNavyDark : AppColors.stone50,
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
                    safeTop: mediaQuery.padding.top,
                    textScale: mediaQuery.textScaler.scale(1.0),
                    searchController: _searchController,
                    focusNode: _searchFocusNode,
                    hasActiveFilters: _hasActiveFilters,
                    searchQuery: _searchController.text,
                    onSearchChanged: _onSearchChanged,
                    onSubmitted: (_) => _performSearch(),
                    onClear: _clearSearch,
                    onFilterTap: _handleFilterTap,
                    onAvatarTap: () =>
                        ref.read(selectedTabProvider.notifier).state = 4,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRefreshPill(),
                ),
                if (_hasActiveFilters)
                  SliverToBoxAdapter(
                    child: _buildActiveFilterChips(l10n),
                  ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryPills(l10n),
                      if (_selectedCategory == HomeCategory.jobs)
                        _buildJobsSectionPills()
                      else if (_selectedCategory == HomeCategory.orders)
                        _buildOrdersSectionPills()
                      else if (_selectedCategory == HomeCategory.all)
                        _buildAllSectionPills()
                      else
                        _buildListingTypeSectionPills(),
                    ],
                  ),
                ),
                if (_hasSearched && _selectedCategory == HomeCategory.orders)
                  ..._buildOrderBrowseSlivers(ordersState, l10n,
                      isSearch: true)
                else if (_hasSearched)
                  isSeekerSearch
                      ? _buildSeekerSearchResults(seekerState, l10n)
                      : _buildSearchResults(searchState, l10n)
                else if (canBrowseAll)
                  ..._buildAllBrowseSlivers(featuredState, vipState,
                      listingsState, carState, jobState, seekerState, l10n)
                else if (_selectedCategory == HomeCategory.vehicles)
                  ..._buildCarBrowseSlivers(
                      featuredState, vipState, carState, l10n)
                else if (_selectedCategory == HomeCategory.jobs &&
                    _jobsSection == JobsSection.seekers)
                  ..._buildJobSeekerBrowseSlivers(seekerState, l10n)
                else if (_selectedCategory == HomeCategory.jobs)
                  ..._buildJobBrowseSlivers(
                      featuredState, vipState, jobState, l10n)
                else if (_selectedCategory == HomeCategory.orders)
                  ..._buildOrderBrowseSlivers(ordersState, l10n)
                else ...[
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_filterPropertyFeatured(featuredState)
                              .listings
                              .isNotEmpty) ...[
                            _buildSectionHeader(l10n.listingsFeatured),
                            _buildFeaturedListings(
                                _filterPropertyFeatured(featuredState)),
                          ],
                          if (_filterPropertyFeatured(vipState)
                              .listings
                              .isNotEmpty)
                            _buildVipSection(
                                _filterPropertyFeatured(vipState)),
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
            if (_selectedCategory == HomeCategory.property ||
                _selectedCategory == HomeCategory.all) ...[
              if (v.propertyType != null)
                _filterChip(
                  v.propertyType == 'house'
                      ? l10n.listingHouse
                      : l10n.listingLand,
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('type');
                      })),
                ),
              if (v.isFeatured)
                _filterChip(
                  l10n.listingsFeatured,
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('is_featured');
                      })),
                ),
              if (v.areaMin != null || v.areaMax != null)
                _filterChip(
                  '${l10n.searchArea}: ${v.areaMin ?? ''}-${v.areaMax ?? ''}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('area_min');
                      })),
                ),
              if (v.bedrooms != null)
                _filterChip(
                  '${l10n.listingBedrooms}: ${v.bedrooms}+',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('bedrooms');
                      })),
                ),
              if (v.bathrooms != null)
                _filterChip(
                  '${l10n.listingBathrooms}: ${v.bathrooms}+',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('bathrooms');
                      })),
                ),
              if (v.listingType == 'rental' && v.rentalPeriod != null)
                _filterChip(
                  v.rentalPeriod == 'day'
                      ? l10n.rentalPeriodDay
                      : v.rentalPeriod == 'month'
                          ? l10n.rentalPeriodMonth
                          : l10n.rentalPeriodYear,
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('rental_period_unit');
                      })),
                ),
            ],
            if (_selectedCategory == HomeCategory.property ||
                _selectedCategory == HomeCategory.vehicles ||
                _selectedCategory == HomeCategory.all) ...[
              if (v.listingType != null && _hasSearched)
                _filterChip(
                  v.listingType == 'sale'
                      ? l10n.listingForSale
                      : l10n.listingForRent,
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('listing_type');
                      })),
                ),
            ],
            if (_selectedCategory == HomeCategory.vehicles ||
                _selectedCategory == HomeCategory.all) ...[
              if (v.make != null)
                _filterChip(
                  '${l10n.listingMake}: ${makeLabel(v.make!, l10n)}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('make');
                      })),
                ),
              if (v.model != null)
                _filterChip(
                  '${l10n.listingModel}: ${modelLabel(v.model!, l10n)}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('model');
                      })),
                ),
              if (v.yearMin != null || v.yearMax != null)
                _filterChip(
                  '${l10n.listingYear}: ${v.yearMin ?? ''}-${v.yearMax ?? ''}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('year_min');
                      })),
                ),
              if (v.vehicleCategory != null)
                _filterChip(
                  vehicleCategoryLabel(v.vehicleCategory!, l10n),
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('vehicle_category');
                      })),
                ),
              if (v.bodyType != null)
                _filterChip(
                  bodyTypeLabel(v.bodyType!, l10n),
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('body_type');
                      })),
                ),
              if (v.condition != null)
                _filterChip(
                  '${l10n.listingCondition}: ${conditionLabel(v.condition!, l10n)}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('condition');
                      })),
                ),
              if (v.mileageMax != null)
                _filterChip(
                  '${l10n.listingMileageMax}: ${v.mileageMax}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('mileage_max');
                      })),
                ),
            ],
            if (_selectedCategory == HomeCategory.jobs) ...[
              if (v.jobCategory != null)
                _filterChip(
                  jobCategoryLabel(v.jobCategory!, l10n),
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('job_category');
                      })),
                ),
              if (!v.forSeekers && v.jobType != null)
                _filterChip(
                  jobTypeLabel(v.jobType!, l10n),
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('job_type');
                      })),
                ),
              if (v.educationLevel != null)
                _filterChip(
                  educationLevelLabel(v.educationLevel!, l10n),
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('education_level');
                      })),
                ),
              if (!v.forSeekers && v.jobSalaryMin != null)
                _filterChip(
                  '${l10n.searchSalaryMin}: ETB ${v.jobSalaryMin}',
                  () => _removeFilterAndCheck(() => setState(() {
                        _filterValues = v.clearField('salary_min');
                      })),
                ),
            ],
            if (_selectedCategory == HomeCategory.orders &&
                (v.priceMin != null || v.priceMax != null))
              _filterChip(
                orderBudgetLabel(
                  OrderRange(
                    min: v.priceMin?.toDouble(),
                    max: v.priceMax?.toDouble(),
                  ),
                  l10n,
                ),
                () => _removeFilterAndCheck(() => setState(() {
                      _filterValues = v.clearField('price_min');
                    })),
              )
            else if (v.priceMin != null || v.priceMax != null)
              _filterChip(
                v.priceMin != null && v.priceMax != null
                    ? 'ETB ${v.priceMin} - ETB ${v.priceMax}'
                    : v.priceMin != null
                        ? 'ETB ${v.priceMin}+'
                        : 'Up to ETB ${v.priceMax}',
                () => _removeFilterAndCheck(() => setState(() {
                      _filterValues = v.clearField('price_min');
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
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

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.searchResultsCount(state.total),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            final listingIndex = index - 1;
            if (listingIndex >= state.listings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = state.listings[listingIndex];
            final fav = _isFavorite(listing.id);
            final Widget card;
            switch (listing.propertyType) {
              case PropertyType.car:
                card = VehicleListingCard(
                  listing: listing,
                  isFavorite: fav,
                  isTogglingFavorite: _isToggling(listing.id),
                  onFavorite: () => _toggleFavorite(listing.id),
                  onTap: () => context.push('/cars/${listing.id}'),
                );
              case PropertyType.job:
                card = JobListingCard(
                  job: listing,
                  isFavorite: fav,
                  isTogglingFavorite: _isToggling(listing.id),
                  onFavorite: () => _toggleFavorite(listing.id),
                  onTap: () => context.push('/jobs/${listing.id}'),
                );
              case PropertyType.house:
              case PropertyType.land:
                card = PropertyListingCard(
                  listing: listing,
                  isFavorite: fav,
                  isTogglingFavorite: _isToggling(listing.id),
                  onFavorite: () => _toggleFavorite(listing.id),
                  onTap: () => _handleListingTap(listing),
                );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: card,
            );
          },
          childCount: 1 + state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  Widget _buildSeekerSearchResults(
    JobSeekerProfilesState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.profiles.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: JobSeekerCardSkeleton(),
            ),
            childCount: 4,
          ),
        ),
      );
    }

    if (state.errorMessage != null && state.profiles.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: TextButton.icon(
            onPressed: () => ref
                .read(homeJobSeekerProfilesProvider.notifier)
                .loadProfiles(filters: _buildSearchFilters()),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.commonRetryMessage),
          ),
        ),
      );
    }

    if (state.profiles.isEmpty) {
      return SliverFillRemaining(
        child: WaveEmptyState(
          icon: Icons.person_search_outlined,
          title: l10n.seekersNoResults,
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
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  l10n.searchResultsCount(state.total),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: context.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            final profileIndex = index - 1;
            if (profileIndex >= state.profiles.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobSeekerCard(profile: state.profiles[profileIndex]),
            );
          },
          childCount: 1 + state.profiles.length + (state.isLoadingMore ? 1 : 0),
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

  Widget _buildFeaturedListings(ListingsState featuredState) {
    if (featuredState.errorMessage != null && featuredState.listings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildPullToRefreshHint(),
      );
    }
    if (featuredState.isLoading && featuredState.listings.isEmpty) {
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
    if (featuredState.listings.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featuredState.listings.length,
        itemBuilder: (context, index) {
          final listing = featuredState.listings[index];
          final fav = _isFavorite(listing.id);
          final isCar = listing.propertyType == PropertyType.car;
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: isCar
                  ? VehicleFeaturedCard(
                      listing: listing,
                      isFavorite: fav,
                      isTogglingFavorite: _isToggling(listing.id),
                      onFavorite: () => _toggleFavorite(listing.id),
                      onTap: () => _handleListingTap(listing),
                    )
                  : FeaturedListingCard(
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

  Widget _buildVipSection(ListingsState vipState) {
    final l10n = AppLocalizations.of(context);
    final subState = ref.watch(subscriptionProvider);
    final canViewVip = subState.canViewVip;

    if (canViewVip) {
      if (vipState.listings.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.vipBadge, eyebrow: 'Premium'),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: vipState.listings.length,
              itemBuilder: (context, index) {
                final listing = vipState.listings[index];
                final fav = _isFavorite(listing.id);
                final isCar = listing.propertyType == PropertyType.car;
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 280,
                    child: isCar
                        ? VehicleFeaturedCard(
                            listing: listing,
                            isFavorite: fav,
                            isTogglingFavorite: _isToggling(listing.id),
                            onFavorite: () => _toggleFavorite(listing.id),
                            onTap: () => _handleListingTap(listing),
                          )
                        : FeaturedListingCard(
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
        ],
      );
    }

    if (subState.isLoading || subState.errorMessage != null) {
      return const SizedBox.shrink();
    }
    return _buildVipTeaser();
  }

  Widget _buildMergedFeed(
    ListingsState propState,
    ListingsState carState,
    ListingsState jobState,
    JobSeekerProfilesState seekerState,
  ) {
    final showJobsAndSeekers = _allSection == AllSection.all;
    final isAll = _allSection == AllSection.all;
    final isRent = _allSection == AllSection.rent;

    // Filter property and car listings by the active sub-tab listing type.
    final filteredPropListings = isAll
        ? propState.listings
        : propState.listings
            .where((l) =>
                l.listingType ==
                (isRent ? ListingType.rental : ListingType.sale))
            .toList();
    final filteredCarListings = isAll
        ? carState.listings
        : carState.listings
            .where((l) =>
                l.listingType ==
                (isRent ? ListingType.rental : ListingType.sale))
            .toList();

    final hasAnyListings = filteredPropListings.isNotEmpty ||
        filteredCarListings.isNotEmpty ||
        (showJobsAndSeekers &&
            (jobState.listings.isNotEmpty || seekerState.profiles.isNotEmpty));

    final isAnyLoading = propState.isLoading ||
        carState.isLoading ||
        (showJobsAndSeekers && (jobState.isLoading || seekerState.isLoading));

    if (!hasAnyListings) {
      if (isAnyLoading) {
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
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 56, color: context.textMuted),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context).listingsNoResults,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final allItems = <_AllFeedItem>[
      ...filteredPropListings.map(_ListingFeedItem.new),
      ...filteredCarListings.map(_ListingFeedItem.new),
      if (showJobsAndSeekers) ...[
        ...jobState.listings.map(_ListingFeedItem.new),
        ...seekerState.profiles.map(_SeekerFeedItem.new),
      ],
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= allItems.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final item = allItems[index];
            if (item is _SeekerFeedItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobSeekerCard(
                  profile: item.profile,
                  onTap: () => context.push('/job-seekers/${item.profile.id}'),
                ),
              );
            }
            final listing = (item as _ListingFeedItem).listing;
            final fav = _isFavorite(listing.id);
            final isVehicle = listing.propertyType == PropertyType.car;
            final isJob = listing.propertyType == PropertyType.job;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: isJob
                  ? JobListingCard(
                      job: listing,
                      isFavorite: fav,
                      isTogglingFavorite: _isToggling(listing.id),
                      onFavorite: () => _toggleFavorite(listing.id),
                      onTap: () => context.push('/jobs/${listing.id}'),
                    )
                  : isVehicle
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
          childCount: allItems.length +
              (propState.isLoadingMore ||
                      carState.isLoadingMore ||
                      (showJobsAndSeekers &&
                          (jobState.isLoadingMore ||
                              seekerState.isLoadingMore))
                  ? 1
                  : 0),
        ),
      ),
    );
  }

  List<Widget> _buildAllBrowseSlivers(
    ListingsState featuredState,
    ListingsState vipState,
    ListingsState propState,
    ListingsState carState,
    ListingsState jobState,
    JobSeekerProfilesState seekerState,
    AppLocalizations l10n,
  ) {
    final isRent = _allSection == AllSection.rent;
    final isAll = _allSection == AllSection.all;

    final filteredFeatured = isAll
        ? featuredState
        : featuredState.copyWith(
            listings: featuredState.listings
                .where((l) =>
                    l.listingType ==
                    (isRent ? ListingType.rental : ListingType.sale))
                .toList(),
          );

    final filteredVip = isAll
        ? vipState
        : vipState.copyWith(
            listings: vipState.listings
                .where((l) =>
                    l.listingType ==
                    (isRent ? ListingType.rental : ListingType.sale))
                .toList(),
          );

    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (filteredFeatured.listings.isNotEmpty) ...[
              _buildSectionHeader(l10n.listingsFeatured),
              _buildFeaturedListings(filteredFeatured),
            ],
            if (filteredVip.listings.isNotEmpty)
              _buildVipSection(filteredVip),
            _buildSectionHeader(l10n.listingsTitle,
                eyebrow: l10n.homeLatestRecently.toUpperCase()),
          ],
        ),
      ),
      _buildMergedFeed(propState, carState, jobState, seekerState),
    ];
  }

  List<Widget> _buildCarBrowseSlivers(
    ListingsState featuredState,
    ListingsState vipState,
    ListingsState carState,
    AppLocalizations l10n,
  ) {
    final carFeatured = _filterCarListings(featuredState);
    final carVip = _filterCarListings(vipState);
    return [
      SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (carFeatured.listings.isNotEmpty)
                _buildSectionHeader(l10n.listingsFeatured),
              if (carFeatured.listings.isNotEmpty)
                _buildFeaturedListings(carFeatured),
              if (carVip.listings.isNotEmpty) _buildVipSection(carVip),
              _buildSectionHeader(l10n.listingCarPlural,
                  eyebrow: l10n.homeLatestRecently.toUpperCase()),
            ],
          ),
        ),
      ),
      _buildCarLatestSliver(carState, l10n),
    ];
  }

  ListingsState _filterCarListings(ListingsState state) {
    final isRental = _listingTypeSection == ListingTypeSection.rent;
    final carListings = state.listings
        .where((l) =>
            l.propertyType == PropertyType.car &&
            l.listingType == (isRental ? ListingType.rental : ListingType.sale))
        .toList();
    return state.copyWith(listings: carListings);
  }

  ListingsState _filterPropertyFeatured(ListingsState state) {
    final isRental = _listingTypeSection == ListingTypeSection.rent;
    final propListings = state.listings
        .where((l) =>
            l.propertyType != PropertyType.car &&
            l.propertyType != PropertyType.job &&
            l.listingType == (isRental ? ListingType.rental : ListingType.sale))
        .toList();
    return state.copyWith(listings: propListings);
  }

  List<Widget> _buildJobSeekerBrowseSlivers(
      JobSeekerProfilesState state, AppLocalizations l10n) {
    if (state.isLoading && state.profiles.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: JobSeekerCardSkeleton(),
              ),
              childCount: 5,
            ),
          ),
        )
      ];
    }
    if (state.profiles.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search_outlined,
                      size: 64, color: context.textMuted),
                  const SizedBox(height: 16),
                  Text(l10n.seekersNoProfiles,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: context.textMuted)),
                ],
              ),
            ),
          ),
        )
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == state.profiles.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final profile = state.profiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobSeekerCard(profile: profile),
              );
            },
            childCount: state.profiles.length + (state.isLoadingMore ? 1 : 0),
          ),
        ),
      )
    ];
  }

  List<Widget> _buildJobBrowseSlivers(
    ListingsState featuredState,
    ListingsState vipState,
    ListingsState jobState,
    AppLocalizations l10n,
  ) {
    final jobFeatured = _filterJobListings(featuredState);
    final jobVip = _filterJobListings(vipState);
    return [
      SliverToBoxAdapter(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (jobFeatured.listings.isNotEmpty)
                _buildSectionHeader(l10n.listingsFeatured),
              if (jobFeatured.listings.isNotEmpty)
                _buildFeaturedListings(jobFeatured),
              if (jobVip.listings.isNotEmpty) _buildVipSection(jobVip),
              _buildSectionHeader(l10n.homeJobs,
                  eyebrow: l10n.homeLatestRecently.toUpperCase()),
            ],
          ),
        ),
      ),
      _buildJobLatestSliver(jobState, l10n),
    ];
  }

  ListingsState _filterJobListings(ListingsState state) {
    final jobListings = state.listings
        .where((l) => l.propertyType == PropertyType.job)
        .toList();
    return state.copyWith(listings: jobListings);
  }

  Widget _buildJobLatestSliver(ListingsState state, AppLocalizations l10n) {
    if (state.isLoading && state.listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            for (int i = 0; i < 3; i++)
              const PropertyListingCard(isLoading: true), // Fallback
          ]),
        ),
      );
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TextButton.icon(
                  onPressed: () =>
                      ref.read(homeJobListingsProvider.notifier).loadListings(),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.work_outline, size: 64, color: context.textMuted),
                const SizedBox(height: 16),
                Text(l10n.messageEmptySubtitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: context.textMuted)),
              ],
            ),
          ),
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: JobListingCard(
                job: listing,
                isFavorite: _isFavorite(listing.id),
                isTogglingFavorite: _isToggling(listing.id),
                onFavorite: () => _toggleFavorite(listing.id),
                onTap: () => context.push('/jobs/${listing.id}'),
              ),
            );
          },
          childCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        ),
      ),
    );
  }

  List<Widget> _buildOrderBrowseSlivers(
      OrdersV2State state, AppLocalizations l10n,
      {bool isSearch = false}) {
    if (state.isLoading && state.orders.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              for (int i = 0; i < 4; i++)
                const PropertyListingCard(isLoading: true),
            ]),
          ),
        ),
      ];
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded,
                      size: 64, color: context.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    l10n.ordersBrowseError,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  WaveButton(
                    text: l10n.commonTryAgain,
                    icon: Icons.refresh_rounded,
                    onPressed: () => _loadOrdersFeed(search: isSearch),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    if (state.orders.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: isSearch
                  ? WaveEmptyState(
                      icon: Icons.search_off_rounded,
                      title: l10n.searchNoResultsTitle,
                      subtitle: l10n.searchNoResultsSubtitle,
                      actionLabel: l10n.searchClearAll,
                      onAction: _clearAllFilters,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: context.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          l10n.ordersBrowseEmpty,
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: context.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= state.orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final order = state.orders[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PublicOrderCard(
                  order: order,
                  onTap: () => _handleOrderTap(order, l10n),
                ),
              );
            },
            childCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
          ),
        ),
      ),
    ];
  }

  void _handleOrderTap(BuyerOrder order, AppLocalizations l10n) {
    final canViewVip =
        order.canViewVip || ref.read(subscriptionProvider).canViewVip;
    if (!canViewVip) {
      showModalBottomSheet(
        context: context,
        backgroundColor: context.sheetBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: UpgradeCard(
              icon: Icons.lock_rounded,
              iconColor: AppColors.accent500,
              title: l10n.ordersVipRequiredTitle,
              subtitle: l10n.ordersVipRequiredSubtitle,
              buttonLabel: l10n.ordersViewVipPlans,
              onButtonTap: () {
                Navigator.pop(ctx);
                context.push('/subscriptions');
              },
            ),
          ),
        ),
      );
      return;
    }

    context.push('/public-orders/${order.id}');
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
            borderRadius: BorderRadius.circular(12),
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
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestListings(ListingsState state) {
    final isRental = _listingTypeSection == ListingTypeSection.rent;
    final propListings = state.listings
        .where((l) =>
            l.propertyType != PropertyType.car &&
            l.propertyType != PropertyType.job &&
            l.listingType == (isRental ? ListingType.rental : ListingType.sale))
        .toList();

    if (state.errorMessage != null && propListings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildPullToRefreshHint(),
          ),
        ),
      );
    }
    if (state.isLoading && propListings.isEmpty) {
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
    if (propListings.isEmpty) {
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
            if (index == propListings.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final listing = propListings[index];
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
          childCount: propListings.length + (state.isLoadingMore ? 1 : 0),
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
  final double safeTop;
  final double textScale;
  final TextEditingController searchController;
  final FocusNode focusNode;
  final bool hasActiveFilters;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;
  final VoidCallback? onAvatarTap;

  _SearchBarDelegate({
    this.user,
    required this.safeTop,
    required this.textScale,
    required this.searchController,
    required this.focusNode,
    required this.hasActiveFilters,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onFilterTap,
    this.onAvatarTap,
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
    final firstName = user?.firstName?.toString().trim() ?? '';
    final greeting = user != null && firstName.isNotEmpty
        ? '${_getGreeting(l10n)}, $firstName'
        : l10n.authWelcomeBack;

    // Calculate dynamic values based on scroll
    // 0.0 at max extent, 1.0 at min extent
    final progress = shrinkOffset / (maxExtent - minExtent);
    final clampedProgress = progress.clamp(0.0, 1.0);

    // Greeting row opacity: fades out early
    final greetingOpacity = (1.0 - clampedProgress * 2).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.oceanicNavyDark : AppColors.stone50)
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
            // Brand & Personalized Greeting Row (Fades out on scroll)
            if (greetingOpacity > 0)
              Opacity(
                opacity: greetingOpacity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Wave',
                                          style: AppTextStyles.title.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.primary900,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Mart',
                                          style: AppTextStyles.title.copyWith(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.accent500,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent500
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.accent500
                                          .withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    'ET',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.accent500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              greeting,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.stone400
                                    : AppColors.stone600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildUserAvatar(context),
                    ],
                  ),
                ),
              ),

            // Sleek Modern Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                6 + (2 * (1.0 - clampedProgress)),
                16,
                10,
              ),
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
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.3)
                          : AppColors.primary900.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                        controller: searchController,
                        focusNode: focusNode,
                        onChanged: onSearchChanged,
                        onSubmitted: onSubmitted,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.stone900,
                          fontWeight: FontWeight.w500,
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
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
                    _buildFilterButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    final initials = user?.initials.isNotEmpty == true ? user!.initials : '?';
    final avatarUrl = user?.googleAvatar as String?;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.navSettings,
      child: Tooltip(
        message: l10n.navSettings,
        child: GestureDetector(
          onTap: onAvatarTap,
          child: Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: ResizeImage(
                            CachedNetworkImageProvider(avatarUrl),
                            width: 84,
                            height: 84,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient:
                      avatarUrl != null ? null : AppColors.gradientNavyEmerald,
                  boxShadow: AppColors.shadowSm,
                  border: Border.all(
                    color: AppColors.accent500,
                    width: 2.0,
                  ),
                ),
                child: avatarUrl != null
                    ? null
                    : Center(
                        child: Text(
                          initials,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.accent500,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.oceanicNavyDark : Colors.white,
                      width: 1.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.searchFilters,
      child: Tooltip(
        message: l10n.searchFilters,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onFilterTap,
          child: Container(
            height: 48,
            constraints: const BoxConstraints(minWidth: 48),
            margin: const EdgeInsets.only(left: 4, right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? AppColors.accent500
                  : (isDark ? AppColors.cardNavyLight : AppColors.stone100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 19,
                    color: hasActiveFilters
                        ? Colors.white
                        : (isDark ? AppColors.accent400 : AppColors.primary900),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _effectiveTextScale => textScale.clamp(1.0, 3.0).toDouble();

  @override
  double get maxExtent => safeTop + 136 + ((_effectiveTextScale - 1.0) * 50.0);

  @override
  double get minExtent => safeTop + 66;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) {
    return oldDelegate.hasActiveFilters != hasActiveFilters ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.user != user ||
        oldDelegate.safeTop != safeTop ||
        oldDelegate.textScale != textScale;
  }
}
