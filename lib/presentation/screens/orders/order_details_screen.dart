import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/status_helpers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/lead_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../../core/constants/app_spacing.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  bool _isLoadingOrder = true;
  bool _isCancelling = false;
  String? _orderError;

  dynamic _order;
  late Future<LeadResponse> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final response = await ref.read(orderServiceProvider).getOrder(widget.orderId);
    if (mounted && response.success) {
      setState(() {
        _order = response.orders.first;
        _isLoadingOrder = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _suggestionsFuture = LeadService().getSuggestions(widget.orderId);
        });
      });
    } else if (mounted) {
      setState(() {
        _orderError = response.message;
        _isLoadingOrder = false;
      });
    }
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

    final success =
        await ref.read(ordersProvider.notifier).cancelOrder(orderId);
    if (mounted) {
      setState(() => _isCancelling = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersCancelled), backgroundColor: AppColors.success));
        if (mounted) Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.commonError), backgroundColor: AppColors.error));
      }
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
            _buildOrderInfoSection(l10n),
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

  Widget _buildOrderInfoSection(AppLocalizations l10n) {
    final cache = ref.watch(addressCacheProvider);
    final isActive = _order.isActive ?? false;

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
                  typeLabel(_order.type, l10n),
                  typeColor(_order.type),
                  Colors.white,
                ),
                const SizedBox(width: 6),
                if (_order.holdingType != null)
                  _buildBadge(
                    _order.getLocalizedHoldingType(context),
                    AppColors.stone100,
                    AppColors.primary800,
                  ),
                const Spacer(),
                _buildBadge(
                  statusLabel(_order.status, l10n),
                  statusColor(_order.status).withValues(alpha: 0.15),
                  statusColor(_order.status),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Budget
            if (_order.minBudget != null || _order.maxBudget != null) ...[
              _detailRow(l10n.ordersBudget,
                  formatRange(_order.minBudget, _order.maxBudget, 'ETB', l10n)),
              const Divider(height: 16),
            ],

            // Area
            if (_order.minArea != null || _order.maxArea != null) ...[
              _detailRow(l10n.ordersArea,
                  formatRange(_order.minArea, _order.maxArea, 'm²', l10n)),
              const Divider(height: 16),
            ],

            // Facing Direction
            if (_order.facingDirection != null) ...[
              _detailRow(
                l10n.ordersFacing,
                _order.getLocalizedFacingDirection(context),
              ),
              const Divider(height: 16),
            ],

            // Location
            if (_order.address != null) ...[
              _detailRow(l10n.ordersLocation,
                  _order.address!.getLocalizedAddress(context, cache)),
              const Divider(height: 16),
            ],

            // Description
            _detailRow(l10n.ordersDescription, _order.description,
                isDescription: true),
            const SizedBox(height: 16),

            // Cancel Button (Edit removed as per requirement)
            if (isActive)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isCancelling
                      ? null
                      : () => _cancelOrder(_order.id, l10n),
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
    return FutureBuilder<LeadResponse>(
      future: _suggestionsFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError =
            snapshot.hasError || (snapshot.hasData && !snapshot.data!.success);
        final suggestions = snapshot.data?.leads ?? [];

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
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (hasError || suggestions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        l10n.ordersSuggestionsEmpty,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: ThemeColors(context).textMuted),
                      ),
                    ),
                  )
                else
                  ...suggestions
                      .map((s) => _buildSuggestionTile(context, s, l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionTile(
      BuildContext context, Lead suggestion, AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 4,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.listingTitle ??
                          l10n.listingIdLabel(suggestion.listingId.toString()),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (suggestion.listingPrice != null)
                      Text(
                        l10n.listingsPriceFixed(formatPrice(suggestion.listingPrice)),
                        style: AppTextStyles.caption
                            .copyWith(color: ThemeColors(context).textSecondary),
                      ),
                    if (suggestion.adminNotes != null &&
                        suggestion.adminNotes!.isNotEmpty)
                      Text(
                        suggestion.adminNotes!,
                        style: AppTextStyles.caption
                            .copyWith(color: ThemeColors(context).textTertiary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (suggestion.isSuggestionPending)
                OutlinedButton(
                  onPressed: () {
                    context.push('/listings/${suggestion.listingId}');
                  },
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: suggestion.isSuggestionAccepted
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    suggestion.isSuggestionAccepted
                        ? l10n.ordersSuggestionsAccepted
                        : l10n.ordersSuggestionsDeclined,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: suggestion.isSuggestionAccepted
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),

          // Accept / Decline buttons (inline, below the info row)
          if (suggestion.isSuggestionPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptSuggestion(suggestion.id, l10n),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.ordersSuggestionsAccept),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineSuggestion(suggestion.id, l10n),
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

  Future<void> _acceptSuggestion(
      int suggestionId, AppLocalizations l10n) async {
    final response = await ref.read(leadServiceProvider).acceptSuggestion(suggestionId);
    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersSuggestionsAcceptedMessage), backgroundColor: AppColors.success));
        setState(() {
          _suggestionsFuture = ref.read(leadServiceProvider).getSuggestions(widget.orderId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersSuggestionsError), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _declineSuggestion(
      int suggestionId, AppLocalizations l10n) async {
    final response = await ref.read(leadServiceProvider).declineSuggestion(suggestionId);
    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersSuggestionsDeclinedMessage), backgroundColor: AppColors.success));
        setState(() {
          _suggestionsFuture = ref.read(leadServiceProvider).getSuggestions(widget.orderId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.ordersSuggestionsError), backgroundColor: AppColors.error));
      }
    }
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
            color: AppColors.primary400,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary900,
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
