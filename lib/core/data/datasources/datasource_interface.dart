/// Abstract interface for all remote data sources
/// Implementations can be Firebase, REST API, GraphQL, etc.
///
/// This abstraction allows easy switching between backends
/// without changing the business logic.
abstract class RemoteDataSource {
  /// Initialize the data source
  Future<void> initialize();

  /// Dispose of any resources
  Future<void> dispose();
}

/// Abstract interface for authentication
abstract class AuthDataSource extends RemoteDataSource {
  /// Login with phone/email and password
  Future<AuthResponse> login(String identifier, String password);

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request);

  /// Send OTP to phone number
  Future<void> sendOtp(String phone);

  /// Verify OTP code
  Future<AuthResponse> verifyOtp(String phone, String otp);

  /// Logout current user
  Future<void> logout();

  /// Refresh authentication token
  Future<String?> refreshToken();

  /// Get current auth state
  Stream<AuthUser?> get authStateChanges;

  /// Get current user
  AuthUser? get currentUser;
}

/// Abstract interface for real-time data operations
abstract class RealtimeDataSource extends RemoteDataSource {
  /// Subscribe to a document/path for real-time updates
  Stream<T> subscribe<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  );

  /// Subscribe to a collection for real-time updates
  Stream<List<T>> subscribeCollection<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  /// Set data at a path (create or overwrite)
  Future<void> set(String path, Map<String, dynamic> data);

  /// Update specific fields at a path
  Future<void> update(String path, Map<String, dynamic> data);

  /// Delete data at a path
  Future<void> delete(String path);

  /// Get data once from a path
  Future<T?> get<T>(String path, T Function(Map<String, dynamic>) fromJson);

  /// Query a collection
  Future<List<T>> query<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson, {
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
    String? startAfter,
  });
}

/// Abstract interface for location services
abstract class LocationDataSource extends RemoteDataSource {
  /// Update driver location
  Future<void> updateDriverLocation(String driverId, DriverLocationData location);

  /// Stream driver location updates
  Stream<DriverLocationData> streamDriverLocation(String driverId);

  /// Get nearby drivers
  Future<List<NearbyDriver>> getNearbyDrivers(
    double latitude,
    double longitude,
    double radiusKm, {
    String? vehicleType,
  });

  /// Stream nearby drivers (for dispatcher view)
  Stream<List<NearbyDriver>> streamNearbyDrivers(
    double latitude,
    double longitude,
    double radiusKm,
  );
}

/// Abstract interface for storage operations (files, images)
abstract class StorageDataSource extends RemoteDataSource {
  /// Upload a file and return the download URL
  Future<String> uploadFile(
    String path,
    List<int> bytes,
    String contentType,
  );

  /// Delete a file
  Future<void> deleteFile(String path);

  /// Get download URL for a file
  Future<String> getDownloadUrl(String path);
}

/// Abstract interface for push notifications
abstract class NotificationDataSource extends RemoteDataSource {
  /// Get FCM token
  Future<String?> getToken();

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Stream of incoming notifications
  Stream<NotificationPayload> get onNotification;

  /// Stream of notification taps
  Stream<NotificationPayload> get onNotificationTap;
}

// ============== Data Transfer Objects ==============

/// Auth response DTO
class AuthResponse {
  final AuthUser user;
  final String token;
  final String? refreshToken;

  const AuthResponse({
    required this.user,
    required this.token,
    this.refreshToken,
  });
}

/// Auth user DTO
class AuthUser {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
  });
}

/// Register request DTO
class RegisterRequest {
  final String phone;
  final String? email;
  final String fullName;
  final String password;
  final String userType; // 'passenger' or 'driver'
  final String tenantId;

  const RegisterRequest({
    required this.phone,
    this.email,
    required this.fullName,
    required this.password,
    required this.userType,
    required this.tenantId,
  });

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'email': email,
        'fullName': fullName,
        'password': password,
        'userType': userType,
        'tenantId': tenantId,
      };
}

/// Query filter for database queries
class QueryFilter {
  final String field;
  final FilterOperator operator;
  final dynamic value;

  const QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}

/// Filter operators
enum FilterOperator {
  equals,
  notEquals,
  lessThan,
  lessThanOrEquals,
  greaterThan,
  greaterThanOrEquals,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
}

/// Driver location DTO for data sources
class DriverLocationData {
  final String driverId;
  final double latitude;
  final double longitude;
  final double heading;
  final double speed;
  final double accuracy;
  final String geoHash;
  final String? currentTripId;
  final String status;
  final DateTime timestamp;

  const DriverLocationData({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.accuracy,
    required this.geoHash,
    this.currentTripId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'driverId': driverId,
        'latitude': latitude,
        'longitude': longitude,
        'heading': heading,
        'speed': speed,
        'accuracy': accuracy,
        'geoHash': geoHash,
        'currentTripId': currentTripId,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      driverId: json['driverId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      geoHash: json['geoHash'] as String,
      currentTripId: json['currentTripId'] as String?,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Nearby driver DTO
class NearbyDriver {
  final String driverId;
  final String? name;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final int? etaMinutes;
  final String vehicleType;
  final double? rating;
  final String? vehiclePlate;
  final String? vehicleModel;

  const NearbyDriver({
    required this.driverId,
    this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.etaMinutes,
    required this.vehicleType,
    this.rating,
    this.vehiclePlate,
    this.vehicleModel,
  });
}

/// Notification payload DTO
class NotificationPayload {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime receivedAt;

  const NotificationPayload({
    this.title,
    this.body,
    this.data,
    required this.receivedAt,
  });
}
