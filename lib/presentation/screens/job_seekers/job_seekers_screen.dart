import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/job_seeker_card.dart';
import '../../providers/job_seeker_providers.dart';
import '../../widgets/common/wave_common_widgets.dart';

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
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(jobSeekerProfilesProvider);
    
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: WaveAppBar(title: Text(l10n.seekersTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null && state.profiles.isEmpty
              ? WaveMessageScreen.error(
                  isEmbedded: true,
                  subtitle: state.errorMessage!,
                  onRetry: () => ref.read(jobSeekerProfilesProvider.notifier).loadProfiles(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(jobSeekerProfilesProvider.notifier).loadProfiles();
                  },
                  child: state.profiles.isEmpty
                      ? WaveEmptyState(
                          icon: Icons.person_search_outlined,
                          title: l10n.seekersNoResults,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: state.profiles.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.profiles.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            return JobSeekerCard(profile: state.profiles[index]);
                          },
                        ),
                ),
    );
  }
}
