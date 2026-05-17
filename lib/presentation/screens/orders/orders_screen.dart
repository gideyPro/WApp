import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/services/order_service.dart';
import '../../../data/models/image.dart';
import '../../widgets/video/video_player_widget.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_glass.dart';
import 'create_order_screen.dart';
import 'edit_order_screen.dart';
import '../../../core/constants/app_spacing.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.ordersStatusActive;
      case 'fulfilled':
        return l10n.ordersStatusFulfilled;
      case 'cancelled':
        return l10n.ordersStatusCancelled;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.accent500;
      case 'fulfilled':
        return AppColors.success;
      case 'cancelled':
        return AppColors.zinc400;
      default:
        return AppColors.primary400;
    }
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    return type == 'house' ? l10n.ordersTypeHouse : l10n.ordersTypeLand;
  }

  Color _typeColor(String type) {
    return type == 'house' ? AppColors.primary600 : AppColors.emerald500;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: context.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.ordersTitle),
            if (state.total > 0)
              Text(
                '${state.total} ${l10n.ordersTitle.toLowerCase()}',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary400),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
              );
              if (mounted) {
                ref.read(ordersProvider.notifier).loadOrders();
              }
            },
          ),
        ],
      ),
      body: _buildBody(state, l10n),
    );
  }

  Widget _buildBody(OrdersState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return _buildSkeletonList(5);
    }

    if (state.errorMessage != null) {
      return WaveMessageScreen.error(
        title: l10n.commonError,
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(ordersProvider.notifier).loadOrders();
        },
        isEmbedded: true,
      );
    }

    if (state.orders.isEmpty) {
      return WaveEmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.ordersEmpty,
        subtitle: l10n.ordersEmptySubtitle,
        actionLabel: l10n.ordersCreate,
        onAction: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
          if (mounted) {
            ref.read(ordersProvider.notifier).loadOrders();
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(ordersProvider.notifier).loadOrders(),
      child: ListView.builder(
        padding: AppSpacing.paddingLg,
        itemCount: state.orders.length,
        itemBuilder: (context, index) {
          final order = state.orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: WaveGlass(
              child: InkWell(
                onTap: () => _showOrderDetail(context, order, l10n),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildBadge(
                            _typeLabel(order.type, l10n),
                            _typeColor(order.type),
                            Colors.white,
                          ),
                          if (order.holdingType != null) ...[
                            const SizedBox(width: 6),
                            _buildBadge(
                              order.holdingType!,
                              AppColors.zinc100,
                              AppColors.primary800,
                            ),
                          ],
                          const Spacer(),
                          _buildBadge(
                            _statusLabel(order.status, l10n),
                            _statusColor(order.status).withValues(alpha: 0.15),
                            _statusColor(order.status),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        order.description,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (order.minBudget != null || order.maxBudget != null)
                            _infoChip(
                              Icons.monetization_on_outlined,
                              _formatRange(order.minBudget, order.maxBudget, 'ETB'),
                            ),
                          if ((order.minBudget != null || order.maxBudget != null) &&
                              (order.minArea != null || order.maxArea != null))
                            const SizedBox(width: 12),
                          if (order.minArea != null || order.maxArea != null)
                            _infoChip(
                              Icons.square_foot,
                              _formatRange(order.minArea, order.maxArea, 'm²'),
                            ),
                        ],
                      ),
                      if (order.locationDisplay.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: AppColors.primary400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                order.locationDisplay,
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primary500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.primary400),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.primary600),
        ),
      ],
    );
  }

  String _formatPrice(double? value) {
    if (value == null) return '0';
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(value);
  }

  String _formatRange(double? min, double? max, String unit) {
    if (min != null && max != null) {
      return '${_formatPrice(min)} - ${_formatPrice(max)} $unit';
    }
    if (min != null) return '${_formatPrice(min)}+ $unit';
    if (max != null) return 'Up to ${_formatPrice(max)} $unit';
    return '';
  }

  void _showOrderDetail(BuildContext context, dynamic order, AppLocalizations l10n) {
    final orderService = OrderService();
    late Future<OrderSuggestionResponse> suggestionsFuture;
    suggestionsFuture = orderService.getSuggestions(order.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.zinc300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildBadge(
                      _typeLabel(order.type, l10n),
                      _typeColor(order.type),
                      Colors.white,
                    ),
                    const SizedBox(width: 6),
                    if (order.holdingType != null)
                      _buildBadge(
                        order.holdingType!,
                        AppColors.zinc100,
                        AppColors.primary800,
                      ),
                    const Spacer(),
                    _buildBadge(
                      _statusLabel(order.status, l10n),
                      _statusColor(order.status).withValues(alpha: 0.15),
                      _statusColor(order.status),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (order.minBudget != null || order.maxBudget != null) ...[
                  _detailRow(l10n.ordersBudget,
                      _formatRange(order.minBudget, order.maxBudget, 'ETB')),
                  const Divider(height: 16),
                ],
                if (order.minArea != null || order.maxArea != null) ...[
                  _detailRow(l10n.ordersArea,
                      _formatRange(order.minArea, order.maxArea, 'm²')),
                  const Divider(height: 16),
                ],
                if (order.facingDirection != null) ...[
                  _detailRow(l10n.ordersFacing,
                      order.facingDirection!.replaceAll('_', ' ')),
                  const Divider(height: 16),
                ],
                if (order.locationDisplay.isNotEmpty) ...[
                  _detailRow(l10n.ordersLocation, order.locationDisplay),
                  const Divider(height: 16),
                ],
                _detailRow(l10n.ordersDescription, order.description, isDescription: true),
                const SizedBox(height: 16),
                if (order.isActive)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditOrderScreen(order: order),
                              ),
                            );
                            if (mounted) {
                              ref.read(ordersProvider.notifier).loadOrders();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            backgroundColor: AppColors.accent500,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.ordersEdit),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmCancel(order.id, l10n),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                            foregroundColor: AppColors.error,
                          ),
                          child: Text(l10n.ordersCancel),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                FutureBuilder<OrderSuggestionResponse>(
                  future: suggestionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    }
                    if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final suggestions = snapshot.data!.suggestions;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          l10n.ordersSuggestions,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary400,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.ordersSuggestionsSubtitle,
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary500),
                        ),
                        const SizedBox(height: 12),
                        ...suggestions.map((s) => _buildSuggestionTile(context, s, orderService, l10n, order)),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuggestionDetail(BuildContext context, OrderSuggestion suggestion, OrderService orderService, AppLocalizations l10n, dynamic order) {
    final listing = suggestion.listing;
    final images = (listing?['images'] as List?)?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>)).toList() ?? <ImageModel>[];
    final videoUrl = listing?['video_link'] as String?;
    final property = listing?['property'] as Map<String, dynamic>?;
    final isHouse = listing?['property_type']?.toString().contains('House') ?? false;
    final address = listing?['address'] as Map<String, dynamic>?;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setSheetState) {
              int currentImageIndex = 0;
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Gallery
                    if (images.isNotEmpty)
                      SizedBox(
                        height: 280,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) => setSheetState(() => currentImageIndex = i),
                              itemBuilder: (context, index) => CachedNetworkImage(
                                imageUrl: images[index].imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(color: AppColors.primary100),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.primary100,
                                  child: Icon(Icons.broken_image, size: 48, color: AppColors.primary400),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12, right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${currentImageIndex + 1}/${images.length}',
                                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.zinc300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title & Price
                          Text(
                            suggestion.listingTitle ?? 'Listing #${suggestion.listingId}',
                            style: AppTextStyles.headline4.copyWith(color: AppColors.primary900),
                          ),
                          if (suggestion.listingPrice != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${_formatPrice(suggestion.listingPrice)} ETB',
                              style: AppTextStyles.priceLarge.copyWith(color: AppColors.accent500),
                            ),
                          ],
                          const SizedBox(height: 8),

                          // Badges row
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildBadge(
                                isHouse ? l10n.ordersTypeHouse : l10n.ordersTypeLand,
                                isHouse ? AppColors.primary600 : AppColors.emerald500,
                                Colors.white,
                              ),
                              _buildBadge(
                                listing?['listing_type'] == 'rental' ? l10n.ordersRent : l10n.ordersBuy,
                                AppColors.zinc100,
                                AppColors.primary800,
                              ),
                              if (listing != null && listing['holding_type'] != null)
                                _buildBadge(
                                  listing['holding_type'] as String,
                                  AppColors.zinc100,
                                  AppColors.primary800,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Location
                          if (address != null) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatListingAddress(address),
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Video Tour
                          if (videoUrl != null && videoUrl.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.videocam, size: 18, color: AppColors.accent500),
                                const SizedBox(width: 6),
                                Text(l10n.listingsVideoTour, style: AppTextStyles.titleSmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            VideoPlayerWidget(
                              videoUrl: videoUrl,
                              autoPlay: false,
                              looping: false,
                              title: l10n.listingsVideoTour,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Key Features
                          if (isHouse) ...[
                            _buildSuggestionKeyFeatures(context, listing, property),
                            const SizedBox(height: 16),
                          ],

                          // Description
                          if (property?['description'] != null && (property!['description'] as String).isNotEmpty) ...[
                            Text(l10n.listingsDescription, style: AppTextStyles.titleSmall),
                            const SizedBox(height: 6),
                            Text(
                              property!['description'] as String,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary700),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Property Details
                          _buildSuggestionPropertyDetails(context, listing, l10n),
                          const SizedBox(height: 16),

                          // Admin Notes
                          if (suggestion.adminNotes != null && suggestion.adminNotes!.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.primary200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Admin Notes', style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  )),
                                  const SizedBox(height: 4),
                                  Text(suggestion.adminNotes!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary800)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Accept/Decline
                          if (suggestion.isPending)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final response = await orderService.acceptSuggestion(suggestion.id);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        if (response.success) {
                                          WaveToast.showSuccess(context, l10n.ordersSuggestionsAcceptedMessage);
                                          setState(() {});
                                        } else {
                                          WaveToast.showError(context, l10n.ordersSuggestionsError);
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(l10n.ordersSuggestionsAccept),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final response = await orderService.declineSuggestion(suggestion.id);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        if (response.success) {
                                          WaveToast.showSuccess(context, l10n.ordersSuggestionsDeclinedMessage);
                                          setState(() {});
                                        } else {
                                          WaveToast.showError(context, l10n.ordersSuggestionsError);
                                        }
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                                      foregroundColor: AppColors.error,
                                    ),
                                    child: Text(l10n.ordersSuggestionsDecline),
                                  ),
                                ),
                              ],
                            )
                          else
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: suggestion.isAccepted
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  suggestion.isAccepted ? l10n.ordersSuggestionsAccepted : l10n.ordersSuggestionsDeclined,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: suggestion.isAccepted ? AppColors.success : AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSuggestionKeyFeatures(BuildContext context, Map<String, dynamic>? listing, Map<String, dynamic>? property) {
    final chips = <Widget>[];
    final l10n = AppLocalizations.of(context);

    if (property != null) {
      final bedrooms = property['bedrooms'];
      final bathrooms = property['bathrooms'];
      final salons = property['salons'];
      final kitchens = property['kitchens'];
      if (bedrooms != null && (bedrooms as int) > 0) {
        chips.add(_buildSuggestionFeatureChip(Icons.bed, l10n.listingsBedrooms(bedrooms)));
      }
      if (bathrooms != null && (bathrooms as int) > 0) {
        chips.add(_buildSuggestionFeatureChip(Icons.bathtub, l10n.listingsBathrooms(bathrooms)));
      }
      if (salons != null && (salons as int) > 0) {
        chips.add(_buildSuggestionFeatureChip(Icons.weekend, l10n.listingsSalons(salons)));
      }
      if (kitchens != null && (kitchens as int) > 0) {
        chips.add(_buildSuggestionFeatureChip(Icons.kitchen, l10n.listingKitchensCount(kitchens)));
      }
    }

    final totalArea = listing?['total_square_meters'];
    if (totalArea != null) {
      chips.add(_buildSuggestionFeatureChip(Icons.square_foot, l10n.listingUnitM2((totalArea as num).toInt())));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsKeyFeatures, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _buildSuggestionFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent500),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelMedium.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  Widget _buildSuggestionPropertyDetails(BuildContext context, Map<String, dynamic>? listing, AppLocalizations l10n) {
    if (listing == null) return const SizedBox.shrink();
    final details = <Map<String, String>>[];

    final frontArea = listing['front_area_sqm'];
    final sideArea = listing['side_area_sqm'];
    if (frontArea != null && (frontArea as num) > 0) {
      details.add({'label': l10n.listingsFrontArea, 'value': l10n.listingUnitM2(frontArea.toInt())});
    }
    if (sideArea != null && (sideArea as num) > 0) {
      details.add({'label': l10n.listingsSideArea, 'value': l10n.listingUnitM2(sideArea.toInt())});
    }

    final useType = listing['use_type'];
    if (useType != null) {
      details.add({'label': l10n.listingsUseType, 'value': useType as String});
    }

    final holdingType = listing['holding_type'];
    if (holdingType != null) {
      details.add({'label': l10n.listingsHoldingType, 'value': holdingType as String});

      final privateDetail = listing['private_holding_detail'] as Map<String, dynamic>?;
      final leaseDetail = listing['lease_holding_detail'] as Map<String, dynamic>?;
      final cooperativeDetail = listing['cooperative_holding_detail'] as Map<String, dynamic>?;

      if (holdingType == 'Free Hold' && privateDetail != null) {
        if (privateDetail['tax_paid_until_year'] != null) {
          details.add({'label': l10n.listingTaxPaid, 'value': privateDetail['tax_paid_until_year'].toString()});
        }
        if (privateDetail['acquisition_clarification'] != null) {
          details.add({'label': l10n.listingAcquisition, 'value': privateDetail['acquisition_clarification'] as String});
        }
      }

      if (holdingType == 'Lease Hold' && leaseDetail != null) {
        if (leaseDetail['leased_year'] != null) {
          details.add({'label': l10n.listingLeasedYear, 'value': leaseDetail['leased_year'].toString()});
        }
        if (leaseDetail['lease_price_per_sqm'] != null) {
          details.add({'label': l10n.listingLeasePrice, 'value': '${(leaseDetail['lease_price_per_sqm'] as num).toInt()} ETB'});
        }
        if (leaseDetail['annual_payment'] != null) {
          details.add({'label': l10n.listingAnnualPayment, 'value': '${(leaseDetail['annual_payment'] as num).toInt()} ETB'});
        }
        if (leaseDetail['build_type'] != null) {
          details.add({'label': l10n.listingBuildType, 'value': leaseDetail['build_type'] as String});
        }
        if (leaseDetail['leaseholder_name'] != null) {
          details.add({'label': l10n.listingLeaseHolder, 'value': leaseDetail['leaseholder_name'] as String});
        }
        if (leaseDetail['lease_organization'] != null) {
          details.add({'label': l10n.listingLeaseOrganization, 'value': leaseDetail['lease_organization'] as String});
        }
        if (leaseDetail['lease_expiry_date'] != null) {
          details.add({'label': l10n.listingLeaseExpiry, 'value': leaseDetail['lease_expiry_date'].toString()});
        }
      }

      if (holdingType == 'Cooperative' && cooperativeDetail != null) {
        if (cooperativeDetail['cooperative_name'] != null) {
          details.add({'label': l10n.listingCooperativeName, 'value': cooperativeDetail['cooperative_name'] as String});
        }
        if (cooperativeDetail['cooperative_code'] != null) {
          details.add({'label': l10n.listingCooperativeCode, 'value': cooperativeDetail['cooperative_code'] as String});
        }
        if (cooperativeDetail['building_status'] != null) {
          details.add({
            'label': l10n.listingBuildingStatus,
            'value': cooperativeDetail['building_status'] == 'Finished' ? l10n.listingFinished : l10n.listingUnfinished,
          });
        }
      }
    }

    final facing = listing['facing_direction'];
    if (facing != null) {
      details.add({'label': l10n.listingsFacing, 'value': (facing as String).replaceAll('_', ' ')});
    }

    if (listing['price_revision_possible'] == true || listing['price_revision_possible'] == 1) {
      details.add({'label': l10n.searchPriceRange, 'value': l10n.listingsNegotiable});
    }

    if (listing['has_debt_or_encumbrance'] == true || listing['has_debt_or_encumbrance'] == 1) {
      final debtAmount = listing['debt_amount'];
      final value = debtAmount != null
          ? l10n.listingsEncumbranceYes((debtAmount as num).toInt())
          : l10n.listingsYes;
      details.add({'label': l10n.listingsEncumbrance, 'value': value});
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.listingsPropertyDetails, style: AppTextStyles.titleSmall),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: context.divider.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(detail['label']!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary500)),
                        Text(detail['value']!, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (index < details.length - 1) const Divider(height: 1, indent: 12, endIndent: 12),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatListingAddress(Map<String, dynamic>? address) {
    if (address == null) return '';
    final parts = <String>[
      address['region'] ?? '',
      address['zone'] ?? '',
      address['woreda'] ?? '',
      address['kebele'] ?? '',
    ];
    return parts.where((p) => p.isNotEmpty).join(' > ');
  }

  Widget _buildSuggestionTile(BuildContext context, OrderSuggestion suggestion, OrderService orderService, AppLocalizations l10n, dynamic order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.primary800.withValues(alpha: 0.3) : AppColors.primary50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.listingTitle ?? 'Listing #${suggestion.listingId}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (suggestion.listingPrice != null)
                  Text(
                    '${_formatPrice(suggestion.listingPrice)} ETB',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary600),
                  ),
                if (suggestion.adminNotes != null && suggestion.adminNotes!.isNotEmpty)
                  Text(
                    suggestion.adminNotes!,
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary500),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (suggestion.isPending)
            _suggestionActionChip(
              l10n.ordersSuggestionsViewDetails,
              AppColors.primary600,
              () => _showSuggestionDetail(context, suggestion, orderService, l10n, order),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: suggestion.isAccepted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                suggestion.isAccepted ? l10n.ordersSuggestionsAccepted : l10n.ordersSuggestionsDeclined,
                style: AppTextStyles.labelSmall.copyWith(
                  color: suggestion.isAccepted ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _suggestionActionChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
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
          overflow: isDescription ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Future<void> _confirmCancel(int orderId, AppLocalizations l10n) async {
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.listingsYes),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(ordersProvider.notifier).cancelOrder(orderId);
      if (mounted) {
        if (success) {
          WaveToast.showSuccess(context, l10n.ordersCancelled);
          Navigator.pop(context);
        } else {
          WaveToast.showError(context, l10n.commonError);
        }
      }
    }
  }

  Widget _buildSkeletonList(int count) {
    return ListView.builder(
      padding: AppSpacing.paddingLg,
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaveGlass(
            child: Container(
              padding: AppSpacing.paddingLg,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _SkeletonBox(width: 60, height: 22),
                    Spacer(),
                    _SkeletonBox(width: 70, height: 22),
                  ]),
                  SizedBox(height: 12),
                  _SkeletonBox(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 200, height: 14),
                  SizedBox(height: 10),
                  Row(children: [
                    _SkeletonBox(width: 120, height: 14),
                    SizedBox(width: 12),
                    _SkeletonBox(width: 100, height: 14),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.primary800 : AppColors.zinc200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
