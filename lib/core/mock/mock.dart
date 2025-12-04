// Mock data and services for testing the app without Firebase
//
// Usage:
// 1. Run with mock mode: `flutter run --dart-define=FLAVOR=mock`
// 2. Or force mock mode in code: `Environment.forceMockMode()`
//
// Test Credentials:
// - Passenger: +1234567890 / password123
// - Driver: +1987654321 / password123
// - OTP Code: 123456
//
// Available Promo Codes:
// - WELCOME20: 20% off (max $10)
// - SAVE10: 10% off (max $5)
// - FIRST50: 50% off (max $25)

export 'mock_auth_datasource.dart';
export 'mock_data.dart';
export 'mock_service.dart';
export 'mock_trip_datasource.dart';
export 'mock_wallet_datasource.dart';
