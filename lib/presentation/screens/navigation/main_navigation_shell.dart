import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_colors.dart';
import '../listing/widgets/create_listing_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/car_providers.dart';
import '../../providers/job_providers.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../account/account_screen.dart';
import '../../../l10n/app_localizations.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  final bool _isCreatingListing = false;
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

  Future<void> _showCreateListingSheet() async {
    final created = await showCreateListingSheet(context);
    if (created == true && mounted) {
      ref.read(listingsProvider.notifier).loadListings();
      ref.read(carListingsProvider.notifier).loadListings();
      ref.read(homeCarListingsProvider.notifier).loadListings();
      ref.read(jobListingsProvider.notifier).loadListings();
      ref.read(homeJobListingsProvider.notifier).loadListings();
      ref.read(subscriptionProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final l10n = AppLocalizations.of(context);
    final screens = [
      const HomeScreen(),
      const OrdersScreen(),
      const Center(child: Text('')), // Placeholder for FAB
      const NotificationsScreen(),
      const AccountScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        backgroundColor:
            context.isDarkMode ? AppColors.oceanicNavyDark : AppColors.stone50,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
        floatingActionButton: Semantics(
          button: true,
          label: l10n.listingsCreate,
          child: Tooltip(
            message: l10n.listingsCreate,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientNavyEmerald,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent500.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _showCreateListingSheet,
                  child: Center(
                    child: _isCreatingListing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded,
                            color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: context.isDarkMode ? AppColors.cardNavyDark : Colors.white,
          elevation: 16,
          padding: EdgeInsets.zero,
          surfaceTintColor: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, l10n.navHome, 0),
                _buildNavItem(Icons.receipt_long_outlined, l10n.navOrders, 1),
                const SizedBox(width: 48), // Space for FAB notch
                _buildNavItem(
                    Icons.notifications_outlined, l10n.settingsNotifications, 3,
                    badgeCount: ref.watch(unreadCountProvider)),
                _buildNavItem(Icons.person_outline, l10n.navSettings, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {int? badgeCount}) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = AppColors.accent500;
    final inactiveColor = isDark ? AppColors.stone400 : AppColors.stone500;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badgeCount != null && badgeCount > 0
                ? Badge(
                    label: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: badgeCount > 99 ? 8 : 10,
                      ),
                    ),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    child: Icon(
                      icon,
                      color: isSelected ? activeColor : inactiveColor,
                      size: 24,
                    ),
                  )
                : Icon(
                    icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.primary900)
                    : inactiveColor,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.accent500,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
