/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server-related exceptions (API errors, Firebase errors, etc.)
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

/// Local cache/storage exceptions
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  factory AuthException.invalidCredentials() => const AuthException(
        message: 'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      );

  factory AuthException.sessionExpired() => const AuthException(
        message: 'Session expired. Please login again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthException.unauthorized() => const AuthException(
        message: 'You are not authorized to perform this action',
        code: 'UNAUTHORIZED',
      );
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Location/GPS exceptions
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code = 'LOCATION_ERROR',
  });

  factory LocationException.serviceDisabled() => const LocationException(
        message: 'Location services are disabled',
        code: 'LOCATION_SERVICE_DISABLED',
      );

  factory LocationException.permissionDenied() => const LocationException(
        message: 'Location permission denied',
        code: 'LOCATION_PERMISSION_DENIED',
      );

  factory LocationException.permissionDeniedForever() => const LocationException(
        message: 'Location permission permanently denied. Please enable in settings.',
        code: 'LOCATION_PERMISSION_DENIED_FOREVER',
      );
}

/// Payment exceptions
class PaymentException extends AppException {
  const PaymentException({
    required super.message,
    super.code = 'PAYMENT_ERROR',
    super.originalError,
  });

  factory PaymentException.insufficientFunds() => const PaymentException(
        message: 'Insufficient funds in wallet',
        code: 'INSUFFICIENT_FUNDS',
      );

  factory PaymentException.cardDeclined() => const PaymentException(
        message: 'Card was declined',
        code: 'CARD_DECLINED',
      );
}

/// Trip-related exceptions
class TripException extends AppException {
  const TripException({
    required super.message,
    super.code = 'TRIP_ERROR',
  });

  factory TripException.noDriversAvailable() => const TripException(
        message: 'No drivers available nearby',
        code: 'NO_DRIVERS_AVAILABLE',
      );

  factory TripException.alreadyInTrip() => const TripException(
        message: 'You already have an active trip',
        code: 'ALREADY_IN_TRIP',
      );

  factory TripException.tripNotFound() => const TripException(
        message: 'Trip not found',
        code: 'TRIP_NOT_FOUND',
      );

  factory TripException.cannotCancel() => const TripException(
        message: 'This trip cannot be cancelled',
        code: 'CANNOT_CANCEL',
      );
}
