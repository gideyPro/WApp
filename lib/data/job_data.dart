import '../l10n/app_localizations.dart';

const jobTypes = [
  'full_time',
  'part_time',
  'contract',
  'temporary',
  'internship',
  'freelance'
];

const jobCategories = [
  'accounting',
  'it_software',
  'healthcare',
  'construction',
  'education',
  'marketing',
  'transport',
  'hospitality',
  'legal',
  'manufacturing',
  'admin_office',
  'customer_service',
  'other'
];

const educationLevels = [
  'none',
  'high_school',
  'tvet_diploma',
  'bachelors',
  'masters',
  'phd'
];

const genderOptions = [
  'any',
  'male',
  'female'
];

const salaryTypes = [
  'fixed',
  'range',
  'per_agreement'
];

String jobTypeLabel(String type, AppLocalizations l10n) {
  switch (type) {
    case 'full_time': return 'Full Time';
    case 'part_time': return 'Part Time';
    case 'contract': return 'Contract';
    case 'temporary': return 'Temporary';
    case 'internship': return 'Internship';
    case 'freelance': return 'Freelance';
    default: return type;
  }
}

String jobCategoryLabel(String category, AppLocalizations l10n) {
  switch (category) {
    case 'accounting': return 'Accounting & Finance';
    case 'it_software': return 'IT & Software';
    case 'healthcare': return 'Healthcare';
    case 'construction': return 'Construction & Real Estate';
    case 'education': return 'Education & Teaching';
    case 'marketing': return 'Marketing & Sales';
    case 'transport': return 'Transport & Logistics';
    case 'hospitality': return 'Hospitality & Tourism';
    case 'legal': return 'Legal Services';
    case 'manufacturing': return 'Manufacturing';
    case 'admin_office': return 'Admin & Office';
    case 'customer_service': return 'Customer Service';
    case 'other': return 'Other';
    default: return category;
  }
}

String educationLevelLabel(String level, AppLocalizations l10n) {
  switch (level) {
    case 'none': return 'None';
    case 'high_school': return 'High School';
    case 'tvet_diploma': return 'TVET / Diploma';
    case 'bachelors': return 'Bachelors Degree';
    case 'masters': return 'Masters Degree';
    case 'phd': return 'PhD';
    default: return level;
  }
}

String genderOptionLabel(String gender, AppLocalizations l10n) {
  switch (gender) {
    case 'any': return 'Any';
    case 'male': return 'Male';
    case 'female': return 'Female';
    default: return gender;
  }
}

String salaryTypeLabel(String type, AppLocalizations l10n) {
  switch (type) {
    case 'fixed': return 'Fixed';
    case 'range': return 'Range';
    case 'per_agreement': return 'Per Agreement';
    default: return type;
  }
}
