import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';

part 'event_participants_view_model.g.dart';

/// Builds the stable cache key for [eventParticipantProfilesProvider].
///
/// The provider is keyed by a `String` (not a `List`) on purpose: Riverpod
/// families compare arguments with `==`, and two distinct `List` instances with
/// the same contents are never equal, so a fresh list per `build` would spawn a
/// new provider (and refetch) on every rebuild. A normalized, sorted CSV key is
/// value-equal across rebuilds, so the batched result is reused.
String eventParticipantProfilesKey(Iterable<String> userIds) {
  final ids =
      userIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toSet().toList()
        ..sort();
  return ids.join(',');
}

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
@riverpod
Future<Map<String, UserModel>> eventParticipantProfiles(
  Ref ref,
  String idsKey,
) async {
  final ids = idsKey.split(',').where((id) => id.isNotEmpty).toList();

  if (ids.isEmpty) return const <String, UserModel>{};

  final firestore = ref.watch(firebaseServiceProvider).firestore;
  final collection = firestore.collection(AppConstants.usersCollection);

  final profiles = <String, UserModel>{};
  for (var start = 0; start < ids.length; start += _chunkSize) {
    final chunk = ids.sublist(
      start,
      (start + _chunkSize).clamp(0, ids.length),
    );
    final snapshot = await collection
        .where(FieldPath.documentId, whereIn: chunk)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      profiles[doc.id] = UserModel.fromJson(data);
    }
  }

  // Cache briefly so re-mounting the screen does not refetch immediately.
  final cacheLink = ref.keepAlive();
  final cacheTimer = Timer(const Duration(minutes: 5), cacheLink.close);
  ref.onDispose(cacheTimer.cancel);

  return profiles;
}

/// Firestore caps `whereIn` filters at 30 values per query.
const int _chunkSize = 30;
