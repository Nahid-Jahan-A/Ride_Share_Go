part of 'auth_bloc.dart';

/// Auth status enum
enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  loading,
  pendingVerification,
  otpSent,
  error,
}

/// Auth state
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? phone; // For OTP flow
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.phone,
    this.errorMessage,
  });

  /// Unknown state (initial)
  const AuthState.unknown() : this._();

  /// Loading state
  const AuthState.loading() : this._(status: AuthStatus.loading);

  /// Authenticated state
  const AuthState.authenticated(User user)
      : this._(
          status: AuthStatus.authenticated,
          user: user,
        );

  /// Unauthenticated state
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  /// Pending verification state
  const AuthState.pendingVerification(User user)
      : this._(
          status: AuthStatus.pendingVerification,
          user: user,
        );

  /// OTP sent state
  const AuthState.otpSent(String phone)
      : this._(
          status: AuthStatus.otpSent,
          phone: phone,
        );

  /// Error state
  const AuthState.error(String message)
      : this._(
          status: AuthStatus.error,
          errorMessage: message,
        );

  /// Check if authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Check if loading
  bool get isLoading => status == AuthStatus.loading;

  /// Check if has error
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, user, phone, errorMessage];
}
