import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/job_requirement_item.dart';

void main() {
  group('ExperienceItem.displayRequirementLabel', () {
    test('shows role and years without the company', () {
      const item = ExperienceItem(
        jobTitle: 'Accountant',
        company: 'ACME Trading',
        years: 3,
      );

      expect(item.displayRequirementLabel(), 'Accountant (3 yrs)');
    });

    test('handles an entry without years', () {
      const item = ExperienceItem(jobTitle: 'Driver');

      expect(item.displayRequirementLabel(), 'Driver');
    });

    test('ignores a company-only entry', () {
      const item = ExperienceItem(company: 'ACME Trading', years: 2);

      expect(item.displayRequirementLabel(), '(2 yrs)');
    });
  });
}
