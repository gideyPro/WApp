/// User model
class User {
  final int id;
  final String firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String phoneNumber;
  final String? role;
  final String? gender;
  final bool isPhoneVerified;
  final bool isKycVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    this.lastName,
    this.username,
    this.email,
    required this.phoneNumber,
    this.role,
    this.gender,
    this.isPhoneVerified = false,
    this.isKycVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'],
      gender: json['gender'],
      isPhoneVerified: json['is_phone_verified'] ?? false,
      isKycVerified: json['is_kyc_verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'gender': gender,
      'is_phone_verified': isPhoneVerified,
      'is_kyc_verified': isKycVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName ${lastName ?? ''}'.trim();
  
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0] : '';
    final lastInitial = lastName?.isNotEmpty ?? false ? lastName![0] : '';
    return '$firstInitial$lastInitial'.toUpperCase();
  }

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isStaff => isAdmin || isModerator;

  @override
  String toString() => 'User(id: $id, firstName: $firstName, phoneNumber: $phoneNumber)';
}
