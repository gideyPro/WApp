// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tigrinya (`ti`).
class AppLocalizationsTi extends AppLocalizations {
  AppLocalizationsTi([String locale = 'ti']) : super(locale);

  @override
  String get appTitle => 'ዌቭማርት';

  @override
  String get commonUser => 'ተጠቃሚ';

  @override
  String get commonNA => 'የለን';

  @override
  String get commonAppInitials => 'ዌማ';

  @override
  String get commonUnknown => 'ዘይፍለጥ';

  @override
  String get commonYou => 'ንስኹም';

  @override
  String get commonNow => 'ሕጂ';

  @override
  String get commonOk => 'እሺ';

  @override
  String get commonCancel => 'ይሰረዝ';

  @override
  String get commonSave => 'ዓቅብ';

  @override
  String get commonDelete => 'ሰርዝ';

  @override
  String get commonEdit => 'ኣዐሪ';

  @override
  String get commonRetry => 'ደጊምካ ፈትን';

  @override
  String get commonLoading => 'ይፅዕን ኣሎ...';

  @override
  String get commonError => 'ጌጋ';

  @override
  String get commonSuccess => 'ተሳኪዑ';

  @override
  String get commonNoData => 'ዝተረኽበ መረዳእታ የለን';

  @override
  String get commonRetryMessage => 'በጃኹም ደጊምኩም ፈትኑ';

  @override
  String get commonComingSoon => 'ብቀረባ እዋን ክመጽእ እዩ';

  @override
  String get navHome => 'መበገሲ';

  @override
  String get navListings => 'ንብረታት';

  @override
  String get navSearch => 'ደለይ';

  @override
  String get navFavorites => 'ዝተመርፁ';

  @override
  String get navProfile => 'መገለጺ';

  @override
  String get navMessages => 'መልእኽታት';

  @override
  String get navSettings => 'ቅጥዒታት';

  @override
  String homeGreeting(Object name) {
    return 'ሰላም፣ $name';
  }

  @override
  String get homeDiscover => 'ዝበለጸ ንብረትኩም ኣብዚ ረኸቡ';

  @override
  String get homeFeaturedPremium => 'ፍሉያት ንብረታት';

  @override
  String get homeLatestRecently => 'ብቀረባ ዝወጹ';

  @override
  String get homeViewAll => 'ኹሉ ተዓዘብ';

  @override
  String get profileTitle => 'መገለጺ';

  @override
  String get profileEdit => 'መገለጺ ኣዐሪ';

  @override
  String get profileEditSubtitle => 'ሓበሬታኹም ኣሐድሱ';

  @override
  String get profileMyListings => 'ናተይ ንብረታት';

  @override
  String get myListingsEmptySubtitle => 'ንምጅማር ናይ መጀመሪያ ንብረትኩም ወስኹ';

  @override
  String get profileFavorites => 'ዝተመርፁ';

  @override
  String get profileMessages => 'መልእኽታት';

  @override
  String get profilePayments => 'ታሪኽ ክፍሊት';

  @override
  String get profileKyc => 'መረጋገጺ መንነት (KYC)';

  @override
  String get profileSubscriptions => 'ናይ ኣባልነት ትልምታት';

  @override
  String get profileHelp => 'መእከሊ ሓገዝ';

  @override
  String get profileNotLoggedIn => 'ኣይኣተኹምን';

  @override
  String get profileLoginPrompt => 'በጃኹም መገለጺኹም ንምርኣይ እተዉ';

  @override
  String get profileVerificationPhone => 'ተሌፎን';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'ንብረታት';

  @override
  String get profileStatsMessages => 'መልእኽታት';

  @override
  String get profileStatsFavorites => 'ዝተፈትው';

  @override
  String get kycTitle => 'መረጋገጺ መንነት (KYC)';

  @override
  String get kycVerifiedTitle => 'መንነት ተረጋጊጹ';

  @override
  String get kycVerifiedSubtitle =>
      'መንነትኩም ተረጋጊጹ ኣሎ። ሕጂ ንብረታት ክትምዝግቡን ኩሉ ኣገልግሎት ክትረኽቡን ትኽእሉ ኢኹም።';

  @override
  String get kycCreateListing => 'ንብረት መዝግብ';

