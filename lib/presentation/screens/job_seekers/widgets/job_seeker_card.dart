import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/job_seeker_profile.dart';
import '../../../../core/theme/text_styles.dart';

class JobSeekerCard extends StatelessWidget {
  final JobSeekerProfile profile;
  const JobSeekerCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/job-seekers/${profile.id}'),
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person)),
            const SizedBox(height: 8),
            Text(profile.fullName, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(profile.professionalTitle, textAlign: TextAlign.center, style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }
}
