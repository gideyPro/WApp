import 'job_requirement_item.dart';

class JobSeekerProfile {
  final int id;
  final int userId;
  final String professionalTitle;
  final String fullName;
  final String? photo;
  final String? cv;
  final String? jobCategory;
  final String educationLevel;
  final String? experience;
  final List<EducationItem>? educations;
  final List<ExperienceItem>? experiences;
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
    this.cv,
    this.jobCategory,
    required this.educationLevel,
    this.experience,
    this.educations,
    this.experiences,
    this.description,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  double get totalExperienceYears {
    if (experiences == null || experiences!.isEmpty) return 0.0;
    return experiences!.fold(0.0, (sum, item) => sum + (item.years ?? 0.0));
  }

  factory JobSeekerProfile.fromJson(Map<String, dynamic> json) {
    List<EducationItem>? parsedEducations;
    if (json['educations'] is List) {
      parsedEducations = (json['educations'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => EducationItem.fromJson(e))
          .toList();
    }

    List<ExperienceItem>? parsedExperiences;
    if (json['experiences'] is List) {
      parsedExperiences = (json['experiences'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ExperienceItem.fromJson(e))
          .toList();
    }

    return JobSeekerProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      professionalTitle: json['professional_title'] as String,
      fullName: json['full_name'] as String,
      photo: json['photo'] as String?,
      cv: json['cv'] as String?,
      jobCategory: json['job_category'] as String?,
      educationLevel: (json['education_level'] ?? 'other') as String,
      experience: json['experience'] as String?,
      educations: parsedEducations,
      experiences: parsedExperiences,
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
      'cv': cv,
      'job_category': jobCategory,
      'education_level': educationLevel,
      'experience': experience,
      if (educations != null) 'educations': educations!.map((e) => e.toJson()).toList(),
      if (experiences != null) 'experiences': experiences!.map((e) => e.toJson()).toList(),
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
    String? cv,
    String? jobCategory,
    String? educationLevel,
    String? experience,
    List<EducationItem>? educations,
    List<ExperienceItem>? experiences,
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
      cv: cv ?? this.cv,
      jobCategory: jobCategory ?? this.jobCategory,
      educationLevel: educationLevel ?? this.educationLevel,
      experience: experience ?? this.experience,
      educations: educations ?? this.educations,
      experiences: experiences ?? this.experiences,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
