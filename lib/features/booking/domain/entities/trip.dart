import 'package:equatable/equatable.dart';

import 'location.dart';
import 'vehicle.dart';

/// Trip status enum representing the lifecycle of a trip
enum TripStatus {
  pending, // Just created, searching for driver
  accepted, // Driver has accepted
  arrivedAtPickup, // Driver arrived at pickup location
  inProgress, // Trip is ongoing
  completed, // Trip finished successfully
  cancelled, // Trip was cancelled
  noDriverFound, // No driver accepted within timeout
}

/// Payment method for the trip
enum PaymentMethod {
  cash,
  card,
  wallet,
}

/// Trip entity - core domain model for rides
class Trip extends Equatable {
  final String id;
  final String tenantId;
  final String passengerId;
  final String? driverId;
  final String? vehicleId;

  // Locations
  final Location pickupLocation;
  final Location dropoffLocation;
  final List<Location>? waypoints;

  // Trip details
  final VehicleType vehicleType;
  final TripStatus status;
  final PaymentMethod paymentMethod;

  // Pricing
  final double estimatedFare;
  final double? finalFare;
  final FareBreakdown? fareBreakdown;
  final double? surgeMultiplier;
  final String? promoCode;
  final double? discount;

  // Distance and duration
  final double estimatedDistanceKm;
  final Duration estimatedDuration;
  final double? actualDistanceKm;
  final Duration? actualDuration;

  // Timestamps
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  // Cancellation
  final String? cancelledBy; // 'passenger', 'driver', 'system'
  final String? cancellationReason;
  final double? cancellationFee;

  // Route
  final String? encodedPolyline;

  const Trip({
    required this.id,
    required this.tenantId,
    required this.passengerId,
    this.driverId,
    this.vehicleId,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.waypoints,
    required this.vehicleType,
    required this.status,
    required this.paymentMethod,
    required this.estimatedFare,
    this.finalFare,
    this.fareBreakdown,
    this.surgeMultiplier,
    this.promoCode,
    this.discount,
    required this.estimatedDistanceKm,
    required this.estimatedDuration,
    this.actualDistanceKm,
    this.actualDuration,
    required this.createdAt,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.cancellationFee,
    this.encodedPolyline,
  });

  /// Check if trip is active (not completed or cancelled)
  bool get isActive =>
      status != TripStatus.completed &&
      status != TripStatus.cancelled &&
      status != TripStatus.noDriverFound;

  /// Check if trip can be cancelled
  bool get canBeCancelled =>
      status == TripStatus.pending ||
      status == TripStatus.accepted ||
      status == TripStatus.arrivedAtPickup;

  /// Check if driver has been assigned
  bool get hasDriver => driverId != null;

  /// Get the effective fare (final or estimated)
  double get effectiveFare => finalFare ?? estimatedFare;

  /// Copy with updated fields
  Trip copyWith({
    String? id,
    String? tenantId,
    String? passengerId,
    String? driverId,
    String? vehicleId,
    Location? pickupLocation,
    Location? dropoffLocation,
    List<Location>? waypoints,
    VehicleType? vehicleType,
    TripStatus? status,
    PaymentMethod? paymentMethod,
    double? estimatedFare,
    double? finalFare,
    FareBreakdown? fareBreakdown,
    double? surgeMultiplier,
    String? promoCode,
    double? discount,
    double? estimatedDistanceKm,
    Duration? estimatedDuration,
    double? actualDistanceKm,
    Duration? actualDuration,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? arrivedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    double? cancellationFee,
    String? encodedPolyline,
  }) {
    return Trip(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      waypoints: waypoints ?? this.waypoints,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      finalFare: finalFare ?? this.finalFare,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      promoCode: promoCode ?? this.promoCode,
      discount: discount ?? this.discount,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDistanceKm: actualDistanceKm ?? this.actualDistanceKm,
      actualDuration: actualDuration ?? this.actualDuration,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      arrivedAt: arrivedAt ?? this.arrivedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationFee: cancellationFee ?? this.cancellationFee,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        passengerId,
        driverId,
        vehicleId,
        pickupLocation,
        dropoffLocation,
        waypoints,
        vehicleType,
        status,
        paymentMethod,
        estimatedFare,
        finalFare,
        fareBreakdown,
        surgeMultiplier,
        promoCode,
        discount,
        estimatedDistanceKm,
        estimatedDuration,
        actualDistanceKm,
        actualDuration,
        createdAt,
        acceptedAt,
        arrivedAt,
        startedAt,
        completedAt,
        cancelledAt,
        cancelledBy,
        cancellationReason,
        cancellationFee,
        encodedPolyline,
      ];
}

/// Fare breakdown for transparency
class FareBreakdown extends Equatable {
  final double baseFare;
  final double distanceCharge;
  final double timeCharge;
  final double? surgeFee;
  final double? bookingFee;
  final double? tollFees;
  final double? waitingCharge;
  final double? discount;
  final double subtotal;
  final double total;

  const FareBreakdown({
    required this.baseFare,
    required this.distanceCharge,
    required this.timeCharge,
    this.surgeFee,
    this.bookingFee,
    this.tollFees,
    this.waitingCharge,
    this.discount,
    required this.subtotal,
    required this.total,
  });

  @override
  List<Object?> get props => [
        baseFare,
        distanceCharge,
        timeCharge,
        surgeFee,
        bookingFee,
        tollFees,
        waitingCharge,
        discount,
        subtotal,
        total,
      ];
}

/// Fare estimate before booking
class FareEstimate extends Equatable {
  final VehicleType vehicleType;
  final double minFare;
  final double maxFare;
  final double estimatedFare;
  final double? surgeMultiplier;
  final double distanceKm;
  final Duration duration;
  final FareBreakdown breakdown;

  const FareEstimate({
    required this.vehicleType,
    required this.minFare,
    required this.maxFare,
    required this.estimatedFare,
    this.surgeMultiplier,
    required this.distanceKm,
    required this.duration,
    required this.breakdown,
  });

  /// Check if surge pricing is active
  bool get hasSurge => surgeMultiplier != null && surgeMultiplier! > 1.0;

  @override
  List<Object?> get props => [
        vehicleType,
        minFare,
        maxFare,
        estimatedFare,
        surgeMultiplier,
        distanceKm,
        duration,
        breakdown,
      ];
}
