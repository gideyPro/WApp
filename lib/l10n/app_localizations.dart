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

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetryMessage.
  ///
  /// In en, this message translates to:
  /// **'Please try again'**
  String get commonRetryMessage;

  /// No description provided for @commonPressBackAgain.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get commonPressBackAgain;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get navSettings;

  /// No description provided for @homeLatestRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeLatestRecently;

  /// No description provided for @homeVipTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium VIP Properties'**
  String get homeVipTitle;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @vipTeaserCta.
  ///
  /// In en, this message translates to:
  /// **'Unlock VIP Listings'**
  String get vipTeaserCta;

  /// No description provided for @vipNoListings.
  ///
  /// In en, this message translates to:
  /// **'No VIP listings yet '**
  String get vipNoListings;

  /// No description provided for @vipBadge.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get vipBadge;

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

  /// No description provided for @noStatusListings.
  ///
  /// In en, this message translates to:
  /// **'No {status} listings'**
  String noStatusListings(Object status);

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

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

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for help...'**
  String get helpSearchHint;

  /// No description provided for @helpNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get helpNoResultsTitle;

  /// No description provided for @helpNoResultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords...'**
  String get helpNoResultsSubtitle;

  /// No description provided for @helpStillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpStillNeedHelp;

  /// No description provided for @helpSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Our support team is here to help you.'**
  String get helpSupportTeam;

  /// No description provided for @helpEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get helpEmail;

  /// No description provided for @helpCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get helpCall;

  /// No description provided for @helpErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get helpErrorEmail;

  /// No description provided for @helpErrorPhone.
  ///
  /// In en, this message translates to:
  /// **'Could not open phone app'**
  String get helpErrorPhone;

  /// No description provided for @helpYoutubeSub.
  ///
  /// In en, this message translates to:
  /// **'Watch tutorials, platform tips & video tours'**
  String get helpYoutubeSub;

  /// No description provided for @helpYoutubeSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get helpYoutubeSubscribe;

  /// No description provided for @helpCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account & Profile'**
  String get helpCategoryAccount;

  /// No description provided for @helpCategoryListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get helpCategoryListings;

  /// No description provided for @helpCategoryOrders.
  ///
  /// In en, this message translates to:
  /// **'Custom Requests & Orders'**
  String get helpCategoryOrders;

  /// No description provided for @helpCategoryPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments & Subscriptions'**
  String get helpCategoryPayments;

  /// No description provided for @helpCategoryKyc.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get helpCategoryKyc;

  /// No description provided for @helpCategorySafety.
  ///
  /// In en, this message translates to:
  /// **'Safety & Policies'**
  String get helpCategorySafety;

  /// No description provided for @helpAccCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'How to create and set up your account'**
  String get helpAccCreateTitle;

  /// No description provided for @helpAccCreateContent.
  ///
  /// In en, this message translates to:
  /// **'To get started on WaveMart:\n\n1. Open the app and tap \"Register\" or \"Sign In\"\n2. Enter your full name, phone number, and a secure password\n3. You will immediately receive a 6-digit SMS verification code (OTP)\n4. Enter the code to verify your phone number and activate your account\n\nOnce registered, you can browse real estate, vehicles, and jobs, save your favorites, unlock seller contact details, or start publishing your own listings.'**
  String get helpAccCreateContent;

  /// No description provided for @helpAccFavTitle.
  ///
  /// In en, this message translates to:
  /// **'Managing favorites and saved items'**
  String get helpAccFavTitle;

  /// No description provided for @helpAccFavContent.
  ///
  /// In en, this message translates to:
  /// **'Keep track of listings you are interested in:\n\n1. Tap the heart icon on any property, vehicle, or job card to save it\n2. Access all your saved items anytime from Account > Favorites\n3. Saved items update in real time if prices drop, a property or vehicle is sold or rented, or a job vacancy closes\n4. Tap the heart icon again to remove an item from your favorites\n\nSaving favorites allows you to compare options, monitor market trends, and quickly revisit items without searching again.'**
  String get helpAccFavContent;

  /// No description provided for @helpAccMsgTitle.
  ///
  /// In en, this message translates to:
  /// **'In-app messaging and contact reveal'**
  String get helpAccMsgTitle;

  /// No description provided for @helpAccMsgContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart provides direct channels to connect with sellers, agents, and recruiters:\n\n1. In-App Chat: Tap \"Chat\" on any listing to start an instant, secure conversation without sharing your personal number\n2. Delivery Indicators: Single check mark means sent; double check marks indicate delivered and read\n3. Direct Contact Reveal: Tap \"Reveal Contact\" or \"Call\" to view the verified phone number of the seller or employer (uses 1 view from your monthly subscription quota)\n4. Context Switching: Easily track which property, vehicle, or job each discussion refers to via the chat header\n\nFor your personal safety, always keep discussions, agreements, and payment negotiations within the WaveMart app.'**
  String get helpAccMsgContent;

  /// No description provided for @helpListCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'How to post properties, vehicles, and jobs'**
  String get helpListCreateTitle;

  /// No description provided for @helpListCreateContent.
  ///
  /// In en, this message translates to:
  /// **'Publishing your listings on WaveMart is quick and guided:\n\n1. Tap the \"+\" button in the center of the bottom navigation bar\n2. Choose your category: Real Estate (House, Apartment, Commercial, Land for Sale or Rent), Vehicles (Car, Truck, Motorcycle, Machinery for Sale or Rent), or Job Opportunity\n3. Fill in the required specifications (price, area, mileage, employment terms, qualifications, and exact location)\n4. Upload high-resolution photos and document scans (such as Site Plans for properties or vehicle inspection details)\n5. Review your information and tap \"Submit Listing\"\n\nAll listings are verified by our moderation team within 24 hours before going live to ensure quality and authenticity.'**
  String get helpListCreateContent;

  /// No description provided for @helpListManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Managing, editing, and renewing listings'**
  String get helpListManageTitle;

  /// No description provided for @helpListManageContent.
  ///
  /// In en, this message translates to:
  /// **'You maintain complete control over all your published items:\n\n1. Go to Account > My Listings to view all your property, vehicle, and job posts\n2. Check listing statuses: Pending Approval, Active, Sold, Rented, Filled, or Rejected\n3. Tap any listing to open management controls: Edit details, adjust pricing, or mark as Sold or Closed\n4. Boost Visibility: Apply a Featured or VIP upgrade directly from the listing management screen\n5. Delete or Pause: Remove items that are no longer available or temporarily unpublish them\n\nPlease note: Major modifications (such as changing location or core title) will undergo a quick re-review by our moderation team.'**
  String get helpListManageContent;

  /// No description provided for @helpListTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for creating high-converting listings'**
  String get helpListTipsTitle;

  /// No description provided for @helpListTipsContent.
  ///
  /// In en, this message translates to:
  /// **'Attract more serious buyers, renters, and top candidates by following these best practices:\n\n1. High-Quality Visuals: Upload at least 5 clear, well-lit photos showing all angles, interior, exterior, and surrounding area\n2. Transparent Pricing: List realistic, market-competitive prices. State clearly whether the price is fixed or negotiable\n3. Comprehensive Details: For real estate, specify area, water/electricity access, and nearby landmarks. For vehicles, state exact year, mileage, engine, and service history\n4. Clear Job Descriptions: Outline compensation, working hours, required experience, and key responsibilities\n5. Respond Fast: Maintain active engagement in the in-app chat. Fast response times build trust and close deals faster.'**
  String get helpListTipsContent;

  /// No description provided for @helpListVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video walkthroughs and virtual tours'**
  String get helpListVideoTitle;

  /// No description provided for @helpListVideoContent.
  ///
  /// In en, this message translates to:
  /// **'Video walkthroughs give buyers and renters a realistic preview before visiting in person:\n\n1. Uploading: When creating or editing a property or vehicle listing, attach a short video tour (up to 60 seconds)\n2. Cloud Processing: Our background video engine automatically compresses and optimizes your clip for smooth streaming across mobile connections\n3. Processing Status: While processing, the listing will show a video preparation badge; once complete, the playable video appears automatically\n4. Verified Video Badge: Listings featuring real video walkthroughs receive higher visibility and customer engagement\n\nViewing video tours is seamless and supported on standard mobile data connections.'**
  String get helpListVideoContent;

  /// No description provided for @helpListInterestTitle.
  ///
  /// In en, this message translates to:
  /// **'Expressing interest and contacting sellers'**
  String get helpListInterestTitle;

  /// No description provided for @helpListInterestContent.
  ///
  /// In en, this message translates to:
  /// **'Connect seamlessly with verified sellers and recruiters:\n\n1. Browse to any property, vehicle, or job detail screen\n2. Direct Contact: Tap \"Reveal Contact\" to instantly view and dial the verified phone number. Each reveal uses one view from your active subscription quota\n3. In-App Chat: Tap \"Chat\" to send inquiries, ask questions, or negotiate terms directly within WaveMart\n4. Job Applications: For job postings, tap \"Apply\" or message the employer directly with your profile\n5. My Interests: View your saved inquiries, conversations, and interaction history anytime from Account > My Interests\n\nDirect contact reveals require an active subscription tier with remaining monthly contact views.'**
  String get helpListInterestContent;

  /// No description provided for @helpListStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding listing statuses and moderation'**
  String get helpListStatusTitle;

  /// No description provided for @helpListStatusContent.
  ///
  /// In en, this message translates to:
  /// **'Every listing on WaveMart moves through defined verification stages:\n\n- Pending Review: Your submission is being examined by our moderation team for authenticity and image quality (usually within 24 hours)\n- Active: Your listing is live, searchable, and receiving views from buyers across Ethiopia\n- Featured / VIP: Your listing is highlighted with high-priority placement on the homepage and search feeds\n- Sold / Rented / Filled: The property has closed, the vehicle is sold, or the job opening has been filled\n- Rejected: The listing did not meet guidelines (e.g., duplicate post, invalid price, unclear photos). Review the specific feedback, make edits, and resubmit\n- Frozen / Inactive: Temporarily hidden by the owner or administrator\n\nCheck the live status of all your items under Account > My Listings.'**
  String get helpListStatusContent;

  /// No description provided for @helpOrdCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom requests for properties, vehicles, and talent'**
  String get helpOrdCreateTitle;

  /// No description provided for @helpOrdCreateContent.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find the exact property, specific vehicle, or skilled professional you need? Create a Custom Request:\n\n1. Navigate to the Requests (Orders) section and tap \"Create Request\"\n2. Choose what you are looking for: Real Estate (buy or rent), Vehicles (make, model, year, budget), or Talent/Hiring requirements\n3. Specify your target budget, desired location, timeline, and exact requirements\n4. Submit your request for automated matching and facilitator assistance\n\nOur system and support team match your request against verified upcoming inventory and alert you the moment a suitable option becomes available.'**
  String get helpOrdCreateContent;

  /// No description provided for @helpOrdManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Managing request proposals and matches'**
  String get helpOrdManageTitle;

  /// No description provided for @helpOrdManageContent.
  ///
  /// In en, this message translates to:
  /// **'When suitable properties, vehicles, or candidate profiles match your request:\n\n1. You will receive an instant notification with full details of the matched proposal\n2. Open your request in the Requests tab to review photos, pricing, and specifications\n3. Tap \"Accept\" to connect directly with the owner, dealer, or applicant\n4. If an offer does not meet your expectations, tap \"Decline\" to keep your request open for further proposals\n5. Close or update your request at any time once your goal has been achieved.'**
  String get helpOrdManageContent;

  /// No description provided for @helpPayPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership plans, listing limits, and contact quotas'**
  String get helpPayPlansTitle;

  /// No description provided for @helpPayPlansContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart offers transparent subscription tiers designed for buyers, sellers, brokers, and recruiters:\n\n- Free / Starter: Browse properties, vehicles, and jobs; save favorites; message via in-app chat\n- Basic: Post listings across categories, view video walkthroughs, and receive monthly quotas to reveal seller and job contact details\n- Professional: Higher listing limits, featured visibility boosts, increased contact view quotas, and priority agent support\n- VIP / Enterprise: Unlimited or maximum contact reveals, exclusive access to unlisted VIP properties and luxury vehicles, VIP badge, and premier placement across the platform\n\nContact quotas reset each billing cycle. You can upgrade or renew your plan at any time from the Subscriptions screen.'**
  String get helpPayPlansContent;

  /// No description provided for @helpPayMakeTitle.
  ///
  /// In en, this message translates to:
  /// **'How to pay using Telebirr, CBEBirr, and Cards via Chapa'**
  String get helpPayMakeTitle;

  /// No description provided for @helpPayMakeContent.
  ///
  /// In en, this message translates to:
  /// **'Upgrading your subscription or boosting listings is instant and secure through Chapa, Ethiopia\'s premier payment system:\n\n1. Go to Account > Subscriptions and choose your preferred plan\n2. Tap \"Subscribe Now\" or \"Upgrade Plan\"\n3. You will be redirected to the secure Chapa checkout interface\n4. Select your preferred payment method: Telebirr, CBEBirr, M-Pesa, Awash Birr, or any Ethiopian debit/credit card\n5. Follow the quick on-screen prompt to authorize payment on your mobile wallet or banking app\n6. Upon confirmation, your subscription benefits and contact quotas are activated immediately\n\nWaveMart does not charge hidden fees; the price you see is the exact amount charged.'**
  String get helpPayMakeContent;

  /// No description provided for @helpPaySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment security and data protection'**
  String get helpPaySecurityTitle;

  /// No description provided for @helpPaySecurityContent.
  ///
  /// In en, this message translates to:
  /// **'Your financial security is our highest priority:\n\n1. Bank-Grade Encryption: All payments are processed through Chapa\'s PCI-DSS compliant, end-to-end encrypted infrastructure\n2. No Card Storage: WaveMart never stores, processes, or has access to your banking passwords, card PINs, or wallet credentials\n3. Instant Receipts: Every successful transaction generates a digital receipt with a unique transaction reference code visible in your account\n4. Transaction Assistance: If a payment completes on your wallet or banking app but is not reflected in your account, contact our support team with your transaction reference for immediate verification.'**
  String get helpPaySecurityContent;

  /// No description provided for @helpPayVipTitle.
  ///
  /// In en, this message translates to:
  /// **'VIP badges and Featured listing boosts'**
  String get helpPayVipTitle;

  /// No description provided for @helpPayVipContent.
  ///
  /// In en, this message translates to:
  /// **'Maximize views and sell or hire faster with promotional boosts:\n\n- Featured Listing: Positions your property, vehicle, or job post in the high-traffic \"Featured Listings\" banner on the home screen and highlights it in search results for 30 days\n- VIP Listing: Adds an exclusive golden VIP badge, ranks your listing at the very top of buyer feeds, and alerts serious high-intent buyers\n- Unlisted VIP Deals: Subscribers on VIP plans gain access to premium properties and luxury vehicles not visible to standard users\n\nTo promote a listing: Go to Account > My Listings, open the active listing, select \"Boost / Feature\", choose your promotion type, and confirm.'**
  String get helpPayVipContent;

  /// No description provided for @helpKycWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why identity verification (KYC) is required'**
  String get helpKycWhyTitle;

  /// No description provided for @helpKycWhyContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart complies with Ethiopian e-commerce safety regulations to protect every member of our community:\n\n1. Preventing Scams & Fraud: Verifying real identities ensures fake accounts, phantom listings, and identity theft cannot operate on WaveMart\n2. Verified Seller Badge: Successfully verified accounts earn a blue checkmark badge, boosting buyer confidence and increasing inquiries\n3. Unlocking Publishing Privileges: KYC verification is required before you can publish properties for sale or rent, list commercial vehicles, or recruit talent\n4. Safe Payments & Contracts: High-value transactions demand trust and accountability on both sides.'**
  String get helpKycWhyContent;

  /// No description provided for @helpKycHowTitle.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step identity verification guide'**
  String get helpKycHowTitle;

  /// No description provided for @helpKycHowContent.
  ///
  /// In en, this message translates to:
  /// **'Completing KYC takes less than 2 minutes in the app:\n\n1. Open Account > Verification (KYC)\n2. Choose your document type: Ethiopian National ID (Fayda), Passport, Driver\'s License, or Kebele ID\n3. Take a sharp, well-lit photo of the front and back of your physical card or document\n4. Take a live selfie using your phone\'s camera (make sure your face is clearly visible without sunglasses or hats)\n5. Review your legal name and document number, then tap \"Submit Verification\"\n\nOur automated verification system and verification team review submissions within 24 to 48 hours.'**
  String get helpKycHowContent;

  /// No description provided for @helpKycRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolving KYC rejection issues'**
  String get helpKycRejectTitle;

  /// No description provided for @helpKycRejectContent.
  ///
  /// In en, this message translates to:
  /// **'If your verification was declined, it is usually due to one of these common issues:\n\n1. Blurry or Glared Photos: Details, letters, or photo IDs are unreadable due to low lighting or camera glare\n2. Expired Document: The identification card or passport submitted is past its expiration date\n3. Mismatched Information: The name entered in your profile does not match the legal name printed on the document\n4. Unclear Selfie: The selfie photo is dark, cropped, or does not clearly match the photo on your official ID\n5. Incomplete Images: Corners or edges of the physical document are cropped out\n\nHow to fix: Go to Verification (KYC), tap \"Resubmit Documents\", retake sharp, well-lit photos of the full document, take a new clear selfie, and submit again.'**
  String get helpKycRejectContent;

  /// No description provided for @helpSafePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy and data protection'**
  String get helpSafePrivacyTitle;

  /// No description provided for @helpSafePrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart strictly respects your personal privacy and safeguards your data:\n\n1. Information We Collect: Basic account profile (name, phone number, email), verified listing specifications, and direct customer support logs\n2. Privacy by Default: Your private phone number and email are concealed on public listings until a verified buyer utilizes a contact reveal\n3. Zero Data Selling: We do not sell, rent, or lease your personal information to advertisers or external marketing brokers\n4. Strict Confidentiality: Documents submitted for KYC verification are stored in secure, encrypted storage and accessed exclusively for compliance verification\n\nRead our full Privacy Policy on our website or reach out to support@wavemart.et for data questions.'**
  String get helpSafePrivacyContent;

  /// No description provided for @helpSafeReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting suspicious activity and getting help'**
  String get helpSafeReportTitle;

  /// No description provided for @helpSafeReportContent.
  ///
  /// In en, this message translates to:
  /// **'We take marketplace safety seriously and provide immediate tools to keep your experience secure:\n\n1. In-App Reporting: Tap the three dots (menu) or \"Report\" on any property, vehicle, or job detail screen to flag suspicious pricing, fake images, or improper conduct\n2. Never Send Advance Money: Never wire advance deposits, broker commissions, or booking fees to individuals before physically inspecting the property or vehicle\n3. Emergency Support Line: Reach our dedicated customer safety team directly at +251 981 41 81 81\n4. Email Support: Email support@wavemart.et with screenshots and details; our trust & safety team investigates and responds within 24 hours\n\nTogether, we keep WaveMart the safest marketplace in Ethiopia.'**
  String get helpSafeReportContent;

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

  /// No description provided for @profileStatsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileStatsFavorites;

  /// No description provided for @profileMyInterests.
  ///
  /// In en, this message translates to:
  /// **'My Interests'**
  String get profileMyInterests;

  /// No description provided for @profileMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get profileMale;

  /// No description provided for @profileFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get profileFemale;

  /// No description provided for @profileFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get profileFirstName;

  /// No description provided for @profileLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get profileLastName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get profileGender;

  /// No description provided for @profileEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get profileEmailRequired;

  /// No description provided for @profileEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get profileEmailInvalid;

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

  /// No description provided for @kycTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get kycTakePhoto;

  /// No description provided for @kycChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get kycChooseGallery;

  /// No description provided for @kycConnectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get kycConnectionErrorTitle;

  /// No description provided for @kycConnectionErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your KYC status. Please check your connection and try again.'**
  String get kycConnectionErrorSubtitle;

  /// No description provided for @kycRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get kycRetry;

  /// No description provided for @kycVerifyPhoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We need to verify your phone number before proceeding'**
  String get kycVerifyPhoneSubtitle;

  /// No description provided for @kycPhoneNumberMinDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 7 digits'**
  String get kycPhoneNumberMinDigits;

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

  /// No description provided for @searchUnder5M.
  ///
  /// In en, this message translates to:
  /// **'Under 5M'**
  String get searchUnder5M;

  /// No description provided for @search5M10M.
  ///
  /// In en, this message translates to:
  /// **'5M - 10M'**
  String get search5M10M;

  /// No description provided for @search10M50M.
  ///
  /// In en, this message translates to:
  /// **'10M - 50M'**
  String get search10M50M;

  /// No description provided for @search50M100M.
  ///
  /// In en, this message translates to:
  /// **'50M - 100M'**
  String get search50M100M;

  /// No description provided for @search100MPlus.
  ///
  /// In en, this message translates to:
  /// **'100M+'**
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

  /// No description provided for @searchSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchSortNewest;

  /// No description provided for @searchSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get searchSortOldest;

  /// No description provided for @searchSortPriceLow.
  ///
  /// In en, this message translates to:
  /// **'Price ↑'**
  String get searchSortPriceLow;

  /// No description provided for @searchSortPriceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price ↓'**
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

  /// No description provided for @listingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get listingContinue;

  /// No description provided for @listingYearBuilt.
  ///
  /// In en, this message translates to:
  /// **'Year Built'**
  String get listingYearBuilt;

  /// No description provided for @listingPostedForOtherOwner.
  ///
  /// In en, this message translates to:
  /// **'Posted for other owner'**
  String get listingPostedForOtherOwner;

  /// No description provided for @listingOwnerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get listingOwnerName;

  /// No description provided for @listingOwnerPhone.
  ///
  /// In en, this message translates to:
  /// **'Owner Phone Number'**
  String get listingOwnerPhone;

  /// No description provided for @listingOwnerNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the owner\'s name'**
  String get listingOwnerNameRequired;

  /// No description provided for @listingOwnerPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the owner\'s phone number'**
  String get listingOwnerPhoneRequired;

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

  /// No description provided for @listingVideoMaxSize.
  ///
  /// In en, this message translates to:
  /// **'Max 100MB'**
  String get listingVideoMaxSize;

  /// No description provided for @listingExistingFile.
  ///
  /// In en, this message translates to:
  /// **'Current: {name}'**
  String listingExistingFile(Object name);

  /// No description provided for @listingListingType.
  ///
  /// In en, this message translates to:
  /// **'Listing Type'**
  String get listingListingType;

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

  /// No description provided for @listingPhotosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s)'**
  String listingPhotosCount(Object count);

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

  /// No description provided for @listingFacing3Directions.
  ///
  /// In en, this message translates to:
  /// **'Facing 3 Directions'**
  String get listingFacing3Directions;

  /// No description provided for @listingFacingAllDirections.
  ///
  /// In en, this message translates to:
  /// **'Facing All Directions'**
  String get listingFacingAllDirections;

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

  /// No description provided for @listingIsTransferable.
  ///
  /// In en, this message translates to:
  /// **'Transferable'**
  String get listingIsTransferable;

  /// No description provided for @listingTransferable.
  ///
  /// In en, this message translates to:
  /// **'Transferable'**
  String get listingTransferable;

  /// No description provided for @listingNotTransferable.
  ///
  /// In en, this message translates to:
  /// **'Not Transferable'**
  String get listingNotTransferable;

  /// No description provided for @listingTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add'**
  String get listingTapToAdd;

  /// No description provided for @listingImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} image(s) selected'**
  String listingImagesSelected(Object count);

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

  /// No description provided for @listingCooperative140.
  ///
  /// In en, this message translates to:
  /// **'Cooperative (140m²)'**
  String get listingCooperative140;

  /// No description provided for @listingCooperative70.
  ///
  /// In en, this message translates to:
  /// **'Cooperative (70m²)'**
  String get listingCooperative70;

  /// No description provided for @listingMarketPlace.
  ///
  /// In en, this message translates to:
  /// **'Market Place'**
  String get listingMarketPlace;

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
  /// **'Sale'**
  String get listingSale;

  /// No description provided for @listingRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get listingRent;

  /// No description provided for @listingForSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get listingForSale;

  /// No description provided for @listingForRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get listingForRent;

  /// No description provided for @listingVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get listingVerified;

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
  /// **'Create new Listing'**
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

  /// No description provided for @listingsKeyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get listingsKeyFeatures;

  /// No description provided for @listingsImInterested.
  ///
  /// In en, this message translates to:
  /// **'Contact with Agent'**
  String get listingsImInterested;

  /// No description provided for @listingsInterestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Interest Accepted'**
  String get listingsInterestAccepted;

  /// No description provided for @listingsInterestPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get listingsInterestPending;

  /// No description provided for @listingsInterestRejected.
  ///
  /// In en, this message translates to:
  /// **'Interest Rejected'**
  String get listingsInterestRejected;

  /// No description provided for @listingsDefaultInterestMessage.
  ///
  /// In en, this message translates to:
  /// **'I am interested!'**
  String get listingsDefaultInterestMessage;

  /// No description provided for @callIncoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming call...'**
  String get callIncoming;

  /// No description provided for @callAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get callAccept;

  /// No description provided for @callDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get callDecline;

  /// No description provided for @jitsiCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio Call'**
  String get jitsiCallTitle;

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

  /// No description provided for @listingsVideoOptimizing.
  ///
  /// In en, this message translates to:
  /// **'Optimizing video…'**
  String get listingsVideoOptimizing;

  /// No description provided for @listingsViewOriginal.
  ///
  /// In en, this message translates to:
  /// **'View original video'**
  String get listingsViewOriginal;

  /// No description provided for @listingsNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get listingsNoDescription;

  /// No description provided for @listingsSimilarListings.
  ///
  /// In en, this message translates to:
  /// **'Similar Listings'**
  String get listingsSimilarListings;

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

  /// No description provided for @listingIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Listing #{id}'**
  String listingIdLabel(Object id);

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

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String ordersCount(Object count);

  /// No description provided for @ordersDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get ordersDetailTitle;

  /// No description provided for @ordersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmpty;

  /// No description provided for @ordersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Submit your property requirements to get started'**
  String get ordersEmptySubtitle;

  /// No description provided for @ordersCreate.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get ordersCreate;

  /// No description provided for @ordersStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ordersStatusActive;

  /// No description provided for @ordersStatusFulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get ordersStatusFulfilled;

  /// No description provided for @ordersStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get ordersStatusCancelled;

  /// No description provided for @ordersTypeHouse.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get ordersTypeHouse;

  /// No description provided for @ordersTypeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get ordersTypeLand;

  /// No description provided for @ordersTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get ordersTypeLabel;

  /// No description provided for @ordersListingType.
  ///
  /// In en, this message translates to:
  /// **'I want to'**
  String get ordersListingType;

  /// No description provided for @ordersBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get ordersBuy;

  /// No description provided for @ordersRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get ordersRent;

  /// No description provided for @ordersHoldingType.
  ///
  /// In en, this message translates to:
  /// **'Holding Type'**
  String get ordersHoldingType;

  /// No description provided for @ordersSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get ordersSelect;

  /// No description provided for @ordersFacing.
  ///
  /// In en, this message translates to:
  /// **'Facing Direction'**
  String get ordersFacing;

  /// No description provided for @ordersBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget (ETB)'**
  String get ordersBudget;

  /// No description provided for @ordersMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get ordersMin;

  /// No description provided for @ordersMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get ordersMax;

  /// No description provided for @ordersArea.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get ordersArea;

  /// No description provided for @ordersDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get ordersDescription;

  /// No description provided for @ordersDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Size, features, requirements...'**
  String get ordersDescriptionHint;

  /// No description provided for @ordersSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Order'**
  String get ordersSubmit;

  /// No description provided for @ordersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get ordersCancel;

  /// No description provided for @ordersCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order?'**
  String get ordersCancelConfirm;

  /// No description provided for @ordersCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order canceled'**
  String get ordersCancelled;

  /// No description provided for @ordersCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get ordersCreated;

  /// No description provided for @ordersLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get ordersLocation;

  /// No description provided for @ordersSuggestionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suggestions yet. An admin will suggest matching properties here.'**
  String get ordersSuggestionsEmpty;

  /// No description provided for @ordersSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested Properties'**
  String get ordersSuggestions;

  /// No description provided for @ordersSuggestionsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get ordersSuggestionsViewDetails;

  /// No description provided for @ordersSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An admin has suggested these properties for you.'**
  String get ordersSuggestionsSubtitle;

  /// No description provided for @ordersSuggestionsAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get ordersSuggestionsAccept;

  /// No description provided for @ordersSuggestionsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get ordersSuggestionsDecline;

  /// No description provided for @ordersSuggestionsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get ordersSuggestionsAccepted;

  /// No description provided for @ordersSuggestionsDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get ordersSuggestionsDeclined;

  /// No description provided for @ordersSuggestionsAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Suggestion accepted. An admin will follow up with you.'**
  String get ordersSuggestionsAcceptedMessage;

  /// No description provided for @ordersSuggestionsDeclinedMessage.
  ///
  /// In en, this message translates to:
  /// **'Suggestion declined.'**
  String get ordersSuggestionsDeclinedMessage;

  /// No description provided for @ordersSuggestionsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to process suggestion.'**
  String get ordersSuggestionsError;

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

  /// No description provided for @messagesUnread.
  ///
  /// In en, this message translates to:
  /// **'unread'**
  String get messagesUnread;

  /// No description provided for @messagesUnreadMessages.
  ///
  /// In en, this message translates to:
  /// **'Unread messages'**
  String get messagesUnreadMessages;

  /// No description provided for @messagesSwitchContext.
  ///
  /// In en, this message translates to:
  /// **'Switch Context'**
  String get messagesSwitchContext;

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

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is permanent and cannot be undone. All your data, listings, and messages will be removed.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get settingsDeleteAccountSuccess;

  /// No description provided for @listingEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Listing'**
  String get listingEditTitle;

  /// No description provided for @listingEditCooldownActive.
  ///
  /// In en, this message translates to:
  /// **'Listings can only be edited once every 14 days.'**
  String get listingEditCooldownActive;

  /// No description provided for @listingMediaLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Locked'**
  String get listingMediaLockedTitle;

  /// No description provided for @listingMediaLockedDesc.
  ///
  /// In en, this message translates to:
  /// **'Media cannot be modified after listing creation.'**
  String get listingMediaLockedDesc;

  /// No description provided for @listingDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Listing'**
  String get listingDeleteConfirmTitle;

  /// No description provided for @listingDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this listing? This action cannot be undone.'**
  String get listingDeleteConfirmMessage;

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

  /// No description provided for @authEnterPhonePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get authEnterPhonePrompt;

  /// No description provided for @authEnterOtpPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit OTP'**
  String get authEnterOtpPrompt;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Wavemart'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Trusted Property Marketplace'**
  String get authWelcomeSubtitle;

  /// No description provided for @authOtpSentMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {phone}'**
  String authOtpSentMessage(Object phone);

  /// No description provided for @authOtpSentEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String authOtpSentEmailMessage(Object email);

  /// No description provided for @authResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String authResendCountdown(Object seconds);

  /// No description provided for @authChangeNumber.
  ///
  /// In en, this message translates to:
  /// **'Change Number'**
  String get authChangeNumber;

  /// No description provided for @authChangeNumberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your phone number?'**
  String get authChangeNumberConfirm;

  /// No description provided for @authExitLogin.
  ///
  /// In en, this message translates to:
  /// **'Exit Login'**
  String get authExitLogin;

  /// No description provided for @authExitLoginConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the login process?'**
  String get authExitLoginConfirm;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccount;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get authCreateAccount;

  /// No description provided for @authJoinMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Join Your Trusted Property Marketplace'**
  String get authJoinMarketplace;

  /// No description provided for @authPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get authPersonalInfo;

  /// No description provided for @authVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Phone'**
  String get authVerifyPhone;

  /// No description provided for @authVerifyAndCreate.
  ///
  /// In en, this message translates to:
  /// **'Verify & Create Account'**
  String get authVerifyAndCreate;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authWelcomeBack;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get authAlreadyHaveAccount;

  /// No description provided for @authCancelRegistration.
  ///
  /// In en, this message translates to:
  /// **'Cancel registration?'**
  String get authCancelRegistration;

  /// No description provided for @authFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first name'**
  String get authFirstNameRequired;

  /// No description provided for @authLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your last name'**
  String get authLastNameRequired;

  /// No description provided for @authPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get authPhoneRequired;

  /// No description provided for @authSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get authSelectGender;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get authNetworkError;

  /// No description provided for @subscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionsTitle;

  /// No description provided for @subscriptionsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get subscriptionsCurrentPlan;

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

  /// No description provided for @subscriptionsChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get subscriptionsChoosePlan;

  /// No description provided for @subscriptionsSelectPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a plan that fits your needs. Upgrade anytime.'**
  String get subscriptionsSelectPlanSubtitle;

  /// No description provided for @subscriptionsListings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get subscriptionsListings;

  /// No description provided for @subscriptionsRentalListings.
  ///
  /// In en, this message translates to:
  /// **'Rental Listings'**
  String get subscriptionsRentalListings;

  /// No description provided for @subscriptionsRentalVehicles.
  ///
  /// In en, this message translates to:
  /// **'Rental Vehicles'**
  String get subscriptionsRentalVehicles;

  /// No description provided for @subscriptionsFeaturedListings.
  ///
  /// In en, this message translates to:
  /// **'Featured Listings'**
  String get subscriptionsFeaturedListings;

  /// No description provided for @subscriptionsDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String subscriptionsDaysLeft(Object count);

  /// No description provided for @subscriptionsFreeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Free plan activated successfully!'**
  String get subscriptionsFreeSuccess;

  /// No description provided for @subscriptionsExpiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on {date}'**
  String subscriptionsExpiresOn(Object date);

  /// No description provided for @subscriptionsCancelledOn.
  ///
  /// In en, this message translates to:
  /// **'Cancelled on {date}'**
  String subscriptionsCancelledOn(Object date);

  /// No description provided for @subscriptionsExpiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on {date}'**
  String subscriptionsExpiredOn(Object date);

  /// No description provided for @subscriptionsFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get subscriptionsFeatures;

  /// No description provided for @subscriptionsNoPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No active subscription plans available at this time.'**
  String get subscriptionsNoPlansAvailable;

  /// No description provided for @subscriptionsOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get subscriptionsOrders;

  /// No description provided for @subscriptionsContactViews.
  ///
  /// In en, this message translates to:
  /// **'Contact Views'**
  String get subscriptionsContactViews;

  /// No description provided for @subscriptionsManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get subscriptionsManage;

  /// No description provided for @subscriptionsRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew Plan'**
  String get subscriptionsRenew;

  /// No description provided for @subscriptionsFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free Trial: {planName}'**
  String subscriptionsFreeTrial(Object planName);

  /// No description provided for @subscriptionsStartFreeTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial?'**
  String get subscriptionsStartFreeTrialTitle;

  /// No description provided for @subscriptionsStartFreeTrialPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start your {days}-day free trial on {planName}? One trial per account.'**
  String subscriptionsStartFreeTrialPrompt(Object days, Object planName);

  /// No description provided for @subscriptionsStartTrialButton.
  ///
  /// In en, this message translates to:
  /// **'Start Trial'**
  String get subscriptionsStartTrialButton;

  /// No description provided for @subscriptionsStartTrialDaysButton.
  ///
  /// In en, this message translates to:
  /// **'Start {days}-day Free Trial'**
  String subscriptionsStartTrialDaysButton(Object days);

  /// No description provided for @subscriptionsUpgradeOff.
  ///
  /// In en, this message translates to:
  /// **'Upgrade {percent}% off'**
  String subscriptionsUpgradeOff(Object percent);

  /// No description provided for @subscriptionsPromoOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}% off'**
  String subscriptionsPromoOff(Object percent);

  /// No description provided for @subscriptionsPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted. We\'ll notify you when it confirms.'**
  String get subscriptionsPaymentPending;

  /// No description provided for @subscriptionPaymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled. You can try again anytime.'**
  String get subscriptionPaymentCancelled;

  /// No description provided for @subscriptionsPoweredByChapa.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed securely by Chapa'**
  String get subscriptionsPoweredByChapa;

  /// No description provided for @subscriptionsVipAccess.
  ///
  /// In en, this message translates to:
  /// **'VIP Access'**
  String get subscriptionsVipAccess;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will see updates here when something happens'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @paymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payment history yet'**
  String get paymentsEmpty;

  /// No description provided for @paymentsRef.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get paymentsRef;

  /// No description provided for @paymentsUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get paymentsUnknownDate;

  /// No description provided for @paymentsSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription Payment'**
  String get paymentsSubscription;

  /// No description provided for @paymentsFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured Listing'**
  String get paymentsFeatured;

  /// No description provided for @paymentsDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct Payment'**
  String get paymentsDirect;

  /// No description provided for @paymentsGeneral.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentsGeneral;

  /// No description provided for @messageRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get messageRetry;

  /// No description provided for @messageDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get messageDismiss;

  /// No description provided for @messageNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get messageNetworkTitle;

  /// No description provided for @messageNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get messageNetworkSubtitle;

  /// No description provided for @messageEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing Here'**
  String get messageEmptyTitle;

  /// No description provided for @messageEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'There\'s nothing to show right now.'**
  String get messageEmptySubtitle;

  /// No description provided for @messageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get messageErrorTitle;

  /// No description provided for @messageErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete your request.'**
  String get messageErrorSubtitle;

  /// No description provided for @messageSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get messageSuccessTitle;

  /// No description provided for @messageSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your action was completed successfully.'**
  String get messageSuccessSubtitle;

  /// No description provided for @messageInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get messageInfoTitle;

  /// No description provided for @messageInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is some important information.'**
  String get messageInfoSubtitle;

  /// No description provided for @messageWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get messageWarningTitle;

  /// No description provided for @messageWarningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please review this important message.'**
  String get messageWarningSubtitle;

  /// No description provided for @listingUpgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get listingUpgradeNow;

  /// No description provided for @listingFeatureNow.
  ///
  /// In en, this message translates to:
  /// **'Feature Now'**
  String get listingFeatureNow;

  /// No description provided for @listingViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get listingViewPlans;

  /// No description provided for @listingFeatureThis.
  ///
  /// In en, this message translates to:
  /// **'Feature this Listing'**
  String get listingFeatureThis;

  /// No description provided for @listingUnfeature.
  ///
  /// In en, this message translates to:
  /// **'Unfeature'**
  String get listingUnfeature;

  /// No description provided for @listingUnfeatureConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfeature Listing?'**
  String get listingUnfeatureConfirmTitle;

  /// No description provided for @listingUnfeatureConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove the featured status? You will need to use another quota slot to re-feature it.'**
  String get listingUnfeatureConfirmMessage;

  /// No description provided for @commonGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get commonGoodMorning;

  /// No description provided for @commonGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get commonGoodAfternoon;

  /// No description provided for @commonGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get commonGoodEvening;

  /// No description provided for @errorLoadingListings.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Listings'**
  String get errorLoadingListings;

  /// No description provided for @errorLoadingPayments.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Payments'**
  String get errorLoadingPayments;

  /// No description provided for @errorLoadingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Notifications'**
  String get errorLoadingNotifications;

  /// No description provided for @errorLoadingFavorites.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Favorites'**
  String get errorLoadingFavorites;

  /// No description provided for @errorLoadingConversations.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Conversations'**
  String get errorLoadingConversations;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Messages'**
  String get errorLoadingMessages;

  /// No description provided for @errorSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription Error'**
  String get errorSubscription;

  /// No description provided for @errorJoinCall.
  ///
  /// In en, this message translates to:
  /// **'Failed to join call: {error}'**
  String errorJoinCall(Object error);

  /// No description provided for @subscriptionPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get subscriptionPaymentSuccess;

  /// No description provided for @subscriptionUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String subscriptionUnexpectedError(Object error);

  /// No description provided for @subscriptionRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscriptionRequiredTitle;

  /// No description provided for @subscriptionRequiredListingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription with posting a listing feature.'**
  String get subscriptionRequiredListingSubtitle;

  /// No description provided for @subscriptionRequiredDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription with access to view property details and contact owners.'**
  String get subscriptionRequiredDetailsSubtitle;

  /// No description provided for @subscriptionRequiredOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to create an order.'**
  String get subscriptionRequiredOrderSubtitle;

  /// No description provided for @subscriptionLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your listing limit. Upgrade your subscription to post more listings.'**
  String get subscriptionLimitReached;

  /// No description provided for @subscriptionLimitReachedRental.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your rental listing limit. Upgrade your subscription to post more rentals.'**
  String get subscriptionLimitReachedRental;

  /// No description provided for @subscriptionLimitReachedRentalVehicle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached your vehicle rental limit. Upgrade your subscription to post more rentals.'**
  String get subscriptionLimitReachedRentalVehicle;

  /// No description provided for @subscriptionLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing Limit Reached'**
  String get subscriptionLimitReachedTitle;

  /// No description provided for @kycRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification Required'**
  String get kycRequiredTitle;

  /// No description provided for @kycPendingSubtitleReview.
  ///
  /// In en, this message translates to:
  /// **'Your KYC verification is still pending review. You can post a listing once it\'s approved.'**
  String get kycPendingSubtitleReview;

  /// No description provided for @kycRequiredSubtitlePost.
  ///
  /// In en, this message translates to:
  /// **'You need to complete identity verification (KYC) before you can post a listing.'**
  String get kycRequiredSubtitlePost;

  /// No description provided for @kycVerifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get kycVerifyNow;

  /// No description provided for @orderSelectPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Select the type of property'**
  String get orderSelectPropertyType;

  /// No description provided for @orderBudgetAreaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Budget, area, and transaction type'**
  String get orderBudgetAreaSubtitle;

  /// No description provided for @orderHoldingFacingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Holding type and facing direction'**
  String get orderHoldingFacingSubtitle;

  /// No description provided for @orderDescriptionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe the property you need in detail'**
  String get orderDescriptionSubtitle;

  /// No description provided for @orderRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get orderRequired;

  /// No description provided for @orderUpTo.
  ///
  /// In en, this message translates to:
  /// **'Up to {price} {unit}'**
  String orderUpTo(Object price, Object unit);

  /// No description provided for @listingErrorPropertyTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Property type is required'**
  String get listingErrorPropertyTypeRequired;

  /// No description provided for @listingErrorHoldingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Holding type is required'**
  String get listingErrorHoldingTypeRequired;

  /// No description provided for @listingErrorListingTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Listing type is required'**
  String get listingErrorListingTypeRequired;

  /// No description provided for @listingErrorUseTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Use type is required'**
  String get listingErrorUseTypeRequired;

  /// No description provided for @listingErrorAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a complete address'**
  String get listingErrorAddressRequired;

  /// No description provided for @listingErrorMinPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get listingErrorMinPrice;

  /// No description provided for @listingPricePerAgreement.
  ///
  /// In en, this message translates to:
  /// **'Per Agreement'**
  String get listingPricePerAgreement;

  /// No description provided for @listingErrorLeasedYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Leased year is required'**
  String get listingErrorLeasedYearRequired;

  /// No description provided for @listingErrorCooperativeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cooperative name is required'**
  String get listingErrorCooperativeNameRequired;

  /// No description provided for @listingErrorCooperativeCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Cooperative code is required'**
  String get listingErrorCooperativeCodeRequired;

  /// No description provided for @listingErrorRoomsRequired.
  ///
  /// In en, this message translates to:
  /// **'Total rooms is required'**
  String get listingErrorRoomsRequired;

  /// No description provided for @listingErrorHouseTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'House type is required'**
  String get listingErrorHouseTypeRequired;

  /// No description provided for @listingErrorAreaRequired.
  ///
  /// In en, this message translates to:
  /// **'Total area is required'**
  String get listingErrorAreaRequired;

  /// No description provided for @listingErrorDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get listingErrorDescriptionRequired;

  /// No description provided for @listingErrorImageRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one property image is required'**
  String get listingErrorImageRequired;

  /// No description provided for @listingErrorSitePlanRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one site plan is required'**
  String get listingErrorSitePlanRequired;

  /// No description provided for @listingErrorVideoRequired.
  ///
  /// In en, this message translates to:
  /// **'A video tour is required'**
  String get listingErrorVideoRequired;

  /// No description provided for @listingErrorOwnershipProofRequired.
  ///
  /// In en, this message translates to:
  /// **'Ownership proof is required for cooperative properties'**
  String get listingErrorOwnershipProofRequired;

  /// No description provided for @listingErrorTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms & Conditions'**
  String get listingErrorTermsRequired;

  /// No description provided for @listingErrorTaxYearRange.
  ///
  /// In en, this message translates to:
  /// **'Tax paid year must be between {min} and {max}'**
  String listingErrorTaxYearRange(Object max, Object min);

  /// No description provided for @listingErrorYearBuiltRange.
  ///
  /// In en, this message translates to:
  /// **'Year built must be between {min} and {max}'**
  String listingErrorYearBuiltRange(Object max, Object min);

  /// No description provided for @notificationJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationJustNow;

  /// No description provided for @listingUpgradeToFeature.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Feature'**
  String get listingUpgradeToFeature;

  /// No description provided for @listingUpgradeToVip.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to VIP'**
  String get listingUpgradeToVip;

  /// No description provided for @subscriptionRequiredFeatureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription with featured listing access to feature this listing.'**
  String get subscriptionRequiredFeatureSubtitle;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get errorConnection;

  /// No description provided for @commonBrowseProperties.
  ///
  /// In en, this message translates to:
  /// **'Browse Properties'**
  String get commonBrowseProperties;

  /// No description provided for @subscriptionPaymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get subscriptionPaymentFailedTitle;

  /// No description provided for @subscriptionPaymentFailedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your transaction was not completed. Would you like to try again?'**
  String get subscriptionPaymentFailedSubtitle;

  /// No description provided for @subscriptionTechnicalFailureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The payment gateway could not be reached. Please check your connection.'**
  String get subscriptionTechnicalFailureSubtitle;

  /// No description provided for @messagesWith.
  ///
  /// In en, this message translates to:
  /// **'with {name}'**
  String messagesWith(Object name);

  /// No description provided for @errorJoinCallGeneric.
  ///
  /// In en, this message translates to:
  /// **'Cannot open join link'**
  String get errorJoinCallGeneric;

  /// No description provided for @errorVideoLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get errorVideoLoad;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get statusCancelled;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get statusSuccess;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get statusRefunded;

  /// No description provided for @connectivityOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get connectivityOffline;

  /// No description provided for @connectivityConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connectivityConnecting;

  /// No description provided for @connectivityOnline.
  ///
  /// In en, this message translates to:
  /// **'Back Online'**
  String get connectivityOnline;

  /// No description provided for @markAsVipTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as VIP?'**
  String get markAsVipTitle;

  /// No description provided for @markAsVip.
  ///
  /// In en, this message translates to:
  /// **'Mark as VIP'**
  String get markAsVip;

  /// No description provided for @markAsVipMessage.
  ///
  /// In en, this message translates to:
  /// **'Your listing will be highlighted with a VIP badge hidden from regular users.'**
  String get markAsVipMessage;

  /// No description provided for @upgradeToContact.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Contact'**
  String get upgradeToContact;

  /// No description provided for @listingsRevealContact.
  ///
  /// In en, this message translates to:
  /// **'Reveal seller Contact'**
  String get listingsRevealContact;

  /// No description provided for @listingsRevealing.
  ///
  /// In en, this message translates to:
  /// **'Revealing...'**
  String get listingsRevealing;

  /// No description provided for @listingsSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller'**
  String get listingsSeller;

  /// No description provided for @listingsContactViewsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {max} contact views remaining this period'**
  String listingsContactViewsRemaining(int remaining, int max);

  /// No description provided for @ordersLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Limit Reached'**
  String get ordersLimitTitle;

  /// No description provided for @ordersLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of orders for your current plan. Upgrade to create more orders.'**
  String get ordersLimitMessage;

  /// No description provided for @ordersUpgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get ordersUpgradePlan;

  /// No description provided for @subscriptionVideoUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to watch property videos'**
  String get subscriptionVideoUpgrade;

  /// No description provided for @subscriptionPlanNotSupportedListing.
  ///
  /// In en, this message translates to:
  /// **'Your current plan does not support creating listings.'**
  String get subscriptionPlanNotSupportedListing;

  /// No description provided for @subscriptionPlanNotSupportedListingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please upgrade to a plan that supports listing creation.'**
  String get subscriptionPlanNotSupportedListingSubtitle;

  /// No description provided for @subscriptionPlanNotSupportedOrder.
  ///
  /// In en, this message translates to:
  /// **'Your current plan does not support creating orders.'**
  String get subscriptionPlanNotSupportedOrder;

  /// No description provided for @subscriptionPlanNotSupportedOrderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please upgrade to a plan that supports order creation.'**
  String get subscriptionPlanNotSupportedOrderSubtitle;

  /// No description provided for @subscriptionsShowPricesIn.
  ///
  /// In en, this message translates to:
  /// **'Show prices in:'**
  String get subscriptionsShowPricesIn;

  /// No description provided for @subscriptionsDowngradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Plan?'**
  String get subscriptionsDowngradeTitle;

  /// No description provided for @subscriptionsDowngradeMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current plan\'s features (listing slots, featured listings, VIP access, and other benefits) will not carry over to the new plan. Any unused benefits from your current plan may be lost.'**
  String get subscriptionsDowngradeMessage;

  /// No description provided for @subscriptionsDowngradeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch Anyway'**
  String get subscriptionsDowngradeConfirm;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonTryAgain;

  /// No description provided for @commonDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// No description provided for @networkErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get networkErrorTitle;

  /// No description provided for @networkErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get networkErrorMessage;

  /// No description provided for @statusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get statusFrozen;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get statusSold;

  /// No description provided for @statusRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get statusRented;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your Trusted Property Marketplace'**
  String get splashSubtitle;

  /// No description provided for @homeRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get homeRefreshing;

  /// No description provided for @shareListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shared from Wavemart - Your Trusted Property Marketplace'**
  String get shareListingTitle;

  /// No description provided for @shareListingMessage.
  ///
  /// In en, this message translates to:
  /// **'Check out this property on Wavemart: '**
  String get shareListingMessage;

  /// No description provided for @authOrSeparator.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOrSeparator;

  /// No description provided for @commonSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get commonSigningIn;

  /// No description provided for @commonSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get commonSignInWithGoogle;

  /// No description provided for @webviewDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get webviewDone;

  /// No description provided for @webviewConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to payment gateway...'**
  String get webviewConnecting;

  /// No description provided for @webviewActivating.
  ///
  /// In en, this message translates to:
  /// **'Activating your plan...'**
  String get webviewActivating;

  /// No description provided for @webviewPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get webviewPleaseWait;

  /// No description provided for @webviewGatewayTimeout.
  ///
  /// In en, this message translates to:
  /// **'Gateway Timeout'**
  String get webviewGatewayTimeout;

  /// No description provided for @webviewFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment URL'**
  String get webviewFailedToLoad;

  /// No description provided for @settingsDeleteRedirect.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to our website to complete the deletion process.'**
  String get settingsDeleteRedirect;

  /// No description provided for @commonFailedOpenOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to open order'**
  String get commonFailedOpenOrder;

  /// No description provided for @jitsiSettingUpCall.
  ///
  /// In en, this message translates to:
  /// **'Setting up call...'**
  String get jitsiSettingUpCall;

  /// No description provided for @submissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed'**
  String get submissionFailed;

  /// No description provided for @submissionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft & Exit'**
  String get submissionSaveDraft;

  /// No description provided for @submissionExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get submissionExit;

  /// No description provided for @submissionGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get submissionGoBack;

  /// No description provided for @authFailedIdToken.
  ///
  /// In en, this message translates to:
  /// **'Failed to get ID token'**
  String get authFailedIdToken;

  /// No description provided for @helpErrorYoutube.
  ///
  /// In en, this message translates to:
  /// **'Could not open YouTube'**
  String get helpErrorYoutube;

  /// No description provided for @settingsBrowserErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not open browser. Please visit {url}'**
  String settingsBrowserErrorMessage(Object url);

  /// No description provided for @interestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No interests yet'**
  String get interestsEmpty;

  /// No description provided for @interestsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Properties you express interest in will appear here'**
  String get interestsEmptySubtitle;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateBlockingMessage.
  ///
  /// In en, this message translates to:
  /// **'This version of the app is no longer supported. Please update to continue using Wavemart.'**
  String get updateBlockingMessage;

  /// No description provided for @updateAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'A new version{versionSuffix} is available.'**
  String updateAvailableMessage(Object versionSuffix);

  /// No description provided for @updateVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version: '**
  String get updateVersionLabel;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updateWhatsNew.
  ///
  /// In en, this message translates to:
  /// **'What\'s New'**
  String get updateWhatsNew;

  /// No description provided for @routerInvalidRoute.
  ///
  /// In en, this message translates to:
  /// **'Invalid route'**
  String get routerInvalidRoute;

  /// No description provided for @reportListing.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get reportListing;

  /// No description provided for @reportReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReason;

  /// No description provided for @reportSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason...'**
  String get reportSelectReason;

  /// No description provided for @reportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportSpam;

  /// No description provided for @reportFake.
  ///
  /// In en, this message translates to:
  /// **'Fake listing'**
  String get reportFake;

  /// No description provided for @reportWrongCategory.
  ///
  /// In en, this message translates to:
  /// **'Wrong category'**
  String get reportWrongCategory;

  /// No description provided for @reportDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate listing'**
  String get reportDuplicate;

  /// No description provided for @reportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportInappropriate;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get reportDescription;

  /// No description provided for @reportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide additional details...'**
  String get reportDescriptionHint;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportSubmit;

  /// No description provided for @reportSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get reportSubmitting;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you.'**
  String get reportSuccess;

  /// No description provided for @reportErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report. Please try again.'**
  String get reportErrorGeneric;

  /// No description provided for @listingCar.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get listingCar;

  /// No description provided for @listingCarPlural.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get listingCarPlural;

  /// No description provided for @listingVehicleCategory.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Category'**
  String get listingVehicleCategory;

  /// No description provided for @listingMake.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get listingMake;

  /// No description provided for @listingMakeModel.
  ///
  /// In en, this message translates to:
  /// **'Make & Model'**
  String get listingMakeModel;

  /// No description provided for @listingModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get listingModel;

  /// No description provided for @listingYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get listingYear;

  /// No description provided for @listingTransmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get listingTransmission;

  /// No description provided for @listingFuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get listingFuelType;

  /// No description provided for @listingBodyType.
  ///
  /// In en, this message translates to:
  /// **'Body Type'**
  String get listingBodyType;

  /// No description provided for @listingMileage.
  ///
  /// In en, this message translates to:
  /// **'Mileage'**
  String get listingMileage;

  /// No description provided for @listingMileageMax.
  ///
  /// In en, this message translates to:
  /// **'Max Mileage (km)'**
  String get listingMileageMax;

  /// No description provided for @listingCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get listingCondition;

  /// No description provided for @listingEngineSize.
  ///
  /// In en, this message translates to:
  /// **'Engine Size'**
  String get listingEngineSize;

  /// No description provided for @listingColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get listingColor;

  /// No description provided for @searchSortYearDesc.
  ///
  /// In en, this message translates to:
  /// **'Year ↓'**
  String get searchSortYearDesc;

  /// No description provided for @searchSortYearAsc.
  ///
  /// In en, this message translates to:
  /// **'Year ↑'**
  String get searchSortYearAsc;

  /// No description provided for @searchSortMileageLow.
  ///
  /// In en, this message translates to:
  /// **'Mileage ↓'**
  String get searchSortMileageLow;

  /// No description provided for @searchSortMileageHigh.
  ///
  /// In en, this message translates to:
  /// **'Mileage ↑'**
  String get searchSortMileageHigh;

  /// No description provided for @searchLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get searchLocation;

  /// No description provided for @searchAnyMake.
  ///
  /// In en, this message translates to:
  /// **'Any Make'**
  String get searchAnyMake;

  /// No description provided for @searchAnyModel.
  ///
  /// In en, this message translates to:
  /// **'Any Model'**
  String get searchAnyModel;

  /// No description provided for @searchCars.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles'**
  String get searchCars;

  /// No description provided for @commonIsRequired.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get commonIsRequired;

  /// No description provided for @carLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a location (Kebele)'**
  String get carLocationRequired;

  /// No description provided for @carTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms'**
  String get carTermsRequired;

  /// No description provided for @carRentalPriceNegotiable.
  ///
  /// In en, this message translates to:
  /// **'By Negotiation'**
  String get carRentalPriceNegotiable;

  /// No description provided for @listingPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get listingPricing;

  /// No description provided for @listingOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get listingOptions;

  /// No description provided for @listingDoors.
  ///
  /// In en, this message translates to:
  /// **'Doors'**
  String get listingDoors;

  /// No description provided for @listingSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get listingSeats;

  /// No description provided for @listingVin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get listingVin;

  /// No description provided for @listingCreated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle listing created'**
  String get listingCreated;

  /// No description provided for @listingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Vehicle listing updated'**
  String get listingUpdated;

  /// No description provided for @updateListing.
  ///
  /// In en, this message translates to:
  /// **'Update Listing'**
  String get updateListing;

  /// No description provided for @carAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get carAddPhoto;

  /// No description provided for @carPhotoFormatHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG, WebP — Max 10MB each'**
  String get carPhotoFormatHint;

  /// No description provided for @carEnterMakeName.
  ///
  /// In en, this message translates to:
  /// **'Enter make name'**
  String get carEnterMakeName;

  /// No description provided for @carEnterModelName.
  ///
  /// In en, this message translates to:
  /// **'Enter model name'**
  String get carEnterModelName;

  /// No description provided for @carFileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'{name} exceeds 10MB limit'**
  String carFileTooLarge(Object name);

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @mediaTapToPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview'**
  String get mediaTapToPreview;

  /// No description provided for @mediaImageFormatHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG, WebP'**
  String get mediaImageFormatHint;

  /// No description provided for @mediaSitePlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Site plan image'**
  String get mediaSitePlanSubtitle;

  /// No description provided for @mediaExistingSitePlan.
  ///
  /// In en, this message translates to:
  /// **'Existing site plan'**
  String get mediaExistingSitePlan;

  /// No description provided for @mediaOwnershipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ownership document'**
  String get mediaOwnershipSubtitle;

  /// No description provided for @mediaVideoFormatHint.
  ///
  /// In en, this message translates to:
  /// **'MP4, max 5 minutes'**
  String get mediaVideoFormatHint;

  /// No description provided for @mediaExistingVideo.
  ///
  /// In en, this message translates to:
  /// **'Existing video'**
  String get mediaExistingVideo;

  /// No description provided for @mediaPlayPreview.
  ///
  /// In en, this message translates to:
  /// **'Play Preview'**
  String get mediaPlayPreview;

  /// No description provided for @mediaPicture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get mediaPicture;

  /// No description provided for @mediaPictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get mediaPictures;

  /// No description provided for @mediaSitePlan.
  ///
  /// In en, this message translates to:
  /// **'Site Plan'**
  String get mediaSitePlan;

  /// No description provided for @mediaOwnershipProof.
  ///
  /// In en, this message translates to:
  /// **'Ownership Proof'**
  String get mediaOwnershipProof;

  /// No description provided for @mediaVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mediaVideo;

  /// No description provided for @mediaFileSizeError.
  ///
  /// In en, this message translates to:
  /// **'{label} exceeds {limit} limit. Please choose a smaller file.'**
  String mediaFileSizeError(Object label, Object limit);

  /// No description provided for @mediaImagesLocked.
  ///
  /// In en, this message translates to:
  /// **'Images cannot be modified after submission.'**
  String get mediaImagesLocked;

  /// No description provided for @carVipSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a VIP badge for VIP only visibility'**
  String get carVipSubtitle;

  /// No description provided for @carCustomFeatures.
  ///
  /// In en, this message translates to:
  /// **'Custom features'**
  String get carCustomFeatures;

  /// No description provided for @submissionStepValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating data'**
  String get submissionStepValidating;

  /// No description provided for @submissionStepUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading files'**
  String get submissionStepUploading;

  /// No description provided for @submissionStepSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving listing'**
  String get submissionStepSaving;

  /// No description provided for @submissionValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating data...'**
  String get submissionValidating;

  /// No description provided for @submissionUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading files...'**
  String get submissionUploading;

  /// No description provided for @submissionSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving listing...'**
  String get submissionSaving;

  /// No description provided for @submissionSavingChanges.
  ///
  /// In en, this message translates to:
  /// **'Saving changes...'**
  String get submissionSavingChanges;

  /// No description provided for @submissionSubmittingTitle.
  ///
  /// In en, this message translates to:
  /// **'Submitting Your Listing'**
  String get submissionSubmittingTitle;

  /// No description provided for @submissionSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing Submitted!'**
  String get submissionSuccessTitle;

  /// No description provided for @submissionPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Your listing is pending approval. We\'ll notify you once it\'s live.'**
  String get submissionPendingApproval;

  /// No description provided for @submissionViewListings.
  ///
  /// In en, this message translates to:
  /// **'View My Listings'**
  String get submissionViewListings;

  /// No description provided for @submissionCreateAnother.
  ///
  /// In en, this message translates to:
  /// **'Create Another'**
  String get submissionCreateAnother;

  /// No description provided for @submissionCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your listing has been submitted.'**
  String get submissionCreatedMessage;

  /// No description provided for @submissionUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Listing updated successfully.'**
  String get submissionUpdatedMessage;

  /// No description provided for @submissionConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Your data has been saved.'**
  String get submissionConnectionLost;

  /// No description provided for @submissionRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Your data has been saved.'**
  String get submissionRequestTimedOut;

  /// No description provided for @submissionErrorDefault.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get submissionErrorDefault;

  /// No description provided for @listingDetail.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get listingDetail;

  /// No description provided for @listingSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications'**
  String get listingSpecifications;

  /// No description provided for @carContactSeller.
  ///
  /// In en, this message translates to:
  /// **'Contact Seller'**
  String get carContactSeller;

  /// No description provided for @carCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get carCall;

  /// No description provided for @carCallHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to call the seller'**
  String get carCallHint;

  /// No description provided for @carWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get carWhatsapp;

  /// No description provided for @carWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get carWhatsappHint;

  /// No description provided for @carTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get carTelegram;

  /// No description provided for @carTelegramHint.
  ///
  /// In en, this message translates to:
  /// **'Chat on Telegram'**
  String get carTelegramHint;

  /// No description provided for @conditionNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get conditionNew;

  /// No description provided for @conditionUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get conditionUsed;

  /// No description provided for @categoryCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get categoryCar;

  /// No description provided for @categoryMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get categoryMotorcycle;

  /// No description provided for @categoryBicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get categoryBicycle;

  /// No description provided for @categoryConstructionEquipment.
  ///
  /// In en, this message translates to:
  /// **'Construction Equipment'**
  String get categoryConstructionEquipment;

  /// No description provided for @bodyTypeSedan.
  ///
  /// In en, this message translates to:
  /// **'Sedan'**
  String get bodyTypeSedan;

  /// No description provided for @bodyTypeSuv.
  ///
  /// In en, this message translates to:
  /// **'SUV'**
  String get bodyTypeSuv;

  /// No description provided for @bodyTypeHatchback.
  ///
  /// In en, this message translates to:
  /// **'Hatchback'**
  String get bodyTypeHatchback;

  /// No description provided for @bodyTypePickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get bodyTypePickup;

  /// No description provided for @bodyTypeTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get bodyTypeTruck;

  /// No description provided for @bodyTypeVan.
  ///
  /// In en, this message translates to:
  /// **'Van'**
  String get bodyTypeVan;

  /// No description provided for @bodyTypeMinibus.
  ///
  /// In en, this message translates to:
  /// **'Minibus'**
  String get bodyTypeMinibus;

  /// No description provided for @bodyTypeCoupe.
  ///
  /// In en, this message translates to:
  /// **'Coupe'**
  String get bodyTypeCoupe;

  /// No description provided for @bodyTypeConvertible.
  ///
  /// In en, this message translates to:
  /// **'Convertible'**
  String get bodyTypeConvertible;

  /// No description provided for @bodyTypeStationWagon.
  ///
  /// In en, this message translates to:
  /// **'Station Wagon'**
  String get bodyTypeStationWagon;

  /// No description provided for @bodyTypeStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get bodyTypeStandard;

  /// No description provided for @bodyTypeCruiser.
  ///
  /// In en, this message translates to:
  /// **'Cruiser'**
  String get bodyTypeCruiser;

  /// No description provided for @bodyTypeSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get bodyTypeSport;

  /// No description provided for @bodyTypeTouring.
  ///
  /// In en, this message translates to:
  /// **'Touring'**
  String get bodyTypeTouring;

  /// No description provided for @bodyTypeDualSport.
  ///
  /// In en, this message translates to:
  /// **'Dual Sport'**
  String get bodyTypeDualSport;

  /// No description provided for @bodyTypeScooter.
  ///
  /// In en, this message translates to:
  /// **'Scooter'**
  String get bodyTypeScooter;

  /// No description provided for @bodyTypeMoped.
  ///
  /// In en, this message translates to:
  /// **'Moped'**
  String get bodyTypeMoped;

  /// No description provided for @bodyTypeMountain.
  ///
  /// In en, this message translates to:
  /// **'Mountain'**
  String get bodyTypeMountain;

  /// No description provided for @bodyTypeRoad.
  ///
  /// In en, this message translates to:
  /// **'Road'**
  String get bodyTypeRoad;

  /// No description provided for @bodyTypeHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get bodyTypeHybrid;

  /// No description provided for @bodyTypeCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get bodyTypeCity;

  /// No description provided for @bodyTypeElectric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get bodyTypeElectric;

  /// No description provided for @bodyTypeFolding.
  ///
  /// In en, this message translates to:
  /// **'Folding'**
  String get bodyTypeFolding;

  /// No description provided for @bodyTypeExcavator.
  ///
  /// In en, this message translates to:
  /// **'Excavator'**
  String get bodyTypeExcavator;

  /// No description provided for @bodyTypeBulldozer.
  ///
  /// In en, this message translates to:
  /// **'Bulldozer'**
  String get bodyTypeBulldozer;

  /// No description provided for @bodyTypeLoader.
  ///
  /// In en, this message translates to:
  /// **'Loader'**
  String get bodyTypeLoader;

  /// No description provided for @bodyTypeCrane.
  ///
  /// In en, this message translates to:
  /// **'Crane'**
  String get bodyTypeCrane;

  /// No description provided for @bodyTypeForklift.
  ///
  /// In en, this message translates to:
  /// **'Forklift'**
  String get bodyTypeForklift;

  /// No description provided for @bodyTypeRoller.
  ///
  /// In en, this message translates to:
  /// **'Roller'**
  String get bodyTypeRoller;

  /// No description provided for @bodyTypeDumper.
  ///
  /// In en, this message translates to:
  /// **'Dumper'**
  String get bodyTypeDumper;

  /// No description provided for @bodyTypeGenerator.
  ///
  /// In en, this message translates to:
  /// **'Generator'**
  String get bodyTypeGenerator;

  /// No description provided for @bodyTypeCompressor.
  ///
  /// In en, this message translates to:
  /// **'Compressor'**
  String get bodyTypeCompressor;

  /// No description provided for @featureAc.
  ///
  /// In en, this message translates to:
  /// **'AC'**
  String get featureAc;

  /// No description provided for @featureAbs.
  ///
  /// In en, this message translates to:
  /// **'ABS'**
  String get featureAbs;

  /// No description provided for @featureAirbag.
  ///
  /// In en, this message translates to:
  /// **'Airbag'**
  String get featureAirbag;

  /// No description provided for @featureAlarmSystem.
  ///
  /// In en, this message translates to:
  /// **'Alarm System'**
  String get featureAlarmSystem;

  /// No description provided for @featureAlloyWheels.
  ///
  /// In en, this message translates to:
  /// **'Alloy Wheels'**
  String get featureAlloyWheels;

  /// No description provided for @featureBackupCamera.
  ///
  /// In en, this message translates to:
  /// **'Backup Camera'**
  String get featureBackupCamera;

  /// No description provided for @featureBasket.
  ///
  /// In en, this message translates to:
  /// **'Basket'**
  String get featureBasket;

  /// No description provided for @featureBatteryIncluded.
  ///
  /// In en, this message translates to:
  /// **'Battery Included'**
  String get featureBatteryIncluded;

  /// No description provided for @featureBell.
  ///
  /// In en, this message translates to:
  /// **'Bell'**
  String get featureBell;

  /// No description provided for @featureBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get featureBluetooth;

  /// No description provided for @featureCentralLocking.
  ///
  /// In en, this message translates to:
  /// **'Central Locking'**
  String get featureCentralLocking;

  /// No description provided for @featureCrashBars.
  ///
  /// In en, this message translates to:
  /// **'Crash Bars'**
  String get featureCrashBars;

  /// No description provided for @featureCruiseControl.
  ///
  /// In en, this message translates to:
  /// **'Cruise Control'**
  String get featureCruiseControl;

  /// No description provided for @featureDiscBrakes.
  ///
  /// In en, this message translates to:
  /// **'Disc Brakes'**
  String get featureDiscBrakes;

  /// No description provided for @featureElectricAssist.
  ///
  /// In en, this message translates to:
  /// **'Electric Assist'**
  String get featureElectricAssist;

  /// No description provided for @featureFenders.
  ///
  /// In en, this message translates to:
  /// **'Fenders'**
  String get featureFenders;

  /// No description provided for @featureFogLights.
  ///
  /// In en, this message translates to:
  /// **'Fog Lights'**
  String get featureFogLights;

  /// No description provided for @featureFrontSuspension.
  ///
  /// In en, this message translates to:
  /// **'Front Suspension'**
  String get featureFrontSuspension;

  /// No description provided for @featureGps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get featureGps;

  /// No description provided for @featureHeatedGrips.
  ///
  /// In en, this message translates to:
  /// **'Heated Grips'**
  String get featureHeatedGrips;

  /// No description provided for @featureHeatedSeat.
  ///
  /// In en, this message translates to:
  /// **'Heated Seat'**
  String get featureHeatedSeat;

  /// No description provided for @featureHydraulicThumb.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic Thumb'**
  String get featureHydraulicThumb;

  /// No description provided for @featureKickstand.
  ///
  /// In en, this message translates to:
  /// **'Kickstand'**
  String get featureKickstand;

  /// No description provided for @featureLeatherSeats.
  ///
  /// In en, this message translates to:
  /// **'Leather Seats'**
  String get featureLeatherSeats;

  /// No description provided for @featureLedLights.
  ///
  /// In en, this message translates to:
  /// **'LED Lights'**
  String get featureLedLights;

  /// No description provided for @featureLockIncluded.
  ///
  /// In en, this message translates to:
  /// **'Lock Included'**
  String get featureLockIncluded;

  /// No description provided for @featureLongReachArm.
  ///
  /// In en, this message translates to:
  /// **'Long Reach Arm'**
  String get featureLongReachArm;

  /// No description provided for @featureLowHours.
  ///
  /// In en, this message translates to:
  /// **'Low Hours'**
  String get featureLowHours;

  /// No description provided for @featureLuggageRack.
  ///
  /// In en, this message translates to:
  /// **'Luggage Rack'**
  String get featureLuggageRack;

  /// No description provided for @featureNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get featureNavigation;

  /// No description provided for @featurePowerSteering.
  ///
  /// In en, this message translates to:
  /// **'Power Steering'**
  String get featurePowerSteering;

  /// No description provided for @featurePowerWindows.
  ///
  /// In en, this message translates to:
  /// **'Power Windows'**
  String get featurePowerWindows;

  /// No description provided for @featureQuickAttach.
  ///
  /// In en, this message translates to:
  /// **'Quick Attach'**
  String get featureQuickAttach;

  /// No description provided for @featureRearSuspension.
  ///
  /// In en, this message translates to:
  /// **'Rear Suspension'**
  String get featureRearSuspension;

  /// No description provided for @featureRops.
  ///
  /// In en, this message translates to:
  /// **'ROPS'**
  String get featureRops;

  /// No description provided for @featureRoofRack.
  ///
  /// In en, this message translates to:
  /// **'Roof Rack'**
  String get featureRoofRack;

  /// No description provided for @featureServiceRecords.
  ///
  /// In en, this message translates to:
  /// **'Service Records'**
  String get featureServiceRecords;

  /// No description provided for @featureSidePanniers.
  ///
  /// In en, this message translates to:
  /// **'Side Panniers'**
  String get featureSidePanniers;

  /// No description provided for @featureSunroof.
  ///
  /// In en, this message translates to:
  /// **'Sunroof'**
  String get featureSunroof;

  /// No description provided for @featureTopCase.
  ///
  /// In en, this message translates to:
  /// **'Top Case'**
  String get featureTopCase;

  /// No description provided for @featureTowBar.
  ///
  /// In en, this message translates to:
  /// **'Tow Bar'**
  String get featureTowBar;

  /// No description provided for @featureTrackVsWheels.
  ///
  /// In en, this message translates to:
  /// **'Track vs Wheels'**
  String get featureTrackVsWheels;

  /// No description provided for @featureUsbCharger.
  ///
  /// In en, this message translates to:
  /// **'USB Charger'**
  String get featureUsbCharger;

  /// No description provided for @featureWindshield.
  ///
  /// In en, this message translates to:
  /// **'Windshield'**
  String get featureWindshield;

  /// No description provided for @listingPostedByAgent.
  ///
  /// In en, this message translates to:
  /// **'Posted by agent'**
  String get listingPostedByAgent;

  /// No description provided for @listingPostedByAgentLabel.
  ///
  /// In en, this message translates to:
  /// **'This listing is posted by an agent'**
  String get listingPostedByAgentLabel;

  /// No description provided for @orderPostedByAgentLabel.
  ///
  /// In en, this message translates to:
  /// **'This order is posted by an agent'**
  String get orderPostedByAgentLabel;

  /// No description provided for @agentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Agent ID'**
  String get agentIdLabel;

  /// No description provided for @agentIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Agent ID is required when posted by agent'**
  String get agentIdRequired;

  /// No description provided for @agentIdEmpty.
  ///
  /// In en, this message translates to:
  /// **'Agent ID is required'**
  String get agentIdEmpty;

  /// No description provided for @listingErrorTaxPaidYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Tax paid year is required'**
  String get listingErrorTaxPaidYearRequired;

  /// No description provided for @listingErrorAcquisitionClarificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Acquisition clarification is required'**
  String get listingErrorAcquisitionClarificationRequired;

  /// No description provided for @listingErrorLeasePricePerSqmRequired.
  ///
  /// In en, this message translates to:
  /// **'Lease price per sqm is required'**
  String get listingErrorLeasePricePerSqmRequired;

  /// No description provided for @listingErrorBuildTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Build type is required'**
  String get listingErrorBuildTypeRequired;

  /// No description provided for @listingErrorAnnualPaymentRequired.
  ///
  /// In en, this message translates to:
  /// **'Annual payment is required'**
  String get listingErrorAnnualPaymentRequired;

  /// No description provided for @listingErrorBuildingStatusRequired.
  ///
  /// In en, this message translates to:
  /// **'Building status is required'**
  String get listingErrorBuildingStatusRequired;

  /// No description provided for @listingErrorDebtAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Debt amount is required'**
  String get listingErrorDebtAmountRequired;

  /// No description provided for @listingErrorYearBuiltRequired.
  ///
  /// In en, this message translates to:
  /// **'Year built is required'**
  String get listingErrorYearBuiltRequired;

  /// No description provided for @jobAddEducation.
  ///
  /// In en, this message translates to:
  /// **'Add Education'**
  String get jobAddEducation;

  /// No description provided for @jobAddExperience.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get jobAddExperience;

  /// No description provided for @jobAll.
  ///
  /// In en, this message translates to:
  /// **'All Jobs'**
  String get jobAll;

  /// No description provided for @jobApplicationDeadlineOptional.
  ///
  /// In en, this message translates to:
  /// **'Application Deadline (Optional)'**
  String get jobApplicationDeadlineOptional;

  /// No description provided for @jobBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get jobBasicInfo;

  /// No description provided for @jobBrowseTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse Jobs'**
  String get jobBrowseTitle;

  /// No description provided for @jobCategoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get jobCategoryEducation;

  /// No description provided for @jobCategoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get jobCategoryFinance;

  /// No description provided for @jobCategoryHealthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get jobCategoryHealthcare;

  /// No description provided for @jobCategoryIT.
  ///
  /// In en, this message translates to:
  /// **'IT & Software'**
  String get jobCategoryIT;

  /// No description provided for @jobCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get jobCategoryOther;

  /// No description provided for @jobClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get jobClear;

  /// No description provided for @jobCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get jobCompanyName;

  /// No description provided for @jobCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get jobCreateButton;

  /// No description provided for @jobCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get jobCreateTitle;

  /// No description provided for @jobDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get jobDeadline;

  /// No description provided for @jobDeadlinePast.
  ///
  /// In en, this message translates to:
  /// **'Deadline cannot be before today'**
  String get jobDeadlinePast;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get jobDescription;

  /// No description provided for @jobEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Job'**
  String get jobEditTitle;

  /// No description provided for @jobEducationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get jobEducationLevel;

  /// No description provided for @jobEducationOtherHint.
  ///
  /// In en, this message translates to:
  /// **'Enter education level'**
  String get jobEducationOtherHint;

  /// No description provided for @jobEmployerInfo.
  ///
  /// In en, this message translates to:
  /// **'Employer Info'**
  String get jobEmployerInfo;

  /// No description provided for @jobFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured Job'**
  String get jobFeatured;

  /// No description provided for @jobFieldOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Field of Study'**
  String get jobFieldOfStudy;

  /// No description provided for @jobFieldOfStudyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Computer Science, Accounting'**
  String get jobFieldOfStudyHint;

  /// No description provided for @jobFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter Jobs'**
  String get jobFilter;

  /// No description provided for @jobFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get jobFixed;

  /// No description provided for @jobImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get jobImages;

  /// No description provided for @jobIndividualPoster.
  ///
  /// In en, this message translates to:
  /// **'Individual Poster'**
  String get jobIndividualPoster;

  /// No description provided for @jobJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get jobJob;

  /// No description provided for @jobJobCategory.
  ///
  /// In en, this message translates to:
  /// **'Job Category'**
  String get jobJobCategory;

  /// No description provided for @jobJobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobJobDetails;

  /// No description provided for @jobJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobJobTitle;

  /// No description provided for @jobJobType.
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get jobJobType;

  /// No description provided for @jobLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get jobLocation;

  /// No description provided for @jobLocationImages.
  ///
  /// In en, this message translates to:
  /// **'Location Images'**
  String get jobLocationImages;

  /// No description provided for @jobLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get jobLocationPlaceholder;

  /// No description provided for @jobLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get jobLogin;

  /// No description provided for @jobLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get jobLoginRequired;

  /// No description provided for @jobMetaDescription.
  ///
  /// In en, this message translates to:
  /// **'Find the best jobs in Ethiopia on Wavemart.'**
  String get jobMetaDescription;

  /// No description provided for @jobMyJobs.
  ///
  /// In en, this message translates to:
  /// **'My Jobs'**
  String get jobMyJobs;

  /// No description provided for @jobNegotiable.
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get jobNegotiable;

  /// No description provided for @jobNoDeadline.
  ///
  /// In en, this message translates to:
  /// **'No deadline'**
  String get jobNoDeadline;

  /// No description provided for @jobNoEducationAdded.
  ///
  /// In en, this message translates to:
  /// **'No specific education requirements added.'**
  String get jobNoEducationAdded;

  /// No description provided for @jobNoExperienceAdded.
  ///
  /// In en, this message translates to:
  /// **'No specific experience requirements added.'**
  String get jobNoExperienceAdded;

  /// No description provided for @jobNoPhotos.
  ///
  /// In en, this message translates to:
  /// **'No Photos'**
  String get jobNoPhotos;

  /// No description provided for @jobNoResultsDescription.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any jobs matching your criteria.'**
  String get jobNoResultsDescription;

  /// No description provided for @jobNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Jobs Found'**
  String get jobNoResultsTitle;

  /// No description provided for @jobPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get jobPhotos;

  /// No description provided for @jobPositions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get jobPositions;

  /// No description provided for @jobPostingAsCompany.
  ///
  /// In en, this message translates to:
  /// **'Posting as Company?'**
  String get jobPostingAsCompany;

  /// No description provided for @jobRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get jobRange;

  /// No description provided for @jobRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get jobRequirements;

  /// No description provided for @jobSalaryAndReqs.
  ///
  /// In en, this message translates to:
  /// **'Salary & Requirements'**
  String get jobSalaryAndReqs;

  /// No description provided for @jobSalaryMax.
  ///
  /// In en, this message translates to:
  /// **'Max Salary'**
  String get jobSalaryMax;

  /// No description provided for @jobSalaryMin.
  ///
  /// In en, this message translates to:
  /// **'Min Salary'**
  String get jobSalaryMin;

  /// No description provided for @jobSalaryPerAgreement.
  ///
  /// In en, this message translates to:
  /// **'Per Agreement'**
  String get jobSalaryPerAgreement;

  /// No description provided for @jobSalaryType.
  ///
  /// In en, this message translates to:
  /// **'Salary Type'**
  String get jobSalaryType;

  /// No description provided for @jobSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get jobSelect;

  /// No description provided for @jobSimilarJobs.
  ///
  /// In en, this message translates to:
  /// **'Similar Jobs'**
  String get jobSimilarJobs;

  /// No description provided for @jobSpecificLocation.
  ///
  /// In en, this message translates to:
  /// **'Specific Location'**
  String get jobSpecificLocation;

  /// No description provided for @jobSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get jobSubmit;

  /// No description provided for @jobTypeContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get jobTypeContract;

  /// No description provided for @jobTypeFullTime.
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get jobTypeFullTime;

  /// No description provided for @jobTypeInternship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get jobTypeInternship;

  /// No description provided for @jobTypePartTime.
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get jobTypePartTime;

  /// No description provided for @jobUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get jobUpdate;

  /// No description provided for @jobValidYearsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter valid years (e.g. 2)'**
  String get jobValidYearsRequired;

  /// No description provided for @jobYearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get jobYearsOfExperience;

  /// No description provided for @jobContactEmployer.
  ///
  /// In en, this message translates to:
  /// **'Contact Employer'**
  String get jobContactEmployer;

  /// No description provided for @jobCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get jobCall;

  /// No description provided for @jobCallHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to call the employer'**
  String get jobCallHint;

  /// No description provided for @jobWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get jobWhatsapp;

  /// No description provided for @jobWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get jobWhatsappHint;

  /// No description provided for @jobTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get jobTelegram;

  /// No description provided for @jobTelegramHint.
  ///
  /// In en, this message translates to:
  /// **'Chat on Telegram'**
  String get jobTelegramHint;

  /// No description provided for @jobSeekerMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get jobSeekerMessage;

  /// No description provided for @homeJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get homeJobs;

  /// No description provided for @homeSeekers.
  ///
  /// In en, this message translates to:
  /// **'Seekers'**
  String get homeSeekers;

  /// No description provided for @seekersTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Seekers'**
  String get seekersTitle;

  /// No description provided for @seekersNoProfiles.
  ///
  /// In en, this message translates to:
  /// **'No profiles found'**
  String get seekersNoProfiles;

  /// No description provided for @seekersNoResults.
  ///
  /// In en, this message translates to:
  /// **'No job seekers found'**
  String get seekersNoResults;

  /// No description provided for @jobSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search jobs...'**
  String get jobSearchPlaceholder;

  /// No description provided for @jobNotFound.
  ///
  /// In en, this message translates to:
  /// **'Job not found'**
  String get jobNotFound;

  /// No description provided for @jobRequiredGender.
  ///
  /// In en, this message translates to:
  /// **'Required Gender'**
  String get jobRequiredGender;

  /// No description provided for @jobPostingLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Posting Limit Reached'**
  String get jobPostingLimitTitle;

  /// No description provided for @jobPostingLimitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have reached your limit. Upgrade plan to post more jobs.'**
  String get jobPostingLimitSubtitle;

  /// No description provided for @seekerProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get seekerProfileDetails;

  /// No description provided for @seekerExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get seekerExperience;

  /// No description provided for @seekerNoEducationAdded.
  ///
  /// In en, this message translates to:
  /// **'No education credentials added yet.'**
  String get seekerNoEducationAdded;

  /// No description provided for @seekerNoExperienceAdded.
  ///
  /// In en, this message translates to:
  /// **'No work history added yet.'**
  String get seekerNoExperienceAdded;

  /// No description provided for @seekerNoBio.
  ///
  /// In en, this message translates to:
  /// **'No bio provided.'**
  String get seekerNoBio;

  /// No description provided for @seekerAboutBio.
  ///
  /// In en, this message translates to:
  /// **'About / Bio'**
  String get seekerAboutBio;

  /// No description provided for @seekerNoWorkExperience.
  ///
  /// In en, this message translates to:
  /// **'No work experience listed.'**
  String get seekerNoWorkExperience;

  /// No description provided for @seekerPdfDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF Document'**
  String get seekerPdfDocument;

  /// No description provided for @seekerVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get seekerVideo;

  /// No description provided for @seekerWaveMartOptions.
  ///
  /// In en, this message translates to:
  /// **'WaveMart options'**
  String get seekerWaveMartOptions;

  /// No description provided for @seekerContactOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Direct in-app messaging with candidate'**
  String get seekerContactOptionsSubtitle;

  /// No description provided for @listingWaveMartOptions.
  ///
  /// In en, this message translates to:
  /// **'WaveMart options'**
  String get listingWaveMartOptions;

  /// No description provided for @listingMessageSeller.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get listingMessageSeller;

  /// No description provided for @seekerYearsExp.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs exp'**
  String seekerYearsExp(String years);

  /// No description provided for @seekerYearsTotal.
  ///
  /// In en, this message translates to:
  /// **'{years} yrs total'**
  String seekerYearsTotal(String years);

  /// No description provided for @seekerMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Job Profile'**
  String get seekerMyProfile;

  /// No description provided for @seekerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get seekerFullName;

  /// No description provided for @seekerProfessionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Title'**
  String get seekerProfessionalTitle;

  /// No description provided for @seekerMakePublic.
  ///
  /// In en, this message translates to:
  /// **'Make Profile Public'**
  String get seekerMakePublic;

  /// No description provided for @seekerSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get seekerSaveProfile;

  /// No description provided for @seekerProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get seekerProfileSaved;

  /// No description provided for @seekerCv.
  ///
  /// In en, this message translates to:
  /// **'CV'**
  String get seekerCv;

  /// No description provided for @seekerUploadCv.
  ///
  /// In en, this message translates to:
  /// **'Upload CV (Optional)'**
  String get seekerUploadCv;

  /// No description provided for @seekerViewCv.
  ///
  /// In en, this message translates to:
  /// **'View CV'**
  String get seekerViewCv;

  /// No description provided for @listingPerDay.
  ///
  /// In en, this message translates to:
  /// **'/ day'**
  String get listingPerDay;

  /// No description provided for @listingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get listingPerMonth;

  /// No description provided for @listingPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get listingPerYear;

  /// No description provided for @searchUnder15K.
  ///
  /// In en, this message translates to:
  /// **'Under 15K'**
  String get searchUnder15K;

  /// No description provided for @search15K30K.
  ///
  /// In en, this message translates to:
  /// **'15K - 30K'**
  String get search15K30K;

  /// No description provided for @search30K60K.
  ///
  /// In en, this message translates to:
  /// **'30K - 60K'**
  String get search30K60K;

  /// No description provided for @search60K100K.
  ///
  /// In en, this message translates to:
  /// **'60K - 100K'**
  String get search60K100K;

  /// No description provided for @search100KPlus.
  ///
  /// In en, this message translates to:
  /// **'100K+'**
  String get search100KPlus;

  /// No description provided for @listingTypeNotEditable.
  ///
  /// In en, this message translates to:
  /// **'Listing type cannot be changed after creation'**
  String get listingTypeNotEditable;

  /// No description provided for @searchArea.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get searchArea;

  /// No description provided for @searchAreaMin.
  ///
  /// In en, this message translates to:
  /// **'Min area'**
  String get searchAreaMin;

  /// No description provided for @searchAreaMax.
  ///
  /// In en, this message translates to:
  /// **'Max area'**
  String get searchAreaMax;

  /// No description provided for @searchPriceMin.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get searchPriceMin;

  /// No description provided for @searchPriceMax.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get searchPriceMax;

  /// No description provided for @searchCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get searchCustom;

  /// No description provided for @searchSalaryMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum salary (ETB)'**
  String get searchSalaryMin;

  /// No description provided for @searchSeekersPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search job seekers...'**
  String get searchSeekersPlaceholder;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String searchResultsCount(int count);

  /// No description provided for @searchValidationNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get searchValidationNumber;

  /// No description provided for @searchValidationRange.
  ///
  /// In en, this message translates to:
  /// **'Minimum must be less than maximum'**
  String get searchValidationRange;

  /// No description provided for @rentalPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get rentalPeriodDay;

  /// No description provided for @rentalPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get rentalPeriodMonth;

  /// No description provided for @rentalPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get rentalPeriodYear;
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
