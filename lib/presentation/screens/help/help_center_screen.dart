import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/constants/app_spacing.dart';

/// Help Center Screen - Browse FAQs and guides
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_HelpArticle> _filteredArticles = [];
  List<_HelpArticle> _allArticles = [];
  bool _isSearching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allArticles = _getLocalizedArticles(AppLocalizations.of(context));
    if (!_isSearching) {
      _filteredArticles = _allArticles;
    } else {
      _onSearchChanged();
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles
            .where((article) =>
                article.title.toLowerCase().contains(query) ||
                article.content.toLowerCase().contains(query) ||
                article.category.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WaveAppBar(
        title: Text(AppLocalizations.of(context).profileHelp),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: AppSpacing.paddingLg,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).helpSearchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                filled: true,
                fillColor: AppColors.stone50,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isSearching ? _buildSearchResults() : _buildCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildCategorySection(
          icon: Icons.account_circle_outlined,
          title: l10n.helpCategoryAccount,
          articles: _allArticles.where((a) => a.category == l10n.helpCategoryAccount).toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.home_outlined,
          title: l10n.helpCategoryListings,
          articles:
              _allArticles.where((a) => a.category == l10n.helpCategoryListings).toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.payment_outlined,
          title: l10n.helpCategoryPayments,
          articles:
              _allArticles.where((a) => a.category == l10n.helpCategoryPayments).toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.verified_user_outlined,
          title: l10n.helpCategoryKyc,
          articles: _allArticles.where((a) => a.category == l10n.helpCategoryKyc).toList(),
        ),
        const SizedBox(height: 24),
        _buildCategorySection(
          icon: Icons.security_outlined,
          title: l10n.helpCategorySafety,
          articles: _allArticles.where((a) => a.category == l10n.helpCategorySafety).toList(),
        ),
        const SizedBox(height: 32),

        // Contact support
        _buildContactSupport(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategorySection({
    required IconData icon,
    required String title,
    required List<_HelpArticle> articles,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.accent600),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.titleSmall),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.stone200),
          ),
          child: Column(
            children: articles.asMap().entries.map((entry) {
              final index = entry.key;
              final article = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.article_outlined,
                      size: 20,
                      color: ThemeColors(context).iconSecondary,
                    ),
                    title: Text(
                      article.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.theme.textPrimary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: ThemeColors(context).textSecondary,
                    ),
                    onTap: () => _showArticleDetail(article),
                  ),
                  if (index < articles.length - 1) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context);
    if (_filteredArticles.isEmpty) {
      return WaveEmptyState(
        icon: Icons.search_off,
        title: l10n.helpNoResultsTitle,
        subtitle: l10n.helpNoResultsSubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredArticles.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final article = _filteredArticles[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accent50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 20,
              color: AppColors.accent600,
            ),
          ),
          title: Text(
            article.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.textPrimary,
            ),
          ),
          subtitle: Text(
            article.category,
            style: AppTextStyles.caption.copyWith(
              color: context.theme.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.stone400),
          onTap: () => _showArticleDetail(article),
        );
      },
    );
  }

  Widget _buildContactSupport() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: AppColors.gradientAccent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                l10n.helpStillNeedHelp,
                style: AppTextStyles.bodyLargePlus.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.helpSupportTeam,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchEmail(),
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: Text(l10n.helpEmail),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone(),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(l10n.helpCall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showArticleDetail(_HelpArticle article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.theme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        style: AppTextStyles.title.copyWith(color: context.theme.textPrimary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      article.content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.8,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : AppColors.primary700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@wavemart.et');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).helpErrorEmail)),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+251911000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).helpErrorPhone)),
        );
      }
    }
  }
}

class _HelpArticle {
  final String title;
  final String content;
  final String category;

  _HelpArticle(
      {required this.title, required this.content, required this.category});
}

List<_HelpArticle> _getLocalizedArticles(AppLocalizations l10n) => [
      // Account
      _HelpArticle(
        title: l10n.helpAccCreateTitle,
        content: l10n.helpAccCreateContent,
        category: l10n.helpCategoryAccount,
      ),
      _HelpArticle(
        title: l10n.helpAccEditTitle,
        content: l10n.helpAccEditContent,
        category: l10n.helpCategoryAccount,
      ),
      _HelpArticle(
        title: l10n.helpAccResetTitle,
        content: l10n.helpAccResetContent,
        category: l10n.helpCategoryAccount,
      ),

      // Listings
      _HelpArticle(
        title: l10n.helpListCreateTitle,
        content: l10n.helpListCreateContent,
        category: l10n.helpCategoryListings,
      ),
      _HelpArticle(
        title: l10n.helpListManageTitle,
        content: l10n.helpListManageContent,
        category: l10n.helpCategoryListings,
      ),
      _HelpArticle(
        title: l10n.helpListTipsTitle,
        content: l10n.helpListTipsContent,
        category: l10n.helpCategoryListings,
      ),

      // Payments
      _HelpArticle(
        title: l10n.helpPayPlansTitle,
        content: l10n.helpPayPlansContent,
        category: l10n.helpCategoryPayments,
      ),
      _HelpArticle(
        title: l10n.helpPayMakeTitle,
        content: l10n.helpPayMakeContent,
        category: l10n.helpCategoryPayments,
      ),
      _HelpArticle(
        title: l10n.helpPaySecurityTitle,
        content: l10n.helpPaySecurityContent,
        category: l10n.helpCategoryPayments,
      ),

      // KYC
      _HelpArticle(
        title: l10n.helpKycWhyTitle,
        content: l10n.helpKycWhyContent,
        category: l10n.helpCategoryKyc,
      ),
      _HelpArticle(
        title: l10n.helpKycHowTitle,
        content: l10n.helpKycHowContent,
        category: l10n.helpCategoryKyc,
      ),
      _HelpArticle(
        title: l10n.helpKycRejectTitle,
        content: l10n.helpKycRejectContent,
        category: l10n.helpCategoryKyc,
      ),

      // Safety
      _HelpArticle(
        title: l10n.helpSafeStayTitle,
        content: l10n.helpSafeStayContent,
        category: l10n.helpCategorySafety,
      ),
      _HelpArticle(
        title: l10n.helpSafePrivacyTitle,
        content: l10n.helpSafePrivacyContent,
        category: l10n.helpCategorySafety,
      ),
      _HelpArticle(
        title: l10n.helpSafeReportTitle,
        content: l10n.helpSafeReportContent,
        category: l10n.helpCategorySafety,
      ),
    ];
