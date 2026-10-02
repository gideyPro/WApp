class JobSeekerProfile {
  final int id;
  final int userId;
  final String professionalTitle;
  final String fullName;
  final String? photo;
  final String? jobCategory;
  final String educationLevel;
  final String? experience;
  final String? description;
  final bool isPublic;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobSeekerProfile({
    required this.id,
    required this.userId,
    required this.professionalTitle,
    required this.fullName,
    this.photo,
    this.jobCategory,
    required this.educationLevel,
    this.experience,
    this.description,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    return JobSeekerProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      professionalTitle: json['professional_title'] as String,
      fullName: json['full_name'] as String,
      photo: json['photo'] as String?,
      jobCategory: json['job_category'] as String?,
      educationLevel: json['education_level'] as String,
      experience: json['experience'] as String?,
      description: json['description'] as String?,
      isPublic: json['is_public'] == 1 || json['is_public'] == true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'professional_title': professionalTitle,
      'full_name': fullName,
      'photo': photo,
      'job_category': jobCategory,
      'education_level': educationLevel,
      'experience': experience,
      'description': description,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  JobSeekerProfile copyWith({
    int? id,
    int? userId,
    String? professionalTitle,
    String? fullName,
    String? photo,
    String? jobCategory,
    String? educationLevel,
    String? experience,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobSeekerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      fullName: fullName ?? this.fullName,
      photo: photo ?? this.photo,
      jobCategory: jobCategory ?? this.jobCategory,
      educationLevel: educationLevel ?? this.educationLevel,
      experience: experience ?? this.experience,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
