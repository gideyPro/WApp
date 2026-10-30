import 'package:flutter/foundation.dart';
import 'package:kenat/kenat.dart';

/// Immutable representation of a date in the Ethiopian Calendar (ዓመተ ምሕረት).
///
/// Handles the 13-month calendar system:
/// - Months 1 to 12 have exactly 30 days each.
/// - Month 13 (Pagume / ጳጉሜ) has 5 days in common years, or 6 days in leap years.
///
/// Seamlessly converts to and from standard Dart [DateTime] (Gregorian).
@immutable
class EthiopianDate implements Comparable<EthiopianDate> {
  final int year;
  final int month;
  final int day;

  /// Creates an [EthiopianDate].
  ///
  /// Throws [ArgumentError] if the date is invalid (e.g. month < 1 or > 13,
  /// day < 1 or day > 30, or Pagume day > 5/6 depending on leap year).
  EthiopianDate(this.year, this.month, this.day) {
    if (month < 1 || month > 13) {
      throw ArgumentError.value(
        month,
        'month',
        'Ethiopian month must be between 1 and 13.',
      );
    }
    final maxDays = month == 13 ? (isLeapYear ? 6 : 5) : 30;
    if (day < 1 || day > maxDays) {
      throw ArgumentError.value(
        day,
        'day',
        'Ethiopian day for month $month in year $year must be between 1 and $maxDays.',
      );
    }
  }

  /// Internal unchecked constructor for trusted conversions.
  const EthiopianDate._raw(this.year, this.month, this.day);

  /// Whether this Ethiopian year is a leap year (ዘመነ ሉቃስ, year % 4 == 3).
  bool get isLeapYear => year % 4 == 3;

  /// Maximum number of days in the current month (30, or 5/6 for Pagume).
  int get maxDaysInMonth => month == 13 ? (isLeapYear ? 6 : 5) : 30;

  /// The current Ethiopian date based on system time.
  factory EthiopianDate.now() {
    return EthiopianDate.fromGregorian(DateTime.now());
  }

  /// Converts a Gregorian [DateTime] to [EthiopianDate].
  factory EthiopianDate.fromGregorian(DateTime gregorian) {
    final ec = Conversions.toEC(gregorian.year, gregorian.month, gregorian.day);
    return EthiopianDate._raw(ec['year']!, ec['month']!, ec['day']!);
  }

  /// Converts this [EthiopianDate] to a standard Gregorian [DateTime].
  DateTime toGregorian([int hour = 0, int minute = 0, int second = 0]) {
    final gc = Conversions.toGC(year, month, day);
    return DateTime(gc['year']!, gc['month']!, gc['day']!, hour, minute, second);
  }

  /// Parses an Ethiopian date string formatted as `YYYY-MM-DD` or `YYYY/MM/DD`.
  static EthiopianDate? tryParse(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final clean = input.trim();
    final parts = clean.contains('/') ? clean.split('/') : clean.split('-');
    if (parts.length != 3) return null;

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;

    try {
      return EthiopianDate(y, m, d);
    } catch (_) {
      return null;
    }
  }

  /// Formats this date using the specified [locale] ('am', 'ti', 'om'/'ao', 'en').
  ///
  /// Example: "ጥቅምት 19, 2017 ዓ/ም" or "Tikimt 19, 2017 ዓ/ም".
  String format([String locale = 'am']) {
    final mName = EthiopianDateHelper.monthName(month, locale);
    return '$mName $day, $year ዓ/ም';
  }

  /// Formats this date side by side with its Gregorian counterpart.
  ///
  /// Example: "ጥቅምት 19, 2017 (2024-10-29)"
  String formatDual([String locale = 'am']) {
    final greg = toGregorian();
    final gregStr =
        '${greg.year}-${greg.month.toString().padLeft(2, '0')}-${greg.day.toString().padLeft(2, '0')}';
    return '${format(locale)} ($gregStr)';
  }

  /// Adds [days] to this date and returns the resulting [EthiopianDate].
  EthiopianDate addDays(int days) {
    final greg = toGregorian().add(Duration(days: days));
    return EthiopianDate.fromGregorian(greg);
  }

  /// Subtracts [days] from this date and returns the resulting [EthiopianDate].
  EthiopianDate subtractDays(int days) {
    return addDays(-days);
  }

  /// Returns a new [EthiopianDate] with updated fields.
  EthiopianDate copyWith({int? year, int? month, int? day}) {
    return EthiopianDate(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
    );
  }

  bool isBefore(EthiopianDate other) => compareTo(other) < 0;
  bool isAfter(EthiopianDate other) => compareTo(other) > 0;
  bool isAtSameMomentAs(EthiopianDate other) => compareTo(other) == 0;

  @override
  int compareTo(EthiopianDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EthiopianDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}

/// Helper service for Ethiopian calendar conversions, formatting, and localization.
class EthiopianDateHelper {
  EthiopianDateHelper._();

  static const List<String> _monthNamesEn = MonthNames.english;

  static const List<String> _monthNamesAm = [
    'መስከረም', 'ጥቅምት', 'ህዳር', 'ታህሳስ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ',
  ];

  static const List<String> _monthNamesTi = [
    'መስከረም', 'ጥቅምቲ', 'ሕዳር', 'ታሕሳስ', 'ጥሪ', 'ለካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰነ', 'ሓምለ', 'ነሓሰ', 'ጳጉሜ',
  ];

  static const List<String> _monthNamesOm = [
    'Fuulbaana', 'Onkololeessa', 'Sadaasa', 'Muddee', 'Amajjii', 'Guraandhala',
    'Bitootessa', 'Ebla', 'Caamsaa', 'Waxabajjii', 'Adooleessa', 'Hagayya', 'Qaammee',
  ];

