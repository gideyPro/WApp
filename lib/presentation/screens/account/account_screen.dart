import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../kyc/kyc_verification_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';
import '../listing/my_listings_screen.dart';
import '../favorites/favorites_screen.dart';
import '../payments/payment_history_screen.dart';
import '../help/help_center_screen.dart';
import '../messages/messages_screen.dart';
import '../auth/otp_login_screen.dart';
import '../../widgets/common/wave_glass.dart';
import '../settings/settings_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authStateProvider);
    final kycState = ref.watch(kycStatusProvider);
    final localeCode = ref.watch(localeProvider).locale?.languageCode;
    final settingsAsync = ref.watch(appSettingsProvider);
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );

    final l10n = AppLocalizations.of(context);
    final user = profileState.user ?? authState.user;

    final initials = user?.initials.isNotEmpty == true
        ? user!.initials
        : l10n.commonAppInitials;
    final fullName = (user?.fullName.isNotEmpty ?? false)
        ? user!.fullName
        : l10n.commonUser;
    final phone = (user?.phoneNumber.isNotEmpty ?? false)
        ? user!.phoneNumber
        : (user?.email ?? l10n.commonNA);

    String kycLabel = l10n.settingsKycRequired;
    Color kycColor = AppColors.warning;
    if (user?.isKycVerified == true || kycState.isVerified || kycState.isApproved) {
      kycLabel = l10n.settingsKycVerified;
      kycColor = AppColors.emerald600;
    } else if (kycState.isPending) {
      kycLabel = l10n.settingsKycPending;
      kycColor = AppColors.warning;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider.notifier).loadProfile();
          ref.invalidate(appSettingsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Gradient hero banner
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient background
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [AppColors.primary950, AppColors.primary900]
                            : [AppColors.primary900, AppColors.primary700],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accent500.withValues(alpha: 0.15),
                                  AppColors.accent500.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -20,
                          left: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.06),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating profile card
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: -40,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: AppColors.shadowPremium,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: WaveGlass(
                        borderRadius: 16,
                        blur: 15,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 24),
                          child: Row(
                            children: [
                              // Avatar with Gradient Ring
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.gradientHero,
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: AppTextStyles.headline3.copyWith(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (user?.isKycVerified == true ||
                                      kycState.isVerified ||
                                      kycState.isApproved)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent500,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            fullName,
                                            style: AppTextStyles.title.copyWith(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: context.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (user?.isKycVerified == true ||
                                            kycState.isVerified ||
                                            kycState.isApproved) ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.verified_rounded,
                                            color: AppColors.accent500,
                                            size: 18,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      phone,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: context.textSecondary,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spacer for the floating card overlap
            const SliverToBoxAdapter(
              child: SizedBox(height: 56),
            ),

            // Stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.divider,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildStatItem(
                        context,
                        icon: Icons.home_work_outlined,
                        value: profileState.stats?.totalListings.toString() ?? '0',
                        label: l10n.profileStatsListings,
                        valueColor: context.textPrimary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const MyListingsScreen()),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: context.divider,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.favorite_border_rounded,
                        value: profileState.stats?.totalFavorites.toString() ?? '0',
                        label: l10n.profileStatsFavorites,
                        valueColor: context.textPrimary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: context.divider,
                      ),
                      _buildStatItem(
                        context,
                        icon: Icons.verified_user_outlined,
                        value: kycLabel,
                        label: l10n.profileVerificationKyc,
                        valueColor: kycColor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const KycVerificationScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            // Menu sections
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuSection(
                      context,
                      title: l10n.settingsSectionAccount,
                      items: [
                        _MenuItemData(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: l10n.navMessages,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MessagesScreen()),
                          ),
                        ),
                        if (subscriptionEnabled) ...[
                          _MenuItemData(
                            icon: Icons.payment_outlined,
                            title: l10n.profileSubscriptions,
                            subtitle: l10n.settingsSubscriptionsSubtitle,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                              );
                              if (mounted) ref.read(subscriptionProvider.notifier).refresh();
                            },
                          ),
                          _MenuItemData(
                            icon: Icons.receipt_long_outlined,
                            title: l10n.profilePayments,
                            subtitle: l10n.settingsPaymentsSubtitle,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
                            ),
                          ),
                        ],
                        _MenuItemData(
                          icon: Icons.verified_user_outlined,
                          title: l10n.profileKyc,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const KycVerificationScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      context,
                      title: l10n.settingsPreferences,
                      items: [
                        _MenuItemData(
                          icon: Icons.language,
                          title: l10n.settingsLanguage,
                          subtitle: _getCurrentLanguageName(context, localeCode),
                          onTap: () => _showLanguageSelectionDialog(context, ref),
                        ),
                        _MenuItemData(
                          icon: Icons.dark_mode_outlined,
                          title: l10n.settingsDarkMode,
                          subtitle: _getDarkModeSubtitle(context, ref),
                          onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      context,
                      title: l10n.settingsSectionSupport,
                      items: [
                        _MenuItemData(
                          icon: Icons.help_outline,
                          title: l10n.profileHelp,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.settingsPrivacyPolicy,
                          onTap: () => _openWebPage(context, 'https://wavemart.et/privacy', l10n.settingsPrivacyPolicy),
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          title: l10n.settingsTermsOfService,
                          onTap: () => _openWebPage(context, 'https://wavemart.et/terms', l10n.settingsTermsOfService),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenuSection(
                      context,
                      title: '',
                      items: [
                        _MenuItemData(
                          icon: Icons.logout,
                          title: l10n.authLogout,
                          textColor: AppColors.error,
                          onTap: () => _showLogoutConfirmation(context, ref),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 20, color: context.textSecondary),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: valueColor ?? AppColors.accent600,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.eyebrow.copyWith(
                color: context.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        WaveGlass(
          borderRadius: 8,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildMenuItem(item, showDivider: index < items.length - 1);
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.theme.isDark ? AppColors.primary800 : AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: item.textColor ?? context.theme.icon,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: item.textColor ?? context.textPrimary,
            ),
          ),
          subtitle: item.subtitle != null
              ? Text(item.subtitle!, style: AppTextStyles.caption.copyWith(color: context.textSecondary))
              : null,
          trailing: Icon(Icons.chevron_right, color: ThemeColors(context).iconSecondary),
          onTap: item.onTap,
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.authLogout,
                style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.authLogoutConfirm,
                style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: context.theme.divider),
                        foregroundColor: context.theme.textPrimary,
                      ),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(dialogContext);
                        await ref.read(authStateProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(l10n.authLogout),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWebPage(BuildContext context, String url, String title) async {
    final uri = Uri.parse(url);
    final l10n = AppLocalizations.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsWebOpenError(title))));
    }
  }

  void _showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider).locale?.languageCode ?? 'en';
    showModalBottomSheet(
      context: context,
      backgroundColor: context.sheetBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(4))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).languageTitle, style: AppTextStyles.title.copyWith(color: context.textPrimary)),
            const SizedBox(height: 24),
            _buildLanguageOption(context, ref, languageCode: 'en', languageName: AppLocalizations.of(context).languageEnglish, currentLocale: currentLocale),
            _buildLanguageOption(context, ref, languageCode: 'am', languageName: AppLocalizations.of(context).languageAmharic, currentLocale: currentLocale),
            _buildLanguageOption(context, ref, languageCode: 'ti', languageName: AppLocalizations.of(context).languageTigrinya, currentLocale: currentLocale),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, {required String languageCode, required String languageName, required String currentLocale}) {
    final isSelected = currentLocale == languageCode;
    return ListTile(
      onTap: () async {
        await ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
        if (context.mounted) Navigator.pop(context);
      },
      leading: isSelected ? const Icon(Icons.check_circle, color: AppColors.accent500) : const Icon(Icons.radio_button_unchecked),
      title: Text(languageName, style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
    );
  }

  String _getCurrentLanguageName(BuildContext context, String? languageCode) {
    final l10n = AppLocalizations.of(context);
    switch (languageCode) {
      case 'am': return l10n.languageAmharic;
      case 'ti': return l10n.languageTigrinya;
      default: return l10n.languageEnglish;
    }
  }

  String _getDarkModeSubtitle(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context);
    return themeMode == ThemeMode.dark ? l10n.commonOn : l10n.commonOff;
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? textColor;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.textColor,
    required this.onTap,
  });
}
