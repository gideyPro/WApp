import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/error_handler.dart';
import 'package:wavemart/data/models/job_form_data.dart';
import 'package:wavemart/data/models/job_requirement_item.dart';
import 'package:wavemart/data/models/listing.dart';
import 'package:wavemart/data/models/listing_form_data.dart';
import 'package:wavemart/data/models/payment.dart';
import 'package:wavemart/data/models/v2/listing_detail.dart';
import 'package:wavemart/data/models/v2/listing_summary.dart';
import 'package:wavemart/data/models/v2/owner_listing.dart';
import 'package:wavemart/data/models/v2/payment_state.dart';
import 'package:wavemart/data/models/v2/v2_legacy_adapters.dart';
import 'package:wavemart/data/services/lead_service.dart';

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

  group('OwnerListingLegacyAdapter (My Listings Cards)', () {
    test('maps owner property listing with moderation status and summary chips', () {
      final ownerListing = OwnerListing.fromJson({
        'id': 501,
        'user_id': 42,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'Owner Villa',
        'description': 'Exclusive villa',
        'price': {'amount': 12000000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa', 'zone': 'Bole', 'specific_location': 'Gerji'},
        'status': 'pending',
        'is_featured': true,
        'is_vip': false,
        'details': {
          'bedrooms': 3,
          'bathrooms': 2,
          'area_sqm': 180.0,
          'salons': 1,
          'total_rooms': 6,
        },
      });

      final listing = ownerListing.toListing();

      expect(listing.id, equals(501));
      expect(listing.userId, equals(42));
      expect(listing.propertyType, equals(PropertyType.house));
      expect(listing.status, equals(ListingStatus.pending));
      expect(listing.isFeatured, isTrue);
      expect(listing.address, isNotNull);
      expect(listing.address?.region, equals('Addis Ababa'));
      expect(listing.address?.zone, equals('Bole'));
      expect(listing.address?.specificLocation, equals('Gerji'));
      expect(listing.bedrooms, equals(3));
      expect(listing.bathrooms, equals(2));
      expect(listing.totalSquareMeters, equals(180.0));
      expect(listing.salons, equals(1));
    });

    test('maps owner car and job listing with chips for My Listings cards', () {
      final ownerCar = OwnerListing.fromJson({
        'id': 601,
        'user_id': 42,
        'type': 'car',
        'listing_type': 'sale',
        'title': '2023 Suzuki Dzire',
        'price': {'amount': 2800000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa', 'zone': 'Kirkos'},
        'status': 'active',
        'details': {
          'year': 2023,
          'mileage_km': 8000.0,
        },
      });

      final carListing = ownerCar.toListing();
      expect(carListing.userId, equals(42));
      expect(carListing.address?.region, equals('Addis Ababa'));
      expect(carListing.carYear, equals(2023));
      expect(carListing.carMileageKm, equals(8000.0));
      expect(carListing.status, equals(ListingStatus.active));

      final ownerJob = OwnerListing.fromJson({
        'id': 701,
        'user_id': 42,
        'type': 'job',
        'listing_type': 'sale',
        'title': 'Frontend Developer',
        'price': {'amount': 45000.0, 'currency': 'ETB'},
        'location': {'region': 'Addis Ababa'},
        'status': 'rejected',
        'details': {
          'company_name': 'Wave Tech',
          'job_type': 'contract',
          'job_category': 'technology',
          'positions_count': 3,
          'salary_min': 40000.0,
          'salary_max': 50000.0,
        },
      });

      final jobListing = ownerJob.toListing();
      expect(jobListing.userId, equals(42));
      expect(jobListing.address?.region, equals('Addis Ababa'));
      expect(jobListing.jobCompanyName, equals('Wave Tech'));
      expect(jobListing.jobType, equals('contract'));
      expect(jobListing.jobCategory, equals('technology'));
      expect(jobListing.jobPositionsCount, equals(3));
      expect(jobListing.jobSalaryMin, equals(40000.0));
      expect(jobListing.jobSalaryMax, equals(50000.0));
      expect(jobListing.status, equals(ListingStatus.rejected));
    });
  });

  group('Viewer Entitlements & Quota Gates', () {
    test('userContactHidden is true when contact quota is exhausted', () {
      final detail = ListingDetail.fromJson({
        'id': 801,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'Test Property',
        'price': {'amount': 1000.0},
        'location': {'region': 'Addis Ababa'},
        'viewer': {
          'is_owner': false,
          'contact_allowed': true,
          'contact_revealed': false,
          'contacts_remaining': 0,
          'contacts_max': 5,
          'video_allowed': false,
          'vip_blocked': true,
          'interest_status': 'negotiating',
          'interest_id': 19,
        },
      });

      final listing = detail.toListing();
      expect(listing.userContactHidden, isTrue,
          reason: 'When quota is 0, userContactHidden must be true so upgrade card shows');
      expect(listing.videoBlocked, isTrue);
      expect(listing.vipBlocked, isTrue);
      expect(listing.interestBlocked, isFalse);
      expect(listing.userInterestStatus, equals('negotiating'));
      expect(listing.userInterestId, equals(19));
    });

    test('userContactHidden is false when user has contact quota remaining', () {
      final detail = ListingDetail.fromJson({
        'id': 802,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'Test Property',
        'price': {'amount': 1000.0},
        'location': {'region': 'Addis Ababa'},
        'viewer': {
          'is_owner': false,
          'contact_allowed': true,
          'contact_revealed': false,
          'contacts_remaining': 3,
          'contacts_max': 5,
        },
      });

      final listing = detail.toListing();
      expect(listing.userContactHidden, isFalse);
      expect(listing.contactRemaining, equals(3));
      expect(listing.contactMax, equals(5));
    });
  });

  group('ApiErrorHandler clean message extraction', () {
    test('extracts clean message from V2 error envelope without raw code leaks', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v2/listings/1/reveal-contact'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v2/listings/1/reveal-contact'),
          statusCode: 403,
          data: {
            'error': {
              'code': 'LIMIT_EXCEEDED',
              'message': 'You have used all contact views for this period.',
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final message = ApiErrorHandler.getMessage(dioException);
      expect(message, equals('You have used all contact views for this period.'));
      expect(message.contains('{code:'), isFalse);
    });
  });

  group('V2 Fallbacks in Listing & Lead Models', () {
    test('Listing.fromJson parses V2 summary JSON with cover image, location and price', () {
      final v2Map = {
        'id': 901,
        'user_id': 10,
        'type': 'house',
        'listing_type': 'sale',
        'title': 'V2 Summary Villa',
        'price': {'amount': 18500000.0, 'currency': 'ETB'},
        'cover_image': {'url': 'https://wavemart.et/storage/cover.jpg'},
        'location': {
          'id': 77,
          'region': 'Addis Ababa',
          'zone': 'Bole',
          'specific_location': 'Atlas',
        },
        'details': {
          'bedrooms': 4,
          'bathrooms': 3,
          'area_sqm': 220.0,
          'salons': 1,
        },
      };

      final listing = Listing.fromJson(v2Map);
      expect(listing.id, equals(901));
      expect(listing.userId, equals(10));
      expect(listing.priceFixed, equals(18500000.0));
      expect(listing.images.length, equals(1));
      expect(listing.images.first.imageUrl, equals('https://wavemart.et/storage/cover.jpg'));
      expect(listing.address, isNotNull);
      expect(listing.address?.region, equals('Addis Ababa'));
      expect(listing.addressId, equals(77));
      expect(listing.bedrooms, equals(4));
      expect(listing.bathrooms, equals(3));
      expect(listing.totalSquareMeters, equals(220.0));
    });

    test('Lead parses V2 suggestion price and listing ID correctly', () {
      final suggestionJson = {
        'id': 12,
        'order_id': 5,
        'listing_id': 456,
        'source': 'suggestion',
        'stage': 'new',
        'listing': {
          'id': 456,
          'title': 'Recommended House',
          'price': {'amount': 7500000.0, 'currency': 'ETB'},
        },
      };

      final lead = Lead.fromJson(suggestionJson);
      expect(lead.id, equals(12));
      expect(lead.orderId, equals(5));
      expect(lead.listingId, equals(456));
      expect(lead.listingPrice, equals(7500000.0));
      expect(lead.isSuggestionPending, isTrue);
    });

    test('ListingFormDataV2Adapter maps price_revision_possible', () {
      final form = ListingFormData(
        priceOnAgreement: true,
      );
      final payload = form.toV2Payload('test-sub');
      expect((payload['attributes'] as Map)['price_revision_possible'], isTrue);
    });

    test('PaymentStateLegacyAdapter maps featured_listing payment type', () {
      const state = PaymentState(
        id: 1,
        txRef: 'WM-FEAT-123',
        type: 'featured_listing',
      );
      final legacy = state.toLegacyPayment();
      expect(legacy.paymentType, equals(PaymentType.featuredListing));
    });
  });
}
