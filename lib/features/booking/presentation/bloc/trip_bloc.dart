import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/trip.dart' as domain;
import '../../domain/entities/trip.dart' show Trip, FareEstimate, PaymentMethod;
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/trip_repository.dart';

part 'trip_event.dart';
part 'trip_state.dart';

/// Trip Bloc
/// Manages trip booking and tracking state
class TripBloc extends Bloc<TripEvent, TripState> {
  final TripRepository _tripRepository;
  StreamSubscription? _tripSubscription;

  TripBloc({
    required TripRepository tripRepository,
  })  : _tripRepository = tripRepository,
        super(const TripState.initial()) {
    on<TripGetEstimatesRequested>(_onGetEstimates);
    on<TripRequestSubmitted>(_onRequestTrip);
    on<TripCancelRequested>(_onCancelTrip);
    on<TripSubscribeRequested>(_onSubscribeToTrip);
    on<TripUpdated>(_onTripUpdated);
    on<TripRatingSubmitted>(_onRatingSubmitted);
    on<TripReset>(_onReset);
  }

  Future<void> _onGetEstimates(
    TripGetEstimatesRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripBlocStatus.loadingEstimates));

    final result = await _tripRepository.getFareEstimates(
      pickup: event.pickup,
      dropoff: event.dropoff,
      promoCode: event.promoCode,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: failure.message,
      )),
      (estimates) => emit(state.copyWith(
        status: TripBlocStatus.estimatesLoaded,
        fareEstimates: estimates,
        pickup: event.pickup,
        dropoff: event.dropoff,
      )),
    );
  }

  Future<void> _onRequestTrip(
    TripRequestSubmitted event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripBlocStatus.requesting));

    final result = await _tripRepository.requestTrip(
      pickup: event.pickup,
      dropoff: event.dropoff,
      vehicleType: event.vehicleType,
      paymentMethod: event.paymentMethod,
      promoCode: event.promoCode,
      note: event.note,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: failure.message,
      )),
      (trip) {
        emit(state.copyWith(
          status: TripBlocStatus.searchingDriver,
          currentTrip: trip,
        ));
        // Subscribe to trip updates
        add(TripSubscribeRequested(tripId: trip.id));
      },
    );
  }

  Future<void> _onCancelTrip(
    TripCancelRequested event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripBlocStatus.cancelling));

    final result = await _tripRepository.cancelTrip(
      tripId: event.tripId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: TripBlocStatus.cancelled,
        currentTrip: null,
      )),
    );
  }

  Future<void> _onSubscribeToTrip(
    TripSubscribeRequested event,
    Emitter<TripState> emit,
  ) async {
    await _tripSubscription?.cancel();

    _tripSubscription = _tripRepository.streamTrip(event.tripId).listen(
      (result) {
        result.fold(
          (failure) => add(TripUpdated(
            trip: state.currentTrip!,
            errorMessage: failure.message,
          )),
          (trip) => add(TripUpdated(trip: trip)),
        );
      },
    );
  }

  void _onTripUpdated(
    TripUpdated event,
    Emitter<TripState> emit,
  ) {
    final trip = event.trip;

    TripBlocStatus newStatus;
    switch (trip.status) {
      case domain.TripStatus.pending:
        newStatus = TripBlocStatus.searchingDriver;
        break;
      case domain.TripStatus.accepted:
        newStatus = TripBlocStatus.driverMatched;
        break;
      case domain.TripStatus.arrivedAtPickup:
        newStatus = TripBlocStatus.driverArrived;
        break;
      case domain.TripStatus.inProgress:
        newStatus = TripBlocStatus.inProgress;
        break;
      case domain.TripStatus.completed:
        newStatus = TripBlocStatus.completed;
        break;
      case domain.TripStatus.cancelled:
        newStatus = TripBlocStatus.cancelled;
        break;
      case domain.TripStatus.noDriverFound:
        newStatus = TripBlocStatus.noDriverFound;
        break;
    }

    emit(state.copyWith(
      status: newStatus,
      currentTrip: trip,
      errorMessage: event.errorMessage,
    ));
  }

  Future<void> _onRatingSubmitted(
    TripRatingSubmitted event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(status: TripBlocStatus.rating));

    final result = await _tripRepository.rateTrip(
      tripId: event.tripId,
      rating: event.rating,
      comment: event.comment,
      feedbackTags: event.feedbackTags,
      tipAmount: event.tipAmount,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: TripBlocStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: TripBlocStatus.rated,
      )),
    );
  }

  void _onReset(
    TripReset event,
    Emitter<TripState> emit,
  ) {
    _tripSubscription?.cancel();
    emit(const TripState.initial());
  }

  @override
  Future<void> close() {
    _tripSubscription?.cancel();
    return super.close();
  }
}
