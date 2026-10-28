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

  group('SubscriptionPlan billing cycles (Option C)', () {
    test('parses explicit billing_cycles from JSON', () {
      final json = {
        'id': 10,
        'name': 'Basic Plan',
        'slug': 'basic',
        'price': 500,
        'price_usd': 10,
        'listing_duration_days': 30,
        'billing_cycles': [
          {
            'months': 1,
            'price': 500,
            'price_usd': 10,
            'listing_duration_days': 30,
            'discount_percent': null,
            'badge': null,
          },
          {
            'months': 3,
            'price': 1350,
            'price_usd': 27,
            'listing_duration_days': 90,
            'discount_percent': 10,
            'badge': 'Popular',
          },
          {
            'months': 6,
            'price': 2400,
            'price_usd': 48,
            'listing_duration_days': 180,
            'discount_percent': 20,
            'badge': 'Best Value',
          },
        ],
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.billingCycles.length, 3);

      final cycle1 = plan.getBillingCycle(1);
      expect(cycle1, isNotNull);
      expect(cycle1!.months, 1);
      expect(cycle1.price, 500.0);
      expect(cycle1.priceUsd, 10.0);
      expect(cycle1.listingDurationDays, 30);
      expect(cycle1.discountPercent, 0);
      expect(cycle1.badge, isNull);
      expect(cycle1.getDisplayPrice('ETB'), '500 ETB');
      expect(cycle1.getDisplayPrice('USD'), '\$10.00');

      final cycle3 = plan.getBillingCycle(3);
      expect(cycle3, isNotNull);
      expect(cycle3!.months, 3);
      expect(cycle3.price, 1350.0);
      expect(cycle3.discountPercent, 10);
      expect(cycle3.badge, 'Popular');
      expect(cycle3.listingDurationDays, 90);

      final cycle6 = plan.getBillingCycle(6);
      expect(cycle6, isNotNull);
      expect(cycle6!.months, 6);
      expect(cycle6.price, 2400.0);
      expect(cycle6.discountPercent, 20);
      expect(cycle6.badge, 'Best Value');
      expect(cycle6.listingDurationDays, 180);

      expect(plan.getListingDurationForMonths(1), 30);
      expect(plan.getListingDurationForMonths(3), 90);
      expect(plan.getListingDurationForMonths(6), 180);
    });

    test('synthesizes 1/3/6 month cycles with default discounts when billing_cycles omitted', () {
      final json = {
        'id': 11,
        'name': 'Premium',
        'slug': 'premium',
        'price': 1000,
        'price_usd': 20,
        'listing_duration_days': 30,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.billingCycles.length, 3);
      expect(plan.billingCycles[0].months, 1);
      expect(plan.billingCycles[0].price, 1000.0);
      expect(plan.billingCycles[0].listingDurationDays, 30);

      expect(plan.billingCycles[1].months, 3);
      expect(plan.billingCycles[1].price, 2700.0);
      expect(plan.billingCycles[1].discountPercent, 10);
      expect(plan.billingCycles[1].badge, 'Popular');
      expect(plan.billingCycles[1].listingDurationDays, 90);

      expect(plan.billingCycles[2].months, 6);
      expect(plan.billingCycles[2].price, 4800.0);
      expect(plan.billingCycles[2].discountPercent, 20);
      expect(plan.billingCycles[2].badge, 'Best Value');
      expect(plan.billingCycles[2].listingDurationDays, 180);
    });

    test('free plan synthesizes single cycle honoring duration_months', () {
      final json = {
        'id': 12,
        'name': 'Free',
        'slug': 'free',
        'price': 0,
        'price_usd': 0,
        'duration_months': 12,
        'listing_duration_days': 15,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.billingCycles.length, 1);
      expect(plan.billingCycles[0].months, 12);
      expect(plan.billingCycles[0].price, 0.0);
      expect(plan.billingCycles[0].listingDurationDays, 15);
    });

    test('legacy paid plan with duration_months > 1 synthesizes single cycle for full duration', () {
      final json = {
        'id': 13,
        'name': 'Annual Pro',
        'slug': 'annual-pro',
        'price': 12000,
        'price_usd': 240,
        'duration_months': 12,
        'listing_duration_days': 30,
      };

      final plan = SubscriptionPlan.fromJson(json);

      expect(plan.billingCycles.length, 1);
      expect(plan.billingCycles[0].months, 12);
      expect(plan.billingCycles[0].price, 12000.0);
      expect(plan.billingCycles[0].priceUsd, 240.0);
      expect(plan.billingCycles[0].listingDurationDays, 30);
    });

    test('uses effective promo prices when the API provides them', () {
      final cycle = PlanBillingCycle.fromJson({
        'months': 3,
        'price': 1350,
        'price_usd': 27,
        'listing_duration_days': 90,
        'discount_percent': 10,
        'badge': 'Popular',
        'original_price': 1350,
        'original_price_usd': 27,
        'effective_price': 1215,
        'effective_price_usd': 24.3,
        'applied_discount_percent': 10,
        'applied_discount_type': 'overall',
      });

      expect(cycle.getDisplayPrice('ETB'), '1215 ETB');
      expect(cycle.getDisplayPrice('USD'), '\$24.30');
      expect(cycle.getOriginalDisplayPrice('ETB'), '1350 ETB');
      expect(cycle.getOriginalDisplayPrice('USD'), '\$27.00');
      expect(cycle.hasAppliedDiscount, isTrue);
      expect(cycle.isUpgradeDiscount, isFalse);
    });

    test('falls back to the stored price without effective fields', () {
      final cycle = PlanBillingCycle.fromJson({
        'months': 1,
        'price': 500,
        'price_usd': 10,
        'listing_duration_days': 30,
      });

      expect(cycle.effectivePrice, isNull);
      expect(cycle.appliedDiscountPercent, 0);
      expect(cycle.hasAppliedDiscount, isFalse);
      expect(cycle.getDisplayPrice('ETB'), '500 ETB');
      expect(cycle.getDisplayPrice('USD'), '\$10.00');
    });
  });

  group('Subscription billing cycle and listing duration snapshot', () {
    test('parses billing_cycle_months and listing_duration_days', () {
      final json = {
        'id': 20,
        'user_id': 1,
        'plan_id': 10,
        'status': 'active',
        'starts_at': '2026-10-28T00:00:00.000Z',
        'billing_cycle_months': 3,
        'listing_duration_days': 90,
      };

      final sub = Subscription.fromJson(json);

      expect(sub.billingCycleMonths, 3);
      expect(sub.listingDurationDays, 90);
      expect(sub.effectiveListingDurationDays, 90);
    });

    test('effectiveListingDurationDays falls back to plan or default 30', () {
      final jsonWithoutDuration = {
        'id': 21,
        'user_id': 1,
        'plan_id': 10,
        'status': 'active',
        'starts_at': '2026-10-28T00:00:00.000Z',
        'billing_cycle_months': 6,
      };

      final subNoPlan = Subscription.fromJson(jsonWithoutDuration);
      expect(subNoPlan.listingDurationDays, isNull);
      expect(subNoPlan.effectiveListingDurationDays, 30);

      final jsonWithPlan = {
        'id': 22,
        'user_id': 1,
        'plan_id': 10,
        'status': 'active',
        'starts_at': '2026-10-28T00:00:00.000Z',
        'billing_cycle_months': 3,
        'plan': {
          'id': 10,
          'name': 'Basic',
          'slug': 'basic',
          'price': 500,
          'listing_duration_days': 30,
          'billing_cycles': [
            {'months': 3, 'price': 1350, 'listing_duration_days': 75},
          ],
        },
      };

      final subWithPlan = Subscription.fromJson(jsonWithPlan);
      expect(subWithPlan.effectiveListingDurationDays, 75);
    });
  });
}
