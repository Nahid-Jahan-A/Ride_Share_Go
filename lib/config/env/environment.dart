/// Backend type enum for switching between Firebase, REST, and Mock
enum BackendType { firebase, rest, mock }

/// Environment configuration
class Environment {
  Environment._();

  static late BackendType backendType;
  static late String apiBaseUrl;
  static late String wsUrl;
  static late String mapsApiKey;
  static late String stripePublishableKey;
  static late bool isProduction;
  static late String tenantId;

  /// Initialize environment from compile-time constants
  static Future<void> initialize() async {
    // Flavor determines which backend to use
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'firebase');
    const env = String.fromEnvironment('ENV', defaultValue: 'development');

    isProduction = env == 'production';

    switch (flavor) {
      case 'firebase':
        backendType = BackendType.firebase;
        break;
      case 'rest':
        backendType = BackendType.rest;
        apiBaseUrl = const String.fromEnvironment(
          'API_URL',
          defaultValue: 'http://localhost:3000/api/v1',
        );
        wsUrl = const String.fromEnvironment(
          'WS_URL',
          defaultValue: 'ws://localhost:3000',
        );
        break;
      case 'mock':
        backendType = BackendType.mock;
        break;
      default:
        // Default to mock for easier testing
        backendType = BackendType.mock;
    }

    mapsApiKey = const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
    stripePublishableKey = const String.fromEnvironment('STRIPE_KEY', defaultValue: '');
    tenantId = const String.fromEnvironment('TENANT_ID', defaultValue: 'default');
  }

  /// Check if using Firebase backend
  static bool get isFirebase => backendType == BackendType.firebase;

  /// Check if using REST backend
  static bool get isRest => backendType == BackendType.rest;

  /// Check if using Mock backend (for testing)
  static bool get isMock => backendType == BackendType.mock;

  /// Force mock mode (useful for hot reload testing)
  static void forceMockMode() {
    backendType = BackendType.mock;
  }
}

/// App flavor for different builds
enum AppFlavor {
  development,
  staging,
  production,
}

/// Feature flags for controlling app behavior
class FeatureFlags {
  FeatureFlags._();

  static bool enableSurgePrice = true;
  static bool enableScheduledRides = true;
  static bool enableWallet = true;
  static bool enableRatings = true;
  static bool enablePromos = true;
  static bool enableChat = true;
  static bool enableSOS = true;
  static bool enableCashPayment = true;
  static bool enableCardPayment = true;

  /// Update feature flags from remote config
  static void updateFromRemoteConfig(Map<String, dynamic> config) {
    enableSurgePrice = config['enable_surge_price'] ?? enableSurgePrice;
    enableScheduledRides = config['enable_scheduled_rides'] ?? enableScheduledRides;
    enableWallet = config['enable_wallet'] ?? enableWallet;
    enableRatings = config['enable_ratings'] ?? enableRatings;
    enablePromos = config['enable_promos'] ?? enablePromos;
    enableChat = config['enable_chat'] ?? enableChat;
    enableSOS = config['enable_sos'] ?? enableSOS;
    enableCashPayment = config['enable_cash_payment'] ?? enableCashPayment;
    enableCardPayment = config['enable_card_payment'] ?? enableCardPayment;
  }
}
