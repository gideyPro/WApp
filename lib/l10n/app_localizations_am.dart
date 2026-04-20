// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'ዌቭማርት';

  @override
  String get commonUser => 'ተጠቃሚ';

  @override
  String get commonNA => 'የለም';

  @override
  String get commonAppInitials => 'ዌማ';

  @override
  String get commonUnknown => 'ያልታወቀ';

  @override
  String get commonYou => 'እርስዎ';

  @override
  String get commonNow => 'አሁን';

  @override
  String get commonOk => 'እሺ';

  @override
  String get commonCancel => 'ይቅር';

  @override
  String get commonSave => 'አስቀምጥ';

  @override
  String get commonDelete => 'ሰርዝ';

  @override
  String get commonEdit => 'አስተካክል';

  @override
  String get commonRetry => 'እንደገና ሞክር';

  @override
  String get commonLoading => 'በመጫን ላይ...';

  @override
  String get commonError => 'ስህተት';

  @override
  String get commonSuccess => 'ተሳክቷል';

  @override
  String get commonNoData => 'ምንም መረጃ የለም';

  @override
  String get commonRetryMessage => 'እባክዎ እንደገና ይሞክሩ';

  @override
  String get commonComingSoon => 'በቅርብ ቀን ይገኛል';

  @override
  String get navHome => 'መነሻ';

  @override
  String get navListings => 'ንብረቶች';

  @override
  String get navSearch => 'ፍለጋ';

  @override
  String get navFavorites => 'ተወዳጆች';

  @override
  String get navProfile => 'መገለጫ';

  @override
  String get navMessages => 'መልእክቶች';

  @override
  String get navSettings => 'ቅንብሮች';

  @override
  String homeGreeting(Object name) {
    return 'ሰላም፣ $name';
  }

  @override
  String get homeDiscover => 'የሚፈልጉትን ንብረት እዚህ ያግኙ';

  @override
  String get homeFeaturedPremium => 'ልዩ ንብረቶች';

  @override
  String get homeLatestRecently => 'በቅርቡ የወጡ';

  @override
  String get homeViewAll => 'ሁሉንም ይመልከቱ';

  @override
  String get profileTitle => 'መገለጫ';

  @override
  String get profileEdit => 'መገለጫ ያስተካክሉ';

  @override
  String get profileEditSubtitle => 'መረጃዎን ያዘምኑ';

  @override
  String get profileMyListings => 'የእኔ ንብረቶች';

  @override
  String get myListingsEmptySubtitle => 'ለመጀመር የመጀመሪያዎን ንብረት ይጨምሩ';

  @override
  String get profileFavorites => 'ተወዳጆች';

  @override
  String get profileMessages => 'መልእክቶች';

  @override
  String get profilePayments => 'የክፍያ ታሪክ';

  @override
  String get profileKyc => 'የማንነት ማረጋገጫ (KYC)';

  @override
  String get profileSubscriptions => 'የአባልነት ዕቅዶች';

  @override
  String get profileHelp => 'የእርዳታ ማዕከል';

  @override
  String get profileNotLoggedIn => 'አልገቡም';

  @override
  String get profileLoginPrompt => 'እባክዎ መገለጫዎን ለማየት ይግቡ';

  @override
  String get profileVerificationPhone => 'ስልክ';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'ንብረቶች';

  @override
  String get profileStatsMessages => 'መልእክቶች';

  @override
  String get profileStatsFavorites => 'ተወዳጆች';

  @override
  String get kycTitle => 'ማንነት ማረጋገጫ (KYC)';

  @override
  String get kycVerifiedTitle => 'ማንነት ተረጋግጧል';

  @override
  String get kycVerifiedSubtitle =>
      'ማንነትዎ ተረጋግጧል። አሁን ንብረቶችን መመዝገብ እና ሁሉንም አገልግሎቶች ማግኘት ይችላሉ።';

  @override
  String get kycCreateListing => 'ንብረት መዝግብ';

  @override
  String get kycPendingTitle => 'ማረጋገጫ በመጠባበቅ ላይ';

  @override
  String get kycPendingSubtitle =>
      'ሰነዶችዎ እየተገመገሙ ነው። ይህ ብዙውን ጊዜ ከ24-48 ሰዓታት ይወስዳል።';

  @override
  String kycSubmittedAt(Object date) {
    return 'ገቢ የተደረገበት ቀን: $date';
  }

  @override
  String get kycRefreshStatus => 'ሁኔታውን አድስ';

  @override
  String get kycRejectedTitle => 'ማረጋገጫ ውድቅ ተደርጓል';

  @override
  String kycRejectedReason(Object reason) {
    return 'ምክንያት: $reason';
  }

  @override
  String get kycRejectedSubtitle => 'እባክዎን ግልጽ እና ተነባቢ ሰነዶችን እንደገና ይላኩ።';

  @override
  String get kycResubmit => 'ሰነዶችን እንደገና ላክ';

  @override
  String get kycInfoBanner => 'ማንነትዎን ለማረጋገጥ እባክዎ የማንነት ሰነድዎን ግልጽ ፎቶዎች ያያይዙ።';

  @override
  String get kycDocumentType => 'የሰነድ ዓይነት';

  @override
  String get kycNationalId => 'ብሔራዊ መታወቂያ';

  @override
  String get kycPassport => 'ፓስፖርት';

  @override
  String get kycFrontOfDocument => 'የሰነዱ የፊት ገጽ';

  @override
  String get kycFrontSubtitle => 'የፊት ገጹ ግልጽ ፎቶ';

  @override
  String get kycBackOfDocument => 'የሰነዱ የጀርባ ገጽ';

  @override
  String get kycBackSubtitle => 'የጀርባ ገጹ ግልጽ ፎቶ';

  @override
  String get kycSelfieWithDocument => 'ከሰነዱ ጋር ያለዎት ፎቶ';

  @override
  String get kycSelfieSubtitle => 'መታወቂያዎን ከፊትዎ አጠገብ ይዘው ይነሱ';

  @override
  String get kycSubmitForVerification => 'ለማረጋገጫ ላክ';

  @override
  String get kycTapToChange => 'ለመቀየር ይንኩ';

  @override
  String get kycSelectDocumentType => 'እባክዎን የሰነድ ዓይነት ይምረጡ';

  @override
  String get kycUploadFront => 'እባክዎን የፊት ገጽ ፎቶ ያያይዙ';

  @override
  String get kycSuccess => 'ማረጋገጫው በትክክል ተልኳል! በግምገማ ላይ ነው።';

  @override
  String kycError(Object error) {
    return 'ፎቶ ማንሳት አልተቻለም: $error';
  }

  @override
  String get profileKycStatusVerified => 'ተረጋግጧል';

  @override
  String get profileKycStatusPending => 'በመጠባበቅ ላይ';

  @override
  String get profileKycStatusRequired => 'ያስፈልጋል';

  @override
  String get searchFilters => 'ማጣሪያዎች';

  @override
  String get searchPropertyType => 'የንብረት አይነት';

  @override
  String get searchListingStatus => 'የሽያጭ/ኪራይ ሁኔታ';

  @override
  String get searchPriceRange => 'የዋጋ ክልል';

  @override
  String get searchSortBy => 'ደረጃ አሰጣጥ';

  @override
  String get searchApplyFilters => 'ማጣሪያዎችን ተግብር';

  @override
  String get searchReset => 'አድስ';

  @override
  String get searchPlaceholder => 'በአካባቢ ይፈልጉ...';

  @override
  String get searchClearAll => 'ሁሉንም አጥፋ';

  @override
  String get searchFindProperty => 'የሚፈልጉትን ንብረት ያግኙ';

  @override
  String get searchWelcomeSubtitle => 'ንብረቶችን በአካባቢ፣ በአይነት እና በሁኔታ ይፈልጉ';

  @override
  String get searchPopular => 'ተወዳጅ ፍለጋዎች';

  @override
  String get searchUnder5M => '💰 ከ5 ሚሊዮን በታች';

  @override
  String get search5M10M => '💎 ከ5-10 ሚሊዮን';

  @override
  String get search10M50M => '🏆 ከ10-50 ሚሊዮን';

  @override
  String get search50M100M => '👑 ከ50-100 ሚሊዮን';

  @override
  String get search100MPlus => '✨ ከ100 ሚሊዮን በላይ';

  @override
  String get searchNoResultsTitle => 'ምንም የተገኘ ንብረት የለም';

  @override
  String get searchNoResultsSubtitle => 'እባክዎ ፍለጋዎን ወይም ማጣሪያዎን ቀይረው ይሞክሩ';

  @override
  String searchFoundCount(Object count) {
    return '$count ንብረቶች ተገኝተዋል';
  }

  @override
  String get searchSortNewest => '🆕 አዲስ';

  @override
  String get searchSortOldest => '📅 የቆየ';

  @override
  String get searchSortPriceLow => '💰 ዝቅተኛ ዋጋ';

  @override
  String get searchSortPriceHigh => '💎 ከፍተኛ ዋጋ';

  @override
  String get searchFilterAll => 'ሁሉም';

  @override
  String get searchFilterAny => 'ማንኛውም';

  @override
  String get listingNext => 'ቀጣይ';

  @override
  String get listingSubmit => 'አስገባ';

  @override
  String get listingSubmitListing => 'ንብረት አስገባ';

  @override
  String get listingContinue => 'ቀጥል';

  @override
  String get listingBack => 'ተመለስ';

  @override
  String get listingStepBasics => 'መሰረታዊ';

  @override
  String get listingStepDetails => 'ዝርዝሮች';

  @override
  String get listingStepMedia => 'ሚዲያ';

  @override
  String get listingStepReview => 'ክለሳ';

  @override
  String get listingPropertyType => 'የንብረት አይነት';

  @override
  String get listingHoldingType => 'የባለቤትነት ሁኔታ';

  @override
  String get listingTaxPaid => 'ግብር የተከፈለበት';

  @override
  String get listingLeaseHolder => 'የሊዝ ባለቤት';

  @override
  String get listingLeaseOrganization => 'ድርጅት';

  @override
  String get listingLeaseExpiry => 'የሊዝ ማብቂያ';

  @override
  String get listingUseType => 'የአጠቃቀም ሁኔታ';

  @override
  String get listingLocation => 'ቦታ';

  @override
  String get listingPrice => 'ዋጋ';

  @override
  String get listingPriceEtb => 'ዋጋ (ብር)';

  @override
  String get listingHasDebt => 'ዕዳ ወይም እገዳ አለበት';

  @override
  String get listingDebtAmount => 'የዕዳ መጠን';

  @override
  String get listingSelectHolding => 'የባለቤትነት ሁኔታ ይምረጡ';

  @override
  String get listingSelectUse => 'የአጠቃቀም ሁኔታ ይምረጡ';

  @override
  String get listingRegion => 'ክልል';

  @override
  String get listingZone => 'ዞን';

  @override
  String get listingWoreda => 'ወረዳ';

  @override
  String get listingKebele => 'ቀበሌ';

  @override
  String get listingSpecificLocation => 'ልዩ ቦታ (አማራጭ)';

  @override
  String get listingTaxPaidYear => 'ግብር የተከፈለበት ዓመት';

  @override
  String get listingAcquisition => 'የተገኘበት መንገድ';

  @override
  String get listingLeasedYear => 'የሊዝ ዓመት';

  @override
  String get listingLeasePrice => 'የሊዝ ዋጋ በካሬ';

  @override
  String get listingBuildType => 'የግንባታ አይነት';

  @override
  String get listingAnnualPayment => 'ዓመታዊ ክፍያ';

  @override
  String get listingCooperativeName => 'የማህበሩ ስም';

  @override
  String get listingCooperativeCode => 'የማህበሩ ኮድ';

  @override
  String get listingBuildingStatus => 'የህንጻው ሁኔታ';

  @override
  String get listingRoomConfig => 'የክፍሎች አደረጃጀት';

  @override
  String get listingTotalRooms => 'ጠቅላላ ክፍሎች';

  @override
  String get listingPhotos => 'ፎቶዎች';

  @override
  String get listingBedrooms => 'መኝታ ቤቶች';

  @override
  String get listingBathrooms => 'መታጠቢያ ቤቶች';

  @override
  String get listingKitchens => 'ወጥ ቤቶች';

  @override
  String listingKitchensCount(Object count) {
    return '$count ወጥ ቤት(ዎች)';
  }

  @override
  String get listingSalons => 'ሳሎኖች';

  @override
  String get listingHouseType => 'የቤት አይነት';

  @override
  String get listingSelectHouseType => 'የቤት አይነት ይምረጡ';

  @override
  String get listingAmenities => 'መገልገያዎች';

  @override
  String get listingElectricity => 'መብራት';

  @override
  String get listingWater => 'ውሃ';

  @override
  String get listingParking => 'ፓርኪንግ';

  @override
  String get listingAreaDimensions => 'የቦታ ስፋት';

  @override
  String get listingTotalArea => 'ጠቅላላ ስፋት (ካሬ)';

  @override
  String get listingFrontArea => 'የፊት ስፋት (ካሬ)';

  @override
  String get listingSideArea => 'የጎን ስፋት (ካሬ)';

  @override
  String get listingFacingDirection => 'የሚመለከተው አቅጣጫ';

  @override
  String get listingSelectDirection => 'አቅጣጫ ይምረጡ';

  @override
  String get listingDescriptionLabel => 'መግለጫ';

  @override
  String get listingDescribeProperty => 'ስለ ንብረቱ ይግለጹ';

  @override
  String get listingImages => 'የንብረቱ ምስሎች (አስፈላጊ)';

  @override
  String get listingSitePlans => 'ሳይት ፕላን (አስፈላጊ)';

  @override
  String get listingOwnershipProof => 'የባለቤትነት ማረጋገጫ';

  @override
  String get listingLeaseContract => 'የሊዝ ውል';

  @override
  String get listingTapToAdd => 'ምስል ለመጨመር ይንኩ';

  @override
  String listingImagesSelected(Object count) {
    return '$count ምስሎች ተመርጠዋል';
  }

  @override
  String get listingBrowseFiles => 'ፋይሎችን ፈልግ';

  @override
  String get listingBrowseFile => 'ፋይል ፈልግ';

  @override
  String listingChangeFile(Object name) {
    return 'ቀይር: $name';
  }

  @override
  String get listingSummary => 'ማጠቃለያ';

  @override
  String get listingNew => 'አዲስ';

  @override
  String get listingAcceptTerms => 'በአገልግሎት ውሎች እና ደንቦች እስማማለሁ';

  @override
  String get listingTermsSubtitle =>
      'ንብረቱን በማስገባትዎ በውሎቻችን እና በግላዊነት ፖሊሲያችን ይስማማሉ';

  @override
  String get listingSuccess => 'ንብረቱ በተሳካ ሁኔታ ገብቷል! ይሁንታ በመጠባበቅ ላይ።';

  @override
  String listingError(Object error) {
    return 'ስህተት: $error';
  }

  @override
  String get listingNoOptions => 'ምንም አማራጮች የሉም';

  @override
  String get listingSelect => 'ይምረጡ';

  @override
  String get listingFreeHold => 'ነጻ ይዞታ';

  @override
  String get listingLeaseHold => 'ሊዝ';

  @override
  String get listingCooperative => 'ማህበር';

  @override
  String get listingResidential => 'ለመኖሪያ';

  @override
  String get listingCommercial => 'ለንግድ';

  @override
  String get listingMixed => 'ለተደባለቀ አገልግሎት';

  @override
  String get listingInvestment => 'ለኢንቨስትመንት';

  @override
  String get listingFinished => 'የተጠናቀቀ';

  @override
  String get listingUnfinished => 'ያልተጠናቀቀ';

  @override
  String get listingNorth => 'ሰሜን';

  @override
  String get listingSouth => 'ደቡብ';

  @override
  String get listingEast => 'ምስራቅ';

  @override
  String get listingWest => 'ምዕራብ';

  @override
  String get listingNorthEast => 'ሰሜን ምስራቅ';

  @override
  String get listingNorthWest => 'ሰሜን ምዕራብ';

  @override
  String get listingSouthEast => 'ደቡብ ምስራቅ';

  @override
  String get listingSouthWest => 'ደቡብ ምዕራብ';

  @override
  String get listingVilla => 'ቪላ';

  @override
  String get listingApartment => 'አፓርታማ';

  @override
  String get listingCondominium => 'ኮንዶሚኒየም';

  @override
  String get listingTownhouse => 'ታውን ሃውስ';

  @override
  String get listingBungalow => 'ባንጋሎው';

  @override
  String get listingPurchased => 'የተገዛ';

  @override
  String get listingInherited => 'የወረሰ';

  @override
  String get listingGift => 'በስጦታ';

  @override
  String get listingAssignment => 'በውክልና';

  @override
  String get listingOther => 'ሌላ';

  @override
  String get listingFreeHoldDetails => 'የነጻ ይዞታ ዝርዝሮች';

  @override
  String get listingLeaseHoldDetails => 'የሊዝ ዝርዝሮች';

  @override
  String get listingCooperativeDetails => 'የማህበር ዝርዝሮች';

  @override
  String get listingFinancial => 'ፋይናንሻል';

  @override
  String get listingSummaryProperty => 'ንብረት';

  @override
  String get listingFeatured => 'ተለይቷል';

  @override
  String get listingHouse => 'ቤት';

  @override
  String get listingLand => 'መሬት';

  @override
  String get listingHouses => '🏠 ቤቶች';

  @override
  String get listingLands => '🌄 መሬቶች';

  @override
  String get listingPriceOnRequest => 'ዋጋ በጠያቂ';

  @override
  String get listingUnknownLocation => 'ያልታወቀ ቦታ';

  @override
  String get listingToday => 'ዛሬ';

  @override
  String get listingYesterday => 'ትናንት';

  @override
  String listingDaysAgo(Object count) {
    return 'ከ $count ቀን በፊት';
  }

  @override
  String listingWeeksAgo(Object count) {
    return 'ከ $count ሳምንት በፊት';
  }

  @override
  String listingMonthsAgo(Object count) {
    return 'ከ $count ወር በፊት';
  }

  @override
  String get listingSale => '💰 ሽያጭ';

  @override
  String get listingRent => '🔑 ኪራይ';

  @override
  String get listingForSale => '💰 ለሽያጭ';

  @override
  String get listingForRent => '🔑 ለኪራይ';

  @override
  String listingUnitM2(Object count) {
    return '$count ካሬ';
  }

  @override
  String get listingsTitle => 'ንብረቶች';

  @override
  String get listingsCreate => 'አዲስ';

  @override
  String get listingsFeatured => 'ተለይተው የወጡ';

  @override
  String get listingsNoResults => 'ምንም ንብረቶች አልተገኙም';

  @override
  String get listingsDetails => 'የንብረት ዝርዝር';

  @override
  String get listingsKeyFeatures => 'ዋና መገለጫዎች';

  @override
  String get listingsImInterested => 'ፍላጎት አለኝ';

  @override
  String get listingsInterestedHint => 'ባለቤቱን በዚህ ንብረት ፍላጎት እንዳለዎት ያሳውቁ';

  @override
  String get listingsInterestedPlaceholder => 'ለባለቤቱ መልዕክት (አማራጭ)';

  @override
  String get listingsSubmitInterest => 'ፍላጎት ላክ';

  @override
  String get listingsInterestSubmitted => 'ፍላጎትዎ በተሳካ ሁኔታ ተልኳል!';

  @override
  String get listingsInterestAccepted => 'ፍላጎት ተቀባይነት';

  @override
  String get listingsInterestPending => 'በመጠበቅ ላይ';

  @override
  String get listingsInterestRejected => 'ፍላጎት ተኪይኑ ነው';

  @override
  String get listingsInterestCancelled => 'ፍላጎቱ ተሰርዟል';

  @override
  String get listingsDescription => 'መግለጫ';

  @override
  String get listingsPropertyDetails => 'የንብረት ዝርዝር';

  @override
  String listingsBedrooms(Object count) {
    return '$count መኝታ ቤቶች';
  }

  @override
  String listingsBathrooms(Object count) {
    return '$count መታጠቢያ ቤቶች';
  }

  @override
  String listingsSalons(Object count) {
    return '$count ሳሎኖች';
  }

  @override
  String get listingsFrontArea => 'የፊት ስፋት';

  @override
  String get listingsSideArea => 'የጎን ስፋት';

  @override
  String get listingsUseType => 'የአጠቃቀም ሁኔታ';

  @override
  String get listingsHoldingType => 'የባለቤትነት ሁኔታ';

  @override
  String get listingsFacing => 'አቅጣጫ';

  @override
  String get listingsNegotiable => 'ድርድር ይቻላል';

  @override
  String get listingsEncumbrance => 'ዕዳ/እገዳ';

  @override
  String listingsEncumbranceYes(Object amount) {
    return 'አዎ ($amount ብር)';
  }

  @override
  String get listingsVideoTour => 'የቪዲዮ ጉብኝት';

  @override
  String get listingsNoDescription => 'ምንም መግለጫ አልተሰጠም';

  @override
  String get listingsNoFeatures => 'ምንም ዋና መገለጫዎች አልተጠቀሱም';

  @override
  String get listingsNotFound => 'ንብረቱ አልተገኘም';

  @override
  String get listingsNotFoundSubtitle => 'ይህ ንብረት ተሰርዞ ሊሆን ይችላል';

  @override
  String get listingsLoadError => 'ንብረቱን መጫን አልተቻለም';

  @override
  String listingsTitleTemplate(Object action, Object location, Object type) {
    return '$type $action በ$location';
  }

  @override
  String listingsPriceFixed(Object price) {
    return '$price ብር';
  }

  @override
  String listingsPriceRange(Object max, Object min) {
    return '$min - $max ብር';
  }

  @override
  String get listingsYes => 'አዎ';

  @override
  String get listingsNo => 'የለም';

  @override
  String get favoritesTitle => 'ተወዳጆች';

  @override
  String get favoritesEmpty => 'ምንም ተወዳጅ የለም';

  @override
  String get favoritesEmptySubtitle => 'የመረጧቸውን ንብረቶች እዚህ ያገኟቸዋል';

  @override
  String get favoritesRemove => 'ከተወዳጆች አጥፋ';

  @override
  String get favoritesAdded => 'ወደ ተወዳጆች ታክሏል';

  @override
  String get favoritesRemoved => 'ከተወዳጆች ጠፍቷል';

  @override
  String get messagesTitle => 'መልእክቶች';

  @override
  String get messagesEmpty => 'ምንም መልእክት የለም';

  @override
  String get messagesTypeMessage => 'መልእክት ይጻፉ...';

  @override
  String get messagesSend => 'ላክ';

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String get settingsSectionAccount => 'የመለያ መረጃ';

  @override
  String get settingsSectionSupport => 'ድጋፍ';

  @override
  String get settingsSectionAuth => 'መለያ';

  @override
  String get settingsMyListingsSubtitle => 'ንብረቶችዎን ያስተዳድሩ';

  @override
  String get settingsSubscriptionsSubtitle => 'ዕቅዶችዎን ይመልከቱ';

  @override
  String get settingsPaymentsSubtitle => 'የክፍያ ታሪክ';

  @override
  String get settingsKycVerified => 'ተረጋግጧል';

  @override
  String get settingsKycPending => 'በመጠባበቅ ላይ';

  @override
  String get settingsKycRequired => 'ያስፈልጋል';

  @override
  String get settingsHelpSubtitle => 'ጥያቄዎች እና መመሪያዎች';

  @override
  String get settingsContactSupport => 'ድጋፍ ሰጪን ያግኙ';

  @override
  String get settingsContactSupportSubtitle => 'እኛን ያግኙን';

  @override
  String get settingsPrivacyPolicy => 'የግላዊነት ፖሊሲ';

  @override
  String get settingsTermsOfService => 'የአገልግሎት ውሎች';

  @override
  String settingsWebOpenError(Object title) {
    return '$title መክፈት አልተቻለም';
  }

  @override
  String get settingsPreferences => 'ምርጫዎች';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsLanguageSubtitle => 'የመተግበሪያ ቋንቋ ቀይር';

  @override
  String get settingsTheme => 'አቀባበል';

  @override
  String get settingsThemeSubtitle => 'የመተግበሪያ አቀባበል ይምረጡ';

  @override
  String get settingsNotifications => 'ማስታወቂያዎች';

  @override
  String get settingsNotificationsSubtitle => 'ማስታወቂያዎችን ያስተዳድሩ';

  @override
  String get settingsPrivacy => 'ግላዊነት';

  @override
  String get settingsPrivacySubtitle => 'የግላዊነት ቅንብሮች';

  @override
  String get settingsAbout => 'ስለ ዌቭማርት';

  @override
  String get settingsAboutSubtitle => 'ስለ መተግበሪያው መረጃ';

  @override
  String get settingsLogout => 'ውጣ';

  @override
  String get settingsLogoutSubtitle => 'ከመለያዎ ለመውጣት';

  @override
  String get languageTitle => 'ቋንቋ ይምረጡ';

  @override
  String get languageEnglish => 'English (እንግሊዝኛ)';

  @override
  String get languageAmharic => 'አማርኛ';

  @override
  String get languageTigrinya => 'ትግርኛ';

  @override
  String get languageChanged => 'ቋንቋ በተሳካ ሁኔታ ተቀይሯል';

  @override
  String get authPhoneNumber => 'ስልክ ቁጥር';

  @override
  String get authEnterPhone => 'ስልክ ቁጥርዎን ያስገቡ';

  @override
  String get authSendOtp => 'ኮድ ላክ';

  @override
  String get authVerifyOtp => 'ኮድ አረጋግጥ';

  @override
  String get authEnterOtp => 'ባለ 6 አሃዝ ኮድ ያስገቡ';

  @override
  String get authResendOtp => 'ኮድ ድጋሚ ላክ';

  @override
  String get authLogin => 'ግባ';

  @override
  String get authRegister => 'ይመዝገቡ';

  @override
  String get authLogout => 'ውጣ';

  @override
  String get authLogoutConfirm => 'እርግጠኛ ነዎት መውጣት ይፈልጋሉ?';

  @override
  String get subscriptionsTitle => 'የአባልነት ዕቅዶች';

  @override
  String get subscriptionsSubtitle => 'ለእርስዎ የሚስማማውን ዕቅድ ይምረጡ';

  @override
  String get subscriptionsCurrentPlan => 'የአሁኑ ዕቅድ';

  @override
  String get subscriptionsFree => 'ነጻ';

  @override
  String get subscriptionsBasic => 'መሰረታዊ';

  @override
  String get subscriptionsPremium => 'ፕሪሚየም';

  @override
  String get subscriptionsSubscribe => 'አሁን ይመዝገቡ';

  @override
  String get subscriptionsSelectPlan => 'ዕቅድ ይምረጡ';
}