  @override
  String get kycPendingTitle => 'ምርግጋጽ ይጽበ ኣሎ';

  @override
  String get kycPendingSubtitle =>
      'ሰነዳትኩም ይግምገም ኣሎ። እዚ መብዛሕትኡ ግዜ ካብ 24-48 ሰዓታት ይወስድ።';

  @override
  String kycSubmittedAt(Object date) {
    return 'ዝተልኣኸሉ ዕለት: $date';
  }

  @override
  String get kycRefreshStatus => 'ኵነታት ኣድስ';

  @override
  String get kycRejectedTitle => 'ምርግጋጽ ተነጺጉ';

  @override
  String kycRejectedReason(Object reason) {
    return 'ምክንያት: $reason';
  }

  @override
  String get kycRejectedSubtitle => 'በጃኹም ንጹርን ክንበብ ዝኽእልን ሰነዳት ደጊምኩም ስደዱ።';

  @override
  String get kycResubmit => 'ሰነዳት ደጊምካ ስደድ';

  @override
  String get kycInfoBanner => 'መንነትኩም ንምርግጋጽ በጃኹም ንጹር ፎቶ ናይ መንነት ወረቐትኩም ኣተሓሕዙ።';

  @override
  String get kycDocumentType => 'ዓይነት ሰነድ';

  @override
  String get kycNationalId => 'ሃገራዊ መለለዪ';

  @override
  String get kycPassport => 'ፓስፖርት';

  @override
  String get kycFrontOfDocument => 'ናይቲ ሰነድ ቅድሚት';

  @override
  String get kycFrontSubtitle => 'ናይ ቅድሚት ገጽ ንጹር ፎቶ';

  @override
  String get kycBackOfDocument => 'ናይቲ ሰነድ ድሕሪት';

  @override
  String get kycBackSubtitle => 'ናይ ድሕሪት ገጽ ንጹር ፎቶ';

  @override
  String get kycSelfieWithDocument => 'ምስቲ ሰነድ ዘለኩም ፎቶ';

  @override
  String get kycSelfieSubtitle => 'መለለዪኹም ኣብ ጥቓ ገጽኩም ሒዝኩም ተልዓሉ';

  @override
  String get kycSubmitForVerification => 'ንምርግጋጽ ስደድ';

  @override
  String get kycTapToChange => 'ንምቕያር ጠውቕ';

  @override
  String get kycSelectDocumentType => 'በጃኹም ዓይነት ሰነድ ምረጹ';

  @override
  String get kycUploadFront => 'በጃኹም ናይ ቅድሚት ገጽ ፎቶ ኣተሓሕዙ';

  @override
  String get kycSuccess => 'ምርግጋጽ ብትኽክል ተልኢኹ ኣሎ! ኣብ ገምጋም ይርከብ።';

  @override
  String kycError(Object error) {
    return 'ፎቶ ምልዓል ኣይተኻእለን: $error';
  }

  @override
  String get profileKycStatusVerified => 'ተረጋጊጹ';

  @override
  String get profileKycStatusPending => 'ኣብ መስርሕ';

  @override
  String get profileKycStatusRequired => 'የድሊ';

  @override
  String get searchFilters => 'መጻረዪታት';

  @override
  String get searchPropertyType => 'ዓይነት ንብረት';

  @override
  String get searchListingStatus => 'ኵነታት መሸጣ/ክራይ';

  @override
  String get searchPriceRange => 'ናይ ዋጋ ክልል';

  @override
  String get searchSortBy => 'ደረጃ ኣሰያይማ';

  @override
  String get searchApplyFilters => 'መጻረዪታት ተጠቐም';

  @override
  String get searchReset => 'ኣሐድስ';

  @override
  String get searchPlaceholder => 'ብቦታ ደለይ...';

  @override
  String get searchClearAll => 'ኹሉ ኣጥፍእ';

  @override
  String get searchFindProperty => 'ዝበለጸ ንብረትኩም ረኸቡ';

  @override
  String get searchWelcomeSubtitle => 'ንብረታት ብቦታ፣ ብዓይነትን ብኵነታትን ደለዩ';

  @override
  String get searchPopular => 'ተፈተውቲ ዳህሳሳት';

