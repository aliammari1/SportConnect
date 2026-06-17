import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/converters/timestamp_converter.dart';
import 'package:sport_connect/core/models/location/location_point.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

/// Recurrence pattern for recurring events.
enum RecurrencePattern {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('biweekly')
  biweekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

/// Extension to provide display helpers for [RecurrencePattern].
extension RecurrencePatternX on RecurrencePattern {
  String get label {
    switch (this) {
      case RecurrencePattern.daily:
        return 'Every day';
      case RecurrencePattern.weekly:
        return 'Every week';
      case RecurrencePattern.biweekly:
        return 'Every 2 weeks';
      case RecurrencePattern.monthly:
        return 'Every month';
      case RecurrencePattern.yearly:
        return 'Every year';
    }
  }

  String get rruleFreq {
    switch (this) {
      case RecurrencePattern.daily:
        return 'DAILY';
      case RecurrencePattern.weekly:
        return 'WEEKLY';
      case RecurrencePattern.biweekly:
        return 'WEEKLY;INTERVAL=2';
      case RecurrencePattern.monthly:
        return 'MONTHLY';
      case RecurrencePattern.yearly:
        return 'YEARLY';
    }
  }

  /// Returns the immediate next occurrence start time for this pattern.
  DateTime nextOccurrenceFrom(DateTime startsAt) {
    return switch (this) {
      RecurrencePattern.daily => startsAt.add(const Duration(days: 1)),
      RecurrencePattern.weekly => startsAt.add(const Duration(days: 7)),
      RecurrencePattern.biweekly => startsAt.add(const Duration(days: 14)),
      RecurrencePattern.monthly => _addMonthsPreservingDay(startsAt, 1),
      RecurrencePattern.yearly => _addYearsPreservingDay(startsAt, 1),
    };
  }

