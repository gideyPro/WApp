import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chapasdk/chapasdk.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../data/services/subscription_service.dart';
import '../../../../data/models/subscription.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_button.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../settings/settings_screen.dart';

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
  int? _processingPlanId;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionProvider.notifier).refresh();
    });
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
      return WaveErrorBanner(
        message: state.errorMessage!,
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
            ...activePlans.map((SubscriptionPlan plan) => _PlanCard(
                  plan: plan,
                  isCurrentPlan: subscription?.planId == plan.id &&
                      (subscription?.isActive ?? false),
                  isLoading: _processingPlanId == plan.id,
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
            ref
                .read(subscriptionProvider.notifier)
                .refresh();
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
      // Initiate payment for mobile SDK - gets tx_ref without calling Chapa
      final paymentResponse = await _subscriptionService.initiatePayment(
        planId: plan.id,
      );

      if (!mounted) return;

      if (!paymentResponse.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResponse.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Free plan - already activated
      if (paymentResponse.requiresPayment == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(paymentResponse.message),
              backgroundColor: AppColors.success,
            ),
          );
          ref.read(subscriptionProvider.notifier).refresh();
        }
        return;
      }

      // Paid plan - get tx_ref for Chapa SDK
      final txRef = paymentResponse.txRef;
      if (txRef == null) {
        throw Exception('Failed to get transaction reference');
      }

      // Get Chapa Public Key from backend settings
      final settings = await ref.read(appSettingsProvider.future);
      final publicKey = settings['chapa_public_key'];
      
      if (publicKey == null || publicKey.toString().isEmpty) {
        throw Exception('Chapa public key not found in settings');
      }

      // Get current user details
      final authState = ref.read(authStateProvider);
      final user = authState.user;
      
      // Format phone number to 10 digits (e.g., 0912345678)
      String formattedPhone = user?.phoneNumber ?? '0900000000';
      // Remove non-digits
      formattedPhone = formattedPhone.replaceAll(RegExp(r'\D'), '');
      // If it starts with 251, remove it
      if (formattedPhone.startsWith('251')) {
        formattedPhone = formattedPhone.substring(3);
      }
      // Ensure it starts with 0
      if (!formattedPhone.startsWith('0')) {
        formattedPhone = '0$formattedPhone';
      }
      // Limit to 10 digits
      if (formattedPhone.length > 10) {
        formattedPhone = formattedPhone.substring(0, 10);
      }
      
      // Start Native Payment Flow
      if (!mounted) return;
      
      // Debug logging for Chapa parameters
      debugPrint('Initializing Chapa with:');
      debugPrint('Public Key: $publicKey');
      debugPrint('Amount: ${plan.price}');
      debugPrint('TX Ref: $txRef');
      debugPrint('Email: ${user?.email ?? '${formattedPhone}@wavemart.et'}');
      debugPrint('Phone: $formattedPhone');
      
      Chapa.paymentParameters(
        context: context,
        publicKey: publicKey.toString(),
        amount: plan.price.toString(),
        currency: 'ETB',
        txRef: txRef,
        email: user?.email ?? '${formattedPhone}@wavemart.et',
        phone: formattedPhone,
        firstName: user?.firstName ?? 'Customer',
        lastName: user?.lastName ?? 'User',
        title: 'WaveMart Subscription',
        desc: '${plan.name} Plan',
        nativeCheckout: true,
        buttonColor: AppColors.wave600,
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: const ['telebirr', 'cbebirr', 'mpesa', 'ebirr'],
        namedRouteFallBack: '',
        onPaymentFinished: (message, reference, amount) async {
          // message can be: "paymentSuccessful", "paymentFailed", "paymentCancelled"
          debugPrint('Chapa payment finished - message: $message, reference: $reference, amount: $amount');
          
          if (message == 'paymentSuccessful') {
            final activateResponse = await _subscriptionService.activateSubscription(
              txRef: reference ?? txRef,
            );
            if (mounted) {
              if (activateResponse.success) {
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
                    content: Text(activateResponse.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          } else if (message == 'paymentFailed') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment failed. Please try again.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
          // paymentCancelled - do nothing
        },
      );
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
        boxShadow: isPopular ? AppColors.shadowWave : AppColors.shadowSm,
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              plan.name,
                              style: AppTextStyles.title.copyWith(
                                color: isCurrentPlan
                                    ? AppColors.wave700
                                    : AppColors.navy900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isPopular) ...[
                            const SizedBox(width: AppSpacing.sm),
                            WaveChip(
                              label: l10n.subscriptionsPopular,
                              variant: ChipVariant.featured,
                              size: ChipSize.small,
                            ),
                          ],
                          if (isCurrentPlan) ...[
                            const SizedBox(width: AppSpacing.sm),
                            WaveChip(
                              label: l10n.subscriptionsCurrent,
                              variant: ChipVariant.current,
                              size: ChipSize.small,
                            ),
                          ],
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
