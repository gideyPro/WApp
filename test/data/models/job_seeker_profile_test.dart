import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/api_constants.dart';
import 'package:wavemart/data/models/job_seeker_profile.dart';

Map<String, dynamic> _baseJson({String? photo}) => {
      'id': 1,
      'user_id': 2,
      'professional_title': 'Engineer',
      'full_name': 'Test User',
      'education_level': 'bachelors',
      'photo': photo,
      'is_public': true,
    };

void main() {
  group('JobSeekerProfile photo URL', () {
    test('prefixes relative storage paths with the API base URL', () {
      final profile = JobSeekerProfile.fromJson(
        _baseJson(photo: 'job-seeker-photos/2/avatar.jpg'),
      );

      expect(
        profile.photo,
        '${ApiConstants.baseUrl}/storage/job-seeker-photos/2/avatar.jpg',
      );
    });

    test('strips a leading slash before prefixing', () {
      final profile = JobSeekerProfile.fromJson(
        _baseJson(photo: '/job-seeker-photos/2/avatar.jpg'),
      );

      expect(
        profile.photo,
        '${ApiConstants.baseUrl}/storage/job-seeker-photos/2/avatar.jpg',
      );
    });

    test('keeps absolute photo URLs unchanged', () {
      final profile = JobSeekerProfile.fromJson(
        _baseJson(photo: 'https://cdn.example.com/avatar.jpg'),
      );

      expect(profile.photo, 'https://cdn.example.com/avatar.jpg');
    });

    test('returns null when the photo is missing or empty', () {
      expect(JobSeekerProfile.fromJson(_baseJson()).photo, isNull);
      expect(JobSeekerProfile.fromJson(_baseJson(photo: '')).photo, isNull);
    });
  });
}
