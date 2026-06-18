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
import '../../providers/transaction_tracker.dart';
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
  String _selectedCurrency = 'ETB';
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
      ref.read(subscriptionProvider.notifier).refresh(currency: _selectedCurrency);
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
    ref.read(subscriptionProvider.notifier).refresh();
    _checkPendingTransaction();
  }

  Future<void> _checkPendingTransaction() async {
    final tracker = ref.read(transactionTrackerProvider.notifier);
    final status = await tracker.checkLatestStatus();
    if (!mounted || status == null) return;
    if (status == 'success') {
      tracker.clear();
      ref.read(subscriptionProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionPaymentSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (status == 'failed' || status == 'cancelled') {
      tracker.clear();
    }
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

    SubscriptionPlan? featuredPlan;
    if (activePlans.any((p) => !p.isFree)) {
      featuredPlan = activePlans.where((p) => !p.isFree).reduce((a, b) {
        final aOrder = a.sortOrder ?? a.price.toInt();
        final bOrder = b.sortOrder ?? b.price.toInt();
        return aOrder >= bOrder ? a : b;
      });
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                // Currency toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCurrencyTab('ETB'),
                      _buildCurrencyTab('USD'),
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
                        isFeatured: plan == featuredPlan,
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

  Widget _buildCurrencyTab(String currency) {
    final isSelected = _selectedCurrency == currency;
    return GestureDetector(
      onTap: () {
        if (isSelected) return;
        setState(() => _selectedCurrency = currency);
        ref.read(subscriptionProvider.notifier).refresh(currency: currency);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          currency,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primary900 : AppColors.primary400,
          ),
        ),
      ),
    );
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
      // 1. Start the payment API call (Chapa initialize — takes 1-3s)
      final paymentFuture = _subscriptionService.processPayment(
        planId: plan.id,
        paymentData: {
          'payment_method': 'chapa',
          'currency': _selectedCurrency,
        },
      );

      // Completer so the poll timer can trigger activation inside the WebView
      final activateCompleter = Completer<String>();

      // 2. Open WebView IMMEDIATELY with urlFuture — no waiting for Chapa
      final webViewFuture = Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WaveWebViewPage(
            urlFuture: paymentFuture.then((r) {
              if (!r.success || r.checkoutUrl == null) {
                throw Exception(r.message);
              }
              return r.checkoutUrl!;
            }),
            title: l10n.subscriptionsSubscribe,
            onActivate: (txRef) async {
              final response = await _subscriptionService.activateSubscription(txRef: txRef);
              if (response.success) {
                ref.read(transactionTrackerProvider.notifier).resolve(plan.id);
              }
            },
            externalTxRef: activateCompleter,
          ),
        ),
      );

      // 3. Wait for payment response to get txRef
      String? resolvedTxRef;
      try {
        final paymentResponse = await paymentFuture;
        resolvedTxRef = paymentResponse.txRef;
        if (resolvedTxRef != null) {
          ref.read(transactionTrackerProvider.notifier).track(plan.id, txRef: resolvedTxRef);
        }
      } catch (_) {
        // Payment init failed — WebView handles it via urlFuture rejection
      }

      if (!mounted) {
        _paymentPollTimer?.cancel();
        return;
      }

      // 4. Poll every 1s while WebView is open
      bool webViewClosed = false;
      _paymentPollTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        if (resolvedTxRef == null) return;

        final rawStatus = await _subscriptionService.verifyPaymentStatus(resolvedTxRef);
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        final status = rawStatus?.toLowerCase() ?? 'pending';

        if (status == 'success') {
          timer.cancel();
          webViewClosed = true;
          // Tell WebView to show "Activating..." and activate before closing
          if (!activateCompleter.isCompleted) {
            activateCompleter.complete(resolvedTxRef);
          }
        } else if (status.contains('fail') || status.contains('cancel') || status == 'abandoned' || status == 'voided') {
          timer.cancel();
          webViewClosed = true;
          // Don't pop if URL redirect already triggered activation
          if (!activateCompleter.isCompleted && mounted) {
            Navigator.of(context).pop('failed');
          }
        }
      });

      // 5. Wait for WebView to close
      final result = await webViewFuture;

      _paymentPollTimer?.cancel();
      _paymentPollTimer = null;
      webViewClosed = true;

      if (!mounted) return;

      // Resolve completer if WebView closed before poll triggered it
      if (result == 'success' && resolvedTxRef != null && !activateCompleter.isCompleted) {
        ref.read(transactionTrackerProvider.notifier).resolve(plan.id);
      }

      // Handle Failures & Retries
      if (result == 'failed' || result == 'technical_failure') {
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
        }
        return;
      }

      if (result == null || result == 'cancelled' || result == 'closed' || result == 'done') {
        // User closed WebView before payment completed
        ref.read(transactionTrackerProvider.notifier).resolve(plan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionsPaymentPending),
            backgroundColor: AppColors.primary800,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // result is 'success' — activation already done inside WebView via onActivate
      ref.read(subscriptionProvider.notifier).refresh(currency: _selectedCurrency);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.subscriptionPaymentSuccess), backgroundColor: AppColors.success));
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
  final bool isFeatured;
  final bool isLoading;
  final String selectedCurrency;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isFeatured,
    this.isLoading = false,
    required this.selectedCurrency,
    required this.onSelect,
  });

  bool get _isFree => plan.isFree;
  bool get _hasDiscount => plan.priceInfo?.hasDiscount ?? false;

  String _discountLabel(AppLocalizations l10n) {
    final pct = plan.priceInfo?.discountPercentage?.toInt() ?? 0;
    if (plan.priceInfo?.isUpgrade == true) {
      return l10n.subscriptionsUpgradeOff(pct);
    }
    return l10n.subscriptionsPromoOff(pct);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isFeatured
        ? AppColors.accent500
        : isCurrentPlan
            ? AppColors.accent300
            : isDark
                ? const Color(0xFF334155)
                : AppColors.primary200;
    final borderWidth = isFeatured ? 2.0 : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isFeatured
                ? AppColors.accent500.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: isFeatured ? 24 : 12,
            offset: Offset(0, isFeatured ? 8 : 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark, l10n),
          _buildBody(context, isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, AppLocalizations l10n) {
    final colors = context.theme;
    final textColor = isFeatured ? Colors.white : colors.textPrimary;
    final mutedColor = isFeatured ? Colors.white70 : colors.textSecondary;
    final isFeaturedOrCurrent = isFeatured || isCurrentPlan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: isFeatured ? AppColors.gradientAccent : null,
        color: isFeatured
            ? null
            : isCurrentPlan
                ? AppColors.accent50
                : null,
        border: !isFeatured
            ? const Border(
                bottom: BorderSide(color: AppColors.primary100, width: 1),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrentPlan)
            _buildOutlineBadge(l10n.subscriptionsCurrentPlan,
                isFeatured ? Colors.white : AppColors.accent700)
          else if (isFeatured)
            _buildOutlineBadge('RECOMMENDED', Colors.white),
          if (isFeaturedOrCurrent) const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: textColor,
                      ),
                    ),
                    if (plan.description != null &&
                        plan.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          plan.description!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            color: mutedColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildPriceBlock(textColor, mutedColor, l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineBadge(String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPriceBlock(Color textColor, Color mutedColor, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_hasDiscount)
          Text(
            plan.getDisplayPrice(selectedCurrency),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.lineThrough,
              color: mutedColor,
            ),
          ),
        Text(
          _hasDiscount
              ? _formatDiscountedPrice()
              : plan.getDisplayPrice(selectedCurrency),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: textColor,
          ),
        ),
        Text(
          plan.durationLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: mutedColor,
          ),
        ),
        if (_hasDiscount) ...[
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
              _discountLabel(l10n),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDiscountedPrice() {
    final priceInfo = plan.priceInfo;
    if (priceInfo == null) return plan.getDisplayPrice(selectedCurrency);
    final price = priceInfo.discounted;
    if (selectedCurrency == 'USD') return '\$${price.toStringAsFixed(2)}';
    return 'ETB ${price.toStringAsFixed(0)}';
  }

  Widget _buildBody(BuildContext context, bool isDark, AppLocalizations l10n) {
    final colors = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComparisonRow(context, l10n.subscriptionsListings,
              '${plan.maxListings}', Icons.home_outlined, true),
          _buildDivider(),
          _buildComparisonRow(
            context,
            l10n.subscriptionsFeaturedListings,
            plan.maxFeaturedListings > 0 ? '${plan.maxFeaturedListings}' : '—',
            Icons.star_border,
            plan.maxFeaturedListings > 0,
          ),
          _buildDivider(),
          _buildComparisonRow(context, l10n.subscriptionsVipAccess,
              plan.viewVip ? '✓' : '—', Icons.diamond, plan.viewVip),
          if (plan.maxContacts > 0) ...[
            _buildDivider(),
            _buildComparisonRow(context, l10n.subscriptionsContactViews,
                '${plan.maxContacts}', Icons.contact_phone_outlined, true),
          ],
          if (plan.features != null && plan.features!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDivider(),
            const SizedBox(height: 16),
            Text(
              l10n.subscriptionsFeatures,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...plan.features!.map((f) => _buildFeatureRow(f, isDark)),
          ],
          const SizedBox(height: 20),
          _buildTrustSignal(l10n.subscriptionsPoweredByChapa),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: WaveButton(
              text: isCurrentPlan
                  ? l10n.subscriptionsCurrentPlan
                  : _isFree
                      ? l10n.subscriptionsSelectPlan
                      : l10n.subscriptionsSubscribe,
              icon: isCurrentPlan
                  ? Icons.check_circle
                  : _isFree
                      ? Icons.check
                      : Icons.arrow_forward,
              isLoading: isLoading && !isCurrentPlan,
              onPressed: isCurrentPlan ? null : onSelect,
              variant:
                  isCurrentPlan ? ButtonVariant.outline : ButtonVariant.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(BuildContext context, String label, String value,
      IconData icon, bool enabled) {
    final colors = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: enabled ? FontWeight.w600 : FontWeight.w500,
                color: enabled ? colors.textPrimary : colors.textMuted,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: enabled ? colors.textPrimary : colors.textMuted,
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

  Widget _buildFeatureRow(String feature, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isDark ? AppColors.accent400 : AppColors.accent500,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.3,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.primary800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustSignal(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline,
            size: 12,
            color: AppColors.primary500.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          message,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary500.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
