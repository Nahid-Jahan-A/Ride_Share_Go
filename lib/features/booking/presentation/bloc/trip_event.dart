part of 'trip_bloc.dart';

/// Base trip event
abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

/// Get fare estimates for a trip
class TripGetEstimatesRequested extends TripEvent {
  final Location pickup;
  final Location dropoff;
  final String? promoCode;

  const TripGetEstimatesRequested({
    required this.pickup,
    required this.dropoff,
    this.promoCode,
  });

  @override
  List<Object?> get props => [pickup, dropoff, promoCode];
}

/// Submit trip request
class TripRequestSubmitted extends TripEvent {
  final Location pickup;
  final Location dropoff;
  final VehicleType vehicleType;
  final PaymentMethod paymentMethod;
  final String? promoCode;
  final String? note;

  const TripRequestSubmitted({
    required this.pickup,
    required this.dropoff,
    required this.vehicleType,
    required this.paymentMethod,
    this.promoCode,
    this.note,
  });

  @override
  List<Object?> get props => [pickup, dropoff, vehicleType, paymentMethod, promoCode, note];
}

/// Cancel trip
class TripCancelRequested extends TripEvent {
  final String tripId;
  final String reason;

  const TripCancelRequested({
    required this.tripId,
    required this.reason,
  });

  @override
  List<Object?> get props => [tripId, reason];
}

/// Subscribe to trip updates
class TripSubscribeRequested extends TripEvent {
  final String tripId;

  const TripSubscribeRequested({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

/// Trip updated (from stream)
class TripUpdated extends TripEvent {
  final Trip trip;
  final String? errorMessage;

  const TripUpdated({
    required this.trip,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [trip, errorMessage];
}

/// Submit trip rating
class TripRatingSubmitted extends TripEvent {
  final String tripId;
  final int rating;
  final String? comment;
  final List<String>? feedbackTags;
  final double? tipAmount;

  const TripRatingSubmitted({
    required this.tripId,
    required this.rating,
    this.comment,
    this.feedbackTags,
    this.tipAmount,
  });

  @override
  List<Object?> get props => [tripId, rating, comment, feedbackTags, tipAmount];
}

/// Reset trip state
class TripReset extends TripEvent {
  const TripReset();
}
