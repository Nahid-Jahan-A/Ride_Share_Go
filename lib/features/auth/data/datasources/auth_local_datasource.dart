import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart';

/// Local data source for auth-related cached data
abstract class AuthLocalDataSource {
  /// Cache user data
  Future<void> cacheUser(User user);

  /// Get cached user
  Future<User?> getCachedUser();

  /// Clear cached user
  Future<void> clearCachedUser();

  /// Cache auth token
  Future<void> cacheToken(String token);

  /// Get cached token
  Future<String?> getCachedToken();

  /// Clear cached token
  Future<void> clearCachedToken();

  /// Cache refresh token
  Future<void> cacheRefreshToken(String token);

  /// Get cached refresh token
  Future<String?> getCachedRefreshToken();

  /// Clear all auth data
  Future<void> clearAll();
}

/// Implementation using SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _sharedPreferences;

  AuthLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  @override
  Future<void> cacheUser(User user) async {
    final userJson = json.encode(_userToJson(user));
    await _sharedPreferences.setString(StorageKeys.userId, userJson);
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = _sharedPreferences.getString(StorageKeys.userId);
    if (userJson == null) return null;

    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return _userFromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    await _sharedPreferences.remove(StorageKeys.userId);
  }

  @override
  Future<void> cacheToken(String token) async {
    await _sharedPreferences.setString(StorageKeys.accessToken, token);
  }

  @override
  Future<String?> getCachedToken() async {
    return _sharedPreferences.getString(StorageKeys.accessToken);
  }

  @override
  Future<void> clearCachedToken() async {
    await _sharedPreferences.remove(StorageKeys.accessToken);
  }

  @override
  Future<void> cacheRefreshToken(String token) async {
    await _sharedPreferences.setString(StorageKeys.refreshToken, token);
  }

  @override
  Future<String?> getCachedRefreshToken() async {
    return _sharedPreferences.getString(StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      clearCachedUser(),
      clearCachedToken(),
      _sharedPreferences.remove(StorageKeys.refreshToken),
    ]);
  }

  Map<String, dynamic> _userToJson(User user) {
    return {
      'id': user.id,
      'tenantId': user.tenantId,
      'userType': user.userType.name,
      'phone': user.phone,
      'email': user.email,
      'fullName': user.fullName,
      'avatarUrl': user.avatarUrl,
      'status': user.status.name,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
  }

  User _userFromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      tenantId: json['tenantId'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['userType'],
        orElse: () => UserType.passenger,
      ),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      fullName: json['fullName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
