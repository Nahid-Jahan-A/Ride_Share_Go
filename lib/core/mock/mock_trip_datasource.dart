import 'dart:async';
import 'dart:math';

import '../../features/auth/domain/entities/user.dart';
import '../../features/booking/domain/entities/location.dart';
import '../../features/booking/domain/entities/trip.dart';
import '../../features/booking/domain/entities/vehicle.dart';
import 'mock_data.dart';

/// Mock implementation of Trip data source for testing
class MockTripDataSource {
  final Map<String, Trip> _trips = {};
  final Map<String, StreamController<Trip>> _tripStreams = {};
  final Random _random = Random();

  // Simulated delay for realistic API behavior
  static const _delay = Duration(milliseconds: 500);

  MockTripDataSource() {
    // Initialize with mock trips
    for (final trip in MockData.trips) {
      _trips[trip.id] = trip;
    }
  }

  /// Get fare estimates for a route
  Future<List<FareEstimate>> getFareEstimates({
    required Location pickup,
    required Location dropoff,
  }) async {
    await Future.delayed(_delay);
    return MockData.getFareEstimates(pickup: pickup, dropoff: dropoff);
  }

  /// Request a new trip
  Future<Trip> requestTrip({
    required String passengerId,
    required Location pickup,
    required Location dropoff,
    required VehicleType vehicleType,
    required PaymentMethod paymentMethod,
    String? promoCode,
  }) async {
    await Future.delayed(_delay);

    final estimates = MockData.getFareEstimates(pickup: pickup, dropoff: dropoff);
    final estimate = estimates.firstWhere((e) => e.vehicleType == vehicleType);

    double discount = 0;
    if (promoCode != null && MockData.promoCodes.containsKey(promoCode)) {
      final promo = MockData.promoCodes[promoCode]!;
      if (promo.isValid) {
        discount = promo.calculateDiscount(estimate.estimatedFare);
      }
    }

    final tripId = 'trip_${DateTime.now().millisecondsSinceEpoch}';
    final trip = Trip(
      id: tripId,
      tenantId: MockData.tenantId,
      passengerId: passengerId,
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      vehicleType: vehicleType,
      status: TripStatus.pending,
      paymentMethod: paymentMethod,
      estimatedFare: estimate.estimatedFare - discount,
      fareBreakdown: estimate.breakdown,
      estimatedDistanceKm: estimate.distanceKm,
      estimatedDuration: estimate.duration,
      promoCode: promoCode,
      discount: discount > 0 ? discount : null,
      createdAt: DateTime.now(),
    );

    _trips[tripId] = trip;

    // Simulate driver acceptance after a delay
    _simulateDriverAcceptance(tripId);

    return trip;
  }

  /// Simulate driver accepting the trip
  void _simulateDriverAcceptance(String tripId) {
    Future.delayed(const Duration(seconds: 3), () {
      final trip = _trips[tripId];
      if (trip != null && trip.status == TripStatus.pending) {
        // Randomly select an available driver
        final availableDrivers = MockData.driverProfiles
            .where((d) => d.isVerified && d.isOnline && d.driverStatus == DriverStatus.online)
            .toList();

        if (availableDrivers.isNotEmpty) {
          final driver = availableDrivers[_random.nextInt(availableDrivers.length)];
          final vehicle = MockData.vehicles.firstWhere(
            (v) => v.id == driver.vehicleId,
            orElse: () => MockData.vehicles.first,
          );

          final updatedTrip = trip.copyWith(
            status: TripStatus.accepted,
            driverId: driver.userId,
            vehicleId: vehicle.id,
            acceptedAt: DateTime.now(),
          );
          _trips[tripId] = updatedTrip;
          _notifyTripUpdate(tripId);

          // Simulate driver arrival
          _simulateDriverArrival(tripId);
        } else {
          // No drivers available
          final updatedTrip = trip.copyWith(status: TripStatus.noDriverFound);
          _trips[tripId] = updatedTrip;
          _notifyTripUpdate(tripId);
        }
      }
    });
  }

