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

  static const String authSendOtp = '$apiBase/auth/send-otp';
  static const String authRegisterSendOtp = '$apiBase/auth/register/send-otp';
  static const String authResendOtp = '$apiBase/auth/resend-otp';
  static const String authLogin = '$apiBase/auth/login';
  static const String authRegister = '$apiBase/auth/register';
  static const String authLogout = '$apiBase/auth/logout';
  static const String me = '$apiBase/me';

  static const String listings = '$apiBase/listings';
  static const String listingsFeatured = '$apiBase/listings/featured';
  static const String cars = '$apiBase/cars';
  static const String carsFeatured = '$apiBase/cars/featured';
  static const String jobs = '$apiBase/jobs';
  static const String jobsFeatured = '$apiBase/jobs/featured';

  static String listing(int id) => '$listings/$id';
  static String car(int id) => '$cars/$id';
  static String job(int id) => '$jobs/$id';
}
