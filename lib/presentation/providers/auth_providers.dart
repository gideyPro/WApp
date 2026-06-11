import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/profile_service.dart';

/// Profile Provider
final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileServiceProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _profileService;
  ProfileNotifier(this._profileService) : super(const ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _profileService.getProfile();
    if (response.success && response.user != null) {
      state = ProfileState.loaded(response.user!, stats: response.stats);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await _profileService.updateProfile(data);
    if (response.success && response.user != null) {
      state = ProfileState.loaded(response.user!, stats: state.stats);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
    return response.success;
  }
}

class ProfileState {
  final bool isLoading;
  final dynamic user;
  final ProfileStats? stats;
  final String? errorMessage;
  const ProfileState(
      {required this.isLoading, this.user, this.stats, this.errorMessage});
  const ProfileState.initial()
      : isLoading = true,
        user = null,
        stats = null,
        errorMessage = null;
  const ProfileState.loaded(this.user, {this.stats})
      : isLoading = false,
        errorMessage = null;
  ProfileState copyWith(
      {bool? isLoading,
      dynamic user,
      ProfileStats? stats,
      String? errorMessage}) {
    return ProfileState(
        isLoading: isLoading ?? this.isLoading,
        user: user ?? this.user,
        stats: stats ?? this.stats,
        errorMessage: errorMessage);
  }
}