  @override
  String get searchUnder5M => '💰 ትሕቲ 5 ሚልዮን';

  @override
  String get search5M10M => '💎 5-10 ሚልዮን';

  @override
  String get search10M50M => '🏆 10-50 ሚልዮን';

  @override
  String get search50M100M => '👑 50-100 ሚልዮን';

  @override
  String get search100MPlus => '✨ ልዕሊ 100 ሚልዮን';

  @override
  String get searchNoResultsTitle => 'ዝተረኽበ ንብረት የለን';

  @override
  String get searchNoResultsSubtitle => 'በጃኹም ዳህሳስኩም ወይ መጻረዪኹም ቀይርኩም ፈትኑ';

  @override
  String searchFoundCount(Object count) {
    return '$count ንብረታት ተረኺቦም';
  }

  @override
  String get searchSortNewest => '🆕 ሓድሽ';

  @override
  String get searchSortOldest => '📅 ዝጸንሐ';

  @override
  String get searchSortPriceLow => '💰 ትሑት ዋጋ';

  @override
  String get searchSortPriceHigh => '💎 ልዑል ዋጋ';

  @override
  String get searchFilterAll => 'ኹሉ';

  @override
  String get searchFilterAny => 'ዝኾነ';

  @override
  String get listingNext => 'ቀፃሊ';

  @override
  String get listingSubmit => 'ኣእቱ';

  @override
  String get listingSubmitListing => 'ንብረት ኣእቱ';

  @override
  String get listingContinue => 'ቀጽል';

  @override
  String get listingBack => 'ተመለስ';

  @override
  String get listingStepBasics => 'መሰረታዊ';

  @override
  String get listingStepDetails => 'ዝርዝራት';

  @override
  String get listingStepMedia => 'ሚዲያ';

  @override
  String get listingStepReview => 'ክለሳ';

  @override
  String get listingPropertyType => 'ዓይነት ንብረት';

  @override
  String get listingHoldingType => 'ዓይነት ዋናነት';

  @override
  String get listingTaxPaid => 'ታክስ ዝተኸፈለሉ';

  @override
  String get listingLeaseHolder => 'ባለ ዋና ሊዝ';

  @override
  String get listingLeaseOrganization => 'ድርጅን';

  @override
  String get listingLeaseExpiry => 'መወዳእታ ሊዝ';

  @override
  String get listingUseType => 'ዓይነት ኣገልግሎት';

  @override
  String get listingLocation => 'ቦታ';

  @override
  String get listingPrice => 'ዋጋ';

  @override
  String get listingPriceEtb => 'ዋጋ (ቅርሺ)';

  @override
  String get listingHasDebt => 'ዕዳ ወይ እገዳ ኣለዎ';

  @override
  String get listingDebtAmount => 'መጠንን ዕዳ';

  @override
  String get listingSelectHolding => 'ዓይነት ዋናነት ይምረጡ';

  @override
  String get listingSelectUse => 'ዓይነት ኣገልግሎት ይምረጡ';

  @override
  String get listingRegion => 'ክልል';

  @override
  String get listingZone => 'ዞን';

  @override
  String get listingWoreda => 'ወረዳ';

  @override
  String get listingKebele => 'ቀበሌ';

  @override
  String get listingSpecificLocation => 'ፍሉይ ቦታ (ኣማራጭ)';

  @override
  String get listingTaxPaidYear => 'ግብሪ ዝተኸፈለሉ ዓመት';

  @override
  String get listingAcquisition => 'ዝተረኸበሉ መንገዲ';

  @override
  String get listingLeasedYear => 'ናይ ሊዝ ዓመት';

  @override
  String get listingLeasePrice => 'ዋጋ ሊዝ ብሜትር ካሬ';

  @override
  String get listingBuildType => 'ዓይነት ህንጻ';

  @override
  String get listingAnnualPayment => 'ዓመታዊ ክፍሊት';

  @override
  String get listingCooperativeName => 'ሽም ማሕበር';

  @override
  String get listingCooperativeCode => 'ኮድ ማሕበር';

  @override
  String get listingBuildingStatus => 'ኩነታት ህንጻ';

  @override
  String get listingRoomConfig => 'ኣቀማምጣ ክፍልታት';

