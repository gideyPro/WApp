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
import '../../providers/app_providers.dart';
import '../settings/settings_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import 'edit_listing_screen.dart';

/// My Listings Screen - Shows user's own listings
class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Listing> _myListings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadMyListings();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMyListings(page: _currentPage + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMyListings({int page = 1}) async {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    final service = ListingService();
    final response = await service.getMyListings(page: page);

    if (mounted) {
      setState(() {
        if (response.success) {
          _myListings = page == 1
              ? response.listings
              : [..._myListings, ...response.listings];
          _currentPage = response.currentPage ?? page;
          _totalPages = response.totalPages ?? 1;
          _hasMore = _currentPage < _totalPages;
        } else {
          _errorMessage = response.message;
        }
        _isLoading = false;
        _isLoadingMore = false;
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
    if (result == true && mounted) _loadMyListings();
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
      if (result.success && mounted) _loadMyListings();
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, AppLocalizations.of(context).commonError);
      }
    }
  }

  Future<void> _featureListing(Listing listing) async {
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
        _loadMyListings();
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

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(AppLocalizations.of(context).profileMyListings),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final nav = Navigator.of(context);
              // Check subscription limit before navigating
              final subState = ref.read(subscriptionProvider);
              final settingsAsync = ref.read(appSettingsProvider);
              final subscriptionEnabled = settingsAsync.maybeWhen(
                data: (data) => data['subscription_enabled'] == true,
                orElse: () => false,
              );

              if (subscriptionEnabled && !subState.canCreateListing) {
                // If still loading, skip front-end gate — backend validates anyway
                if (subState.isLoading) {
                  // proceed to create screen
                } else if (subState.errorMessage != null) {
                  // Network error — offer retry
                  await WaveDialog.show(
                    context: context,
                    title: AppLocalizations.of(context).errorConnection,
                    message: AppLocalizations.of(context).errorCheckSubscription,
                    type: DialogType.confirm,
                    actions: [
                      WaveButton(
                        text: AppLocalizations.of(context).commonCancel,
                        variant: ButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      WaveButton(
                        text: AppLocalizations.of(context).commonRetry,
                        onPressed: () {
                          ref.read(subscriptionProvider.notifier).refresh();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                  return;
                } else {
                  // Genuine limit reached or plan doesn't support
                  final l10n = AppLocalizations.of(context);
                  String message;
                  if (!subState.hasPaidSubscription) {
                    message = l10n.subscriptionRequiredListingSubtitle;
                  } else {
                    final plan = subState.subscription?.plan;
                    if (plan == null || plan.maxListings == 0) {
                      message = l10n.subscriptionPlanNotSupportedListing;
                    } else {
                      message = l10n.subscriptionLimitReached;
                    }
                  }
                  final goSub = await WaveDialog.showUpgrade(
                    context: context,
                    title: l10n.subscriptionRequiredTitle,
                    message: message,
                  );
                  if (goSub == true) {
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionPlansScreen(),
                      ),
                    );
                  }
                }
                if (!subState.isLoading && subState.errorMessage == null) return;
              }
              final result = await nav.push(
                MaterialPageRoute(builder: (_) => const CreateListingScreen()),
              );
              if (result == true && mounted) {
                _loadMyListings();
              }
            },
            tooltip: AppLocalizations.of(context).listingsCreate,
          ),
        ],
      ),
      body: _buildBody(canFeature),
    );
  }

  Widget _buildBody(bool canFeature) {
    if (_isLoading && _myListings.isEmpty) {
      return ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: 5,
        itemBuilder: (_, __) => const PropertyListingCard(isLoading: true),
      );
    }

    if (_errorMessage != null && _myListings.isEmpty) {
      return WaveMessageScreen.error(
        title: AppLocalizations.of(context).errorLoadingListings,
        subtitle: _errorMessage!,
        onRetry: () => _loadMyListings(),
        isEmbedded: true,
      );
    }

    if (_myListings.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return WaveEmptyState(
        icon: Icons.home_outlined,
        title: l10n.listingsNoResults,
        subtitle: l10n.myListingsEmptySubtitle,
        actionLabel: l10n.listingsCreate,
        onAction: () async {
          final subState = ref.read(subscriptionProvider);
          final settingsAsync = ref.read(appSettingsProvider);
          final subscriptionEnabled = settingsAsync.maybeWhen(
            data: (data) => data['subscription_enabled'] == true,
            orElse: () => false,
          );
          if (subscriptionEnabled && !subState.canCreateListing) {
            String message;
            if (!subState.hasPaidSubscription) {
              message = l10n.subscriptionRequiredListingSubtitle;
            } else {
              final plan = subState.subscription?.plan;
              if (plan == null || plan.maxListings == 0) {
                message = l10n.subscriptionPlanNotSupportedListing;
              } else {
                message = l10n.subscriptionLimitReached;
              }
            }
            final goSub = await WaveDialog.showUpgrade(
              context: context,
              title: l10n.subscriptionRequiredTitle,
              message: message,
            );
            if (goSub == true && mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
              );
            }
            return;
          }
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateListingScreen()),
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMyListings(),
      child: ListView.builder(
        controller: _scrollController,
        padding: AppSpacing.paddingLg,
        itemCount: _myListings.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _myListings.length) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: PropertyListingCard(isLoading: true),
            );
          }

          final listing = _myListings[index];
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
                if (canFeature && !listing.isFeaturedActive)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: _buildOwnerActionIcon(
                      icon: Icons.workspace_premium_outlined,
                      tooltip: 'Feature',
                      color: AppColors.accent500,
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
