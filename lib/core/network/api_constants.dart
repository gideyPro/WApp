/// API Constants - All endpoint paths for the WaveMart mobile app
///
/// Base URL changes based on environment:
/// - Development: http://10.0.2.2:8000/api (Android emulator)
/// - Production: https://wavemart.et/api
class ApiConstants {
  // Base URLs
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://wavemart.et',
  );
  static const String apiBase = '$baseUrl/api';

  // ==========================================================================
  // 1. AUTHENTICATION ENDPOINTS
  // ==========================================================================
  static const String sendOtp = '$apiBase/auth/send-otp';
  static const String login = '$apiBase/auth/login';
  static const String verifyOtp = '$apiBase/auth/verify-otp';
  static const String resendOtp = '$apiBase/auth/resend-otp';
  static const String register = '$apiBase/auth/register';
  static const String logout = '$apiBase/auth/logout';
  static const String currentUser = '$apiBase/user';

  // ==========================================================================
  // 2. LISTINGS ENDPOINTS
  // ==========================================================================
  static const String listings = '$apiBase/listings';
  static const String listingDetail = '$apiBase/listings'; // + /{id}
  static const String featuredListings = '$apiBase/listings/featured';
  static const String similarListings = '$apiBase/listings'; // + /{id}/similar
  static const String createListing = '$apiBase/listings';
  static const String updateListing = '$apiBase/listings'; // + /{id}
  static const String deleteListing = '$apiBase/listings'; // + /{id}
  static const String featureListing = '$apiBase/listings'; // + /{id}/feature
  static const String processFeatured =
      '$apiBase/listings'; // + /{id}/process-featured
  static const String activateFeatured =
      '$apiBase/listings/activate-featured';

  // ==========================================================================
  // 3. FAVORITES ENDPOINTS
  // ==========================================================================
  static const String favorites = '$apiBase/favorites';
  static const String toggleFavorite = '$apiBase/favorites'; // + /{id}/toggle
  static const String addFavorite = '$apiBase/favorites'; // + /{listing}
  static const String removeFavorite = '$apiBase/favorites'; // + /{listing}

  // ==========================================================================
  // 4. MESSAGES ENDPOINTS
  // ==========================================================================
  static const String messages = '$apiBase/messages';
  static const String fetchConversations = '$apiBase/messages/fetch-list';
  static const String conversation = '$apiBase/messages'; // + /{id}
  static const String fetchMessages = '$apiBase/messages'; // + /{id}/fetch
  static const String sendMessage = '$apiBase/messages'; // + /{id}
  static const String deleteConversation = '$apiBase/messages'; // + /{id}
  static const String startMessageFromListing =
      '$apiBase/listings'; // + /{id}/message
  static const String startDirectMessage = '$apiBase/users'; // + /{id}/message

  // ==========================================================================
  // 5. NOTIFICATIONS ENDPOINTS
  // ==========================================================================
  static const String notifications = '$apiBase/notifications';
  static const String unreadCount = '$apiBase/notifications/unread-count';
  static const String recentNotifications = '$apiBase/notifications/recent';
  static const String markAsRead = '$apiBase/notifications'; // + /{id}/read
  static const String markAllAsRead = '$apiBase/notifications/mark-all-read';
  static const String deleteNotification = '$apiBase/notifications'; // + /{id}

  // ==========================================================================
  // 6. PROFILE ENDPOINTS
  // ==========================================================================
  static const String profile = '$apiBase/profile';
  static const String updateProfile = '$apiBase/profile';
  static const String deleteProfile = '$apiBase/profile';
  static const String publicProfile = '$apiBase/users'; // + /{id}

  // ==========================================================================
  // 7. DASHBOARD ENDPOINTS
  // ==========================================================================
  static const String dashboard = '$apiBase/dashboard';

  // ==========================================================================
  // 8. KYC ENDPOINTS
  // ==========================================================================
  static const String kycStatus = '$apiBase/kyc/status';
  static const String kycSubmit = '$apiBase/kyc';
  static const String kycCreate = '$apiBase/kyc/create';

  // ==========================================================================
  // 9. SUBSCRIPTIONS ENDPOINTS
  // ==========================================================================
  static const String subscriptionPlans = '$apiBase/subscriptions/plans';
  static const String currentSubscription = '$apiBase/subscriptions';
  static const String subscribeToPlan =
      '$apiBase/subscriptions'; // + /{id}/subscribe
  static const String initiateSubscriptionPayment =
      '$apiBase/subscriptions'; // + /{id}/initiate-payment
  static const String processSubscriptionPayment =
      '$apiBase/subscriptions'; // + /{id}/process-payment
  static const String activateSubscription =
      '$apiBase/subscriptions/activate';
  static const String cancelSubscription = '$apiBase/subscriptions/cancel';

  // ==========================================================================
  // 10. PAYMENTS ENDPOINTS
  // ==========================================================================
  static const String payments = '$apiBase/payments';
  static const String paymentDetail = '$apiBase/payments'; // + /{id}
  static const String initializePayment = '$apiBase/payments/initialize';
  static const String verifyPayment = '$apiBase/payments/verify'; // + /{tx_ref}
  static const String paymentSuccess = '$apiBase/payments/success';
  static const String paymentCancel = '$apiBase/payments/cancel';
  static const String paymentCallback = '$apiBase/payment/callback';

  // ==========================================================================
  // 11. INTEREST REQUESTS ENDPOINTS
  // ==========================================================================
  static const String myInterests = '$apiBase/my-interests';
  static const String expressInterest = '$apiBase/listings'; // + /{id}/interest
  static const String cancelInterest = '$apiBase/my-interests'; // + /{id}

  // ==========================================================================
  // 12. CONFERENCES (VIDEO CALLS) ENDPOINTS
  // ==========================================================================
  static const String conferences = '$apiBase/conferences';
  static const String checkIncomingCall = '$apiBase/conferences/check-incoming';
  static const String createConference = '$apiBase/conferences'; // + /{listing}
  static const String startDirectCall =
      '$apiBase/conferences/start-direct'; // + /{conversation}
  static const String conferenceDetail = '$apiBase/conferences'; // + /{id}
  static const String joinConference = '$apiBase/conferences'; // + /{id}/join
  static const String conferenceStatus = '$apiBase/conferences'; // + /{id}/status
  static const String updateConferenceStatus =
      '$apiBase/conferences'; // + /{id}/status
  static const String deleteConference = '$apiBase/conferences'; // + /{id}
  static const String inviteToConference =
      '$apiBase/conferences'; // + /{id}/invite/{user}
  static const String pingConference = '$apiBase/conferences'; // + /{id}/ping

  // ==========================================================================
  // 13. ADDRESS ENDPOINTS (Cascading Dropdowns)
  // ==========================================================================
  static const String regions = '$apiBase/addresses/regions';
  static const String zones = '$apiBase/addresses/zones';
  static const String woredas = '$apiBase/addresses/woredas';
  static const String kebeles = '$apiBase/addresses/kebeles';

  // ==========================================================================
  // 14. HELP CENTER ENDPOINTS
  // ==========================================================================
  static const String helpCenter = '$apiBase/help';
  static const String helpCategory = '$apiBase/help/category'; // + /{slug}
  static const String helpArticle = '$apiBase/help/article'; // + /{slug}
  static const String articleFeedback = '$apiBase/help/article'; // + /{id}/feedback
  static const String helpSearch = '$apiBase/help/search';
  static const String helpFeedback = '$apiBase/help/feedback';
  static const String submitHelpFeedback = '$apiBase/help/feedback';
  static const String helpTickets = '$apiBase/help/tickets';
  static const String createTicket = '$apiBase/help/tickets';
  static const String ticketDetail = '$apiBase/help/tickets'; // + /{number}
  static const String ticketMessage = '$apiBase/help/tickets'; // + /{number}/message
  static const String rateTicket = '$apiBase/help/tickets'; // + /{number}/rate

  // ==========================================================================
  // HEADERS
  // ==========================================================================
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String headerBearer = 'Bearer';
  static const String contentTypeJson = 'application/json';

  // ==========================================================================
  // TIMEOUTS
  // ==========================================================================
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
