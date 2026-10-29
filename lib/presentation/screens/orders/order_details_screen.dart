import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/status_helpers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/network/v2/api_v2_error.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/v2/buyer_order.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../data/services/v2/order_service.dart';
import '../../providers/v2_order_provider.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../../core/constants/app_spacing.dart';

/// One buyer request with its admin-curated listing suggestions.
class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isLoadingOrder = true;
  bool _isLoadingSuggestions = true;
  bool _isCancelling = false;
  int? _actingSuggestionId;
  String? _orderError;
  String? _suggestionsError;

  BuyerOrder? _order;
  List<OrderSuggestion> _suggestions = const [];

  OrderServiceV2 get _service => ref.read(orderV2ServiceProvider);

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    try {
      final order = await _service.fetchOrder(widget.orderId);

      if (!mounted) return;
      setState(() {
        _order = order;
        _isLoadingOrder = false;
        _orderError = null;
      });

      await _loadSuggestions();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _orderError = _messageFor(error);
        _isLoadingOrder = false;
      });
    }
  }

  Future<void> _loadSuggestions() async {
    try {
      final page = await _service.fetchSuggestions(widget.orderId);
      if (!mounted) return;
      setState(() {
        _suggestions = page.items;
        _isLoadingSuggestions = false;
        _suggestionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _suggestionsError = _messageFor(error);
        _isLoadingSuggestions = false;
      });
    }
  }

  String _messageFor(Object error) {
    if (error is ApiV2Exception) return error.message;
    return 'Something went wrong';
  }

  Future<void> _cancelOrder(int orderId, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.ordersCancel),
        content: Text(l10n.ordersCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.listingsYes),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    final updated = await ref.read(ordersV2Provider.notifier).cancel(orderId);

    if (!mounted) return;
    setState(() => _isCancelling = false);

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersCancelled),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.commonError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        centerTitle: false,
        title: Text(l10n.ordersDetailTitle),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoadingOrder && _order == null) {
      return ListView(
        padding: AppSpacing.paddingLg,
        children: [
          Shimmer.fromColors(
            baseColor: context.shimmerBase,
            highlightColor: context.shimmerHighlight,
            child: _buildOrderInfoSkeleton(),
          ),
        ],
      );
    }

    if (_orderError != null && _order == null) {
      return WaveMessageScreen.error(
        title: l10n.commonError,
        subtitle: _orderError!,
        onRetry: () {
          setState(() {
            _isLoadingOrder = true;
            _orderError = null;
            _order = null;
          });
          _loadOrder();
        },
        isEmbedded: true,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoadingOrder = true;
          _orderError = null;
          _order = null;
          _isLoadingSuggestions = true;
          _suggestionsError = null;
          _suggestions = const [];
        });
        await _loadOrder();
      },
      child: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          if (_order == null)
            Shimmer.fromColors(
              baseColor: context.shimmerBase,
              highlightColor: context.shimmerHighlight,
              child: _buildOrderInfoSkeleton(),
            )
          else
            _buildOrderInfoSection(l10n, _order!),
          const SizedBox(height: 16),
          _buildSuggestedPropertiesSection(l10n),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSkeleton() {
    return WaveGlass(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge row skeleton
            Row(
              children: [
                _buildSkeletonBox(width: 60, height: 18),
                const SizedBox(width: 6),
                _buildSkeletonBox(width: 80, height: 18),
                const Spacer(),
                _buildSkeletonBox(width: 60, height: 18),
              ],
            ),
            const SizedBox(height: 16),

            // Budget skeleton
            _buildSkeletonLine(isFull: true),
            const SizedBox(height: 8),
            _buildSkeletonLine(width: 0.6),
            const Divider(height: 16),

            // Area skeleton
            _buildSkeletonLine(isFull: true),
            const SizedBox(height: 8),
            _buildSkeletonLine(width: 0.6),
            const Divider(height: 16),

            // Facing / Location skeleton
            _buildSkeletonLine(isFull: true),
            const SizedBox(height: 8),
            _buildSkeletonLine(width: 0.5),
            const Divider(height: 16),

            // Description skeleton
            _buildSkeletonLine(isFull: true),
            const SizedBox(height: 6),
            _buildSkeletonLine(isFull: true),
            const SizedBox(height: 6),
            _buildSkeletonLine(width: 0.7),
            const SizedBox(height: 24),
            _buildSkeletonLine(isFull: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoSection(AppLocalizations l10n, BuyerOrder order) {
    return WaveGlass(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges row
            Row(
              children: [
                _buildBadge(
                  typeLabel(order.type.name, l10n),
                  typeColor(order.type.name),
                  Colors.white,
                ),
                const SizedBox(width: 6),
                if (order.holdingType != null)
                  Flexible(
                    child: _buildBadge(
                      order.holdingType!,
                      context.isDarkMode
                          ? AppColors.cardNavyLight
                          : AppColors.stone100,
                      context.isDarkMode
                          ? AppColors.accent300
                          : AppColors.primary800,
                    ),
                  ),
                const Spacer(),
                _buildBadge(
                  statusLabel(order.status.wireValue, l10n),
                  statusColor(order.status.wireValue).withValues(alpha: 0.15),
                  statusColor(order.status.wireValue),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget
            if (!order.budget.isEmpty) ...[
              _detailRow(
                l10n.ordersBudget,
                formatRange(order.budget.min, order.budget.max, 'ETB', l10n),
              ),
              const Divider(height: 16),
            ],

            // Area
            if (!order.area.isEmpty) ...[
              _detailRow(
                l10n.ordersArea,
                formatRange(order.area.min, order.area.max, 'm²', l10n),
              ),
              const Divider(height: 16),
            ],

            // Facing Direction
            if (order.facingDirection != null) ...[
              _detailRow(
                l10n.ordersFacing,
                facingDirectionLabel(order.facingDirection, l10n),
              ),
              const Divider(height: 16),
            ],

            // Location
            if (order.hasAddress) ...[
              _detailRow(l10n.ordersLocation, order.address!.displayAddress),
              const Divider(height: 16),
            ],

            // Description
            _detailRow(l10n.ordersDescription, order.description,
                isDescription: true),
            const SizedBox(height: 16),

            // Cancel Button (Edit removed as per requirement)
            if (order.canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      _isCancelling ? null : () => _cancelOrder(order.id, l10n),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.5)),
                    foregroundColor: AppColors.error,
                  ),
                  child: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.ordersCancel),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPropertiesSection(AppLocalizations l10n) {
    return WaveGlass(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ordersSuggestions,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.theme.iconSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.ordersSuggestionsSubtitle,
              style: AppTextStyles.caption
                  .copyWith(color: ThemeColors(context).textSecondary),
            ),
            const SizedBox(height: 16),
            if (_isLoadingSuggestions)
              const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_suggestionsError != null || _suggestions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    _suggestionsError ?? l10n.ordersSuggestionsEmpty,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: ThemeColors(context).textMuted),
                  ),
                ),
              )
            else
              ..._suggestions
                  .map((suggestion) => _buildSuggestionTile(suggestion, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(
      OrderSuggestion suggestion, AppLocalizations l10n) {
    final listing = suggestion.listing;
    final isActing = _actingSuggestionId == suggestion.id;

    return LiquidGlass(
      borderRadius: 16,
      blur: 20,
      variant: LiquidGlassVariant.regular,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (listing != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: listing.hasCoverImage
                        ? CachedNetworkImage(
                            imageUrl: listing.coverImage!.url!,
                            fit: BoxFit.cover,
                            memCacheWidth: 160,
                            memCacheHeight: 160,
                            placeholder: (_, __) => _suggestionPlaceholder(),
                            errorWidget: (_, __, ___) =>
                                _suggestionPlaceholder(),
                          )
                        : _suggestionPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing?.title ?? l10n.listingsNotFound,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (listing != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _suggestionPrice(l10n, listing),
                        style: AppTextStyles.caption.copyWith(
                            color: ThemeColors(context).textSecondary),
                      ),
                      if (listing.location.shortLabel.isNotEmpty)
                        Text(
                          listing.location.shortLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: ThemeColors(context).textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                    if (suggestion.adminNotes != null &&
                        suggestion.adminNotes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        suggestion.adminNotes!,
                        style: AppTextStyles.caption
                            .copyWith(color: ThemeColors(context).textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (suggestion.status.isPending)
                OutlinedButton(
                  onPressed:
                      listing == null ? null : () => _openListing(listing),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: BorderSide(color: context.theme.divider),
                    foregroundColor: ThemeColors(context).textPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  child: Text(
                    l10n.ordersSuggestionsViewDetails,
                    style: AppTextStyles.labelSmall
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                )
              else
                _buildSuggestionStatusBadge(suggestion, l10n),
            ],
          ),

          // Accept / Decline buttons (inline, below the info row)
          if (suggestion.status.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isActing || !suggestion.canAccept
                        ? null
                        : () => _acceptSuggestion(suggestion, l10n),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: isActing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(l10n.ordersSuggestionsAccept),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isActing || !suggestion.canDecline
                        ? null
                        : () => _declineSuggestion(suggestion, l10n),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.5)),
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(l10n.ordersSuggestionsDecline),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionStatusBadge(
      OrderSuggestion suggestion, AppLocalizations l10n) {
    final accepted = suggestion.status == OrderSuggestionStatus.accepted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (accepted ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        accepted
            ? l10n.ordersSuggestionsAccepted
            : l10n.ordersSuggestionsDeclined,
        style: AppTextStyles.labelSmall.copyWith(
          color: accepted ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _suggestionPlaceholder() {
    return Container(
      color:
          context.theme.isDark ? AppColors.cardNavyLight : AppColors.primary50,
      child: Icon(
        Icons.apartment_rounded,
        size: 28,
        color: context.theme.textMuted,
      ),
    );
  }

  String _suggestionPrice(AppLocalizations l10n, ListingSummary listing) {
    final amount = listing.price.amount;
    if (amount == null) return l10n.listingPriceOnRequest;

    return l10n.listingsPriceFixed(smartDecimal(amount));
  }

  void _openListing(ListingSummary listing) {
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

  Future<void> _acceptSuggestion(
      OrderSuggestion suggestion, AppLocalizations l10n) async {
    setState(() => _actingSuggestionId = suggestion.id);
    try {
      final updated = await _service.acceptSuggestion(
        widget.orderId,
        suggestion.id,
      );
      if (!mounted) return;
      _replaceSuggestion(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersSuggestionsAcceptedMessage),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersSuggestionsError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _actingSuggestionId = null);
    }
  }

  Future<void> _declineSuggestion(
      OrderSuggestion suggestion, AppLocalizations l10n) async {
    setState(() => _actingSuggestionId = suggestion.id);
    try {
      final updated = await _service.declineSuggestion(
        widget.orderId,
        suggestion.id,
      );
      if (!mounted) return;
      _replaceSuggestion(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersSuggestionsDeclinedMessage),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ordersSuggestionsError),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _actingSuggestionId = null);
    }
  }

  void _replaceSuggestion(OrderSuggestion updated) {
    setState(() {
      _suggestions = _suggestions
          .map((suggestion) =>
              suggestion.id == updated.id ? updated : suggestion)
          .toList();
    });
  }

  /// Skeleton box for shimmer loading placeholders
  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  /// Skeleton line for shimmer loading placeholder (full or partial width)
  Widget _buildSkeletonLine({bool isFull = false, double width = 1.0}) {
    return Container(
      width: isFull ? double.infinity : double.infinity * width,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isDescription = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: isDescription ? 10 : 2,
          overflow:
              isDescription ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
