// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WaveMart';

  @override
  String get commonUser => 'User';

  @override
  String get commonNA => 'N/A';

  @override
  String get commonAppInitials => 'WM';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get commonYou => 'You';

  @override
  String get commonNow => 'Now';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'Error';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonNoData => 'No data available';

  @override
  String get commonRetryMessage => 'Please try again';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get navHome => 'Home';

  @override
  String get navListings => 'Listings';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMessages => 'Messages';

  @override
  String get navSettings => 'Settings';

  @override
  String homeGreeting(Object name) {
    return 'Hi, $name';
  }

  @override
  String get homeDiscover => 'Discover your perfect property';

  @override
  String get homeFeaturedPremium => 'Premium properties';

  @override
  String get homeLatestRecently => 'Recently added';

  @override
  String get homeViewAll => 'View All';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileEditSubtitle => 'Update your information';

  @override
  String get profileMyListings => 'My Listings';

  @override
  String get myListingsEmptySubtitle =>
      'Create your first listing to get started';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileMessages => 'Messages';

  @override
  String get profilePayments => 'Payment History';

  @override
  String get profileKyc => 'KYC Verification';

  @override
  String get profileSubscriptions => 'Subscriptions';

  @override
  String get profileHelp => 'Help Center';

  @override
  String get profileNotLoggedIn => 'Not Logged In';

  @override
  String get profileLoginPrompt => 'Please log in to view your profile';

  @override
  String get profileVerificationPhone => 'Phone';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'Listings';

  @override
  String get profileStatsMessages => 'Messages';

  @override
  String get profileStatsFavorites => 'Favorites';

  @override
  String get kycTitle => 'KYC Verification';

  @override
  String get kycVerifiedTitle => 'Identity Verified';

  @override
  String get kycVerifiedSubtitle =>
      'Your identity has been verified. You can now create listings and access all features.';

  @override
  String get kycCreateListing => 'Create a Listing';

  @override
  String get kycPendingTitle => 'Verification Pending';

  @override
  String get kycPendingSubtitle =>
      'Your documents are being reviewed. This usually takes 24-48 hours.';

  @override
  String kycSubmittedAt(Object date) {
    return 'Submitted: $date';
  }

  @override
  String get kycRefreshStatus => 'Refresh Status';

  @override
  String get kycRejectedTitle => 'Verification Rejected';

  @override
  String kycRejectedReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get kycRejectedSubtitle =>
      'Please resubmit with clear, readable documents.';

  @override
  String get kycResubmit => 'Resubmit Documents';

  @override
  String get kycInfoBanner =>
      'Please upload clear photos of your ID document to verify your identity.';

  @override
  String get kycDocumentType => 'Document Type';

  @override
  String get kycNationalId => 'National ID';

  @override
  String get kycPassport => 'Passport';

  @override
  String get kycFrontOfDocument => 'Front of Document';

  @override
  String get kycFrontSubtitle => 'Clear photo of the front side';

  @override
  String get kycBackOfDocument => 'Back of Document';

  @override
  String get kycBackSubtitle => 'Clear photo of the back side';

  @override
  String get kycSelfieWithDocument => 'Selfie with Document';

  @override
  String get kycSelfieSubtitle => 'Hold your ID next to your face';

  @override
  String get kycSubmitForVerification => 'Submit for Verification';

  @override
  String get kycTapToChange => 'Tap to change';

  @override
  String get kycSelectDocumentType => 'Please select a document type';

  @override
  String get kycUploadFront => 'Please upload front image';

  @override
  String get kycSuccess => 'KYC submitted successfully! Awaiting approval.';

  @override
  String kycError(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get profileKycStatusVerified => 'Verified';

  @override
  String get profileKycStatusPending => 'Pending';

  @override
  String get profileKycStatusRequired => 'Required';

  @override
  String get searchFilters => 'Filters';

  @override
  String get searchPropertyType => 'Property Type';

  @override
  String get searchListingStatus => 'Listing Status';

  @override
  String get searchPriceRange => 'Price Range';

  @override
  String get searchSortBy => 'Sort By';

  @override
  String get searchApplyFilters => 'Apply Filters';

  @override
  String get searchReset => 'Reset';

  @override
  String get searchPlaceholder => 'Search by location...';

  @override
  String get searchClearAll => 'Clear All';

  @override
  String get searchFindProperty => 'Find Your Perfect Property';

  @override
  String get searchWelcomeSubtitle =>
      'Search by location, filter by type and status to discover amazing properties';

  @override
  String get searchPopular => 'Popular Searches';

  @override
  String get searchUnder5M => '💰 Under 5M';

  @override
  String get search5M10M => '💎 5M - 10M';

  @override
  String get search10M50M => '🏆 10M - 50M';

  @override
  String get search50M100M => '👑 50M - 100M';

  @override
  String get search100MPlus => '✨ 100M+';

  @override
  String get searchNoResultsTitle => 'No Properties Found';

  @override
  String get searchNoResultsSubtitle =>
      'Try adjusting your search or filters to find more results';

  @override
  String searchFoundCount(Object count) {
    return '$count properties found';
  }

  @override
  String get searchSortNewest => '🆕 Newest';

  @override
  String get searchSortOldest => '📅 Oldest';

  @override
  String get searchSortPriceLow => '💰 Price ↑';

  @override
  String get searchSortPriceHigh => '💎 Price ↓';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterAny => 'Any';

  @override
  String get listingNext => 'Next';

  @override
  String get listingSubmit => 'Submit';

  @override
  String get listingSubmitListing => 'Submit Listing';

  @override
  String get listingContinue => 'Continue';

  @override
  String get listingBack => 'Back';

  @override
  String get listingStepBasics => 'Basics';

  @override
  String get listingStepDetails => 'Details';

  @override
  String get listingStepMedia => 'Media';

  @override
  String get listingStepReview => 'Review';

  @override
  String get listingPropertyType => 'Property Type';

  @override
  String get listingHoldingType => 'Holding Type';

  @override
  String get listingUseType => 'Use Type';

  @override
  String get listingLocation => 'Location';

  @override
  String get listingPrice => 'Price';

  @override
  String get listingPriceEtb => 'Price (ETB)';

  @override
  String get listingHasDebt => 'Has Debt or Encumbrance';

  @override
  String get listingDebtAmount => 'Debt Amount';

  @override
  String get listingSelectHolding => 'Select holding type';

  @override
  String get listingSelectUse => 'Select use type';

  @override
  String get listingRegion => 'Region';

  @override
  String get listingZone => 'Zone';

  @override
  String get listingWoreda => 'Woreda';

  @override
  String get listingKebele => 'Kebele';

  @override
  String get listingSpecificLocation => 'Specific Location (optional)';

  @override
  String get listingTaxPaidYear => 'Tax Paid Until Year';

  @override
  String get listingAcquisition => 'Acquisition Clarification';

  @override
  String get listingLeasedYear => 'Leased Year';

  @override
  String get listingLeasePrice => 'Lease Price per m²';

  @override
  String get listingBuildType => 'Build Type';

  @override
  String get listingAnnualPayment => 'Annual Payment';

  @override
  String get listingCooperativeName => 'Cooperative Name';

  @override
  String get listingCooperativeCode => 'Cooperative Code';

  @override
  String get listingBuildingStatus => 'Building Status';

  @override
  String get listingRoomConfig => 'Room Configuration';

  @override
  String get listingTotalRooms => 'Total Rooms';

  @override
  String get listingBedrooms => 'Bedrooms';

  @override
  String get listingBathrooms => 'Bathrooms';

  @override
  String get listingKitchens => 'Kitchens';

  @override
  String get listingSalons => 'Salons';

  @override
  String get listingHouseType => 'House Type';

  @override
  String get listingSelectHouseType => 'Select house type';

  @override
  String get listingAmenities => 'Amenities';

  @override
  String get listingElectricity => 'Electricity';

  @override
  String get listingWater => 'Water';

  @override
  String get listingParking => 'Parking';

  @override
  String get listingAreaDimensions => 'Area Dimensions';

  @override
  String get listingTotalArea => 'Total Area (m²)';

  @override
  String get listingFrontArea => 'Front Area (m²)';

  @override
  String get listingSideArea => 'Side Area (m²)';

  @override
  String get listingFacingDirection => 'Facing Direction';

  @override
  String get listingSelectDirection => 'Select direction';

  @override
  String get listingDescriptionLabel => 'Description';

  @override
  String get listingDescribeProperty => 'Describe your property';

  @override
  String get listingImages => 'Property Images (Required)';

  @override
  String get listingSitePlans => 'Site Plans (Required)';

  @override
  String get listingOwnershipProof => 'Ownership Proof';

  @override
  String get listingLeaseContract => 'Lease Contract';

  @override
  String get listingTapToAdd => 'Tap to add images';

  @override
  String listingImagesSelected(Object count) {
    return '$count image(s) selected';
  }

  @override
  String get listingBrowseFiles => 'Browse Files';

  @override
  String get listingBrowseFile => 'Browse File';

  @override
  String listingChangeFile(Object name) {
    return 'Change: $name';
  }

  @override
  String get listingSummary => 'Summary';

  @override
  String get listingNew => 'NEW';

  @override
  String get listingAcceptTerms => 'I accept the Terms & Conditions';

  @override
  String get listingTermsSubtitle =>
      'By submitting, you agree to our terms and privacy policy';

  @override
  String get listingSuccess =>
      'Listing submitted successfully! Awaiting approval.';

  @override
  String listingError(Object error) {
    return 'Error: $error';
  }

  @override
  String get listingNoOptions => 'No options available';

  @override
  String get listingSelect => 'Select';

  @override
  String get listingFreeHold => 'Free Hold';

  @override
  String get listingLeaseHold => 'Lease Hold';

  @override
  String get listingCooperative => 'Cooperative';

  @override
  String get listingResidential => 'Residential';

  @override
  String get listingCommercial => 'Commercial';

  @override
  String get listingMixed => 'Mixed';

  @override
  String get listingInvestment => 'Investment';

  @override
  String get listingFinished => 'Finished';

  @override
  String get listingUnfinished => 'Unfinished';

  @override
  String get listingNorth => 'North';

  @override
  String get listingSouth => 'South';

  @override
  String get listingEast => 'East';

  @override
  String get listingWest => 'West';

  @override
  String get listingNorthEast => 'North East';

  @override
  String get listingNorthWest => 'North West';

  @override
  String get listingSouthEast => 'South East';

  @override
  String get listingSouthWest => 'South West';

  @override
  String get listingVilla => 'Villa';

  @override
  String get listingApartment => 'Apartment';

  @override
  String get listingCondominium => 'Condominium';

  @override
  String get listingTownhouse => 'Townhouse';

  @override
  String get listingBungalow => 'Bungalow';

  @override
  String get listingPurchased => 'Purchased';

  @override
  String get listingInherited => 'Inherited';

  @override
  String get listingGift => 'Gift';

  @override
  String get listingAssignment => 'Assignment';

  @override
  String get listingOther => 'Other';

  @override
  String get listingFreeHoldDetails => 'Free Hold Details';

  @override
  String get listingLeaseHoldDetails => 'Lease Hold Details';

  @override
  String get listingCooperativeDetails => 'Cooperative Details';

  @override
  String get listingFinancial => 'Financial';

  @override
  String get listingSummaryProperty => 'Property';

  @override
  String get listingFeatured => 'FEATURED';

  @override
  String get listingHouse => 'House';

  @override
  String get listingLand => 'Land';

  @override
  String get listingHouses => '🏠 Houses';

  @override
  String get listingLands => '🌄 Lands';

  @override
  String get listingPriceOnRequest => 'Price on Request';

  @override
  String get listingUnknownLocation => 'Unknown Location';

  @override
  String get listingToday => 'Today';

  @override
  String get listingYesterday => 'Yesterday';

  @override
  String listingDaysAgo(Object count) {
    return '$count days ago';
  }

  @override
  String listingWeeksAgo(Object count) {
    return '$count weeks ago';
  }

  @override
  String listingMonthsAgo(Object count) {
    return '$count months ago';
  }

  @override
  String get listingSale => '💰 Sale';

  @override
  String get listingRent => '🔑 Rent';

  @override
  String get listingForSale => '💰 For Sale';

  @override
  String get listingForRent => '🔑 For Rent';

  @override
  String listingUnitM2(Object count) {
    return '$count m²';
  }

  @override
  String get listingsTitle => 'Listings';

  @override
  String get listingsCreate => 'List';

  @override
  String get listingsFeatured => 'Featured';

  @override
  String get listingsNoResults => 'No listings found';

  @override
  String get listingsDetails => 'Property Details';

  @override
  String get listingsKeyFeatures => 'Key Features';

  @override
  String get listingsDescription => 'Description';

  @override
  String get listingsPropertyDetails => 'Property Details';

  @override
  String listingsBedrooms(Object count) {
    return '$count Bedrooms';
  }

  @override
  String listingsBathrooms(Object count) {
    return '$count Bathrooms';
  }

  @override
  String listingsSalons(Object count) {
    return '$count Salons';
  }

  @override
  String get listingsFrontArea => 'Front Area';

  @override
  String get listingsSideArea => 'Side Area';

  @override
  String get listingsUseType => 'Use Type';

  @override
  String get listingsHoldingType => 'Holding Type';

  @override
  String get listingsFacing => 'Facing';

  @override
  String get listingsNegotiable => 'Negotiable';

  @override
  String get listingsEncumbrance => 'Encumbrance';

  @override
  String listingsEncumbranceYes(Object amount) {
    return 'Yes ($amount ETB)';
  }

  @override
  String get listingsVideoTour => 'Video Tour';

  @override
  String get listingsNoDescription => 'No description provided.';

  @override
  String get listingsNoFeatures => 'No key features specified';

  @override
  String get listingsNotFound => 'Listing Not Found';

  @override
  String get listingsNotFoundSubtitle => 'This property may have been removed';

  @override
  String get listingsLoadError => 'Could not load property';

  @override
  String listingsTitleTemplate(Object action, Object location, Object type) {
    return '$type $action in $location';
  }

  @override
  String listingsPriceFixed(Object price) {
    return '$price ETB';
  }

  @override
  String listingsPriceRange(Object max, Object min) {
    return '$min - $max ETB';
  }

  @override
  String get listingsYes => 'Yes';

  @override
  String get listingsNo => 'No';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Start adding properties to your favorites';

  @override
  String get favoritesRemove => 'Remove from favorites';

  @override
  String get favoritesAdded => 'Added to favorites';

  @override
  String get favoritesRemoved => 'Removed from favorites';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No messages yet';

  @override
  String get messagesTypeMessage => 'Type a message...';

  @override
  String get messagesSend => 'Send';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionAccount => 'My Account';

  @override
  String get settingsSectionSupport => 'Support';

  @override
  String get settingsSectionAuth => 'Account';

  @override
  String get settingsMyListingsSubtitle => 'Manage your properties';

  @override
  String get settingsSubscriptionsSubtitle => 'View your plans';

  @override
  String get settingsPaymentsSubtitle => 'Transaction history';

  @override
  String get settingsKycVerified => 'Verified';

  @override
  String get settingsKycPending => 'Pending';

  @override
  String get settingsKycRequired => 'Required';

  @override
  String get settingsHelpSubtitle => 'FAQs and guides';

  @override
  String get settingsContactSupport => 'Contact Support';

  @override
  String get settingsContactSupportSubtitle => 'Get in touch';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String settingsWebOpenError(Object title) {
    return 'Could not open $title';
  }

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Change app language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSubtitle => 'Select app theme';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage notifications';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacySubtitle => 'Privacy settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutSubtitle => 'About WaveMart';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutSubtitle => 'Sign out of your account';

  @override
  String get languageTitle => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ (Amharic)';

  @override
  String get languageTigrinya => 'ትግርኛ (Tigrinya)';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authEnterPhone => 'Enter your phone number';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authVerifyOtp => 'Verify OTP';

  @override
  String get authEnterOtp => 'Enter 6-digit OTP';

  @override
  String get authResendOtp => 'Resend OTP';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authLogout => 'Logout';

  @override
  String get authLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get subscriptionsTitle => 'Subscription Plans';

  @override
  String get subscriptionsSubtitle => 'Select a plan that fits your needs';

  @override
  String get subscriptionsCurrentPlan => 'Current Plan';

  @override
  String get subscriptionsFree => 'Free';

  @override
  String get subscriptionsBasic => 'Basic';

  @override
  String get subscriptionsPremium => 'Premium';

  @override
  String get subscriptionsSubscribe => 'Subscribe Now';

  @override
  String get subscriptionsSelectPlan => 'Select Plan';
}
