import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/network/v2/api_v2_error.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/v2/buyer_order.dart';
import '../../../data/models/v2/listing_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_upgrade_card.dart';

class PublicOrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const PublicOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<PublicOrderDetailScreen> createState() =>
      _PublicOrderDetailScreenState();
}

class _PublicOrderDetailScreenState
    extends ConsumerState<PublicOrderDetailScreen> {
  BuyerOrder? _order;
  bool _isLoading = true;
  bool _isVipBlocked = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _isVipBlocked = false;
      _errorMessage = null;
    });

    try {
      final order = await ref
          .read(orderV2ServiceProvider)
          .fetchBrowseOrderDetail(widget.orderId);
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } on ApiV2Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (e.code == 'SUBSCRIPTION_REQUIRED') {
            _isVipBlocked = true;
          } else {
            _errorMessage = e.message;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Could not load order details.';
        });
      }
    }
  }

  Future<void> _makeCall(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isVipBlocked) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(
          title: Text(l10n.ordersDetailTitle),
        ),
        body: Center(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: UpgradeCard(
              icon: Icons.lock_rounded,
              iconColor: AppColors.accent500,
              title: l10n.ordersVipRequiredTitle,
              subtitle: l10n.ordersVipRequiredSubtitle,
              buttonLabel: l10n.ordersViewVipPlans,
              onButtonTap: () => context.push('/subscriptions'),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(title: Text(l10n.ordersDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _order == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(title: Text(l10n.ordersDetailTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: context.theme.textMuted),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Order not found.',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                WaveButton(
                  text: l10n.commonRetryMessage,
                  onPressed: _loadOrder,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = _order!;
    final isCar = order.type == ListingKind.car;
    final isRental = order.listingType == 'rental';
    final buyer = order.buyer;
    final categoryLabel = switch (order.type) {
      ListingKind.car => l10n.listingCar,
      ListingKind.land => l10n.listingLand,
      _ => l10n.listingHouse,
    };
    final intentLabel = isRental ? l10n.listingRent : l10n.listingSale;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(order.title ?? '$categoryLabel $intentLabel'),
      ),
      body: ListView(
        padding: AppSpacing.paddingLg,
        children: [
          // Order Header Summary Card
          WaveCard(
            borderRadius: AppSpacing.borderRadiusLg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$categoryLabel · $intentLabel'.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary600,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      order.status.wireValue.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.title ?? '$categoryLabel $intentLabel',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.ordersBudget,
                  style: AppTextStyles.caption
                      .copyWith(color: context.theme.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  _budgetLabel(order.budget),
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Specifications Section
          WaveCard(
            borderRadius: AppSpacing.borderRadiusLg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.listingSpecifications,
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (!isCar && order.area.hasMin)
                  _specRow(
                    l10n.ordersArea,
                    '${order.area.min?.toInt() ?? 0} - ${order.area.max?.toInt() ?? 0} m²',
                  ),
                if (!isCar && order.holdingType != null)
                  _specRow(l10n.ordersHoldingType, order.holdingType!),
                if (!isCar && order.facingDirection != null)
                  _specRow(l10n.ordersFacing, order.facingDirection!),
                if (isCar && order.vehicleDetails != null) ...[
                  if (order.vehicleDetails!['make'] != null)
                    _specRow(l10n.listingMake,
                        order.vehicleDetails!['make'].toString()),
                  if (order.vehicleDetails!['model'] != null)
                    _specRow(l10n.listingModel,
                        order.vehicleDetails!['model'].toString()),
                  if (order.vehicleDetails!['year_min'] != null)
                    _specRow(
                      l10n.listingYear,
                      '${order.vehicleDetails!['year_min']} - ${order.vehicleDetails!['year_max'] ?? 'Present'}',
                    ),
                  if (order.vehicleDetails!['transmission'] != null)
                    _specRow(
                      l10n.listingTransmission,
                      order.vehicleDetails!['transmission'].toString().toUpperCase(),
                    ),
                ],
                if (order.address != null)
                  _specRow(
                    l10n.listingLocation,
                    order.address!.displayAddress,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description Card
          if (order.description.isNotEmpty) ...[
            WaveCard(
              borderRadius: AppSpacing.borderRadiusLg,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ordersDescription,
                    style: AppTextStyles.titleSmall
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.theme.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Buyer Information Card
          WaveCard(
            borderRadius: AppSpacing.borderRadiusLg,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer Information',
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFCCFBF1),
                      child: Text(
                        (buyer?.displayName.isNotEmpty == true
                                ? buyer!.displayName[0]
                                : 'B')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  buyer?.displayName ?? 'Verified Buyer',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (buyer?.isKycVerified == true) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                              ],
                            ],
                          ),
                          if (buyer?.phoneNumber != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              buyer!.phoneNumber!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.theme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 90), // Space for sticky bottom bar
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: context.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (buyer?.phoneNumber != null) ...[
              Expanded(
                child: WaveButton(
                  icon: Icons.phone_rounded,
                  text: l10n.ordersCallBuyer,
                  onPressed: () => _makeCall(buyer!.phoneNumber),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                onPressed: () => _openWhatsApp(buyer?.phoneNumber),
                tooltip: 'WhatsApp',
              ),
            ] else ...[
              Expanded(
                child: WaveButton(
                  text: l10n.ordersContactBuyer,
                  onPressed: () {
                    if (buyer?.id != null) {
                      context.push('/chat/new?user_id=${buyer!.id}');
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

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: context.theme.textMuted)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: context.theme.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _budgetLabel(OrderRange budget) {
    if (budget.min != null && budget.max != null) {
      return 'ETB ${budget.min!.toInt()} - ${budget.max!.toInt()}';
    }
    if (budget.min != null) return 'ETB ${budget.min!.toInt()}+';
    if (budget.max != null) return 'Up to ETB ${budget.max!.toInt()}';
    return 'Negotiable';
  }
}
