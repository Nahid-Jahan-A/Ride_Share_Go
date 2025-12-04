import 'package:equatable/equatable.dart';

/// Rater type enum
enum RaterType {
  passenger,
  driver,
}

/// Rating category for feedback
enum RatingCategory {
  // Passenger -> Driver categories
  professionalism,
  vehicleCleanliness,
  navigation,
  safety,
  communication,
  onTime,

  // Driver -> Passenger categories
  behavior,
  punctuality,
  pickupLocationAccuracy,
  respect,

  // Common
  other,
}

/// Rating entity
class Rating extends Equatable {
  final String id;
  final String tripId;
  final String raterId;
  final String ratedId;
  final RaterType raterType;
  final int score; // 1-5
  final List<RatingCategory>? categories;
  final String? comment;
  final bool isAnonymous;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.tripId,
    required this.raterId,
    required this.ratedId,
    required this.raterType,
    required this.score,
    this.categories,
    this.comment,
    this.isAnonymous = false,
    required this.createdAt,
  });

  /// Check if this is a low rating
  bool get isLowRating => score <= 3;

  /// Check if this is a critical rating
  bool get isCriticalRating => score <= 2;

  @override
  List<Object?> get props => [
        id,
        tripId,
        raterId,
        ratedId,
        raterType,
        score,
        categories,
        comment,
        isAnonymous,
        createdAt,
      ];
}

/// User rating summary
class UserRatingSummary extends Equatable {
  final String userId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // {5: 100, 4: 50, ...}
  final List<RatingCategory> topCompliments;
  final DateTime lastUpdated;

  const UserRatingSummary({
    required this.userId,
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    this.topCompliments = const [],
    required this.lastUpdated,
  });

  /// Get percentage for a specific star rating
  double getPercentageForStar(int star) {
    if (totalRatings == 0) return 0;
    return ((ratingDistribution[star] ?? 0) / totalRatings) * 100;
  }

  /// Get count for 5-star ratings
  int get fiveStarCount => ratingDistribution[5] ?? 0;

  @override
  List<Object?> get props => [
        userId,
        averageRating,
        totalRatings,
        ratingDistribution,
        topCompliments,
        lastUpdated,
      ];
}

/// Rating request model
class RatingRequest extends Equatable {
  final String tripId;
  final int score;
  final List<RatingCategory>? categories;
  final String? comment;
  final double? tipAmount;

  const RatingRequest({
    required this.tripId,
    required this.score,
    this.categories,
    this.comment,
    this.tipAmount,
  });

  @override
  List<Object?> get props => [tripId, score, categories, comment, tipAmount];
}

/// Predefined feedback options for low ratings
class RatingFeedbackOption {
  final RatingCategory category;
  final String label;
  final RaterType applicableTo;

  const RatingFeedbackOption({
    required this.category,
    required this.label,
    required this.applicableTo,
  });

  /// Default feedback options for passengers rating drivers
  static const List<RatingFeedbackOption> passengerToDriverOptions = [
    RatingFeedbackOption(
      category: RatingCategory.professionalism,
      label: 'Unprofessional behavior',
      applicableTo: RaterType.passenger,
    ),
    RatingFeedbackOption(
      category: RatingCategory.vehicleCleanliness,
      label: 'Vehicle was not clean',
      applicableTo: RaterType.passenger,
    ),
    RatingFeedbackOption(
      category: RatingCategory.navigation,
      label: 'Took wrong route',
      applicableTo: RaterType.passenger,
    ),
    RatingFeedbackOption(
      category: RatingCategory.safety,
      label: 'Unsafe driving',
      applicableTo: RaterType.passenger,
    ),
    RatingFeedbackOption(
      category: RatingCategory.onTime,
      label: 'Arrived late',
      applicableTo: RaterType.passenger,
    ),
  ];

  /// Default feedback options for drivers rating passengers
  static const List<RatingFeedbackOption> driverToPassengerOptions = [
    RatingFeedbackOption(
      category: RatingCategory.behavior,
      label: 'Rude behavior',
      applicableTo: RaterType.driver,
    ),
    RatingFeedbackOption(
      category: RatingCategory.punctuality,
      label: 'Made me wait too long',
      applicableTo: RaterType.driver,
    ),
    RatingFeedbackOption(
      category: RatingCategory.pickupLocationAccuracy,
      label: 'Incorrect pickup location',
      applicableTo: RaterType.driver,
    ),
    RatingFeedbackOption(
      category: RatingCategory.respect,
      label: 'Disrespectful',
      applicableTo: RaterType.driver,
    ),
  ];
}
