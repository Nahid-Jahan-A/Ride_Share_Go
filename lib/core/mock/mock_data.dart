import '../../features/auth/domain/entities/user.dart';
import '../../features/booking/domain/entities/location.dart';
import '../../features/booking/domain/entities/trip.dart' as booking;
import '../../features/booking/domain/entities/trip.dart' show Trip, TripStatus, FareBreakdown, FareEstimate;
import '../../features/booking/domain/entities/vehicle.dart';
import '../../features/wallet/domain/entities/wallet.dart';

/// Mock data for testing the app without Firebase
class MockData {
  MockData._();

  static const String tenantId = 'mock_tenant';

  // ============== USERS ==============

  static final List<User> passengers = [
    User(
      id: 'passenger_1',
      tenantId: tenantId,
      userType: UserType.passenger,
      phone: '+1234567890',
      email: 'john.doe@example.com',
      fullName: 'John Doe',
      avatarUrl: 'https://i.pravatar.cc/150?u=john',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'passenger_2',
      tenantId: tenantId,
      userType: UserType.passenger,
      phone: '+1234567891',
      email: 'jane.smith@example.com',
      fullName: 'Jane Smith',
      avatarUrl: 'https://i.pravatar.cc/150?u=jane',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'passenger_3',
      tenantId: tenantId,
      userType: UserType.passenger,
      phone: '+1234567892',
      email: 'bob.wilson@example.com',
      fullName: 'Bob Wilson',
      avatarUrl: 'https://i.pravatar.cc/150?u=bob',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'passenger_4',
      tenantId: tenantId,
      userType: UserType.passenger,
      phone: '+1234567893',
      email: 'alice.johnson@example.com',
      fullName: 'Alice Johnson',
      avatarUrl: 'https://i.pravatar.cc/150?u=alice',
      status: UserStatus.pendingVerification,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'passenger_5',
      tenantId: tenantId,
      userType: UserType.passenger,
      phone: '+1234567894',
      email: 'charlie.brown@example.com',
      fullName: 'Charlie Brown',
      avatarUrl: 'https://i.pravatar.cc/150?u=charlie',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<User> driverUsers = [
    User(
      id: 'driver_1',
      tenantId: tenantId,
      userType: UserType.driver,
      phone: '+1987654321',
      email: 'mike.driver@example.com',
      fullName: 'Mike Driver',
      avatarUrl: 'https://i.pravatar.cc/150?u=mike',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'driver_2',
      tenantId: tenantId,
      userType: UserType.driver,
      phone: '+1987654322',
      email: 'sarah.wheels@example.com',
      fullName: 'Sarah Wheels',
      avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'driver_3',
      tenantId: tenantId,
      userType: UserType.driver,
      phone: '+1987654323',
      email: 'tom.roads@example.com',
      fullName: 'Tom Roads',
      avatarUrl: 'https://i.pravatar.cc/150?u=tom',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'driver_4',
      tenantId: tenantId,
      userType: UserType.driver,
      phone: '+1987654324',
      email: 'emma.cruise@example.com',
      fullName: 'Emma Cruise',
      avatarUrl: 'https://i.pravatar.cc/150?u=emma',
      status: UserStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'driver_5',
      tenantId: tenantId,
      userType: UserType.driver,
      phone: '+1987654325',
      email: 'david.lane@example.com',
      fullName: 'David Lane',
      avatarUrl: 'https://i.pravatar.cc/150?u=david',
      status: UserStatus.pendingVerification,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  static final List<DriverProfile> driverProfiles = [
    DriverProfile(
      userId: 'driver_1',
      vehicleId: 'vehicle_1',
      licenseNumber: 'DL123456789',
      licenseExpiry: DateTime.now().add(const Duration(days: 365)),
      averageRating: 4.8,
      totalTrips: 1250,
      totalEarnings: 45000,
      isVerified: true,
      isOnline: true,
      driverStatus: DriverStatus.online,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    DriverProfile(
      userId: 'driver_2',
      vehicleId: 'vehicle_2',
      licenseNumber: 'DL987654321',
      licenseExpiry: DateTime.now().add(const Duration(days: 500)),
      averageRating: 4.9,
      totalTrips: 890,
      totalEarnings: 32000,
      isVerified: true,
      isOnline: true,
      driverStatus: DriverStatus.online,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
    DriverProfile(
      userId: 'driver_3',
      vehicleId: 'vehicle_3',
      licenseNumber: 'DL456789123',
      licenseExpiry: DateTime.now().add(const Duration(days: 300)),
      averageRating: 4.6,
      totalTrips: 650,
      totalEarnings: 24000,
      isVerified: true,
      isOnline: false,
      driverStatus: DriverStatus.offline,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now(),
    ),
    DriverProfile(
      userId: 'driver_4',
      vehicleId: 'vehicle_4',
      licenseNumber: 'DL789123456',
      licenseExpiry: DateTime.now().add(const Duration(days: 450)),
      averageRating: 4.95,
      totalTrips: 420,
      totalEarnings: 18000,
      isVerified: true,
      isOnline: true,
      driverStatus: DriverStatus.busy,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now(),
    ),
    DriverProfile(
      userId: 'driver_5',
      vehicleId: null,
      licenseNumber: 'DL321654987',
      licenseExpiry: DateTime.now().add(const Duration(days: 700)),
      averageRating: 5.0,
      totalTrips: 0,
      totalEarnings: 0,
      isVerified: false,
      isOnline: false,
      driverStatus: DriverStatus.offline,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
  ];

  // ============== VEHICLES ==============

  static final List<Vehicle> vehicles = [
    Vehicle(
      id: 'vehicle_1',
      tenantId: tenantId,
      assignedDriverId: 'driver_1',
      make: 'Toyota',
      model: 'Camry',
      year: 2022,
      color: 'Silver',
      plateNumber: 'ABC 1234',
      type: VehicleType.comfort,
      passengerCapacity: 4,
      features: [VehicleFeature.airConditioning, VehicleFeature.musicSystem, VehicleFeature.charger],
      status: VehicleStatus.active,
      currentMileage: 25000,
      imageUrl: 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Vehicle(
      id: 'vehicle_2',
      tenantId: tenantId,
      assignedDriverId: 'driver_2',
      make: 'Honda',
      model: 'Civic',
      year: 2023,
      color: 'White',
      plateNumber: 'XYZ 5678',
      type: VehicleType.economy,
      passengerCapacity: 4,
      features: [VehicleFeature.airConditioning, VehicleFeature.musicSystem],
      status: VehicleStatus.active,
      currentMileage: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
    Vehicle(
      id: 'vehicle_3',
      tenantId: tenantId,
      assignedDriverId: 'driver_3',
      make: 'Mercedes',
      model: 'E-Class',
      year: 2023,
      color: 'Black',
      plateNumber: 'LUX 9999',
      type: VehicleType.premium,
      passengerCapacity: 4,
      features: [
        VehicleFeature.airConditioning,
        VehicleFeature.wifi,
        VehicleFeature.charger,
        VehicleFeature.water,
        VehicleFeature.musicSystem,
      ],
      status: VehicleStatus.active,
      currentMileage: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      updatedAt: DateTime.now(),
    ),
    Vehicle(
      id: 'vehicle_4',
      tenantId: tenantId,
      assignedDriverId: 'driver_4',
      make: 'Ford',
      model: 'Explorer',
      year: 2022,
      color: 'Blue',
      plateNumber: 'SUV 4321',
      type: VehicleType.suv,
      passengerCapacity: 6,
      features: [
        VehicleFeature.airConditioning,
        VehicleFeature.wifi,
        VehicleFeature.childSeat,
        VehicleFeature.musicSystem,
      ],
      status: VehicleStatus.active,
      currentMileage: 30000,
      imageUrl: 'https://images.unsplash.com/photo-1533473359331-f99d1d0db73b?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now(),
    ),
    Vehicle(
      id: 'vehicle_5',
      tenantId: tenantId,
      assignedDriverId: null,
      make: 'Toyota',
      model: 'Sienna',
      year: 2023,
      color: 'Gray',
      plateNumber: 'VAN 8888',
      type: VehicleType.van,
      passengerCapacity: 8,
      features: [
        VehicleFeature.airConditioning,
        VehicleFeature.wifi,
        VehicleFeature.wheelchairAccessible,
        VehicleFeature.musicSystem,
      ],
      status: VehicleStatus.active,
      currentMileage: 5000,
      imageUrl: 'https://images.unsplash.com/photo-1559416523-140ddc3d238c?w=400',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    ),
  ];

  // ============== LOCATIONS ==============

  static final List<Location> popularLocations = [
    const Location(
      latitude: 40.7128,
      longitude: -74.0060,
      address: '123 Broadway, New York, NY 10001',
      placeId: 'place_nyc_broadway',
      placeName: 'Times Square',
      geoHash: 'dr5ru7',
    ),
    const Location(
      latitude: 40.7484,
      longitude: -73.9857,
      address: '350 5th Ave, New York, NY 10118',
      placeId: 'place_nyc_empire',
      placeName: 'Empire State Building',
      geoHash: 'dr5ru6',
    ),
    const Location(
      latitude: 40.7580,
      longitude: -73.9855,
      address: '45 Rockefeller Plaza, New York, NY 10111',
      placeId: 'place_nyc_rockefeller',
      placeName: 'Rockefeller Center',
      geoHash: 'dr5ru9',
    ),
    const Location(
      latitude: 40.7614,
      longitude: -73.9776,
      address: '11 W 53rd St, New York, NY 10019',
      placeId: 'place_nyc_moma',
      placeName: 'MoMA',
      geoHash: 'dr5rub',
    ),
    const Location(
      latitude: 40.7794,
      longitude: -73.9632,
      address: '1000 5th Ave, New York, NY 10028',
      placeId: 'place_nyc_met',
      placeName: 'Metropolitan Museum',
      geoHash: 'dr5rvc',
    ),
    const Location(
      latitude: 40.6892,
      longitude: -74.0445,
      address: 'Liberty Island, New York, NY 10004',
      placeId: 'place_nyc_liberty',
      placeName: 'Statue of Liberty',
      geoHash: 'dr5r7z',
    ),
    const Location(
      latitude: 40.7527,
      longitude: -73.9772,
      address: '89 E 42nd St, New York, NY 10017',
      placeId: 'place_nyc_grandcentral',
      placeName: 'Grand Central Terminal',
      geoHash: 'dr5ru8',
    ),
    const Location(
      latitude: 40.7829,
      longitude: -73.9654,
      address: 'Central Park, New York, NY',
      placeId: 'place_nyc_centralpark',
      placeName: 'Central Park',
      geoHash: 'dr5rvd',
    ),
    const Location(
      latitude: 40.7587,
      longitude: -73.9787,
      address: '1 Vanderbilt Ave, New York, NY 10017',
      placeId: 'place_nyc_summit',
      placeName: 'Summit One Vanderbilt',
      geoHash: 'dr5rua',
    ),
    const Location(
      latitude: 40.7061,
      longitude: -73.9969,
      address: 'Brooklyn Bridge, New York, NY',
      placeId: 'place_nyc_brooklyn_bridge',
      placeName: 'Brooklyn Bridge',
      geoHash: 'dr5reg',
    ),
  ];

  static final List<SavedLocation> savedLocations = [
    SavedLocation(
      id: 'saved_1',
      userId: 'passenger_1',
      name: 'Home',
      location: const Location(
        latitude: 40.7589,
        longitude: -73.9851,
        address: '123 Park Ave, New York, NY 10017',
        placeName: 'Home',
      ),
      type: SavedLocationType.home,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    SavedLocation(
      id: 'saved_2',
      userId: 'passenger_1',
      name: 'Work',
      location: const Location(
        latitude: 40.7484,
        longitude: -73.9857,
        address: '350 5th Ave, New York, NY 10118',
        placeName: 'Office',
      ),
      type: SavedLocationType.work,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    SavedLocation(
      id: 'saved_3',
      userId: 'passenger_1',
      name: 'Gym',
      location: const Location(
        latitude: 40.7527,
        longitude: -73.9772,
        address: '100 E 42nd St, New York, NY 10017',
        placeName: 'Fitness Center',
      ),
      type: SavedLocationType.other,
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
  ];

  // ============== TRIPS ==============

  static List<Trip> get trips {
    final now = DateTime.now();
    return [
      // Active trip - just requested
      Trip(
        id: 'trip_active_1',
        tenantId: tenantId,
        passengerId: 'passenger_1',
        driverId: null,
        vehicleId: null,
        pickupLocation: popularLocations[0],
        dropoffLocation: popularLocations[1],
        vehicleType: VehicleType.comfort,
        status: TripStatus.pending,
        paymentMethod: booking.PaymentMethod.card,
        estimatedFare: 25.50,
        estimatedDistanceKm: 3.2,
        estimatedDuration: const Duration(minutes: 15),
        createdAt: now.subtract(const Duration(minutes: 2)),
      ),
      // Active trip - driver accepted
      Trip(
        id: 'trip_active_2',
        tenantId: tenantId,
        passengerId: 'passenger_2',
        driverId: 'driver_1',
        vehicleId: 'vehicle_1',
        pickupLocation: popularLocations[2],
        dropoffLocation: popularLocations[3],
        vehicleType: VehicleType.comfort,
        status: TripStatus.accepted,
        paymentMethod: booking.PaymentMethod.wallet,
        estimatedFare: 18.00,
        estimatedDistanceKm: 2.1,
        estimatedDuration: const Duration(minutes: 10),
        createdAt: now.subtract(const Duration(minutes: 8)),
        acceptedAt: now.subtract(const Duration(minutes: 5)),
      ),
      // Active trip - driver arrived
      Trip(
        id: 'trip_active_3',
        tenantId: tenantId,
        passengerId: 'passenger_3',
        driverId: 'driver_2',
        vehicleId: 'vehicle_2',
        pickupLocation: popularLocations[4],
        dropoffLocation: popularLocations[5],
        vehicleType: VehicleType.economy,
        status: TripStatus.arrivedAtPickup,
        paymentMethod: booking.PaymentMethod.cash,
        estimatedFare: 45.00,
        estimatedDistanceKm: 8.5,
        estimatedDuration: const Duration(minutes: 35),
        createdAt: now.subtract(const Duration(minutes: 15)),
        acceptedAt: now.subtract(const Duration(minutes: 12)),
        arrivedAt: now.subtract(const Duration(minutes: 2)),
      ),
      // Active trip - in progress
      Trip(
        id: 'trip_active_4',
        tenantId: tenantId,
        passengerId: 'passenger_5',
        driverId: 'driver_4',
        vehicleId: 'vehicle_4',
        pickupLocation: popularLocations[6],
        dropoffLocation: popularLocations[7],
        vehicleType: VehicleType.suv,
        status: TripStatus.inProgress,
        paymentMethod: booking.PaymentMethod.card,
        estimatedFare: 32.00,
        estimatedDistanceKm: 4.8,
        estimatedDuration: const Duration(minutes: 22),
        createdAt: now.subtract(const Duration(minutes: 30)),
        acceptedAt: now.subtract(const Duration(minutes: 25)),
        arrivedAt: now.subtract(const Duration(minutes: 18)),
        startedAt: now.subtract(const Duration(minutes: 15)),
      ),
      // Completed trips (history)
      ...List.generate(20, (index) {
        final daysAgo = index + 1;
        final tripTime = now.subtract(Duration(days: daysAgo));
        final vehicleTypes = VehicleType.values;
        final tripPaymentMethods = booking.PaymentMethod.values;
        final pickupIndex = index % popularLocations.length;
        final dropoffIndex = (index + 3) % popularLocations.length;
        final driverIndex = index % 4;
        final fare = 15.0 + (index % 10) * 5.0;

        return Trip(
          id: 'trip_completed_$index',
          tenantId: tenantId,
          passengerId: 'passenger_1',
          driverId: 'driver_${driverIndex + 1}',
          vehicleId: 'vehicle_${driverIndex + 1}',
          pickupLocation: popularLocations[pickupIndex],
          dropoffLocation: popularLocations[dropoffIndex],
          vehicleType: vehicleTypes[index % vehicleTypes.length],
          status: TripStatus.completed,
          paymentMethod: tripPaymentMethods[index % tripPaymentMethods.length],
          estimatedFare: fare,
          finalFare: fare + (index % 3) * 2.0,
          fareBreakdown: FareBreakdown(
            baseFare: 5.0,
            distanceCharge: fare * 0.4,
            timeCharge: fare * 0.2,
            bookingFee: 2.0,
            subtotal: fare,
            total: fare + (index % 3) * 2.0,
          ),
          estimatedDistanceKm: 2.0 + index * 0.5,
          estimatedDuration: Duration(minutes: 10 + index * 2),
          actualDistanceKm: 2.0 + index * 0.5 + 0.3,
          actualDuration: Duration(minutes: 10 + index * 2 + 3),
          createdAt: tripTime,
          acceptedAt: tripTime.add(const Duration(minutes: 3)),
          arrivedAt: tripTime.add(const Duration(minutes: 8)),
          startedAt: tripTime.add(const Duration(minutes: 10)),
          completedAt: tripTime.add(Duration(minutes: 10 + index * 2 + 3)),
        );
      }),
      // Cancelled trips
      Trip(
        id: 'trip_cancelled_1',
        tenantId: tenantId,
        passengerId: 'passenger_1',
        driverId: 'driver_1',
        vehicleId: 'vehicle_1',
        pickupLocation: popularLocations[8],
        dropoffLocation: popularLocations[9],
        vehicleType: VehicleType.comfort,
        status: TripStatus.cancelled,
        paymentMethod: booking.PaymentMethod.card,
        estimatedFare: 22.00,
        estimatedDistanceKm: 3.5,
        estimatedDuration: const Duration(minutes: 18),
        createdAt: now.subtract(const Duration(days: 5)),
        acceptedAt: now.subtract(const Duration(days: 5)).add(const Duration(minutes: 2)),
        cancelledAt: now.subtract(const Duration(days: 5)).add(const Duration(minutes: 5)),
        cancelledBy: 'passenger',
        cancellationReason: 'Changed plans',
        cancellationFee: 5.0,
      ),
      Trip(
        id: 'trip_cancelled_2',
        tenantId: tenantId,
        passengerId: 'passenger_1',
        driverId: 'driver_2',
        vehicleId: 'vehicle_2',
        pickupLocation: popularLocations[1],
        dropoffLocation: popularLocations[4],
        vehicleType: VehicleType.economy,
        status: TripStatus.cancelled,
        paymentMethod: booking.PaymentMethod.cash,
        estimatedFare: 35.00,
        estimatedDistanceKm: 5.2,
        estimatedDuration: const Duration(minutes: 25),
        createdAt: now.subtract(const Duration(days: 10)),
        acceptedAt: now.subtract(const Duration(days: 10)).add(const Duration(minutes: 3)),
        cancelledAt: now.subtract(const Duration(days: 10)).add(const Duration(minutes: 8)),
        cancelledBy: 'driver',
        cancellationReason: 'Vehicle issue',
        cancellationFee: 0.0,
      ),
      // No driver found
      Trip(
        id: 'trip_no_driver_1',
        tenantId: tenantId,
        passengerId: 'passenger_1',
        driverId: null,
        vehicleId: null,
        pickupLocation: popularLocations[5],
        dropoffLocation: popularLocations[0],
        vehicleType: VehicleType.premium,
        status: TripStatus.noDriverFound,
        paymentMethod: booking.PaymentMethod.card,
        estimatedFare: 55.00,
        estimatedDistanceKm: 9.0,
        estimatedDuration: const Duration(minutes: 40),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }

  // ============== WALLETS ==============

  static final List<Wallet> wallets = [
    Wallet(
      id: 'wallet_passenger_1',
      ownerId: 'passenger_1',
      type: WalletType.passenger,
      balance: 125.50,
      pendingBalance: 0,
      currency: 'USD',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      updatedAt: DateTime.now(),
    ),
    Wallet(
      id: 'wallet_passenger_2',
      ownerId: 'passenger_2',
      type: WalletType.passenger,
      balance: 50.00,
      pendingBalance: 10.00,
      currency: 'USD',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    ),
    Wallet(
      id: 'wallet_driver_1',
      ownerId: 'driver_1',
      type: WalletType.driver,
      balance: 850.75,
      pendingBalance: 45.00,
      currency: 'USD',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    Wallet(
      id: 'wallet_driver_2',
      ownerId: 'driver_2',
      type: WalletType.driver,
      balance: 620.00,
      pendingBalance: 0,
      currency: 'USD',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now(),
    ),
  ];

  static List<WalletTransaction> get transactions {
    final now = DateTime.now();
    return [
      // Recent transactions for passenger_1
      WalletTransaction(
        id: 'txn_1',
        walletId: 'wallet_passenger_1',
        type: TransactionType.topUp,
        amount: 50.00,
        balanceAfter: 125.50,
        description: 'Wallet top-up via card',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(hours: 2)),
        completedAt: now.subtract(const Duration(hours: 2)),
      ),
      WalletTransaction(
        id: 'txn_2',
        walletId: 'wallet_passenger_1',
        type: TransactionType.ridePayment,
        amount: -25.50,
        balanceAfter: 75.50,
        referenceId: 'trip_completed_0',
        description: 'Ride payment - Times Square to Empire State',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 'txn_3',
        walletId: 'wallet_passenger_1',
        type: TransactionType.promoCredit,
        amount: 10.00,
        balanceAfter: 101.00,
        description: 'Welcome bonus credit',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 3)),
      ),
      WalletTransaction(
        id: 'txn_4',
        walletId: 'wallet_passenger_1',
        type: TransactionType.refund,
        amount: 5.00,
        balanceAfter: 91.00,
        referenceId: 'trip_cancelled_1',
        description: 'Partial refund for cancelled trip',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 5)),
      ),
      // Driver transactions
      WalletTransaction(
        id: 'txn_d1',
        walletId: 'wallet_driver_1',
        type: TransactionType.tripEarning,
        amount: 22.50,
        balanceAfter: 850.75,
        referenceId: 'trip_completed_0',
        description: 'Trip earnings - Times Square to Empire State',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 'txn_d2',
        walletId: 'wallet_driver_1',
        type: TransactionType.commission,
        amount: -3.00,
        balanceAfter: 828.25,
        referenceId: 'trip_completed_0',
        description: 'Platform commission (12%)',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      WalletTransaction(
        id: 'txn_d3',
        walletId: 'wallet_driver_1',
        type: TransactionType.withdrawal,
        amount: -200.00,
        balanceAfter: 628.25,
        description: 'Withdrawal to bank account ****4521',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 7)),
        completedAt: now.subtract(const Duration(days: 6)),
      ),
      WalletTransaction(
        id: 'txn_d4',
        walletId: 'wallet_driver_1',
        type: TransactionType.incentiveBonus,
        amount: 25.00,
        balanceAfter: 828.25,
        description: 'Weekly bonus - Completed 50+ trips',
        status: TransactionStatus.completed,
        createdAt: now.subtract(const Duration(days: 7)),
        completedAt: now.subtract(const Duration(days: 7)),
      ),
      // Generate more historical transactions
      ...List.generate(15, (index) {
        final daysAgo = index + 2;
        return WalletTransaction(
          id: 'txn_hist_$index',
          walletId: 'wallet_passenger_1',
          type: index % 2 == 0 ? TransactionType.ridePayment : TransactionType.topUp,
          amount: index % 2 == 0 ? -(15.0 + index * 2) : (50.0 + index * 10),
          balanceAfter: 86.00 + index * 5,
          referenceId: index % 2 == 0 ? 'trip_completed_$index' : null,
          description: index % 2 == 0 ? 'Ride payment' : 'Wallet top-up',
          status: TransactionStatus.completed,
          createdAt: now.subtract(Duration(days: daysAgo)),
          completedAt: now.subtract(Duration(days: daysAgo)),
        );
      }),
    ];
  }

  // ============== PAYMENT METHODS ==============

  static final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'pm_1',
      userId: 'passenger_1',
      type: PaymentMethodType.card,
      last4: '4242',
      brand: 'Visa',
      expiryMonth: '12',
      expiryYear: '2026',
      isDefault: true,
      stripePaymentMethodId: 'pm_mock_visa_4242',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
    PaymentMethod(
      id: 'pm_2',
      userId: 'passenger_1',
      type: PaymentMethodType.card,
      last4: '5555',
      brand: 'Mastercard',
      expiryMonth: '06',
      expiryYear: '2025',
      isDefault: false,
      stripePaymentMethodId: 'pm_mock_mc_5555',
      createdAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
    PaymentMethod(
      id: 'pm_3',
      userId: 'passenger_1',
      type: PaymentMethodType.wallet,
      isDefault: false,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    PaymentMethod(
      id: 'pm_4',
      userId: 'driver_1',
      type: PaymentMethodType.bankAccount,
      last4: '4521',
      brand: 'Chase',
      isDefault: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ];

  // ============== DRIVER LOCATIONS ==============

  static List<DriverLocation> get nearbyDrivers {
    final now = DateTime.now();
    return [
      DriverLocation(
        driverId: 'driver_1',
        latitude: 40.7135,
        longitude: -74.0050,
        heading: 45,
        speed: 25,
        accuracy: 5,
        geoHash: 'dr5ru7',
        timestamp: now,
      ),
      DriverLocation(
        driverId: 'driver_2',
        latitude: 40.7150,
        longitude: -74.0080,
        heading: 90,
        speed: 0,
        accuracy: 3,
        geoHash: 'dr5ru7',
        timestamp: now,
      ),
      DriverLocation(
        driverId: 'driver_4',
        latitude: 40.7100,
        longitude: -74.0020,
        heading: 180,
        speed: 35,
        accuracy: 8,
        geoHash: 'dr5ru6',
        currentTripId: 'trip_active_4',
        timestamp: now,
      ),
    ];
  }

  // ============== FARE ESTIMATES ==============

  static List<FareEstimate> getFareEstimates({
    required Location pickup,
    required Location dropoff,
  }) {
    // Simple distance calculation (approximate)
    final latDiff = (pickup.latitude - dropoff.latitude).abs();
    final lngDiff = (pickup.longitude - dropoff.longitude).abs();
    final distance = (latDiff + lngDiff) * 111; // Rough km conversion
    final duration = Duration(minutes: (distance * 3).round());

    return VehicleTypeConfig.defaultConfigs.map((config) {
      final baseFare = 5.0 * config.baseMultiplier;
      final distanceCharge = distance * 2.0 * config.baseMultiplier;
      final timeCharge = duration.inMinutes * 0.3 * config.baseMultiplier;
      final bookingFee = 2.0;
      final subtotal = baseFare + distanceCharge + timeCharge;
      final total = subtotal + bookingFee;

      return FareEstimate(
        vehicleType: config.type,
        minFare: total * 0.9,
        maxFare: total * 1.1,
        estimatedFare: total,
        distanceKm: distance,
        duration: duration,
        breakdown: FareBreakdown(
          baseFare: baseFare,
          distanceCharge: distanceCharge,
          timeCharge: timeCharge,
          bookingFee: bookingFee,
          subtotal: subtotal,
          total: total,
        ),
      );
    }).toList();
  }

  // ============== PROMO CODES ==============

  static final Map<String, PromoCode> promoCodes = {
    'WELCOME20': PromoCode(
      code: 'WELCOME20',
      discountPercent: 20,
      maxDiscount: 10.0,
      minFare: 15.0,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      usageLimit: 1,
    ),
    'SAVE10': PromoCode(
      code: 'SAVE10',
      discountPercent: 10,
      maxDiscount: 5.0,
      minFare: 10.0,
      expiresAt: DateTime.now().add(const Duration(days: 60)),
      usageLimit: 3,
    ),
    'FIRST50': PromoCode(
      code: 'FIRST50',
      discountPercent: 50,
      maxDiscount: 25.0,
      minFare: 20.0,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      usageLimit: 1,
    ),
  };

  // ============== HELPER METHODS ==============

  /// Get trips for a specific passenger
  static List<Trip> getTripsForPassenger(String passengerId) {
    return trips.where((trip) => trip.passengerId == passengerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get trips for a specific driver
  static List<Trip> getTripsForDriver(String driverId) {
    return trips.where((trip) => trip.driverId == driverId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get wallet for a specific user
  static Wallet? getWalletForUser(String userId) {
    return wallets.where((w) => w.ownerId == userId).firstOrNull;
  }

  /// Get transactions for a specific user
  static List<MockWalletTransaction> getTransactionsForUser(String userId) {
    final wallet = getWalletForUser(userId);
    if (wallet == null) return [];

    // Convert domain transactions to mock transactions
    return transactions
        .where((t) => t.walletId == wallet.id)
        .map((t) => MockWalletTransaction(
              id: t.id,
              walletId: t.walletId,
              type: t.amount > 0 ? 'credit' : 'debit',
              amount: t.amount.abs(),
              description: t.description,
              status: t.status.toString().split('.').last,
              createdAt: t.createdAt,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get payment methods for a specific user
  static List<MockPaymentMethod> getPaymentMethodsForUser(String userId) {
    return paymentMethods
        .where((pm) => pm.userId == userId)
        .map((pm) => MockPaymentMethod(
              id: pm.id,
              userId: pm.userId,
              type: pm.type.toString().split('.').last,
              last4: pm.last4,
              brand: pm.brand,
              expiryMonth: pm.expiryMonth,
              expiryYear: pm.expiryYear,
              isDefault: pm.isDefault,
              displayName: pm.type == PaymentMethodType.wallet
                  ? 'Wallet Balance'
                  : pm.type == PaymentMethodType.bankAccount
                      ? 'Bank ****${pm.last4}'
                      : '${pm.brand} ****${pm.last4}',
            ))
        .toList();
  }

  // ============== DEFAULT CREDENTIALS ==============

  static const defaultPassengerPhone = '+1234567890';
  static const defaultPassengerEmail = 'john.doe@example.com';
  static const defaultPassword = 'password123';

  static const defaultDriverPhone = '+1987654321';
  static const defaultDriverEmail = 'mike.driver@example.com';
}

/// Promo code model
class PromoCode {
  final String code;
  final int discountPercent;
  final double maxDiscount;
  final double minFare;
  final DateTime expiresAt;
  final int usageLimit;

  const PromoCode({
    required this.code,
    required this.discountPercent,
    required this.maxDiscount,
    required this.minFare,
    required this.expiresAt,
    required this.usageLimit,
  });

  bool get isValid => DateTime.now().isBefore(expiresAt);

  double calculateDiscount(double fare) {
    if (fare < minFare) return 0;
    final discount = fare * (discountPercent / 100);
    return discount > maxDiscount ? maxDiscount : discount;
  }
}

/// Mock wallet transaction for UI display
class MockWalletTransaction {
  final String id;
  final String walletId;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final String status;
  final DateTime createdAt;

  const MockWalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
  });
}

/// Mock payment method for UI display
class MockPaymentMethod {
  final String id;
  final String userId;
  final String type; // 'card', 'wallet', 'bankAccount'
  final String? last4;
  final String? brand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final String displayName;

  const MockPaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    this.last4,
    this.brand,
    this.expiryMonth,
    this.expiryYear,
    required this.isDefault,
    required this.displayName,
  });
}
