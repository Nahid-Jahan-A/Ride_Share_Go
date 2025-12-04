/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RideShareGo';
  static const String appVersion = '1.0.0';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration locationUpdateInterval = Duration(seconds: 5);
  static const Duration driverRequestTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Location
  static const double defaultSearchRadiusKm = 5.0;
  static const double maxSearchRadiusKm = 50.0;
  static const int geoHashPrecision = 6;

  // Trip
  static const int maxTripRequestAttempts = 5;
  static const Duration tripRequestRetryDelay = Duration(seconds: 5);
  static const double minimumFare = 5.0;

  // Ratings
  static const double defaultRating = 5.0;
  static const int minRatingForFeedback = 3;

  // Wallet
  static const double minimumTopUpAmount = 10.0;
  static const double maximumTopUpAmount = 10000.0;
  static const double minimumWithdrawalAmount = 50.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int otpLength = 6;
  static const Duration otpExpiry = Duration(minutes: 5);

  // Cache
  static const Duration cacheDuration = Duration(hours: 24);
  static const Duration locationCacheDuration = Duration(seconds: 30);

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
}

/// Storage keys for local persistence
class StorageKeys {
  StorageKeys._();

  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tenantId = 'tenant_id';
  static const String userType = 'user_type';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastKnownLocation = 'last_known_location';
  static const String savedLocations = 'saved_locations';
  static const String recentSearches = 'recent_searches';
  static const String appTheme = 'app_theme';
  static const String appLanguage = 'app_language';
  static const String pushNotificationsEnabled = 'push_notifications_enabled';
  static const String driverStatus = 'driver_status';
}

/// API Endpoints (used when migrating to REST backend)
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

  // User
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';

  // Trips
  static const String trips = '/trips';
  static const String tripEstimate = '/trips/estimate';
  static String tripDetails(String id) => '/trips/$id';
  static String cancelTrip(String id) => '/trips/$id/cancel';
  static String rateTrip(String id) => '/trips/$id/rate';

  // Driver
  static const String driverProfile = '/driver/profile';
  static const String driverStatus = '/driver/status';
  static const String driverTrips = '/driver/trips';
  static const String driverEarnings = '/driver/earnings';
  static String acceptTrip(String id) => '/driver/trips/$id/accept';
  static String declineTrip(String id) => '/driver/trips/$id/decline';
  static String startTrip(String id) => '/driver/trips/$id/start';
  static String completeTrip(String id) => '/driver/trips/$id/complete';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTopUp = '/wallet/topup';
  static const String walletWithdraw = '/wallet/withdraw';

  // Payments
  static const String paymentMethods = '/payments/methods';

  // Locations
  static const String savedLocations = '/passenger/saved-locations';
  static const String nearbyDrivers = '/drivers/nearby';
}

/// Firebase collection names
class FirestoreCollections {
  FirestoreCollections._();

  static const String tenants = 'tenants';
  static const String users = 'users';
  static const String drivers = 'drivers';
  static const String vehicles = 'vehicles';
  static const String trips = 'trips';
  static const String wallets = 'wallets';
  static const String transactions = 'transactions';
  static const String ratings = 'ratings';
  static const String promoCodes = 'promo_codes';
  static const String locations = 'locations';
  static const String notifications = 'notifications';
  static const String pricingConfigs = 'pricing_configs';
  static const String zones = 'zones';
}
