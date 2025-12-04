import '../../features/auth/domain/entities/user.dart';
import '../../features/booking/domain/entities/location.dart';
import '../../features/booking/domain/entities/trip.dart' as booking;
import '../../features/booking/domain/entities/trip.dart' show Trip, FareEstimate;
import '../../features/booking/domain/entities/vehicle.dart';
import '../../features/wallet/domain/entities/wallet.dart';
import 'mock_auth_datasource.dart';
import 'mock_data.dart';
import 'mock_trip_datasource.dart';
import 'mock_wallet_datasource.dart';

/// Unified mock service for the entire app
/// Use this for testing on mobile and web without Firebase
class MockService {
  static MockService? _instance;
  static MockService get instance => _instance ??= MockService._();

  late final MockAuthDataSource auth;
  late final MockTripDataSource trips;
  late final MockWalletDataSource wallet;

  MockService._() {
    auth = MockAuthDataSource();
    trips = MockTripDataSource();
    wallet = MockWalletDataSource();
  }

  /// Reset all mock data (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }

  /// Get current logged in user
  User? get currentUser => auth.currentUserEntity;

  /// Quick login as passenger for testing
  Future<void> loginAsPassenger() async {
    await auth.quickLogin(asDriver: false);
  }

  /// Quick login as driver for testing
  Future<void> loginAsDriver() async {
    await auth.quickLogin(asDriver: true);
  }

  /// Get all mock data for debugging
  Map<String, dynamic> get debugData => {
        'passengers': MockData.passengers.length,
        'drivers': MockData.driverUsers.length,
        'vehicles': MockData.vehicles.length,
        'locations': MockData.popularLocations.length,
        'trips': MockData.trips.length,
        'wallets': MockData.wallets.length,
        'transactions': MockData.transactions.length,
        'paymentMethods': MockData.paymentMethods.length,
        'promoCodes': MockData.promoCodes.keys.toList(),
      };

  void dispose() {
    auth.dispose();
    trips.dispose();
    wallet.dispose();
  }
}

/// Extension to easily access mock service
extension MockServiceExtension on MockService {
  // Auth shortcuts
  Future<User> getPassenger(int index) async {
    return MockData.passengers[index % MockData.passengers.length];
  }

  Future<User> getDriver(int index) async {
    return MockData.driverUsers[index % MockData.driverUsers.length];
  }

  // Trip shortcuts
  Future<List<FareEstimate>> getEstimates(Location pickup, Location dropoff) {
    return trips.getFareEstimates(pickup: pickup, dropoff: dropoff);
  }

  Future<Trip> bookTrip({
    required Location pickup,
    required Location dropoff,
    VehicleType vehicleType = VehicleType.economy,
    booking.PaymentMethod paymentMethod = booking.PaymentMethod.card,
  }) {
    final userId = currentUser?.id ?? 'passenger_1';
    return trips.requestTrip(
      passengerId: userId,
      pickup: pickup,
      dropoff: dropoff,
      vehicleType: vehicleType,
      paymentMethod: paymentMethod,
    );
  }

  // Wallet shortcuts
  Future<Wallet?> getMyWallet() {
    final userId = currentUser?.id ?? 'passenger_1';
    return wallet.getWallet(userId);
  }

  Future<List<WalletTransaction>> getMyTransactions({int limit = 20}) {
    final userId = currentUser?.id ?? 'passenger_1';
    final walletId = 'wallet_$userId';
    return wallet.getTransactions(walletId: walletId, limit: limit);
  }
}

/// Debug helper to print mock data info
void printMockDataInfo() {
  print('=== Mock Data Info ===');
  print('Passengers: ${MockData.passengers.length}');
  for (final p in MockData.passengers) {
    print('  - ${p.fullName} (${p.phone})');
  }
  print('\nDrivers: ${MockData.driverUsers.length}');
  for (final d in MockData.driverUsers) {
    print('  - ${d.fullName} (${d.phone})');
  }
  print('\nVehicles: ${MockData.vehicles.length}');
  for (final v in MockData.vehicles) {
    print('  - ${v.fullDisplayName} [${v.type.name}] - ${v.plateNumber}');
  }
  print('\nLocations: ${MockData.popularLocations.length}');
  for (final l in MockData.popularLocations) {
    print('  - ${l.placeName}');
  }
  print('\nPromo Codes:');
  for (final code in MockData.promoCodes.keys) {
    final promo = MockData.promoCodes[code]!;
    print('  - $code: ${promo.discountPercent}% off (max \$${promo.maxDiscount})');
  }
  print('\n=== Test Credentials ===');
  print('Passenger: ${MockData.defaultPassengerPhone} / ${MockData.defaultPassword}');
  print('Driver: ${MockData.defaultDriverPhone} / ${MockData.defaultPassword}');
  print('OTP Code: 123456');
  print('======================');
}
