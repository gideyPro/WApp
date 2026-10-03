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
  final lang = l10n.localeName;
  if (lang == 'am') {
    switch (type) {
      case 'full_time': return 'ሙሉ ጊዜ';
      case 'part_time': return 'የትርፍ ጊዜ';
      case 'contract': return 'ኮንትራት';
      case 'temporary': return 'ጊዜያዊ';
      case 'internship': return 'ልምምድ';
      case 'freelance': return 'ፍሪላንስ';
    }
  } else if (lang == 'ti') {
    switch (type) {
      case 'full_time': return 'ሙሉ ግዜ';
      case 'part_time': return 'ናይ ትርፊ ግዜ';
      case 'contract': return 'ኮንትራት';
      case 'temporary': return 'ግዚያዊ';
      case 'internship': return 'ልምምድ';
      case 'freelance': return 'ፍሪላንስ';
    }
  }
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
  final lang = l10n.localeName;
  if (lang == 'am') {
    switch (category) {
      case 'accounting': return 'አካውንቲንግ እና ፋይናንስ';
      case 'it_software': return 'አይቲ እና ሶፍትዌር';
      case 'healthcare': return 'ጤና ጥበቃ';
      case 'construction': return 'ኮንስትራክሽን እና ሪል ስቴት';
      case 'education': return 'ትምህርት እና ማስተማር';
      case 'marketing': return 'ሽያጭ እና ማርኬቲንግ';
      case 'transport': return 'ትራንስፖርት እና ሎጂስቲክስ';
      case 'hospitality': return 'ሆስፒታሊቲ እና ቱሪዝም';
      case 'legal': return 'የህግ አገልግሎት';
      case 'manufacturing': return 'ማኑፋክቸሪንግ';
      case 'admin_office': return 'አስተዳደር እና ቢሮ';
      case 'customer_service': return 'የደንበኞች አገልግሎት';
      case 'other': return 'ሌላ';
    }
  } else if (lang == 'ti') {
    switch (category) {
      case 'accounting': return 'ኣካውንቲንግን ፋይናንስን';
      case 'it_software': return 'ኣይቲን ሶፍትዌርን';
      case 'healthcare': return 'ክንክን ጥዕና';
      case 'construction': return 'ህንፃን ሪል ስቴትን';
      case 'education': return 'ትምህርትን ምምሃርን';
      case 'marketing': return 'ሸያጥን ዕዳጋን';
      case 'transport': return 'ትራንስፖርትን ሎጂስቲክስን';
      case 'hospitality': return 'ሆስፒታሊቲን ቱሪዝምን';
      case 'legal': return 'ሕጋዊ ኣገልግሎት';
      case 'manufacturing': return 'ማኑፋክቸሪንግ';
      case 'admin_office': return 'ምምሕዳርን ቤት ጽሕፈትን';
      case 'customer_service': return 'ኣገልግሎት ዓማዊል';
      case 'other': return 'ካልእ';
    }
  }
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
  final lang = l10n.localeName;
  if (lang == 'am') {
    switch (level) {
      case 'none': return 'ምንም';
      case 'high_school': return 'ሁለተኛ ደረጃ';
      case 'tvet_diploma': return 'ዲፕሎማ / TVET';
      case 'bachelors': return 'የመጀመሪያ ዲግሪ';
      case 'masters': return 'ማስተርስ ዲግሪ';
      case 'phd': return 'ዶክትሬት (PhD)';
    }
  } else if (lang == 'ti') {
    switch (level) {
      case 'none': return 'ዋላ ሓደ';
      case 'high_school': return 'ካልኣይ ብርኪ';
      case 'tvet_diploma': return 'ዲፕሎማ / TVET';
      case 'bachelors': return 'ቀዳማይ ዲግሪ';
      case 'masters': return 'ማስተርስ ዲግሪ';
      case 'phd': return 'ዶክትሬት (PhD)';
    }
  }
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
  final lang = l10n.localeName;
  if (lang == 'am') {
    switch (gender) {
      case 'any': return 'ማንኛውም';
      case 'male': return 'ወንድ';
      case 'female': return 'ሴት';
    }
  } else if (lang == 'ti') {
    switch (gender) {
      case 'any': return 'ዝኾነ';
      case 'male': return 'ተባዕታይ';
      case 'female': return 'ኣንስተይቲ';
    }
  }
  switch (gender) {
    case 'any': return 'Any';
    case 'male': return 'Male';
    case 'female': return 'Female';
    default: return gender;
  }
}

String salaryTypeLabel(String type, AppLocalizations l10n) {
  final lang = l10n.localeName;
  if (lang == 'am') {
    switch (type) {
      case 'fixed': return 'ቋሚ';
      case 'range': return 'ተለዋዋጭ (ከ-እስከ)';
      case 'per_agreement': return 'በስምምነት';
    }
  } else if (lang == 'ti') {
    switch (type) {
      case 'fixed': return 'ቀዋሚ';
      case 'range': return 'ካብ-ክሳብ';
      case 'per_agreement': return 'ብስምምነት';
    }
  }
  switch (type) {
    case 'fixed': return 'Fixed';
    case 'range': return 'Range';
    case 'per_agreement': return 'Per Agreement';
    default: return type;
  }
}
