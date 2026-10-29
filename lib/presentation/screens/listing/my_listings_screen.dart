import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../data/models/v2/owner_listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/v2/v2_listing_card.dart';

/// My Listings screen wired to V2 `/v2/me/listings`.
///
/// Shows owner-facing listings with moderation state (draft, pending, active,
/// rejected, frozen) and owner affordances (edit, submit, delete, feature).
class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  static final _tabs = <_MyListingsTab>[
    _MyListingsTab('All', OwnerListingStatusFilter.all()),
    _MyListingsTab('Active', OwnerListingStatusFilter.active()),
    _MyListingsTab('Pending', OwnerListingStatusFilter.pending()),
    _MyListingsTab('Frozen', OwnerListingStatusFilter.frozen()),
    _MyListingsTab('Rejected', OwnerListingStatusFilter.rejected()),
    _MyListingsTab('Draft', OwnerListingStatusFilter.draft()),
  ];

  int? _editingListingId;
  bool _isEditing(int listingId) => _editingListingId == listingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadCurrentTab();
    }
  }

  void _onScroll() {
    final filter = _tabs[_tabController.index].filter;
    final state = ref.read(myListingsV2Provider(filter));
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      ref.read(myListingsV2Provider(filter).notifier).loadMore();
    }
  }

  StateNotifierProvider<MyListingsV2Notifier, MyListingsV2State>
      _currentProvider() {
    return myListingsV2Provider(_tabs[_tabController.index].filter);
  }

  void _loadCurrentTab() {
    ref.read(_currentProvider().notifier).loadMyListings();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.profileMyListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              final result = await context.push<bool>('/listings/create');
              if (result == true && mounted) {
                _loadCurrentTab();
              }
            },
            tooltip: l10n.listingsCreate,
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.accent800,
            unselectedLabelColor: context.textSecondary,
            indicatorColor: AppColors.accent800,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.titleSmall.copyWith(fontSize: 14),
            unselectedLabelStyle: AppTextStyles.subtitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                return _buildTabBody(i, l10n);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(int tabIndex, AppLocalizations l10n) {
    final filter = _tabs[tabIndex].filter;
    final notifier = ref.read(myListingsV2Provider(filter).notifier);
    final state = ref.read(myListingsV2Provider(filter));

    if (state.isLoading && state.listings.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => const V2ListingCardSkeleton(),
      );
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return WaveMessageScreen.error(
        title: l10n.errorLoadingListings,
        subtitle: state.errorMessage!,
        onRetry: () => notifier.loadMyListings(),
        isEmbedded: true,
      );
    }

    if (state.listings.isEmpty) {
      final isAllTab = tabIndex == 0;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.theme.isDark
                      ? AppColors.cardNavyDark
                      : AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: context.theme.isDark
                      ? AppColors.accent400
                      : AppColors.primary400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAllTab
                    ? l10n.listingsNoResults
                    : _tabLabelForStatus(l10n, filter.status),
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              if (isAllTab) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.myListingsEmptySubtitle,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: context.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 220,
                  child: WaveButton(
                    text: l10n.listingsCreate,
                    icon: Icons.add,
                    variant: ButtonVariant.success,
                    isFullWidth: true,
                    onPressed: () async {
                      final result =
                          await context.push<bool>('/listings/create');
                      if (result == true && mounted) {
                        notifier.loadMyListings();
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadMyListings(),
      child: ListView.builder(
        controller: tabIndex == _tabController.index ? _scrollController : null,
        padding: const EdgeInsets.all(16),
        itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.listings.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final listing = state.listings[index];
          final isEditing = _isEditing(listing.id);
          final ownerActions = <Widget>[
            if (isEditing)
              const Padding(
                padding: EdgeInsets.all(6),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            else
              _buildOwnerActionIcon(
                icon: Icons.edit_outlined,
                tooltip: l10n.commonEdit,
                onTap: () => _editListing(listing),
              ),
            const SizedBox(width: 4),
            _buildOwnerActionIcon(
              icon: Icons.delete_outline,
              tooltip: l10n.commonDelete,
              color: AppColors.error,
              onTap: isEditing ? null : () => _confirmDelete(listing, l10n),
            ),
            if (listing.canSubmit)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _buildOwnerActionIcon(
                  icon: Icons.publish_outlined,
                  tooltip: 'Submit',
                  color: AppColors.accent500,
                  onTap: isEditing ? null : () => _confirmSubmit(listing, l10n),
                ),
              ),
            if (listing.isFeatured == false)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: _buildOwnerActionIcon(
                  icon: Icons.workspace_premium_outlined,
                  tooltip: 'Feature',
                  color: AppColors.accent500,
                  onTap:
                      isEditing ? null : () => _featureListing(listing, l10n),
                ),
              ),
          ];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: V2ListingCard(
              listing: ListingSummary(
                id: listing.id,
                kind: listing.kind,
                listingType: listing.listingType,
                title: listing.title,
                price: listing.price,
                location: listing.location,
                coverImage: listing.coverImage,
                isVip: listing.isVip,
                isFavorite: false,
              ),
              isFavorite: false,
              isTogglingFavorite: false,
              hideFavoriteButton: true,
              onTap: () => _handleListingTap(listing),
              imageOverlayActions: ownerActions,
            ),
          );
        },
      ),
    );
  }

  String _tabLabelForStatus(
    AppLocalizations l10n,
    OwnerListingStatus? status,
  ) {
    switch (status) {
      case OwnerListingStatus.active:
        return l10n.statusActive;
      case OwnerListingStatus.pending:
        return l10n.statusPending;
      case OwnerListingStatus.frozen:
        return l10n.statusFrozen;
      case OwnerListingStatus.rejected:
        return l10n.statusRejected;
      case OwnerListingStatus.draft:
        return 'Draft';
      default:
        return l10n.listingsNoResults;
    }
  }

  Widget _buildOwnerActionIcon({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    Color? color,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.65),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDisabled
              ? Colors.white.withValues(alpha: 0.4)
              : (color ?? Colors.white),
        ),
      ),
    );
  }

  void _handleListingTap(OwnerListing listing) {
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

  Future<void> _editListing(OwnerListing listing) async {
    setState(() => _editingListingId = listing.id);

    final editRoute = switch (listing.kind) {
      ListingKind.car => '/cars/${listing.id}/edit',
      ListingKind.job => '/jobs/${listing.id}/edit',
      ListingKind.house => '/listings/${listing.id}/edit',
      ListingKind.land => '/listings/${listing.id}/edit',
      ListingKind.unknown => '/listings/${listing.id}/edit',
    };

    final result = await context.push<bool>(editRoute);
    if (!mounted) return;
    setState(() => _editingListingId = null);

    if (result == true) {
      final notifier = ref.read(_currentProvider().notifier);
      notifier.loadMyListings();
    }
  }

  Future<void> _confirmDelete(
      OwnerListing listing, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listingDeleteConfirmTitle),
        content: Text(l10n.listingDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success =
        await ref.read(_currentProvider().notifier).delete(listing.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmSubmit(
      OwnerListing listing, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Listing'),
        content: const Text(
          'Submit this listing for moderation review?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent500),
            child: Text(l10n.listingSubmit),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final success =
        await ref.read(_currentProvider().notifier).submit(listing.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing submitted'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _featureListing(
      OwnerListing listing, AppLocalizations l10n) async {
    try {
      final result =
          await ref.read(promotionV2ServiceProvider).feature(listing.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.isFeatured ? 'Featured' : l10n.commonError),
            backgroundColor:
                result.isFeatured ? AppColors.success : AppColors.error,
          ),
        );
        final notifier = ref.read(_currentProvider().notifier);
        notifier.loadMyListings();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Tab label and filter for a my-listings tab.
class _MyListingsTab {
  final String label;
  final OwnerListingStatusFilter filter;

  const _MyListingsTab(this.label, this.filter);
}
