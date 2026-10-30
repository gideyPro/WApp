import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/utils/ethiopian_date_helper.dart';

void main() {
  group('EthiopianDate Value Object', () {
    test('creates valid Ethiopian dates', () {
      final date = EthiopianDate(2017, 2, 19);
      expect(date.year, 2017);
      expect(date.month, 2);
      expect(date.day, 19);
      expect(date.toString(), '2017-02-19');
    });

    test('throws ArgumentError on invalid month or day', () {
      expect(() => EthiopianDate(2017, 0, 1), throwsArgumentError);
      expect(() => EthiopianDate(2017, 14, 1), throwsArgumentError);
      expect(() => EthiopianDate(2017, 1, 0), throwsArgumentError);
      expect(() => EthiopianDate(2017, 1, 31), throwsArgumentError);
    });

    test('handles Pagume leap years correctly (year % 4 == 3)', () {
      // 2015 is a leap year (2015 % 4 == 3) -> 6 days
      final leapPagume = EthiopianDate(2015, 13, 6);
      expect(leapPagume.isLeapYear, isTrue);
      expect(leapPagume.maxDaysInMonth, 6);

      // 2016 is not a leap year -> max 5 days
      final commonPagume = EthiopianDate(2016, 13, 5);
      expect(commonPagume.isLeapYear, isFalse);
      expect(commonPagume.maxDaysInMonth, 5);
      expect(() => EthiopianDate(2016, 13, 6), throwsArgumentError);
    });

    test('converts Ethiopian to Gregorian accurately', () {
      // Tikimt 19, 2017 -> Oct 29, 2024
      final eth = EthiopianDate(2017, 2, 19);
      final greg = eth.toGregorian();
      expect(greg.year, 2024);
      expect(greg.month, 10);
      expect(greg.day, 29);

      // Meskerem 1, 2017 -> Sept 11, 2024
      final newYear = EthiopianDate(2017, 1, 1);
      final gregNewYear = newYear.toGregorian();
      expect(gregNewYear.year, 2024);
      expect(gregNewYear.month, 9);
      expect(gregNewYear.day, 11);
    });

    test('converts Gregorian to Ethiopian accurately', () {
      final greg = DateTime(2024, 10, 29);
      final eth = EthiopianDate.fromGregorian(greg);
      expect(eth.year, 2017);
      expect(eth.month, 2);
      expect(eth.day, 19);

      final leapDay = DateTime(2023, 9, 11); // Pagume 6, 2015
      final ethLeap = EthiopianDate.fromGregorian(leapDay);
      expect(ethLeap.year, 2015);
      expect(ethLeap.month, 13);
      expect(ethLeap.day, 6);
    });

    test('tryParse parses formatted dates', () {
      final parsed1 = EthiopianDate.tryParse('2017-02-19');
      expect(parsed1, equals(EthiopianDate(2017, 2, 19)));

      final parsed2 = EthiopianDate.tryParse('2017/02/19');
      expect(parsed2, equals(EthiopianDate(2017, 2, 19)));

      expect(EthiopianDate.tryParse('invalid'), isNull);
      expect(EthiopianDate.tryParse('2017-15-01'), isNull);
    });

    test('date arithmetic (addDays, subtractDays)', () {
      final start = EthiopianDate(2017, 1, 30);
      final nextDay = start.addDays(1);
      expect(nextDay.year, 2017);
      expect(nextDay.month, 2);
      expect(nextDay.day, 1);

      final prevDay = nextDay.subtractDays(1);
      expect(prevDay, equals(start));
    });

    test('comparison methods (isBefore, isAfter)', () {
      final d1 = EthiopianDate(2017, 1, 1);
      final d2 = EthiopianDate(2017, 1, 2);
      final d3 = EthiopianDate(2018, 1, 1);

      expect(d1.isBefore(d2), isTrue);
      expect(d2.isAfter(d1), isTrue);
      expect(d3.isAfter(d2), isTrue);
      expect(d1 == EthiopianDate(2017, 1, 1), isTrue);
    });
  });

  group('EthiopianDateHelper Localizations and Formatters', () {
    test('monthName returns localized month names', () {
      expect(EthiopianDateHelper.monthName(1, 'am'), 'መስከረም');
      expect(EthiopianDateHelper.monthName(2, 'am'), 'ጥቅምት');
      expect(EthiopianDateHelper.monthName(13, 'am'), 'ጳጉሜ');

      expect(EthiopianDateHelper.monthName(1, 'ti'), 'መስከረም');
      expect(EthiopianDateHelper.monthName(2, 'ti'), 'ጥቅምቲ');

      expect(EthiopianDateHelper.monthName(1, 'om'), 'Fuulbaana');
      expect(EthiopianDateHelper.monthName(2, 'om'), 'Onkololeessa');

      expect(EthiopianDateHelper.monthName(1, 'en'), 'Meskerem');
    });

    test('formatEthiopian formats correctly', () {
      final greg = DateTime(2024, 10, 29);
      final formattedAm = EthiopianDateHelper.formatEthiopian(greg, 'am');
      expect(formattedAm, 'ጥቅምት 19, 2017 ዓ/ም');

      final formattedEn = EthiopianDateHelper.formatEthiopian(greg, 'en');
      expect(formattedEn, 'Tikimt 19, 2017 ዓ/ም');
    });

    test('formatDual formats Gregorian and Ethiopian side-by-side', () {
      final greg = DateTime(2024, 10, 29);
      final dual = EthiopianDateHelper.formatDual(greg, 'am');
      expect(dual, contains('Oct 29, 2024'));
      expect(dual, contains('ጥቅምት 19, 2017 ዓ/ም'));
    });

    test('isValidEthiopianDate correctly validates dates', () {
      expect(EthiopianDateHelper.isValidEthiopianDate(2017, 2, 30), isTrue);
      expect(EthiopianDateHelper.isValidEthiopianDate(2017, 2, 31), isFalse);
      expect(EthiopianDateHelper.isValidEthiopianDate(2015, 13, 6), isTrue); // Leap year
      expect(EthiopianDateHelper.isValidEthiopianDate(2016, 13, 6), isFalse); // Common year
    });
  });
}
