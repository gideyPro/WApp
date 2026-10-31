import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/job_form_data.dart';
import 'package:wavemart/data/models/job_requirement_item.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/data/models/listing_form_data.dart';
import 'package:wavemart/data/models/v2/listing_detail.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/models/v2/v2_legacy_adapters.dart';

void main() {
  group('ListingSummaryLegacyAdapter', () {
    test('maps summary details feature chips to legacy Listing model', () {
      final summary = ListingSummary.fromJson({
        'id': 101,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'Modern Villa',
        'description': 'A beautiful villa in Bole',
        'price': {'amount': 15000000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa', 'zone': 'Bole'},
        'details': {
          'bedrooms': 4,
          'bathrooms': 3,
          'area_sqm': 250.0,
          'salons': 2,
          'total_rooms': 9,
        },
      });

      final listing = summary.toListing();

      expect(listing.id, equals(101));
      expect(listing.propertyType, equals(PropertyType.house));
      expect(listing.bedrooms, equals(4));
      expect(listing.bathrooms, equals(3));
      expect(listing.totalSquareMeters, equals(250.0));
      expect(listing.salons, equals(2));
      expect(listing.priceFixed, equals(15000000.0));
    });

    test('maps car and job summary details to legacy Listing model', () {
      final carSummary = ListingSummary.fromJson({
        'id': 202,
        'type': 'car',
        'listing_type': 'sale',
        'title': '2022 Toyota RAV4',
        'price': {'amount': 5500000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa'},
        'details': {
          'year': 2022,
          'mileage_km': 15000.0,
        },
      });

      final carListing = carSummary.toListing();
      expect(carListing.carYear, equals(2022));
      expect(carListing.carMileageKm, equals(15000.0));

      final jobSummary = ListingSummary.fromJson({
        'id': 303,
        'type': 'job',
        'listing_type': 'sale',
        'title': 'Senior Flutter Engineer',
        'price': {'amount': 80000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa'},
        'details': {
          'company_name': 'WaveMart Tech',
          'job_type': 'full_time',
        },
      });

      final jobListing = jobSummary.toListing();
      expect(jobListing.jobCompanyName, equals('WaveMart Tech'));
      expect(jobListing.jobType, equals('full_time'));
    });
  });

  group('ListingDetailLegacyAdapter', () {
    test('maps detailed fields including media URLs and holding details', () {
      final detail = ListingDetail.fromJson({
        'id': 105,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'Luxury House',
        'price': {'amount': 20000000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa'},
        'site_plan_url': 'https://wavemart.et/storage/site_plans/sp1.jpg',
        'ownership_proof_url': 'https://wavemart.et/storage/proofs/p1.jpg',
        'details': {
          'bedrooms': 5,
          'bathrooms': 4,
          'salons': 2,
          'total_rooms': 11,
          'area_sqm': 350.0,
        },
        'holding_details': {
          'lease': {
            'leased_year': 2018,
            'is_transferable': true,
            'annual_payment': 5000.0,
          },
        },
        'viewer': {
          'is_owner': true,
          'contact_allowed': true,
          'contact_revealed': true,
        },
        'seller': {
          'name': 'Abebe Kebede',
          'phone': '+251911223344',
        },
      });

      final listing = detail.toListing();
      expect(listing.salons, equals(2));
      expect(listing.totalRooms, equals(11));
      expect(listing.sitePlanUrl, equals('https://wavemart.et/storage/site_plans/sp1.jpg'));
      expect(listing.ownershipProofUrl, equals('https://wavemart.et/storage/proofs/p1.jpg'));
      expect(listing.isTransferable, isTrue);
      expect(listing.sellerName, equals('Abebe Kebede'));
      expect(listing.sellerPhone, equals('+251911223344'));
    });
  });

  group('FormData toV2Payload', () {
    test('ListingFormDataV2Adapter outputs valid V2 property write payload', () {
      final formData = ListingFormData(
        type: 'house',
        listingType: 'sale',
        holdingType: 'Lease Hold',
        leasedYear: 2020,
        isTransferable: true,
        totalRooms: 8,
        salons: 2,
        bedrooms: 3,
        bathrooms: 2,
        isVip: true,
        postedByAgent: true,
        agentId: '5',
        postedForOtherOwner: true,
        ownerName: 'Tadesse',
        ownerPhone: '0912345678',
      );

      final payload = formData.toV2Payload('test-sub-key-123');

      expect(payload['submission_key'], equals('test-sub-key-123'));
      expect(payload['type'], equals('house'));
      expect(payload['is_vip'], isTrue);
      expect(payload['agent_id'], equals(5));

      final owner = payload['owner'] as Map;
      expect(owner['posted_for_other_owner'], isTrue);
      expect(owner['name'], equals('Tadesse'));
      expect(owner['phone'], equals('0912345678'));

      final details = payload['details'] as Map;
      expect(details['total_rooms'], equals(8));
      expect(details['salons'], equals(2));
      expect(details['bedrooms'], equals(3));

      final holding = payload['holding'] as Map;
      expect(holding['type'], equals('Lease Hold'));
      final lease = holding['lease'] as Map;
      expect(lease['leased_year'], equals(2020));
      expect(lease['is_transferable'], isTrue);
    });

    test('JobFormDataV2Adapter outputs structured requirements in V2 payload', () {
      final formData = JobFormData(
        title: 'Project Manager',
        companyName: 'Habesha Tech',
        jobType: 'full_time',
        jobCategory: 'management',
        reqEducations: const [
          EducationItem(educationLevel: 'degree', fieldOfStudy: 'Computer Science'),
        ],
        reqExperiences: const [
          ExperienceItem(jobTitle: 'Scrum Master', company: 'Addis Soft', years: 3.5),
        ],
      );

      final payload = formData.toV2Payload('job-sub-1');

      expect(payload['title'], equals('Project Manager'));
      expect(payload['company_name'], equals('Habesha Tech'));

      final educations = payload['req_educations'] as List;
      expect(educations.length, equals(1));
      expect(educations.first['education_level'], equals('degree'));
      expect(educations.first['field_of_study'], equals('Computer Science'));

      final experiences = payload['req_experiences'] as List;
      expect(experiences.length, equals(1));
      expect(experiences.first['job_title'], equals('Scrum Master'));
      expect(experiences.first['company'], equals('Addis Soft'));
      expect(experiences.first['years'], equals(3.5));
    });
  });
}
