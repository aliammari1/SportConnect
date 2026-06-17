import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) {
  return ProfileRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

/// Profile Repository for user operations - Firebase only
class ProfileRepository {
  ProfileRepository(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<UserModel> get _usersCollection => _firestore
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      );

  // ==================== USER PROFILE ====================

  /// Get user by ID

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Stream user profile

  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  /// Update user profile

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) async {
    // Server timestamp avoids client-clock skew on the profile's updatedAt.
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(uid).update(updates);
  }

  /// Upload profile photo.
  /// PROF-4: writes each replacement under a unique object name so the new
  /// download URL changes (avoiding stale CDN/browser-cached images), then
  /// prunes older objects in the profile folder to avoid orphans.
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final folderRef = _storage.ref().child('users').child(uid).child('profile');
    final ref = folderRef.child(
      'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'userId': uid},
    );

    await ref.putFile(file, metadata);
    final downloadUrl = await ref.getDownloadURL();

    // Best-effort cleanup of previous photos; never fail the upload over it.
    try {
      final existing = await folderRef.listAll();
      for (final item in existing.items) {
        if (item.fullPath != ref.fullPath) {
          await item.delete();
        }
      }
    } on FirebaseException catch (e) {
      TalkerService.warning(
        'uploadProfilePhoto: failed to prune old photos for $uid: ${e.code}',
      );
    }

    return downloadUrl;
  }

  /// Update profile photo

  Future<void> updateProfilePhoto(String uid, File file) async {
    final photoUrl = await uploadProfilePhoto(uid, file);
    await updateProfile(uid, {'photoUrl': photoUrl});
  }

  /// Delete profile photo.
  /// PROF-4: photos are stored under unique names, so delete every object in
  /// the user's profile folder rather than a single fixed path.
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      final folderRef = _storage
          .ref()
          .child('users')
          .child(uid)
          .child('profile');
      final existing = await folderRef.listAll();
      for (final item in existing.items) {
        await item.delete();
      }
      await updateProfile(uid, {'photoUrl': null});
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File was already absent — still clear the Firestore URL.
        await updateProfile(uid, {'photoUrl': null});
        return;
      }
      rethrow;
    }
  }

  /// Update FCM token
  Future<void> updateFCMToken(String uid, String token) async {
    await _usersCollection.doc(uid).update({'fcmToken': token});
  }

  // ==================== SOCIAL FEATURES ====================

  CollectionReference _blockedUsersCollection(String userId) => _firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .collection(AppConstants.blockedUsersCollection);

  /// Block a user atomically:
  /// 1. Writes metadata to blocked-users sub-collection.
  /// 2. Appends UID to [UserModel.blockedUsers] array for fast query filtering.

  Future<void> blockUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    batch.set(_blockedUsersCollection(currentUserId).doc(targetUserId), {
      'blockedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_usersCollection.doc(currentUserId), {
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
    });

    await batch.commit();
  }

  /// Unblock a user atomically — exact reverse of [blockUser].

  Future<void> unblockUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    batch.delete(_blockedUsersCollection(currentUserId).doc(targetUserId));

    batch.update(_usersCollection.doc(currentUserId), {
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });

    await batch.commit();
  }

  Future<bool> isUserBlocked({
    required String userId,
    required String blockedUserId,
  }) async {
    final doc = await _blockedUsersCollection(userId).doc(blockedUserId).get();
    return doc.exists;
  }

  Stream<List<String>> streamBlockedUserIds(String userId) {
    return _blockedUsersCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.id).toList(),
    );
  }

  // ==================== VEHICLES (Driver Only) ====================

  CollectionReference<VehicleModel> get _vehiclesCollection => _firestore
      .collection(AppConstants.vehiclesCollection)
      .withConverter<VehicleModel>(
        fromFirestore: (snapshot, _) => VehicleModel.fromJson(snapshot.data()!),
        toFirestore: (vehicle, _) => vehicle.toJson(),
      );

  /// Add a vehicle (only for drivers)

  Future<void> addVehicle(String uid, VehicleModel vehicle) async {
    final user = await getUserById(uid);
    if (user == null) {
      throw StateError('User not found for vehicle creation');
    }
    if (user is! DriverModel && user is! PendingUserModel) {
      throw StateError('Only drivers or pending users can add vehicles');
    }

    // Use a batch to atomically create the vehicle document and append its
    // id to the driver's vehicleIds array — prevents orphaned vehicle docs
    // if the second write fails.
    final batch = _firestore.batch();
    batch.set(_vehiclesCollection.doc(vehicle.id), vehicle);
    batch.update(_usersCollection.doc(uid), {
      'vehicleIds': FieldValue.arrayUnion([vehicle.id]),
    });
    await batch.commit();
  }

  /// Update a vehicle (only for drivers)

  Future<void> updateVehicle(String uid, VehicleModel vehicle) async {
    final user = await getUserById(uid);
    if (user == null) {
      throw StateError('User not found for vehicle update');
    }
    // PROF-9: mirror addVehicle's guard (drivers and pending drivers) and fail
    // explicitly on rejection instead of silently dropping the write.
    if (user is! DriverModel && user is! PendingUserModel) {
      throw StateError('Only drivers or pending users can update vehicles');
    }

    // Update vehicle in its own collection
    await _vehiclesCollection.doc(vehicle.id).update(vehicle.toJson());
  }

  /// Remove a vehicle (only for drivers)

  Future<void> removeVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null) {
      throw StateError('User not found for vehicle removal');
    }
    // PROF-9: mirror addVehicle's guard (drivers and pending drivers) and fail
    // explicitly on rejection instead of silently dropping the write.
    if (user is! DriverModel && user is! PendingUserModel) {
      throw StateError('Only drivers or pending users can remove vehicles');
    }

    // Use a batch to atomically delete the vehicle document and remove the
    // vehicleId from the driver's array — mirrors the pattern in blockUser().
    final batch = _firestore.batch();
    batch.delete(_vehiclesCollection.doc(vehicleId));
    batch.update(_usersCollection.doc(uid), {
      'vehicleIds': FieldValue.arrayRemove([vehicleId]),
    });
    await batch.commit();
  }

  /// Set default vehicle (only for drivers).
  /// PROF-7: a single atomic batch flips the isActive flag across all of the
  /// driver's vehicles, so the default-vehicle invariant (exactly one active)
  /// can never be left in a half-applied state. A driver's vehicle count is
  /// always far below Firestore's 500-op batch limit.

  Future<void> setDefaultVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final vehicleIds = user.vehicleIds;
    if (vehicleIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final vId in vehicleIds) {
      batch.update(_vehiclesCollection.doc(vId), {
        'isActive': vId == vehicleId,
      });
    }
    await batch.commit();
  }

  /// Get vehicles for a driver

  Future<List<VehicleModel>> getDriverVehicles(String uid) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return [];

    final driver = user;
    if (driver.vehicleIds.isEmpty) return [];

    // Fetch all vehicle documents in parallel rather than awaiting each read
    // sequentially, so latency stays roughly constant instead of scaling
    // linearly with the number of vehicles.
    final docs = await Future.wait(
      driver.vehicleIds.map((vId) => _vehiclesCollection.doc(vId).get()),
    );
    return [
      for (final doc in docs)
        if (doc.exists) doc.data()!,
    ];
  }

  // ==================== GAMIFICATION ====================

  /// Add XP to user. Returns the new level if a level-up occurred, or null.

  Future<int?> addXP(String uid, int xp) async {
    int? returnedLevel;

    // Use a transaction so that concurrent XP awards each read the latest
    // values before computing the new totals, preventing lost increments.
    final docRef = _usersCollection.doc(uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final user = snapshot.data();
      if (user == null) return;

      // Get current gamification stats based on user type
      final (
        int totalXP,
        int currentLevelXP,
        int level,
        int xpToNextLevel,
      ) = switch (user) {
        RiderModel(:final gamification) => (
          gamification.totalXP,
          gamification.currentLevelXP,
          gamification.level,
          gamification.xpToNextLevel,
        ),
        DriverModel(:final gamification) => (
          gamification.totalXP,
          gamification.currentLevelXP,
          gamification.level,
          gamification.xpToNextLevel,
        ),
        PendingUserModel() => (0, 0, 0, 0),
      };

      // FIX G-1: Cap XP/level progression at level 50.
      const maxLevel = 50;

      final newTotalXP = totalXP + xp;
      var newCurrentLevelXP = currentLevelXP + xp;
      var newLevel = level;
      var newXpToNextLevel = xpToNextLevel;

      // Check for level up — stop advancing once max level is reached.
      while (newCurrentLevelXP >= newXpToNextLevel && newLevel < maxLevel) {
        newLevel++;
        newCurrentLevelXP -= newXpToNextLevel;
        newXpToNextLevel = (newXpToNextLevel * 1.2).round();
      }
      // At max level clamp XP so the bar stays full but doesn't overflow.
      if (newLevel >= maxLevel) {
        newCurrentLevelXP = newXpToNextLevel;
      }

      transaction.update(docRef, {
        'gamification.totalXP': newTotalXP,
        'gamification.level': newLevel,
        'gamification.currentLevelXP': newCurrentLevelXP,
        'gamification.xpToNextLevel': newXpToNextLevel,
      });

      if (newLevel > level) {
        returnedLevel = newLevel;
      }
    });

    return returnedLevel;
  }

  /// Update streak.
  /// PROF-6: the streak is computed inside a Firestore transaction that treats
  /// the user document as the source of truth. It reads the server-stored
  /// gamification.lastActiveDate and the current/longest streak from the doc,
  /// compares against a server timestamp, and writes atomically. The canonical
  /// streak is never derived from device-local SharedPreferences or the client
  /// clock (which are spoofable, resettable on reinstall, and per-device).
  Future<void> updateStreak(String uid) async {
    // Use an untyped document reference so the transaction can read/write the
    // server-managed gamification.lastActiveDate timestamp, which is not part
    // of the typed UserModel converter.
    final docRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data();
      final gamification =
          (data?['gamification'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};

      var currentStreak = (gamification['currentStreak'] as num?)?.toInt() ?? 0;
      var longestStreak = (gamification['longestStreak'] as num?)?.toInt() ?? 0;

      // Anchor the previous active day to the server-written Timestamp stored
      // in Firestore rather than a per-device value. The current reference day
      // still uses the local clock (a fully spoof-proof 'now' would require a
      // Cloud Function), but the canonical streak state is read from and
      // written to the Firestore document as the single source of truth.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastActiveTs = gamification['lastActiveDate'];
      final DateTime? lastActive = lastActiveTs is Timestamp
          ? lastActiveTs.toDate()
          : null;

      if (lastActive == null) {
        currentStreak = 1;
      } else {
        final lastActiveDay = DateTime(
          lastActive.year,
          lastActive.month,
          lastActive.day,
        );
        final calendarDays = today.difference(lastActiveDay).inDays;
        if (calendarDays == 1) {
          currentStreak++;
        } else if (calendarDays > 1) {
          currentStreak = 1;
        }
        // calendarDays <= 0 → same calendar day, streak unchanged.
      }

      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      transaction.update(docRef, {
        'gamification.currentStreak': currentStreak,
        'gamification.longestStreak': longestStreak,
        'gamification.lastActiveDate': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Reset streak to 0 (no-show / bad behaviour penalty).

  Future<void> resetStreak(String uid) async {
    await _usersCollection.doc(uid).update({
      'gamification.currentStreak': 0,
    });
  }

  /// Update ride stats

  Future<void> updateRideStats({
    required String uid,
    required bool asDriver,
    required double distance,
    int fareAmountPaidInCents = 0,
  }) async {
    // G-4 guard: verify role matches the asDriver flag to catch call-site bugs.
    final user = await getUserById(uid);
    if (user != null && asDriver != user.isDriver) {
      TalkerService.warning(
        'updateRideStats: asDriver=$asDriver but uid=$uid has role=${user.role.name} — skipping to avoid stat corruption.',
      );
      return;
    }

    final updates = <String, dynamic>{
      'gamification.totalRides': FieldValue.increment(1),
      'gamification.totalDistance': FieldValue.increment(distance),
      'gamification.totalFareAmountPaidInCents': FieldValue.increment(
        fareAmountPaidInCents,
      ),
    };

    if (asDriver) {
      updates['gamification.ridesAsDriver'] = FieldValue.increment(1);
    } else {
      updates['gamification.ridesAsPassenger'] = FieldValue.increment(1);
    }

    await _usersCollection.doc(uid).update(updates);
  }

  // NOTE: A generic `unlockAchievement(uid, achievementId)` helper was removed.
  // It was the only path to grant arbitrary badges but had no callers, so the
  // social/verification/time-of-day badges it implied could never be awarded.
  // The achievements UI now only surfaces badges that evaluateAchievements
  // (below) can actually grant. Reintroduce a generic unlock path together with
  // its triggering flow (e.g. review-count, verification, ride time-of-day)
  // when those badges gain real awarding logic.

  /// Evaluate and unlock achievements based on current user stats.
  /// Returns list of newly unlocked badge IDs.

  Future<List<String>> evaluateAchievements(String uid) async {
    // PROF-5: compute newly-unlocked badges and the matching XP reward inside a
    // single transaction so the badge arrayUnion and the gamification XP update
    // are atomic and retry-safe. Guarding on the transactional snapshot makes
    // this idempotent under concurrent evaluations (no double XP awards).
    const xpPerBadge = 50;
    const maxLevel = 50;

    final docRef = _usersCollection.doc(uid);
    var unlocked = <String>[];

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final user = snapshot.data();
      if (user == null) return;

      final (
        int totalRides,
        double totalDistance,
        int longestStreak,
        List<String> unlockedBadges,
        int totalXP,
        int currentLevelXP,
        int level,
        int xpToNextLevel,
      ) = switch (user) {
        RiderModel(:final gamification) => (
          gamification.totalRides,
          gamification.totalDistance,
          gamification.longestStreak,
          gamification.unlockedBadges,
          gamification.totalXP,
          gamification.currentLevelXP,
          gamification.level,
          gamification.xpToNextLevel,
        ),
        DriverModel(:final gamification) => (
          gamification.totalRides,
          gamification.totalDistance,
          gamification.longestStreak,
          gamification.unlockedBadges,
          gamification.totalXP,
          gamification.currentLevelXP,
          gamification.level,
          gamification.xpToNextLevel,
        ),
        PendingUserModel() => (0, 0, 0, <String>[], 0, 0, 0, 0),
      };

      // Badge definitions: id → condition
      final badgeCriteria = <String, bool>{
        'first_ride': totalRides >= 1,
        'road_tripper': totalDistance >= 50,
        'speed_demon': longestStreak >= 7,
        'road_master': totalRides >= 100,
        'marathon_driver': totalDistance >= 1000,
      };

      final newBadges = badgeCriteria.entries
          .where((e) => e.value && !unlockedBadges.contains(e.key))
          .map((e) => e.key)
          .toList();

      if (newBadges.isEmpty) return;

      // Award XP for each newly unlocked badge, applying the same level-up
      // progression as addXP so both writes stay consistent in one commit.
      final newTotalXP = totalXP + newBadges.length * xpPerBadge;
      var newCurrentLevelXP = currentLevelXP + newBadges.length * xpPerBadge;
      var newLevel = level;
      var newXpToNextLevel = xpToNextLevel;
      while (newCurrentLevelXP >= newXpToNextLevel && newLevel < maxLevel) {
        newLevel++;
        newCurrentLevelXP -= newXpToNextLevel;
        newXpToNextLevel = (newXpToNextLevel * 1.2).round();
      }
      if (newLevel >= maxLevel) {
        newCurrentLevelXP = newXpToNextLevel;
      }

      transaction.update(docRef, {
        'gamification.unlockedBadges': FieldValue.arrayUnion(newBadges),
        'gamification.totalXP': newTotalXP,
        'gamification.level': newLevel,
        'gamification.currentLevelXP': newCurrentLevelXP,
        'gamification.xpToNextLevel': newXpToNextLevel,
      });

      unlocked = newBadges;
    });

    return unlocked;
  }

  // ==================== RATINGS ====================
  //
  // Rating aggregation is owned exclusively by ReviewRepository.createReview,
  // which increments only the star-bucket counters (fiveStars..oneStars) via
  // FieldValue.increment. RatingBreakdown.total and RatingBreakdown.average are
  // DERIVED getters (not constructor params, not serialized), so they must never
  // be persisted. The former ProfileRepository.addRating wrote orphan
  // rating.total / rating.average fields the model ignores and had no callers;
  // it was removed to prevent inconsistent/ignored writes if ever wired up.

  // ==================== LEADERBOARD ====================

  /// Get leaderboard
  Future<List<LeaderboardEntry>> getLeaderboard({int limit = 50}) async {
    final query = await _usersCollection
        .orderBy('gamification.totalXP', descending: true)
        .limit(limit)
        .get();

    var rank = 0;
    return query.docs.map((doc) {
      rank++;
      final user = doc.data();
      final gamification = switch (user) {
        RiderModel(:final gamification) => gamification,
        DriverModel(:final gamification) => gamification,
        PendingUserModel() => null,
      };
      return LeaderboardEntry(
        userId: user.uid,
        username: user.username,
        photoUrl: user.photoUrl,
        totalXP: gamification?.totalXP ?? 0,
        level: user.userLevel.level,
        rank: rank,
        totalRides: gamification?.totalRides ?? 0,
      );
    }).toList();
  }

  /// Get user's rank

  Future<int> getUserRank(String uid) async {
    final user = await getUserById(uid);
    if (user == null) return 0;
    if (user.role == UserRole.pending) return 0;
    final gamification = switch (user) {
      RiderModel(:final gamification) => gamification,
      DriverModel(:final gamification) => gamification,
      PendingUserModel() => null,
    };
    final query = await _usersCollection
        .where(
          'gamification.totalXP',
          isGreaterThan: gamification?.totalXP ?? 0,
        )
        .count()
        .get();

    return (query.count ?? 0) + 1;
  }

  // ==================== PREFERENCES ====================

  /// Update preferences
  Future<void> updatePreferences(
    String uid,
    UserPreferences preferences,
  ) async {
    await _usersCollection.doc(uid).update({
      'preferences': preferences.toJson(),
    });
  }

  // ==================== SEARCH ====================

  /// Search users

  Future<List<UserModel>> searchUsers({
    String? query,
    UserRole? role,
    int? limit,
    Iterable<String>? excludeUserIds,
    String? excludeUsersWhoBlockedId,
  }) async {
    final rawQuery = query?.trim() ?? '';
    if (rawQuery.isEmpty) return [];

    final maxItems = limit ?? 50;
    final excludedIds = (excludeUserIds ?? const <String>[]).toSet();
    final deduped = <String, UserModel>{};

    // PROF-1/PROF-2: Search only the actually-persisted, indexed 'username'
    // field via bounded prefix range queries. We must never download the whole
    // users collection to filter client-side: that exposes every user's
    // email/PII and is effectively a full-collection scan on each search.
    Future<void> runPrefixQuery(String value) async {
      if (value.isEmpty) return;

      var queryRef = _usersCollection
          .where('username', isGreaterThanOrEqualTo: value)
          .where('username', isLessThanOrEqualTo: '$value\uf8ff');

      if (role != null) {
        queryRef = queryRef.where('role', isEqualTo: role.name);
      }

      // Cap each prefix query at maxItems. The dedup map + .take(maxItems)
      // below already bound the final result set, so over-fetching (the former
      // `maxItems * 2`) only inflated billed reads without surfacing more
      // results.
      final snapshot = await queryRef.limit(maxItems).get();
      for (final doc in snapshot.docs) {
        final user = doc.data();
        final blockedUsers = switch (user) {
          RiderModel(:final blockedUsers) => blockedUsers,
          DriverModel(:final blockedUsers) => blockedUsers,
          PendingUserModel() => <String>[],
        };
        final isExcludedById = excludedIds.contains(user.uid);
        final hasBlockedCurrentUser =
            excludeUsersWhoBlockedId != null &&
            blockedUsers.contains(excludeUsersWhoBlockedId);
        if (isExcludedById || hasBlockedCurrentUser) {
          continue;
        }

        deduped[user.uid] = user;
      }
    }

    // Try common casing patterns so a username prefix match is found
    // regardless of how the user typed it, without resorting to a full scan.
    final titleCase = rawQuery.isEmpty
        ? rawQuery
        : '${rawQuery[0].toUpperCase()}${rawQuery.substring(1).toLowerCase()}';
    for (final candidate in <String>{
      rawQuery,
      rawQuery.toLowerCase(),
      titleCase,
    }) {
      await runPrefixQuery(candidate);
      if (deduped.length >= maxItems) break;
    }

    return deduped.values.take(maxItems).toList(growable: false);
  }

  // ==================== INTERFACE METHODS ====================

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).update({
      ...user.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserField(
    String userId,
    String field,
    dynamic value,
  ) async {
    await _usersCollection.doc(userId).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

/// Stream provider for current user
@riverpod
Stream<UserModel?> currentUserStream(Ref ref) async* {
  final repository = ref.watch(profileRepositoryProvider);
  final userId = await ref.watch(currentAuthUidProvider.future);
  if (userId == null) {
    yield null;
    return;
  }
  yield* repository.streamUser(userId);
}

/// Stream provider for a user by ID
@riverpod
Stream<UserModel?> userStream(Ref ref, String userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.streamUser(userId);
}

/// Provider to load VehicleModel objects for a driver
@riverpod
Future<List<VehicleModel>> driverVehicles(Ref ref, String uid) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getDriverVehicles(uid);
}
