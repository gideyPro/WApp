import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/job_data.dart';
import '../../../data/models/job_requirement_item.dart';
import '../../../data/models/job_seeker_profile.dart';
import '../../../data/services/message_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_seeker_providers.dart';
import '../../widgets/common/wave_card.dart';

class JobSeekerDetailScreen extends ConsumerStatefulWidget {
  final int profileId;
  const JobSeekerDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<JobSeekerDetailScreen> createState() => _JobSeekerDetailScreenState();
}

class _JobSeekerDetailScreenState extends ConsumerState<JobSeekerDetailScreen> {
  bool _isActionLoading = false;
  String? _loadingAction; // 'chat', 'voice', 'video'

  Future<void> _startChat(int userId) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }

    setState(() {
      _isActionLoading = true;
      _loadingAction = 'chat';
    });
    try {
      final l10n = AppLocalizations.of(context);
      final result = await MessageService().startDirectConversation(userId: userId);
      if (result.success && result.conversation != null && mounted) {
        context.push('/chat/${result.conversation!.id}', extra: result.conversation);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message.isNotEmpty ? result.message : l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  Future<void> _startCall(int userId, {required bool isVideo}) async {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }

    setState(() {
      _isActionLoading = true;
      _loadingAction = isVideo ? 'video' : 'voice';
    });
    try {
      final l10n = AppLocalizations.of(context);
      final messageService = MessageService();
      final convResult = await messageService.startDirectConversation(userId: userId);
      if (!convResult.success || convResult.conversation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(convResult.message.isNotEmpty ? convResult.message : l10n.commonError),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final conferenceService = ref.read(conferenceServiceProvider);
      final callResult = await conferenceService.startDirectCall(
        conversationId: convResult.conversation!.id,
        isVideo: isVideo,
      );
      if (callResult.success && callResult.conference != null && mounted) {
        context.push('/call/${callResult.conference!.id}', extra: {'is_video': isVideo});
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(callResult.message.isNotEmpty ? callResult.message : l10n.commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
          _loadingAction = null;
        });
      }
    }
  }

  Future<void> _openCv(String cv) async {
    final url = cv.startsWith('http') ? cv : '${ApiConstants.baseUrl}/storage/$cv';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildAvatarFallback(JobSeekerProfile profile) {
    final initials = profile.fullName.trim().isNotEmpty
        ? profile.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';
    return Container(
      width: 100,
      height: 100,
      color: context.theme.iconBg,
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: AppTextStyles.headline2.copyWith(color: context.theme.icon),
      ),
    );
  }

  Widget _buildBadgeChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(JobSeekerProfile profile, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent500.withValues(alpha: 0.35), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: profile.photo != null
                      ? CachedNetworkImage(
                          imageUrl: profile.photo!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildAvatarFallback(profile),
                        )
                      : _buildAvatarFallback(profile),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accent500,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: AppTextStyles.headline3.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            profile.professionalTitle,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.accent600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.jobCategory != null)
                _buildBadgeChip(
                  icon: Icons.work_outline,
                  label: jobCategoryLabel(profile.jobCategory!, l10n),
                  bgColor: AppColors.primary100.withValues(alpha: 0.7),
                  textColor: AppColors.primary900,
                ),
              _buildBadgeChip(
                icon: Icons.school_outlined,
                label: educationLevelLabel(profile.educationLevel, l10n),
                bgColor: AppColors.accent100.withValues(alpha: 0.7),
                textColor: AppColors.accent900,
              ),
              if (profile.totalExperienceYears > 0)
                _buildBadgeChip(
                  icon: Icons.timeline_outlined,
                  label:
                      '${profile.totalExperienceYears.toStringAsFixed(profile.totalExperienceYears.truncateToDouble() == profile.totalExperienceYears ? 0 : 1)} yrs exp',
                  bgColor: AppColors.cta100.withValues(alpha: 0.7),
                  textColor: AppColors.cta900,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaveMartContactCard(JobSeekerProfile profile, bool isOwnProfile, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      tint: AppColors.accent500,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline, size: 20, color: AppColors.accent600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WaveMart options', style: AppTextStyles.titleSmall.copyWith(color: context.theme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                      'In-app messaging and calling with candidate',
                      style: AppTextStyles.caption.copyWith(color: context.theme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (isOwnProfile) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/my-job-profile'),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.commonEdit),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.theme.primary,
                      side: BorderSide(color: context.theme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ContactActionButton(
                  icon: Icons.message_outlined,
                  label: l10n.jobSeekerMessage,
                  color: AppColors.accent600,
                  isLoading: _isActionLoading && _loadingAction == 'chat',
                  onTap: () {
                    if (!_isActionLoading) _startChat(profile.userId);
                  },
                ),
                _ContactActionButton(
                  icon: Icons.call,
                  label: l10n.helpCall,
                  color: AppColors.cta600,
                  isLoading: _isActionLoading && _loadingAction == 'voice',
                  onTap: () {
                    if (!_isActionLoading) _startCall(profile.userId, isVideo: false);
                  },
                ),
                _ContactActionButton(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: const Color(0xFF8B5CF6),
                  isLoading: _isActionLoading && _loadingAction == 'video',
                  onTap: () {
                    if (!_isActionLoading) _startCall(profile.userId, isVideo: true);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isActionLoading ? null : () => _startChat(profile.userId),
                icon: _isActionLoading && _loadingAction == 'chat'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text(l10n.jobSeekerMessage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutCard(String? description, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: context.theme.icon),
              const SizedBox(width: 8),
              Text(l10n.jobDescription, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description?.isNotEmpty == true ? description! : 'No bio provided.',
            style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(ExperienceItem exp, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.theme.cardBgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.theme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.theme.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.theme.border),
              ),
              child: const Icon(Icons.work_outline, size: 18, color: AppColors.accent600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.jobTitle ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.theme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    exp.company ?? '',
                    style: AppTextStyles.caption.copyWith(color: context.theme.textMuted),
                  ),
                ],
              ),
            ),
            if (exp.years != null && exp.years! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.theme.cardBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: context.theme.border),
                ),
                child: Text(
                  '${exp.years!.toStringAsFixed(exp.years!.truncateToDouble() == exp.years! ? 0 : 1)} yrs',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: context.theme.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(JobSeekerProfile profile, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_outlined, size: 20, color: context.theme.icon),
              const SizedBox(width: 8),
              Text(l10n.seekerExperience, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (profile.totalExperienceYears > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.theme.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${profile.totalExperienceYears.toStringAsFixed(profile.totalExperienceYears.truncateToDouble() == profile.totalExperienceYears ? 0 : 1)} yrs total',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: context.theme.textPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (profile.experiences != null && profile.experiences!.isNotEmpty) ...[
            ...profile.experiences!.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              final isLast = index == profile.experiences!.length - 1;
              return _buildExperienceItem(exp, isLast);
            }),
          ] else if (profile.experience != null && profile.experience!.isNotEmpty) ...[
            Text(profile.experience!, style: AppTextStyles.bodyMedium.copyWith(color: context.theme.textPrimary, height: 1.5)),
          ] else ...[
            Text('No work experience listed.', style: AppTextStyles.caption.copyWith(color: context.theme.textMuted, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  Widget _buildEducationCard(JobSeekerProfile profile, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, size: 20, color: context.theme.icon),
              const SizedBox(width: 8),
              Text(l10n.jobCategoryEducation, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          if (profile.educations != null && profile.educations!.isNotEmpty) ...[
            ...profile.educations!.map((edu) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.theme.cardBgElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: context.theme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: context.theme.cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accent200),
                          ),
                          child: const Icon(Icons.school, size: 18, color: AppColors.accent600),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                educationLevelLabel(edu.educationLevel, l10n),
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.theme.textPrimary),
                              ),
                              if (edu.fieldOfStudy != null && edu.fieldOfStudy!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  edu.fieldOfStudy!,
                                  style: AppTextStyles.caption.copyWith(color: context.theme.textMuted),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.theme.cardBgElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.theme.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: context.theme.cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent200),
                    ),
                    child: const Icon(Icons.school, size: 18, color: AppColors.accent600),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      educationLevelLabel(profile.educationLevel, l10n),
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: context.theme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCvCard(String cv, AppLocalizations l10n) {
    return WaveCard(
      useLiquidGlass: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.seekerCv, style: AppTextStyles.titleSmall.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text('PDF Document', style: AppTextStyles.caption.copyWith(color: context.theme.textMuted)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openCv(cv),
            icon: const Icon(Icons.download_outlined, size: 16),
            label: Text(l10n.seekerViewCv),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(jobSeekerDetailProvider(widget.profileId));
    final currentUserId = ref.watch(authStateProvider).user?.id;

    return Scaffold(
      backgroundColor: context.theme.scaffold,
      appBar: AppBar(
        title: Text(l10n.seekerProfileDetails),
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) {
          final isOwnProfile = currentUserId != null && profile.userId == currentUserId;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroCard(profile, l10n),
                const SizedBox(height: 16),
                _buildWaveMartContactCard(profile, isOwnProfile, l10n),
                const SizedBox(height: 16),
                _buildAboutCard(profile.description, l10n),
                const SizedBox(height: 16),
                _buildEducationCard(profile, l10n),
                const SizedBox(height: 16),
                _buildExperienceCard(profile, l10n),
                if (profile.cv != null) ...[
                  const SizedBox(height: 16),
                  _buildCvCard(profile.cv!, l10n),
                ],
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  l10n.commonError,
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  style: AppTextStyles.caption.copyWith(color: context.theme.textMuted),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(jobSeekerDetailProvider(widget.profileId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ContactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isLoading ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: color,
                      ),
                    )
                  : Icon(icon, size: 24, color: color),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: context.theme.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
