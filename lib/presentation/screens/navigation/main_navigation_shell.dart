import 'package:flutter/material.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../account/account_screen.dart';
import '../listing/create_listing_screen.dart';
import '../settings/settings_screen.dart';
import '../kyc/kyc_verification_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/wave_dialog.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  bool _isCreatingListing = false;

  void _onItemTapped(int index) {
    if (index == 2) return; // FAB button
    ref.read(selectedTabProvider.notifier).state = index;
  }

  /// Pre-flight check before opening Create Listing — KYC then Subscription
  Future<void> _onCreateListingTap() async {
    setState(() => _isCreatingListing = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(kycStatusProvider.notifier).loadKycStatus();
      if (!mounted) return;
      final kycState = ref.read(kycStatusProvider);
      final subState = ref.read(subscriptionProvider);
      final settingsAsync = ref.read(appSettingsProvider);
      final subscriptionEnabled = settingsAsync.maybeWhen(
        data: (data) => data['subscription_enabled'] == true,
        orElse: () => false,
      );

      // 1 — Check KYC first
      if (!kycState.isVerified && !kycState.isApproved) {
        final kycAction = kycState.isPending ? null : l10n.kycVerifyNow;
        final goKyc = await WaveDialog.showUpgrade(
          context: context,
          icon: Icons.verified_outlined,
          iconColor: AppColors.accent500,
          title: l10n.kycRequiredTitle,
          message: kycState.isPending
              ? l10n.kycPendingSubtitleReview
              : l10n.kycRequiredSubtitlePost,
          actionLabel: kycAction,
        );
        if (goKyc == true && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KycVerificationScreen()),
          );
        }
        return;
      }

      // 2 — Check subscription (only if enabled globally)
      if (subscriptionEnabled && !subState.canCreateListing) {
        String message;
        if (!subState.hasPaidSubscription) {
          message = l10n.subscriptionRequiredListingSubtitle;
        } else {
          final plan = subState.subscription?.plan;
          if (plan == null || plan.maxListings == 0) {
            message = l10n.subscriptionPlanNotSupportedListing;
          } else {
            message = l10n.subscriptionLimitReached;
          }
        }
        final goSub = await WaveDialog.showUpgrade(
          context: context,
          icon: Icons.add_home_work_outlined,
          iconColor: AppColors.accent500,
          title: l10n.subscriptionRequiredTitle,
          message: message,
          actionLabel: l10n.listingViewPlans,
        );
        if (goSub == true && mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
          );
        }
        return;
      }

      // All good — open the create screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingListing = false);
    }
  }

  /// Shows a styled access-gate dialog.
  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final screens = [
      const HomeScreen(),
      const OrdersScreen(),
      const Center(child: Text('')), // Placeholder for FAB
      const NotificationsScreen(),
      const AccountScreen(),
    ];

    // Watch unread notifications count
    final unreadNotifCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: context.isDarkMode ? AppColors.primary900 : AppColors.primary50,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateListingTap,
        backgroundColor: AppColors.emerald600,
        elevation: 12,
        shape: const CircleBorder(),
        child: _isCreatingListing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: context.sheetBg,
        elevation: 20,
        padding: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  Icons.home_rounded, AppLocalizations.of(context).navHome, 0),
              _buildNavItem(Icons.receipt_long_outlined,
                  AppLocalizations.of(context).navOrders, 1),
              const SizedBox(width: 48), // Space for FAB notch
              _buildNotificationsNavItem(unreadNotifCount),
              _buildNavItem(Icons.person_outline,
                  AppLocalizations.of(context).navSettings, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.accent600 : (isDark ? AppColors.primary600 : AppColors.primary300),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary900 : (isDark ? AppColors.primary600 : AppColors.primary300),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsNavItem(int unreadCount) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == 3;
    final displayCount = unreadCount > 99 ? '99+' : '$unreadCount';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unreadCount > 0)
              Badge(
                label: Text(
                  displayCount,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: unreadCount > 99 ? 8 : 10,
                  ),
                ),
                backgroundColor: AppColors.accent600,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.notifications_outlined,
                  color: isSelected ? AppColors.accent600 : (isDark ? AppColors.primary600 : AppColors.primary300),
                  size: 26,
                ),
              )
            else
              Icon(
                Icons.notifications_outlined,
                color: isSelected ? AppColors.accent600 : (isDark ? AppColors.primary600 : AppColors.primary300),
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).settingsNotifications,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primary900 : (isDark ? AppColors.primary600 : AppColors.primary300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
