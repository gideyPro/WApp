import 'job_requirement_item.dart';

class JobFormData {
  // Job-specific fields
  String? title;
  String? companyName;
  String jobType = 'full_time';
  String jobCategory = '';
  int positionsCount = 1;
  String salaryType = 'per_agreement';
  double? salaryMin;
  double? salaryMax;
  String salaryCurrency = 'ETB';
  String? reqEducation;
  String? reqEducationCustom;
  List<EducationItem> reqEducations = [];
  String? reqExperience;
  List<ExperienceItem> reqExperiences = [];
  String reqGender = 'any';
  String? description;
  DateTime? deadline;

  // Common fields (match CarFormData pattern)
  int? addressRegion, addressZone, addressWoreda, addressKebele, addressId;
  String? specificLocation;
  List<dynamic> images = []; // File or XFile
  bool termsAccepted = false;
  int? agentId;
  bool postedByAgent = false;
  
  JobFormData({
    this.title,
    this.companyName,
    this.jobType = 'full_time',
    this.jobCategory = '',
    this.positionsCount = 1,
    this.salaryType = 'per_agreement',
    this.salaryMin,
    this.salaryMax,
    this.salaryCurrency = 'ETB',
    this.reqEducation,
    this.reqEducationCustom,
    List<EducationItem>? reqEducations,
    this.reqExperience,
    List<ExperienceItem>? reqExperiences,
    this.reqGender = 'any',
    this.description,
    this.deadline,
    this.addressRegion,
    this.addressZone,
    this.addressWoreda,
    this.addressKebele,
    this.addressId,
    this.specificLocation,
    List<dynamic>? images,
    this.termsAccepted = false,
    this.agentId,
    this.postedByAgent = false,
  })  : reqEducations = reqEducations ?? [],
        reqExperiences = reqExperiences ?? [],
        images = images ?? [];

  JobFormData copyWith({
    String? title,
    String? companyName,
    String? jobType,
    String? jobCategory,
    int? positionsCount,
    String? salaryType,
    double? salaryMin,
    double? salaryMax,
    String? salaryCurrency,
    String? reqEducation,
    String? reqEducationCustom,
    List<EducationItem>? reqEducations,
    String? reqExperience,
    List<ExperienceItem>? reqExperiences,
    String? reqGender,
    String? description,
    DateTime? deadline,
    int? addressRegion,
    int? addressZone,
    int? addressWoreda,
    int? addressKebele,
    int? addressId,
    String? specificLocation,
    List<dynamic>? images,
    bool? termsAccepted,
    int? agentId,
    bool? postedByAgent,
  }) {
    return JobFormData(
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      jobType: jobType ?? this.jobType,
      jobCategory: jobCategory ?? this.jobCategory,
      positionsCount: positionsCount ?? this.positionsCount,
      salaryType: salaryType ?? this.salaryType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      reqEducation: reqEducation ?? this.reqEducation,
      reqEducationCustom: reqEducationCustom ?? this.reqEducationCustom,
      reqEducations: reqEducations ?? this.reqEducations,
      reqExperience: reqExperience ?? this.reqExperience,
      reqExperiences: reqExperiences ?? this.reqExperiences,
      reqGender: reqGender ?? this.reqGender,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      addressRegion: addressRegion ?? this.addressRegion,
      addressZone: addressZone ?? this.addressZone,
      addressWoreda: addressWoreda ?? this.addressWoreda,
      addressKebele: addressKebele ?? this.addressKebele,
      addressId: addressId ?? this.addressId,
      specificLocation: specificLocation ?? this.specificLocation,
      images: images ?? this.images,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      agentId: agentId ?? this.agentId,
      postedByAgent: postedByAgent ?? this.postedByAgent,
    );
  }
}
