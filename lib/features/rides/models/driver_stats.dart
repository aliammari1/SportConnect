import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
part 'driver_stats.freezed.dart';
part 'driver_stats.g.dart';

/// Transaction types exposed by the driver earnings feed.
///
/// Keep this narrower than payment/payout enums so earnings UI only models the
/// categories it actually renders from the `transactions` collection.
enum EarningsTransactionType { ride, bonus, refund, payout }

/// Driver statistics - converted to Freezed for consistency
@freezed
abstract class DriverStats with _$DriverStats {
  const factory DriverStats({
    @Default('') String driverId,
    @Default(0.0) double rating,

    // Rides
    @Default(0) int totalRides,
    @Default(0) int ridesToday,
    @Default(0) int ridesThisWeek,
    @Default(0) int ridesThisMonth,
    @Default(0) int pendingRequests,

    // Earnings
    @Default(0) int totalEarningsInCents,
    @Default(0) int earningsTodayInCents,
    @Default(0) int earningsThisWeekInCents,
    @Default(0) int earningsThisMonthInCents,
    @Default(0) int totalSpentInCents,

    // Distance & status
    @Default(0.0) double totalDistance,
    @Default(null) @TimestampConverter() DateTime? lastRideAt,
  }) = _DriverStats;
  const DriverStats._();

  factory DriverStats.fromJson(Map<String, dynamic> json) =>
      _$DriverStatsFromJson(_normalizeDriverStatsJson(json));

  /// Net earnings after the driver's own spend on the platform.
  int get netEarningsInCents => totalEarningsInCents - totalSpentInCents;

  /// Average gross earnings per completed ride, in cents.
  int get averageEarningsPerRideInCents =>
      totalRides > 0 ? (totalEarningsInCents / totalRides).round() : 0;

  /// Whether the driver has completed at least one ride.
  bool get hasRides => totalRides > 0;

  /// Whether there are requests awaiting the driver's response.
  bool get hasPendingRequests => pendingRequests > 0;
}

Map<String, dynamic> _normalizeDriverStatsJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);

  int majorUnitsToCents(String key) {
    final value = normalized[key];
    if (value is num) return (value * 100).round();
    return 0;
  }

  void fillCents(String centsKey, String legacyMajorKey) {
    final current = normalized[centsKey];
    final legacy = majorUnitsToCents(legacyMajorKey);
    if (current == null || (current is num && current == 0 && legacy > 0)) {
      normalized[centsKey] = legacy;
    }
  }

  fillCents('totalEarningsInCents', 'totalEarnings');
  fillCents('earningsTodayInCents', 'earningsToday');
  fillCents('earningsThisWeekInCents', 'earningsThisWeek');
  fillCents('earningsThisMonthInCents', 'earningsThisMonth');

  return normalized;
}

/// Earnings Transaction - converted to Freezed
@freezed
abstract class EarningsTransaction with _$EarningsTransaction {
  const factory EarningsTransaction({
    required String id,
    required String rideId,
    required int amountInCents,
    required String description,
    @RequiredTimestampConverter() required DateTime createdAt,
    @Default(EarningsTransactionType.ride)
    EarningsTransactionType type, // ride, bonus, refund, payout
  }) = _EarningsTransaction;
  const EarningsTransaction._();

  factory EarningsTransaction.fromJson(Map<String, dynamic> json) =>
      _$EarningsTransactionFromJson(json);

  /// Whether this entry reduces the driver's balance (refund or payout).
  bool get isDebit =>
      type == EarningsTransactionType.refund ||
      type == EarningsTransactionType.payout;

  /// Signed amount: positive for credits, negative for debits.
  int get signedAmountInCents => isDebit ? -amountInCents : amountInCents;
}
