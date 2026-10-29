import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/v2/app_config.dart';
import 'package:wavemart/data/services/v2/catalog_filters.dart';

void main() {
  group('ListingFilters', () {
    test('serializes every supported filter to the contract keys', () {
      const filters = ListingFilters(
        type: 'house',
        listingType: 'rental',
        rentalPeriodUnit: 'month',
        location: '  Bole  ',
        priceMin: 1000,
        priceMax: 9000,
        areaMin: 50,
        areaMax: 400,
        minBedrooms: 2,
        minBathrooms: 1,
        isFeatured: true,
        sort: CatalogSort.priceLow,
      );

      expect(filters.toQuery(), {
        'type': 'house',
        'listing_type': 'rental',
        'rental_period_unit': 'month',
        'location': 'Bole',
        'price_min': 1000.0,
        'price_max': 9000.0,
        'area_min': 50.0,
        'area_max': 400.0,
        'bedrooms': 2,
        'bathrooms': 1,
        'is_featured': true,
        'sort': 'price_low',
      });
    });

    test('omits unset and blank filters', () {
      const filters = ListingFilters(location: '   ');

      expect(filters.toQuery(), {'sort': 'newest'});
    });
  });

  group('CarFilters', () {
    test('serializes car-specific filters', () {
      const filters = CarFilters(
        make: ' Toyota ',
        model: 'Corolla',
        yearMin: 2018,
        yearMax: 2022,
        mileageMax: 120000,
        condition: 'used',
        bodyType: 'sedan',
        vehicleCategory: 'private',
        transmission: 'automatic',
        fuelType: 'petrol',
        sort: CatalogSort.priceHigh,
      );

      expect(filters.toQuery(), {
        'make': 'Toyota',
        'model': 'Corolla',
        'year_min': 2018,
        'year_max': 2022,
        'mileage_max': 120000.0,
        'condition': 'used',
        'body_type': 'sedan',
        'vehicle_category': 'private',
        'transmission': 'automatic',
        'fuel_type': 'petrol',
        'sort': 'price_high',
      });
    });
  });

  group('JobFilters', () {
    test('serializes search and salary filters', () {
      const filters = JobFilters(
        search: ' Accountant ',
        location: 'Addis Ababa',
        jobCategory: 'finance',
        jobType: 'full_time',
        educationLevel: 'degree',
        salaryMin: 10000,
        salaryMax: 25000,
      );

      expect(filters.toQuery(), {
        'search': 'Accountant',
        'location': 'Addis Ababa',
        'job_category': 'finance',
        'job_type': 'full_time',
        'education_level': 'degree',
        'salary_min': 10000.0,
        'salary_max': 25000.0,
        'sort': 'newest',
      });
    });

    test('jobs only expose the newest/oldest sort', () {
      expect(JobSort.values.map((sort) => sort.wireValue), ['newest', 'oldest']);
    });
  });

  group('AppUpdateType', () {
    test('maps backend wire values', () {
      expect(AppUpdateType.parse('none'), AppUpdateType.none);
      expect(AppUpdateType.parse('non_blocking'), AppUpdateType.nonBlocking);
      expect(AppUpdateType.parse('blocking'), AppUpdateType.blocking);
      expect(AppUpdateType.parse(null), AppUpdateType.none);
      expect(AppUpdateType.parse('surprise'), AppUpdateType.none);
    });

    test('non-blocking updates are recommendations, not gates', () {
      const config = AppConfig(
        latestBuild: 10,
        updateType: AppUpdateType.nonBlocking,
      );

      expect(config.isUpdateRecommended(3), isTrue);
      expect(config.isUpdateRequired(3), isFalse);
    });
  });
}
