import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/ethiopian_date_helper.dart';
import '../../../../data/services/subscription_service.dart';
import '../../../../data/models/subscription.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_webview_page.dart';
import '../../../../l10n/app_localizations.dart';

/// Subscription Plans Screen
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> with RouteAware {
  final SubscriptionServiceApi _subscriptionService = SubscriptionServiceApi();
  int? _processingPlanId;
  late final String _selectedCurrency;
  final GlobalKey _plansKey = GlobalKey();
  Timer? _paymentPollTimer;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authStateProvider);
    final phone = authState.user?.phoneNumber ?? authState.phoneNumber ?? '';
    _selectedCurrency = phone.startsWith('+251') ? 'ETB' : 'USD';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _paymentPollTimer?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    // This is called when the top route has been popped off, 
    // and this route shows up.
    debugPrint('SubscriptionPlansScreen: didPopNext - refreshing subscription');
    ref.read(subscriptionProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final subState = ref.watch(subscriptionProvider);

    return Scaffold(
      appBar: WaveAppBar(
        title: Text(AppLocalizations.of(context).subscriptionsTitle),
      ),
      body: _buildContent(subState),
    );
  }

  Widget _buildContent(SubscriptionState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.plans.isEmpty) {
      return WaveMessageScreen.error(
        title: l10n.errorSubscription,
        subtitle: state.errorMessage!,
        onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
        isEmbedded: true,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(subscriptionProvider.notifier).refresh(),
      child: _buildBody(state),
    );
  }

  Widget _buildBody(SubscriptionState state) {
    final activePlans = state.plans.where((p) => p.isActive).toList();
    final subscription = state.subscription;
    final isActiveSub = subscription != null && subscription.isActive;

    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current subscription banner (if any)
          if (subscription != null) ...[
              if (isActiveSub)
                _buildCurrentSubscriptionBanner(
                  subscription,
                  state.canCreateListing,
                  state.canFeatureListing,
                  state.canViewVip,
                  contactViewsUsed: state.contactViewsUsed,
                  contactViewsRemaining: state.contactViewsRemaining,
                )
            else
              _buildInactiveSubscriptionBanner(
                subscription,
                state.canCreateListing,
                state.canFeatureListing,
                state.canViewVip,
              ),
            const SizedBox(height: 8),
          ],

          // Plans header
          if (activePlans.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.subscriptionsChoosePlan,
                        style: AppTextStyles.headline4,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.subscriptionsSelectPlanSubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Plans list
            Container(
              key: _plansKey,
              child: Column(
                children: [
                  ...activePlans.map((SubscriptionPlan plan) => _PlanCard(
                        plan: plan,
                        isCurrentPlan: subscription?.planId == plan.id &&
                            (subscription?.isActive ?? false),
                        isLoading: _processingPlanId == plan.id,
                        selectedCurrency: _selectedCurrency,
                        onSelect: () => _selectPlan(plan),
                      )),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.subscriptionsNoPlansAvailable,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.stone500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionBanner(
    Subscription sub,
    bool canCreateListing,
    bool canFeatureListing,
    bool canViewVip, {
    int contactViewsUsed = 0,
    int contactViewsRemaining = 0,
  }) {
    final localPlan = sub.plan;
    if (localPlan == null) return const SizedBox.shrink();

    final showDaysLeft = sub.daysRemaining < 999;
    final isUrgent = sub.daysRemaining <= 7;
    final hasVip = localPlan.viewVip;
    final hasFeatures = localPlan.features != null && localPlan.features!.isNotEmpty;
    final showContactBar = contactViewsUsed + contactViewsRemaining > 0;

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: AppColors.gradientAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: plan name + days-left pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.star, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.subscriptionsCurrentPlan}: ${localPlan.name}',
                      style: AppTextStyles.bodyLargePlus.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sub.endsAt != null)
                      Text(
                        l10n.subscriptionsExpiresOn(_formatDate(sub.endsAt!)),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (showDaysLeft)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 12,
                        color: isUrgent ? AppColors.error : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.subscriptionsDaysLeft(sub.daysRemaining),
                        style: AppTextStyles.caption.copyWith(
                          color: isUrgent ? AppColors.error : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // VIP chip (visually distinct row, before features)
          if (hasVip) ...[
            const SizedBox(height: 12),
            _buildVipChip(),
          ],
          // Feature chips
          if (hasFeatures) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ...?localPlan.features
                    ?.take(4)
                    .map((feature) => _buildFeatureChip(feature)),
              ],
            ),
          ],
          const SizedBox(height: 18),
          // All usage bars (rendered when the plan defines a max)
          if (localPlan.maxListings > 0)
            _buildUsageBar(
              label: l10n.subscriptionsListings,
              used: sub.listingsUsed,
              max: localPlan.maxListings,
              icon: Icons.home_work_outlined,
            ),
          if (localPlan.maxListings > 0 && localPlan.maxFeaturedListings > 0)
            const SizedBox(height: 12),
          if (localPlan.maxFeaturedListings > 0)
            _buildUsageBar(
              label: l10n.subscriptionsFeaturedListings,
              used: sub.featuredListingsUsed,
              max: localPlan.maxFeaturedListings,
              icon: Icons.star_outline,
            ),
          if ((localPlan.maxFeaturedListings > 0) && (localPlan.maxOrders > 0))
            const SizedBox(height: 12),
          if (localPlan.maxOrders > 0)
            _buildUsageBar(
              label: l10n.subscriptionsOrders,
              used: sub.ordersUsed,
              max: localPlan.maxOrders,
              icon: Icons.receipt_long_outlined,
            ),
          if ((localPlan.maxOrders > 0) && showContactBar)
            const SizedBox(height: 12),
          if (showContactBar)
            _buildUsageBar(
              label: l10n.subscriptionsContactViews,
              used: contactViewsUsed,
              max: contactViewsUsed + contactViewsRemaining,
              icon: Icons.visibility_outlined,
            ),
          // Manage / Upgrade CTA
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    final ctx = _plansKey.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(
                        color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    l10n.subscriptionsManage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar({
    required String label,
    required int used,
    required int max,
    required IconData icon,
  }) {
    final ratio = max > 0 ? used / max : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final displayMax = max > 0 ? max : (used > 0 ? used : 1);
    final progressColor = clampedRatio >= 0.9
        ? AppColors.error
        : clampedRatio >= 0.7
            ? AppColors.amber
            : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '$used / $displayMax',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedRatio,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  Widget _buildVipChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            l10n.subscriptionsVipAccess,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            feature,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveSubscriptionBanner(
    Subscription sub,
    bool canCreateListing,
    bool canFeatureListing,
    bool canViewVip,
  ) {
    final localPlan = sub.plan;
    if (localPlan == null) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.stone100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.stone300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sub.isCancelled ? Icons.cancel : Icons.info_outline,
                color: AppColors.stone600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${sub.getStatusLabel(l10n)} Plan: ${localPlan.name}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.primary900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (sub.endsAt != null) ...[
            const SizedBox(height: 8),
            Text(
              sub.isCancelled
                  ? l10n.subscriptionsCancelledOn(
                      _formatDate(sub.cancelledAt ?? sub.endsAt!))
                  : l10n.subscriptionsExpiredOn(_formatDate(sub.endsAt!)),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.stone600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: WaveButton(
              text: l10n.subscriptionsSubscribe,
              icon: Icons.refresh,
              variant: ButtonVariant.primary,
              isLoading: _processingPlanId != null && _processingPlanId == localPlan.id,
              onPressed: () => _selectPlan(localPlan),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).languageCode;
    return EthiopianDateHelper.formatDual(date, locale);
  }

  Future<void> _selectPlan(SubscriptionPlan plan) async {
    if (_processingPlanId != null) return;

    // For free plans, activate directly
    if (plan.isFree) {
      setState(() => _processingPlanId = plan.id);
      try {
        // Backend handles free plan activation in the subscribe method
        final response = await _subscriptionService.subscribe(plan.id);
        if (mounted) {
          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionsFreeSuccess), backgroundColor: AppColors.success));
            ref.read(subscriptionProvider.notifier).refresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message), backgroundColor: AppColors.error));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionUnexpectedError(e.toString())), backgroundColor: AppColors.error));
        }
      } finally {
        if (mounted) {
          setState(() => _processingPlanId = null);
        }
      }
      return;
    }

    setState(() => _processingPlanId = plan.id);

    try {
      // Process payment - initializes Chapa on backend and gets checkoutUrl
      final paymentResponse = await _subscriptionService.processPayment(
        planId: plan.id,
        paymentData: {
          'payment_method': 'chapa',
          'currency': _selectedCurrency,
        },
      );

      if (!mounted) return;

      if (!paymentResponse.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(paymentResponse.message), backgroundColor: AppColors.error));
        }
        return;
      }

      final checkoutUrl = paymentResponse.checkoutUrl;
      if (checkoutUrl == null) {
        throw Exception('Failed to get checkout URL');
      }
      final txRef = paymentResponse.txRef;

      // Open WebView for payment (polling starts after WebView opens)
      final webViewFuture = Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WaveWebViewPage(
            url: checkoutUrl,
            title: l10n.subscriptionsSubscribe,
          ),
        ),
      );

      // Start polling for payment status in parallel with the WebView
      bool webViewClosed = false;
      _paymentPollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        final status = await _subscriptionService.getLatestPaymentStatus();
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        if (status == 'failed' || status == 'cancelled') {
          timer.cancel();
          webViewClosed = true;
          if (mounted) {
            Navigator.of(context).pop(status);
          }
        }
      });

      final result = await webViewFuture;

      // Stop polling
      _paymentPollTimer?.cancel();
      _paymentPollTimer = null;
      webViewClosed = true;

      if (!mounted) return;

      // Handle Failures & Retries
      if (result == 'retry' || result == 'failed' || result == 'technical_failure') {
        final failureTitle = result == 'technical_failure'
            ? l10n.errorConnection
            : l10n.subscriptionPaymentFailedTitle;
        final failureSubtitle = result == 'technical_failure'
            ? l10n.subscriptionTechnicalFailureSubtitle
            : l10n.subscriptionPaymentFailedSubtitle;

        final retryAction = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WaveMessageScreen.error(
              title: failureTitle,
              subtitle: failureSubtitle,
              onRetry: () => Navigator.of(context).pop('retry'),
              onAction: () => Navigator.of(context).pop('cancelled'),
            ),
          ),
        );

        if (retryAction == 'retry') {
          setState(() => _processingPlanId = null);
          _selectPlan(plan);
          return;
        }
        return;
      }

      if (result == 'cancelled' || result == 'closed') {
        // User closed WebView before payment - show pending state
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionsPaymentPending),
            backgroundColor: AppColors.primary800,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Explicitly activate subscription via backend verify + activate
      bool activated = false;
      if (txRef != null) {
        final activationResponse = await _subscriptionService.activateSubscription(txRef: txRef);
        activated = activationResponse.success;
      }

      // Refresh subscription to get latest status
      await ref.read(subscriptionProvider.notifier).refresh();
      final subState = ref.read(subscriptionProvider);
      final isActive = subState.subscription?.isActive == true;

      if (!mounted) return;

      if (activated || isActive) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionPaymentSuccess), backgroundColor: AppColors.success));
        }
      } else {
        // Fallback: check payment status directly in case webhook will arrive soon
        final paymentStatus = await _subscriptionService.getLatestPaymentStatus();
        if (paymentStatus == 'pending') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionPaymentSuccess), backgroundColor: AppColors.success));
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionPaymentNotVerified), backgroundColor: AppColors.error));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionUnexpectedError(e.toString())), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) {
        setState(() => _processingPlanId = null);
      }
    }
  }
}

/// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isCurrentPlan;
  final bool isLoading;
  final String selectedCurrency;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    this.isLoading = false,
    required this.selectedCurrency,
    required this.onSelect,
  });

  String _formatDiscountedPrice(SubscriptionPlan plan, String currency) {
    final price = plan.priceInfo!.discounted;
    if (currency == 'USD') {
      return '\$${price.toStringAsFixed(2)}';
    }
    return 'ETB ${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = plan.isFree;
    final isPopular = plan.slug == 'basic' || plan.slug == 'premium';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final hasDiscount = plan.priceInfo != null && plan.priceInfo!.hasDiscount;

    final cardColor = isDark ? AppColors.primary800 : Colors.white;
    final borderColor = isPopular || isCurrentPlan
        ? AppColors.accent500
        : (isDark ? AppColors.primary700 : AppColors.primary200);
    final borderWidth = isPopular ? 2.0 : 1.5;
    final cardShadow = isPopular
        ? [
            BoxShadow(
              color: AppColors.accent500.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ]
        : null;

    Widget card = Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSm),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            context: context,
            isPopular: isPopular,
            isFree: isFree,
            isCurrent: isCurrentPlan,
            hasDiscount: hasDiscount,
            l10n: l10n,
          ),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.description != null && plan.description!.isNotEmpty) ...[
                  Text(
                    plan.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: context.theme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildComparisonRow(
                  context,
                  icon: Icons.home_outlined,
                  label: l10n.subscriptionsListings,
                  value: '${plan.maxListings}',
                ),
                _buildDivider(),
                _buildComparisonRow(
                  context,
                  icon: Icons.star_border,
                  label: l10n.subscriptionsFeaturedListings,
                  value: plan.maxFeaturedListings > 0
                      ? '${plan.maxFeaturedListings}'
                      : '—',
                  enabled: plan.maxFeaturedListings > 0,
                ),
                _buildDivider(),
                _buildComparisonRow(
                  context,
                  icon: Icons.diamond,
                  label: l10n.subscriptionsVipAccess,
                  value: plan.viewVip ? '✓' : '—',
                  enabled: plan.viewVip,
                ),
                if (plan.maxContacts > 0) ...[
                  _buildDivider(),
                  _buildComparisonRow(
                    context,
                    icon: Icons.contact_phone_outlined,
                    label: l10n.subscriptionsContactViews,
                    value: '${plan.maxContacts}',
                  ),
                ],
                if (plan.features != null && plan.features!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _buildDivider(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.subscriptionsFeatures,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: context.theme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...plan.features!.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: isPopular
                                  ? AppColors.accent500
                                  : AppColors.primary500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: context.theme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: AppSpacing.lg),
                _buildTrustSignal(l10n.subscriptionsPoweredByChapa),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: WaveButton(
                    text: isCurrentPlan
                        ? l10n.subscriptionsCurrentPlan
                        : isFree
                            ? l10n.subscriptionsSelectPlan
                            : l10n.subscriptionsSubscribe,
                    icon: isCurrentPlan
                        ? Icons.check_circle
                        : isFree
                            ? Icons.check
                            : Icons.arrow_forward,
                    isLoading: isLoading && !isCurrentPlan,
                    onPressed: isCurrentPlan ? null : onSelect,
                    variant: isCurrentPlan
                        ? ButtonVariant.outline
                        : ButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isPopular && !isCurrentPlan) {
      card = Stack(
        children: [
          card,
          Positioned(
            top: 0,
            right: 0,
            child: _buildPopularRibbon(l10n),
          ),
        ],
      );
    }

    return card;
  }

  Widget _buildHeader({
    required BuildContext context,
    required bool isPopular,
    required bool isFree,
    required bool isCurrent,
    required bool hasDiscount,
    required AppLocalizations l10n,
  }) {
    if (isPopular) {
      return Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.lg),
        decoration: const BoxDecoration(
          gradient: AppColors.gradientAccent,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.borderRadiusSm - 2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTierLabel('MOST POPULAR', Colors.white),
            const SizedBox(height: AppSpacing.sm),
            Text(
              plan.name,
              style: AppTextStyles.headline2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildPriceBlock(textColor: Colors.white, mutedColor: Colors.white70, l10n: l10n),
          ],
        ),
      );
    }

    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.accent50,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.borderRadiusSm - 1),
          ),
          border: Border(
            bottom: BorderSide(color: AppColors.accent200, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTierLabel('CURRENT PLAN', AppColors.accent700),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    plan.name,
                    style: AppTextStyles.headline3.copyWith(
                      color: AppColors.accent800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _buildPriceBlock(
              textColor: AppColors.accent800,
              mutedColor: AppColors.accent700,
              l10n: l10n,
            ),
          ],
        ),
      );
    }

    // Free / standard
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTierLabel(isFree ? 'FREE' : 'STANDARD',
                    context.theme.textMuted),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  plan.name,
                  style: AppTextStyles.headline3.copyWith(
                    color: context.theme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _buildPriceBlock(
            textColor: context.theme.textPrimary,
            mutedColor: context.theme.textMuted,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildTierLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.6,
        color: color,
      ),
    );
  }

  Widget _buildPriceBlock({
    required Color textColor,
    required Color mutedColor,
    required AppLocalizations l10n,
  }) {
    final hasDiscount = plan.priceInfo != null && plan.priceInfo!.hasDiscount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (hasDiscount) ...[
          Text(
            plan.getDisplayPrice(selectedCurrency),
            style: AppTextStyles.bodySmall.copyWith(
              decoration: TextDecoration.lineThrough,
              color: mutedColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          hasDiscount
              ? _formatDiscountedPrice(plan, selectedCurrency)
              : plan.getDisplayPrice(selectedCurrency),
          style: AppTextStyles.priceLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        Text(
          plan.durationLabel,
          style: AppTextStyles.caption.copyWith(
            color: mutedColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: plan.priceInfo!.isUpgrade
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppColors.success,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              plan.priceInfo!.isUpgrade
                  ? l10n.subscriptionsUpgradeOff(
                      plan.priceInfo!.discountPercentage?.toInt() ?? 0)
                  : l10n.subscriptionsPromoOff(
                      plan.priceInfo!.discountPercentage?.toInt() ?? 0),
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPopularRibbon(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.accent600,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSpacing.borderRadiusSm - 2),
          bottomLeft: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            l10n.subscriptionsPopular,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.accent600 : AppColors.stone400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: enabled
                    ? context.theme.textPrimary
                    : context.theme.textMuted,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyLargePlus.copyWith(
              color: enabled
                  ? context.theme.textPrimary
                  : context.theme.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.primary100.withValues(alpha: 0.5),
    );
  }

  Widget _buildTrustSignal(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 12,
          color: AppColors.primary500.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          message,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary500.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
