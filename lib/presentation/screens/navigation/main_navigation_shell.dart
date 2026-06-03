import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../l10n/app_localizations.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  bool _isCreatingListing = false;
  DateTime? _lastBackPressTime;

  void _onItemTapped(int index) {
    if (index == 2) return; // FAB button
    ref.read(selectedTabProvider.notifier).state = index;
    if (index == 4) {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(kycStatusProvider.notifier).loadKycStatus();
    }
  }

  void _onBackPressed() {
    final selectedIndex = ref.read(selectedTabProvider);
    if (selectedIndex != 0) {
      ref.read(selectedTabProvider.notifier).state = 0;
      return;
    }
    final now = DateTime.now();
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPressTime = now;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonPressBackAgain),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Navigate to Create Listing — inline gates handled inside the screen
  Future<void> _onCreateListingTap() async {
    setState(() => _isCreatingListing = true);
    try {
      if (mounted) {
        await Navigator.of(context).push(
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
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
