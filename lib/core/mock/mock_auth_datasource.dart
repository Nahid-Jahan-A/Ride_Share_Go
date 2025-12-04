import 'dart:async';

import '../../features/auth/domain/entities/user.dart';
import '../data/datasources/datasource_interface.dart';
import 'mock_data.dart';

/// Mock implementation of AuthDataSource for testing without Firebase
class MockAuthDataSource implements AuthDataSource {
  User? _currentUser;
  AuthUser? _currentAuthUser;
  final _authStateController = StreamController<AuthUser?>.broadcast();
  String? _pendingVerificationId;
  String? _pendingPhone;

  // Simulated delay for realistic API behavior
  static const _delay = Duration(milliseconds: 500);

  @override
  Future<void> initialize() async {
    // No initialization needed for mock
  }

  @override
  Future<void> dispose() async {
    _authStateController.close();
  }

  @override
  AuthUser? get currentUser => _currentAuthUser;

  @override
  Future<AuthResponse> login(String identifier, String password) async {
    await Future.delayed(_delay);

    // Find user by phone or email
    final allUsers = [...MockData.passengers, ...MockData.driverUsers];
    final user = allUsers.cast<User?>().firstWhere(
          (u) => u?.phone == identifier || u?.email == identifier,
          orElse: () => null,
        );

    if (user == null) {
      throw Exception('User not found');
    }

    // Simple password check (in mock, any password works or use default)
    if (password != MockData.defaultPassword && password != 'password') {
      throw Exception('Invalid password');
    }

    _currentUser = user;
    _currentAuthUser = AuthUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.fullName,
    );
    _authStateController.add(_currentAuthUser);

    return AuthResponse(
      user: _currentAuthUser!,
      token: 'mock_access_token_${user.id}',
      refreshToken: 'mock_refresh_token_${user.id}',
    );
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    await Future.delayed(_delay);

    // Generate new user ID
    final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    final newUser = User(
      id: newId,
      tenantId: MockData.tenantId,
      userType: request.userType == 'driver' ? UserType.driver : UserType.passenger,
      phone: request.phone,
      email: request.email,
      fullName: request.fullName,
      status: UserStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _currentUser = newUser;
    _currentAuthUser = AuthUser(
      id: newUser.id,
      email: newUser.email,
      phone: newUser.phone,
      displayName: newUser.fullName,
    );
    _authStateController.add(_currentAuthUser);

    return AuthResponse(
      user: _currentAuthUser!,
      token: 'mock_access_token_$newId',
      refreshToken: 'mock_refresh_token_$newId',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _currentAuthUser = null;
    _authStateController.add(null);
  }

  @override
  Stream<AuthUser?> get authStateChanges => _authStateController.stream;

  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(_delay);
    _pendingVerificationId = 'mock_verification_${DateTime.now().millisecondsSinceEpoch}';
    _pendingPhone = phone;
    // In mock, OTP is always "123456"
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    await Future.delayed(_delay);

    // Accept "123456" as the mock OTP
    if (otp != '123456') {
      throw Exception('Invalid OTP');
    }

    // Find or create user with pending phone
    final allUsers = [...MockData.passengers, ...MockData.driverUsers];
    var user = allUsers.cast<User?>().firstWhere(
          (u) => u?.phone == phone,
          orElse: () => null,
        );

    if (user == null) {
      // Create new user if not exists
      final newId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      user = User(
        id: newId,
        tenantId: MockData.tenantId,
        userType: UserType.passenger,
        phone: phone,
        fullName: 'New User',
        status: UserStatus.active,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    _currentUser = user;
    _currentAuthUser = AuthUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.fullName,
    );
    _authStateController.add(_currentAuthUser);

    _pendingVerificationId = null;
    _pendingPhone = null;

    return AuthResponse(
      user: _currentAuthUser!,
      token: 'mock_access_token_${user.id}',
      refreshToken: 'mock_refresh_token_${user.id}',
    );
  }

  @override
  Future<String?> refreshToken() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser == null) {
      return null;
    }
    return 'mock_access_token_refreshed_${_currentUser!.id}';
  }

  /// Get the current user entity (for internal use)
  User? get currentUserEntity => _currentUser;

  /// Set current user directly (for testing)
  void setCurrentUser(User user) {
    _currentUser = user;
    _currentAuthUser = AuthUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.fullName,
    );
    _authStateController.add(_currentAuthUser);
  }

  /// Quick login for testing (auto-login as default passenger)
  Future<AuthResponse> quickLogin({bool asDriver = false}) async {
    final user = asDriver ? MockData.driverUsers.first : MockData.passengers.first;
    _currentUser = user;
    _currentAuthUser = AuthUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.fullName,
    );
    _authStateController.add(_currentAuthUser);

    return AuthResponse(
      user: _currentAuthUser!,
      token: 'mock_access_token_${user.id}',
      refreshToken: 'mock_refresh_token_${user.id}',
    );
  }
}
