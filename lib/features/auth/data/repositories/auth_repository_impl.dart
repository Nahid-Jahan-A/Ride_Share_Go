import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/env/environment.dart';
import '../../../../core/data/datasources/datasource_interface.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, User>> login({
    required String identifier,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await _remoteDataSource.login(identifier, password);
      final user = _mapAuthUserToUser(response.user);

      // Cache user and token
      await _localDataSource.cacheUser(user);
      await _localDataSource.cacheToken(response.token);
      if (response.refreshToken != null) {
        await _localDataSource.cacheRefreshToken(response.refreshToken!);
      }

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerPassenger({
    required String phone,
    String? email,
    required String fullName,
    required String password,
  }) async {
    return _register(
      phone: phone,
      email: email,
      fullName: fullName,
      password: password,
      userType: 'passenger',
    );
  }

  @override
  Future<Either<Failure, User>> registerDriver({
    required String phone,
    String? email,
    required String fullName,
    required String password,
    required String licenseNumber,
  }) async {
    return _register(
      phone: phone,
      email: email,
      fullName: fullName,
      password: password,
      userType: 'driver',
    );
  }

  Future<Either<Failure, User>> _register({
    required String phone,
    String? email,
    required String fullName,
    required String password,
    required String userType,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final request = RegisterRequest(
        phone: phone,
        email: email,
        fullName: fullName,
        password: password,
        userType: userType,
        tenantId: Environment.tenantId,
      );

      final response = await _remoteDataSource.register(request);
      final user = _mapAuthUserToUser(response.user);

      // Cache user and token
      await _localDataSource.cacheUser(user);
      await _localDataSource.cacheToken(response.token);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({required String phone}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remoteDataSource.sendOtp(phone);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final response = await _remoteDataSource.verifyOtp(phone, otp);
      final user = _mapAuthUserToUser(response.user);

      await _localDataSource.cacheUser(user);
      await _localDataSource.cacheToken(response.token);

      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendOtp({required String phone}) async {
    return sendOtp(phone: phone);
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Still clear local data even if remote logout fails
      await _localDataSource.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    debugPrint('[AuthRepo] getCurrentUser called');
    try {
      // First check remote auth state
      final authUser = _remoteDataSource.currentUser;
      debugPrint('[AuthRepo] Remote currentUser: ${authUser?.id}');
      if (authUser != null) {
        // Get cached full user data
        try {
          final cachedUser = await _localDataSource.getCachedUser();
          debugPrint('[AuthRepo] Cached user: ${cachedUser?.id}');
          if (cachedUser != null && cachedUser.id == authUser.id) {
            debugPrint('[AuthRepo] Returning cached user');
            return Right(cachedUser);
          }
        } catch (e) {
          debugPrint('[AuthRepo] Error getting cached user: $e');
        }
        // If no cached data, return basic user
        debugPrint('[AuthRepo] Returning mapped auth user');
        return Right(_mapAuthUserToUser(authUser));
      }

      // No remote user, check cached
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        debugPrint('[AuthRepo] No remote user, cached user: ${cachedUser?.id}');
        return Right(cachedUser);
      } catch (e) {
        debugPrint('[AuthRepo] Error getting cached user: $e');
        return const Right(null);
      }
    } catch (e) {
      debugPrint('[AuthRepo] getCurrentUser error: $e');
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _remoteDataSource.authStateChanges.asyncMap((authUser) async {
      if (authUser == null) {
        await _localDataSource.clearAll();
        return null;
      }

      // Try to get full user from cache
      final cachedUser = await _localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.id == authUser.id) {
        return cachedUser;
      }

      return _mapAuthUserToUser(authUser);
    });
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user.fold((_) => false, (user) => user != null);
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset({required String email}) async {
    // TODO: Implement password reset
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // TODO: Implement password reset
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement password update
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    // TODO: Implement account deletion
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final token = await _remoteDataSource.refreshToken();
      if (token != null) {
        await _localDataSource.cacheToken(token);
        return Right(token);
      }
      return Left(AuthFailure.sessionExpired());
    } catch (e) {
      return Left(AuthFailure.sessionExpired());
    }
  }

  /// Map AuthUser DTO to User entity
  User _mapAuthUserToUser(AuthUser authUser) {
    return User(
      id: authUser.id,
      tenantId: Environment.tenantId,
      userType: UserType.passenger, // Default, should be fetched from Firestore
      phone: authUser.phone ?? '',
      email: authUser.email,
      fullName: authUser.displayName ?? '',
      avatarUrl: authUser.photoUrl,
      status: UserStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
