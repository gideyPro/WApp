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
  /// **'Try different keywords or browse categories'**
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
  /// **'Watch tutorials, tips & property tours'**
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
  /// **'Property Requests'**
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
  /// **'How to create an account'**
  String get helpAccCreateTitle;

  /// No description provided for @helpAccCreateContent.
  ///
  /// In en, this message translates to:
  /// **'To create an account on WaveMart:\n\n1. Open the app and tap on \"Sign Up\"\n2. Enter your name phone number,email address and other details and submit.\n3. You will receive a 6-digit OTP (One-Time Password)\n4. Enter the OTP to verify your account\n\nOnce registered, you can browse properties, create your own listings, and connect with owners or agents.'**
  String get helpAccCreateContent;

  /// No description provided for @helpAccFavTitle.
  ///
  /// In en, this message translates to:
  /// **'Managing your favorites'**
  String get helpAccFavTitle;

  /// No description provided for @helpAccFavContent.
  ///
  /// In en, this message translates to:
  /// **'To save a property for later:\n\n1. Tap the heart icon on any listing card or on the property detail page\n2. Access your saved items from Account > Favorites\n3. Tap the heart icon again to remove a listing from your favorites\n'**
  String get helpAccFavContent;

  /// No description provided for @helpAccMsgTitle.
  ///
  /// In en, this message translates to:
  /// **'Using in-app messaging'**
  String get helpAccMsgTitle;

  /// No description provided for @helpAccMsgContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart has a built-in messaging system for communicating with property owners and agents:\n\n1. When you express interest in a property, a conversation is automatically created with the agent.\n2. Go to the Account > Messages to view all your conversations\n3. Tap on a conversation to read and send messages\n4. Messages show delivery status with checkmarks (one check = sent, two checks = seen)\n5. You can switch between related conversations using the \"Switch Context\" menu\n\nFor your safety, keep all communication within the app.'**
  String get helpAccMsgContent;

  /// No description provided for @helpListCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'How to post a property listing'**
  String get helpListCreateTitle;

  /// No description provided for @helpListCreateContent.
  ///
  /// In en, this message translates to:
  /// **'To post a property for sale or rent:\n\n1. Tap the \"+\" button in the navigation bar\n2. Choose between \"House\" or \"Land\"\n3. Select if it is for Sale or Rent\n4. Fill in the details: Price, Area (m²), Number of Rooms, etc.\n5. Select the exact location (Region, Zone, Woreda, Kebele)\n6. Upload at least 5 clear photos and a Site Plan document\n7. Accept the terms and tap \"Submit\"\n\nAll listings are reviewed by our moderation team within 24 hours to ensure quality and authenticity.'**
  String get helpListCreateContent;

  /// No description provided for @helpListManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Managing your listings'**
  String get helpListManageTitle;

  /// No description provided for @helpListManageContent.
  ///
  /// In en, this message translates to:
  /// **'To manage or update your property posts:\n\n1. Navigate to My Account > My Listings\n2. View the status of your listings (Active, Pending, Rejected, or Sold)\n3. Tap on a listing to see its full details\n4. Use the Edit button to update information or the Delete button to remove it\n\nNote: Significant changes to an active listing may trigger a re-review by our team.'**
  String get helpListManageContent;

  /// No description provided for @helpListTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for better listings'**
  String get helpListTipsTitle;

  /// No description provided for @helpListTipsContent.
  ///
  /// In en, this message translates to:
  /// **'To make your listing stand out:\n\n1. Use clear, well-lit photos (at least 5 images)\n2. Write a detailed description of the property\n3. Include accurate location details\n4. Set a competitive and fair price\n5. Mention nearby amenities and landmarks\n6. Highlight unique features of the property\n7. Respond promptly to buyer inquiries'**
  String get helpListTipsContent;

  /// No description provided for @helpListVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video tours on listings'**
  String get helpListVideoTitle;

  /// No description provided for @helpListVideoContent.
  ///
  /// In en, this message translates to:
  /// **'Some property listings include a video tour uploaded by the seller:\n\n1. Look for the \"Video Tour\" section on the property detail page\n2. If the video is still processing, you will see a loading indicator\n3. Once ready, tap the video to play it\n4. You can also view the original video if available\n\nVideo tours help you get a better sense of the property before visiting in person. Viewing videos may require an active subscription.'**
  String get helpListVideoContent;

  /// No description provided for @helpListInterestTitle.
  ///
  /// In en, this message translates to:
  /// **'How to express interest in a property'**
  String get helpListInterestTitle;

  /// No description provided for @helpListInterestContent.
  ///
  /// In en, this message translates to:
  /// **'To let a seller know you are interested in their property:\n\n1. Open the property listing detail page\n2. Tap the \"Contact with Agent\" button\n3. Optionally add a message to the seller\n4. Tap \"Submit Interest\" to send your request\n\nThe seller will be notified and can respond. You can track your interest status under Profile > My Interests. Statuses include Pending (waiting for response), Accepted, or Rejected. Some plans require an upgrade to contact sellers.'**
  String get helpListInterestContent;

  /// No description provided for @helpListStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding listing statuses'**
  String get helpListStatusTitle;

  /// No description provided for @helpListStatusContent.
  ///
  /// In en, this message translates to:
  /// **'Each property listing goes through several statuses:\n\n- Pending: Your listing is under review by our moderation team (usually within 24 hours)\n- Active: Your listing is live and visible to buyers\n- Rejected: The listing did not meet our guidelines. Check the reason and resubmit\n- Sold/Rented: The property has been sold or rented\n- Frozen: The listing is temporarily hidden\n\nYou can view the status of your listings under My Account > My Listings.'**
  String get helpListStatusContent;

  /// No description provided for @helpOrdCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'What are Property Requests (Orders)?'**
  String get helpOrdCreateTitle;

  /// No description provided for @helpOrdCreateContent.
  ///
  /// In en, this message translates to:
  /// **'If you cannot find the exact property you are looking for, you can create a Property Request (Order):\n\n1. Go to the \"Orders\" tab and tap \"Create Order\"\n2. Describe the property you need (Type, Budget, Preferred Location)\n3. Our administrators and agents will look for properties matching your criteria\n4. You will receive suggestions directly in your Orders page\n\nThis feature is ideal for buyers with specific requirements who want a personalized search experience.'**
  String get helpOrdCreateContent;

  /// No description provided for @helpOrdManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Handling property suggestions'**
  String get helpOrdManageTitle;

  /// No description provided for @helpOrdManageContent.
  ///
  /// In en, this message translates to:
  /// **'When an administrator finds a property matching your request:\n\n1. You will receive a notification and a suggestion in your Order details\n2. Review the suggested property details and photos\n3. You can \"Accept\" the suggestion to express interest or \"Decline\" it\n4. Once accepted, you can proceed to contact the owner or agent\n\nYou can cancel your property request at any time once you have found what you need.'**
  String get helpOrdManageContent;

  /// No description provided for @helpPayPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership & Subscription plans'**
  String get helpPayPlansTitle;

  /// No description provided for @helpPayPlansContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart offers tiered plans to suit different needs:\n\n- Free Plan: For casual users to browse and post limited listings\n- Basic Plan: For individuals with multiple properties or frequent searches\n- Premium Plan: For professional agents and developers, offering unlimited posts and Featured/VIP status for listings\n\nEach plan increases your visibility and the number of active listings you can maintain simultaneously.'**
  String get helpPayPlansContent;

  /// No description provided for @helpPayMakeTitle.
  ///
  /// In en, this message translates to:
  /// **'How to pay for a subscription'**
  String get helpPayMakeTitle;

  /// No description provided for @helpPayMakeContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart uses Chapa, Ethiopia\'s leading payment gateway, for secure transactions:\n\n1. Select your desired plan from the Subscriptions page\n2. Tap \"Subscribe Now\" or \"Upgrade\"\n3. You will be redirected to the secure Chapa payment page\n4. Pay using Telebirr, CBEBirr, M-Pesa, or any supported bank card\n5. After successful payment, your account features will be updated instantly\n\nAlways ensure you are on the official Chapa payment page before entering any details.'**
  String get helpPayMakeContent;

  /// No description provided for @helpPaySecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment security'**
  String get helpPaySecurityTitle;

  /// No description provided for @helpPaySecurityContent.
  ///
  /// In en, this message translates to:
  /// **'All payments on WaveMart are processed securely through Chapa, a trusted Ethiopian payment gateway.\n\nWe do not store your payment card information. All transactions are encrypted.\n\nIf you encounter any payment-related issues, please contact our support team immediately.'**
  String get helpPaySecurityContent;

  /// No description provided for @helpPayVipTitle.
  ///
  /// In en, this message translates to:
  /// **'VIP & Featured listings'**
  String get helpPayVipTitle;

  /// No description provided for @helpPayVipContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart offers premium visibility options for your listings:\n\n- Featured: Your listing appears in the \"Premium Listings\" section on the home page and stands out in search results for 30 days\n- VIP: Your listing gets a special VIP badge and appears in the \"Premium VIP Properties\" section\n\nTo feature or mark a listing as VIP:\n1. Go to My Account > My Listings\n2. Open your active listing\n3. Tap \"Feature this Listing\" or \"Mark as VIP\"\n4. Confirm your choice\n\nThese features require an active subscription plan that supports them. Upgrade your plan if needed.'**
  String get helpPayVipContent;

  /// No description provided for @helpKycWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why is KYC verification necessary?'**
  String get helpKycWhyTitle;

  /// No description provided for @helpKycWhyContent.
  ///
  /// In en, this message translates to:
  /// **'KYC (Know Your Customer) is a security standard used to verify the identity of our users.\n\nIt is required to:\n- Post property listings (Preventing fake/fraudulent posts)\n- Ensure a safe marketplace for all users\n- Comply with Ethiopian digital commerce regulations\n\nVerified users have a badge on their profile, which significantly increases trust with potential buyers.'**
  String get helpKycWhyContent;

  /// No description provided for @helpKycHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How to verify your identity'**
  String get helpKycHowTitle;

  /// No description provided for @helpKycHowContent.
  ///
  /// In en, this message translates to:
  /// **'To complete your identity verification:\n\n1. Go to Settings > KYC Verification\n2. Choose \"National ID\" or \"Passport\"\n3. Take a clear photo of the front and back of the document\n4. Take a clear selfie while holding the document next to your face\n5. Submit the documents\n\nOur team will review your submission within 48 hours. Ensure the text on your ID is perfectly readable in the photos.'**
  String get helpKycHowContent;

  /// No description provided for @helpKycRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Why was my KYC rejected?'**
  String get helpKycRejectTitle;

  /// No description provided for @helpKycRejectContent.
  ///
  /// In en, this message translates to:
  /// **'Common reasons for KYC rejection:\n\n1. Blurry or unreadable document photos\n2. Document is expired or invalid\n3. Selfie does not clearly show your face and document\n4. Document type does not match selection\n5. Cropped or incomplete document images\n\nTo resubmit:\n- Go to KYC Verification\n- Tap \"Resubmit Documents\"\n- Ensure all photos are clear and well-lit\n- Make sure the entire document is visible'**
  String get helpKycRejectContent;

  /// No description provided for @helpSafeStayTitle.
  ///
  /// In en, this message translates to:
  /// **'Staying safe on WaveMart'**
  String get helpSafeStayTitle;

  /// No description provided for @helpSafePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get helpSafePrivacyTitle;

  /// No description provided for @helpSafePrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'WaveMart respects your privacy and protects your personal data.\n\nWe collect:\n- Account information (name, phone, email)\n- Listing data you provide\n- Usage analytics to improve the app\n\nWe do not:\n- Sell your personal data\n- Share your information with third parties (except for necessary services like payment processing)\n- Store your payment details\n\nFor full details, visit our website or contact support.'**
  String get helpSafePrivacyContent;

  /// No description provided for @helpSafeReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reporting a problem'**
  String get helpSafeReportTitle;

  /// No description provided for @helpSafeReportContent.
  ///
  /// In en, this message translates to:
  /// **'If you encounter any issues:\n\n1. Use the in-app Help Center to find solutions\n2. Contact support via email: support@wavemart.et\n3. Call our support line for urgent issues\n4. Report suspicious listings or users through the listing detail page\n\nWe aim to respond to all inquiries within 24 hours.'**
  String get helpSafeReportContent;

  /// No description provided for @helpSafeCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio calls with owners and agents'**
  String get helpSafeCallTitle;

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

  /// No description provided for @listingRentalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rental Period'**
  String get listingRentalPeriod;

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
  /// **'Welcome to WaveMart'**
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
  /// **'Price must be at least 50,000 ETB'**
  String get listingErrorMinPrice;

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
