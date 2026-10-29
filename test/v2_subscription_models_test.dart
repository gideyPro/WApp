import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/core/network/v2/paginated.dart';
import 'package:wavemart/data/models/v2/payment_state.dart';
import 'package:wavemart/data/models/v2/subscription_state.dart';

import 'v2_fixtures.dart';

void main() {
  group('subscription overview fixture', () {
    late SubscriptionOverview overview;

    setUp(() {
      overview = SubscriptionOverview.fromJson(
        loadV2Fixture('subscription.show.json')['data'] as Map,
      );
    });

    test('parses the active free subscription', () {
      expect(overview.enabled, isTrue);
      expect(overview.hasActiveSubscription, isTrue);

      final subscription = overview.subscription!;
      expect(subscription.id, 12);
      expect(subscription.status, 'active');
      expect(subscription.plan?.slug, 'free');
      expect(subscription.billingCycleMonths, 12);
      expect(subscription.listingDurationDays, 30);
      expect(subscription.isActive, isTrue);
      expect(subscription.isTrial, isFalse);
      expect(subscription.isOnTrial, isFalse);
      expect(subscription.daysRemaining, 365);
      expect(subscription.trialEndsAt, isNull);
      expect(
        subscription.endsAt?.toUtc(),
        DateTime.utc(2027, 10, 29, 8),
      );
      expect(subscription.usage.listings, 0);
      expect(subscription.usage.featuredListings, 0);
    });

    test('reads quota, boolean and tier capabilities from one key space', () {
      final capabilities = overview.capabilities;

      expect(capabilities.maxListings?.max, 0);
      expect(capabilities.maxListings?.allowed, isTrue);
      expect(capabilities.maxListings?.remaining, 0);
      expect(capabilities.maxListings?.hasCapacity, isFalse);
      expect(capabilities.maxVehicles?.isQuota, isTrue);

      expect(capabilities.canViewVip, isFalse);
      expect(capabilities.canViewVideo, isFalse);
      expect(capabilities.canAccessContact, isFalse);

      expect(capabilities.detailsAccess, 'discovery');
      expect(capabilities.detailsAccessCar, 'discovery');
      expect(capabilities.detailsAccessJob, 'discovery');
      expect(capabilities.quota('max_jobs'), 0);
      expect(capabilities['missing'], isNull);
    });

    test('treats an anonymous or disabled overview as no subscription', () {
      final disabled = SubscriptionOverview.fromJson({
        'enabled': false,
        'subscription': null,
        'capabilities': <String, dynamic>{},
      });

      expect(disabled.enabled, isFalse);
      expect(disabled.subscription, isNull);
      expect(disabled.hasActiveSubscription, isFalse);
      expect(disabled.capabilities.maxListings, isNull);
    });
  });

  group('capability', () {
    test('computes remaining quota and capacity', () {
      const quota = Capability(allowed: true, used: 4, max: 5);
      expect(quota.isQuota, isTrue);
      expect(quota.remaining, 1);
      expect(quota.hasCapacity, isTrue);

      const full = Capability(allowed: true, used: 5, max: 5);
      expect(full.remaining, 0);
      expect(full.hasCapacity, isFalse);

      const blocked = Capability(allowed: false, used: 0, max: 5);
      expect(blocked.hasCapacity, isFalse);

      const flag = Capability(allowed: true);
      expect(flag.isQuota, isFalse);
      expect(flag.remaining, 0);
      expect(flag.hasCapacity, isTrue);
    });
  });

  group('payments fixture', () {
    test('parses the history envelope', () {
      final page = Paginated.fromJson(
        loadV2Fixture('payments.index.json'),
        PaymentState.fromJson,
      );

      expect(page.items, hasLength(1));
      expect(page.hasMore, isFalse);
      expect(page.perPage, 20);

      final payment = page.items.single;
      expect(payment.id, 31);
      expect(payment.txRef, 'wm-sub-20261029-abc123');
      expect(payment.type, 'subscription');
      expect(payment.status, PaymentStatusV2.success);
      expect(payment.isSuccessful, isTrue);
      expect(payment.isPending, isFalse);
      expect(payment.amount, 1350);
      expect(payment.currency, 'ETB');
      expect(payment.plan?.slug, 'basic');
      expect(payment.paymentMethod, 'telebirr');
      expect(payment.isActivated, isTrue);
      expect(payment.paidAt?.toUtc(), DateTime.utc(2026, 10, 29, 9, 5));
      expect(
        payment.activatedAt?.toUtc(),
        DateTime.utc(2026, 10, 29, 9, 5, 10),
      );
    });

    test('parses every status wire value', () {
      expect(PaymentStatusV2.parse('pending'), PaymentStatusV2.pending);
      expect(PaymentStatusV2.parse('success'), PaymentStatusV2.success);
      expect(PaymentStatusV2.parse('failed'), PaymentStatusV2.failed);
      expect(PaymentStatusV2.parse('cancelled'), PaymentStatusV2.cancelled);
      expect(PaymentStatusV2.parse('refunded'), PaymentStatusV2.unknown);
      expect(PaymentStatusV2.parse(null), PaymentStatusV2.unknown);

      expect(PaymentStatusV2.pending.isPending, isTrue);
      expect(PaymentStatusV2.success.isSettled, isTrue);
      expect(PaymentStatusV2.pending.isSettled, isFalse);
    });
  });

  group('checkout result', () {
    test('free checkout activates without a payment', () {
      final result = CheckoutResult.fromJson({
        'activated': true,
        'checkout_url': null,
        'payment': null,
        'subscription': {
          'id': 13,
          'status': 'active',
          'plan': {'id': 1, 'slug': 'free', 'name': 'Free'},
          'billing_cycle_months': 12,
          'listing_duration_days': 30,
          'is_active': true,
          'is_trial': false,
        },
      });

      expect(result.activated, isTrue);
      expect(result.needsGateway, isFalse);
      expect(result.payment, isNull);
      expect(result.subscription?.plan?.slug, 'free');
    });

    test('paid checkout exposes the gateway url and pending payment', () {
      final result = CheckoutResult.fromJson({
        'activated': false,
        'checkout_url': 'https://checkout.chapa.test/abc',
        'payment': {
          'id': 32,
          'tx_ref': 'tx-paid',
          'type': 'subscription',
          'status': 'pending',
          'amount': 1350,
          'currency': 'ETB',
          'plan': {'id': 2, 'slug': 'basic', 'name': 'Basic'},
          'payment_method': null,
          'paid_at': null,
          'activated_at': null,
          'created_at': '2026-10-29T09:00:00Z',
        },
        'subscription': null,
      });

      expect(result.activated, isFalse);
      expect(result.hasCheckoutUrl, isTrue);
      expect(result.needsGateway, isTrue);
      expect(result.payment?.isPending, isTrue);
      expect(result.payment?.plan?.id, 2);
      expect(result.subscription, isNull);
    });
  });

  group('payment verification', () {
    test('parses an activated subscription', () {
      final verification = PaymentVerification.fromJson({
        'status': 'success',
        'payment': {
          'id': 32,
          'tx_ref': 'tx-paid',
          'type': 'subscription',
          'status': 'success',
          'amount': 1350,
          'currency': 'ETB',
          'plan': {'id': 2, 'slug': 'basic', 'name': 'Basic'},
          'activated_at': '2026-10-29T09:05:10Z',
        },
        'subscription': {
          'id': 14,
          'status': 'active',
          'plan': {'id': 2, 'slug': 'basic', 'name': 'Basic'},
          'billing_cycle_months': 3,
          'listing_duration_days': 90,
          'is_active': true,
          'is_trial': false,
        },
      });

      expect(verification.isSuccess, isTrue);
      expect(verification.isPending, isFalse);
      expect(verification.payment.isActivated, isTrue);
      expect(verification.subscription?.billingCycleMonths, 3);
      expect(verification.subscription?.listingDurationDays, 90);
      expect(verification.activatedSubscription, isTrue);
    });

    test('parses a pending verification without a subscription', () {
      final verification = PaymentVerification.fromJson({
        'status': 'pending',
        'payment': {
          'id': 33,
          'tx_ref': 'tx-pending',
          'type': 'subscription',
          'status': 'pending',
          'amount': 500,
          'currency': 'ETB',
          'plan': null,
        },
        'subscription': null,
      });

      expect(verification.isPending, isTrue);
      expect(verification.isSuccess, isFalse);
      expect(verification.activatedSubscription, isFalse);
      expect(verification.payment.plan, isNull);
    });
  });
}
