import 'package:equatable/equatable.dart';

/// Vehicle type enum
enum VehicleType {
  economy,
  comfort,
  premium,
  suv,
  van,
}

/// Vehicle status enum
enum VehicleStatus {
  active,
  inactive,
  maintenance,
  retired,
}

/// Vehicle entity
class Vehicle extends Equatable {
  final String id;
  final String tenantId;
  final String? assignedDriverId;

  // Vehicle details
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final String? vin;
  final VehicleType type;
  final int passengerCapacity;
  final List<VehicleFeature> features;

  // Status
  final VehicleStatus status;
  final int? currentMileage;
  final DateTime? lastInspectionDate;
  final DateTime? nextMaintenanceDate;

  // Images
  final String? imageUrl;
  final List<String>? additionalImages;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.tenantId,
    this.assignedDriverId,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    this.vin,
    required this.type,
    required this.passengerCapacity,
    this.features = const [],
    required this.status,
    this.currentMileage,
    this.lastInspectionDate,
    this.nextMaintenanceDate,
    this.imageUrl,
    this.additionalImages,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get display name (Make Model)
  String get displayName => '$make $model';

  /// Get full display name with year
  String get fullDisplayName => '$year $make $model';

  /// Check if vehicle is available
  bool get isAvailable => status == VehicleStatus.active && assignedDriverId != null;

  /// Check if maintenance is due
  bool get isMaintenanceDue {
    if (nextMaintenanceDate == null) return false;
    return DateTime.now().isAfter(nextMaintenanceDate!);
  }

  @override
  List<Object?> get props => [
        id,
        tenantId,
        assignedDriverId,
        make,
        model,
        year,
        color,
        plateNumber,
        vin,
        type,
        passengerCapacity,
        features,
        status,
        currentMileage,
        lastInspectionDate,
        nextMaintenanceDate,
        imageUrl,
        additionalImages,
        createdAt,
        updatedAt,
      ];
}

/// Vehicle features/amenities
enum VehicleFeature {
  airConditioning,
  wifi,
  childSeat,
  wheelchairAccessible,
  petFriendly,
  charger,
  water,
  magazine,
  musicSystem,
}

/// Vehicle type configuration for pricing and display
class VehicleTypeConfig extends Equatable {
  final VehicleType type;
  final String name;
  final String description;
  final String iconPath;
  final int minCapacity;
  final int maxCapacity;
  final double baseMultiplier; // Price multiplier compared to economy

  const VehicleTypeConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.minCapacity,
    required this.maxCapacity,
    required this.baseMultiplier,
  });

  static const List<VehicleTypeConfig> defaultConfigs = [
    VehicleTypeConfig(
      type: VehicleType.economy,
      name: 'Economy',
      description: 'Affordable everyday rides',
      iconPath: 'assets/icons/car_economy.svg',
      minCapacity: 1,
      maxCapacity: 4,
      baseMultiplier: 1.0,
    ),
    VehicleTypeConfig(
      type: VehicleType.comfort,
      name: 'Comfort',
      description: 'Newer cars with more space',
      iconPath: 'assets/icons/car_comfort.svg',
      minCapacity: 1,
      maxCapacity: 4,
      baseMultiplier: 1.3,
    ),
    VehicleTypeConfig(
      type: VehicleType.premium,
      name: 'Premium',
      description: 'Luxury vehicles for special occasions',
      iconPath: 'assets/icons/car_premium.svg',
      minCapacity: 1,
      maxCapacity: 4,
      baseMultiplier: 2.0,
    ),
    VehicleTypeConfig(
      type: VehicleType.suv,
      name: 'SUV',
      description: 'Extra space for groups and luggage',
      iconPath: 'assets/icons/car_suv.svg',
      minCapacity: 1,
      maxCapacity: 6,
      baseMultiplier: 1.5,
    ),
    VehicleTypeConfig(
      type: VehicleType.van,
      name: 'Van',
      description: 'For larger groups',
      iconPath: 'assets/icons/car_van.svg',
      minCapacity: 1,
      maxCapacity: 8,
      baseMultiplier: 2.0,
    ),
  ];

  @override
  List<Object?> get props => [
        type,
        name,
        description,
        iconPath,
        minCapacity,
        maxCapacity,
        baseMultiplier,
      ];
}