  @override
  String get listingTotalRooms => 'ጠቅላላ ክፍልታት';

  @override
  String get listingPhotos => 'ፎቶታት';

  @override
  String get listingBedrooms => 'መኝታ ክፍልታት';

  @override
  String get listingBathrooms => 'ሽቓቓት';

  @override
  String get listingKitchens => 'ክሽነታት';

  @override
  String listingKitchensCount(Object count) {
    return '$count ክሽነ(ታት)';
  }

  @override
  String get listingSalons => 'ሳሎናት';

  @override
  String get listingHouseType => 'ዓይነት ገዛ';

  @override
  String get listingSelectHouseType => 'ዓይነት ገዛ ይምረጡ';

  @override
  String get listingAmenities => 'መገልገያታት';

  @override
  String get listingElectricity => 'መብራት';

  @override
  String get listingWater => 'ማይ';

  @override
  String get listingParking => 'ፓርኪንግ';

  @override
  String get listingAreaDimensions => 'ስፍሓት ቦታ';

  @override
  String get listingTotalArea => 'ጠቅላላ ስፍሓት (ሜትር ካሬ)';

  @override
  String get listingFrontArea => 'ናይ ቅድሚት ስፍሓት (ሜትር ካሬ)';

  @override
  String get listingSideArea => 'ናይ ጎኒ ስፍሓት (ሜትር ካሬ)';

  @override
  String get listingFacingDirection => 'ዝጥምቶ ኣንፈት';

  @override
  String get listingSelectDirection => 'ኣንፈት ይምረጡ';

  @override
  String get listingDescriptionLabel => 'መግለጺ';

  @override
  String get listingDescribeProperty => 'ብዛዕባ ንብረትኩም ግለጹ';

  @override
  String get listingImages => 'ስእልታት ንብረት (የድሊ)';

  @override
  String get listingSitePlans => 'ሳይት ፕላን (የድሊ)';

  @override
  String get listingOwnershipProof => 'መረጋገጺ ዋናነት';

  @override
  String get listingLeaseContract => 'ውዕል ሊዝ';

  @override
  String get listingTapToAdd => 'ስእሊ ንምውሳኽ ንከው';

  @override
  String listingImagesSelected(Object count) {
    return '$count ስእልታት ተመሪጾም';
  }

  @override
  String get listingBrowseFiles => 'ፋይላት ድለ';

  @override
  String get listingBrowseFile => 'ፋይል ድለ';

  @override
  String listingChangeFile(Object name) {
    return 'ቀይር: $name';
  }

  @override
  String get listingSummary => 'ጽማረ';

  @override
  String get listingNew => 'ሓድሽ';

  @override
  String get listingAcceptTerms => 'ብውዕላትን ደንብታትን እሰማማዕ';

  @override
  String get listingTermsSubtitle =>
      'ንብረትኩም ብምእታውኩም ብውዕልናን ፖሊሲ ምስጢራውነትናን ትሰማምዑ ኣለኹም';

  @override
  String get listingSuccess => 'ንብረትኩም ብዝግባእ ተመዝጊቡ ኣሎ! ይጽበ ኣሎ።';

  @override
  String listingError(Object error) {
    return 'ጌጋ: $error';
  }

  @override
  String get listingNoOptions => 'ዝኾነ ኣማራጺ የለን';

  @override
  String get listingSelect => 'ይምረጡ';

  @override
  String get listingFreeHold => 'ናጻ ይዞታ';

  @override
  String get listingLeaseHold => 'ሊዝ';

  @override
  String get listingCooperative => 'ማሕበር';

  @override
  String get listingResidential => 'ንመበገሲ';

  @override
  String get listingCommercial => 'ንንግዲ';

  @override
  String get listingMixed => 'ንድሁብ ኣገልግሎት';

  @override
  String get listingInvestment => 'ንኢንቨስትመንት';

  @override
  String get listingFinished => 'ዝተወድአ';

  @override
  String get listingUnfinished => 'ዘይተወድአ';

  @override
  String get listingNorth => 'ሰሜን';

  @override
  String get listingSouth => 'ደቡብ';

  @override
  String get listingEast => 'ምብራቕ';

  @override
  String get listingWest => 'ምዕራብ';

