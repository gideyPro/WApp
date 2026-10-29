import '../../../core/utils/type_utils.dart';
import '../user.dart';

/// KYC state as exposed by the v2 user projection.
class UserKyc {
  final bool verified;
  final String? status;

  const UserKyc({this.verified = false, this.status});

  factory UserKyc.fromJson(dynamic json) {
    final map = json is Map ? json : const {};
    return UserKyc(
      verified: TypeUtils.safeBool(map['verified']),
      status: _text(map['status']),
    );
  }
}

/// Authenticated account shape. Named [AccountUser] so it can coexist with the
/// legacy `User` model while screens migrate.
class AccountUser {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String? username;
  final String? email;
  final String phoneNumber;
  final String? gender;
  final String role;
  final String? avatarUrl;
  final String? authProvider;
  final bool phoneVerified;
  final UserKyc kyc;
  final DateTime? createdAt;

  const AccountUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.phoneNumber,
    this.username,
    this.email,
    this.gender,
    this.role = 'user',
    this.avatarUrl,
    this.authProvider,
    this.phoneVerified = false,
    this.kyc = const UserKyc(),
    this.createdAt,
  });

  bool get isKycVerified => kyc.verified;

  bool get isStaff => role == 'admin' || role == 'moderator';

  bool get isAgent => role == 'agent';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return (first + last).toUpperCase();
  }

  User toUser() {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      gender: gender,
      isPhoneVerified: phoneVerified,
      isKycVerified: isKycVerified,
      googleAvatar: avatarUrl,
      createdAt: createdAt,
    );
  }

  factory AccountUser.fromJson(Map<String, dynamic> json) {
    return AccountUser(
      id: TypeUtils.safeInt(json['id']) ?? 0,
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: _text(json['username']),
      email: _text(json['email']),
      phoneNumber: json['phone_number']?.toString() ?? '',
      gender: _text(json['gender']),
      role: json['role']?.toString() ?? 'user',
      avatarUrl: _text(json['avatar_url']),
      authProvider: _text(json['auth_provider']),
      phoneVerified: TypeUtils.safeBool(json['phone_verified']),
      kyc: UserKyc.fromJson(json['kyc']),
      createdAt: _date(json['created_at']),
    );
  }
}

String? _text(dynamic value) {
  final text = value?.toString();
  return (text == null || text.isEmpty) ? null : text;
}

DateTime? _date(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
