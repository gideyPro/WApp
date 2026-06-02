import 'package:kenat/kenat.dart';

class EthiopianDateHelper {
  EthiopianDateHelper._();

  static const _monthNamesEn = MonthNames.english;
  static const _monthNamesAm = MonthNames.amharic;
  static const _monthNamesTi = [
    'መስከረም', 'ጥቅምቲ', 'ሕዳር', 'ታሕሳስ', 'ጥሪ', 'ለካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰነ', 'ሓምለ', 'ነሓሰ', 'ጳጉሜ',
  ];

  static String _monthName(int month, String locale) {
    switch (locale) {
      case 'am':
        return _monthNamesAm[month - 1];
      case 'ti':
        return _monthNamesTi[month - 1];
      default:
        return _monthNamesEn[month - 1];
    }
  }

  /// Formats a Gregorian [DateTime] as an Ethiopian date string.
  /// Returns e.g. "Tikimt 12, 2018 ዓ/ም" or "ጥቅምት 12, 2018 ዓ/ም".
  static String formatEthiopian(DateTime greg, [String locale = 'en']) {
    final kenat = Kenat(greg);
    final eth = kenat.getEthiopian();
    final month = _monthName(eth['month'] as int, locale);
    return '$month ${eth['day']}, ${eth['year']} ዓ/ም';
  }

  /// Formats a year integer as a dual Gregorian/Ethiopian display.
  /// Returns e.g. "2026 / 2018 ዓ/ም".
  /// Uses Jan 1 as the reference date so the Ethiopian year shown
  /// is the one covering most of the Gregorian year.
  static String formatYear(int gregYear) {
    final ref = DateTime(gregYear, 1, 1);
    final kenat = Kenat(ref);
    final eth = kenat.getEthiopian();
    return '$gregYear / ${eth['year']} ዓ/ም';
  }

  /// Returns just the Ethiopian year suffix e.g. "2018 ዓ/ም"
  /// for a given Gregorian year.
  static String toEthiopianYearSuffix(int gregYear) {
    final ref = DateTime(gregYear, 1, 1);
    final kenat = Kenat(ref);
    final eth = kenat.getEthiopian();
    return '${eth['year']} ዓ/ም';
  }

  /// Formats a Gregorian [DateTime] with both calendars side by side.
  /// Returns e.g. "Mar 12, 2026 / መጋቢት 03, 2018".
  static String formatDual(DateTime greg, [String locale = 'en']) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final gregStr = '${months[greg.month - 1]} ${greg.day}, ${greg.year}';
    final kenat = Kenat(greg);
    final eth = kenat.getEthiopian();
    final month = _monthName(eth['month'] as int, locale);
    return '$gregStr / $month ${eth['day']}, ${eth['year']}';
  }
}