  @override
  String get listingNorthEast => 'ሰሜን ምብራቕ';

  @override
  String get listingNorthWest => 'ሰሜን ምዕራብ';

  @override
  String get listingSouthEast => 'ደቡብ ምብራቕ';

  @override
  String get listingSouthWest => 'ደቡብ ምዕራብ';

  @override
  String get listingVilla => 'ቪላ';

  @override
  String get listingApartment => 'ኣፓርታማ';

  @override
  String get listingCondominium => 'ኮንዶሚኒየም';

  @override
  String get listingTownhouse => 'ታውን ሃውስ';

  @override
  String get listingBungalow => 'ባንጋሎው';

  @override
  String get listingPurchased => 'ዝተዓደገ';

  @override
  String get listingInherited => 'ዝወረሰ';

  @override
  String get listingGift => 'ብውህብቶ';

  @override
  String get listingAssignment => 'ብውክልና';

  @override
  String get listingOther => 'ካልእ';

  @override
  String get listingFreeHoldDetails => 'ዝርዝር ናጻ ይዞታ';

  @override
  String get listingLeaseHoldDetails => 'ዝርዝር ሊዝ';

  @override
  String get listingCooperativeDetails => 'ዝርዝር ማሕበር';

  @override
  String get listingFinancial => 'ፋይናንሻል';

  @override
  String get listingSummaryProperty => 'ንብረት';

  @override
  String get listingFeatured => 'ፍሉይ';

  @override
  String get listingHouse => 'ገዛ';

  @override
  String get listingLand => 'መሬት';

  @override
  String get listingHouses => '🏠 ገዛውቲ';

  @override
  String get listingLands => '🌄 መሬታት';

  @override
  String get listingPriceOnRequest => 'ዋጋ ብሕቶ';

  @override
  String get listingUnknownLocation => 'ዘይፍለጥ ቦታ';

  @override
  String get listingToday => 'ሎሚ';

  @override
  String get listingYesterday => 'ትማሊ';

  @override
  String listingDaysAgo(Object count) {
    return 'ቅድሚ $count መዓልቲ';
  }

  @override
  String listingWeeksAgo(Object count) {
    return 'ቅድሚ $count ሰሙን';
  }

  @override
  String listingMonthsAgo(Object count) {
    return 'ቅድሚ $count ወርሒ';
  }

  @override
  String get listingSale => '💰 መሸጣ';

  @override
  String get listingRent => '🔑 ክራይ';

  @override
  String get listingForSale => '💰 ንመሸጣ';

  @override
  String get listingForRent => '🔑 ንክራይ';

  @override
  String listingUnitM2(Object count) {
    return '$count ሜትር ካሬ';
  }

  @override
  String get listingsTitle => 'ንብረታት';

  @override
  String get listingsCreate => 'ኣእቱ';

  @override
  String get listingsFeatured => 'ፍሉያት ንብረታት';

  @override
  String get listingsNoResults => 'ዝተረኽበ ንብረት የለን';

  @override
  String get listingsDetails => 'ዝርዝር ንብረት';

  @override
  String get listingsKeyFeatures => 'ቀንዲ መገለጺታት';

  @override
  String get listingsImInterested => 'ድሌት ኣለኒ';

  @override
  String get listingsInterestedHint => 'ድሌት ከምዘለኩም ንባዓል ንብረት ኣፍልጡ';

  @override
  String get listingsInterestedPlaceholder => 'ንባዓል ንብረት ዝኸውን መልእኽቲ (ኣማራጭ)';

  @override
  String get listingsSubmitInterest => 'ድሌት ስደድ';

  @override
  String get listingsInterestSubmitted => 'ድሌትኩም ብዝግባእ ተላኢኹ ኣሎ!';

  @override
  String get listingsInterestAccepted => 'ድሌት ተቐባልነት ረኺቡ';

  @override
  String get listingsInterestPending => 'ኣብ መስርሕ';

  @override
  String get listingsInterestRejected => 'ድሌት ተነጺጉ';

  @override
  String get listingsInterestCancelled => 'ድሌት ተሰሪዙ';

  @override
  String get callIncoming => 'ዝመጽእ ዘሎ ጥሪ...';

  @override
  String get callAccept => 'ተቐበል';

