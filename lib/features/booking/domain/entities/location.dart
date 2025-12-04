import 'package:equatable/equatable.dart';

/// Location entity for coordinates
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;
  final String? placeName;
  final String? geoHash;

  const Location({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeId,
    this.placeName,
    this.geoHash,
  });

  /// Create location with generated geohash
  factory Location.withGeoHash({
    required double latitude,
    required double longitude,
    String? address,
    String? placeId,
    String? placeName,
    int precision = 6,
  }) {
    return Location(
      latitude: latitude,
      longitude: longitude,
      address: address,
      placeId: placeId,
      placeName: placeName,
      geoHash: _generateGeoHash(latitude, longitude, precision),
    );
  }

  static String _generateGeoHash(double latitude, double longitude, int precision) {
    const base32 = '0123456789bcdefghjkmnpqrstuvwxyz';
    var latRange = [-90.0, 90.0];
    var lonRange = [-180.0, 180.0];
    var isEven = true;
    var bit = 0;
    var ch = 0;
    var hash = '';

    while (hash.length < precision) {
      if (isEven) {
        final mid = (lonRange[0] + lonRange[1]) / 2;
        if (longitude > mid) {
          ch |= 1 << (4 - bit);
          lonRange[0] = mid;
        } else {
          lonRange[1] = mid;
        }
      } else {
        final mid = (latRange[0] + latRange[1]) / 2;
        if (latitude > mid) {
          ch |= 1 << (4 - bit);
          latRange[0] = mid;
        } else {
          latRange[1] = mid;
        }
      }

      isEven = !isEven;
      if (bit < 4) {
        bit++;
      } else {
        hash += base32[ch];
        bit = 0;
        ch = 0;
      }
    }

    return hash;
  }

  /// Get display name for the location
  String get displayName => placeName ?? address ?? '$latitude, $longitude';

  /// Short display name
  String get shortName {
    if (placeName != null) return placeName!;
    if (address != null) {
      final parts = address!.split(',');
      return parts.first.trim();
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  @override
  List<Object?> get props => [latitude, longitude, address, placeId, placeName, geoHash];
}

/// Driver location with additional movement data
class DriverLocation extends Equatable {
  final String driverId;
  final double latitude;
  final double longitude;
  final double heading; // Direction in degrees (0-360)
  final double speed; // km/h
  final double accuracy; // GPS accuracy in meters
  final String geoHash;
  final String? currentTripId;
  final DateTime timestamp;

  const DriverLocation({
    required this.driverId,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.accuracy,
    required this.geoHash,
    this.currentTripId,
    required this.timestamp,
  });

  /// Convert to basic Location
  Location toLocation() {
    return Location(
      latitude: latitude,
      longitude: longitude,
      geoHash: geoHash,
    );
  }

  @override
  List<Object?> get props => [
        driverId,
        latitude,
        longitude,
        heading,
        speed,
        accuracy,
        geoHash,
        currentTripId,
        timestamp,
      ];
}

/// Saved location (favorites)
class SavedLocation extends Equatable {
  final String id;
  final String userId;
  final String name; // e.g., "Home", "Work"
  final Location location;
  final SavedLocationType type;
  final DateTime createdAt;

  const SavedLocation({
    required this.id,
    required this.userId,
    required this.name,
    required this.location,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, location, type, createdAt];
}

/// Type of saved location
enum SavedLocationType {
  home,
  work,
  other,
}
