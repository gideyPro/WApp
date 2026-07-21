import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../../providers/car_providers.dart';
import '../../providers/listing_providers.dart';
import '../../widgets/vehicle_listing_card.dart';
import '../home/filter_sheet.dart';
import 'car_strings.dart';

class CarListScreen extends ConsumerStatefulWidget {
  const CarListScreen({super.key});

  @override
  ConsumerState<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends ConsumerState<CarListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  UnifiedFilterValues _filterValues = const UnifiedFilterValues(category: HomeCategory.vehicles);
  Map<String, dynamic> _activeFilters = {};
  final Set<int> _togglingFavorites = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(carListingsProvider.notifier).loadListings();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = ref.read(carListingsProvider);
      if (state.hasMore && !state.isLoadingMore) {
        final page = state.currentPage + 1;
        ref.read(carListingsProvider.notifier).loadListings(
          page: page,
          filters: _activeFilters.isNotEmpty ? _activeFilters : null,
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void _performSearch() {
    final searchText = _searchController.text.trim();
    final filters = <String, dynamic>{..._filterValues.toQueryParams()};
    if (searchText.isNotEmpty) {
      filters['location'] = searchText;
    }
    _activeFilters = filters;
    ref.read(carListingsProvider.notifier).loadListings(
      filters: filters.isNotEmpty ? filters : null,
    );
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<UnifiedFilterValues>(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialValues: _filterValues,
        showCategoryToggle: false,
      ),
    );
    if (result != null) {
      setState(() => _filterValues = result);
      _performSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch();
  }

  void _removeFilter(String key) {
    setState(() => _filterValues = _filterValues.clearField(key));
    _performSearch();
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filterValues = const UnifiedFilterValues(category: HomeCategory.vehicles);
      _activeFilters = {};
    });
    ref.read(carListingsProvider.notifier).loadListings();
  }

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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _hasActiveFilters => _filterValues.hasAnyFilter || _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(carListingsProvider);
    ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(
        title: Text(l10n.listingCarPlural),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: _filterValues.hasAnyFilter ? AppColors.accent500 : null),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          if (_hasActiveFilters) _buildActiveFilterChips(l10n),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null && state.listings.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(state.errorMessage!, style: const TextStyle(color: AppColors.stone500)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => ref.read(carListingsProvider.notifier).loadListings(),
                              child: Text(l10n.commonRetry),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(carListingsProvider.notifier).loadListings(
                            filters: _activeFilters.isNotEmpty ? _activeFilters : null,
                          );
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.listings.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            final listing = state.listings[index];
return VehicleListingCard(
              listing: listing,
              isFavorite: _isFavorite(listing.id),
              onFavorite: () => _toggleFavorite(listing.id),
              isTogglingFavorite: _isToggling(listing.id),
              onTap: () => context.push('/cars/${listing.id}'),
            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      color: context.cardBg,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: CarStrings.searchCars,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: context.textSecondary.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, size: 20, color: context.textSecondary.withValues(alpha: 0.5)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18, color: context.textSecondary.withValues(alpha: 0.5)),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: context.scaffoldBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: AppTextStyles.bodySmall,
      ),
    );
  }

  Widget _buildActiveFilterChips(AppLocalizations l10n) {
    return Container(
      color: context.cardBg,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_filterValues.make != null)
              _filterChip('${l10n.listingMake}: ${_filterValues.make}', () => _removeFilter('make')),
            if (_filterValues.model != null)
              _filterChip('${l10n.listingModel}: ${_filterValues.model}', () => _removeFilter('model')),
            if (_filterValues.yearMin != null)
              _filterChip('${l10n.listingYear}: ${_filterValues.yearMin}-${_filterValues.yearMax ?? ''}', () => _removeFilter('year_min')),
            if (_filterValues.transmission != null)
              _filterChip(_filterValues.transmission!, () => _removeFilter('transmission')),
            if (_filterValues.fuelType != null)
              _filterChip(_filterValues.fuelType!, () => _removeFilter('fuel_type')),
            if (_filterValues.bodyType != null)
              _filterChip(_filterValues.bodyType!, () => _removeFilter('body_type')),
            if (_filterValues.mileageMax != null)
              _filterChip('${l10n.listingMileageMax}: ${_filterValues.mileageMax}', () => _removeFilter('mileage_max')),
            if (_filterValues.priceMin != null || _filterValues.priceMax != null)
              _filterChip(
                '${_filterValues.priceMin != null ? 'ETB ${_filterValues.priceMin}' : ''} - ${_filterValues.priceMax != null ? 'ETB ${_filterValues.priceMax}' : ''}',
                () => _removeFilter('price_min'),
              ),
            if (_searchController.text.isNotEmpty)
              _filterChip(_searchController.text, _clearSearch),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(Icons.close, size: 16, color: context.textSecondary.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent500.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent500, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: AppColors.accent500.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
