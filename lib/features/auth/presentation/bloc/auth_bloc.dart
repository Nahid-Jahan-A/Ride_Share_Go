import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication Bloc
/// Manages authentication state across the app
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    debugPrint('[AuthBloc] Initializing...');
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSendOtpRequested>(_onSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) {
        debugPrint('[AuthBloc] Auth state changed: user=${user?.fullName}');
        add(AuthUserChanged(user));
      },
      onError: (e) => debugPrint('[AuthBloc] Auth stream error: $e'),
    );
    debugPrint('[AuthBloc] Initialized');
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] Auth check requested');
    final result = await _authRepository.getCurrentUser();
    debugPrint('[AuthBloc] getCurrentUser result: $result');

    result.fold(
      (failure) {
        debugPrint('[AuthBloc] Auth check failed: ${failure.message}');
        emit(const AuthState.unauthenticated());
      },
      (user) {
        debugPrint('[AuthBloc] Auth check success: user=${user?.fullName}');
        if (user != null) {
          emit(AuthState.authenticated(user));
        } else {
          emit(const AuthState.unauthenticated());
        }
      },
    );
    debugPrint('[AuthBloc] Auth check completed, state: ${state.status}');
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.login(
      identifier: event.identifier,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = event.isDriver
        ? await _authRepository.registerDriver(
            phone: event.phone,
            email: event.email,
            fullName: event.fullName,
            password: event.password,
            licenseNumber: event.licenseNumber!,
          )
        : await _authRepository.registerPassenger(
            phone: event.phone,
            email: event.email,
            fullName: event.fullName,
            password: event.password,
          );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.pendingVerification(user)),
    );
  }

  Future<void> _onSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.sendOtp(phone: event.phone);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(AuthState.otpSent(event.phone)),
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.verifyOtp(
      phone: event.phone,
      otp: event.otp,
    );

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
