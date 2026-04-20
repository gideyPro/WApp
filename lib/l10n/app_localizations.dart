import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ti.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('ti')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'WaveMart'**
  String get appTitle;

  /// No description provided for @commonUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get commonUser;

  /// No description provided for @commonNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNA;

  /// No description provided for @commonAppInitials.
  ///
  /// In en, this message translates to:
  /// **'WM'**
  String get commonAppInitials;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @commonYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commonYou;

  /// No description provided for @commonNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get commonNow;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get commonNoData;

  /// No description provided for @commonRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get commonRetryMessage;

  /// No description provided for @commonComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get commonComingSoon;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get navListings;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homeDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover your perfect property'**
  String get homeDiscover;

  /// No description provided for @homeFeaturedPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium properties'**
  String get homeFeaturedPremium;

  /// No description provided for @homeLatestRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeLatestRecently;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEdit;

  /// No description provided for @profileEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your information'**
  String get profileEditSubtitle;

  /// No description provided for @profileMyListings.
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get profileMyListings;

  /// No description provided for @myListingsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing to get started'**
  String get myListingsEmptySubtitle;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profileMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileMessages;

  /// No description provided for @profilePayments.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get profilePayments;

  /// No description provided for @profileKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get profileKyc;

  /// No description provided for @profileSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get profileSubscriptions;

  /// No description provided for @profileHelp.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelp;

  /// No description provided for @profileNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not Logged In'**
  String get profileNotLoggedIn;

  /// No description provided for @profileLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get profileLoginPrompt;

  /// No description provided for @profileVerificationPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profileVerificationPhone;

  /// No description provided for @profileVerificationKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get profileVerificationKyc;

  /// No description provided for @profileStatsListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get profileStatsListings;

  /// No description provided for @profileStatsMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get profileStatsMessages;

  /// No description provided for @profileStatsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileStatsFavorites;

  /// No description provided for @kycTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycTitle;

  /// No description provided for @kycVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity Verified'**
  String get kycVerifiedTitle;

  /// No description provided for @kycVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified. You can now create listings and access all features.'**
  String get kycVerifiedSubtitle;

  /// No description provided for @kycCreateListing.
  ///
  /// In en, this message translates to:
  /// **'Create a Listing'**
  String get kycCreateListing;

  /// No description provided for @kycPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get kycPendingTitle;

  /// No description provided for @kycPendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your documents are being reviewed. This usually takes 24-48 hours.'**
  String get kycPendingSubtitle;

  /// No description provided for @kycSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted: {date}'**
  String kycSubmittedAt(Object date);

  /// No description provided for @kycRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get kycRefreshStatus;

  /// No description provided for @kycRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification Rejected'**
  String get kycRejectedTitle;

  /// No description provided for @kycRejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String kycRejectedReason(Object reason);

  /// No description provided for @kycRejectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please resubmit with clear, readable documents.'**
  String get kycRejectedSubtitle;

  /// No description provided for @kycResubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit Documents'**
  String get kycResubmit;

  /// No description provided for @kycInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'Please upload clear photos of your ID document to verify your identity.'**
  String get kycInfoBanner;

  /// No description provided for @kycDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Document Type'**
  String get kycDocumentType;

  /// No description provided for @kycNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get kycNationalId;

  /// No description provided for @kycPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get kycPassport;

  /// No description provided for @kycFrontOfDocument.
  ///
  /// In en, this message translates to:
  /// **'Front of Document'**
  String get kycFrontOfDocument;

  /// No description provided for @kycFrontSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear photo of the front side'**
  String get kycFrontSubtitle;

  /// No description provided for @kycBackOfDocument.
  ///
  /// In en, this message translates to:
  /// **'Back of Document'**
  String get kycBackOfDocument;

  /// No description provided for @kycBackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear photo of the back side'**
  String get kycBackSubtitle;

  /// No description provided for @kycSelfieWithDocument.
  ///
  /// In en, this message translates to:
  /// **'Selfie with Document'**
  String get kycSelfieWithDocument;

  /// No description provided for @kycSelfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hold your ID next to your face'**
  String get kycSelfieSubtitle;

  /// No description provided for @kycSubmitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get kycSubmitForVerification;

  /// No description provided for @kycTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get kycTapToChange;

  /// No description provided for @kycSelectDocumentType.
  ///
  /// In en, this message translates to:
  /// **'Please select a document type'**
  String get kycSelectDocumentType;

  /// No description provided for @kycUploadFront.
  ///
  /// In en, this message translates to:
  /// **'Please upload front image'**
  String get kycUploadFront;

  /// No description provided for @kycSuccess.
  ///
  /// In en, this message translates to:
  /// **'KYC submitted successfully! Awaiting approval.'**
  String get kycSuccess;

  /// No description provided for @kycError.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String kycError(Object error);

  /// No description provided for @profileKycStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileKycStatusVerified;

  /// No description provided for @profileKycStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get profileKycStatusPending;

  /// No description provided for @profileKycStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get profileKycStatusRequired;

  /// No description provided for @searchFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get searchFilters;

  /// No description provided for @searchPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get searchPropertyType;

  /// No description provided for @searchListingStatus.
  ///
  /// In en, this message translates to:
  /// **'Listing Status'**
  String get searchListingStatus;

  /// No description provided for @searchPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get searchPriceRange;

  /// No description provided for @searchSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get searchSortBy;

  /// No description provided for @searchApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get searchApplyFilters;

  /// No description provided for @searchReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get searchReset;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by location...'**
  String get searchPlaceholder;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get searchClearAll;

  /// No description provided for @searchFindProperty.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Property'**
  String get searchFindProperty;

  /// No description provided for @searchWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by location, filter by type and status to discover amazing properties'**
  String get searchWelcomeSubtitle;

  /// No description provided for @searchPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get searchPopular;

  /// No description provided for @searchUnder5M.
  ///
  /// In en, this message translates to:
  /// **'💰 Under 5M'**
  String get searchUnder5M;

  /// No description provided for @search5M10M.
  ///
  /// In en, this message translates to:
  /// **'💎 5M - 10M'**
  String get search5M10M;

  /// No description provided for @search10M50M.
  ///
  /// In en, this message translates to:
  /// **'🏆 10M - 50M'**
  String get search10M50M;

  /// No description provided for @search50M100M.
  ///
  /// In en, this message translates to:
  /// **'👑 50M - 100M'**
  String get search50M100M;

  /// No description provided for @search100MPlus.
  ///
  /// In en, this message translates to:
  /// **'✨ 100M+'**
  String get search100MPlus;

  /// No description provided for @searchNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Properties Found'**
  String get searchNoResultsTitle;

  /// No description provided for @searchNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters to find more results'**
  String get searchNoResultsSubtitle;

  /// No description provided for @searchFoundCount.
  ///
  /// In en, this message translates to:
  /// **'{count} properties found'**
  String searchFoundCount(Object count);

  /// No description provided for @searchSortNewest.
  ///
  /// In en, this message translates to:
  /// **'🆕 Newest'**
  String get searchSortNewest;

  /// No description provided for @searchSortOldest.
  ///
  /// In en, this message translates to:
  /// **'📅 Oldest'**
  String get searchSortOldest;

  /// No description provided for @searchSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'💰 Price ↑'**
  String get searchSortPriceLow;

  /// No description provided for @searchSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'💎 Price ↓'**
  String get searchSortPriceHigh;

  /// No description provided for @searchFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchFilterAll;

  /// No description provided for @searchFilterAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get searchFilterAny;

  /// No description provided for @listingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get listingNext;

  /// No description provided for @listingSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get listingSubmit;

  /// No description provided for @listingSubmitListing.
  ///
  /// In en, this message translates to:
  /// **'Submit Listing'**
  String get listingSubmitListing;

  /// No description provided for @listingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get listingContinue;

  /// No description provided for @listingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get listingBack;

  /// No description provided for @listingStepBasics.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get listingStepBasics;

  /// No description provided for @listingStepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get listingStepDetails;

  /// No description provided for @listingStepMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get listingStepMedia;

  /// No description provided for @listingStepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get listingStepReview;

  /// No description provided for @listingPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get listingPropertyType;

  /// No description provided for @listingHoldingType.
  ///
  /// In en, this message translates to:
  /// **'Holding Type'**
  String get listingHoldingType;

  /// No description provided for @listingTaxPaid.
  ///
  /// In en, this message translates to:
  /// **'Tax Paid Until'**
  String get listingTaxPaid;

  /// No description provided for @listingLeaseHolder.
  ///
  /// In en, this message translates to:
  /// **'Lease Holder'**
  String get listingLeaseHolder;

  /// No description provided for @listingLeaseOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get listingLeaseOrganization;

  /// No description provided for @listingLeaseExpiry.
  ///
  /// In en, this message translates to:
  /// **'Lease Expiry'**
  String get listingLeaseExpiry;

  /// No description provided for @listingUseType.
  ///
  /// In en, this message translates to:
  /// **'Use Type'**
  String get listingUseType;

  /// No description provided for @listingLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get listingLocation;

  /// No description provided for @listingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get listingPrice;

  /// No description provided for @listingPriceEtb.
  ///
  /// In en, this message translates to:
  /// **'Price (ETB)'**
  String get listingPriceEtb;

  /// No description provided for @listingHasDebt.
  ///
  /// In en, this message translates to:
  /// **'Has Debt or Encumbrance'**
  String get listingHasDebt;

  /// No description provided for @listingDebtAmount.
  ///
  /// In en, this message translates to:
  /// **'Debt Amount'**
  String get listingDebtAmount;

  /// No description provided for @listingSelectHolding.
  ///
  /// In en, this message translates to:
  /// **'Select holding type'**
  String get listingSelectHolding;

  /// No description provided for @listingSelectUse.
  ///
  /// In en, this message translates to:
  /// **'Select use type'**
  String get listingSelectUse;

  /// No description provided for @listingRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get listingRegion;

  /// No description provided for @listingZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get listingZone;

  /// No description provided for @listingWoreda.
  ///
  /// In en, this message translates to:
  /// **'Woreda'**
  String get listingWoreda;

  /// No description provided for @listingKebele.
  ///
  /// In en, this message translates to:
  /// **'Kebele'**
  String get listingKebele;

  /// No description provided for @listingSpecificLocation.
  ///
  /// In en, this message translates to:
  /// **'Specific Location (optional)'**
  String get listingSpecificLocation;

  /// No description provided for @listingTaxPaidYear.
  ///
  /// In en, this message translates to:
  /// **'Tax Paid Until Year'**
  String get listingTaxPaidYear;

  /// No description provided for @listingAcquisition.
  ///
  /// In en, this message translates to:
  /// **'Acquisition Clarification'**
  String get listingAcquisition;

  /// No description provided for @listingLeasedYear.
  ///
  /// In en, this message translates to:
  /// **'Leased Year'**
  String get listingLeasedYear;

  /// No description provided for @listingLeasePrice.
  ///
  /// In en, this message translates to:
  /// **'Lease Price per m²'**
  String get listingLeasePrice;

  /// No description provided for @listingBuildType.
  ///
  /// In en, this message translates to:
  /// **'Build Type'**
  String get listingBuildType;

  /// No description provided for @listingAnnualPayment.
  ///
  /// In en, this message translates to:
  /// **'Annual Payment'**
  String get listingAnnualPayment;

  /// No description provided for @listingCooperativeName.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Name'**
  String get listingCooperativeName;

  /// No description provided for @listingCooperativeCode.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Code'**
  String get listingCooperativeCode;

  /// No description provided for @listingBuildingStatus.
  ///
  /// In en, this message translates to:
  /// **'Building Status'**
  String get listingBuildingStatus;

  /// No description provided for @listingRoomConfig.
  ///
  /// In en, this message translates to:
  /// **'Room Configuration'**
  String get listingRoomConfig;

  /// No description provided for @listingTotalRooms.
  ///
  /// In en, this message translates to:
  /// **'Total Rooms'**
  String get listingTotalRooms;

  /// No description provided for @listingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get listingPhotos;

  /// No description provided for @listingBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get listingBedrooms;

  /// No description provided for @listingBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get listingBathrooms;

  /// No description provided for @listingKitchens.
  ///
  /// In en, this message translates to:
  /// **'Kitchens'**
  String get listingKitchens;

  /// No description provided for @listingKitchensCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Kitchen(s)'**
  String listingKitchensCount(Object count);

  /// No description provided for @listingSalons.
  ///
  /// In en, this message translates to:
  /// **'Salons'**
  String get listingSalons;

  /// No description provided for @listingHouseType.
  ///
  /// In en, this message translates to:
  /// **'House Type'**
  String get listingHouseType;

  /// No description provided for @listingSelectHouseType.
  ///
  /// In en, this message translates to:
  /// **'Select house type'**
  String get listingSelectHouseType;

  /// No description provided for @listingAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get listingAmenities;

  /// No description provided for @listingElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get listingElectricity;

  /// No description provided for @listingWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get listingWater;

  /// No description provided for @listingParking.
  ///
  /// In en, this message translates to:
  /// **'Parking'**
  String get listingParking;

  /// No description provided for @listingAreaDimensions.
  ///
  /// In en, this message translates to:
  /// **'Area Dimensions'**
  String get listingAreaDimensions;

  /// No description provided for @listingTotalArea.
  ///
  /// In en, this message translates to:
  /// **'Total Area (m²)'**
  String get listingTotalArea;

  /// No description provided for @listingFrontArea.
  ///
  /// In en, this message translates to:
  /// **'Front Area (m²)'**
  String get listingFrontArea;

  /// No description provided for @listingSideArea.
  ///
  /// In en, this message translates to:
  /// **'Side Area (m²)'**
  String get listingSideArea;

  /// No description provided for @listingFacingDirection.
  ///
  /// In en, this message translates to:
  /// **'Facing Direction'**
  String get listingFacingDirection;

  /// No description provided for @listingSelectDirection.
  ///
  /// In en, this message translates to:
  /// **'Select direction'**
  String get listingSelectDirection;

  /// No description provided for @listingDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingDescriptionLabel;

  /// No description provided for @listingDescribeProperty.
  ///
  /// In en, this message translates to:
  /// **'Describe your property'**
  String get listingDescribeProperty;

  /// No description provided for @listingImages.
  ///
  /// In en, this message translates to:
  /// **'Property Images (Required)'**
  String get listingImages;

  /// No description provided for @listingSitePlans.
  ///
  /// In en, this message translates to:
  /// **'Site Plans (Required)'**
  String get listingSitePlans;

  /// No description provided for @listingOwnershipProof.
  ///
  /// In en, this message translates to:
  /// **'Ownership Proof'**
  String get listingOwnershipProof;

  /// No description provided for @listingLeaseContract.
  ///
  /// In en, this message translates to:
  /// **'Lease Contract'**
  String get listingLeaseContract;

  /// No description provided for @listingTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add images'**
  String get listingTapToAdd;

  /// No description provided for @listingImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} image(s) selected'**
  String listingImagesSelected(Object count);

  /// No description provided for @listingBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get listingBrowseFiles;

  /// No description provided for @listingBrowseFile.
  ///
  /// In en, this message translates to:
  /// **'Browse File'**
  String get listingBrowseFile;

  /// No description provided for @listingChangeFile.
  ///
  /// In en, this message translates to:
  /// **'Change: {name}'**
  String listingChangeFile(Object name);

  /// No description provided for @listingSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get listingSummary;

  /// No description provided for @listingNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get listingNew;

  /// No description provided for @listingAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms & Conditions'**
  String get listingAcceptTerms;

  /// No description provided for @listingTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'By submitting, you agree to our terms and privacy policy'**
  String get listingTermsSubtitle;

  /// No description provided for @listingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing submitted successfully! Awaiting approval.'**
  String get listingSuccess;

  /// No description provided for @listingError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String listingError(Object error);

  /// No description provided for @listingNoOptions.
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get listingNoOptions;

  /// No description provided for @listingSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get listingSelect;

  /// No description provided for @listingFreeHold.
  ///
  /// In en, this message translates to:
  /// **'Free Hold'**
  String get listingFreeHold;

  /// No description provided for @listingLeaseHold.
  ///
  /// In en, this message translates to:
  /// **'Lease Hold'**
  String get listingLeaseHold;

  /// No description provided for @listingCooperative.
  ///
  /// In en, this message translates to:
  /// **'Cooperative'**
  String get listingCooperative;

  /// No description provided for @listingResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get listingResidential;

  /// No description provided for @listingCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get listingCommercial;

  /// No description provided for @listingMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get listingMixed;

  /// No description provided for @listingInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get listingInvestment;

  /// No description provided for @listingFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get listingFinished;

  /// No description provided for @listingUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Unfinished'**
  String get listingUnfinished;

  /// No description provided for @listingNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get listingNorth;

  /// No description provided for @listingSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get listingSouth;

  /// No description provided for @listingEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get listingEast;

  /// No description provided for @listingWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get listingWest;

  /// No description provided for @listingNorthEast.
  ///
  /// In en, this message translates to:
  /// **'North East'**
  String get listingNorthEast;

  /// No description provided for @listingNorthWest.
  ///
  /// In en, this message translates to:
  /// **'North West'**
  String get listingNorthWest;

  /// No description provided for @listingSouthEast.
  ///
  /// In en, this message translates to:
  /// **'South East'**
  String get listingSouthEast;

  /// No description provided for @listingSouthWest.
  ///
  /// In en, this message translates to:
  /// **'South West'**
  String get listingSouthWest;

  /// No description provided for @listingVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get listingVilla;

  /// No description provided for @listingApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get listingApartment;

  /// No description provided for @listingCondominium.
  ///
  /// In en, this message translates to:
  /// **'Condominium'**
  String get listingCondominium;

  /// No description provided for @listingTownhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get listingTownhouse;

  /// No description provided for @listingBungalow.
  ///
  /// In en, this message translates to:
  /// **'Bungalow'**
  String get listingBungalow;

  /// No description provided for @listingPurchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get listingPurchased;

  /// No description provided for @listingInherited.
  ///
  /// In en, this message translates to:
  /// **'Inherited'**
  String get listingInherited;

  /// No description provided for @listingGift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get listingGift;

  /// No description provided for @listingAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get listingAssignment;

  /// No description provided for @listingOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get listingOther;

  /// No description provided for @listingFreeHoldDetails.
  ///
  /// In en, this message translates to:
  /// **'Free Hold Details'**
  String get listingFreeHoldDetails;

  /// No description provided for @listingLeaseHoldDetails.
  ///
  /// In en, this message translates to:
  /// **'Lease Hold Details'**
  String get listingLeaseHoldDetails;

  /// No description provided for @listingCooperativeDetails.
  ///
  /// In en, this message translates to:
  /// **'Cooperative Details'**
  String get listingCooperativeDetails;

  /// No description provided for @listingFinancial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get listingFinancial;

  /// No description provided for @listingSummaryProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get listingSummaryProperty;

  /// No description provided for @listingFeatured.
  ///
  /// In en, this message translates to:
  /// **'FEATURED'**
  String get listingFeatured;

  /// No description provided for @listingHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get listingHouse;

  /// No description provided for @listingLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get listingLand;

  /// No description provided for @listingHouses.
  ///
  /// In en, this message translates to:
  /// **'🏠 Houses'**
  String get listingHouses;

  /// No description provided for @listingLands.
  ///
  /// In en, this message translates to:
  /// **'🌄 Lands'**
  String get listingLands;

  /// No description provided for @listingPriceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on Request'**
  String get listingPriceOnRequest;

  /// No description provided for @listingUnknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown Location'**
  String get listingUnknownLocation;

  /// No description provided for @listingToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get listingToday;

  /// No description provided for @listingYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get listingYesterday;

  /// No description provided for @listingDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String listingDaysAgo(Object count);

  /// No description provided for @listingWeeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String listingWeeksAgo(Object count);

  /// No description provided for @listingMonthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} months ago'**
  String listingMonthsAgo(Object count);

  /// No description provided for @listingSale.
  ///
  /// In en, this message translates to:
  /// **'💰 Sale'**
  String get listingSale;

  /// No description provided for @listingRent.
  ///
  /// In en, this message translates to:
  /// **'🔑 Rent'**
  String get listingRent;

  /// No description provided for @listingForSale.
  ///
  /// In en, this message translates to:
  /// **'💰 For Sale'**
  String get listingForSale;

  /// No description provided for @listingForRent.
  ///
  /// In en, this message translates to:
  /// **'🔑 For Rent'**
  String get listingForRent;

  /// No description provided for @listingUnitM2.
  ///
  /// In en, this message translates to:
  /// **'{count} m²'**
  String listingUnitM2(Object count);

  /// No description provided for @listingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listingsTitle;

  /// No description provided for @listingsCreate.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get listingsCreate;

  /// No description provided for @listingsFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get listingsFeatured;

  /// No description provided for @listingsNoResults.
  ///
  /// In en, this message translates to:
  /// **'No listings found'**
  String get listingsNoResults;

  /// No description provided for @listingsDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get listingsDetails;

  /// No description provided for @listingsKeyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get listingsKeyFeatures;

  /// No description provided for @listingsImInterested.
  ///
  /// In en, this message translates to:
  /// **'I\'m Interested'**
  String get listingsImInterested;

  /// No description provided for @listingsInterestedHint.
  ///
  /// In en, this message translates to:
  /// **'Let the owner know you\'re interested in this property'**
  String get listingsInterestedHint;

  /// No description provided for @listingsInterestedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your message to the owner (optional)'**
  String get listingsInterestedPlaceholder;

  /// No description provided for @listingsSubmitInterest.
  ///
  /// In en, this message translates to:
  /// **'Submit Interest'**
  String get listingsSubmitInterest;

  /// No description provided for @listingsInterestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Interest submitted successfully!'**
  String get listingsInterestSubmitted;

  /// No description provided for @listingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get listingsDescription;

  /// No description provided for @listingsPropertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get listingsPropertyDetails;

  /// No description provided for @listingsBedrooms.
  ///
  /// In en, this message translates to:
  /// **'{count} Bedrooms'**
  String listingsBedrooms(Object count);

  /// No description provided for @listingsBathrooms.
  ///
  /// In en, this message translates to:
  /// **'{count} Bathrooms'**
  String listingsBathrooms(Object count);

  /// No description provided for @listingsSalons.
  ///
  /// In en, this message translates to:
  /// **'{count} Salons'**
  String listingsSalons(Object count);

  /// No description provided for @listingsFrontArea.
  ///
  /// In en, this message translates to:
  /// **'Front Area'**
  String get listingsFrontArea;

  /// No description provided for @listingsSideArea.
  ///
  /// In en, this message translates to:
  /// **'Side Area'**
  String get listingsSideArea;

  /// No description provided for @listingsUseType.
  ///
  /// In en, this message translates to:
  /// **'Use Type'**
  String get listingsUseType;

  /// No description provided for @listingsHoldingType.
  ///
  /// In en, this message translates to:
  /// **'Holding Type'**
  String get listingsHoldingType;

  /// No description provided for @listingsFacing.
  ///
  /// In en, this message translates to:
  /// **'Facing'**
  String get listingsFacing;

  /// No description provided for @listingsNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get listingsNegotiable;

  /// No description provided for @listingsEncumbrance.
  ///
  /// In en, this message translates to:
  /// **'Encumbrance'**
  String get listingsEncumbrance;

  /// No description provided for @listingsEncumbranceYes.
  ///
  /// In en, this message translates to:
  /// **'Yes ({amount} ETB)'**
  String listingsEncumbranceYes(Object amount);

  /// No description provided for @listingsVideoTour.
  ///
  /// In en, this message translates to:
  /// **'Video Tour'**
  String get listingsVideoTour;

  /// No description provided for @listingsNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get listingsNoDescription;

  /// No description provided for @listingsNoFeatures.
  ///
  /// In en, this message translates to:
  /// **'No key features specified'**
  String get listingsNoFeatures;

  /// No description provided for @listingsNotFound.
  ///
  /// In en, this message translates to:
  /// **'Listing Not Found'**
  String get listingsNotFound;

  /// No description provided for @listingsNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This property may have been removed'**
  String get listingsNotFoundSubtitle;

  /// No description provided for @listingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load property'**
  String get listingsLoadError;

  /// No description provided for @listingsTitleTemplate.
  ///
  /// In en, this message translates to:
  /// **'{type} {action} in {location}'**
  String listingsTitleTemplate(Object action, Object location, Object type);

  /// No description provided for @listingsPriceFixed.
  ///
  /// In en, this message translates to:
  /// **'{price} ETB'**
  String listingsPriceFixed(Object price);

  /// No description provided for @listingsPriceRange.
  ///
  /// In en, this message translates to:
  /// **'{min} - {max} ETB'**
  String listingsPriceRange(Object max, Object min);

  /// No description provided for @listingsYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get listingsYes;

  /// No description provided for @listingsNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get listingsNo;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding properties to your favorites'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoritesRemove;

  /// No description provided for @favoritesAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get favoritesAdded;

  /// No description provided for @favoritesRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoritesRemoved;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get messagesEmpty;

  /// No description provided for @messagesTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messagesTypeMessage;

  /// No description provided for @messagesSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get messagesSend;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get settingsSectionAccount;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSectionSupport;

  /// No description provided for @settingsSectionAuth.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsSectionAuth;

  /// No description provided for @settingsMyListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your properties'**
  String get settingsMyListingsSubtitle;

  /// No description provided for @settingsSubscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your plans'**
  String get settingsSubscriptionsSubtitle;

  /// No description provided for @settingsPaymentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get settingsPaymentsSubtitle;

  /// No description provided for @settingsKycVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get settingsKycVerified;

  /// No description provided for @settingsKycPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get settingsKycPending;

  /// No description provided for @settingsKycRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get settingsKycRequired;

  /// No description provided for @settingsHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQs and guides'**
  String get settingsHelpSubtitle;

  /// No description provided for @settingsContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get settingsContactSupport;

  /// No description provided for @settingsContactSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get settingsContactSupportSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsWebOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open {title}'**
  String settingsWebOpenError(Object title);

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select app theme'**
  String get settingsThemeSubtitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'About WaveMart'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsLogoutSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ (Amharic)'**
  String get languageAmharic;

  /// No description provided for @languageTigrinya.
  ///
  /// In en, this message translates to:
  /// **'ትግርኛ (Tigrinya)'**
  String get languageTigrinya;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get authEnterPhone;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// No description provided for @authVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get authVerifyOtp;

  /// No description provided for @authEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get authEnterOtp;

  /// No description provided for @authResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get authResendOtp;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get authLogoutConfirm;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a plan that fits your needs'**
  String get subscriptionsSubtitle;

  /// No description provided for @subscriptionsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get subscriptionsCurrentPlan;

  /// No description provided for @subscriptionsFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get subscriptionsFree;

  /// No description provided for @subscriptionsBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get subscriptionsBasic;

  /// No description provided for @subscriptionsPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get subscriptionsPremium;

  /// No description provided for @subscriptionsSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscriptionsSubscribe;

  /// No description provided for @subscriptionsSelectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get subscriptionsSelectPlan;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'ti':
      return AppLocalizationsTi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
