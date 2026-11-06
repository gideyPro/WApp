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
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/v2_providers.dart';
import '../../../data/car_data.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../../widgets/status_helpers.dart';

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
  bool _isStartingChat = false;
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
          _errorMessage = AppLocalizations.of(context).ordersDetailError;
        });
      }
    }
  }

  /// Leave the paywall, refresh entitlements, then retry the gated detail.
  Future<void> _openVipPlans() async {
    await context.push('/subscriptions');
    if (!mounted) return;
    ref.read(subscriptionProvider.notifier).refresh();
    _loadOrder();
  }

  Future<void> _startChat() async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }

    if (_isStartingChat) return;
    setState(() => _isStartingChat = true);

    try {
      final l10n = AppLocalizations.of(context);
      final result = await ref
          .read(messageServiceProvider)
          .startOrderConversation(orderId: widget.orderId);

      if (!mounted) return;

      if (result.success && result.conversation != null) {
        await context.push(
          '/chat/${result.conversation!.id}',
          extra: result.conversation,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message.isNotEmpty ? result.message : l10n.commonError,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isStartingChat = false);
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
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
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
              onButtonTap: _openVipPlans,
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
                  _errorMessage ?? l10n.ordersDetailError,
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
    final isCar = order.isCar;
    final isRental = order.isRental;
    final buyer = order.buyer;
    final categoryLabel = orderTypeLabel(order.type, l10n);
    final intentLabel = isRental ? l10n.listingRent : l10n.listingSale;
    final headline = orderHeadline(order, l10n);
    final areaLabel = orderAreaLabel(order.area, l10n);
    final vehicleYear = vehicleYearLabel(order, l10n);
    final buyerName = buyer?.name ??
        (buyer?.isKycVerified == true
            ? l10n.ordersVerifiedBuyer
            : l10n.ordersBuyer);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(headline),
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
                    Expanded(
                      child: Text(
                        '$categoryLabel · $intentLabel'.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary600,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      statusLabel(order.status.wireValue, l10n).toUpperCase(),
                      style: TextStyle(
                        color: statusColor(order.status.wireValue),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  headline,
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
                  orderBudgetLabel(order.budget, l10n),
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
                  isCar ? l10n.ordersVehicleCriteria : l10n.listingSpecifications,
                  style: AppTextStyles.titleSmall
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (!isCar && areaLabel.isNotEmpty)
                  _specRow(l10n.ordersArea, areaLabel),
                if (!isCar && order.holdingType != null)
                  _specRow(
                    l10n.ordersHoldingType,
                    holdingTypeLabel(order.holdingType!, l10n),
                  ),
                if (!isCar && order.facingDirection != null)
                  _specRow(
                    l10n.ordersFacing,
                    facingDirectionLabel(order.facingDirection!, l10n),
                  ),
                if (isCar) ...[
                  if (order.vehicleMake != null)
                    _specRow(l10n.listingMake, order.vehicleMake!),
                  if (order.vehicleModel != null)
                    _specRow(l10n.listingModel, order.vehicleModel!),
                  if (vehicleYear.isNotEmpty)
                    _specRow(l10n.listingYear, vehicleYear),
                  if (order.vehicleBodyType != null)
                    _specRow(
                      l10n.listingBodyType,
                      bodyTypeLabel(order.vehicleBodyType!, l10n),
                    ),
                ],
                if (order.address != null)
                  _specRow(
                    l10n.listingLocation,
                    order.address!.displayAddressFor(l10n.localeName),
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
                  l10n.ordersBuyerInformation,
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
                        buyerName[0].toUpperCase(),
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
                                  buyerName,
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
            // In-app chat works for every VIP viewer because the backend
            // resolves the buyer from the order id.
            Expanded(
              child: WaveButton(
                icon: Icons.chat_bubble_outline_rounded,
                text: l10n.ordersChatBuyer,
                onPressed: _isStartingChat ? null : _startChat,
                isLoading: _isStartingChat,
              ),
            ),
            if (buyer?.phoneNumber != null) ...[
              const SizedBox(width: 10),
              IconButton.filledTonal(
                icon: const Icon(Icons.phone_rounded),
                onPressed: () => _makeCall(buyer?.phoneNumber),
                tooltip: l10n.ordersCallBuyer,
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                icon: const Icon(Icons.chat_rounded),
                onPressed: () => _openWhatsApp(buyer?.phoneNumber),
                tooltip: 'WhatsApp',
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
}
