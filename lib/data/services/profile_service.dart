import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../../core/network/error_handler.dart';
import '../models/user.dart';

/// Service for user profile management
class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Get current user profile
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);

      if (response.statusCode == 200 && response.data is Map) {
        final responseData = response.data as Map;
        final data = responseData['data'] is Map ? responseData['data'] : responseData;
        final user = User.fromJson(data is Map ? data as Map<String, dynamic> : {});
        final stats = responseData['stats'];

        return ProfileResponse(
          success: true,
          user: user,
          stats: stats is Map ? ProfileStats.fromJson(stats as Map<String, dynamic>) : null,
        );
      }

      return ProfileResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to fetch profile'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Update user profile
  Future<ProfileResponse> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiConstants.updateProfile,
        data: profileData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final user = (responseData is Map && responseData['data'] is Map)
            ? User.fromJson(responseData['data'] as Map<String, dynamic>)
            : null;

        return ProfileResponse(
          success: true,
          message: _extractMessage(responseData, 'Profile updated successfully'),
          user: user,
        );
      }

      return ProfileResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to update profile'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Delete user account
  Future<ProfileResponse> deleteAccount() async {
    try {
      final response = await _apiClient.dio.delete(ApiConstants.deleteProfile);

      if (response.statusCode == 200) {
        return ProfileResponse(
          success: true,
          message: _extractMessage(response.data, 'Account deleted successfully'),
        );
      }

      return ProfileResponse(
        success: false,
        message: _extractMessage(response.data, 'Failed to delete account'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Get public user profile
  Future<ProfileResponse> getPublicProfile(int userId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.publicProfile}/$userId',
      );

      if (response.statusCode == 200 && response.data is Map) {
        final responseData = response.data as Map;
        final userData = responseData['data'] is Map 
            ? (responseData['data']?['user'] ?? responseData['data'])
            : responseData;
            
        final user = User.fromJson(userData is Map ? userData as Map<String, dynamic> : {});
        return ProfileResponse(success: true, user: user);
      }

      return ProfileResponse(
        success: false,
        message: _extractMessage(response.data, 'User not found'),
      );
    } catch (e) {
      final exception = ApiErrorHandler.handle(e);
      return ProfileResponse(
        success: false,
        message: exception.toString().replaceAll(RegExp(r'^\w+: '), ''),
      );
    }
  }

  /// Helper to extract list from dynamic response
  List<dynamic> _extractList(dynamic raw) {
    if (raw is List) return raw;
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    return [];
  }

  /// Helper to extract message from dynamic response
  String _extractMessage(dynamic raw, String defaultMessage) {
    if (raw is Map && raw['message'] != null) {
      return raw['message'].toString();
    }
    return defaultMessage;
  }
}

/// Response wrapper for profile operations
class ProfileResponse {
  final bool success;
  final String message;
  final User? user;
  final ProfileStats? stats;

  const ProfileResponse({
    required this.success,
    this.message = '',
    this.user,
    this.stats,
  });
}

/// User profile statistics
class ProfileStats {
  final int totalListings;
  final int totalFavorites;
  final int unreadMessages;

  const ProfileStats({
    this.totalListings = 0,
    this.totalFavorites = 0,
    this.unreadMessages = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalListings: json['total_listings'] ?? 0,
      totalFavorites: json['total_favorites'] ?? 0,
      unreadMessages: json['unread_messages'] ?? 0,
    );
  }
}
