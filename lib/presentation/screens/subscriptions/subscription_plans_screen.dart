import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/services/subscription_service.dart';
import '../../../../data/services/payment_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';

/// Subscription Plans Screen
class SubscriptionPlansScreen extends ConsumerStatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  ConsumerState<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState
    extends ConsumerState<SubscriptionPlansScreen> {
  final SubscriptionServiceApi _subscriptionService = SubscriptionServiceApi();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessingPayment = false;
  
  AppLocalizations get l10n => AppLocalizations.of(context);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentSubscriptionProvider.notifier).loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final currentSub = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).subscriptionsTitle),
      ),
      body: plansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => WaveErrorBanner(
          message: error.toString(),
          onRetry: () => ref.invalidate(subscriptionPlansProvider),
        ),
        data: (plans) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(subscriptionPlansProvider);
            await ref
                .read(currentSubscriptionProvider.notifier)
                .loadCurrentSubscription();
          },
          child: _buildBody(plans, currentSub),
        ),
      ),
    );
  }

  Widget _buildBody(dynamic plans, CurrentSubscriptionState currentSub) {
    final activePlans = plans.where((p) => p.isActive).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current subscription banner
          if (currentSub.subscription != null &&
              currentSub.subscription.isActive)
            _buildCurrentSubscriptionBanner(currentSub),

          const SizedBox(height: 8),

          // Plans header
          if (activePlans.isNotEmpty) ...[
            Text(
              l10n.subscriptionsChoosePlan,
              style: AppTextStyles.headline4,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.subscriptionsSelectPlanSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.navy600,
              ),
            ),
            const SizedBox(height: 24),

            // Plans list
            ...activePlans.map((plan) => _PlanCard(
                  plan: plan,
                  isCurrentPlan: currentSub.subscription?.planId == plan.id &&
                      currentSub.subscription.isActive,
                  isLoading: _isProcessingPayment,
                  onSelect: () => _selectPlan(plan),
                )),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Text(
                'No active subscription plans available at this time.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.zinc500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionBanner(CurrentSubscriptionState state) {
    final sub = state.subscription;
    final plan = sub?.plan;

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
              Text(
                '${l10n.subscriptionsCurrentPlan}: ${plan?.name ?? l10n.commonUnknown}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatPill(
                icon: Icons.home,
                label: '${state.canCreateListing ? '✓' : '✗'} ${l10n.subscriptionsListings}',
              ),
              const SizedBox(width: 8),
              _buildStatPill(
                icon: Icons.star_border,
                label: '${state.canFeatureListing ? '✓' : '✗'} ${l10n.listingFeatured}',
              ),
              if (sub != null && sub.daysRemaining < 999) ...[
                const SizedBox(width: 8),
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

  Widget _buildStatPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
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

  Future<void> _selectPlan(dynamic plan) async {
    if (_isProcessingPayment) return;

    // For free plans, activate directly
    if (plan.isFree) {
      setState(() => _isProcessingPayment = true);
      try {
        final response = await _subscriptionService.activateSubscription();
        if (mounted) {
          if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.subscriptionsFreeSuccess),
              backgroundColor: AppColors.success,
            ),
          );
            ref
                .read(currentSubscriptionProvider.notifier)
                .loadCurrentSubscription();
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
          setState(() => _isProcessingPayment = false);
        }
      }
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      // First, try to subscribe via subscription service (which returns checkout URL)
      final response = await _subscriptionService.subscribe(plan.id);

      if (!mounted) return;

      if (response.success && response.checkoutUrl != null) {
        // Open checkout URL in browser
        final uri = Uri.parse(response.checkoutUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.subscriptionsPaymentBrowserMessage),
                backgroundColor: AppColors.wave500,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.subscriptionsPaymentBrowserError),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else if (response.success) {
        // Fallback: initialize payment via payment service
        final paymentResponse = await _paymentService.initializePayment(
          paymentType: 'subscription',
          amount: plan.price ?? 0.0,
          relatedId: plan.id,
        );

        if (mounted &&
            paymentResponse.success &&
            paymentResponse.checkoutUrl != null) {
          final uri = Uri.parse(paymentResponse.checkoutUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResponse.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } else {
        if (mounted) {
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
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.subscriptionsPaymentError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }
}

/// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final dynamic plan;
  final bool isCurrentPlan;
  final bool isLoading;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    this.isLoading = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = plan.isFree;
    final isPopular = plan.slug == 'basic' || plan.slug == 'premium';
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? AppColors.wave400
              : isPopular
                  ? AppColors.wave200
                  : AppColors.zinc200,
          width: isCurrentPlan || isPopular ? 2 : 1,
        ),
        boxShadow: isPopular ? AppColors.shadowWave : AppColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentPlan
                  ? AppColors.wave50
                  : isPopular
                      ? AppColors.wave50
                      : Colors.transparent,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: AppTextStyles.title.copyWith(
                              color: isCurrentPlan
                                  ? AppColors.wave700
                                  : AppColors.navy900,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.wave500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.subscriptionsPopular,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          if (isCurrentPlan) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.emerald500,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.subscriptionsCurrent,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
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
                      plan.displayPrice,
                      style: AppTextStyles.headline3.copyWith(
                        color: isCurrentPlan
                            ? AppColors.wave600
                            : AppColors.navy900,
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
                const SizedBox(height: 8),
                _buildFeatureRow(
                  icon: Icons.star_border,
                  label: plan.maxFeaturedListings != null
                      ? '${plan.maxFeaturedListings} ${l10n.subscriptionsFeaturedListings}'
                      : l10n.subscriptionsNoFeaturedListings,
                  included: plan.maxFeaturedListings != null &&
                      plan.maxFeaturedListings! > 0,
                ),
                const SizedBox(height: 16),

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