  @override
  String get callDecline => 'ኣይትቀበል';

  @override
  String get jitsiCallTitle => 'ናይ ድምጺ ጥሪ';

  @override
  String get jitsiOpening => 'ናይ ጂትሲ ስብሰባ ይኽፈት ኣሎ...';

  @override
  String get jitsiOpenedExternal => 'እቲ ስብሰባ እንተዘይተኸፊቱ ደጊምኩም ንምፍታን ኣብ ታሕቲ ጠውቑ';

  @override
  String get jitsiCloseToJoin => 'ኣብቲ መተግበሪ ንምጽንባር ነዚ ዕጸዉ';

  @override
  String get listingsDescription => 'መግለጺ';

  @override
  String get listingsPropertyDetails => 'ዝርዝር ንብረት';

  @override
  String listingsBedrooms(Object count) {
    return '$count መኝታ ክፍል';
  }

  @override
  String listingsBathrooms(Object count) {
    return '$count ሽቓቓት';
  }

  @override
  String listingsSalons(Object count) {
    return '$count ሳሎን';
  }

  @override
  String get listingsFrontArea => 'ናይ ቅድሚት ስፍሓት';

  @override
  String get listingsSideArea => 'ናይ ጎኒ ስፍሓት';

  @override
  String get listingsUseType => 'ዓይነት ኣገልግሎት';

  @override
  String get listingsHoldingType => 'ዓይነት ዋናነት';

  @override
  String get listingsFacing => 'ኣንፈት';

  @override
  String get listingsNegotiable => 'ብድርድር';

  @override
  String get listingsEncumbrance => 'ዕዳ/እገዳ';

  @override
  String listingsEncumbranceYes(Object amount) {
    return 'እወ ($amount ቅርሺ)';
  }

  @override
  String get listingsVideoTour => 'ናይ ቪዲዮ ዑደት';

  @override
  String get listingsNoDescription => 'መግለጺ ኣይተዋህበን';

  @override
  String get listingsNoFeatures => 'ቀንዲ መገለጺታት ኣይተጠቐሱን';

  @override
  String get listingsNotFound => 'ንብረቱ ኣይተረኽበን';

  @override
  String get listingsNotFoundSubtitle => 'እዚ ንብረት ተሰሪዙ ክኸውን ይኽእል እዩ';

  @override
  String get listingsLoadError => 'ንብረቱ ክጽዕን ኣይከኣለን';

  @override
  String listingsTitleTemplate(Object action, Object location, Object type) {
    return '$type $action ኣብ $location';
  }

  @override
  String listingsPriceFixed(Object price) {
    return '$price ቅርሺ';
  }

  @override
  String listingsPriceRange(Object max, Object min) {
    return '$min - $max ቅርሺ';
  }

  @override
  String get listingsYes => 'እወ';

  @override
  String get listingsNo => 'የለን';

  @override
  String get favoritesTitle => 'ዝተመርፁ';

  @override
  String get favoritesEmpty => 'ዝተመርጸ ንብረት የለን';

  @override
  String get favoritesEmptySubtitle => 'ዝመረጽኩምዎም ንብረታት ኣብዚ ክትረኽብዎም ኢኹም';

  @override
  String get favoritesRemove => 'ካብ ዝተመርፁ ኣውጽእ';

  @override
  String get favoritesAdded => 'ናብ ዝተመርፁ ተወሲኹ';

  @override
  String get favoritesRemoved => 'ካብ ዝተመርፁ ወጺኡ';

  @override
  String get messagesTitle => 'መልእኽታት';

  @override
  String get messagesEmpty => 'መልእኽቲ የለን';

  @override
  String get messagesTypeMessage => 'መልእኽቲ ጽሓፉ...';

  @override
  String get messagesSend => 'ስደድ';

  @override
  String get settingsTitle => 'ቅጥዒታት';

  @override
  String get settingsSectionAccount => 'ናይ መለያ ሓበሬታ';

  @override
  String get settingsSectionSupport => 'ሓገዝ';

  @override
  String get settingsSectionAuth => 'መለያ';

  @override
  String get settingsMyListingsSubtitle => 'ንብረትኩም ኣመሓድሩ';

  @override
  String get settingsSubscriptionsSubtitle => 'ትልምታትኩም ርኣዩ';

