import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/data/models/listing_form_data.dart';
import 'package:wavemart/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  ListingFormData rentalForm() => ListingFormData(
        type: 'house',
        listingType: 'rental',
        holdingType: 'Free Hold',
        useType: 'Residential',
        addressId: 1,
        priceFixed: 15000,
        rentalPeriodUnit: 'month',
      );

  test('requires owner name and phone for other-owner rental listings', () {
    final form = rentalForm()
      ..postedForOtherOwner = true
      ..ownerName = ''
      ..ownerPhone = '';

    final errors = form.validateStep1(l10n);

    expect(errors, contains(l10n.listingOwnerNameRequired));
    expect(errors, contains(l10n.listingOwnerPhoneRequired));
  });

  test('accepts a complete other-owner contact', () {
    final form = rentalForm()
      ..postedForOtherOwner = true
      ..ownerName = 'Property Owner'
      ..ownerPhone = '+251922000222';

    final errors = form.validateStep1(l10n);

    expect(errors, isNot(contains(l10n.listingOwnerNameRequired)));
    expect(errors, isNot(contains(l10n.listingOwnerPhoneRequired)));
  });

  test('ignores owner contact for sale listings', () {
    final form = rentalForm()
      ..listingType = 'sale'
      ..postedForOtherOwner = true;

    final errors = form.validateStep1(l10n);

    expect(errors, isNot(contains(l10n.listingOwnerNameRequired)));
    expect(errors, isNot(contains(l10n.listingOwnerPhoneRequired)));
  });
}
