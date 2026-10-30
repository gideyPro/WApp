import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/network/v2/api_v2_error.dart';
import '../../../../core/network/v2/paginated.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/v2/help_content.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/v2_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';

/// Help Center Screen backed by V2 `/v2/help`
class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HelpArticleSummary> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _isLoadingSearch = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _isLoadingSearch = true;
    });

    try {
      final page =
          await ref.read(helpV2ServiceProvider).fetchArticles(query: query);
      if (mounted) {
        setState(() {
          _searchResults = page.items;
          _isLoadingSearch = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isLoadingSearch = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeAsync = ref.watch(helpHomeProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.profileHelp),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: AppSpacing.paddingLg,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.helpSearchHint,
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: context.textSecondary),
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: Icon(Icons.clear, color: context.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.theme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent500, width: 1.5),
                ),
                filled: true,
                fillColor: context.theme.inputBg,
              ),
              style: AppTextStyles.bodyMedium.copyWith(
                color: context.theme.textPrimary,
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isSearching
                ? _buildSearchResults(l10n)
                : homeAsync.when(
                    data: (home) => _buildHome(home, l10n),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => WaveMessageScreen.error(
                      title: l10n.commonError,
                      subtitle: error is ApiV2Exception
                          ? error.message
                          : 'Could not load help center',
                      onRetry: () => ref.invalidate(helpHomeProvider),
                      isEmbedded: true,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AppLocalizations l10n) {
    if (_isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return WaveEmptyState(
        icon: Icons.search_off,
        title: l10n.helpNoResultsTitle,
        subtitle: l10n.helpNoResultsSubtitle,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final article = _searchResults[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.theme.isDark
                  ? AppColors.accent500.withValues(alpha: 0.15)
                  : AppColors.accent50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.article_outlined,
              size: 20,
              color: context.theme.isDark
                  ? AppColors.accent400
                  : AppColors.accent600,
            ),
          ),
          title: Text(
            article.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: context.theme.textPrimary,
            ),
          ),
          subtitle: article.category != null
              ? Text(
                  article.category!.name,
                  style: AppTextStyles.caption.copyWith(
                    color: context.theme.textSecondary,
                  ),
                )
              : null,
          trailing:
              Icon(Icons.chevron_right_rounded, color: context.theme.textMuted),
          onTap: () => _showArticleDetail(article.slug, article.title),
        );
      },
    );
  }

  Widget _buildHome(HelpHome home, AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(helpHomeProvider);
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Categories
          if (home.categories.isNotEmpty) ...[
            Text(
              'Categories',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...home.categories.map((category) => _buildCategoryTile(category)),
            const SizedBox(height: 24),
          ],

          // Featured articles
          if (home.featuredArticles.isNotEmpty) ...[
            Text(
              'Featured Articles',
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...home.featuredArticles.map(
              (article) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline,
                    color: AppColors.accent500, size: 20),
                title: Text(
                  article.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                onTap: () => _showArticleDetail(article.slug, article.title),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Contact support
          _buildContactSupport(l10n),
          const SizedBox(height: 20),

          // YouTube banner
          _buildYoutubeBanner(l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(HelpCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.divider.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accent500.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder_outlined,
              color: AppColors.accent500, size: 20),
        ),
        title: Text(
          category.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: context.theme.textPrimary,
          ),
        ),
        subtitle: category.description != null
            ? Text(
                category.description!,
                style: AppTextStyles.caption
                    .copyWith(color: context.theme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: context.theme.divider.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${category.articlesCount}',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        onTap: () => _showCategoryArticles(category),
      ),
    );
  }

  void _showCategoryArticles(HelpCategory category) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) =>
            FutureBuilder<Paginated<HelpArticleSummary>>(
          future: ref
              .read(helpV2ServiceProvider)
              .fetchArticles(category: category.slug),
          builder: (context, snapshot) {
            return Container(
              decoration: BoxDecoration(
                color: context.scaffoldBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.theme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: AppTextStyles.title
                                .copyWith(color: context.theme.textPrimary),
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
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : (snapshot.data?.items.isEmpty ?? true)
                            ? const Center(child: Text('No articles found'))
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: snapshot.data!.items.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, i) {
                                  final item = snapshot.data!.items[i];
                                  return ListTile(
                                    title: Text(item.title),
                                    trailing: const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      _showArticleDetail(item.slug, item.title);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showArticleDetail(String slug, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => FutureBuilder<HelpArticle>(
          future: ref.read(helpV2ServiceProvider).fetchArticle(slug),
          builder: (context, snapshot) {
            final article = snapshot.data;
            return Container(
              decoration: BoxDecoration(
                color: context.scaffoldBg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.theme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            article?.title ?? title,
                            style: AppTextStyles.title
                                .copyWith(color: context.theme.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: context.textSecondary),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : snapshot.hasError
                            ? const Center(
                                child: Text('Failed to load article content'))
                            : ListView(
                                controller: controller,
                                padding: const EdgeInsets.all(20),
                                children: [
                                  Text(
                                    article!.content.isNotEmpty
                                        ? article.content
                                        : article.formattedContent,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      height: 1.8,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  _buildFeedbackSection(slug),
                                  const SizedBox(height: 24),
                                ],
                              ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(String slug) {
    bool voted = false;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        if (voted) {
          return const Center(
            child: Text(
              'Thank you for your feedback!',
              style: TextStyle(
                  color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          );
        }

        return Column(
          children: [
            const Text(
              'Was this article helpful?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(helpV2ServiceProvider)
                          .submitArticleFeedback(slug, isHelpful: true);
                      setLocalState(() => voted = true);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: const Text('Yes'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(helpV2ServiceProvider)
                          .submitArticleFeedback(slug, isHelpful: false);
                      setLocalState(() => voted = true);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.thumb_down_outlined, size: 16),
                  label: const Text('No'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactSupport(AppLocalizations l10n) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: AppColors.gradientAccent,
        borderRadius: BorderRadius.circular(16),
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
                  onPressed: _launchEmail,
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: Text(l10n.helpEmail),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _launchPhone,
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(l10n.helpCall),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showCreateTicketDialog,
              icon: const Icon(Icons.confirmation_number_outlined, size: 18),
              label: const Text('Submit Support Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary900,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketDialog() {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Support Ticket'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Brief summary of the issue',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Describe your issue in detail',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final subject = subjectCtrl.text.trim();
                      final message = messageCtrl.text.trim();
                      if (subject.isEmpty || message.isEmpty) return;

                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);
                      setDialogState(() => isSubmitting = true);
                      try {
                        await ref.read(helpV2ServiceProvider).createTicket(
                              subject: subject,
                              message: message,
                            );
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Support ticket created!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        ref.invalidate(helpHomeProvider);
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to submit ticket'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeBanner(AppLocalizations l10n) {
    return GestureDetector(
      onTap: _launchYoutube,
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF212121), Color(0xFFCC0000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCC0000).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFFCC0000),
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wavemart on YouTube',
                    style: AppTextStyles.bodyLargePlus.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.helpYoutubeSub,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFCC0000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.subscriptions,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    l10n.helpYoutubeSubscribe,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).helpErrorEmail),
            backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:+251981418181');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).helpErrorPhone),
            backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _launchYoutube() async {
    final uri = Uri.parse('https://www.youtube.com/@WavemartET');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).helpErrorYoutube),
            backgroundColor: AppColors.error));
      }
    }
  }
}
