import '../api_constants.dart';

/// Endpoint paths and shared limits for the mobile API v2.
///
/// v2 is served alongside the frozen v1 API. Keep every path here so callers
/// never hand-build `/api/v2` strings.
class ApiV2Constants {
  ApiV2Constants._();

  static const String apiBase = '${ApiConstants.baseUrl}/api/v2';

  /// Default page size for cursor-paginated endpoints.
  static const int defaultLimit = 20;

  /// The backend rejects `limit` above 50 with `VALIDATION_FAILED`.
  static const int maxLimit = 50;

  static const String appConfig = '$apiBase/app-config';
  static const String home = '$apiBase/home';
  static const String plans = '$apiBase/plans';
  static const String subscription = '$apiBase/subscription';
  static const String payments = '$apiBase/payments';

  static const String authSendOtp = '$apiBase/auth/send-otp';
  static const String authRegisterSendOtp = '$apiBase/auth/register/send-otp';
  static const String authResendOtp = '$apiBase/auth/resend-otp';
  static const String authLogin = '$apiBase/auth/login';
  static const String authRegister = '$apiBase/auth/register';
  static const String authLogout = '$apiBase/auth/logout';
  static const String me = '$apiBase/me';
  static const String meListings = '$apiBase/me/listings';

  static const String favorites = '$apiBase/favorites';

  static const String notifications = '$apiBase/notifications';
  static const String notificationsUnreadCount = '$notifications/unread-count';
  static const String notificationsReadAll = '$notifications/read-all';

  static const String addressRegions = '$apiBase/addresses/regions';
  static const String addressZones = '$apiBase/addresses/zones';
  static const String addressWoredas = '$apiBase/addresses/woredas';
  static const String addressKebeles = '$apiBase/addresses/kebeles';

  static const String listings = '$apiBase/listings';
  static const String listingsFeatured = '$apiBase/listings/featured';
  static const String cars = '$apiBase/cars';
  static const String carsFeatured = '$apiBase/cars/featured';
  static const String jobs = '$apiBase/jobs';
  static const String jobsFeatured = '$apiBase/jobs/featured';

  static String listing(int id) => '$listings/$id';
  static String car(int id) => '$cars/$id';
  static String job(int id) => '$jobs/$id';

  static String listingSubmit(int id) => '$listings/$id/submit';
  static String listingImages(int id) => '$listings/$id/images';
  static String listingImage(int id, int imageId) =>
      '$listings/$id/images/$imageId';
  static String listingVideo(int id) => '$listings/$id/video';
  static String listingSitePlan(int id) => '$listings/$id/site-plan';
  static String listingDebtDocument(int id) => '$listings/$id/debt-document';
  static String listingOwnershipProof(int id) =>
      '$listings/$id/ownership-proof';
  static String listingFeature(int id) => '$listings/$id/feature';
  static String listingVip(int id) => '$listings/$id/vip';

  static String favorite(int listingId) => '$favorites/$listingId';

  static String notification(int id) => '$notifications/$id';
  static String notificationRead(int id) => '$notifications/$id/read';

  static String planCheckout(int planId) =>
      '$apiBase/subscriptions/$planId/checkout';
  static String planTrial(int planId) => '$apiBase/subscriptions/$planId/trial';

  static String payment(String txRef) =>
      '$payments/${Uri.encodeComponent(txRef)}';
  static String paymentVerify(String txRef) => '${payment(txRef)}/verify';
  static String paymentCancel(String txRef) => '${payment(txRef)}/cancel';

  static const String kyc = '$apiBase/kyc';
  static const String kycPhoneSendOtp = '$kyc/phone/send-otp';
  static const String kycPhoneVerify = '$kyc/phone/verify';
}
