import 'package:equatable/equatable.dart';

/// User type enum
enum UserType { passenger, driver }

/// User status enum
enum UserStatus { active, inactive, suspended, pendingVerification }

/// User entity - core domain model
class User extends Equatable {
  final String id;
  final String tenantId;
  final UserType userType;
  final String phone;
  final String? email;
  final String fullName;
  final String? avatarUrl;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.tenantId,
    required this.userType,
    required this.phone,
    this.email,
    required this.fullName,
    this.avatarUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if user is a driver
  bool get isDriver => userType == UserType.driver;

  /// Check if user is a passenger
  bool get isPassenger => userType == UserType.passenger;

  /// Check if user is active
  bool get isActive => status == UserStatus.active;

  /// Check if user is verified
  bool get isVerified => status != UserStatus.pendingVerification;

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? tenantId,
    UserType? userType,
    String? phone,
    String? email,
    String? fullName,
    String? avatarUrl,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        userType,
        phone,
        email,
        fullName,
        avatarUrl,
        status,
        createdAt,
        updatedAt,
      ];
}

/// Driver profile entity - extends user with driver-specific data
class DriverProfile extends Equatable {
  final String userId;
  final String? vehicleId;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final double averageRating;
  final int totalTrips;
  final int totalEarnings;
  final bool isVerified;
  final bool isOnline;
  final DriverStatus driverStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverProfile({
    required this.userId,
    this.vehicleId,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.averageRating = 5.0,
    this.totalTrips = 0,
    this.totalEarnings = 0,
    this.isVerified = false,
    this.isOnline = false,
    this.driverStatus = DriverStatus.offline,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if driver can go online
  bool get canGoOnline => isVerified && vehicleId != null;

  @override
  List<Object?> get props => [
        userId,
        vehicleId,
        licenseNumber,
        licenseExpiry,
        averageRating,
        totalTrips,
        totalEarnings,
        isVerified,
        isOnline,
        driverStatus,
        createdAt,
        updatedAt,
      ];
}

/// Driver status for trip management
enum DriverStatus {
  offline,
  online,
  busy, // Has accepted a trip but not started
  onTrip, // Currently on an active trip
}
