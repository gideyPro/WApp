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

    test('clearField preserves vehicle listingType when clearing other fields', () {
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
  });
}
