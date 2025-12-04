import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/location.dart';
import '../entities/trip.dart';
import '../entities/vehicle.dart';

/// Abstract trip repository
abstract class TripRepository {
  /// Get fare estimate for a trip
  Future<Either<Failure, List<FareEstimate>>> getFareEstimates({
    required Location pickup,
    required Location dropoff,
    String? promoCode,
  });

  /// Request a new trip
  Future<Either<Failure, Trip>> requestTrip({
    required Location pickup,
    required Location dropoff,
    required VehicleType vehicleType,
    required PaymentMethod paymentMethod,
    String? promoCode,
    String? note,
    DateTime? scheduledTime,
  });

  /// Cancel a trip
  Future<Either<Failure, void>> cancelTrip({
    required String tripId,
    required String reason,
  });

  /// Get trip by ID
  Future<Either<Failure, Trip>> getTrip(String tripId);

  /// Stream trip updates (real-time)
  Stream<Either<Failure, Trip>> streamTrip(String tripId);

  /// Get passenger trip history
  Future<Either<Failure, List<Trip>>> getPassengerTripHistory({
    int page = 1,
    int limit = 20,
    TripStatus? statusFilter,
  });

  /// Get current active trip for passenger
  Future<Either<Failure, Trip?>> getCurrentTrip();

  /// Rate a completed trip
  Future<Either<Failure, void>> rateTrip({
    required String tripId,
    required int rating,
    String? comment,
    List<String>? feedbackTags,
    double? tipAmount,
  });

  /// Apply promo code to trip
  Future<Either<Failure, double>> applyPromoCode({
    required String tripId,
    required String promoCode,
  });

  /// Get trip route polyline
  Future<Either<Failure, String>> getTripRoute({
    required Location pickup,
    required Location dropoff,
    List<Location>? waypoints,
  });
}

/// Driver-specific trip repository methods
abstract class DriverTripRepository {
  /// Stream incoming trip requests
  Stream<Either<Failure, Trip>> streamTripRequests();

  /// Accept a trip request
  Future<Either<Failure, Trip>> acceptTrip(String tripId);

  /// Decline a trip request
  Future<Either<Failure, void>> declineTrip({
    required String tripId,
    String? reason,
  });

  /// Notify arrival at pickup
  Future<Either<Failure, Trip>> arriveAtPickup(String tripId);

  /// Start the trip
  Future<Either<Failure, Trip>> startTrip(String tripId);

  /// Complete the trip
  Future<Either<Failure, Trip>> completeTrip({
    required String tripId,
    required Location dropoffLocation,
  });

  /// Cancel trip (driver side)
  Future<Either<Failure, void>> cancelTrip({
    required String tripId,
    required String reason,
  });

  /// Get driver's current active trip
  Future<Either<Failure, Trip?>> getCurrentTrip();

  /// Get driver trip history
  Future<Either<Failure, List<Trip>>> getDriverTripHistory({
    int page = 1,
    int limit = 20,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Rate passenger after trip
  Future<Either<Failure, void>> ratePassenger({
    required String tripId,
    required int rating,
    String? comment,
    List<String>? feedbackTags,
  });
}
