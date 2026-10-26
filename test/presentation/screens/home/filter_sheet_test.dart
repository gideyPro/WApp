import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/presentation/screens/home/filter_sheet.dart';
import 'package:wavemart/presentation/screens/home/home_screen.dart';

void main() {
  group('UnifiedFilterValues', () {
    test('hasAnyFilter detects vehicle listingType', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        listingType: 'rental',
      );

      expect(filters.hasAnyFilter, isTrue);
    });

    test('hasAnyFilter is false when no vehicle filters set', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
      );

      expect(filters.hasAnyFilter, isFalse);
    });

    test('clearField preserves vehicle listingType when clearing other fields',
        () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        make: 'Toyota',
        listingType: 'rental',
        priceMin: 20000,
        priceMax: 50000,
      );

      final clearedMake = filters.clearField('make');
      expect(clearedMake.make, isNull);
      expect(clearedMake.listingType, 'rental');
      expect(clearedMake.priceMin, 20000);
      expect(clearedMake.priceMax, 50000);

      final clearedPrice = clearedMake.clearField('price_min');
      expect(clearedPrice.priceMin, isNull);
      expect(clearedPrice.priceMax, isNull);
      expect(clearedPrice.listingType, 'rental');

      final clearedType = clearedPrice.clearField('listing_type');
      expect(clearedType.listingType, isNull);
      expect(clearedType.hasAnyFilter, isFalse);
    });

    test('toQueryParams includes listing_type for vehicles', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        make: 'Hyundai',
        listingType: 'sale',
      );

      final params = filters.toQueryParams();
      expect(params['make'], 'Hyundai');
      expect(params['listing_type'], 'sale');
    });

    test('toQueryParams includes listing_type for property', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.property,
        propertyType: 'house',
        listingType: 'rental',
      );

      final params = filters.toQueryParams();
      expect(params['type'], 'house');
      expect(params['listing_type'], 'rental');
    });

    test('toQueryParams sends include_all_types for the mixed home feed', () {
      const filters = UnifiedFilterValues(category: HomeCategory.all);

      expect(filters.toQueryParams()['include_all_types'], isTrue);
    });

    test('vehicle rentals drop price filters and price sorts', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        listingType: 'rental',
        priceMin: 10000,
        priceMax: 50000,
        sort: 'price_high',
      );

      final params = filters.toQueryParams();
      expect(params.containsKey('price_min'), isFalse);
      expect(params.containsKey('price_max'), isFalse);
      expect(params.containsKey('sort'), isFalse);
    });

    test('vehicle sale keeps price filters and maps year/mileage sorts', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        listingType: 'sale',
        priceMin: 1000000,
        priceMax: 5000000,
        sort: 'mileage_low',
      );

      final params = filters.toQueryParams();
      expect(params['price_min'], 1000000);
      expect(params['price_max'], 5000000);
      expect(params['sort'], 'mileage');
      expect(params['order'], 'asc');
    });

    test('property sale filters include area and rooms', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.property,
        listingType: 'sale',
        areaMin: 60,
        areaMax: 180,
        bedrooms: 2,
        bathrooms: 1,
      );

      final params = filters.toQueryParams();
      expect(params['area_min'], 60);
      expect(params['area_max'], 180);
      expect(params['bedrooms'], 2);
      expect(params['bathrooms'], 1);
    });

    test('property rental filters drop area', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.property,
        listingType: 'rental',
        areaMin: 60,
        areaMax: 180,
        bedrooms: 2,
        bathrooms: 1,
      );

      final params = filters.toQueryParams();
      expect(params.containsKey('area_min'), isFalse);
      expect(params.containsKey('area_max'), isFalse);
      expect(params['bedrooms'], 2);
      expect(params['bathrooms'], 1);
    });

    test('rental period is not sent for sale properties', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.property,
        listingType: 'sale',
        rentalPeriod: 'month',
      );

      expect(
        filters.toQueryParams().containsKey('rental_period_unit'),
        isFalse,
      );
    });

    test('job filters include salary_min for postings', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.jobs,
        jobCategory: 'technology',
        jobType: 'full_time',
        educationLevel: "bachelor's",
        jobSalaryMin: 15000,
      );

      final params = filters.toQueryParams();
      expect(params['job_category'], 'technology');
      expect(params['job_type'], 'full_time');
      expect(params['education_level'], "bachelor's");
      expect(params['salary_min'], 15000);
      expect(params.containsKey('sort'), isFalse);
    });

    test('seeker filters skip job type and salary', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.jobs,
        forSeekers: true,
        jobCategory: 'technology',
        jobType: 'full_time',
        educationLevel: "bachelor's",
        jobSalaryMin: 15000,
      );

      final params = filters.toQueryParams();
      expect(params['job_category'], 'technology');
      expect(params['education_level'], "bachelor's");
      expect(params.containsKey('job_type'), isFalse);
      expect(params.containsKey('salary_min'), isFalse);
    });

    test('clearField resets dependent vehicle fields', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        vehicleCategory: 'car',
        make: 'Toyota',
        model: 'Corolla',
        bodyType: 'sedan',
        condition: 'used',
        yearMin: 2015,
        yearMax: 2020,
        mileageMax: 90000,
      );

      final cleared = filters.clearField('vehicle_category');
      expect(cleared.vehicleCategory, isNull);
      expect(cleared.make, isNull);
      expect(cleared.model, isNull);
      expect(cleared.bodyType, isNull);
      expect(cleared.condition, isNull);
      expect(cleared.yearMin, isNull);
      expect(cleared.yearMax, isNull);
      expect(cleared.mileageMax, isNull);
      expect(cleared.hasAnyFilter, isFalse);
    });

    test('clearField handles new property, vehicle and job keys', () {
      const base = UnifiedFilterValues(category: HomeCategory.property);

      expect(base.copyWith(areaMin: 10).clearField('area_min').areaMin, isNull);
      expect(
          base.copyWith(bedrooms: 3).clearField('bedrooms').bedrooms, isNull);
      expect(base.copyWith(bathrooms: 2).clearField('bathrooms').bathrooms,
          isNull);
      expect(
        base
            .copyWith(rentalPeriod: 'year')
            .clearField('rental_period_unit')
            .rentalPeriod,
        isNull,
      );
      expect(
        base.copyWith(condition: 'used').clearField('condition').condition,
        isNull,
      );
      expect(
        base.copyWith(jobSalaryMin: 5000).clearField('salary_min').jobSalaryMin,
        isNull,
      );
    });

    test('copyWith can explicitly null every field', () {
      const filters = UnifiedFilterValues(
        category: HomeCategory.jobs,
        jobCategory: 'technology',
        jobSalaryMin: 10000,
        educationLevel: "bachelor's",
      );

      final cleared = filters.copyWith(
        jobCategory: null,
        jobSalaryMin: null,
        educationLevel: null,
      );

      expect(cleared.hasAnyFilter, isFalse);
      expect(cleared.jobCategory, isNull);
      expect(cleared.jobSalaryMin, isNull);
      expect(cleared.educationLevel, isNull);
    });

    test('equality compares every filter field and hashCode agrees', () {
      const a = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        make: 'Toyota',
        condition: 'used',
      );
      const b = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        make: 'Toyota',
        condition: 'used',
      );
      const c = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        make: 'Toyota',
        condition: 'new',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}
