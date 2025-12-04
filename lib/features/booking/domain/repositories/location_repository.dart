import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/location.dart';

/// Abstract location repository
abstract class LocationRepository {
  /// Get current device location
  Future<Either<Failure, Location>> getCurrentLocation();

  /// Stream location updates
  Stream<Either<Failure, Location>> streamLocation();

  /// Search for places by query
  Future<Either<Failure, List<PlaceSearchResult>>> searchPlaces({
    required String query,
    Location? nearLocation,
    int limit = 10,
  });

  /// Get place details by place ID
  Future<Either<Failure, Location>> getPlaceDetails(String placeId);

  /// Reverse geocode coordinates to address
  Future<Either<Failure, Location>> reverseGeocode({
    required double latitude,
    required double longitude,
  });

  /// Get saved locations for user
  Future<Either<Failure, List<SavedLocation>>> getSavedLocations();

  /// Add saved location
  Future<Either<Failure, SavedLocation>> addSavedLocation({
    required String name,
    required Location location,
    required SavedLocationType type,
  });

  /// Update saved location
  Future<Either<Failure, SavedLocation>> updateSavedLocation({
    required String id,
    String? name,
    Location? location,
    SavedLocationType? type,
  });

  /// Delete saved location
  Future<Either<Failure, void>> deleteSavedLocation(String id);

  /// Get recent search locations
  Future<Either<Failure, List<Location>>> getRecentSearches();

  /// Add to recent searches
  Future<Either<Failure, void>> addRecentSearch(Location location);

  /// Clear recent searches
  Future<Either<Failure, void>> clearRecentSearches();

  /// Check if location permission is granted
  Future<bool> hasLocationPermission();

  /// Request location permission
  Future<Either<Failure, bool>> requestLocationPermission();

  /// Check if location service is enabled
  Future<bool> isLocationServiceEnabled();
}

/// Driver-specific location repository
abstract class DriverLocationRepository {
  /// Update driver location
  Future<Either<Failure, void>> updateLocation(DriverLocation location);

  /// Start location tracking (background)
  Future<Either<Failure, void>> startTracking();

  /// Stop location tracking
  Future<Either<Failure, void>> stopTracking();

  /// Stream driver location updates
  Stream<Either<Failure, DriverLocation>> streamDriverLocation(String driverId);

  /// Get nearby drivers
  Future<Either<Failure, List<NearbyDriverInfo>>> getNearbyDrivers({
    required Location center,
    required double radiusKm,
    String? vehicleType,
  });

  /// Stream nearby drivers (for map view)
  Stream<Either<Failure, List<NearbyDriverInfo>>> streamNearbyDrivers({
    required Location center,
    required double radiusKm,
  });
}

/// Place search result
class PlaceSearchResult {
  final String placeId;
  final String name;
  final String address;
  final String? secondaryText;
  final double? distanceKm;
  final PlaceType type;

  const PlaceSearchResult({
    required this.placeId,
    required this.name,
    required this.address,
    this.secondaryText,
    this.distanceKm,
    this.type = PlaceType.other,
  });
}

/// Place type for icons/categorization
enum PlaceType {
  airport,
  trainStation,
  busStation,
  hospital,
  hotel,
  restaurant,
  shopping,
  home,
  work,
  other,
}

/// Nearby driver info for passenger view
class NearbyDriverInfo {
  final String driverId;
  final String? driverName;
  final Location location;
  final double distanceKm;
  final Duration eta;
  final String vehicleType;
  final double? rating;
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? vehicleColor;

  const NearbyDriverInfo({
    required this.driverId,
    this.driverName,
    required this.location,
    required this.distanceKm,
    required this.eta,
    required this.vehicleType,
    this.rating,
    this.vehiclePlate,
    this.vehicleModel,
    this.vehicleColor,
  });
}