  static const List<String> _weekdayNamesAm = [
    'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'አርብ', 'ቅዳሜ', 'እሑድ',
  ];

  static const List<String> _weekdayNamesTi = [
    'ሰኑይ', 'ሰሉስ', 'ረቡዕ', 'ሓሙስ', 'ዓርቢ', 'ቀዳም', 'ሰንበት',
  ];

  static const List<String> _weekdayNamesOm = [
    'Wixata', 'Kibxata', 'Roobii', 'Kamiisa', 'Jimaata', 'Sanbata', 'Dilbata',
  ];

  static const List<String> _weekdayNamesEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// Returns the localized name for an Ethiopian month (1 to 13).
  static String monthName(int month, [String locale = 'en']) {
    final norm = _normalizeLocale(locale);
    final list = switch (norm) {
      'am' => _monthNamesAm,
      'ti' => _monthNamesTi,
      'om' => _monthNamesOm,
      _ => _monthNamesEn,
    };
    if (month < 1 || month > 13) return '$month';
    return list[month - 1];
  }

  /// Returns the full list of 13 localized Ethiopian month names.
  static List<String> monthNames([String locale = 'en']) {
    final norm = _normalizeLocale(locale);
    return switch (norm) {
      'am' => _monthNamesAm,
      'ti' => _monthNamesTi,
      'om' => _monthNamesOm,
      _ => _monthNamesEn,
    };
  }

  /// Returns the full list of localized weekday names (Monday to Sunday).
  static List<String> weekdayNames([String locale = 'en']) {
    final norm = _normalizeLocale(locale);
    return switch (norm) {
      'am' => _weekdayNamesAm,
      'ti' => _weekdayNamesTi,
      'om' => _weekdayNamesOm,
      _ => _weekdayNamesEn,
    };
  }

  /// Returns the localized weekday name for a given 1-based weekday (1 = Monday ... 7 = Sunday).
  static String weekdayName(int weekday, [String locale = 'en']) {
    final list = weekdayNames(locale);
    if (weekday < 1 || weekday > 7) return '$weekday';
    return list[weekday - 1];
  }

  /// Returns short localized weekday labels (Mon..Sun).
  static List<String> weekdayShortNames([String locale = 'en']) {
    final norm = _normalizeLocale(locale);
    return switch (norm) {
      'am' => const ['ሰኞ', 'ማክ', 'ረቡ', 'ሐሙ', 'አር', 'ቅዳ', 'እሁ'],
      'ti' => const ['ሰኑ', 'ሰሉ', 'ረቡ', 'ሓሙ', 'ዓር', 'ቀዳ', 'ሰን'],
      'om' => const ['Wix', 'Kib', 'Roo', 'Kam', 'Jim', 'San', 'Dil'],
      _ => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    };
  }

  /// Converts a Gregorian [DateTime] to [EthiopianDate].
  static EthiopianDate gregorianToEthiopian(DateTime greg) {
    return EthiopianDate.fromGregorian(greg);
  }

  /// Converts Ethiopian year, month, and day integers to a Gregorian [DateTime].
  static DateTime ethiopianToGregorian(int year, int month, int day, [int hour = 0, int minute = 0]) {
    return EthiopianDate(year, month, day).toGregorian(hour, minute);
  }

  /// Validates whether the given numbers form a valid Ethiopian date.
  static bool isValidEthiopianDate(int year, int month, int day) {
    if (year < 1 || month < 1 || month > 13) return false;
    final maxDays = month == 13 ? (year % 4 == 3 ? 6 : 5) : 30;
    return day >= 1 && day <= maxDays;
  }

  /// Formats a Gregorian [DateTime] as an Ethiopian date string.
  /// Returns e.g. "Tikimt 12, 2018 ዓ/ም" or "ጥቅምት 12, 2018 ዓ/ም".
  static String formatEthiopian(DateTime greg, [String locale = 'en']) {
    final eth = EthiopianDate.fromGregorian(greg);
    return eth.format(locale);
  }

  /// Formats a year integer as a dual Gregorian/Ethiopian display.
  /// Returns e.g. "2026 / 2018 ዓ/ም".
  /// Uses Jan 1 as the reference date so the Ethiopian year shown
  /// is the one covering most of the Gregorian year.
  static String formatYear(int gregYear) {
    final ref = DateTime(gregYear, 1, 1);
    final eth = EthiopianDate.fromGregorian(ref);
    return '$gregYear / ${eth.year} ዓ/ም';
  }

  /// Returns just the Ethiopian year suffix e.g. "2018 ዓ/ም"
  /// for a given Gregorian year.
  static String toEthiopianYearSuffix(int gregYear) {
    final ref = DateTime(gregYear, 1, 1);
    final eth = EthiopianDate.fromGregorian(ref);
    return '${eth.year} ዓ/ም';
  }

  /// Formats a Gregorian [DateTime] with both calendars side by side.
  /// Returns e.g. "Mar 12, 2026 / መጋቢት 03, 2018 ዓ/ም".
  static String formatDual(DateTime greg, [String locale = 'en']) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final gregStr = '${months[greg.month - 1]} ${greg.day}, ${greg.year}';
    final eth = EthiopianDate.fromGregorian(greg);
    final month = monthName(eth.month, locale);
    final dayStr = eth.day.toString().padLeft(2, '0');
    return '$gregStr / $month $dayStr, ${eth.year} ዓ/ም';
  }

  static String _normalizeLocale(String locale) {
    final l = locale.toLowerCase().split('_').first;
    if (l == 'ao' || l == 'om' || l == 'orm') return 'om';
    if (l == 'ti' || l == 'tir') return 'ti';
    if (l == 'am' || l == 'amh') return 'am';
    return 'en';
  }
}
