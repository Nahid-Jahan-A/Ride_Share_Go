part of 'trip_bloc.dart';

/// Trip bloc status for UI state management
enum TripBlocStatus {
  initial,
  loadingEstimates,
  estimatesLoaded,
  requesting,
  searchingDriver,
  driverMatched,
  driverArrived,
  inProgress,
  completing,
  completed,
  cancelling,
  cancelled,
  noDriverFound,
  rating,
  rated,
  error,
}

/// Trip state
class TripState extends Equatable {
  final TripBlocStatus status;
  final Location? pickup;
  final Location? dropoff;
  final List<FareEstimate>? fareEstimates;
  final Trip? currentTrip;
  final DriverLocation? driverLocation;
  final Duration? eta;
  final String? errorMessage;

  const TripState._({
    this.status = TripBlocStatus.initial,
    this.pickup,
    this.dropoff,
    this.fareEstimates,
    this.currentTrip,
    this.driverLocation,
    this.eta,
    this.errorMessage,
  });

  /// Initial state
  const TripState.initial() : this._();

  /// Copy with new values
  TripState copyWith({
    TripBlocStatus? status,
    Location? pickup,
    Location? dropoff,
    List<FareEstimate>? fareEstimates,
    Trip? currentTrip,
    DriverLocation? driverLocation,
    Duration? eta,
    String? errorMessage,
  }) {
    return TripState._(
      status: status ?? this.status,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      fareEstimates: fareEstimates ?? this.fareEstimates,
      currentTrip: currentTrip ?? this.currentTrip,
      driverLocation: driverLocation ?? this.driverLocation,
      eta: eta ?? this.eta,
      errorMessage: errorMessage,
    );
  }

  /// Check if trip is active
  bool get hasActiveTrip => currentTrip != null && currentTrip!.isActive;

  /// Check if loading
  bool get isLoading =>
      status == TripBlocStatus.loadingEstimates ||
      status == TripBlocStatus.requesting ||
      status == TripBlocStatus.cancelling;

  /// Check if has error
  bool get hasError => status == TripBlocStatus.error;

  /// Check if can cancel
  bool get canCancel =>
      currentTrip != null &&
      (status == TripBlocStatus.searchingDriver ||
          status == TripBlocStatus.driverMatched ||
          status == TripBlocStatus.driverArrived);

  @override
  List<Object?> get props => [
        status,
        pickup,
        dropoff,
        fareEstimates,
        currentTrip,
        driverLocation,
        eta,
        errorMessage,
      ];
}
