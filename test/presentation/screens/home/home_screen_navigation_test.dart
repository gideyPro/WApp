import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/presentation/screens/home/filter_sheet.dart';
import 'package:wavemart/presentation/screens/home/home_screen.dart';

void main() {
  group('HomeScreen Category and Section Hierarchy', () {
    test('HomeCategory order has All at the end', () {
      expect(HomeCategory.values, [
        HomeCategory.property,
        HomeCategory.vehicles,
        HomeCategory.jobs,
        HomeCategory.all,
      ]);
    });

    test('ListingTypeSection has sale and rent with correct wire values', () {
      expect(ListingTypeSection.values, [
        ListingTypeSection.sale,
        ListingTypeSection.rent,
      ]);
      expect(ListingTypeSection.sale.wireValue, 'sale');
      expect(ListingTypeSection.rent.wireValue, 'rental');
    });

    test('AllSection has all, sale, and rent with correct wire values', () {
      expect(AllSection.values, [
        AllSection.all,
        AllSection.sale,
        AllSection.rent,
      ]);
      expect(AllSection.all.wireValue, isNull);
      expect(AllSection.sale.wireValue, 'sale');
      expect(AllSection.rent.wireValue, 'rental');
    });

    test('JobsSection has listings and seekers', () {
      expect(JobsSection.values, [
        JobsSection.listings,
        JobsSection.seekers,
      ]);
    });

    test('UnifiedFilterValues defaults to property category', () {
      const filters = UnifiedFilterValues();
      expect(filters.category, HomeCategory.property);
    });

    test('UnifiedFilterValues allows listingType for all, property and vehicles', () {
      const propFilters = UnifiedFilterValues(
        category: HomeCategory.property,
        listingType: 'rental',
      );
      expect(propFilters.toQueryParams()['listing_type'], 'rental');

      const carFilters = UnifiedFilterValues(
        category: HomeCategory.vehicles,
        listingType: 'sale',
      );
      expect(carFilters.toQueryParams()['listing_type'], 'sale');

      const allFilters = UnifiedFilterValues(
        category: HomeCategory.all,
        listingType: 'rental',
      );
      expect(allFilters.toQueryParams()['include_all_types'], isTrue);
    });
  });
}
