import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/listing.dart';
import '../../../../data/services/listing_service.dart';
import '../../widgets/common/wave_common_widgets.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonError),
          backgroundColor: AppColors.error,
        ),
      );
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
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.deleteListing(listing.id);
      if (result.success && mounted) _loadMyListings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _featureListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Feature this Listing?'),
        content: const Text(
          'Your listing will be featured on the home page and search results for 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Feature Now'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.featureListing(listing.id);
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.emerald600,
          ),
        );
        _loadMyListings();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
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
              // Check subscription limit before navigating
              final subState = ref.read(subscriptionProvider);
              final settingsAsync = ref.read(appSettingsProvider);
              final subscriptionEnabled = settingsAsync.maybeWhen(
                data: (data) => data['subscription_enabled'] == true,
                orElse: () => false,
              );
              if (subscriptionEnabled && !subState.canCreateListing) {
                final goSub = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    icon: const Icon(Icons.workspace_premium_outlined,
                        color: AppColors.accent500, size: 40),
                    title: const Text('Subscription Required'),
                    content: const Text(
                      'You\'ve reached your listing limit. Upgrade your subscription to post more listings.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(AppLocalizations.of(ctx).commonCancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('View Plans'),
                      ),
                    ],
                  ),
                );
                if (goSub == true && mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionPlansScreen(),
                    ),
                  );
                }
                return;
              }
              final result = await Navigator.of(context).push(
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
        title: 'Error Loading Listings',
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
        onAction: () {
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
                  Padding(
                    padding: const EdgeInsets.all(6),
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
