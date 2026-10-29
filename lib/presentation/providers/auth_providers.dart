import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/v2/api_v2_error.dart';
import '../../data/models/v2/profile.dart';
import '../../data/services/v2/profile_service.dart';
import 'v2_providers.dart';

/// Profile Provider backed by `/v2/me`
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileV2ServiceProvider));
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileServiceV2 _profileService;
  ProfileNotifier(this._profileService) : super(const ProfileState.initial());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _profileService.fetch();
      state = ProfileState.loaded(profile.user.toUser(), stats: profile.stats);
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load profile',
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updatedUser = await _profileService.update(
        firstName: data['first_name'] as String?,
        lastName: data['last_name'] as String?,
        email: data['email'] as String?,
        gender: data['gender'] as String?,
      );
      state = ProfileState.loaded(updatedUser.toUser(), stats: state.stats);
      return true;
    } on ApiV2Exception catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not update profile',
      );
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _profileService.deleteAccount();
      return true;
    } catch (_) {
      return false;
    }
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
