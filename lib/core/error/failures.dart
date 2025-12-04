import 'package:equatable/equatable.dart';

/// Base failure class for all app failures
/// Used in the Either pattern for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server-related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Local cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No account found with this email',
        code: 'USER_NOT_FOUND',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Your session has expired. Please login again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'You are not authorized to perform this action',
        code: 'UNAUTHORIZED',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'An account with this email already exists',
        code: 'EMAIL_ALREADY_IN_USE',
      );

  factory AuthFailure.phoneAlreadyInUse() => const AuthFailure(
        message: 'An account with this phone number already exists',
        code: 'PHONE_ALREADY_IN_USE',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak. Please use a stronger password.',
        code: 'WEAK_PASSWORD',
      );

  factory AuthFailure.invalidOtp() => const AuthFailure(
        message: 'Invalid OTP code. Please try again.',
        code: 'INVALID_OTP',
      );

  factory AuthFailure.otpExpired() => const AuthFailure(
        message: 'OTP has expired. Please request a new one.',
        code: 'OTP_EXPIRED',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Location/GPS failures
class LocationFailure extends Failure {
  const LocationFailure({
    required super.message,
    super.code = 'LOCATION_ERROR',
  });

  factory LocationFailure.serviceDisabled() => const LocationFailure(
        message: 'Please enable location services to continue',
        code: 'LOCATION_SERVICE_DISABLED',
      );

  factory LocationFailure.permissionDenied() => const LocationFailure(
        message: 'Location permission is required for this feature',
        code: 'LOCATION_PERMISSION_DENIED',
      );

  factory LocationFailure.permissionDeniedForever() => const LocationFailure(
        message: 'Please enable location permission in app settings',
        code: 'LOCATION_PERMISSION_DENIED_FOREVER',
      );

  factory LocationFailure.timeout() => const LocationFailure(
        message: 'Could not get your location. Please try again.',
        code: 'LOCATION_TIMEOUT',
      );
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code = 'PAYMENT_ERROR',
  });

  factory PaymentFailure.insufficientFunds() => const PaymentFailure(
        message: 'Insufficient balance. Please top up your wallet.',
        code: 'INSUFFICIENT_FUNDS',
      );

  factory PaymentFailure.cardDeclined() => const PaymentFailure(
        message: 'Your card was declined. Please try another payment method.',
        code: 'CARD_DECLINED',
      );

  factory PaymentFailure.paymentFailed() => const PaymentFailure(
        message: 'Payment failed. Please try again.',
        code: 'PAYMENT_FAILED',
      );
}

/// Trip-related failures
class TripFailure extends Failure {
  const TripFailure({
    required super.message,
    super.code = 'TRIP_ERROR',
  });

  factory TripFailure.noDriversAvailable() => const TripFailure(
        message: 'No drivers available in your area. Please try again later.',
        code: 'NO_DRIVERS_AVAILABLE',
      );

  factory TripFailure.alreadyInTrip() => const TripFailure(
        message: 'You already have an active trip',
        code: 'ALREADY_IN_TRIP',
      );

  factory TripFailure.tripNotFound() => const TripFailure(
        message: 'Trip not found',
        code: 'TRIP_NOT_FOUND',
      );

  factory TripFailure.cannotCancel() => const TripFailure(
        message: 'This trip cannot be cancelled at this stage',
        code: 'CANNOT_CANCEL',
      );

  factory TripFailure.driverNotFound() => const TripFailure(
        message: 'Driver not found or no longer available',
        code: 'DRIVER_NOT_FOUND',
      );
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNEXPECTED_ERROR',
  });
}
