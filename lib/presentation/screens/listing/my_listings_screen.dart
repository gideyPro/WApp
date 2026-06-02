import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/services/listing_service.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_dialog.dart';
import '../../widgets/listing_card.dart';
import '../listing/listing_detail_screen.dart';
import '../listing/create_listing_screen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../subscriptions/subscription_plans_screen.dart';
import 'edit_listing_screen.dart';

class _TabState {
  List<Listing> listings = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  bool hasMore = false;
}

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late List<_TabState> _tabStates;
  late List<String Function(AppLocalizations)> _tabLabels;

  static const _tabs = [
    'all',
    'active',
    'pending',
    'frozen',
    'rejected',
    'sold',
    'rented',
  ];

  static String? _statusForTab(int index) {
    if (index == 0) return null;
    return _tabs[index];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _tabStates = List.generate(_tabs.length, (_) => _TabState());
    _tabLabels = [
      (l) => l.searchFilterAll,
      (l) => l.statusActive,
      (l) => l.statusPending,
      (l) => l.statusFrozen,
      (l) => l.statusRejected,
      (l) => l.statusSold,
      (l) => l.statusRented,
    ];
    _scrollController.addListener(_onScroll);
    _loadTab(0);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  int get _currentTab => _tabController.index;

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadTab(_currentTab);
    }
  }

  void _onScroll() {
    final state = _tabStates[_currentTab];
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !state.isLoading &&
        !state.isLoadingMore &&
        state.hasMore) {
      _loadTab(_currentTab, page: state.currentPage + 1);
    }
  }

  Future<void> _loadTab(int tabIndex, {int page = 1}) async {
    final state = _tabStates[tabIndex];
    if (page == 1) {
      state.isLoading = true;
      state.errorMessage = null;
    } else {
      state.isLoadingMore = true;
    }
    setState(() {});

    final service = ListingService();
    final response = await service.getMyListings(
      page: page,
      status: _statusForTab(tabIndex),
    );

    if (mounted) {
      setState(() {
        if (response.success) {
          state.listings = page == 1
              ? response.listings
              : [...state.listings, ...response.listings];
          state.currentPage = response.currentPage ?? page;
          state.totalPages = response.totalPages ?? 1;
          state.hasMore = state.currentPage < state.totalPages;
        } else {
          state.errorMessage = response.message;
        }
        state.isLoading = false;
        state.isLoadingMore = false;
      });
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
        child: Icon(icon, size: 16, color: isDisabled ? Colors.white.withValues(alpha: 0.4) : (color ?? Colors.white)),
      ),
    );
  }

  int? _editingListingId;
  bool _isEditing(int listingId) => _editingListingId == listingId;

  Future<void> _editListing(Listing listing) async {
    setState(() => _editingListingId = listing.id);
    final service = ListingService();
    final detail = await service.getListingDetail(listing.id);
    if (!mounted) return;
    setState(() => _editingListingId = null);
    if (!detail.success || detail.listing == null) {
      WaveToast.showError(context, AppLocalizations.of(context).commonError);
      return;
    }
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditListingScreen(listing: detail.listing!),
      ),
    );
    if (result == true && mounted) _loadTab(_currentTab);
  }

  Future<void> _deleteListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.showConfirm(
      context: context,
      title: l10n.listingDeleteConfirmTitle,
      message: l10n.listingDeleteConfirmMessage,
      confirmLabel: l10n.commonDelete,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.deleteListing(listing.id);
      if (result.success && mounted) _loadTab(_currentTab);
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _featureListing(Listing listing) async {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canFeatureListing) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await WaveDialog.show<bool>(
      context: context,
      title: '${l10n.listingFeatureThis}?',
      message: 'Your listing will be featured on the home page and search results for 30 days.',
      type: DialogType.confirm,
      actions: [
        WaveButton(
          text: l10n.commonCancel,
          variant: ButtonVariant.outline,
          onPressed: () => Navigator.pop(context, false),
        ),
        WaveButton(
          text: l10n.listingFeatureNow,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.featureListing(listing.id);
      if (result.success && mounted) {
        WaveToast.showSuccess(context, result.message);
        _loadTab(_currentTab);
      } else if (mounted) {
        WaveToast.showError(context, result.message);
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, l10n.commonError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);
    final canFeature = subState.canFeatureListing;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(l10n.profileMyListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              final nav = Navigator.of(context);
              final result = await nav.push(
                MaterialPageRoute(builder: (_) => const CreateListingScreen()),
              );
              if (result == true && mounted) {
                _loadTab(_currentTab);
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
            labelColor: AppColors.primary500,
            unselectedLabelColor: AppColors.stone500,
            indicatorColor: AppColors.primary500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: _tabs.asMap().entries.map((e) {
              return Tab(text: _tabLabels[e.key](l10n));
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_tabs.length, (i) {
                return _buildTabBody(i, canFeature);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBody(int tabIndex, bool canFeature) {
    final state = _tabStates[tabIndex];

    if (state.isLoading && state.listings.isEmpty) {
      return ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: 5,
        itemBuilder: (_, __) => const PropertyListingCard(isLoading: true),
      );
    }

    if (state.errorMessage != null && state.listings.isEmpty) {
      return WaveMessageScreen.error(
        title: AppLocalizations.of(context).errorLoadingListings,
        subtitle: state.errorMessage!,
        onRetry: () => _loadTab(tabIndex),
        isEmbedded: true,
      );
    }

    if (state.listings.isEmpty) {
      final l10n = AppLocalizations.of(context);
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
                decoration: const BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: AppColors.primary400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isAllTab
                    ? l10n.listingsNoResults
                    : l10n.noStatusListings(_tabLabels[tabIndex](l10n)),
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              if (isAllTab) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.myListingsEmptySubtitle,
                  style: AppTextStyles.bodyMedium,
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
                      if (!mounted) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                      );
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
      onRefresh: () => _loadTab(tabIndex),
      child: ListView.builder(
        controller: tabIndex == _currentTab ? _scrollController : null,
        padding: AppSpacing.paddingLg,
        itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.listings.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(isLoading: true),
            );
          }

          final listing = state.listings[index];
          final isEditing = _isEditing(listing.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PropertyListingCard(
              listing: listing,
              hideFavoriteButton: true,
              imageOverlayActions: [
                if (isEditing)
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  _buildOwnerActionIcon(
                    icon: Icons.edit_outlined,
                    tooltip: AppLocalizations.of(context).commonEdit,
                    onTap: () => _editListing(listing),
                  ),
                const SizedBox(width: 4),
                _buildOwnerActionIcon(
                  icon: Icons.delete_outline,
                  tooltip: AppLocalizations.of(context).commonDelete,
                  color: AppColors.error,
                  onTap: isEditing ? null : () => _deleteListing(listing),
                ),
                if (!listing.isFeaturedActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _buildOwnerActionIcon(
                      icon: canFeature ? Icons.workspace_premium_outlined : Icons.lock_outline,
                      tooltip: canFeature ? 'Feature' : 'Upgrade to Feature',
                      color: canFeature ? AppColors.accent500 : AppColors.stone400,
                      onTap: isEditing ? null : () => _featureListing(listing),
                    ),
                  ),
              ],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ListingDetailScreen(listingId: listing.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
