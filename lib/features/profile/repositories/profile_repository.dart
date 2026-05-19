import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    updates['updatedAt'] = DateTime.now();
    await _usersCollection.doc(uid).update(updates);
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('profile')
        .child('profile.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'userId': uid},
    );

    await ref.putFile(file, metadata);
    return ref.getDownloadURL();
  }

  /// Update profile photo

  Future<void> updateProfilePhoto(String uid, File file) async {
    final photoUrl = await uploadProfilePhoto(uid, file);
    await updateProfile(uid, {'photoUrl': photoUrl});
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto(String uid) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(uid)
          .child('profile')
          .child('profile.jpg');
      await ref.delete();
      await updateProfile(uid, {'photoUrl': null});
    } on Exception {
      // Photo might not exist, ignore
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

    // Store vehicle in its own collection
    final vehicleRef = _vehiclesCollection.doc(vehicle.id);
    await vehicleRef.set(vehicle);

    // Add vehicle ID to driver's vehicleIds list using arrayUnion to avoid
    // mutating the immutable freezed list.
    await _usersCollection.doc(uid).update({
      'vehicleIds': FieldValue.arrayUnion([vehicle.id]),
    });
  }

  /// Update a vehicle (only for drivers)

  Future<void> updateVehicle(String uid, VehicleModel vehicle) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    // Update vehicle in its own collection
    await _vehiclesCollection.doc(vehicle.id).update(vehicle.toJson());
  }

  /// Remove a vehicle (only for drivers)

  Future<void> removeVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    // Remove from vehicles collection
    await _vehiclesCollection.doc(vehicleId).delete();

    // Remove vehicle ID from driver's vehicleIds list using arrayRemove to
    // avoid mutating the immutable freezed list.
    await _usersCollection.doc(uid).update({
      'vehicleIds': FieldValue.arrayRemove([vehicleId]),
    });
  }

  /// Set default vehicle (only for drivers).
  /// G-6: Chunks writes into batches of 499 to stay within Firestore's
  /// 500-operation-per-batch limit for drivers with many vehicles.

  Future<void> setDefaultVehicle(String uid, String vehicleId) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return;

    final driver = user;
    final vehicleIds = driver.vehicleIds;

    for (var i = 0; i < vehicleIds.length; i += 499) {
      final chunk = vehicleIds.sublist(
        i,
        (i + 499).clamp(0, vehicleIds.length),
      );
      final batch = _firestore.batch();
      for (final vId in chunk) {
        batch.update(_vehiclesCollection.doc(vId), {
          'isActive': vId == vehicleId,
        });
      }
      await batch.commit();
    }
  }

  /// Get vehicles for a driver

  Future<List<VehicleModel>> getDriverVehicles(String uid) async {
    final user = await getUserById(uid);
    if (user == null || user is! DriverModel) return [];

    final driver = user;
    if (driver.vehicleIds.isEmpty) return [];

    final vehicles = <VehicleModel>[];
    for (final vId in driver.vehicleIds) {
      final doc = await _vehiclesCollection.doc(vId).get();
      if (doc.exists) {
        vehicles.add(doc.data()!);
      }
    }
    return vehicles;
  }

  // ==================== GAMIFICATION ====================

  /// Add XP to user. Returns the new level if a level-up occurred, or null.

  Future<int?> addXP(String uid, int xp) async {
    final user = await getUserById(uid);
    if (user == null) return null;

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

    await _usersCollection.doc(uid).update({
      'gamification.totalXP': newTotalXP,
      'gamification.level': newLevel,
      'gamification.currentLevelXP': newCurrentLevelXP,
      'gamification.xpToNextLevel': newXpToNextLevel,
    });

    return newLevel > level ? newLevel : null;
  }

  /// Update streak

  Future<void> updateStreak(String uid) async {
    final user = await getUserById(uid);
    if (user == null) return;

    // --- SharedPreferences logic for local streak tracking ---
    // This code assumes it is running in a Flutter environment.
    // If you want to keep this logic in the repository, you must add shared_preferences as a dependency.
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveMillis = prefs.getInt('last_active_date') ?? 0;
    final lastActive = lastActiveMillis > 0
        ? DateTime.fromMillisecondsSinceEpoch(lastActiveMillis)
        : null;
    var currentStreak = prefs.getInt('current_streak') ?? 0;
    var longestStreak = prefs.getInt('longest_streak') ?? 0;

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
      // calendarDays == 0 → same calendar day, streak unchanged
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Save to shared preferences
    await prefs.setInt('last_active_date', today.millisecondsSinceEpoch);
    await prefs.setInt('current_streak', currentStreak);
    await prefs.setInt('longest_streak', longestStreak);

    // --- Always update Firestore with the latest streak values ---
    await _usersCollection.doc(uid).update({
      'gamification.currentStreak': currentStreak,
      'gamification.longestStreak': longestStreak,
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

  /// Unlock achievement

  Future<void> unlockAchievement(String uid, String achievementId) async {
    await _usersCollection.doc(uid).update({
      'gamification.unlockedBadges': FieldValue.arrayUnion([achievementId]),
    });
  }

  /// Evaluate and unlock achievements based on current user stats.
  /// Returns list of newly unlocked badge IDs.

  Future<List<String>> evaluateAchievements(String uid) async {
    final user = await getUserById(uid);
    if (user == null) return [];

    final (
      int totalRides,
      double totalDistance,
      int longestStreak,
      List<String> unlockedBadges,
    ) = switch (user) {
      RiderModel(:final gamification) => (
        gamification.totalRides,
        gamification.totalDistance,
        gamification.longestStreak,
        gamification.unlockedBadges,
      ),
      DriverModel(:final gamification) => (
        gamification.totalRides,
        gamification.totalDistance,
        gamification.longestStreak,
        gamification.unlockedBadges,
      ),
      PendingUserModel() => (0, 0, 0, []),
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

    if (newBadges.isEmpty) return [];

    // Batch-unlock all newly earned badges
    await _usersCollection.doc(uid).update({
      'gamification.unlockedBadges': FieldValue.arrayUnion(newBadges),
    });

    // FIX G-5: Award XP for each newly unlocked badge.
    // Each badge grants 50 XP as a reward for the achievement.
    const xpPerBadge = 50;
    await addXP(uid, newBadges.length * xpPerBadge);

    return newBadges;
  }

  // ==================== RATINGS ====================

  /// Add rating - now simplified since each user type has one rating
  Future<void> addRating({
    required String uid,
    required double rating,
    required bool asDriver,
  }) async {
    final user = await getUserById(uid);
    if (user == null) return;
    if (user.role == UserRole.pending) return;

    // Get current rating breakdown
    var breakdown = const RatingBreakdown();
    if (user is RiderModel) {
      breakdown = user.rating;
    } else if (user is DriverModel) {
      breakdown = user.rating;
    }
    final newTotal = breakdown.total + 1;
    final newAverage =
        ((breakdown.average * breakdown.total) + rating) / newTotal;

    final updates = <String, dynamic>{};

    updates['rating.total'] = newTotal;
    updates['rating.average'] = newAverage;

    if (rating >= 4.5) {
      updates['rating.fiveStars'] = FieldValue.increment(1);
    } else if (rating >= 3.5) {
      updates['rating.fourStars'] = FieldValue.increment(1);
    } else if (rating >= 2.5) {
      updates['rating.threeStars'] = FieldValue.increment(1);
    } else if (rating >= 1.5) {
      updates['rating.twoStars'] = FieldValue.increment(1);
    } else {
      updates['rating.oneStars'] = FieldValue.increment(1);
    }

    await _usersCollection.doc(uid).update(updates);
  }

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
        ridesThisMonth: gamification?.totalRides ?? 0,
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

    final normalized = rawQuery.toLowerCase();
    final maxItems = limit ?? 50;
    final excludedIds = (excludeUserIds ?? const <String>[]).toSet();
    final deduped = <String, UserModel>{};

    Future<void> runPrefixQuery(String value) async {
      if (value.isEmpty) return;

      var queryRef = _usersCollection
          .where('displayName', isGreaterThanOrEqualTo: value)
          .where('displayName', isLessThanOrEqualTo: '$value\uf8ff');

      if (role != null) {
        queryRef = queryRef.where('role', isEqualTo: role.name);
      }

      final snapshot = await queryRef.limit(maxItems * 2).get();
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

        final matchesName = user.username.toLowerCase().contains(normalized);
        final matchesEmail = user.email.toLowerCase().contains(normalized);
        if (matchesName || matchesEmail) {
          deduped[user.uid] = user;
        }
      }
    }

    // Try common casing patterns first to avoid full scans.
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

    if (deduped.length < maxItems) {
      // Fallback broad scan for mixed-case/non-prefix matches.
      Query<UserModel> fallbackQuery = _usersCollection;
      if (role != null) {
        fallbackQuery = fallbackQuery.where('role', isEqualTo: role.name);
      }

      final fallback = await fallbackQuery.limit(maxItems * 8).get();
      for (final doc in fallback.docs) {
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

        final matchesName = user.username.toLowerCase().contains(normalized);
        final matchesEmail = user.email.toLowerCase().contains(normalized);
        if (matchesName || matchesEmail) {
          deduped[user.uid] = user;
          if (deduped.length >= maxItems) break;
        }
      }
    }

    return deduped.values.take(maxItems).toList(growable: false);
  }

  // ==================== INTERFACE METHODS ====================

  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).update({
      ...user.toJson(),
      'updatedAt': DateTime.now(),
    });
  }

  Future<void> updateUserField(
    String userId,
    String field,
    dynamic value,
  ) async {
    await _usersCollection.doc(userId).update({
      field: value,
      'updatedAt': DateTime.now(),
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
