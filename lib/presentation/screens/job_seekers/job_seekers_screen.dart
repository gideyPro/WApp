import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/job_seeker_card.dart';
import '../../providers/job_seeker_providers.dart';

class JobSeekersScreen extends ConsumerStatefulWidget {
  const JobSeekersScreen({super.key});

  @override
  ConsumerState<JobSeekersScreen> createState() => _JobSeekersScreenState();
}

class _JobSeekersScreenState extends ConsumerState<JobSeekersScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobSeekerProfilesProvider.notifier).loadProfiles();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final state = ref.read(jobSeekerProfilesProvider);
      if (state.hasMore && !state.isLoadingMore) {
        final page = state.currentPage + 1;
        ref.read(jobSeekerProfilesProvider.notifier).loadProfiles(page: page);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSeekerProfilesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primary50,
      appBar: AppBar(title: const Text('Job Seekers')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.profiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.errorMessage!, style: const TextStyle(color: AppColors.stone500)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(jobSeekerProfilesProvider.notifier).loadProfiles(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(jobSeekerProfilesProvider.notifier).loadProfiles();
                  },
                  child: state.profiles.isEmpty
                      ? const Center(child: Text('No job seekers found'))
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: state.profiles.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.profiles.length) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            }
                            return JobSeekerCard(profile: state.profiles[index]);
                          },
                        ),
                ),
    );
  }
}
