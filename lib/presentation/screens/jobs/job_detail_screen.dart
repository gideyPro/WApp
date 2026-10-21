import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/job_data.dart';
import '../../../data/models/listing.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_providers.dart';
import '../../widgets/common/wave_card.dart';
import '../../widgets/common/wave_common_widgets.dart';
import '../../widgets/common/wave_liquid_glass.dart';
import '../../widgets/common/wave_upgrade_card.dart';
import '../listing/widgets/listing_gallery.dart';
import 'widgets/job_listing_card.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final int listingId;
  const JobDetailScreen({super.key, required this.listingId});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isRevealingContact = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobDetailProvider.notifier).loadListing(widget.listingId);
    });
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
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.listing == null) {
      if (state.requiresSubscription) {
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          appBar: WaveAppBar(title: Text(l10n.jobJobDetails)),
          body: WaveMessageScreen(
            type: WaveMessageType.warning,
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
          title: l10n.jobNotFound,
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final currentUserId = authState.user?.id;
    final isOwner = currentUserId != null && listing.userId == currentUserId;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(
        title: Text(l10n.jobJobDetails),
        actions: [
          if (isOwner)
            IconButton(
              icon: Icon(Icons.edit_outlined, color: context.theme.icon),
              onPressed: () => context.push('/jobs/${widget.listingId}/edit', extra: listing),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.images.isNotEmpty) ...[
              ListingGallery(
                listing: listing,
              ),
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

            _buildContactSection(listing, isOwner, l10n),
            const SizedBox(height: 32),

            _buildSimilarJobs(listing, l10n),
            const SizedBox(height: 40),
          ],
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
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildContactSection(Listing listing, bool isOwner, AppLocalizations l10n) {
    if (isOwner) {
      return const SizedBox.shrink();
    }

    final hasPhone = listing.sellerPhone != null && listing.sellerPhone!.isNotEmpty;
    final isRevealed = listing.contactRevealed || (hasPhone && !listing.userContactHidden);

    if (isRevealed) {
      return _buildEmployerContact(listing, l10n);
    }

    if (listing.userContactHidden) {
      return _buildContactUpgradeSection(l10n);
    }

    if (listing.contactMax > 0) {
      return _buildContactRevealSection(listing, l10n);
    }

    return const SizedBox.shrink();
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
        Text(l10n.jobContactEmployer, style: AppTextStyles.title.copyWith(color: context.textPrimary)),
        const SizedBox(height: 12),
        WaveCard(
          useLiquidGlass: true,
          isGlass: true,
          showBorder: true,
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
