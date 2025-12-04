import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Abstract authentication repository
/// This is the contract that any auth implementation must follow
abstract class AuthRepository {
  /// Login with phone/email and password
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  });

  /// Register a new passenger account
  Future<Either<Failure, User>> registerPassenger({
    required String phone,
    String? email,
    required String fullName,
    required String password,
  });

  /// Register a new driver account
  Future<Either<Failure, User>> registerDriver({
    required String phone,
    String? email,
    required String fullName,
    required String password,
    required String licenseNumber,
  });

  /// Send OTP to phone number
  Future<Either<Failure, void>> sendOtp({required String phone});

  /// Verify OTP code
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Resend OTP code
  Future<Either<Failure, void>> resendOtp({required String phone});

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Request password reset
  Future<Either<Failure, void>> requestPasswordReset({required String email});

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Update password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Delete account
  Future<Either<Failure, void>> deleteAccount();

  /// Refresh auth token
  Future<Either<Failure, String>> refreshToken();
}
