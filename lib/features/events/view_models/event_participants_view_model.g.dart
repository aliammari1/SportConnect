// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_participants_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Batch-fetches the profiles for a set of participant user IDs in a single
/// provider, using `whereIn` queries in chunks of [_chunkSize] document IDs.
///
/// This replaces the previous N+1 pattern where each attendee card / participant
/// avatar opened its own `userProfileProvider` document listener — for an event
/// with K participants that spun up K separate Firestore reads. Here every ID is
/// resolved through at most `ceil(K / 30)` batched queries and the resulting map
/// is shared by all rows.
///
/// [idsKey] must be produced by [eventParticipantProfilesKey].
///
/// Returns a map keyed by uid. IDs with no matching document are simply absent
/// from the map, so callers should treat a missing entry as an unknown user.

@ProviderFor(eventParticipantProfiles)
final eventParticipantProfilesProvider = EventParticipantProfilesFamily._();

/// Batch-fetches the profiles for a set of participant user IDs in a single
/// provider, using `whereIn` queries in chunks of [_chunkSize] document IDs.
///
/// This replaces the previous N+1 pattern where each attendee card / participant
/// avatar opened its own `userProfileProvider` document listener — for an event
/// with K participants that spun up K separate Firestore reads. Here every ID is
/// resolved through at most `ceil(K / 30)` batched queries and the resulting map
/// is shared by all rows.
///
/// [idsKey] must be produced by [eventParticipantProfilesKey].
///
/// Returns a map keyed by uid. IDs with no matching document are simply absent
/// from the map, so callers should treat a missing entry as an unknown user.

final class EventParticipantProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, UserModel>>,
          Map<String, UserModel>,
          FutureOr<Map<String, UserModel>>
        >
    with
        $FutureModifier<Map<String, UserModel>>,
        $FutureProvider<Map<String, UserModel>> {
  /// Batch-fetches the profiles for a set of participant user IDs in a single
  /// provider, using `whereIn` queries in chunks of [_chunkSize] document IDs.
  ///
  /// This replaces the previous N+1 pattern where each attendee card / participant
  /// avatar opened its own `userProfileProvider` document listener — for an event
  /// with K participants that spun up K separate Firestore reads. Here every ID is
  /// resolved through at most `ceil(K / 30)` batched queries and the resulting map
  /// is shared by all rows.
  ///
  /// [idsKey] must be produced by [eventParticipantProfilesKey].
  ///
  /// Returns a map keyed by uid. IDs with no matching document are simply absent
  /// from the map, so callers should treat a missing entry as an unknown user.
  EventParticipantProfilesProvider._({
    required EventParticipantProfilesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventParticipantProfilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventParticipantProfilesHash();

  @override
  String toString() {
    return r'eventParticipantProfilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return eventParticipantProfiles(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventParticipantProfilesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventParticipantProfilesHash() =>
    r'99fae26995e1240f692ef885d5602570296239aa';

/// Batch-fetches the profiles for a set of participant user IDs in a single
/// provider, using `whereIn` queries in chunks of [_chunkSize] document IDs.
///
/// This replaces the previous N+1 pattern where each attendee card / participant
/// avatar opened its own `userProfileProvider` document listener — for an event
/// with K participants that spun up K separate Firestore reads. Here every ID is
/// resolved through at most `ceil(K / 30)` batched queries and the resulting map
/// is shared by all rows.
///
/// [idsKey] must be produced by [eventParticipantProfilesKey].
///
/// Returns a map keyed by uid. IDs with no matching document are simply absent
/// from the map, so callers should treat a missing entry as an unknown user.

final class EventParticipantProfilesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, UserModel>>, String> {
  EventParticipantProfilesFamily._()
    : super(
        retry: null,
        name: r'eventParticipantProfilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Batch-fetches the profiles for a set of participant user IDs in a single
  /// provider, using `whereIn` queries in chunks of [_chunkSize] document IDs.
  ///
  /// This replaces the previous N+1 pattern where each attendee card / participant
  /// avatar opened its own `userProfileProvider` document listener — for an event
  /// with K participants that spun up K separate Firestore reads. Here every ID is
  /// resolved through at most `ceil(K / 30)` batched queries and the resulting map
  /// is shared by all rows.
  ///
  /// [idsKey] must be produced by [eventParticipantProfilesKey].
  ///
  /// Returns a map keyed by uid. IDs with no matching document are simply absent
  /// from the map, so callers should treat a missing entry as an unknown user.

  EventParticipantProfilesProvider call(String idsKey) =>
      EventParticipantProfilesProvider._(argument: idsKey, from: this);

  @override
  String toString() => r'eventParticipantProfilesProvider';
}
