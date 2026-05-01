import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../theme/text_styles.dart';

class CountryCode {
  final String code;
  final String name;
  final String flag;
  final int minDigits;
  final int maxDigits;
  final String example;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
    required this.minDigits,
    required this.maxDigits,
    required this.example,
  });

  String get display => '$flag $name ($code)';
}

class Countries {
  Countries._();

  static const CountryCode ethiopia = CountryCode(
    code: '+251',
    name: 'Ethiopia',
    flag: '🇪🇹',
    minDigits: 9,
    maxDigits: 9,
    example: '912 345 678',
  );

  static const List<CountryCode> all = [
    ethiopia,
    CountryCode(code: '+93', name: 'Afghanistan', flag: '🇦🇫', minDigits: 9, maxDigits: 9, example: '701 234 567'),
    CountryCode(code: '+355', name: 'Albania', flag: '🇦🇱', minDigits: 9, maxDigits: 9, example: '66 123 4567'),
    CountryCode(code: '+213', name: 'Algeria', flag: '🇩🇿', minDigits: 9, maxDigits: 9, example: '551 23 4567'),
    CountryCode(code: '+1684', name: 'American Samoa', flag: '🇦🇸', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+376', name: 'Andorra', flag: '🇦🇩', minDigits: 6, maxDigits: 9, example: '123 456'),
    CountryCode(code: '+244', name: 'Angola', flag: '🇦🇴', minDigits: 9, maxDigits: 9, example: '923 123 456'),
    CountryCode(code: '+1264', name: 'Anguilla', flag: '🇦🇮', minDigits: 7, maxDigits: 7, example: '235 1234'),
    CountryCode(code: '+1268', name: 'Antigua and Barbuda', flag: '🇦🇬', minDigits: 7, maxDigits: 7, example: '268 123 4567'),
    CountryCode(code: '+54', name: 'Argentina', flag: '🇦🇷', minDigits: 10, maxDigits: 10, example: '11 1234 5678'),
    CountryCode(code: '+374', name: 'Armenia', flag: '🇦🇲', minDigits: 8, maxDigits: 8, example: '91 234 567'),
    CountryCode(code: '+297', name: 'Aruba', flag: '🇦🇼', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺', minDigits: 9, maxDigits: 9, example: '412 345 678'),
    CountryCode(code: '+43', name: 'Austria', flag: '🇦🇹', minDigits: 10, maxDigits: 13, example: '660 123 4567'),
    CountryCode(code: '+994', name: 'Azerbaijan', flag: '🇦🇿', minDigits: 9, maxDigits: 9, example: '50 123 4567'),
    CountryCode(code: '+1242', name: 'Bahamas', flag: '🇧🇸', minDigits: 7, maxDigits: 7, example: '242 123 4567'),
    CountryCode(code: '+973', name: 'Bahrain', flag: '🇧🇭', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+880', name: 'Bangladesh', flag: '🇧🇩', minDigits: 10, maxDigits: 10, example: '01712 345678'),
    CountryCode(code: '+1246', name: 'Barbados', flag: '🇧🇧', minDigits: 7, maxDigits: 7, example: '246 123 4567'),
    CountryCode(code: '+375', name: 'Belarus', flag: '🇧🇾', minDigits: 9, maxDigits: 9, example: '29 123 4567'),
    CountryCode(code: '+32', name: 'Belgium', flag: '🇧🇪', minDigits: 9, maxDigits: 9, example: '470 123 456'),
    CountryCode(code: '+501', name: 'Belize', flag: '🇧🇿', minDigits: 7, maxDigits: 7, example: '223 4567'),
    CountryCode(code: '+229', name: 'Benin', flag: '🇧🇯', minDigits: 8, maxDigits: 8, example: '90 123 4567'),
    CountryCode(code: '+1441', name: 'Bermuda', flag: '🇧🇲', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+975', name: 'Bhutan', flag: '🇧🇹', minDigits: 7, maxDigits: 7, example: '17 123 456'),
    CountryCode(code: '+591', name: 'Bolivia', flag: '🇧🇴', minDigits: 8, maxDigits: 8, example: '123 4567'),
    CountryCode(code: '+387', name: 'Bosnia and Herzegovina', flag: '🇧🇦', minDigits: 8, maxDigits: 8, example: '61 123 456'),
    CountryCode(code: '+267', name: 'Botswana', flag: '🇧🇼', minDigits: 7, maxDigits: 8, example: '71 123 456'),
    CountryCode(code: '+55', name: 'Brazil', flag: '🇧🇷', minDigits: 10, maxDigits: 11, example: '(11) 91234-5678'),
    CountryCode(code: '+246', name: 'British Indian Ocean Territory', flag: '🇮🇴', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+1284', name: 'British Virgin Islands', flag: '🇻🇬', minDigits: 7, maxDigits: 7, example: '234 5678'),
    CountryCode(code: '+673', name: 'Brunei', flag: '🇧🇳', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+359', name: 'Bulgaria', flag: '🇧🇬', minDigits: 9, maxDigits: 9, example: '87 123 4567'),
    CountryCode(code: '+226', name: 'Burkina Faso', flag: '🇧🇫', minDigits: 8, maxDigits: 8, example: '70 12 3456'),
    CountryCode(code: '+257', name: 'Burundi', flag: '🇧🇮', minDigits: 8, maxDigits: 8, example: '79 12 3456'),
    CountryCode(code: '+855', name: 'Cambodia', flag: '🇰🇭', minDigits: 8, maxDigits: 9, example: '12 345 678'),
    CountryCode(code: '+237', name: 'Cameroon', flag: '🇨🇲', minDigits: 9, maxDigits: 9, example: '6 12 345 678'),
    CountryCode(code: '+1', name: 'Canada', flag: '🇨🇦', minDigits: 10, maxDigits: 10, example: '(555) 123-4567'),
    CountryCode(code: '+238', name: 'Cape Verde', flag: '🇨🇻', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+1345', name: 'Cayman Islands', flag: '🇰🇾', minDigits: 7, maxDigits: 7, example: '345 123 4567'),
    CountryCode(code: '+236', name: 'Central African Republic', flag: '🇨🇫', minDigits: 8, maxDigits: 8, example: '12 34 5678'),
    CountryCode(code: '+235', name: 'Chad', flag: '🇹🇩', minDigits: 8, maxDigits: 8, example: '63 12 3456'),
    CountryCode(code: '+56', name: 'Chile', flag: '🇨🇱', minDigits: 9, maxDigits: 9, example: '9 1234 5678'),
    CountryCode(code: '+86', name: 'China', flag: '🇨🇳', minDigits: 11, maxDigits: 11, example: '138 1234 5678'),
    CountryCode(code: '+61', name: 'Christmas Island', flag: '🇨🇽', minDigits: 9, maxDigits: 9, example: '412 345 678'),
    CountryCode(code: '+61', name: 'Cocos Islands', flag: '🇨🇨', minDigits: 9, maxDigits: 9, example: '412 345 678'),
    CountryCode(code: '+57', name: 'Colombia', flag: '🇨🇴', minDigits: 10, maxDigits: 10, example: '300 123 4567'),
    CountryCode(code: '+269', name: 'Comoros', flag: '🇰🇲', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+242', name: 'Congo', flag: '🇨🇬', minDigits: 9, maxDigits: 9, example: '06 123 4567'),
    CountryCode(code: '+243', name: 'Congo Democratic Republic', flag: '🇨🇩', minDigits: 9, maxDigits: 9, example: '81 123 4567'),
    CountryCode(code: '+682', name: 'Cook Islands', flag: '🇨🇰', minDigits: 5, maxDigits: 7, example: '12 345'),
    CountryCode(code: '+506', name: 'Costa Rica', flag: '🇨🇷', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+225', name: 'Ivory Coast', flag: '🇨🇮', minDigits: 8, maxDigits: 8, example: '12 345 678'),
    CountryCode(code: '+385', name: 'Croatia', flag: '🇭🇷', minDigits: 9, maxDigits: 9, example: '91 123 4567'),
    CountryCode(code: '+53', name: 'Cuba', flag: '🇨🇺', minDigits: 8, maxDigits: 8, example: '5 123 4567'),
    CountryCode(code: '+599', name: 'Curacao', flag: '🇨🇼', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+357', name: 'Cyprus', flag: '🇨🇾', minDigits: 8, maxDigits: 8, example: '96 123456'),
    CountryCode(code: '+420', name: 'Czech Republic', flag: '🇨🇿', minDigits: 9, maxDigits: 9, example: '601 123 456'),
    CountryCode(code: '+45', name: 'Denmark', flag: '🇩🇰', minDigits: 8, maxDigits: 8, example: '12 34 5678'),
    CountryCode(code: '+253', name: 'Djibouti', flag: '🇩🇯', minDigits: 8, maxDigits: 8, example: '21 234 56'),
    CountryCode(code: '+1767', name: 'Dominica', flag: '🇩🇲', minDigits: 7, maxDigits: 7, example: '235 1234'),
    CountryCode(code: '+1809', name: 'Dominican Republic', flag: '🇩🇴', minDigits: 10, maxDigits: 10, example: '(809) 123-4567'),
    CountryCode(code: '+593', name: 'Ecuador', flag: '🇪🇨', minDigits: 9, maxDigits: 9, example: '99 123 4567'),
    CountryCode(code: '+20', name: 'Egypt', flag: '🇪🇬', minDigits: 10, maxDigits: 10, example: '100 123 4567'),
    CountryCode(code: '+503', name: 'El Salvador', flag: '🇸🇻', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+240', name: 'Equatorial Guinea', flag: '🇬🇶', minDigits: 9, maxDigits: 9, example: '222 123 456'),
    CountryCode(code: '+291', name: 'Eritrea', flag: '🇪🇷', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+372', name: 'Estonia', flag: '🇪🇪', minDigits: 8, maxDigits: 8, example: '5123 4567'),
    CountryCode(code: '+251', name: 'Ethiopia', flag: '🇪🇹', minDigits: 9, maxDigits: 9, example: '912 345 678'),
    CountryCode(code: '+500', name: 'Falkland Islands', flag: '🇫🇰', minDigits: 5, maxDigits: 5, example: '12345'),
    CountryCode(code: '+298', name: 'Faroe Islands', flag: '🇫🇴', minDigits: 6, maxDigits: 6, example: '123456'),
    CountryCode(code: '+679', name: 'Fiji', flag: '🇫🇯', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+358', name: 'Finland', flag: '🇫🇮', minDigits: 9, maxDigits: 9, example: '50 123 4567'),
    CountryCode(code: '+33', name: 'France', flag: '🇫🇷', minDigits: 9, maxDigits: 10, example: '6 12 34 56 78'),
    CountryCode(code: '+594', name: 'French Guiana', flag: '🇬🇫', minDigits: 9, maxDigits: 9, example: '694 123 456'),
    CountryCode(code: '+689', name: 'French Polynesia', flag: '🇵🇫', minDigits: 6, maxDigits: 8, example: '12 3456'),
    CountryCode(code: '+262', name: 'French Southern Territories', flag: '🇹🇫', minDigits: 6, maxDigits: 6, example: '12 3456'),
    CountryCode(code: '+241', name: 'Gabon', flag: '🇬🇦', minDigits: 7, maxDigits: 9, example: '01 23 456'),
    CountryCode(code: '+220', name: 'Gambia', flag: '🇬🇲', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+995', name: 'Georgia', flag: '🇬🇪', minDigits: 9, maxDigits: 9, example: '555 12 3456'),
    CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪', minDigits: 10, maxDigits: 11, example: '1512 3456789'),
    CountryCode(code: '+233', name: 'Ghana', flag: '🇬🇭', minDigits: 9, maxDigits: 9, example: '20 123 4567'),
    CountryCode(code: '+350', name: 'Gibraltar', flag: '🇬🇮', minDigits: 8, maxDigits: 8, example: '12345678'),
    CountryCode(code: '+30', name: 'Greece', flag: '🇬🇷', minDigits: 10, maxDigits: 10, example: '691 123 4567'),
    CountryCode(code: '+299', name: 'Greenland', flag: '🇬🇱', minDigits: 6, maxDigits: 6, example: '123456'),
    CountryCode(code: '+1473', name: 'Grenada', flag: '🇬🇩', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+590', name: 'Guadeloupe', flag: '🇬🇵', minDigits: 9, maxDigits: 9, example: '690 123 456'),
    CountryCode(code: '+1671', name: 'Guam', flag: '🇬🇺', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+502', name: 'Guatemala', flag: '🇬🇹', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+44', name: 'Guernsey', flag: '🇬🇬', minDigits: 10, maxDigits: 10, example: '7700 900000'),
    CountryCode(code: '+224', name: 'Guinea', flag: '🇬🇳', minDigits: 9, maxDigits: 9, example: '612 123 456'),
    CountryCode(code: '+245', name: 'Guinea-Bissau', flag: '🇬🇼', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+592', name: 'Guyana', flag: '🇬🇾', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+509', name: 'Haiti', flag: '🇭🇹', minDigits: 8, maxDigits: 8, example: '22 123 4567'),
    CountryCode(code: '+39', name: 'Holy See', flag: '🇻🇦', minDigits: 9, maxDigits: 9, example: '312 345 6789'),
    CountryCode(code: '+504', name: 'Honduras', flag: '🇭🇳', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+852', name: 'Hong Kong', flag: '🇭🇰', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+36', name: 'Hungary', flag: '🇭🇺', minDigits: 9, maxDigits: 9, example: '20 123 4567'),
    CountryCode(code: '+354', name: 'Iceland', flag: '🇮🇸', minDigits: 7, maxDigits: 9, example: '123 4567'),
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳', minDigits: 10, maxDigits: 10, example: '98765 43210'),
    CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩', minDigits: 10, maxDigits: 12, example: '0812 1234 5678'),
    CountryCode(code: '+98', name: 'Iran', flag: '🇮🇷', minDigits: 10, maxDigits: 10, example: '0912 123 4567'),
    CountryCode(code: '+964', name: 'Iraq', flag: '🇮🇶', minDigits: 10, maxDigits: 10, example: '0790 123 4567'),
    CountryCode(code: '+353', name: 'Ireland', flag: '🇮🇪', minDigits: 9, maxDigits: 9, example: '085 123 4567'),
    CountryCode(code: '+44', name: 'Isle of Man', flag: '🇮🇲', minDigits: 10, maxDigits: 10, example: '7700 900000'),
    CountryCode(code: '+972', name: 'Israel', flag: '🇮🇱', minDigits: 9, maxDigits: 9, example: '050-123-4567'),
    CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹', minDigits: 9, maxDigits: 10, example: '312 345 6789'),
    CountryCode(code: '+1876', name: 'Jamaica', flag: '🇯🇲', minDigits: 7, maxDigits: 7, example: '876 123 4567'),
    CountryCode(code: '+81', name: 'Japan', flag: '🇯🇵', minDigits: 10, maxDigits: 10, example: '090 1234 5678'),
    CountryCode(code: '+44', name: 'Jersey', flag: '🇯🇪', minDigits: 10, maxDigits: 10, example: '7700 900000'),
    CountryCode(code: '+962', name: 'Jordan', flag: '🇯🇴', minDigits: 9, maxDigits: 9, example: '07 9123 4567'),
    CountryCode(code: '+7', name: 'Kazakhstan', flag: '🇰🇿', minDigits: 10, maxDigits: 10, example: '777 123 4567'),
    CountryCode(code: '+254', name: 'Kenya', flag: '🇰🇪', minDigits: 9, maxDigits: 9, example: '712 345 678'),
    CountryCode(code: '+686', name: 'Kiribati', flag: '🇰🇮', minDigits: 5, maxDigits: 7, example: '12 345'),
    CountryCode(code: '+383', name: 'Kosovo', flag: '🇽🇰', minDigits: 8, maxDigits: 8, example: '44 123 456'),
    CountryCode(code: '+965', name: 'Kuwait', flag: '🇰🇼', minDigits: 7, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+996', name: 'Kyrgyzstan', flag: '🇰🇬', minDigits: 9, maxDigits: 9, example: '700 123 456'),
    CountryCode(code: '+856', name: 'Laos', flag: '🇱🇦', minDigits: 8, maxDigits: 9, example: '20 123 45678'),
    CountryCode(code: '+371', name: 'Latvia', flag: '🇱🇻', minDigits: 8, maxDigits: 8, example: '21 234 567'),
    CountryCode(code: '+961', name: 'Lebanon', flag: '🇱🇧', minDigits: 7, maxDigits: 8, example: '3 123 456'),
    CountryCode(code: '+266', name: 'Lesotho', flag: '🇱🇸', minDigits: 8, maxDigits: 8, example: '5012 3456'),
    CountryCode(code: '+231', name: 'Liberia', flag: '🇱🇷', minDigits: 7, maxDigits: 9, example: '077 123 4567'),
    CountryCode(code: '+218', name: 'Libya', flag: '🇱🇾', minDigits: 9, maxDigits: 9, example: '91 234 5678'),
    CountryCode(code: '+423', name: 'Liechtenstein', flag: '🇱🇮', minDigits: 7, maxDigits: 9, example: '123 4567'),
    CountryCode(code: '+370', name: 'Lithuania', flag: '🇱🇹', minDigits: 8, maxDigits: 8, example: '612 34567'),
    CountryCode(code: '+352', name: 'Luxembourg', flag: '🇱🇺', minDigits: 8, maxDigits: 9, example: '123 456 78'),
    CountryCode(code: '+853', name: 'Macau', flag: '🇲🇴', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+389', name: 'Macedonia', flag: '🇲🇰', minDigits: 8, maxDigits: 8, example: '70 123 456'),
    CountryCode(code: '+261', name: 'Madagascar', flag: '🇲🇬', minDigits: 9, maxDigits: 10, example: '32 12 345 67'),
    CountryCode(code: '+265', name: 'Malawi', flag: '🇲🇼', minDigits: 7, maxDigits: 9, example: '1 234 567'),
    CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾', minDigits: 9, maxDigits: 10, example: '012 345 6789'),
    CountryCode(code: '+960', name: 'Maldives', flag: '🇲🇻', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+223', name: 'Mali', flag: '🇲🇱', minDigits: 8, maxDigits: 8, example: '70 12 3456'),
    CountryCode(code: '+356', name: 'Malta', flag: '🇲🇹', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+692', name: 'Marshall Islands', flag: '🇲🇭', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+596', name: 'Martinique', flag: '🇲🇶', minDigits: 9, maxDigits: 9, example: '696 12 3456'),
    CountryCode(code: '+222', name: 'Mauritania', flag: '🇲🇷', minDigits: 8, maxDigits: 8, example: '22 12 3456'),
    CountryCode(code: '+230', name: 'Mauritius', flag: '🇲🇺', minDigits: 8, maxDigits: 8, example: '123 4567'),
    CountryCode(code: '+262', name: 'Mayotte', flag: '🇾🇹', minDigits: 9, maxDigits: 9, example: '639 12 3456'),
    CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽', minDigits: 10, maxDigits: 10, example: '55 1234 5678'),
    CountryCode(code: '+691', name: 'Micronesia', flag: '🇫🇲', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+373', name: 'Moldova', flag: '🇲🇩', minDigits: 8, maxDigits: 8, example: '22 123 456'),
    CountryCode(code: '+377', name: 'Monaco', flag: '🇲🇨', minDigits: 8, maxDigits: 9, example: '12 34 56 78'),
    CountryCode(code: '+976', name: 'Mongolia', flag: '🇲🇳', minDigits: 8, maxDigits: 8, example: '9912 3456'),
    CountryCode(code: '+382', name: 'Montenegro', flag: '🇲🇪', minDigits: 8, maxDigits: 8, example: '67 123 456'),
    CountryCode(code: '+1664', name: 'Montserrat', flag: '🇲🇸', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+212', name: 'Morocco', flag: '🇲🇦', minDigits: 9, maxDigits: 9, example: '612 123 456'),
    CountryCode(code: '+258', name: 'Mozambique', flag: '🇲🇿', minDigits: 9, maxDigits: 9, example: '82 123 4567'),
    CountryCode(code: '+95', name: 'Myanmar', flag: '🇲🇲', minDigits: 9, maxDigits: 10, example: '09 123 45678'),
    CountryCode(code: '+264', name: 'Namibia', flag: '🇳🇦', minDigits: 8, maxDigits: 9, example: '81 123 4567'),
    CountryCode(code: '+674', name: 'Nauru', flag: '🇳🇷', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+977', name: 'Nepal', flag: '🇳🇵', minDigits: 10, maxDigits: 10, example: '984 123 4567'),
    CountryCode(code: '+31', name: 'Netherlands', flag: '🇳🇱', minDigits: 9, maxDigits: 9, example: '6 12345678'),
    CountryCode(code: '+599', name: 'Netherlands Antilles', flag: '🇦🇳', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+687', name: 'New Caledonia', flag: '🇳🇨', minDigits: 6, maxDigits: 7, example: '12 3456'),
    CountryCode(code: '+64', name: 'New Zealand', flag: '🇳🇿', minDigits: 9, maxDigits: 10, example: '021 234 5678'),
    CountryCode(code: '+505', name: 'Nicaragua', flag: '🇳🇮', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+227', name: 'Niger', flag: '🇳🇪', minDigits: 8, maxDigits: 8, example: '20 12 3456'),
    CountryCode(code: '+234', name: 'Nigeria', flag: '🇳🇬', minDigits: 10, maxDigits: 10, example: '080 1234 5678'),
    CountryCode(code: '+683', name: 'Niue', flag: '🇳🇺', minDigits: 4, maxDigits: 4, example: '1234'),
    CountryCode(code: '+672', name: 'Norfolk Island', flag: '🇳🇫', minDigits: 6, maxDigits: 6, example: '123456'),
    CountryCode(code: '+850', name: 'North Korea', flag: '🇰🇵', minDigits: 10, maxDigits: 10, example: '192 123 4567'),
    CountryCode(code: '+1670', name: 'Northern Mariana Islands', flag: '🇲🇵', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+47', name: 'Norway', flag: '🇳🇴', minDigits: 8, maxDigits: 8, example: '412 34 567'),
    CountryCode(code: '+968', name: 'Oman', flag: '🇴🇲', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+92', name: 'Pakistan', flag: '🇵🇰', minDigits: 10, maxDigits: 10, example: '0300 1234567'),
    CountryCode(code: '+680', name: 'Palau', flag: '🇵🇼', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+970', name: 'Palestine', flag: '🇵🇸', minDigits: 9, maxDigits: 9, example: '059 123 4567'),
    CountryCode(code: '+507', name: 'Panama', flag: '🇵🇦', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+675', name: 'Papua New Guinea', flag: '🇵🇬', minDigits: 7, maxDigits: 8, example: '123 4567'),
    CountryCode(code: '+595', name: 'Paraguay', flag: '🇵🇾', minDigits: 9, maxDigits: 9, example: '0961 123456'),
    CountryCode(code: '+51', name: 'Peru', flag: '🇵🇪', minDigits: 9, maxDigits: 9, example: '912 345 678'),
    CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭', minDigits: 10, maxDigits: 10, example: '0912 345 6789'),
    CountryCode(code: '+64', name: 'Pitcairn', flag: '🇵🇳', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+48', name: 'Poland', flag: '🇵🇱', minDigits: 9, maxDigits: 9, example: '501 123 456'),
    CountryCode(code: '+351', name: 'Portugal', flag: '🇵🇹', minDigits: 9, maxDigits: 9, example: '912 345 678'),
    CountryCode(code: '+1787', name: 'Puerto Rico', flag: '🇵🇷', minDigits: 10, maxDigits: 10, example: '(787) 123-4567'),
    CountryCode(code: '+974', name: 'Qatar', flag: '🇶🇦', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+262', name: 'Reunion', flag: '🇷🇪', minDigits: 9, maxDigits: 9, example: '692 12 3456'),
    CountryCode(code: '+40', name: 'Romania', flag: '🇷🇴', minDigits: 10, maxDigits: 10, example: '0712 345 678'),
    CountryCode(code: '+7', name: 'Russia', flag: '🇷🇺', minDigits: 10, maxDigits: 10, example: '912 345-67-89'),
    CountryCode(code: '+250', name: 'Rwanda', flag: '🇷🇼', minDigits: 9, maxDigits: 9, example: '072 123 4567'),
    CountryCode(code: '+262', name: 'Saint Barthelemy', flag: '🇧🇱', minDigits: 9, maxDigits: 9, example: '690 12 3456'),
    CountryCode(code: '+290', name: 'Saint Helena', flag: '🇸🇭', minDigits: 4, maxDigits: 4, example: '1234'),
    CountryCode(code: '+1599', name: 'Saint Kitts and Nevis', flag: '🇰🇳', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+1758', name: 'Saint Lucia', flag: '🇱🇨', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+590', name: 'Saint Martin', flag: '🇲🇫', minDigits: 9, maxDigits: 9, example: '690 12 3456'),
    CountryCode(code: '+508', name: 'Saint Pierre and Miquelon', flag: '🇵🇲', minDigits: 6, maxDigits: 6, example: '12 3456'),
    CountryCode(code: '+1784', name: 'Saint Vincent and the Grenadines', flag: '🇻🇨', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+685', name: 'Samoa', flag: '🇼🇸', minDigits: 6, maxDigits: 7, example: '12 3456'),
    CountryCode(code: '+378', name: 'San Marino', flag: '🇸🇲', minDigits: 9, maxDigits: 10, example: '0549 123456'),
    CountryCode(code: '+239', name: 'Sao Tome and Principe', flag: '🇸🇹', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦', minDigits: 9, maxDigits: 9, example: '051 123 4567'),
    CountryCode(code: '+221', name: 'Senegal', flag: '🇸🇳', minDigits: 9, maxDigits: 9, example: '77 123 4567'),
    CountryCode(code: '+381', name: 'Serbia', flag: '🇷🇸', minDigits: 9, maxDigits: 9, example: '60 123 4567'),
    CountryCode(code: '+248', name: 'Seychelles', flag: '🇸🇨', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+232', name: 'Sierra Leone', flag: '🇸🇱', minDigits: 8, maxDigits: 8, example: '76 123456'),
    CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬', minDigits: 8, maxDigits: 8, example: '1234 5678'),
    CountryCode(code: '+1721', name: 'Sint Maarten', flag: '🇸🇽', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+421', name: 'Slovakia', flag: '🇸🇰', minDigits: 9, maxDigits: 9, example: '912 123 456'),
    CountryCode(code: '+386', name: 'Slovenia', flag: '🇸🇮', minDigits: 8, maxDigits: 8, example: '31 123 456'),
    CountryCode(code: '+677', name: 'Solomon Islands', flag: '🇸🇧', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+252', name: 'Somalia', flag: '🇸🇴', minDigits: 9, maxDigits: 9, example: '61 234 5678'),
    CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦', minDigits: 9, maxDigits: 9, example: '82 123 4567'),
    CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷', minDigits: 10, maxDigits: 10, example: '010 1234 5678'),
    CountryCode(code: '+211', name: 'South Sudan', flag: '🇸🇸', minDigits: 9, maxDigits: 9, example: '912 345 678'),
    CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸', minDigits: 9, maxDigits: 9, example: '612 34 56 78'),
    CountryCode(code: '+94', name: 'Sri Lanka', flag: '🇱🇰', minDigits: 9, maxDigits: 9, example: '77 123 4567'),
    CountryCode(code: '+249', name: 'Sudan', flag: '🇸🇩', minDigits: 9, maxDigits: 9, example: '91 234 5678'),
    CountryCode(code: '+597', name: 'Suriname', flag: '🇸🇷', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+47', name: 'Svalbard and Jan Mayen', flag: '🇸🇯', minDigits: 8, maxDigits: 8, example: '412 34 567'),
    CountryCode(code: '+268', name: 'Swaziland', flag: '🇸🇿', minDigits: 8, maxDigits: 8, example: '76 12 3456'),
    CountryCode(code: '+46', name: 'Sweden', flag: '🇸🇪', minDigits: 9, maxDigits: 9, example: '70 123 4567'),
    CountryCode(code: '+41', name: 'Switzerland', flag: '🇨🇭', minDigits: 9, maxDigits: 9, example: '78 123 4567'),
    CountryCode(code: '+963', name: 'Syria', flag: '🇸🇾', minDigits: 9, maxDigits: 10, example: '091 123 4567'),
    CountryCode(code: '+886', name: 'Taiwan', flag: '🇹🇼', minDigits: 9, maxDigits: 9, example: '0912 345 678'),
    CountryCode(code: '+992', name: 'Tajikistan', flag: '🇹🇯', minDigits: 9, maxDigits: 9, example: '927 123 4567'),
    CountryCode(code: '+255', name: 'Tanzania', flag: '🇹🇿', minDigits: 9, maxDigits: 9, example: '612 345 678'),
    CountryCode(code: '+66', name: 'Thailand', flag: '🇹🇭', minDigits: 9, maxDigits: 9, example: '081 234 5678'),
    CountryCode(code: '+228', name: 'Togo', flag: '🇹🇬', minDigits: 7, maxDigits: 7, example: '90 123 456'),
    CountryCode(code: '+690', name: 'Tokelau', flag: '🇹🇰', minDigits: 4, maxDigits: 4, example: '1234'),
    CountryCode(code: '+676', name: 'Tonga', flag: '🇹🇴', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+1868', name: 'Trinidad and Tobago', flag: '🇹🇹', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+216', name: 'Tunisia', flag: '🇹🇳', minDigits: 8, maxDigits: 8, example: '20 123 456'),
    CountryCode(code: '+90', name: 'Turkey', flag: '🇹🇷', minDigits: 10, maxDigits: 10, example: '532 123 4567'),
    CountryCode(code: '+993', name: 'Turkmenistan', flag: '🇹🇲', minDigits: 8, maxDigits: 8, example: '12 34 5678'),
    CountryCode(code: '+1649', name: 'Turks and Caicos Islands', flag: '🇹🇨', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+688', name: 'Tuvalu', flag: '🇹🇻', minDigits: 5, maxDigits: 7, example: '12 345'),
    CountryCode(code: '+256', name: 'Uganda', flag: '🇺🇬', minDigits: 9, maxDigits: 9, example: '712 345 678'),
    CountryCode(code: '+380', name: 'Ukraine', flag: '🇺🇦', minDigits: 9, maxDigits: 9, example: '39 123 4567'),
    CountryCode(code: '+971', name: 'United Arab Emirates', flag: '🇦🇪', minDigits: 9, maxDigits: 9, example: '050 123 4567'),
    CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧', minDigits: 10, maxDigits: 10, example: '7700 900000'),
    CountryCode(code: '+1', name: 'United States', flag: '🇺🇸', minDigits: 10, maxDigits: 10, example: '(555) 123-4567'),
    CountryCode(code: '+598', name: 'Uruguay', flag: '🇺🇾', minDigits: 8, maxDigits: 9, example: '091 234 567'),
    CountryCode(code: '+998', name: 'Uzbekistan', flag: '🇺🇿', minDigits: 9, maxDigits: 9, example: '90 123 4567'),
    CountryCode(code: '+678', name: 'Vanuatu', flag: '🇻🇺', minDigits: 7, maxDigits: 7, example: '123 4567'),
    CountryCode(code: '+58', name: 'Venezuela', flag: '🇻🇪', minDigits: 10, maxDigits: 10, example: '0412 123 4567'),
    CountryCode(code: '+84', name: 'Vietnam', flag: '🇻🇳', minDigits: 9, maxDigits: 10, example: '091 234 5678'),
    CountryCode(code: '+1284', name: 'Virgin Islands British', flag: '🇻🇬', minDigits: 7, maxDigits: 7, example: '234 5678'),
    CountryCode(code: '+1340', name: 'Virgin Islands US', flag: '🇻🇮', minDigits: 10, maxDigits: 10, example: '(340) 123-4567'),
    CountryCode(code: '+681', name: 'Wallis and Futuna', flag: '🇼🇫', minDigits: 6, maxDigits: 6, example: '12 3456'),
    CountryCode(code: '+967', name: 'Yemen', flag: '🇾🇪', minDigits: 9, maxDigits: 9, example: '712 345 678'),
    CountryCode(code: '+260', name: 'Zambia', flag: '🇿🇲', minDigits: 9, maxDigits: 9, example: '95 123 4567'),
    CountryCode(code: '+263', name: 'Zimbabwe', flag: '🇿🇼', minDigits: 9, maxDigits: 9, example: '77 123 4567'),
  ];

  static List<CountryCode> get sorted {
    final eth = all.where((c) => c.code == '+251').toList();
    final others = all.where((c) => c.code != '+251').toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return [...eth, ...others];
  }

  static CountryCode get defaultCountry => ethiopia;
}

class CountrySelectorDropdown extends StatelessWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;

  const CountrySelectorDropdown({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(
              selectedCountry.code,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.navy900,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? AppColors.zinc400 : AppColors.navy600,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerSheet(
        selectedCountry: selectedCountry,
        onCountrySelected: (country) {
          onCountrySelected(country);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountrySelected;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryCode> _filtered = Countries.sorted;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = Countries.sorted;
      } else {
        _filtered = Countries.sorted.where((c) =>
          c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.code.contains(query)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.zinc900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.zinc700 : AppColors.zinc300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Country',
                  style: AppTextStyles.title.copyWith(
                    color: isDark ? Colors.white : AppColors.navy900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.zinc800 : AppColors.zinc100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.zinc500 : AppColors.zinc400,
                      ),
                      icon: Icon(
                        Icons.search,
                        color: isDark ? AppColors.zinc500 : AppColors.zinc400,
                      ),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.navy900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final country = _filtered[index];
                final isSelected = country.code == widget.selectedCountry.code;

                return ListTile(
                  onTap: () => widget.onCountrySelected(country),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.navy900,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    country.example,
                    style: TextStyle(
                      color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                      fontSize: 12,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.wave500)
                      : Text(
                          country.code,
                          style: TextStyle(
                            color: isDark ? AppColors.zinc400 : AppColors.zinc500,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}