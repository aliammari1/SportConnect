import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';

part 'ride_schedule.freezed.dart';
part 'ride_schedule.g.dart';

/// Ride schedule information
@freezed
abstract class RideSchedule with _$RideSchedule {
  const factory RideSchedule({
    @RequiredTimestampConverter() required DateTime departureTime,
    @TimestampConverter() DateTime? arrivalTime,
    @TimestampConverter() DateTime? actualDepartureTime,
    @Default(15) int flexibilityMinutes,
    @Default(false) bool isRecurring,
    @Default([]) List<int> recurringDays,
    @TimestampConverter() DateTime? recurringEndDate,
  }) = _RideSchedule;
  const RideSchedule._();

  factory RideSchedule.fromJson(Map<String, dynamic> json) =>
      _$RideScheduleFromJson(json);

  /// Check if ride is in the past (accounts for the flexibility window)
  bool get isPast =>
      DateTime.now().isAfter(departureTime.add(Duration(minutes: flexibilityMinutes)));

  /// Check if ride is upcoming (within next 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final diff = departureTime.difference(now);
    return diff.inHours <= 24 && diff.inHours >= 0;
  }

  /// Check if ride is happening soon (within flexibility window)
  bool get isHappeningSoon {
    final now = DateTime.now();
    final diff = departureTime.difference(now);
    return diff.inMinutes <= flexibilityMinutes && diff.inMinutes >= 0;
  }

  /// Whether the driver has stamped an actual departure.
  bool get hasDeparted => actualDepartureTime != null;

  /// Time remaining until departure (negative once the window has passed).
  Duration get timeUntilDeparture =>
      departureTime.difference(DateTime.now());

  /// Get departure window (earliest to latest)
  DateTimeRange get departureWindow {
    final earliest = departureTime.subtract(
      Duration(minutes: flexibilityMinutes),
    );
    final latest = departureTime.add(Duration(minutes: flexibilityMinutes));
    return DateTimeRange(start: earliest, end: latest);
  }
}

/// Helper class for date ranges
class DateTimeRange {
  DateTimeRange({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }
}
