import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/job_data.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_providers.dart';
import '../../providers/listing_providers.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../listing/widgets/listing_gallery.dart';
import '../listing/widgets/listing_report_sheet.dart';
import 'widgets/job_listing_card.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  const JobDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isRevealingContact = false;
  bool _isFeatureLoading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobDetailProvider.notifier).loadListing(widget.listingId);
    });
  }

  Future<void> _shareListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final title = listing.resolvedJobTitle ?? l10n.jobJob;
    final company = listing.jobCompanyName?.trim();
    final companyText = (company != null && company.isNotEmpty) ? ' ($company)' : '';
    final salaryText = listing.jobSalaryType == 'fixed' && listing.jobSalaryMin != null
        ? '${listing.jobSalaryCurrency ?? 'ETB'} ${smartDecimal(listing.jobSalaryMin!)}'
        : l10n.jobSalaryPerAgreement;

    final shareText = '''
$title$companyText
$salaryText
${listing.jobDescriptionBody.isNotEmpty ? '\n${listing.jobDescriptionBody}' : ''}

${l10n.shareListingTitle}
''';

    await Share.share(
      shareText,
      subject: '${l10n.shareListingMessage}$title',
    );
  }

  Future<void> _toggleFavorite(int listingId, bool isFavorited) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      if (mounted) context.push('/login');
      return;
    }

    final success = await ref.read(favoritesProvider.notifier).toggleFavorite(listingId);
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final msg = isFavorited ? l10n.favoritesRemoved : l10n.favoritesAdded;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _showReportSheet(Listing listing) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ListingReportSheet(listingId: listing.id),
    );
  }

  Future<void> _featureListing(Listing listing) async {
    final subState = ref.read(subscriptionProvider);
    if (!subState.canFeatureListing) {
      if (mounted) context.push('/subscriptions');
      return;
    }
    setState(() => _isFeatureLoading = true);
    try {
      final error = await ref.read(jobDetailProvider.notifier).featureListing(listing.id);
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.error),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).statusSuccess), backgroundColor: AppColors.success),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isFeatureLoading = false);
    }
  }

  Future<void> _unfeatureListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unfeature Listing?'),
        content: const Text('Your listing will no longer appear as featured. You can feature it again later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unfeature'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isFeatureLoading = true);
    try {
      final error = await ref.read(jobDetailProvider.notifier).unfeatureListing(listing.id);
      if (mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.error),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).statusSuccess), backgroundColor: AppColors.success),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isFeatureLoading = false);
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.listingDeleteConfirmTitle),
        content: Text(l10n.listingDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        final error = await ref.read(jobDetailProvider.notifier).deleteListing(listing.id);
        if (mounted) {
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: AppColors.error),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.statusSuccess), backgroundColor: AppColors.success),
            );
            Navigator.of(context).pop();
          }
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsWebOpenError(url)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _revealContact(int listingId) async {
    setState(() => _isRevealingContact = true);
    try {
      final result = await ref.read(jobDetailProvider.notifier).revealContact(listingId);
      if (result != null && mounted) {
        final message = result['message'] as String? ?? 'Contact revealed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRevealingContact = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(jobDetailProvider);
    final authState = ref.watch(authStateProvider);

    if (state.isLoading) {
      return _buildSkeletonLoader();
    }

    if (state.errorMessage != null && state.listing == null) {
      if (state.requiresSubscription) {
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
          body: WaveMessageScreen(
            type: WaveMessageType.warning,
            isEmbedded: true,
            title: l10n.subscriptionRequiredTitle,
            subtitle: l10n.subscriptionRequiredDetailsSubtitle,
            actionLabel: l10n.listingUpgradeNow,
            onAction: () => context.pushReplacement('/subscriptions'),
          ),
        );
      }
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
        body: WaveMessageScreen.error(
          isEmbedded: true,
          title: l10n.listingsLoadError,
          subtitle: state.errorMessage,
          onRetry: () => ref.read(jobDetailProvider.notifier).loadListing(widget.listingId),
        ),
      );
    }

    final listing = state.listing;
    if (listing == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
        body: WaveMessageScreen.empty(
          isEmbedded: true,
          title: l10n.jobNotFound,
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;
    final favState = ref.watch(favoritesProvider);
    final isFavorited = favState.favorites.any((f) => f.id == listing.id);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.jobJobDetails),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? AppColors.error : context.theme.icon,
            ),
            onPressed: () => _toggleFavorite(listing.id, isFavorited),
          ),
          IconButton(
            icon: Icon(Icons.share_outlined, color: context.theme.icon),
            onPressed: () => _shareListing(listing),
          ),
          if (isOwner)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: context.theme.icon),
              onPressed: () => context.push('/jobs/${widget.listingId}/edit', extra: listing),
            )
          else
            IconButton(
              icon: Icon(Icons.flag_outlined, color: context.theme.icon),
              tooltip: l10n.reportListing,
              onPressed: () => _showReportSheet(listing),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.images.isNotEmpty) ...[
              _buildImageGallery(listing),
              const SizedBox(height: 16),
            ],

            _buildHeader(listing, l10n),
            const SizedBox(height: 16),

            _buildOverviewCards(listing, l10n),
            const SizedBox(height: 20),

            _buildRequirementsSection(listing, l10n),
            const SizedBox(height: 20),

            if (listing.jobDescriptionBody.isNotEmpty) ...[
              _buildSection(
                title: l10n.listingDescriptionLabel,
                child: Text(
                  listing.jobDescriptionBody,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (listing.address != null || (listing.specificLocation?.isNotEmpty ?? false)) ...[
              _buildLocationSection(listing, l10n),
              const SizedBox(height: 20),
            ],

            _buildActionSection(listing, isOwner, l10n),
            const SizedBox(height: 32),

            _buildSimilarJobs(listing, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Shimmer.fromColors(
          baseColor: context.shimmerBase,
          highlightColor: context.shimmerHighlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 90,
                    decoration: BoxDecoration(
                      color: context.shimmerHighlight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 24,
                    width: 70,
                    decoration: BoxDecoration(
                      color: context.shimmerHighlight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 28,
                width: 220,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 140,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 76,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 76,
                      decoration: BoxDecoration(
                        color: context.shimmerHighlight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.shimmerHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(Listing listing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 240,
        child: ListingGallery(
          listing: listing,
        ),
      ),
    );
  }

  Widget _buildHeader(Listing listing, AppLocalizations l10n) {
    final title = listing.resolvedJobTitle ??
        (listing.jobCategory != null && listing.jobCategory!.isNotEmpty
            ? jobCategoryLabel(listing.jobCategory!, l10n)
            : l10n.jobJob);
    final company = (listing.jobCompanyName?.trim().isNotEmpty ?? false)
        ? listing.jobCompanyName!.trim()
        : l10n.jobIndividualPoster;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (listing.jobCategory != null && listing.jobCategory!.isNotEmpty)
              _buildBadge(
                jobCategoryLabel(listing.jobCategory!, l10n),
                AppColors.accent600,
              ),
            if (listing.jobType != null && listing.jobType!.isNotEmpty)
              _buildBadge(
                jobTypeLabel(listing.jobType!, l10n),
                AppColors.cta600,
              ),
            if ((listing.jobPositionsCount ?? 1) > 1)
              _buildBadge(
                '${listing.jobPositionsCount} ${l10n.jobPositions}',
                AppColors.amber,
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: AppTextStyles.headline4.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.business_outlined, size: 16, color: context.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                company,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 14, color: context.textSecondary.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(
              DateFormat('MMM d, yyyy').format(listing.createdAt),
              style: AppTextStyles.labelSmall.copyWith(color: context.textSecondary.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildOverviewCards(Listing listing, AppLocalizations l10n) {
    String salaryText = l10n.jobSalaryPerAgreement;
    final currency = listing.jobSalaryCurrency ?? 'ETB';
    if (listing.jobSalaryType == 'fixed' && listing.jobSalaryMin != null) {
      salaryText = '$currency ${smartDecimal(listing.jobSalaryMin!)}';
    } else if (listing.jobSalaryType == 'range' && listing.jobSalaryMin != null && listing.jobSalaryMax != null) {
      salaryText = '$currency ${smartDecimal(listing.jobSalaryMin!)} - ${smartDecimal(listing.jobSalaryMax!)}';
    }

    String deadlineText = l10n.jobNoDeadline;
    bool isExpired = false;
    if (listing.jobDeadline != null) {
      deadlineText = DateFormat('MMM d, yyyy').format(listing.jobDeadline!);
      isExpired = listing.jobDeadline!.isBefore(DateTime.now());
    }

    return Row(
      children: [
        Expanded(
          child: WaveCard(
            useLiquidGlass: true,
            isGlass: true,
            showBorder: true,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, size: 18, color: AppColors.emerald600),
                    const SizedBox(width: 6),
                    Text(
                      l10n.jobSalaryType,
                      style: AppTextStyles.caption.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  salaryText,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.emerald600,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: WaveCard(
            useLiquidGlass: true,
            isGlass: true,
            showBorder: true,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 18,
                      color: isExpired ? AppColors.error : AppColors.accent600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.jobDeadline,
                      style: AppTextStyles.caption.copyWith(color: context.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  deadlineText,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isExpired ? AppColors.error : context.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection(Listing listing, AppLocalizations l10n) {
    final hasEducations = listing.jobReqEducations != null && listing.jobReqEducations!.isNotEmpty;
    final hasExperiences = listing.jobReqExperiences != null && listing.jobReqExperiences!.isNotEmpty;
    final hasLegacyEducation = listing.jobReqEducation != null && listing.jobReqEducation!.isNotEmpty;
    final hasLegacyExperience = listing.jobReqExperience != null && listing.jobReqExperience!.isNotEmpty;
    final hasGender = listing.jobReqGender != null && listing.jobReqGender!.isNotEmpty && listing.jobReqGender != 'any';

    if (!hasEducations && !hasExperiences && !hasLegacyEducation && !hasLegacyExperience && !hasGender) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      title: l10n.jobRequirements,
      child: WaveCard(
        useLiquidGlass: true,
        isGlass: true,
        showBorder: true,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasEducations) ...[
              _buildReqHeader(Icons.school_outlined, l10n.jobEducationLevel),
              const SizedBox(height: 6),
              ...listing.jobReqEducations!.map((edu) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(edu.displayLabel(l10n), style: AppTextStyles.bodyMedium)),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ] else if (hasLegacyEducation) ...[
              _buildReqRow(
                Icons.school_outlined,
                l10n.jobEducationLevel,
                educationLevelLabel(listing.jobReqEducation!, l10n),
              ),
              const SizedBox(height: 12),
            ],

            if (hasExperiences) ...[
              _buildReqHeader(Icons.work_outline, l10n.seekerExperience),
              const SizedBox(height: 6),
              ...listing.jobReqExperiences!.map((exp) => Padding(
                padding: const EdgeInsets.only(left: 24, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(exp.displayRequirementLabel(), style: AppTextStyles.bodyMedium)),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ] else if (hasLegacyExperience) ...[
              _buildReqRow(
                Icons.work_outline,
                l10n.seekerExperience,
                listing.jobReqExperience!,
              ),
              const SizedBox(height: 12),
            ],

            if (hasGender) ...[
              _buildReqRow(
                Icons.people_outline,
                l10n.jobRequiredGender,
                genderOptionLabel(listing.jobReqGender!, l10n),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReqHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent600),
        const SizedBox(width: 6),
        Text(title, style: AppTextStyles.labelLarge.copyWith(color: context.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildReqRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent600),
        const SizedBox(width: 8),
        Text('$title: ', style: AppTextStyles.labelLarge.copyWith(color: context.textPrimary, fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildLocationSection(Listing listing, AppLocalizations l10n) {
    final addr = listing.address;
    final parts = <String>[];
    if (addr?.region != null && addr!.region!.isNotEmpty) parts.add(addr.region!);
    if (addr?.zone != null && addr!.zone!.isNotEmpty) parts.add(addr.zone!);
    if (addr?.woreda != null && addr!.woreda!.isNotEmpty) parts.add(addr.woreda!);
    if (addr?.kebele != null && addr!.kebele!.isNotEmpty) parts.add('Kebele ${addr.kebele!}');

    String locationText = parts.join(', ');
    if (listing.specificLocation != null && listing.specificLocation!.isNotEmpty) {
      locationText = locationText.isNotEmpty ? '$locationText (${listing.specificLocation})' : listing.specificLocation!;
    }

    return _buildSection(
      title: l10n.jobLocation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: AppColors.accent600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              locationText.isNotEmpty ? locationText : 'Ethiopia',
              style: AppTextStyles.bodyMedium.copyWith(color: context.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(Listing listing, bool isOwner, AppLocalizations l10n) {
    final subState = ref.watch(subscriptionProvider);

    return WaveCard(
      useLiquidGlass: true,
      margin: EdgeInsets.zero,
      isGlass: true,
      showBorder: true,
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isOwner) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/jobs/${widget.listingId}/edit', extra: listing),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(l10n.commonEdit),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.theme.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: context.isDarkMode ? AppColors.primary300 : AppColors.primary600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDeleting ? null : () => _deleteListing(listing),
                    icon: _isDeleting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                        : const Icon(Icons.delete_outline, size: 20),
                    label: Text(l10n.commonDelete),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (listing.isFeaturedActive)
              LiquidGlass(
                borderRadius: 12,
                blur: 20,
                tint: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      l10n.jobFeatured,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isFeatureLoading ? null : () => _unfeatureListing(listing),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.stone500,
                      ),
                      child: _isFeatureLoading
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              'Unfeature',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.stone500),
                            ),
                    ),
                  ],
                ),
              )
            else
              subState.canFeatureListing
                  ? SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isFeatureLoading ? null : () => _featureListing(listing),
                        icon: _isFeatureLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.workspace_premium_outlined, size: 20),
                        label: Text(_isFeatureLoading ? '' : l10n.listingFeatureThis),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.accent500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: AppColors.accent500,
                        ),
                      ),
                    )
                  : UpgradeCard(
                      icon: Icons.workspace_premium_outlined,
                      iconColor: AppColors.accent500,
                      title: l10n.listingUpgradeToFeature,
                      subtitle: l10n.subscriptionRequiredFeatureSubtitle,
                    ),
          ],
          if (!isOwner) ...[
            if (listing.contactRevealed || ((listing.sellerPhone?.isNotEmpty ?? false) && !listing.userContactHidden)) ...[
              _buildEmployerContact(listing, l10n),
            ] else if (listing.userContactHidden) ...[
              _buildContactUpgradeSection(l10n),
            ] else if (listing.contactMax > 0) ...[
              _buildContactRevealSection(listing, l10n),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showReportSheet(listing),
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: Text(l10n.reportListing),
                style: TextButton.styleFrom(
                  foregroundColor: context.textSecondary,
                  visualDensity: VisualDensity.compact,
                  textStyle: AppTextStyles.labelSmall,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactRevealSection(Listing listing, AppLocalizations l10n) {
    return LiquidGlass(
      borderRadius: 12,
      blur: 20,
      tint: AppColors.accent500,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 28, color: AppColors.accent600),
          const SizedBox(height: 8),
          Text(l10n.listingsRevealContact, style: AppTextStyles.title.copyWith(fontSize: 14)),
          if (listing.contactMax > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.listingsContactViewsRemaining(listing.contactRemaining, listing.contactMax),
              style: AppTextStyles.caption.copyWith(color: context.theme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRevealingContact ? null : () => _revealContact(listing.id),
              icon: _isRevealingContact
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.visibility_outlined, size: 18),
              label: Text(_isRevealingContact ? l10n.listingsRevealing : l10n.listingsRevealContact),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUpgradeSection(AppLocalizations l10n) {
    return UpgradeCard(
      icon: Icons.lock_outline,
      iconColor: AppColors.accent500,
      title: l10n.upgradeToContact,
      subtitle: l10n.subscriptionRequiredDetailsSubtitle,
      buttonLabel: l10n.listingViewPlans,
    );
  }

  Widget _buildEmployerContact(Listing listing, AppLocalizations l10n) {
    final phone = listing.revealedContact ?? listing.sellerPhone ?? '';
    final company = listing.jobCompanyName?.trim();
    final name = (listing.revealedName?.isNotEmpty ?? false)
        ? listing.revealedName!
        : ((listing.sellerName?.isNotEmpty ?? false)
            ? listing.sellerName!
            : ((company != null && company.isNotEmpty) ? company : l10n.jobIndividualPoster));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(l10n.jobContactEmployer, style: AppTextStyles.titleSmall.copyWith(color: context.textPrimary)),
        ),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: false,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: context.theme.cardBg,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      style: AppTextStyles.titleSmall.copyWith(color: AppColors.accent600, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600, color: context.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: AppTextStyles.bodyMedium.copyWith(color: context.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.phone,
                        label: l10n.jobCall,
                        hint: l10n.jobCallHint,
                        color: const Color(0xFF4CAF50),
                        onTap: () => _launchUrl('tel:$phone'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.chat_bubble_outline,
                        label: l10n.jobWhatsapp,
                        hint: l10n.jobWhatsappHint,
                        color: const Color(0xFF25D366),
                        onTap: () => _launchUrl('https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ContactButton(
                        icon: Icons.send,
                        label: l10n.jobTelegram,
                        hint: l10n.jobTelegramHint,
                        color: const Color(0xFF0088CC),
                        onTap: () => _launchUrl('https://t.me/+${phone.replaceAll(RegExp(r'[^0-9]'), '')}'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarJobs(Listing listing, AppLocalizations l10n) {
    final similarAsync = ref.watch(similarJobsProvider(listing.id));

    return similarAsync.when(
      data: (response) {
        if (!response.success || response.listings.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.listingsSimilarListings),
            const SizedBox(height: 12),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: response.listings.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = response.listings[index];
                  return SizedBox(
                    width: 280,
                    child: JobListingCard(
                      job: item,
                      onTap: () => context.push('/jobs/${item.id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.title.copyWith(
        color: context.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: hint,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(label, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
