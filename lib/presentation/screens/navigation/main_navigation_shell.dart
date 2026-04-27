import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';
import '../favorites/favorites_screen.dart';
import '../messages/messages_screen.dart';
import '../settings/settings_screen.dart';
import '../listing/create_listing_screen.dart';
import '../../../l10n/app_localizations.dart';

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  void _onItemTapped(int index) {
    if (index == 2) return; // FAB button
    ref.read(selectedTabProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      const Center(child: Text('')), // Placeholder for FAB
      const MessagesScreen(),
    ];

    // Watch unread messages count
    final unreadMessagesAsync = ref.watch(unreadMessagesCountProvider);
    final unreadMsgCount = unreadMessagesAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.navy950 : AppColors.zinc50,
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
        ),
        backgroundColor: context.cardBg,
        elevation: 12,
        shape: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: AppColors.navy900, size: 30),
            const SizedBox(height: 2),
            Text(
              AppLocalizations.of(context).listingsCreate,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.wave400 : AppColors.navy900,
              ),
            ),
          ],
        ),
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
              _buildNavItem(Icons.favorite_rounded,
                  AppLocalizations.of(context).navFavorites, 1),
              const SizedBox(width: 48), // Space for FAB notch
              _buildMessagesNavItem(unreadMsgCount),
              _buildSettingsNavItem(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? context.textPrimary : context.textMuted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.navy900 : AppColors.zinc500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesNavItem(int unreadCount) {
    final selectedIndex = ref.watch(selectedTabProvider);
    final isSelected = selectedIndex == 3;
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
                  '$unreadCount',
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.wave500,
                textColor: Colors.white,
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: isSelected ? AppColors.navy900 : AppColors.zinc400,
                  size: 26,
                ),
              )
            else
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: isSelected ? AppColors.navy900 : AppColors.zinc400,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).navMessages,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.navy900 : AppColors.zinc500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsNavItem(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              color: AppColors.zinc400,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              AppLocalizations.of(context).navSettings,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.zinc500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
