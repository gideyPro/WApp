import '../../core/utils/type_utils.dart';
import '../../l10n/app_localizations.dart';
import '../job_data.dart';

class EducationItem {
  final String educationLevel;
  final String? fieldOfStudy;
  /// Custom text for the "Other" level only; sent to the API through the
  /// companion `*_custom` field (not part of the item JSON).
  final String? customText;

  const EducationItem({
    required this.educationLevel,
    this.fieldOfStudy,
    this.customText,
  });

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      educationLevel: (json['education_level'] ?? 'other').toString(),
      fieldOfStudy: json['field_of_study']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'education_level': educationLevel,
      if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty)
        'field_of_study': fieldOfStudy,
    };
  }

  String displayLabel(AppLocalizations l10n) {
    final custom = customText?.trim() ?? '';
    final levelLabel = (educationLevel == 'other' && custom.isNotEmpty)
        ? custom
        : educationLevelLabel(educationLevel, l10n);
    if (fieldOfStudy != null && fieldOfStudy!.trim().isNotEmpty) {
      return '$levelLabel - ${fieldOfStudy!.trim()}';
    }
    return levelLabel;
  }

  EducationItem copyWith({
    String? educationLevel,
    String? fieldOfStudy,
    String? customText,
  }) {
    return EducationItem(
      educationLevel: educationLevel ?? this.educationLevel,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      customText: customText ?? this.customText,
    );
  }

  @override
  String toString() => 'EducationItem($educationLevel, $fieldOfStudy)';
}

class ExperienceItem {
  final String? jobTitle;
  final String? company;
  final double? years;

  const ExperienceItem({
    this.jobTitle,
    this.company,
    this.years,
  });

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      jobTitle: json['job_title']?.toString(),
      company: json['company']?.toString(),
      years: TypeUtils.safeDouble(json['years']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (jobTitle != null && jobTitle!.isNotEmpty) 'job_title': jobTitle,
      if (company != null && company!.isNotEmpty) 'company': company,
      if (years != null) 'years': years,
    };
  }

  String displayLabel() {
    final title = jobTitle?.trim() ?? '';
    final comp = company?.trim() ?? '';
    final yrStr = years != null ? '${years!.toStringAsFixed(years! % 1 == 0 ? 0 : 1)} yrs' : '';

    final parts = <String>[];
    if (title.isNotEmpty && comp.isNotEmpty) {
      parts.add('$title at $comp');
    } else if (title.isNotEmpty) {
      parts.add(title);
    } else if (comp.isNotEmpty) {
      parts.add(comp);
    }

    if (yrStr.isNotEmpty) {
      parts.add('($yrStr)');
    }

    return parts.join(' ');
  }

  ExperienceItem copyWith({
    String? jobTitle,
    String? company,
    double? years,
  }) {
    return ExperienceItem(
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      years: years ?? this.years,
    );
  }

  @override
  String toString() => 'ExperienceItem($jobTitle, $company, $years)';
}
