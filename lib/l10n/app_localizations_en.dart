// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonUser => 'User';

  @override
  String get commonNA => 'N/A';

  @override
  String get commonAppInitials => 'WM';

  @override
  String get commonYou => 'You';

  @override
  String get commonNow => 'Now';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonError => 'Error';

  @override
  String get commonNo => 'No';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRetryMessage => 'Please try again';

  @override
  String get commonPressBackAgain => 'Press back again to exit';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonSave => 'Save';

  @override
  String get navHome => 'Home';

  @override
  String get navOrders => 'Orders';

  @override
  String get navMessages => 'Messages';

  @override
  String get navSettings => 'My Account';

  @override
  String get homeLatestRecently => 'Recently added';

  @override
  String get homeVipTitle => 'Premium VIP Properties';

  @override
  String get homeViewAll => 'View All';

  @override
  String get vipTeaserCta => 'Unlock VIP Listings';

  @override
  String get vipNoListings => 'No VIP listings yet ';

  @override
  String get vipBadge => 'VIP';

  @override
  String get profileMyListings => 'My Listings';

  @override
  String get myListingsEmptySubtitle =>
      'Create your first listing to get started';

  @override
  String noStatusListings(Object status) {
    return 'No $status listings';
  }

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profilePayments => 'Payment History';

  @override
  String get profileKyc => 'KYC Verification';

  @override
  String get profileSubscriptions => 'Subscriptions';

  @override
  String get profileHelp => 'Help Center';

  @override
  String get helpSearchHint => 'Search for help...';

  @override
  String get helpNoResultsTitle => 'No Results Found';

  @override
  String get helpNoResultsSubtitle => 'Try different keywords...';

  @override
  String get helpStillNeedHelp => 'Still need help?';

  @override
  String get helpSupportTeam => 'Our support team is here to help you.';

  @override
  String get helpEmail => 'Email';

  @override
  String get helpCall => 'Call';

  @override
  String get helpErrorEmail => 'Could not open email app';

  @override
  String get helpErrorPhone => 'Could not open phone app';

  @override
  String get helpYoutubeSub => 'Watch tutorials, platform tips & video tours';

  @override
  String get helpYoutubeSubscribe => 'Subscribe';

  @override
  String get helpCategoryAccount => 'Account & Profile';

  @override
  String get helpCategoryListings => 'Listings';

  @override
  String get helpCategoryOrders => 'Custom Requests & Orders';

  @override
  String get helpCategoryPayments => 'Payments & Subscriptions';

  @override
  String get helpCategoryKyc => 'KYC Verification';

  @override
  String get helpCategorySafety => 'Safety & Policies';

  @override
  String get helpAccCreateTitle => 'How to create and set up your account';

  @override
  String get helpAccCreateContent =>
      'To get started on WaveMart:\n\n1. Open the app and tap \"Register\" or \"Sign In\"\n2. Enter your full name, phone number, and a secure password\n3. You will immediately receive a 6-digit SMS verification code (OTP)\n4. Enter the code to verify your phone number and activate your account\n\nOnce registered, you can browse real estate, vehicles, and jobs, save your favorites, unlock seller contact details, or start publishing your own listings.';

  @override
  String get helpAccFavTitle => 'Managing favorites and saved items';

  @override
  String get helpAccFavContent =>
      'Keep track of listings you are interested in:\n\n1. Tap the heart icon on any property, vehicle, or job card to save it\n2. Access all your saved items anytime from Account > Favorites\n3. Saved items update in real time if prices drop, a property or vehicle is sold or rented, or a job vacancy closes\n4. Tap the heart icon again to remove an item from your favorites\n\nSaving favorites allows you to compare options, monitor market trends, and quickly revisit items without searching again.';

  @override
  String get helpAccMsgTitle => 'In-app messaging and contact reveal';

  @override
  String get helpAccMsgContent =>
      'WaveMart provides direct channels to connect with sellers, agents, and recruiters:\n\n1. In-App Chat: Tap \"Chat\" on any listing to start an instant, secure conversation without sharing your personal number\n2. Delivery Indicators: Single check mark means sent; double check marks indicate delivered and read\n3. Direct Contact Reveal: Tap \"Reveal Contact\" or \"Call\" to view the verified phone number of the seller or employer (uses 1 view from your monthly subscription quota)\n4. Context Switching: Easily track which property, vehicle, or job each discussion refers to via the chat header\n\nFor your personal safety, always keep discussions, agreements, and payment negotiations within the WaveMart app.';

  @override
  String get helpListCreateTitle =>
      'How to post properties, vehicles, and jobs';

  @override
  String get helpListCreateContent =>
      'Publishing your listings on WaveMart is quick and guided:\n\n1. Tap the \"+\" button in the center of the bottom navigation bar\n2. Choose your category: Real Estate (House, Apartment, Commercial, Land for Sale or Rent), Vehicles (Car, Truck, Motorcycle, Machinery for Sale or Rent), or Job Opportunity\n3. Fill in the required specifications (price, area, mileage, transmission, fuel type, employment terms, qualifications, and exact location)\n4. Upload high-resolution photos and document scans (such as Site Plans for properties or vehicle inspection details)\n5. Review your information and tap \"Submit Listing\"\n\nAll listings are verified by our moderation team within 24 hours before going live to ensure quality and authenticity.';

  @override
  String get helpListManageTitle => 'Managing, editing, and renewing listings';

  @override
  String get helpListManageContent =>
      'You maintain complete control over all your published items:\n\n1. Go to Account > My Listings to view all your property, vehicle, and job posts\n2. Check listing statuses: Pending Approval, Active, Sold, Rented, Filled, or Rejected\n3. Tap any listing to open management controls: Edit details, adjust pricing, or mark as Sold or Closed\n4. Boost Visibility: Apply a Featured or VIP upgrade directly from the listing management screen\n5. Delete or Pause: Remove items that are no longer available or temporarily unpublish them\n\nPlease note: Major modifications (such as changing location or core title) will undergo a quick re-review by our moderation team.';

  @override
  String get helpListTipsTitle => 'Tips for creating high-converting listings';

  @override
  String get helpListTipsContent =>
      'Attract more serious buyers, renters, and top candidates by following these best practices:\n\n1. High-Quality Visuals: Upload at least 5 clear, well-lit photos showing all angles, interior, exterior, and surrounding area\n2. Transparent Pricing: List realistic, market-competitive prices. State clearly whether the price is fixed or negotiable\n3. Comprehensive Details: For real estate, specify area, water/electricity access, and nearby landmarks. For vehicles, state exact year, mileage, engine, transmission, and service history\n4. Clear Job Descriptions: Outline compensation, working hours, required experience, and key responsibilities\n5. Respond Fast: Maintain active engagement in the in-app chat. Fast response times build trust and close deals faster.';

  @override
  String get helpListVideoTitle => 'Video walkthroughs and virtual tours';

  @override
  String get helpListVideoContent =>
      'Video walkthroughs give buyers and renters a realistic preview before visiting in person:\n\n1. Uploading: When creating or editing a property or vehicle listing, attach a short video tour (up to 60 seconds)\n2. Cloud Processing: Our background video engine automatically compresses and optimizes your clip for smooth streaming across mobile connections\n3. Processing Status: While processing, the listing will show a video preparation badge; once complete, the playable video appears automatically\n4. Verified Video Badge: Listings featuring real video walkthroughs receive higher visibility and customer engagement\n\nViewing video tours is seamless and supported on standard mobile data connections.';

  @override
  String get helpListInterestTitle =>
      'Expressing interest and contacting sellers';

  @override
  String get helpListInterestContent =>
      'Connect seamlessly with verified sellers and recruiters:\n\n1. Browse to any property, vehicle, or job detail screen\n2. Direct Contact: Tap \"Reveal Contact\" to instantly view and dial the verified phone number. Each reveal uses one view from your active subscription quota\n3. In-App Chat: Tap \"Chat\" to send inquiries, ask questions, or negotiate terms directly within WaveMart\n4. Job Applications: For job postings, tap \"Apply\" or message the employer directly with your profile\n5. My Interests: View your saved inquiries, conversations, and interaction history anytime from Account > My Interests\n\nDirect contact reveals require an active subscription tier with remaining monthly contact views.';

  @override
  String get helpListStatusTitle =>
      'Understanding listing statuses and moderation';

  @override
  String get helpListStatusContent =>
      'Every listing on WaveMart moves through defined verification stages:\n\n- Pending Review: Your submission is being examined by our moderation team for authenticity and image quality (usually within 24 hours)\n- Active: Your listing is live, searchable, and receiving views from buyers across Ethiopia\n- Featured / VIP: Your listing is highlighted with high-priority placement on the homepage and search feeds\n- Sold / Rented / Filled: The property has closed, the vehicle is sold, or the job opening has been filled\n- Rejected: The listing did not meet guidelines (e.g., duplicate post, invalid price, unclear photos). Review the specific feedback, make edits, and resubmit\n- Frozen / Inactive: Temporarily hidden by the owner or administrator\n\nCheck the live status of all your items under Account > My Listings.';

  @override
  String get helpOrdCreateTitle =>
      'Custom requests for properties, vehicles, and talent';

  @override
  String get helpOrdCreateContent =>
      'Can\'t find the exact property, specific vehicle, or skilled professional you need? Create a Custom Request:\n\n1. Navigate to the Requests (Orders) section and tap \"Create Request\"\n2. Choose what you are looking for: Real Estate (buy or rent), Vehicles (make, model, year, budget), or Talent/Hiring requirements\n3. Specify your target budget, desired location, timeline, and exact requirements\n4. Submit your request for automated matching and facilitator assistance\n\nOur system and support team match your request against verified upcoming inventory and alert you the moment a suitable option becomes available.';

  @override
  String get helpOrdManageTitle => 'Managing request proposals and matches';

  @override
  String get helpOrdManageContent =>
      'When suitable properties, vehicles, or candidate profiles match your request:\n\n1. You will receive an instant notification with full details of the matched proposal\n2. Open your request in the Requests tab to review photos, pricing, and specifications\n3. Tap \"Accept\" to connect directly with the owner, dealer, or applicant\n4. If an offer does not meet your expectations, tap \"Decline\" to keep your request open for further proposals\n5. Close or update your request at any time once your goal has been achieved.';

  @override
  String get helpPayPlansTitle =>
      'Membership plans, listing limits, and contact quotas';

  @override
  String get helpPayPlansContent =>
      'WaveMart offers transparent subscription tiers designed for buyers, sellers, brokers, and recruiters:\n\n- Free / Starter: Browse properties, vehicles, and jobs; save favorites; message via in-app chat\n- Basic: Post listings across categories, view video walkthroughs, and receive monthly quotas to reveal seller and job contact details\n- Professional: Higher listing limits, featured visibility boosts, increased contact view quotas, and priority agent support\n- VIP / Enterprise: Unlimited or maximum contact reveals, exclusive access to unlisted VIP properties and luxury vehicles, VIP badge, and premier placement across the platform\n\nContact quotas reset each billing cycle. You can upgrade or renew your plan at any time from the Subscriptions screen.';

  @override
  String get helpPayMakeTitle =>
      'How to pay using Telebirr, CBEBirr, and Cards via Chapa';

  @override
  String get helpPayMakeContent =>
      'Upgrading your subscription or boosting listings is instant and secure through Chapa, Ethiopia\'s premier payment system:\n\n1. Go to Account > Subscriptions and choose your preferred plan\n2. Tap \"Subscribe Now\" or \"Upgrade Plan\"\n3. You will be redirected to the secure Chapa checkout interface\n4. Select your preferred payment method: Telebirr, CBEBirr, M-Pesa, Awash Birr, or any Ethiopian debit/credit card\n5. Follow the quick on-screen prompt to authorize payment on your mobile wallet or banking app\n6. Upon confirmation, your subscription benefits and contact quotas are activated immediately\n\nWaveMart does not charge hidden fees; the price you see is the exact amount charged.';

  @override
  String get helpPaySecurityTitle => 'Payment security and data protection';

  @override
  String get helpPaySecurityContent =>
      'Your financial security is our highest priority:\n\n1. Bank-Grade Encryption: All payments are processed through Chapa\'s PCI-DSS compliant, end-to-end encrypted infrastructure\n2. No Card Storage: WaveMart never stores, processes, or has access to your banking passwords, card PINs, or wallet credentials\n3. Instant Receipts: Every successful transaction generates a digital receipt with a unique transaction reference code visible in your account\n4. Transaction Assistance: If a payment completes on your wallet or banking app but is not reflected in your account, contact our support team with your transaction reference for immediate verification.';

  @override
  String get helpPayVipTitle => 'VIP badges and Featured listing boosts';

  @override
  String get helpPayVipContent =>
      'Maximize views and sell or hire faster with promotional boosts:\n\n- Featured Listing: Positions your property, vehicle, or job post in the high-traffic \"Featured Listings\" banner on the home screen and highlights it in search results for 30 days\n- VIP Listing: Adds an exclusive golden VIP badge, ranks your listing at the very top of buyer feeds, and alerts serious high-intent buyers\n- Unlisted VIP Deals: Subscribers on VIP plans gain access to premium properties and luxury vehicles not visible to standard users\n\nTo promote a listing: Go to Account > My Listings, open the active listing, select \"Boost / Feature\", choose your promotion type, and confirm.';

  @override
  String get helpKycWhyTitle => 'Why identity verification (KYC) is required';

  @override
  String get helpKycWhyContent =>
      'WaveMart complies with Ethiopian e-commerce safety regulations to protect every member of our community:\n\n1. Preventing Scams & Fraud: Verifying real identities ensures fake accounts, phantom listings, and identity theft cannot operate on WaveMart\n2. Verified Seller Badge: Successfully verified accounts earn a blue checkmark badge, boosting buyer confidence and increasing inquiries\n3. Unlocking Publishing Privileges: KYC verification is required before you can publish properties for sale or rent, list commercial vehicles, or recruit talent\n4. Safe Payments & Contracts: High-value transactions demand trust and accountability on both sides.';

  @override
  String get helpKycHowTitle => 'Step-by-step identity verification guide';

  @override
  String get helpKycHowContent =>
      'Completing KYC takes less than 2 minutes in the app:\n\n1. Open Account > Verification (KYC)\n2. Choose your document type: Ethiopian National ID (Fayda), Passport, Driver\'s License, or Kebele ID\n3. Take a sharp, well-lit photo of the front and back of your physical card or document\n4. Take a live selfie using your phone\'s camera (make sure your face is clearly visible without sunglasses or hats)\n5. Review your legal name and document number, then tap \"Submit Verification\"\n\nOur automated verification system and verification team review submissions within 24 to 48 hours.';

  @override
  String get helpKycRejectTitle => 'Resolving KYC rejection issues';

  @override
  String get helpKycRejectContent =>
      'If your verification was declined, it is usually due to one of these common issues:\n\n1. Blurry or Glared Photos: Details, letters, or photo IDs are unreadable due to low lighting or camera glare\n2. Expired Document: The identification card or passport submitted is past its expiration date\n3. Mismatched Information: The name entered in your profile does not match the legal name printed on the document\n4. Unclear Selfie: The selfie photo is dark, cropped, or does not clearly match the photo on your official ID\n5. Incomplete Images: Corners or edges of the physical document are cropped out\n\nHow to fix: Go to Verification (KYC), tap \"Resubmit Documents\", retake sharp, well-lit photos of the full document, take a new clear selfie, and submit again.';

  @override
  String get helpSafePrivacyTitle => 'Privacy policy and data protection';

  @override
  String get helpSafePrivacyContent =>
      'WaveMart strictly respects your personal privacy and safeguards your data:\n\n1. Information We Collect: Basic account profile (name, phone number, email), verified listing specifications, and direct customer support logs\n2. Privacy by Default: Your private phone number and email are concealed on public listings until a verified buyer utilizes a contact reveal\n3. Zero Data Selling: We do not sell, rent, or lease your personal information to advertisers or external marketing brokers\n4. Strict Confidentiality: Documents submitted for KYC verification are stored in secure, encrypted storage and accessed exclusively for compliance verification\n\nRead our full Privacy Policy on our website or reach out to support@wavemart.et for data questions.';

  @override
  String get helpSafeReportTitle =>
      'Reporting suspicious activity and getting help';

  @override
  String get helpSafeReportContent =>
      'We take marketplace safety seriously and provide immediate tools to keep your experience secure:\n\n1. In-App Reporting: Tap the three dots (menu) or \"Report\" on any property, vehicle, or job detail screen to flag suspicious pricing, fake images, or improper conduct\n2. Never Send Advance Money: Never wire advance deposits, broker commissions, or booking fees to individuals before physically inspecting the property or vehicle\n3. Emergency Support Line: Reach our dedicated customer safety team directly at +251 981 41 81 81\n4. Email Support: Email support@wavemart.et with screenshots and details; our trust & safety team investigates and responds within 24 hours\n\nTogether, we keep WaveMart the safest marketplace in Ethiopia.';

  @override
  String get profileVerificationKyc => 'KYC';

  @override
  String get profileStatsListings => 'Listings';

  @override
  String get profileStatsFavorites => 'Favorites';

  @override
  String get profileMyInterests => 'My Interests';

  @override
  String get profileMale => 'Male';

  @override
  String get profileFemale => 'Female';

  @override
  String get profileFirstName => 'First Name';

  @override
  String get profileLastName => 'Last Name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileEmailRequired => 'Email is required';

  @override
  String get profileEmailInvalid => 'Please enter a valid email';

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
  String get kycTakePhoto => 'Take Photo';

  @override
  String get kycChooseGallery => 'Choose from Gallery';

  @override
  String get kycConnectionErrorTitle => 'Connection Error';

  @override
  String get kycConnectionErrorSubtitle =>
      'Unable to load your KYC status. Please check your connection and try again.';

  @override
  String get kycRetry => 'Retry';

  @override
  String get kycVerifyPhoneSubtitle =>
      'We need to verify your phone number before proceeding';

  @override
  String get kycPhoneNumberMinDigits =>
      'Phone number must be at least 7 digits';

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
  String get searchUnder5M => 'Under 5M';

  @override
  String get search5M10M => '5M - 10M';

  @override
  String get search10M50M => '10M - 50M';

  @override
  String get search50M100M => '50M - 100M';

  @override
  String get search100MPlus => '100M+';

  @override
  String get searchNoResultsTitle => 'No Properties Found';

  @override
  String get searchNoResultsSubtitle =>
      'Try adjusting your search or filters to find more results';

  @override
  String get searchSortNewest => 'Newest';

  @override
  String get searchSortOldest => 'Oldest';

  @override
  String get searchSortPriceLow => 'Price ↑';

  @override
  String get searchSortPriceHigh => 'Price ↓';

  @override
  String get searchFilterAll => 'All';

  @override
  String get searchFilterAny => 'Any';

  @override
  String get listingNext => 'Next';

  @override
  String get listingSubmit => 'Submit';

  @override
  String get listingContinue => 'Continue';

  @override
  String get listingYearBuilt => 'Year Built';

  @override
  String get listingRentalPeriod => 'Rental Period';

  @override
  String get listingPostedForOtherOwner => 'Posted for other owner';

  @override
  String get listingOwnerName => 'Owner Name';

  @override
  String get listingOwnerPhone => 'Owner Phone Number';

  @override
  String get listingOwnerNameRequired => 'Enter the owner\'s name';

  @override
  String get listingOwnerPhoneRequired => 'Enter the owner\'s phone number';

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
  String get listingVideoMaxSize => 'Max 100MB';

  @override
  String listingExistingFile(Object name) {
    return 'Current: $name';
  }

  @override
  String get listingListingType => 'Listing Type';

  @override
  String get listingHoldingType => 'Holding Type';

  @override
  String get listingTaxPaid => 'Tax Paid Until';

  @override
  String get listingUseType => 'Use Type';

  @override
  String get listingLocation => 'Location';

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
  String listingPhotosCount(Object count) {
    return '$count photo(s)';
  }

  @override
  String get listingBedrooms => 'Bedrooms';

  @override
  String get listingBathrooms => 'Bathrooms';

  @override
  String get listingKitchens => 'Kitchens';

  @override
  String listingKitchensCount(Object count) {
    return '$count Kitchen(s)';
  }

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
  String get listingFacing3Directions => 'Facing 3 Directions';

  @override
  String get listingFacingAllDirections => 'Facing All Directions';

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
  String get listingIsTransferable => 'Transferable';

  @override
  String get listingTransferable => 'Transferable';

  @override
  String get listingNotTransferable => 'Not Transferable';

  @override
  String get listingTapToAdd => 'Tap to add';

  @override
  String listingImagesSelected(Object count) {
    return '$count image(s) selected';
  }

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
  String get listingCooperative140 => 'Cooperative (140m²)';

  @override
  String get listingCooperative70 => 'Cooperative (70m²)';

  @override
  String get listingMarketPlace => 'Market Place';

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
  String get listingSale => 'Sale';

  @override
  String get listingRent => 'Rent';

  @override
  String get listingForSale => 'For Sale';

  @override
  String get listingForRent => 'For Rent';

  @override
  String get listingVerified => 'Verified';

  @override
  String listingUnitM2(Object count) {
    return '$count m²';
  }

  @override
  String get listingsTitle => 'Listings';

  @override
  String get listingsCreate => 'Create new Listing';

  @override
  String get listingsFeatured => 'Featured';

  @override
  String get listingsNoResults => 'No listings found';

  @override
  String get listingsKeyFeatures => 'Key Features';

  @override
  String get listingsImInterested => 'Contact with Agent';

  @override
  String get listingsInterestAccepted => 'Interest Accepted';

  @override
  String get listingsInterestPending => 'Pending';

  @override
  String get listingsInterestRejected => 'Interest Rejected';

  @override
  String get listingsDefaultInterestMessage => 'I am interested!';

  @override
  String get callIncoming => 'Incoming call...';

  @override
  String get callAccept => 'Accept';

  @override
  String get callDecline => 'Decline';

  @override
  String get jitsiCallTitle => 'Audio Call';

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
  String get listingsVideoOptimizing => 'Optimizing video…';

  @override
  String get listingsViewOriginal => 'View original video';

  @override
  String get listingsNoDescription => 'No description provided.';

  @override
  String get listingsSimilarListings => 'Similar Listings';

  @override
  String get listingsNoFeatures => 'No key features specified';

  @override
  String get listingsNotFound => 'Listing Not Found';

  @override
  String get listingsNotFoundSubtitle => 'This property may have been removed';

  @override
  String get listingsLoadError => 'Could not load property';

  @override
  String listingIdLabel(Object id) {
    return 'Listing #$id';
  }

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
  String get favoritesTitle => 'Favorites';

  @override
  String get ordersTitle => 'Orders';

  @override
  String ordersCount(Object count) {
    return '$count orders';
  }

  @override
  String get ordersDetailTitle => 'Order Details';

  @override
  String get ordersEmpty => 'No orders yet';

  @override
  String get ordersEmptySubtitle =>
      'Submit your property requirements to get started';

  @override
  String get ordersCreate => 'Create Order';

  @override
  String get ordersStatusActive => 'Active';

  @override
  String get ordersStatusFulfilled => 'Fulfilled';

  @override
  String get ordersStatusCancelled => 'Canceled';

  @override
  String get ordersTypeHouse => 'House';

  @override
  String get ordersTypeLand => 'Land';

  @override
  String get ordersTypeLabel => 'Property Type';

  @override
  String get ordersListingType => 'I want to';

  @override
  String get ordersBuy => 'Buy';

  @override
  String get ordersRent => 'Rent';

  @override
  String get ordersHoldingType => 'Holding Type';

  @override
  String get ordersSelect => 'Select';

  @override
  String get ordersFacing => 'Facing Direction';

  @override
  String get ordersBudget => 'Budget (ETB)';

  @override
  String get ordersMin => 'Min';

  @override
  String get ordersMax => 'Max';

  @override
  String get ordersArea => 'Area (m²)';

  @override
  String get ordersDescription => 'Description';

  @override
  String get ordersDescriptionHint => 'Size, features, requirements...';

  @override
  String get ordersSubmit => 'Submit Order';

  @override
  String get ordersCancel => 'Cancel Order';

  @override
  String get ordersCancelConfirm =>
      'Are you sure you want to cancel this order?';

  @override
  String get ordersCancelled => 'Order canceled';

  @override
  String get ordersCreated => 'Order created successfully';

  @override
  String get ordersLocation => 'Location';

  @override
  String get ordersSuggestionsEmpty =>
      'No suggestions yet. An admin will suggest matching properties here.';

  @override
  String get ordersSuggestions => 'Suggested Properties';

  @override
  String get ordersSuggestionsViewDetails => 'View Details';

  @override
  String get ordersSuggestionsSubtitle =>
      'An admin has suggested these properties for you.';

  @override
  String get ordersSuggestionsAccept => 'Accept';

  @override
  String get ordersSuggestionsDecline => 'Decline';

  @override
  String get ordersSuggestionsAccepted => 'Accepted';

  @override
  String get ordersSuggestionsDeclined => 'Declined';

  @override
  String get ordersSuggestionsAcceptedMessage =>
      'Suggestion accepted. An admin will follow up with you.';

  @override
  String get ordersSuggestionsDeclinedMessage => 'Suggestion declined.';

  @override
  String get ordersSuggestionsError => 'Failed to process suggestion.';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptySubtitle =>
      'Start adding properties to your favorites';

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
  String get messagesUnread => 'unread';

  @override
  String get messagesUnreadMessages => 'Unread messages';

  @override
  String get messagesSwitchContext => 'Switch Context';

  @override
  String get settingsSectionAccount => 'My Account';

  @override
  String get settingsSectionSupport => 'Support';

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
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountConfirm =>
      'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data, listings, and messages will be removed.';

  @override
  String get settingsDeleteAccountSuccess => 'Account deleted successfully';

  @override
  String get listingEditTitle => 'Edit Listing';

  @override
  String get listingEditCooldownActive =>
      'Listings can only be edited once every 14 days.';

  @override
  String get listingMediaLockedTitle => 'Media Locked';

  @override
  String get listingMediaLockedDesc =>
      'Media cannot be modified after listing creation.';

  @override
  String get listingDeleteConfirmTitle => 'Delete Listing';

  @override
  String get listingDeleteConfirmMessage =>
      'Are you sure you want to delete this listing? This action cannot be undone.';

  @override
  String get languageTitle => 'Select Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageAmharic => 'አማርኛ (Amharic)';

  @override
  String get languageTigrinya => 'ትግርኛ (Tigrinya)';

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
  String get authEnterPhonePrompt => 'Please enter your phone number';

  @override
  String get authEnterOtpPrompt => 'Please enter the complete 6-digit OTP';

  @override
  String get authWelcomeTitle => 'Welcome to Wavemart';

  @override
  String get authWelcomeSubtitle => 'Your Trusted Property Marketplace';

  @override
  String authOtpSentMessage(Object phone) {
    return 'We sent a 6-digit code to $phone';
  }

  @override
  String authOtpSentEmailMessage(Object email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String authResendCountdown(Object seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get authChangeNumber => 'Change Number';

  @override
  String get authChangeNumberConfirm =>
      'Are you sure you want to change your phone number?';

  @override
  String get authExitLogin => 'Exit Login';

  @override
  String get authExitLoginConfirm =>
      'Are you sure you want to exit the login process?';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authCreateAccount => 'Create Your Account';

  @override
  String get authJoinMarketplace => 'Join Your Trusted Property Marketplace';

  @override
  String get authPersonalInfo => 'Personal Information';

  @override
  String get authVerifyPhone => 'Verify Your Phone';

  @override
  String get authVerifyAndCreate => 'Verify & Create Account';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get authCancelRegistration => 'Cancel registration?';

  @override
  String get authFirstNameRequired => 'Please enter your first name';

  @override
  String get authLastNameRequired => 'Please enter your last name';

  @override
  String get authPhoneRequired => 'Please enter a valid phone number';

  @override
  String get authSelectGender => 'Please select your gender';

  @override
  String get authNetworkError => 'Network error. Please try again.';

  @override
  String get subscriptionsTitle => 'Subscription Plans';

  @override
  String get subscriptionsCurrentPlan => 'Current Plan';

  @override
  String get subscriptionsSubscribe => 'Subscribe Now';

  @override
  String get subscriptionsSelectPlan => 'Select Plan';

  @override
  String get subscriptionsChoosePlan => 'Choose Your Plan';

  @override
  String get subscriptionsSelectPlanSubtitle =>
      'Select a plan that fits your needs. Upgrade anytime.';

  @override
  String get subscriptionsListings => 'Listings';

  @override
  String get subscriptionsRentalListings => 'Rental Listings';

  @override
  String get subscriptionsRentalVehicles => 'Rental Vehicles';

  @override
  String get subscriptionsFeaturedListings => 'Featured Listings';

  @override
  String subscriptionsDaysLeft(Object count) {
    return '$count days left';
  }

  @override
  String get subscriptionsFreeSuccess => 'Free plan activated successfully!';

  @override
  String subscriptionsExpiresOn(Object date) {
    return 'Expires on $date';
  }

  @override
  String subscriptionsCancelledOn(Object date) {
    return 'Cancelled on $date';
  }

  @override
  String subscriptionsExpiredOn(Object date) {
    return 'Expired on $date';
  }

  @override
  String get subscriptionsFeatures => 'Features';

  @override
  String get subscriptionsNoPlansAvailable =>
      'No active subscription plans available at this time.';

  @override
  String get subscriptionsOrders => 'Orders';

  @override
  String get subscriptionsContactViews => 'Contact Views';

  @override
  String get subscriptionsManage => 'Manage';

  @override
  String get subscriptionsRenew => 'Renew Plan';

  @override
  String subscriptionsFreeTrial(Object planName) {
    return 'Free Trial: $planName';
  }

  @override
  String get subscriptionsStartFreeTrialTitle => 'Start Free Trial?';

  @override
  String subscriptionsStartFreeTrialPrompt(Object days, Object planName) {
    return 'Start your $days-day free trial on $planName? One trial per account.';
  }

  @override
  String get subscriptionsStartTrialButton => 'Start Trial';

  @override
  String subscriptionsStartTrialDaysButton(Object days) {
    return 'Start $days-day Free Trial';
  }

  @override
  String subscriptionsUpgradeOff(Object percent) {
    return 'Upgrade $percent% off';
  }

  @override
  String subscriptionsPromoOff(Object percent) {
    return '$percent% off';
  }

  @override
  String get subscriptionsPaymentPending =>
      'Payment submitted. We\'ll notify you when it confirms.';

  @override
  String get subscriptionPaymentCancelled =>
      'Payment cancelled. You can try again anytime.';

  @override
  String get subscriptionsPoweredByChapa =>
      'Payments are processed securely by Chapa';

  @override
  String get subscriptionsVipAccess => 'VIP Access';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsEmptySubtitle =>
      'You will see updates here when something happens';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get paymentsEmpty => 'No payment history yet';

  @override
  String get paymentsRef => 'Ref';

  @override
  String get paymentsUnknownDate => 'Unknown date';

  @override
  String get paymentsSubscription => 'Subscription Payment';

  @override
  String get paymentsFeatured => 'Featured Listing';

  @override
  String get paymentsDirect => 'Direct Payment';

  @override
  String get paymentsGeneral => 'Payment';

  @override
  String get messageRetry => 'Try Again';

  @override
  String get messageDismiss => 'Dismiss';

  @override
  String get messageNetworkTitle => 'No Internet Connection';

  @override
  String get messageNetworkSubtitle => 'Check your connection and try again.';

  @override
  String get messageEmptyTitle => 'Nothing Here';

  @override
  String get messageEmptySubtitle => 'There\'s nothing to show right now.';

  @override
  String get messageErrorTitle => 'Something Went Wrong';

  @override
  String get messageErrorSubtitle => 'We couldn\'t complete your request.';

  @override
  String get messageSuccessTitle => 'Success!';

  @override
  String get messageSuccessSubtitle =>
      'Your action was completed successfully.';

  @override
  String get messageInfoTitle => 'Info';

  @override
  String get messageInfoSubtitle => 'Here is some important information.';

  @override
  String get messageWarningTitle => 'Warning';

  @override
  String get messageWarningSubtitle => 'Please review this important message.';

  @override
  String get listingUpgradeNow => 'Upgrade Now';

  @override
  String get listingFeatureNow => 'Feature Now';

  @override
  String get listingViewPlans => 'View Plans';

  @override
  String get listingFeatureThis => 'Feature this Listing';

  @override
  String get listingUnfeature => 'Unfeature';

  @override
  String get listingUnfeatureConfirmTitle => 'Unfeature Listing?';

  @override
  String get listingUnfeatureConfirmMessage =>
      'Are you sure you want to remove the featured status? You will need to use another quota slot to re-feature it.';

  @override
  String get commonGoodMorning => 'Good Morning';

  @override
  String get commonGoodAfternoon => 'Good Afternoon';

  @override
  String get commonGoodEvening => 'Good Evening';

  @override
  String get errorLoadingListings => 'Error Loading Listings';

  @override
  String get errorLoadingPayments => 'Error Loading Payments';

  @override
  String get errorLoadingNotifications => 'Error Loading Notifications';

  @override
  String get errorLoadingFavorites => 'Error Loading Favorites';

  @override
  String get errorLoadingConversations => 'Error Loading Conversations';

  @override
  String get errorLoadingMessages => 'Error Loading Messages';

  @override
  String get errorSubscription => 'Subscription Error';

  @override
  String errorJoinCall(Object error) {
    return 'Failed to join call: $error';
  }

  @override
  String get subscriptionPaymentSuccess => 'Payment successful!';

  @override
  String subscriptionUnexpectedError(Object error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get subscriptionRequiredTitle => 'Subscription Required';

  @override
  String get subscriptionRequiredListingSubtitle =>
      'You need an active subscription with posting a listing feature.';

  @override
  String get subscriptionRequiredDetailsSubtitle =>
      'You need an active subscription with access to view property details and contact owners.';

  @override
  String get subscriptionRequiredOrderSubtitle =>
      'You need an active subscription to create an order.';

  @override
  String get subscriptionLimitReached =>
      'You\'ve reached your listing limit. Upgrade your subscription to post more listings.';

  @override
  String get subscriptionLimitReachedRental =>
      'You\'ve reached your rental listing limit. Upgrade your subscription to post more rentals.';

  @override
  String get subscriptionLimitReachedRentalVehicle =>
      'You\'ve reached your vehicle rental limit. Upgrade your subscription to post more rentals.';

  @override
  String get subscriptionLimitReachedTitle => 'Listing Limit Reached';

  @override
  String get kycRequiredTitle => 'KYC Verification Required';

  @override
  String get kycPendingSubtitleReview =>
      'Your KYC verification is still pending review. You can post a listing once it\'s approved.';

  @override
  String get kycRequiredSubtitlePost =>
      'You need to complete identity verification (KYC) before you can post a listing.';

  @override
  String get kycVerifyNow => 'Verify Now';

  @override
  String get orderSelectPropertyType => 'Select the type of property';

  @override
  String get orderBudgetAreaSubtitle => 'Budget, area, and transaction type';

  @override
  String get orderHoldingFacingSubtitle => 'Holding type and facing direction';

  @override
  String get orderDescriptionSubtitle =>
      'Describe the property you need in detail';

  @override
  String get orderRequired => 'Required';

  @override
  String orderUpTo(Object price, Object unit) {
    return 'Up to $price $unit';
  }

  @override
  String get listingErrorPropertyTypeRequired => 'Property type is required';

  @override
  String get listingErrorHoldingTypeRequired => 'Holding type is required';

  @override
  String get listingErrorListingTypeRequired => 'Listing type is required';

  @override
  String get listingErrorUseTypeRequired => 'Use type is required';

  @override
  String get listingErrorAddressRequired => 'Please select a complete address';

  @override
  String get listingErrorMinPrice => 'Price must be at least 50,000 ETB';

  @override
  String get listingErrorLeasedYearRequired => 'Leased year is required';

  @override
  String get listingErrorCooperativeNameRequired =>
      'Cooperative name is required';

  @override
  String get listingErrorCooperativeCodeRequired =>
      'Cooperative code is required';

  @override
  String get listingErrorRoomsRequired => 'Total rooms is required';

  @override
  String get listingErrorHouseTypeRequired => 'House type is required';

  @override
  String get listingErrorAreaRequired => 'Total area is required';

  @override
  String get listingErrorDescriptionRequired => 'Description is required';

  @override
  String get listingErrorImageRequired =>
      'At least one property image is required';

  @override
  String get listingErrorSitePlanRequired =>
      'At least one site plan is required';

  @override
  String get listingErrorVideoRequired => 'A video tour is required';

  @override
  String get listingErrorOwnershipProofRequired =>
      'Ownership proof is required for cooperative properties';

  @override
  String get listingErrorTermsRequired =>
      'You must accept the Terms & Conditions';

  @override
  String listingErrorTaxYearRange(Object max, Object min) {
    return 'Tax paid year must be between $min and $max';
  }

  @override
  String listingErrorYearBuiltRange(Object max, Object min) {
    return 'Year built must be between $min and $max';
  }

  @override
  String get notificationJustNow => 'Just now';

  @override
  String get listingUpgradeToFeature => 'Upgrade to Feature';

  @override
  String get listingUpgradeToVip => 'Upgrade to VIP';

  @override
  String get subscriptionRequiredFeatureSubtitle =>
      'You need an active subscription with featured listing access to feature this listing.';

  @override
  String get errorConnection => 'Connection Error';

  @override
  String get commonBrowseProperties => 'Browse Properties';

  @override
  String get subscriptionPaymentFailedTitle => 'Payment Failed';

  @override
  String get subscriptionPaymentFailedSubtitle =>
      'Your transaction was not completed. Would you like to try again?';

  @override
  String get subscriptionTechnicalFailureSubtitle =>
      'The payment gateway could not be reached. Please check your connection.';

  @override
  String messagesWith(Object name) {
    return 'with $name';
  }

  @override
  String get errorJoinCallGeneric => 'Cannot open join link';

  @override
  String get errorVideoLoad => 'Failed to load video';

  @override
  String get statusActive => 'Active';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusCancelled => 'Canceled';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSuccess => 'Success';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get connectivityOffline => 'No internet connection';

  @override
  String get connectivityConnecting => 'Connecting...';

  @override
  String get connectivityOnline => 'Back Online';

  @override
  String get markAsVipTitle => 'Mark as VIP?';

  @override
  String get markAsVip => 'Mark as VIP';

  @override
  String get markAsVipMessage =>
      'Your listing will be highlighted with a VIP badge hidden from regular users.';

  @override
  String get upgradeToContact => 'Upgrade to Contact';

  @override
  String get listingsRevealContact => 'Reveal seller Contact';

  @override
  String get listingsRevealing => 'Revealing...';

  @override
  String get listingsSeller => 'Seller';

  @override
  String listingsContactViewsRemaining(int remaining, int max) {
    return '$remaining of $max contact views remaining this period';
  }

  @override
  String get ordersLimitTitle => 'Order Limit Reached';

  @override
  String get ordersLimitMessage =>
      'You\'ve reached the maximum number of orders for your current plan. Upgrade to create more orders.';

  @override
  String get ordersUpgradePlan => 'Upgrade Plan';

  @override
  String get subscriptionVideoUpgrade => 'Upgrade to watch property videos';

  @override
  String get subscriptionPlanNotSupportedListing =>
      'Your current plan does not support creating listings.';

  @override
  String get subscriptionPlanNotSupportedListingSubtitle =>
      'Please upgrade to a plan that supports listing creation.';

  @override
  String get subscriptionPlanNotSupportedOrder =>
      'Your current plan does not support creating orders.';

  @override
  String get subscriptionPlanNotSupportedOrderSubtitle =>
      'Please upgrade to a plan that supports order creation.';

  @override
  String get subscriptionsShowPricesIn => 'Show prices in:';

  @override
  String get subscriptionsDowngradeTitle => 'Switch Plan?';

  @override
  String get subscriptionsDowngradeMessage =>
      'Your current plan\'s features (listing slots, featured listings, VIP access, and other benefits) will not carry over to the new plan. Any unused benefits from your current plan may be lost.';

  @override
  String get subscriptionsDowngradeConfirm => 'Switch Anyway';

  @override
  String get commonTryAgain => 'Try Again';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get networkErrorTitle => 'No Internet Connection';

  @override
  String get networkErrorMessage =>
      'Please check your internet connection and try again.';

  @override
  String get statusFrozen => 'Frozen';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusSold => 'Sold';

  @override
  String get statusRented => 'Rented';

  @override
  String get splashSubtitle => 'Your Trusted Property Marketplace';

  @override
  String get homeRefreshing => 'Refreshing...';

  @override
  String get shareListingTitle =>
      'Shared from Wavemart - Your Trusted Property Marketplace';

  @override
  String get shareListingMessage => 'Check out this property on Wavemart: ';

  @override
  String get authOrSeparator => 'or';

  @override
  String get commonSigningIn => 'Signing in...';

  @override
  String get commonSignInWithGoogle => 'Sign in with Google';

  @override
  String get webviewDone => 'Done';

  @override
  String get webviewConnecting => 'Connecting to payment gateway...';

  @override
  String get webviewActivating => 'Activating your plan...';

  @override
  String get webviewPleaseWait => 'Please wait a moment';

  @override
  String get webviewGatewayTimeout => 'Gateway Timeout';

  @override
  String get webviewFailedToLoad => 'Failed to load payment URL';

  @override
  String get settingsDeleteRedirect =>
      'You will be redirected to our website to complete the deletion process.';

  @override
  String get commonFailedOpenOrder => 'Failed to open order';

  @override
  String get jitsiSettingUpCall => 'Setting up call...';

  @override
  String get submissionFailed => 'Submission Failed';

  @override
  String get submissionSaveDraft => 'Save Draft & Exit';

  @override
  String get submissionExit => 'Exit';

  @override
  String get submissionGoBack => 'Go Back';

  @override
  String get authFailedIdToken => 'Failed to get ID token';

  @override
  String get helpErrorYoutube => 'Could not open YouTube';

  @override
  String settingsBrowserErrorMessage(Object url) {
    return 'Could not open browser. Please visit $url';
  }

  @override
  String get interestsEmpty => 'No interests yet';

  @override
  String get interestsEmptySubtitle =>
      'Properties you express interest in will appear here';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateBlockingMessage =>
      'This version of the app is no longer supported. Please update to continue using Wavemart.';

  @override
  String updateAvailableMessage(Object versionSuffix) {
    return 'A new version$versionSuffix is available.';
  }

  @override
  String get updateVersionLabel => 'Version: ';

  @override
  String get updateLater => 'Later';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updateWhatsNew => 'What\'s New';

  @override
  String get routerInvalidRoute => 'Invalid route';

  @override
  String get reportListing => 'Report this listing';

  @override
  String get reportReason => 'Reason';

  @override
  String get reportSelectReason => 'Select a reason...';

  @override
  String get reportSpam => 'Spam';

  @override
  String get reportFake => 'Fake listing';

  @override
  String get reportWrongCategory => 'Wrong category';

  @override
  String get reportDuplicate => 'Duplicate listing';

  @override
  String get reportInappropriate => 'Inappropriate content';

  @override
  String get reportOther => 'Other';

  @override
  String get reportDescription => 'Description (optional)';

  @override
  String get reportDescriptionHint => 'Provide additional details...';

  @override
  String get reportSubmit => 'Submit Report';

  @override
  String get reportSubmitting => 'Submitting...';

  @override
  String get reportSuccess => 'Report submitted. Thank you.';

  @override
  String get reportErrorGeneric => 'Failed to submit report. Please try again.';

  @override
  String get listingCar => 'Vehicle';

  @override
  String get listingCarPlural => 'Vehicles';

  @override
  String get listingVehicleCategory => 'Vehicle Category';

  @override
  String get listingMake => 'Make';

  @override
  String get listingMakeModel => 'Make & Model';

  @override
  String get listingModel => 'Model';

  @override
  String get listingYear => 'Year';

  @override
  String get listingTransmission => 'Transmission';

  @override
  String get listingFuelType => 'Fuel Type';

  @override
  String get listingBodyType => 'Body Type';

  @override
  String get listingMileage => 'Mileage';

  @override
  String get listingMileageMax => 'Max Mileage (km)';

  @override
  String get listingCondition => 'Condition';

  @override
  String get listingEngineSize => 'Engine Size';

  @override
  String get listingColor => 'Color';

  @override
  String get searchSortYearDesc => 'Year ↓';

  @override
  String get searchSortYearAsc => 'Year ↑';

  @override
  String get searchSortMileageLow => 'Mileage ↓';

  @override
  String get searchSortMileageHigh => 'Mileage ↑';

  @override
  String get searchLocation => 'Location';

  @override
  String get searchAnyMake => 'Any Make';

  @override
  String get searchAnyModel => 'Any Model';

  @override
  String get searchCars => 'Search vehicles';

  @override
  String get commonIsRequired => 'is required';

  @override
  String get carLocationRequired => 'Please select a location (Kebele)';

  @override
  String get carTermsRequired => 'You must accept the terms';

  @override
  String get carRentalPriceNegotiable => 'By Negotiation';

  @override
  String get listingPricing => 'Pricing';

  @override
  String get listingOptions => 'Options';

  @override
  String get listingDoors => 'Doors';

  @override
  String get listingSeats => 'Seats';

  @override
  String get listingVin => 'VIN';

  @override
  String get listingCreated => 'Vehicle listing created';

  @override
  String get listingUpdated => 'Vehicle listing updated';

  @override
  String get updateListing => 'Update Listing';

  @override
  String get carAddPhoto => 'Add Photo';

  @override
  String get carPhotoFormatHint => 'JPEG, PNG, WebP — Max 10MB each';

  @override
  String get carEnterMakeName => 'Enter make name';

  @override
  String get carEnterModelName => 'Enter model name';

  @override
  String carFileTooLarge(Object name) {
    return '$name exceeds 10MB limit';
  }

  @override
  String get photos => 'Photos';

  @override
  String get mediaTapToPreview => 'Tap to preview';

  @override
  String get mediaImageFormatHint => 'JPEG, PNG, WebP';

  @override
  String get mediaSitePlanSubtitle => 'Site plan image';

  @override
  String get mediaExistingSitePlan => 'Existing site plan';

  @override
  String get mediaOwnershipSubtitle => 'Ownership document';

  @override
  String get mediaVideoFormatHint => 'MP4, max 5 minutes';

  @override
  String get mediaExistingVideo => 'Existing video';

  @override
  String get mediaPlayPreview => 'Play Preview';

  @override
  String get mediaPicture => 'Picture';

  @override
  String get mediaPictures => 'Pictures';

  @override
  String get mediaSitePlan => 'Site Plan';

  @override
  String get mediaOwnershipProof => 'Ownership Proof';

  @override
  String get mediaVideo => 'Video';

  @override
  String mediaFileSizeError(Object label, Object limit) {
    return '$label exceeds $limit limit. Please choose a smaller file.';
  }

  @override
  String get mediaImagesLocked => 'Images cannot be modified after submission.';

  @override
  String get carVipSubtitle => 'Get a VIP badge for VIP only visibility';

  @override
  String get carCustomFeatures => 'Custom features';

  @override
  String get submissionStepValidating => 'Validating data';

  @override
  String get submissionStepUploading => 'Uploading files';

  @override
  String get submissionStepSaving => 'Saving listing';

  @override
  String get submissionValidating => 'Validating data...';

  @override
  String get submissionUploading => 'Uploading files...';

  @override
  String get submissionSaving => 'Saving listing...';

  @override
  String get submissionSavingChanges => 'Saving changes...';

  @override
  String get submissionSubmittingTitle => 'Submitting Your Listing';

  @override
  String get submissionSuccessTitle => 'Listing Submitted!';

  @override
  String get submissionPendingApproval =>
      'Your listing is pending approval. We\'ll notify you once it\'s live.';

  @override
  String get submissionViewListings => 'View My Listings';

  @override
  String get submissionCreateAnother => 'Create Another';

  @override
  String get submissionCreatedMessage => 'Your listing has been submitted.';

  @override
  String get submissionUpdatedMessage => 'Listing updated successfully.';

  @override
  String get submissionConnectionLost =>
      'Connection lost. Your data has been saved.';

  @override
  String get submissionRequestTimedOut =>
      'Request timed out. Your data has been saved.';

  @override
  String get submissionErrorDefault =>
      'Something went wrong. Please try again.';

  @override
  String get listingDetail => 'Details';

  @override
  String get listingSpecifications => 'Specifications';

  @override
  String get carContactSeller => 'Contact Seller';

  @override
  String get carCall => 'Call';

  @override
  String get carCallHint => 'Tap to call the seller';

  @override
  String get carWhatsapp => 'WhatsApp';

  @override
  String get carWhatsappHint => 'Chat on WhatsApp';

  @override
  String get carTelegram => 'Telegram';

  @override
  String get carTelegramHint => 'Chat on Telegram';

  @override
  String get conditionNew => 'New';

  @override
  String get conditionUsed => 'Used';

  @override
  String get categoryCar => 'Car';

  @override
  String get categoryMotorcycle => 'Motorcycle';

  @override
  String get categoryBicycle => 'Bicycle';

  @override
  String get categoryConstructionEquipment => 'Construction Equipment';

  @override
  String get bodyTypeSedan => 'Sedan';

  @override
  String get bodyTypeSuv => 'SUV';

  @override
  String get bodyTypeHatchback => 'Hatchback';

  @override
  String get bodyTypePickup => 'Pickup';

  @override
  String get bodyTypeTruck => 'Truck';

  @override
  String get bodyTypeVan => 'Van';

  @override
  String get bodyTypeMinibus => 'Minibus';

  @override
  String get bodyTypeCoupe => 'Coupe';

  @override
  String get bodyTypeConvertible => 'Convertible';

  @override
  String get bodyTypeStationWagon => 'Station Wagon';

  @override
  String get bodyTypeStandard => 'Standard';

  @override
  String get bodyTypeCruiser => 'Cruiser';

  @override
  String get bodyTypeSport => 'Sport';

  @override
  String get bodyTypeTouring => 'Touring';

  @override
  String get bodyTypeDualSport => 'Dual Sport';

  @override
  String get bodyTypeScooter => 'Scooter';

  @override
  String get bodyTypeMoped => 'Moped';

  @override
  String get bodyTypeMountain => 'Mountain';

  @override
  String get bodyTypeRoad => 'Road';

  @override
  String get bodyTypeHybrid => 'Hybrid';

  @override
  String get bodyTypeCity => 'City';

  @override
  String get bodyTypeElectric => 'Electric';

  @override
  String get bodyTypeFolding => 'Folding';

  @override
  String get bodyTypeExcavator => 'Excavator';

  @override
  String get bodyTypeBulldozer => 'Bulldozer';

  @override
  String get bodyTypeLoader => 'Loader';

  @override
  String get bodyTypeCrane => 'Crane';

  @override
  String get bodyTypeForklift => 'Forklift';

  @override
  String get bodyTypeRoller => 'Roller';

  @override
  String get bodyTypeDumper => 'Dumper';

  @override
  String get bodyTypeGenerator => 'Generator';

  @override
  String get bodyTypeCompressor => 'Compressor';

  @override
  String get featureAc => 'AC';

  @override
  String get featureAbs => 'ABS';

  @override
  String get featureAirbag => 'Airbag';

  @override
  String get featureAlarmSystem => 'Alarm System';

  @override
  String get featureAlloyWheels => 'Alloy Wheels';

  @override
  String get featureBackupCamera => 'Backup Camera';

  @override
  String get featureBasket => 'Basket';

  @override
  String get featureBatteryIncluded => 'Battery Included';

  @override
  String get featureBell => 'Bell';

  @override
  String get featureBluetooth => 'Bluetooth';

  @override
  String get featureCentralLocking => 'Central Locking';

  @override
  String get featureCrashBars => 'Crash Bars';

  @override
  String get featureCruiseControl => 'Cruise Control';

  @override
  String get featureDiscBrakes => 'Disc Brakes';

  @override
  String get featureElectricAssist => 'Electric Assist';

  @override
  String get featureFenders => 'Fenders';

  @override
  String get featureFogLights => 'Fog Lights';

  @override
  String get featureFrontSuspension => 'Front Suspension';

  @override
  String get featureGps => 'GPS';

  @override
  String get featureHeatedGrips => 'Heated Grips';

  @override
  String get featureHeatedSeat => 'Heated Seat';

  @override
  String get featureHydraulicThumb => 'Hydraulic Thumb';

  @override
  String get featureKickstand => 'Kickstand';

  @override
  String get featureLeatherSeats => 'Leather Seats';

  @override
  String get featureLedLights => 'LED Lights';

  @override
  String get featureLockIncluded => 'Lock Included';

  @override
  String get featureLongReachArm => 'Long Reach Arm';

  @override
  String get featureLowHours => 'Low Hours';

  @override
  String get featureLuggageRack => 'Luggage Rack';

  @override
  String get featureNavigation => 'Navigation';

  @override
  String get featurePowerSteering => 'Power Steering';

  @override
  String get featurePowerWindows => 'Power Windows';

  @override
  String get featureQuickAttach => 'Quick Attach';

  @override
  String get featureRearSuspension => 'Rear Suspension';

  @override
  String get featureRops => 'ROPS';

  @override
  String get featureRoofRack => 'Roof Rack';

  @override
  String get featureServiceRecords => 'Service Records';

  @override
  String get featureSidePanniers => 'Side Panniers';

  @override
  String get featureSunroof => 'Sunroof';

  @override
  String get featureTopCase => 'Top Case';

  @override
  String get featureTowBar => 'Tow Bar';

  @override
  String get featureTrackVsWheels => 'Track vs Wheels';

  @override
  String get featureUsbCharger => 'USB Charger';

  @override
  String get featureWindshield => 'Windshield';

  @override
  String get listingPostedByAgent => 'Posted by agent';

  @override
  String get listingPostedByAgentLabel => 'This listing is posted by an agent';

  @override
  String get orderPostedByAgentLabel => 'This order is posted by an agent';

  @override
  String get agentIdLabel => 'Agent ID';

  @override
  String get agentIdRequired => 'Agent ID is required when posted by agent';

  @override
  String get agentIdEmpty => 'Agent ID is required';

  @override
  String get listingErrorTaxPaidYearRequired => 'Tax paid year is required';

  @override
  String get listingErrorAcquisitionClarificationRequired =>
      'Acquisition clarification is required';

  @override
  String get listingErrorLeasePricePerSqmRequired =>
      'Lease price per sqm is required';

  @override
  String get listingErrorBuildTypeRequired => 'Build type is required';

  @override
  String get listingErrorAnnualPaymentRequired => 'Annual payment is required';

  @override
  String get listingErrorBuildingStatusRequired =>
      'Building status is required';

  @override
  String get listingErrorDebtAmountRequired => 'Debt amount is required';

  @override
  String get listingErrorYearBuiltRequired => 'Year built is required';

  @override
  String get jobAddEducation => 'Add Education';

  @override
  String get jobAddExperience => 'Add Experience';

  @override
  String get jobAll => 'All Jobs';

  @override
  String get jobApplicationDeadlineOptional =>
      'Application Deadline (Optional)';

  @override
  String get jobBasicInfo => 'Basic Info';

  @override
  String get jobBrowseTitle => 'Browse Jobs';

  @override
  String get jobCategoryEducation => 'Education';

  @override
  String get jobCategoryFinance => 'Finance';

  @override
  String get jobCategoryHealthcare => 'Healthcare';

  @override
  String get jobCategoryIT => 'IT & Software';

  @override
  String get jobCategoryOther => 'Other';

  @override
  String get jobClear => 'Clear';

  @override
  String get jobCompanyName => 'Company Name';

  @override
  String get jobCreateButton => 'Post a Job';

  @override
  String get jobCreateTitle => 'Post a Job';

  @override
  String get jobDeadline => 'Deadline';

  @override
  String get jobDeadlinePast => 'Deadline cannot be before today';

  @override
  String get jobDescription => 'Description';

  @override
  String get jobEditTitle => 'Edit Job';

  @override
  String get jobEducationLevel => 'Education Level';

  @override
  String get jobEducationOtherHint => 'Enter education level';

  @override
  String get jobEmployerInfo => 'Employer Info';

  @override
  String get jobFeatured => 'Featured Job';

  @override
  String get jobFieldOfStudy => 'Field of Study';

  @override
  String get jobFieldOfStudyHint => 'e.g. Computer Science, Accounting';

  @override
  String get jobFilter => 'Filter Jobs';

  @override
  String get jobFixed => 'Fixed';

  @override
  String get jobImages => 'Images';

  @override
  String get jobIndividualPoster => 'Individual Poster';

  @override
  String get jobJob => 'Job';

  @override
  String get jobJobCategory => 'Job Category';

  @override
  String get jobJobDetails => 'Job Details';

  @override
  String get jobJobTitle => 'Job Title';

  @override
  String get jobJobType => 'Job Type';

  @override
  String get jobLocation => 'Location';

  @override
  String get jobLocationImages => 'Location Images';

  @override
  String get jobLocationPlaceholder => 'Search location...';

  @override
  String get jobLogin => 'Login';

  @override
  String get jobLoginRequired => 'Login Required';

  @override
  String get jobMetaDescription =>
      'Find the best jobs in Ethiopia on Wavemart.';

  @override
  String get jobMyJobs => 'My Jobs';

  @override
  String get jobNegotiable => 'Negotiable';

  @override
  String get jobNoDeadline => 'No deadline';

  @override
  String get jobNoEducationAdded => 'No specific education requirements added.';

  @override
  String get jobNoExperienceAdded =>
      'No specific experience requirements added.';

  @override
  String get jobNoPhotos => 'No Photos';

  @override
  String get jobNoResultsDescription =>
      'We couldn\'t find any jobs matching your criteria.';

  @override
  String get jobNoResultsTitle => 'No Jobs Found';

  @override
  String get jobPhotos => 'Photos';

  @override
  String get jobPositions => 'Positions';

  @override
  String get jobPostingAsCompany => 'Posting as Company?';

  @override
  String get jobRange => 'Range';

  @override
  String get jobRequirements => 'Requirements';

  @override
  String get jobSalaryAndReqs => 'Salary & Requirements';

  @override
  String get jobSalaryMax => 'Max Salary';

  @override
  String get jobSalaryMin => 'Min Salary';

  @override
  String get jobSalaryPerAgreement => 'Per Agreement';

  @override
  String get jobSalaryType => 'Salary Type';

  @override
  String get jobSelect => 'Select';

  @override
  String get jobSimilarJobs => 'Similar Jobs';

  @override
  String get jobSpecificLocation => 'Specific Location';

  @override
  String get jobSubmit => 'Submit';

  @override
  String get jobTypeContract => 'Contract';

  @override
  String get jobTypeFullTime => 'Full Time';

  @override
  String get jobTypeInternship => 'Internship';

  @override
  String get jobTypePartTime => 'Part Time';

  @override
  String get jobUpdate => 'Update';

  @override
  String get jobValidYearsRequired => 'Enter valid years (e.g. 2)';

  @override
  String get jobYearsOfExperience => 'Years of Experience';

  @override
  String get jobContactEmployer => 'Contact Employer';

  @override
  String get jobCall => 'Call';

  @override
  String get jobCallHint => 'Tap to call the employer';

  @override
  String get jobWhatsapp => 'WhatsApp';

  @override
  String get jobWhatsappHint => 'Chat on WhatsApp';

  @override
  String get jobTelegram => 'Telegram';

  @override
  String get jobTelegramHint => 'Chat on Telegram';

  @override
  String get jobSeekerMessage => 'Message';

  @override
  String get homeJobs => 'Jobs';

  @override
  String get homeSeekers => 'Seekers';

  @override
  String get seekersTitle => 'Job Seekers';

  @override
  String get seekersNoProfiles => 'No profiles found';

  @override
  String get seekersNoResults => 'No job seekers found';

  @override
  String get jobSearchPlaceholder => 'Search jobs...';

  @override
  String get jobNotFound => 'Job not found';

  @override
  String get jobRequiredGender => 'Required Gender';

  @override
  String get jobPostingLimitTitle => 'Job Posting Limit Reached';

  @override
  String get jobPostingLimitSubtitle =>
      'You have reached your limit. Upgrade plan to post more jobs.';

  @override
  String get seekerProfileDetails => 'Profile Details';

  @override
  String get seekerExperience => 'Experience';

  @override
  String get seekerNoEducationAdded => 'No education credentials added yet.';

  @override
  String get seekerNoExperienceAdded => 'No work history added yet.';

  @override
  String get seekerNoBio => 'No bio provided.';

  @override
  String get seekerAboutBio => 'About / Bio';

  @override
  String get seekerNoWorkExperience => 'No work experience listed.';

  @override
  String get seekerPdfDocument => 'PDF Document';

  @override
  String get seekerVideo => 'Video';

  @override
  String get seekerWaveMartOptions => 'WaveMart options';

  @override
  String get seekerContactOptionsSubtitle =>
      'Direct in-app messaging with candidate';

  @override
  String get listingWaveMartOptions => 'WaveMart options';

  @override
  String get listingMessageSeller => 'Message';

  @override
  String seekerYearsExp(String years) {
    return '$years yrs exp';
  }

  @override
  String seekerYearsTotal(String years) {
    return '$years yrs total';
  }

  @override
  String get seekerMyProfile => 'My Job Profile';

  @override
  String get seekerFullName => 'Full Name';

  @override
  String get seekerProfessionalTitle => 'Professional Title';

  @override
  String get seekerMakePublic => 'Make Profile Public';

  @override
  String get seekerSaveProfile => 'Save Profile';

  @override
  String get seekerProfileSaved => 'Profile updated successfully';

  @override
  String get seekerCv => 'CV';

  @override
  String get seekerUploadCv => 'Upload CV (Optional)';

  @override
  String get seekerViewCv => 'View CV';

  @override
  String get listingPerDay => '/ day';

  @override
  String get listingPerMonth => '/ month';

  @override
  String get listingPerYear => '/ year';

  @override
  String get searchUnder15K => 'Under 15K';

  @override
  String get search15K30K => '15K - 30K';

  @override
  String get search30K60K => '30K - 60K';

  @override
  String get search60K100K => '60K - 100K';

  @override
  String get search100KPlus => '100K+';

  @override
  String get listingTypeNotEditable =>
      'Listing type cannot be changed after creation';

  @override
  String get searchArea => 'Area (m²)';

  @override
  String get searchAreaMin => 'Min area';

  @override
  String get searchAreaMax => 'Max area';

  @override
  String get searchPriceMin => 'Min price';

  @override
  String get searchPriceMax => 'Max price';

  @override
  String get searchCustom => 'Custom';

  @override
  String get searchSalaryMin => 'Minimum salary (ETB)';

  @override
  String get searchSeekersPlaceholder => 'Search job seekers...';

  @override
  String searchResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get searchValidationNumber => 'Enter a valid number';

  @override
  String get searchValidationRange => 'Minimum must be less than maximum';

  @override
  String get transmissionManual => 'Manual';

  @override
  String get transmissionAutomatic => 'Automatic';

  @override
  String get transmissionSemiAutomatic => 'Semi-automatic';

  @override
  String get fuelPetrol => 'Petrol';

  @override
  String get fuelGasoline => 'Gasoline';

  @override
  String get fuelDiesel => 'Diesel';

  @override
  String get fuelHybrid => 'Hybrid';

  @override
  String get fuelElectric => 'Electric';

  @override
  String get rentalPeriodDay => 'Day';

  @override
  String get rentalPeriodMonth => 'Month';

  @override
  String get rentalPeriodYear => 'Year';
}