  /// Simulate driver arriving at pickup
  void _simulateDriverArrival(String tripId) {
    Future.delayed(const Duration(seconds: 5), () {
      final trip = _trips[tripId];
      if (trip != null && trip.status == TripStatus.accepted) {
        final updatedTrip = trip.copyWith(
          status: TripStatus.arrivedAtPickup,
          arrivedAt: DateTime.now(),
        );
        _trips[tripId] = updatedTrip;
        _notifyTripUpdate(tripId);
      }
    });
  }

  /// Cancel a trip
  Future<Trip> cancelTrip({
    required String tripId,
    required String cancelledBy,
    String? reason,
  }) async {
    await Future.delayed(_delay);

    final trip = _trips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (!trip.canBeCancelled) {
      throw Exception('Trip cannot be cancelled');
    }

    // Calculate cancellation fee based on status
    double cancellationFee = 0;
    if (trip.status == TripStatus.accepted || trip.status == TripStatus.arrivedAtPickup) {
      cancellationFee = 5.0;
    }

    final updatedTrip = trip.copyWith(
      status: TripStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancelledBy: cancelledBy,
      cancellationReason: reason,
      cancellationFee: cancellationFee,
    );

    _trips[tripId] = updatedTrip;
    _notifyTripUpdate(tripId);

    return updatedTrip;
  }

  /// Get a trip by ID
  Future<Trip?> getTrip(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _trips[tripId];
  }

  /// Stream trip updates
  Stream<Trip> streamTrip(String tripId) {
    if (!_tripStreams.containsKey(tripId)) {
      _tripStreams[tripId] = StreamController<Trip>.broadcast();

      // Emit current state
      final trip = _trips[tripId];
      if (trip != null) {
        Future.microtask(() => _tripStreams[tripId]?.add(trip));
      }
    }
    return _tripStreams[tripId]!.stream;
  }

  void _notifyTripUpdate(String tripId) {
    final trip = _trips[tripId];
    if (trip != null && _tripStreams.containsKey(tripId)) {
      _tripStreams[tripId]!.add(trip);
    }
  }

  /// Get passenger trip history
  Future<List<Trip>> getPassengerTripHistory({
    required String passengerId,
    int limit = 20,
    String? lastTripId,
  }) async {
    await Future.delayed(_delay);

    var trips = _trips.values
        .where((t) => t.passengerId == passengerId)
        .where((t) => t.status == TripStatus.completed || t.status == TripStatus.cancelled)
        .toList();

    // Sort by created date descending
    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Handle pagination
    if (lastTripId != null) {
      final lastIndex = trips.indexWhere((t) => t.id == lastTripId);
      if (lastIndex != -1) {
        trips = trips.sublist(lastIndex + 1);
      }
    }

    return trips.take(limit).toList();
  }

