import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/services/subscription_service.dart';
import '../../../../data/models/subscription.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_chip.dart';
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

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
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
      appBar: AppBar(
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
        title: 'Subscription Error',
        subtitle: state.errorMessage!,
        onRetry: () => ref.read(subscriptionProvider.notifier).refresh(),
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
      padding: const EdgeInsets.all(16),
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
              )
            else
              _buildInactiveSubscriptionBanner(
                subscription,
                state.canCreateListing,
                state.canFeatureListing,
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
                          color: AppColors.navy600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildCurrencySwitch(),
              ],
            ),
            const SizedBox(height: 24),

            // Plans list
            ...activePlans.map((SubscriptionPlan plan) => _PlanCard(
                  plan: plan,
                  isCurrentPlan: subscription?.planId == plan.id &&
                      (subscription?.isActive ?? false),
                  isLoading: _processingPlanId == plan.id,
                  selectedCurrency: _selectedCurrency,
                  onSelect: () => _selectPlan(plan),
                )),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                l10n.subscriptionsNoPlansAvailable,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.zinc500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionBanner(
      Subscription sub, bool canCreateListing, bool canFeatureListing) {
    final localPlan = sub.plan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWave,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.subscriptionsCurrentPlan}: ${localPlan?.name ?? l10n.commonUnknown}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (sub.endsAt != null)
                      Text(
                        l10n.subscriptionsExpiresOn(_formatDate(sub.endsAt!)),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (localPlan != null)
            Builder(builder: (context) {
              final localFeatures = localPlan.features;
              if (localFeatures!.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: localFeatures!
                      .take(4) // Limit to first 4 features to avoid overflow
                      .map((feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  feature,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              );
            }),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatPill(
                icon: Icons.home,
                label: l10n.subscriptionsListings,
                included: canCreateListing,
              ),
              _buildStatPill(
                icon: Icons.star_border,
                label: l10n.listingFeatured,
                included: canFeatureListing,
              ),
              if (sub.daysRemaining < 999) ...[
                _buildStatPill(
                  icon: Icons.timer,
                  label: l10n.subscriptionsDaysLeft(sub.daysRemaining),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveSubscriptionBanner(
    Subscription sub,
    bool canCreateListing,
    bool canFeatureListing,
  ) {
    final localPlan = sub.plan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.zinc300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                sub.isCancelled ? Icons.cancel : Icons.info_outline,
                color: AppColors.zinc600,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${sub.statusLabel} Plan: ${localPlan?.name ?? l10n.commonUnknown}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.navy900,
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
                color: AppColors.zinc600,
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
              isLoading: _processingPlanId != null && _processingPlanId == localPlan?.id,
              onPressed: () {
                if (localPlan != null) {
                  _selectPlan(localPlan);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    bool? included,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            included != null
                ? (included ? Icons.check_circle : Icons.cancel)
                : icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.subscriptionsFreeSuccess),
                backgroundColor: AppColors.success,
              ),
            );
            ref.read(subscriptionProvider.notifier).refresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
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
        WaveToast.showError(context, paymentResponse.message);
        return;
      }

      final checkoutUrl = paymentResponse.checkoutUrl;
      if (checkoutUrl == null) {
        throw Exception('Failed to get checkout URL');
      }

      // Start polling for payment status - 1s interval for instant feedback
      Timer? paymentCheckTimer;
      bool webViewClosed = false;

      paymentCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        final status = await _subscriptionService.getLatestPaymentStatus();
        if (!mounted || webViewClosed) {
          timer.cancel();
          return;
        }

        // If payment failed or cancelled, handle it
        if (status == 'failed' || status == 'cancelled') {
          timer.cancel();
          webViewClosed = true;
          
          if (mounted) {
            // Close WebView if it's still open
            Navigator.of(context).pop(status);
          }
        }
      });

      // Open WebView for payment
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WaveWebViewPage(
            url: checkoutUrl,
            title: l10n.subscriptionsSubscribe,
          ),
        ),
      );

      // Stop polling
      paymentCheckTimer?.cancel();
      webViewClosed = true;

      if (!mounted) return;

      // Handle Failures & Retries
      if (result == 'retry' || result == 'failed' || result == 'technical_failure') {
        final failureTitle = result == 'technical_failure' 
            ? 'Connection Error' 
            : 'Payment Failed';
        final failureSubtitle = result == 'technical_failure'
            ? 'The payment gateway could not be reached. Please check your connection.'
            : 'Your transaction was not completed. Would you like to try again?';

        final retryAction = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WaveMessageScreen.error(
              title: failureTitle,
              subtitle: failureSubtitle,
              actionLabel: 'Retry Payment',
            ),
          ),
        );

        if (retryAction == 'retry' || retryAction == true || retryAction == 'Continue') {
          setState(() => _processingPlanId = null);
          _selectPlan(plan); // RE-START FRESH
          return;
        }
        return;
      }
      
      if (result == 'cancelled' || result == 'closed') {
        return;
      }

      // Check payment status from API
      final paymentStatus = await _subscriptionService.getLatestPaymentStatus();
      
      // Refresh subscription to get latest status
      await ref.read(subscriptionProvider.notifier).refresh();
      final subState = ref.read(subscriptionProvider);
      final isActive = subState.subscription?.isActive == true;

      if (!mounted) return;

      if (!isActive && paymentStatus != 'pending') {
        WaveToast.showError(context, 'Your payment could not be verified.');
      } else {
        // Payment successful
        WaveToast.showSuccess(context, 'Payment successful!');
      }
    } catch (e) {
      if (mounted) {
        WaveToast.showError(context, 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _processingPlanId = null);
      }
    }
  }
  Widget _buildCurrencySwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.zinc100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCurrencyToggleItem('ETB'),
          _buildCurrencyToggleItem('USD'),
        ],
      ),
    );
  }

  Widget _buildCurrencyToggleItem(String currency) {
    final isSelected = _selectedCurrency == currency;
    return GestureDetector(
      onTap: () => setState(() => _selectedCurrency = currency),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          currency,
          style: TextStyle(
            color: isSelected ? AppColors.wave600 : AppColors.zinc600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final isFree = plan.isFree;
    final isPopular = plan.slug == 'basic' || plan.slug == 'premium';
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        border: Border.all(
          color: isCurrentPlan
              ? AppColors.wave400
              : isPopular
                  ? AppColors.wave200
                  : AppColors.zinc200,
          width: isCurrentPlan || isPopular ? 2 : 1,
        ),
        boxShadow: isCurrentPlan || isPopular ? AppColors.shadowWave : AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isCurrentPlan
                  ? AppColors.wave50
                  : isPopular
                      ? AppColors.wave50
                      : Colors.transparent,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppSpacing.borderRadiusLg)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.title.copyWith(
                              color: isCurrentPlan
                                  ? AppColors.wave700
                                  : AppColors.navy900,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isPopular)
                            WaveChip(
                              label: l10n.subscriptionsPopular,
                              variant: ChipVariant.featured,
                              size: ChipSize.small,
                            ),
                          if (isCurrentPlan)
                            WaveChip(
                              label: l10n.subscriptionsCurrent,
                              variant: ChipVariant.current,
                              size: ChipSize.small,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        plan.description ?? '',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.navy600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.getDisplayPrice(selectedCurrency),
                      style: AppTextStyles.headline3.copyWith(
                        color: isCurrentPlan ? AppColors.wave600 : AppColors.navy900,
                      ),
                    ),
                    Text(
                      plan.durationLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.navy500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Features
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureRow(
                  icon: Icons.home_outlined,
                  label: '${plan.maxListings} ${l10n.subscriptionsListings}',
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildFeatureRow(
                  icon: Icons.star_border,
                  label: plan.maxFeaturedListings != null
                      ? '${plan.maxFeaturedListings} ${l10n.subscriptionsFeaturedListings}'
                      : l10n.subscriptionsNoFeaturedListings,
                  included: plan.maxFeaturedListings != null &&
                      plan.maxFeaturedListings! > 0,
                ),
                // Additional features from JSON (if any)
                if (plan.features != null && plan.features!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.subscriptionsFeatures,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.navy800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...plan.features!.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: AppColors.wave500),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                feature,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.navy700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Action button
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
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String label,
    bool included = true,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: included ? AppColors.wave600 : AppColors.zinc400,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: included ? AppColors.navy700 : AppColors.zinc500,
            fontWeight: included ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
