import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/subscription.dart';

void main() {
  group('SubscriptionPlan rental quotas', () {
    test('parses max_rental_listings and max_rental_vehicles from JSON', () {
      final json = {
        'id': 1,
        'name': 'Pro Plan',
        'slug': 'pro',
        'price': '1000.00',
        'price_usd': '20.00',
        'max_listings': 5,
        'max_rental_listings': 10,
        'max_vehicles': 3,
        'max_rental_vehicles': 6,
        'max_jobs': 2,
        'max_contacts': 15,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.maxListings, 5);
      expect(plan.maxRentalListings, 10);
      expect(plan.maxVehicles, 3);
      expect(plan.maxRentalVehicles, 6);

      expect(plan.getQuota('max_listings'), 5);
      expect(plan.getQuota('max_rental_listings'), 10);
      expect(plan.getQuota('max_vehicles'), 3);
      expect(plan.getQuota('max_rental_vehicles'), 6);
    });

    test('defaults rental quotas to 0 when omitted', () {
      final json = {
        'id': 2,
        'name': 'Basic Plan',
        'slug': 'basic',
        'price': 0,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.maxRentalListings, 0);
      expect(plan.maxRentalVehicles, 0);
      expect(plan.getQuota('max_rental_listings'), 0);
      expect(plan.getQuota('max_rental_vehicles'), 0);
    });
  });

  group('Subscription rental usage', () {
    test('parses rental_listings_used and rental_vehicles_used from JSON', () {
      final json = {
        'id': 10,
        'user_id': 1,
        'plan_id': 1,
        'status': 'active',
        'starts_at': '2026-10-17T00:00:00.000Z',
        'listings_used': 2,
        'rental_listings_used': 4,
        'vehicles_used': 1,
        'rental_vehicles_used': 3,
      };

      final sub = Subscription.fromJson(json);

      expect(sub.listingsUsed, 2);
      expect(sub.rentalListingsUsed, 4);
      expect(sub.vehiclesUsed, 1);
      expect(sub.rentalVehiclesUsed, 3);
    });
  });

  group('SubscriptionPlan separate contact quotas and fallback', () {
    test('parses separate sale and rental contact quotas', () {
      final json = {
        'id': 3,
        'name': 'Premium',
        'slug': 'premium',
        'price': 1000,
        'max_contacts': 10,
        'max_rental_contacts': 5,
        'plan_features': {
          'max_contacts_car': 8,
          'max_rental_contacts_car': 3,
        },
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.maxContacts, 10);
      expect(plan.maxRentalContacts, 5);
      expect(plan.maxRentalContactsCar, 3);

      // Property Sale vs Rental
      expect(plan.maxContactsFor('listing', listingType: 'sale'), 10);
      expect(plan.maxContactsFor('listing', listingType: 'rental'), 5);

      // Vehicle Sale vs Rental
      expect(plan.maxContactsFor('car', listingType: 'sale'), 8);
      expect(plan.maxContactsFor('car', listingType: 'rental'), 3);
    });

    test('falls back rental contacts to sale contact quota when omitted', () {
      final json = {
        'id': 4,
        'name': 'Standard',
        'slug': 'standard',
        'price': 500,
        'max_contacts': 12,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.maxContacts, 12);
      expect(plan.maxRentalContacts, 12); // Fallback to max_contacts
      expect(plan.maxRentalContactsCar, 0);

      // Unspecified rental inherits sale quota
      expect(plan.maxContactsFor('listing', listingType: 'sale'), 12);
      expect(plan.maxContactsFor('listing', listingType: 'rental'), 12);

      // Car inherits base max_contacts
      expect(plan.maxContactsFor('car', listingType: 'sale'), 12);
      expect(plan.maxContactsFor('car', listingType: 'rental'), 12);
    });
  });

  group('SubscriptionPlan plan_features serialization shapes', () {
    test('parses relation-shaped plan_features (list of pivot rows)', () {
      // current_subscription.plan serializes the planFeatures relation, so
      // plan_features arrives as a list of rows instead of a flat map.
      final json = {
        'id': 6,
        'name': 'Premium',
        'slug': 'premium',
        'price': 1000,
        'max_contacts': 50,
        'plan_features': [
          {
            'feature_key': 'max_rental_contacts_car',
            'value_type': 'integer',
            'int_value': 7,
            'bool_value': null,
            'string_value': null,
          },
          {
            'feature_key': 'details_access',
            'value_type': 'string',
            'int_value': null,
            'bool_value': null,
            'string_value': 'full',
          },
          {
            'feature_key': 'view_vip',
            'value_type': 'boolean',
            'int_value': null,
            'bool_value': true,
            'string_value': null,
          },
        ],
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.planFeatures, isNotNull);
      expect(plan.maxRentalContactsCar, 7);
      expect(plan.planFeatures!['details_access'], 'full');
      expect(plan.planFeatures!['view_vip'], true);
      expect(plan.hasFeature('view_vip'), true);
    });

    test('does not throw when relation-shaped plan_features omits car quota',
        () {
      final json = {
        'id': 7,
        'name': 'Basic',
        'slug': 'basic',
        'price': 0,
        'plan_features': [
          {
            'feature_key': 'max_listings',
            'value_type': 'integer',
            'int_value': 3,
          },
        ],
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.maxRentalContactsCar, 0);
      expect(plan.getQuota('max_listings'), 3);
    });

    test('ignores plan_features values of unknown shape', () {
      final json = {
        'id': 8,
        'name': 'Legacy',
        'slug': 'legacy',
        'price': 0,
        'plan_features': 'not-a-map',
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.planFeatures, isNull);
      expect(plan.maxRentalContactsCar, 0);
    });
  });
}
