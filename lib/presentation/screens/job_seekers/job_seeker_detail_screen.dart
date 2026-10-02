import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../providers/job_seeker_providers.dart';

class JobSeekerDetailScreen extends ConsumerWidget {
  final int profileId;
  const JobSeekerDetailScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(jobSeekerDetailProvider(profileId));

    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(title: const Text('Profile Details')),
      body: profileAsync.when(
        data: (profile) {
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
                const SizedBox(height: 24),
                _buildSectionTitle('Education'),
                Text(profile.educationLevel, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                if (profile.jobCategory != null) ...[
                  _buildSectionTitle('Category'),
                  Text(profile.jobCategory!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                ],
                if (profile.experience != null) ...[
                  _buildSectionTitle('Experience'),
                  Text(profile.experience!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                ],
                if (profile.description != null) ...[
                  _buildSectionTitle('About'),
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
