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
import '../payments/payment_history_screen.dart';
import '../help/help_center_screen.dart';
import '../auth/otp_login_screen.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';

final appSettingsProvider = FutureProvider<Map<String, dynamic>>((_) async {
  try {
    final response = await ApiClient().dio.get(ApiConstants.apiBase + '/settings');
    if (response.statusCode == 200 && response.data is Map) {
      return response.data['data'] ?? {};
    }
  } catch (_) {}
  return {'subscription_enabled': false};
});

/// Settings Screen - App settings and support (no profile/nav)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final kycState = ref.watch(kycStatusProvider);
    final localeCode = ref.watch(localeProvider).locale?.languageCode;
final settingsAsync = ref.watch(appSettingsProvider);
    final subscriptionEnabled = settingsAsync.maybeWhen(
      data: (data) => data['subscription_enabled'] == true,
      orElse: () => false,
    );

    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine KYC status display
    String kycSubtitle = l10n.settingsKycRequired;
    String? kycBadge = l10n.settingsKycRequired;

    if (profileState.user?.isKycVerified == true || kycState.isVerified || kycState.isApproved) {
      kycSubtitle = l10n.settingsKycVerified;
      kycBadge = null;
    } else if (kycState.isPending) {
      kycSubtitle = l10n.settingsKycPending;
      kycBadge = l10n.settingsKycPending;
    }

    // Build account menu items based on subscription enabled
    final List<_MenuItemData> accountItems = [
      _MenuItemData(
        icon: Icons.list_alt_outlined,
        title: l10n.profileMyListings,
        subtitle: l10n.settingsMyListingsSubtitle,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyListingsScreen()),
        ),
      ),
    ];

    // Add subscription and payment only if enabled
    if (subscriptionEnabled) {
      accountItems.addAll([
        _MenuItemData(
          icon: Icons.payment_outlined,
          title: l10n.profileSubscriptions,
          subtitle: l10n.settingsSubscriptionsSubtitle,
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
            );
            // Refresh subscription when returning
            if (mounted) {
              ref.read(subscriptionProvider.notifier).refresh();
            }
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
      ]);
    }

    accountItems.add(
      _MenuItemData(
        icon: Icons.verified_user_outlined,
        title: l10n.profileKyc,
        subtitle: kycSubtitle,
        badge: kycBadge,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const KycVerificationScreen()),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: context.cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.settingsTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(profileProvider.notifier).loadProfile();
          ref.invalidate(appSettingsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMenuSection(
              title: l10n.settingsSectionAccount,
              items: accountItems,
            ),
            const SizedBox(height: 16),
            _buildMenuSection(
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
              title: l10n.settingsSectionSupport,
              items: [
                _MenuItemData(
                  icon: Icons.help_outline,
                  title: l10n.profileHelp,
                  subtitle: l10n.settingsHelpSubtitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                _MenuItemData(
                  icon: Icons.support_agent,
                  title: l10n.settingsContactSupport,
                  subtitle: l10n.settingsContactSupportSubtitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                _MenuItemData(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  onTap: () => _openWebPage(
                      context, 'https://wavemart.et/privacy', l10n.settingsPrivacyPolicy),
                ),
                _MenuItemData(
                  icon: Icons.description_outlined,
                  title: l10n.settingsTermsOfService,
                  onTap: () => _openWebPage(
                      context, 'https://wavemart.et/terms', l10n.settingsTermsOfService),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMenuSection(
              title: l10n.settingsSectionAuth,
              items: [
                _MenuItemData(
                  icon: Icons.logout,
                  title: l10n.settingsLogout,
                  subtitle: l10n.settingsLogoutSubtitle,
                  textColor: AppColors.error,
                  onTap: () => _showLogoutConfirmation(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmation(
      BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsLogout),
        content: Text(l10n.authLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
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
            child:
                Text(l10n.settingsLogout, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _openWebPage(
      BuildContext context, String url, String title) async {
    final uri = Uri.parse(url);
    final l10n = AppLocalizations.of(context);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsWebOpenError(title))),
        );
      }
    }
  }

  Widget _buildMenuSection({
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
              color: context.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.divider.withOpacity(0.5)),
          ),
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
              color: context.theme.isDark ? AppColors.navy800 : AppColors.navy50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: item.textColor ?? AppColors.navy600,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: item.textColor,
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
                    color: context.theme.isDark ? AppColors.wave950 : AppColors.wave100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.wave500.withOpacity(0.3)),
                  ),
                  child: Text(
                    item.badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.wave700,
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
}

/// Get current language display name
String _getCurrentLanguageName(BuildContext context, String? languageCode) {
  final l10n = AppLocalizations.of(context);
  switch (languageCode) {
    case 'am':
      return l10n.languageAmharic;
    case 'ti':
      return l10n.languageTigrinya;
    default:
      return l10n.languageEnglish;
  }
}

/// Show language selection dialog
void _showLanguageSelectionDialog(BuildContext context, WidgetRef ref) {
  final currentLocale = ref.read(localeProvider).locale?.languageCode ?? 'en';

  showModalBottomSheet(
    context: context,
    backgroundColor: context.sheetBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).languageTitle,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 24),
          _buildLanguageOption(
            context,
            ref,
            languageCode: 'en',
            languageName: AppLocalizations.of(context).languageEnglish,
            currentLocale: currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            languageCode: 'am',
            languageName: AppLocalizations.of(context).languageAmharic,
            currentLocale: currentLocale,
          ),
          _buildLanguageOption(
            context,
            ref,
            languageCode: 'ti',
            languageName: AppLocalizations.of(context).languageTigrinya,
            currentLocale: currentLocale,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

/// Build single language option
Widget _buildLanguageOption(
  BuildContext context,
  WidgetRef ref, {
  required String languageCode,
  required String languageName,
  required String currentLocale,
}) {
  final isSelected = currentLocale == languageCode;

  return ListTile(
    onTap: () async {
      await ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
      if (context.mounted) {
        Navigator.pop(context);
      }
    },
    leading: isSelected
        ? const Icon(Icons.check_circle, color: AppColors.wave500)
        : const Icon(Icons.radio_button_unchecked),
    title: Text(languageName),
  );
}

String _getDarkModeSubtitle(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeModeProvider);
  final l10n = AppLocalizations.of(context);
  return themeMode == ThemeMode.dark ? l10n.commonOn : l10n.commonOff;
}



class _MenuItemData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final Color? textColor;
  final VoidCallback onTap;

  _MenuItemData({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.textColor,
    required this.onTap,
  });
}
