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
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              final nav = Navigator.of(context);
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
                l10n.listingsNoResults,
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
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
          ),
        ),
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