  /// Get driver trip history
  Future<List<Trip>> getDriverTripHistory({
    required String driverId,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(_delay);

    var trips = _trips.values.where((t) => t.driverId == driverId).toList();

    if (startDate != null) {
      trips = trips.where((t) => t.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      trips = trips.where((t) => t.createdAt.isBefore(endDate)).toList();
    }

    trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return trips.take(limit).toList();
  }

  /// Get current active trip for passenger
  Future<Trip?> getCurrentTrip(String passengerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _trips.values.cast<Trip?>().firstWhere(
          (t) => t?.passengerId == passengerId && t!.isActive,
          orElse: () => null,
        );
  }

  /// Start a trip (driver action)
  Future<Trip> startTrip(String tripId) async {
    await Future.delayed(_delay);

    final trip = _trips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (trip.status != TripStatus.arrivedAtPickup) {
      throw Exception('Cannot start trip - driver has not arrived');
    }

    final updatedTrip = trip.copyWith(
      status: TripStatus.inProgress,
      startedAt: DateTime.now(),
    );

    _trips[tripId] = updatedTrip;
    _notifyTripUpdate(tripId);

    return updatedTrip;
  }

  /// Complete a trip (driver action)
  Future<Trip> completeTrip(String tripId) async {
    await Future.delayed(_delay);

    final trip = _trips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (trip.status != TripStatus.inProgress) {
      throw Exception('Cannot complete trip - trip not in progress');
    }

    final actualDuration = DateTime.now().difference(trip.startedAt!);
    final actualDistance = trip.estimatedDistanceKm * (0.9 + _random.nextDouble() * 0.2);

    // Recalculate fare based on actual distance/time
    final timeCharge = actualDuration.inMinutes * 0.3;
    final distanceCharge = actualDistance * 2.0;
    final baseFare = trip.fareBreakdown?.baseFare ?? 5.0;
    final bookingFee = 2.0;
    final subtotal = baseFare + distanceCharge + timeCharge;
    final discount = trip.discount ?? 0;
    final finalFare = subtotal + bookingFee - discount;

    final updatedTrip = trip.copyWith(
      status: TripStatus.completed,
      completedAt: DateTime.now(),
      actualDistanceKm: actualDistance,
      actualDuration: actualDuration,
      finalFare: finalFare,
      fareBreakdown: FareBreakdown(
        baseFare: baseFare,
        distanceCharge: distanceCharge,
        timeCharge: timeCharge,
        bookingFee: bookingFee,
        discount: discount > 0 ? discount : null,
        subtotal: subtotal,
        total: finalFare,
      ),
    );

    _trips[tripId] = updatedTrip;
    _notifyTripUpdate(tripId);

    return updatedTrip;
  }

  /// Apply promo code to estimate
  Future<double> applyPromoCode({
    required String promoCode,
    required double fare,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final promo = MockData.promoCodes[promoCode.toUpperCase()];
    if (promo == null) {
      throw Exception('Invalid promo code');
    }

    if (!promo.isValid) {
      throw Exception('Promo code has expired');
    }

    return promo.calculateDiscount(fare);
  }

  /// Get trip route (encoded polyline)
  Future<String> getTripRoute({
    required Location pickup,
    required Location dropoff,
  }) async {
    await Future.delayed(_delay);
    // Return a mock encoded polyline
    return 'mock_polyline_${pickup.geoHash}_${dropoff.geoHash}';
  }

  /// Get nearby drivers
  Future<List<DriverLocation>> getNearbyDrivers({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    await Future.delayed(_delay);
    return MockData.nearbyDrivers;
  }

  /// Stream incoming trip requests (for drivers)
  Stream<Trip> streamTripRequests(String driverId) {
    final controller = StreamController<Trip>();

    // In a real app, this would listen to new trip requests
    // For mock, we just provide a stream that can be used

    return controller.stream;
  }

  /// Accept a trip (driver action)
  Future<Trip> acceptTrip({
    required String tripId,
    required String driverId,
  }) async {
    await Future.delayed(_delay);

    final trip = _trips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (trip.status != TripStatus.pending) {
      throw Exception('Trip already accepted or unavailable');
    }

    final driver = MockData.driverProfiles.firstWhere((d) => d.userId == driverId);
    final vehicle = MockData.vehicles.firstWhere((v) => v.id == driver.vehicleId);

    final updatedTrip = trip.copyWith(
      status: TripStatus.accepted,
      driverId: driverId,
      vehicleId: vehicle.id,
      acceptedAt: DateTime.now(),
    );

    _trips[tripId] = updatedTrip;
    _notifyTripUpdate(tripId);

    return updatedTrip;
  }

  /// Decline a trip (driver action)
  Future<void> declineTrip({
    required String tripId,
    required String driverId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In mock, just acknowledge the decline
  }

  /// Arrive at pickup (driver action)
  Future<Trip> arriveAtPickup(String tripId) async {
    await Future.delayed(_delay);

    final trip = _trips[tripId];
    if (trip == null) {
      throw Exception('Trip not found');
    }

    if (trip.status != TripStatus.accepted) {
      throw Exception('Cannot arrive - trip not in accepted state');
    }

    final updatedTrip = trip.copyWith(
      status: TripStatus.arrivedAtPickup,
      arrivedAt: DateTime.now(),
    );

    _trips[tripId] = updatedTrip;
    _notifyTripUpdate(tripId);

    return updatedTrip;
  }

  void dispose() {
    for (final controller in _tripStreams.values) {
      controller.close();
    }
    _tripStreams.clear();
  }
}
