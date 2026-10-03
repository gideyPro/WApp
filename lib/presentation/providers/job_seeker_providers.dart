import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/job_seeker_service.dart';
import '../../data/models/job_seeker_profile.dart';

final jobSeekerServiceProvider = Provider<JobSeekerService>((ref) {
  return JobSeekerService();
});

class JobSeekerProfilesState {
  final List<JobSeekerProfile> profiles;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;

  const JobSeekerProfilesState({
    this.profiles = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasMore = false,
  });

  const JobSeekerProfilesState.initial()
      : profiles = const [],
        isLoading = false,
        isLoadingMore = false,
        errorMessage = null,
        currentPage = 1,
        totalPages = 1,
        total = 0,
        hasMore = false;

  JobSeekerProfilesState copyWith({
    List<JobSeekerProfile>? profiles,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
  }) {
    return JobSeekerProfilesState(
      profiles: profiles ?? this.profiles,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class JobSeekerProfilesNotifier extends StateNotifier<JobSeekerProfilesState> {
  final JobSeekerService _service;

  JobSeekerProfilesNotifier(this._service) : super(const JobSeekerProfilesState.initial());

  Future<void> loadProfiles({int page = 1, Map<String, dynamic>? filters}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await _service.getProfiles(page: page, filters: filters);
      
      final newProfiles = <JobSeekerProfile>[
        if (page != 1) ...state.profiles,
        ...?response.profiles,
      ];

      state = state.copyWith(
        profiles: newProfiles,
        isLoading: false,
        isLoadingMore: false,
        currentPage: response.currentPage ?? page,
        totalPages: response.totalPages ?? 1,
        total: response.total ?? 0,
        hasMore: (response.currentPage ?? page) < (response.totalPages ?? 1),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const JobSeekerProfilesState.initial();
  }
}

final jobSeekerProfilesProvider = StateNotifierProvider<JobSeekerProfilesNotifier, JobSeekerProfilesState>((ref) {
  return JobSeekerProfilesNotifier(ref.watch(jobSeekerServiceProvider));
});

final jobSeekerDetailProvider = FutureProvider.family<JobSeekerProfile, int>((ref, profileId) async {
  final service = ref.watch(jobSeekerServiceProvider);
  final response = await service.getProfile(profileId);
  if (response.profile != null) {
    return response.profile!;
  }
  throw Exception(response.message ?? 'Failed to load profile');
});

final myJobSeekerProfileProvider = FutureProvider<JobSeekerProfile?>((ref) async {
  final service = ref.watch(jobSeekerServiceProvider);
  final response = await service.getMyProfile();
  return response.profile;
});
