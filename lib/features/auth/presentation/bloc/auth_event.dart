part of 'auth_bloc.dart';

/// Base auth event
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check current authentication status
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with identifier (phone/email) and password
class AuthLoginRequested extends AuthEvent {
  final String identifier;
  final String password;

  const AuthLoginRequested({
    required this.identifier,
    required this.password,
  });

  @override
  List<Object?> get props => [identifier, password];
}

/// Register new account
class AuthRegisterRequested extends AuthEvent {
  final String phone;
  final String? email;
  final String fullName;
  final String password;
  final bool isDriver;
  final String? licenseNumber;

  const AuthRegisterRequested({
    required this.phone,
    this.email,
    required this.fullName,
    required this.password,
    this.isDriver = false,
    this.licenseNumber,
  });

  @override
  List<Object?> get props => [phone, email, fullName, password, isDriver, licenseNumber];
}

/// Send OTP to phone
class AuthSendOtpRequested extends AuthEvent {
  final String phone;

  const AuthSendOtpRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Verify OTP code
class AuthVerifyOtpRequested extends AuthEvent {
  final String phone;
  final String otp;

  const AuthVerifyOtpRequested({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Auth state changed (from stream)
class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
