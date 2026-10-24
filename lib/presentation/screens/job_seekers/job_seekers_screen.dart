import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/job_data.dart';
import '../../../l10n/app_localizations.dart';
import '../home/home_screen.dart';
import '../home/filter_sheet.dart';
import 'widgets/job_seeker_card.dart';
import '../../providers/job_seeker_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';

class JobSeekersScreen extends ConsumerStatefulWidget {
  const JobSeekersScreen({super.key});

  @override
  ConsumerState<JobSeekersScreen> createState() => _JobSeekersScreenState();
}

class _JobSeekersScreenState extends ConsumerState<JobSeekersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  UnifiedFilterValues _filterValues =
      const UnifiedFilterValues(category: HomeCategory.jobs, forSeekers: true);
  Map<String, dynamic> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobSeekerProfilesProvider.notifier).loadProfiles();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = ref.read(jobSeekerProfilesProvider);
      if (state.hasMore && !state.isLoadingMore) {
        ref.read(jobSeekerProfilesProvider.notifier).loadProfiles(
              page: state.currentPage + 1,
              filters: _activeFilters.isNotEmpty ? _activeFilters : null,
            );
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _performSearch);
  }

  void _performSearch() {
    final searchText = _searchController.text.trim();
    final filters = <String, dynamic>{..._filterValues.toQueryParams()};
    if (searchText.isNotEmpty) {
      filters['search'] = searchText;
    }
    _activeFilters = filters;
    ref.read(jobSeekerProfilesProvider.notifier).loadProfiles(
          filters: filters.isNotEmpty ? filters : null,
        );
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<UnifiedFilterValues>(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) => FilterSheet(
        initialValues: _filterValues,
        showCategoryToggle: false,
      ),
    );
    if (result == null) return;
    if (result == _filterValues) return;
    setState(() => _filterValues = result);
    _performSearch();
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
      _filterValues = const UnifiedFilterValues(
        category: HomeCategory.jobs,
        forSeekers: true,
      );
      _activeFilters = {};
    });
    ref.read(jobSeekerProfilesProvider.notifier).loadProfiles();
  }

  bool get _hasActiveFilters =>
      _filterValues.hasAnyFilter || _searchController.text.isNotEmpty;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(jobSeekerProfilesProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.seekersTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _filterValues.hasAnyFilter ? AppColors.accent500 : null,
            ),
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
                : state.errorMessage != null && state.profiles.isEmpty
                    ? WaveMessageScreen.error(
                        isEmbedded: true,
                        subtitle: state.errorMessage!,
                        onRetry: () => ref
                            .read(jobSeekerProfilesProvider.notifier)
                            .loadProfiles(
                              filters: _activeFilters.isNotEmpty
                                  ? _activeFilters
                                  : null,
                            ),
                      )
                    : state.profiles.isEmpty
                        ? WaveEmptyState(
                            icon: Icons.person_search_outlined,
                            title: l10n.seekersNoResults,
                            subtitle: l10n.searchNoResultsSubtitle,
                            actionLabel:
                                _hasActiveFilters ? l10n.searchClearAll : null,
                            onAction:
                                _hasActiveFilters ? _clearAllFilters : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(jobSeekerProfilesProvider.notifier)
                                  .loadProfiles(
                                    filters: _activeFilters.isNotEmpty
                                        ? _activeFilters
                                        : null,
                                  );
                            },
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                              itemCount: 1 +
                                  state.profiles.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
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
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final profile = state.profiles[profileIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: JobSeekerCard(
                                    profile: profile,
                                    onTap: () => context
                                        .push('/job-seekers/${profile.id}'),
                                  ),
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
          hintText: l10n.searchSeekersPlaceholder,
          hintStyle: AppTextStyles.bodySmall
              .copyWith(color: context.textSecondary.withValues(alpha: 0.5)),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: context.textSecondary.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 18,
                    color: context.textSecondary.withValues(alpha: 0.5),
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: context.theme.inputBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.theme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.theme.border),
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
            if (_filterValues.jobCategory != null)
              _filterChip(
                jobCategoryLabel(_filterValues.jobCategory!, l10n),
                () => _removeFilter('job_category'),
              ),
            if (_filterValues.educationLevel != null)
              _filterChip(
                educationLevelLabel(_filterValues.educationLevel!, l10n),
                () => _removeFilter('education_level'),
              ),
            if (_searchController.text.isNotEmpty)
              _filterChip(_searchController.text, _clearSearch),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _clearAllFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: context.textSecondary.withValues(alpha: 0.5),
                ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent500.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent500,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.accent500.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
