import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../widgets/common/wave_upgrade_card.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../data/services/lead_service.dart';
import '../../../../data/services/listing_service.dart';
import '../../../widgets/common/wave_liquid_glass.dart';
import '../../auth/otp_login_screen.dart';
import '../../subscriptions/subscription_plans_screen.dart';
import '../edit_listing_screen.dart';
import 'listing_contact_form.dart';

class ListingActionButtons extends ConsumerStatefulWidget {
  final Listing listing;

  const ListingActionButtons({super.key, required this.listing});

  @override
  ConsumerState<ListingActionButtons> createState() =>
      _ListingActionButtonsState();
}

class _ListingActionButtonsState extends ConsumerState<ListingActionButtons> {
  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subState = ref.read(subscriptionProvider);

    final authState = ref.read(authStateProvider);
    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;

    final interestStatus = listing.userInterestStatus;
    final hasInterest = interestStatus != null;

    return WaveCard(
      useLiquidGlass: true,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      isGlass: !isDark,
      color: isDark ? AppColors.primary800 : null,
      padding: AppSpacing.paddingLg,
      child: Column(
        children: [
          if (isOwner) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editListing(listing),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(l10n.commonEdit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.theme.divider),
                      foregroundColor:
                          isDark ? AppColors.primary300 : AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteListing(listing),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: Text(l10n.commonDelete),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listing.isFeaturedActive)
              LiquidGlass(
                borderRadius: 8,
                blur: 20,
                tint: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      l10n.listingUpgradeToFeature.replaceFirst('Feature', 'Featured'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _unfeatureListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: Text(
                        'Unfeature',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.stone500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              subState.canFeatureListing
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _featureListing(listing),
                        icon: const Icon(Icons.workspace_premium_outlined, size: 20),
                        label: Text(l10n.listingFeatureThis),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.accent500),
                          foregroundColor: AppColors.accent500,
                        ),
                      ),
                    )
                  : UpgradeCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.accent500,
                      title: l10n.listingUpgradeToFeature,
                      subtitle: l10n.subscriptionRequiredFeatureSubtitle,
                    ),
            const SizedBox(height: 12),
            if (listing.isVipActive)
              LiquidGlass(
                borderRadius: 8,
                blur: 20,
                tint: AppColors.vip,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.vip),
                    const SizedBox(width: 8),
                    Text(
                      l10n.markAsVip,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.vip,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _unvipListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: Text(
                        'Un-VIP',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.stone500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _vipListing(listing),
                  icon: const Icon(Icons.diamond_outlined, size: 20),
                  label: Text(l10n.markAsVip),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.vip),
                    foregroundColor: AppColors.vip,
                  ),
                ),
              ),
          ],
          Row(
            children: [
              if (!isOwner && !hasInterest)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: listing.interestBlocked
                      ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()))
                      : () => _submitInterest(listing.id),
                    icon: Icon(listing.interestBlocked ? Icons.lock_outline : Icons.handyman_outlined, size: 20),
                    label: Text(listing.interestBlocked ? l10n.upgradeToContact : l10n.listingsImInterested),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.accent500),
                      foregroundColor: AppColors.accent600,
                    ),
                  ),
                ),
              if (!isOwner && hasInterest)
              Expanded(
                child: LiquidGlass(
                  borderRadius: 8,
                  blur: 20,
                  tint: _getInterestStatusColor(listing.userInterestStatus),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getInterestStatusIcon(listing.userInterestStatus),
                          size: 20,
                          color: _getInterestStatusColor(
                              listing.userInterestStatus),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getInterestStatusText(
                              listing.userInterestStatus, l10n),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _getInterestStatusColor(
                                listing.userInterestStatus),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          ListingContactForm(
            listing: listing,
            isOwner: isOwner,
          ),
        ],
      ),
    );
  }

  Color _getInterestStatusColor(String? status) {
    switch (status) {
      case 'new':
        return AppColors.warning;
      case 'won':
        return AppColors.emerald600;
      case 'lost':
        return AppColors.error;
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getInterestStatusIcon(String? status) {
    switch (status) {
      case 'new':
        return Icons.hourglass_empty;
      case 'won':
        return Icons.check_circle;
      case 'lost':
        return Icons.cancel;
      default:
        return Icons.trending_up;
    }
  }

  String _getInterestStatusText(String? status, AppLocalizations l10n) {
    switch (status) {
      case 'new':
        return l10n.listingsInterestPending;
      case 'won':
        return l10n.listingsInterestAccepted;
      case 'lost':
        return l10n.listingsInterestRejected;
      default:
        return status ?? '';
    }
  }

  Future<void> _submitInterest(int listingId, [String? message]) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);

    try {
      final service = LeadService();
      final response = await service.expressInterest(
        listingId: listingId,
        message: message?.isNotEmpty == true
            ? message
            : l10n.listingsDefaultInterestMessage,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: AppColors.success),
          );
          ref.read(listingDetailProvider.notifier).loadListing(listingId);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _editListing(Listing listing) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditListingScreen(listing: listing)),
    );
    if (result == true && mounted) {
      ref.read(listingDetailProvider.notifier).loadListing(listing.id);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listingDeleteConfirmTitle),
        content: Text(l10n.listingDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final service = ListingService();
      final result = await service.deleteListing(listing.id);
      if (result.success && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _vipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.markAsVipTitle),
        content: Text(l10n.markAsVipMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.markAsVip),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.vipListing(listing.id);
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.success),
        );
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _unvipListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove VIP Status?'),
        content: const Text('Your listing will no longer be a VIP listing. You can mark it as VIP again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove VIP'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.unvipListing(listing.id);
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.success),
        );
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _featureListing(Listing listing) async {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canFeatureListing) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
        );
      }
      return;
    }

    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${l10n.listingFeatureThis}?'),
        content: const Text('Your listing will be featured on the home page and search results for 30 days.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.listingFeatureNow),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.featureListing(listing.id);
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.success),
        );
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _unfeatureListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unfeature Listing?'),
        content: const Text('Your listing will no longer appear as featured. You can feature it again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unfeature'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final service = ListingService();
      final result = await service.unfeatureListing(listing.id);
      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.success),
        );
        ref.read(listingDetailProvider.notifier).loadListing(listing.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).commonError), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