  /// Get patterns that can repeat at least once between [startsAt] and [endsAt].
  /// If [endsAt] is before [startsAt], returns all patterns to avoid locking the UI
  /// while the user is still adjusting dates.
  static List<RecurrencePattern> getPatternsByWindow(
    DateTime startsAt,
    DateTime endsAt,
  ) {
    if (endsAt.isBefore(startsAt)) {
      return RecurrencePattern.values;
    }

    final patterns = <RecurrencePattern>[];
    for (final pattern in RecurrencePattern.values) {
      final nextOccurrence = pattern.nextOccurrenceFrom(startsAt);

      if (!nextOccurrence.isAfter(endsAt)) {
        patterns.add(pattern);
      }
    }

    return patterns;
  }
}

DateTime _addMonthsPreservingDay(DateTime value, int monthsToAdd) {
  final totalMonths = value.month - 1 + monthsToAdd;
  final nextYear = value.year + (totalMonths ~/ 12);
  final nextMonth = (totalMonths % 12) + 1;
  final maxDay = _daysInMonth(nextYear, nextMonth);
  final nextDay = value.day <= maxDay ? value.day : maxDay;
  return DateTime(
    nextYear,
    nextMonth,
    nextDay,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

DateTime _addYearsPreservingDay(DateTime value, int yearsToAdd) {
  final nextYear = value.year + yearsToAdd;
  final maxDay = _daysInMonth(nextYear, value.month);
  final nextDay = value.day <= maxDay ? value.day : maxDay;
  return DateTime(
    nextYear,
    value.month,
    nextDay,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  );
}

int _daysInMonth(int year, int month) {
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  return DateTime(year, month + 1, 0).day;
}

/// Per-participant carpool RSVP status for an event.
///
/// Backed by the string values persisted in [EventModel.rideStatuses]
/// (`'driving' | 'need_ride' | 'self_arranged'`). Use [EventRideStatusX.fromValue]
/// to parse a stored value defensively (unknown/legacy values map to `null`).
enum EventRideStatus {
  @JsonValue('driving')
  driving('driving'),
  @JsonValue('need_ride')
  needRide('need_ride'),
  @JsonValue('self_arranged')
  selfArranged('self_arranged');

  const EventRideStatus(this.value);

  /// The wire/JSON value persisted in Firestore.
  final String value;
}

/// Parsing and display helpers for [EventRideStatus].
extension EventRideStatusX on EventRideStatus {
  String get label {
    switch (this) {
      case EventRideStatus.driving:
        return 'Driving';
      case EventRideStatus.needRide:
        return 'Needs a ride';
      case EventRideStatus.selfArranged:
        return 'Self-arranged';
    }
  }

  /// Parse a stored string into an [EventRideStatus], or `null` if unknown.
  static EventRideStatus? fromValue(String? value) {
    if (value == null) return null;
    for (final status in EventRideStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}

/// Sport categories with display metadata.
enum EventType {
  // @JsonValue('football')
  // football,
  // @JsonValue('basketball')
  // basketball,
  // @JsonValue('volleyball')
  // volleyball,
  // @JsonValue('tennis')
  // tennis,
  @JsonValue('running')
  running,
  // @JsonValue('gym')
  // gym,
  // @JsonValue('swimming')
  // swimming,
  // @JsonValue('cycling')
  // cycling,
  // @JsonValue('hiking')
  // hiking,
  // @JsonValue('yoga')
  // yoga,
  // @JsonValue('martial_arts')
  // martialArts,
  // @JsonValue('other')
  // other,
}

/// Extension to provide display helpers for [EventType].
extension EventTypeX on EventType {
  // add this into the switch if you want to support it in the future, but comment out for now since it's not used:
  // case EventType.martialArts:
  //   return 'martial_arts';

  String get jsonValue {
    switch (this) {
      default:
        return name; // enum name matches @JsonValue for all others
    }
  }

  String get label {
    switch (this) {
      // case EventType.football:
      //   return 'Football';
      // case EventType.basketball:
      //   return 'Basketball';
      // case EventType.volleyball:
      //   return 'Volleyball';
      // case EventType.tennis:
      //   return 'Tennis';
      case EventType.running:
        return 'Running';
      // case EventType.gym:
      //   return 'Gym';
      // case EventType.swimming:
      //   return 'Swimming';
      // case EventType.cycling:
      //   return 'Cycling';
      // case EventType.hiking:
      //   return 'Hiking';
      // case EventType.yoga:
      //   return 'Yoga';
      // case EventType.martialArts:
      //   return 'Martial Arts';
      // case EventType.other:
      //   return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      // case EventType.football:
      //   return Icons.sports_soccer;
      // case EventType.basketball:
      //   return Icons.sports_basketball;
      // case EventType.volleyball:
      //   return Icons.sports_volleyball;
      // case EventType.tennis:
      //   return Icons.sports_tennis;
      case EventType.running:
        return Icons.directions_run;
      // case EventType.gym:
      //   return Icons.fitness_center;
      // case EventType.swimming:
      //   return Icons.pool;
      // case EventType.cycling:
      //   return Icons.directions_bike;
      // case EventType.hiking:
      //   return Icons.terrain;
      // case EventType.yoga:
      //   return Icons.self_improvement;
      // case EventType.martialArts:
      //   return Icons.sports_martial_arts;
      // case EventType.other:
      //   return Icons.sports;
    }
  }

  Color get color {
    switch (this) {
      // case EventType.football:
      //   return const Color(0xFF43A047);
      // case EventType.basketball:
      //   return const Color(0xFFEF6C00);
      // case EventType.volleyball:
      //   return const Color(0xFFFDD835);
      // case EventType.tennis:
      //   return const Color(0xFF66BB6A);
      case EventType.running:
        return const Color(0xFF29B6F6);
      // case EventType.gym:
      //   return const Color(0xFF8E24AA);
      // case EventType.swimming:
      //   return const Color(0xFF0288D1);
      // case EventType.cycling:
      //   return const Color(0xFFFF7043);
      // case EventType.hiking:
      //   return const Color(0xFF5D4037);
      // case EventType.yoga:
      //   return const Color(0xFFAB47BC);
      // case EventType.martialArts:
      //   return const Color(0xFFD32F2F);
      // case EventType.other:
      //   return const Color(0xFF78909C);
    }
  }
}

@freezed
abstract class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String creatorId,
    required String title,
    required EventType type,
    required LocationPoint location,
    @RequiredTimestampConverter() required DateTime startsAt,
    @TimestampConverter() DateTime? endsAt,
    String? description,

    /// Display name of the organiser (denormalized for fast rendering).
    String? organizerName,

    /// Cover image URL (Firebase Storage).
    String? imageUrl,
    @Default([]) List<String> participantIds,
    @Default(0) int maxParticipants,
    @Default(true) bool isActive,

    // ── Event-Ride Integration fields ──

    // Note: the event↔ride link is standardized on `ride.eventId` (queried via
    // streamRidesByEventId / eventLinkedRidesProvider). The previously
    // one-directional `linkedRideIds` array was never populated and has been
    // removed to avoid a permanently-empty dead field.

    /// RSVP ride status per participant: { uid: 'driving' | 'need_ride' | 'self_arranged' }.
    @Default({}) Map<String, String> rideStatuses,

    /// Post-event meetup pin location for coordinating departure.
    LocationPoint? meetupPinLocation,

    /// Auto-created chat group ID for event participants.
    String? chatGroupId,

    /// Whether this is a recurring event (e.g. weekly training).
    @Default(false) bool isRecurring,

    /// Recurrence pattern for recurring events (daily, weekly, biweekly, monthly).
    RecurrencePattern? recurringPattern,

    /// End date for the recurring series.
    @TimestampConverter() DateTime? recurringEndDate,

    /// Whether cost-splitting is enabled for event carpools.
    @Default(false) bool costSplitEnabled,

    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _EventModel;
  const EventModel._();

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  bool get isUpcoming => startsAt.isAfter(DateTime.now());

  bool get isFull =>
      maxParticipants > 0 && participantIds.length >= maxParticipants;

  int get seatsLeft {
    if (maxParticipants <= 0) return -1; // -1 means unlimited
    return (maxParticipants - participantIds.length).clamp(0, maxParticipants);
  }

  /// Formatted participant count string for UI badges.
  String get participantLabel {
    if (maxParticipants <= 0) return '${participantIds.length} joined';
    return '${participantIds.length}/$maxParticipants';
  }

  // ── Event-Ride Integration getters ──

  /// Number of attendees who are driving and offering seats.
  int get driversCount =>
      rideStatuses.values.where((s) => s == EventRideStatus.driving.value).length;

  /// Number of attendees who need a ride.
  int get needRideCount =>
      rideStatuses.values.where((s) => s == EventRideStatus.needRide.value).length;

  /// Number of attendees who arranged their own transport.
  int get selfArrangedCount => rideStatuses.values
      .where((s) => s == EventRideStatus.selfArranged.value)
      .length;

  /// Number of attendees who haven't set a ride status yet.
  int get noRideStatusCount => participantIds.length - rideStatuses.length;

  /// Summary label: "4 driving · 3 need rides"
  String get rideStatusSummary {
    final parts = <String>[];
    if (driversCount > 0) parts.add('$driversCount driving');
    if (needRideCount > 0) parts.add('$needRideCount need rides');
    if (parts.isEmpty) return 'No ride info yet';
    return parts.join(' · ');
  }

  /// Whether the event has ended (for "need ride home" button).
  bool get hasEnded => effectiveEndsAt.isBefore(DateTime.now());

  /// Whether the event is currently happening.
  bool get isOngoing {
    final now = DateTime.now();
    return startsAt.isBefore(now) && effectiveEndsAt.isAfter(now);
  }

  /// Ride status for a specific user.
  String? rideStatusFor(String userId) => rideStatuses[userId];

  /// Typed ride status for a specific user (`null` if unset or unrecognised).
  EventRideStatus? rideStatusEnumFor(String userId) =>
      EventRideStatusX.fromValue(rideStatuses[userId]);

  /// Whether a given user has joined this event.
  bool isParticipant(String userId) => participantIds.contains(userId);

  /// Whether [userId] is the organiser/creator of this event.
  bool isCreatedBy(String userId) => creatorId == userId;

  /// Number of attendees who have joined.
  int get participantCount => participantIds.length;

  /// Whether new participants can still join (active, upcoming and not full).
  bool get canJoin => isActive && isUpcoming && !isFull;

  /// Effective end time, falling back to a 2h default when [endsAt] is unset.
  /// Used consistently by [hasEnded] and [isOngoing].
  DateTime get effectiveEndsAt =>
      endsAt ?? startsAt.add(const Duration(hours: 2));

  /// Duration of the event using [effectiveEndsAt].
  Duration get duration => effectiveEndsAt.difference(startsAt);

  /// Whether a recurring series is still ongoing (no end date, or end in future).
  bool get hasActiveRecurrence {
    if (!isRecurring) return false;
    final end = recurringEndDate;
    return end == null || end.isAfter(DateTime.now());
  }
}
