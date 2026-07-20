import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../messages/messages_screen.dart';
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

  void _showCreateListingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.home_work_outlined, color: context.theme.textSecondary),
              title: Text('Property', style: TextStyle(color: context.theme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/listings/create');
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car_outlined, color: context.theme.textSecondary),
              title: Text('Vehicle', style: TextStyle(color: context.theme.textPrimary)),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/cars/create');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final screens = [
      const HomeScreen(),
      const OrdersScreen(),
      const Center(child: Text('')), // Placeholder for FAB
      const MessagesScreen(),
      const AccountScreen(),
    ];

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
        body: Column(
          children: [
            _buildNotificationHeader(unreadNotifCount),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateListingSheet,
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
                _buildNavItem(Icons.home_rounded, AppLocalizations.of(context).navHome, 0),
                _buildNavItem(Icons.receipt_long_outlined, AppLocalizations.of(context).navOrders, 1),
                const SizedBox(width: 48), // Space for FAB notch
                _buildNavItem(Icons.chat_bubble_outline_rounded, AppLocalizations.of(context).navMessages, 3),
                _buildNavItem(Icons.person_outline, AppLocalizations.of(context).navSettings, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(int unreadCount) {
    if (unreadCount == 0) return const SizedBox(height: 0);
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 4,
          bottom: 4,
          left: 16,
          right: 16,
        ),
        color: AppColors.accent600,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Badge(
              label: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: unreadCount > 99 ? 8 : 10,
                ),
              ),
              backgroundColor: Colors.white,
              textColor: AppColors.accent600,
              child: const Icon(Icons.notifications, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).settingsNotifications,
              style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
            ),
          ],
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
}
