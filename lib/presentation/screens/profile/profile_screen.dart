import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_card.dart';
import '../auth/otp_login_screen.dart';
import '../kyc/kyc_verification_screen.dart';
import '../../../../l10n/app_localizations.dart';

/// Profile Screen - Only profile-related content (personal info, KYC, stats)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context);
    ref.watch(authStateProvider);

    if (profileState.isLoading && profileState.user == null) {
      ref.read(profileProvider.notifier).loadProfile();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.primary900 : AppColors.primary50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.primary900 : Colors.white,
        title: Text(l10n.profileTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider.notifier).loadProfile();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            _buildProfileHeader(context, ref, profileState, isDark),
            const SizedBox(height: 24),

            // Stats
            _buildStatsRow(context, profileState, isDark),
            const SizedBox(height: 24),

            // Account Actions
            _buildMenuSection(
              context,
              title: l10n.settingsSectionAuth,
              items: [
                _MenuItemData(
                  icon: Icons.verified_user_outlined,
                  title: l10n.profileKyc,
                  subtitle: profileState.user?.isKycVerified == true
                      ? l10n.profileKycStatusVerified
                      : l10n.profileKycStatusRequired,
                  badge: profileState.user?.isKycVerified == true
                      ? null
                      : l10n.profileKycStatusRequired,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const KycVerificationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout, size: 20),
                label: Text(l10n.authLogout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, WidgetRef ref, ProfileState state, [bool isDark = false]) {
    final l10n = AppLocalizations.of(context);
    if (state.isLoading) {
      return const SizedBox(
        height: 72,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null) {
      return WaveMessageScreen.error(
        isEmbedded: true,
        title: 'Error Loading Profile',
        subtitle: state.errorMessage!,
        onRetry: () {
          ref.read(profileProvider.notifier).loadProfile();
        },
      );
    }

    final user = state.user;
    if (user == null) {
      return WaveEmptyState(
        icon: Icons.person_outline,
        title: l10n.profileNotLoggedIn,
        subtitle: l10n.profileLoginPrompt,
      );
    }

    final initials = user.initials.isNotEmpty ? user.initials : '?';
    final displayName = user.fullName.isNotEmpty ? user.fullName : 'User';
    final phoneOrEmail = user.phoneNumber.isNotEmpty
        ? user.phoneNumber
        : user.email ?? 'No contact info';

    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.accent500,
            borderRadius: BorderRadius.circular(18),
          ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.headline4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: AppTextStyles.title,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                phoneOrEmail,
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Verification Status Badges
              Row(
                children: [
                  _buildVerificationBadge(
                    context,
                    icon: Icons.phone,
                    label: l10n.profileVerificationPhone,
                    isVerified: user.isPhoneVerified,
                  ),
                  const SizedBox(width: 8),
                  _buildVerificationBadge(
                    context,
                    icon: Icons.verified_user,
                    label: l10n.profileVerificationKyc,
                    isVerified: user.isKycVerified,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.emerald50 : AppColors.zinc100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isVerified ? AppColors.emerald200 : AppColors.zinc200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            size: 11,
            color: isVerified ? AppColors.emerald600 : AppColors.zinc400,
          ),
          const SizedBox(width: 3),
          Text(
            isVerified ? '$label ✓' : label,
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isVerified ? AppColors.emerald700 : AppColors.zinc500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ProfileState state, [bool isDark = false]) {
    final stats = state.stats;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        _buildStatItem(
          value: stats?.totalListings.toString() ?? '-',
          label: l10n.profileStatsListings,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          value: stats?.unreadMessages.toString() ?? '-',
          label: l10n.profileStatsMessages,
          isDark: isDark,
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          value: stats?.totalFavorites.toString() ?? '-',
          label: l10n.profileStatsFavorites,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatItem({required String value, required String label, bool isDark = false}) {
    return Expanded(
      child: WaveCard(
        isGlass: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headline4.copyWith(
                color: AppColors.accent600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.zinc400 : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required List<_MenuItemData> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.zinc500,
            ),
          ),
        ),
        WaveCard(
          isGlass: true,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildMenuItem(item,
                  showDivider: index < items.length - 1);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItemData item, {bool showDivider = true}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: AppColors.primary600,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(item.subtitle!, style: AppTextStyles.caption)
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right,
                color: AppColors.zinc400,
              ),
            ],
          ),
          onTap: item.onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authLogout),
        content: Text(l10n.authLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
                  (route) => false,
                );
              }
            },
            child:
                Text(l10n.authLogout, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    required this.onTap,
  });
}
