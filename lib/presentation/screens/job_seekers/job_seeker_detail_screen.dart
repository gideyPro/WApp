import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/job_data.dart';
import '../../../data/services/message_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_seeker_providers.dart';

class JobSeekerDetailScreen extends ConsumerStatefulWidget {
  final int profileId;
  const JobSeekerDetailScreen({super.key, required this.profileId});

  @override
  ConsumerState<JobSeekerDetailScreen> createState() => _JobSeekerDetailScreenState();
}

class _JobSeekerDetailScreenState extends ConsumerState<JobSeekerDetailScreen> {
  bool _isStartingChat = false;

  Future<void> _startChat(int userId) async {
    setState(() => _isStartingChat = true);
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
      if (mounted) setState(() => _isStartingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(jobSeekerDetailProvider(widget.profileId));
    final currentUserId = ref.watch(authStateProvider).user?.id;

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(title: Text(l10n.seekerProfileDetails)),
      body: profileAsync.when(
        data: (profile) {
          final isOwnProfile = currentUserId != null && profile.userId == currentUserId;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: profile.photo != null
                        ? CachedNetworkImage(
                            imageUrl: profile.photo!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    profile.fullName,
                    style: AppTextStyles.headline3.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    profile.professionalTitle,
                    style: AppTextStyles.title.copyWith(color: AppColors.stone500),
                  ),
                ),
                if (!isOwnProfile) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: _isStartingChat
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: () => _startChat(profile.userId),
                            icon: const Icon(Icons.chat_bubble_outline, size: 18),
                            label: Text(l10n.jobSeekerMessage),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.jobCategoryEducation),
                Text(educationLevelLabel(profile.educationLevel, l10n), style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                if (profile.jobCategory != null) ...[
                  _buildSectionTitle(l10n.jobJobCategory),
                  Text(jobCategoryLabel(profile.jobCategory!, l10n), style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                ],
                if (profile.experience != null) ...[
                  _buildSectionTitle(l10n.seekerExperience),
                  Text(profile.experience!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                ],
                if (profile.description != null) ...[
                  _buildSectionTitle(l10n.jobDescription),
                  Text(profile.description!, style: AppTextStyles.bodyMedium),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