  @override
  String get settingsPaymentsSubtitle => 'ታሪኽ ክፍሊት';

  @override
  String get settingsKycVerified => 'ተረጋጊጹ';

  @override
  String get settingsKycPending => 'ኣብ መስርሕ';

  @override
  String get settingsKycRequired => 'የድሊ';

  @override
  String get settingsHelpSubtitle => 'ሕቶታትን መምርሒታትን';

  @override
  String get settingsContactSupport => 'ሓገዝ ረኸቡ';

  @override
  String get settingsContactSupportSubtitle => 'ተወከሱና';

  @override
  String get settingsPrivacyPolicy => 'ፖሊሲ ምስጢራውነት';

  @override
  String get settingsTermsOfService => 'ውዕል ኣገልግሎት';

  @override
  String settingsWebOpenError(Object title) {
    return '$title ክኽፈት ኣይከኣለን';
  }

  @override
  String get settingsPreferences => 'ምርጫታት';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsLanguageSubtitle => 'ናይ መተግበሪ ቋቋ ቀይሩ';

  @override
  String get settingsTheme => 'መልክዕ';

  @override
  String get settingsThemeSubtitle => 'ናይ መተግበሪ መልክዕ ይምረጡ';

  @override
  String get settingsNotifications => 'መጠንቀቕታታት';

  @override
  String get settingsNotificationsSubtitle => 'መጠንቀቕታታት ኣመሓድሩ';

  @override
  String get settingsPrivacy => 'ምስጢራውነት';

  @override
  String get settingsPrivacySubtitle => 'ቅጥዒታት ምስጢራውነት';

  @override
  String get settingsAbout => 'ብዛዕባ ዌቭማርት';

  @override
  String get settingsAboutSubtitle => 'ሓበሬታ ብዛዕባ መተግበሪ';

  @override
  String get settingsLogout => 'ውጻእ';

  @override
  String get settingsLogoutSubtitle => 'ካብ መለያኹም ንምውጻእ';

  @override
  String get languageTitle => 'ቋንቋ ይምረጡ';

  @override
  String get languageEnglish => 'English (እንግሊዝኛ)';

  @override
  String get languageAmharic => 'አማርኛ (ኣምሓርኛ)';

  @override
  String get languageTigrinya => 'ትግርኛ';

  @override
  String get languageChanged => 'ቋንቋ ብዝግባእ ተቐይሩ';

  @override
  String get authPhoneNumber => 'ቁጽሪ ተሌፎን';

  @override
  String get authEnterPhone => 'ቁጽሪ ተሌፎንኩም ኣእትዉ';

  @override
  String get authSendOtp => 'ኮድ ስደድ';

  @override
  String get authVerifyOtp => 'ኮድ ኣረጋግጽ';

  @override
  String get authEnterOtp => 'ባለ 6 ኣሃዝ ኮድ ኣእትዉ';

  @override
  String get authResendOtp => 'ኮድ ደጊምካ ስደድ';

  @override
  String get authLogin => 'እቶ';

  @override
  String get authRegister => 'ተመዝገብ';

  @override
  String get authLogout => 'ውጻእ';

  @override
  String get authLogoutConfirm => 'ርግጸኛ ዲኹም ክትወጽኡ ትደልዩ?';

  @override
  String get subscriptionsTitle => 'ናይ ኣባልነት ትልምታት';

  @override
  String get subscriptionsSubtitle => 'ንዓኹም ዝበቅዕ ትልሚ ይምረጡ';

  @override
  String get subscriptionsCurrentPlan => 'ናይ ሕጂ ትልሚ';

  @override
  String get subscriptionsFree => 'ብናጻ';

  @override
  String get subscriptionsBasic => 'መሰረታዊ';

  @override
  String get subscriptionsPremium => 'ፕሪሚየም';

  @override
  String get subscriptionsSubscribe => 'ሕጂ ተመዝገብ';

  @override
  String get subscriptionsSelectPlan => 'ትልሚ ይምረጡ';

  @override
  String get settingsDarkMode => 'ጸሊም መልክዕ';

  @override
  String get commonOn => 'ተወሊዑ';

  @override
  String get commonOff => 'ተጠፊኡ';
}
