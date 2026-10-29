import '../../../core/utils/type_utils.dart';
import 'account_user.dart';

/// Account counters returned with the profile.
class ProfileStats {
  final int listings;
  final int favorites;
  final int interests;
  final int unreadMessages;

  const ProfileStats({
    this.listings = 0,
    this.favorites = 0,
    this.interests = 0,
    this.unreadMessages = 0,
  });

  factory ProfileStats.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return ProfileStats(
      listings: TypeUtils.safeInt(map['listings']) ?? 0,
      favorites: TypeUtils.safeInt(map['favorites']) ?? 0,
      interests: TypeUtils.safeInt(map['interests']) ?? 0,
      unreadMessages: TypeUtils.safeInt(map['unread_messages']) ?? 0,
    );
  }
}

/// Payload of `GET /me`.
class Profile {
  final AccountUser user;
  final ProfileStats stats;

  const Profile({required this.user, this.stats = const ProfileStats()});

  factory Profile.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException('Profile response is missing the user object');
    }

    return Profile(
      user: AccountUser.fromJson(Map<String, dynamic>.from(rawUser)),
      stats: ProfileStats.fromJson(json['stats']),
    );
  }
}
