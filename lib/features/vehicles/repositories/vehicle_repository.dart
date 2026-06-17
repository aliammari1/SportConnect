import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'vehicle_repository.g.dart';

@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  return VehicleRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

/// Vehicle Repository for Firestore operations
class VehicleRepository {
  VehicleRepository(this._firestore, this._storage);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<VehicleModel> get _vehiclesCollection => _firestore
      .collection(AppConstants.vehiclesCollection)
      .withConverter<VehicleModel>(
        fromFirestore: (snap, _) =>
            VehicleModel.fromJson({...snap.data()!, 'id': snap.id}),
        toFirestore: (vehicle, _) => vehicle.toJson(),
      );

  // ==================== VEHICLE OPERATIONS ====================

  /// Create a new vehicle
  Future<String> createVehicle(VehicleModel vehicle) async {
    // VE-3: Validate vehicle year is realistic (1900-current year + 1).
    final currentYear = DateTime.now().year;
    if (vehicle.year < 1900 || vehicle.year > currentYear + 1) {
      throw ArgumentError(
        'Vehicle year must be between 1900 and ${currentYear + 1} (got ${vehicle.year}).',
      );
    }

    // FIX VE-1: Reject duplicate license plates across all drivers.
    final plateQuery = await _vehiclesCollection
        .where('licensePlate', isEqualTo: vehicle.licensePlate)
        .limit(1)
        .get();
    if (plateQuery.docs.isNotEmpty) {
      throw StateError(
        'A vehicle with plate "${vehicle.licensePlate}" is already registered.',
      );
    }

    final rawCol = _firestore.collection(AppConstants.vehiclesCollection);
    final docRef = rawCol.doc();
    final vehicleWithId = vehicle.copyWith(id: docRef.id);
    final json = vehicleWithId.toJson();
    // Use server timestamps for consistency across time zones
    json['createdAt'] = FieldValue.serverTimestamp();
    json['updatedAt'] = FieldValue.serverTimestamp();

    // VE-3 (state-sync): atomically create the vehicle document AND append its
    // id to the owner's vehicleIds, mirroring ProfileRepository.addVehicle so
    // the management-screen create path can no longer diverge from the
    // profile-side flows (getDriverVehicles / setDefaultVehicle iterate
    // vehicleIds). A batch keeps both writes consistent.
    final batch = _firestore.batch();
    batch.set(docRef, json);
    batch.update(
      _firestore.collection(AppConstants.usersCollection).doc(vehicle.ownerId),
      {
        'vehicleIds': FieldValue.arrayUnion([docRef.id]),
      },
    );
    await batch.commit();
    return docRef.id;
  }

  /// Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    final doc = await _vehiclesCollection.doc(id).get();
    return doc.data();
  }

  /// Stream user's vehicles
  Stream<List<VehicleModel>> streamUserVehicles(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Get user's vehicles
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Get user's active vehicle
  Future<VehicleModel?> getActiveVehicle(String userId) async {
    final snapshot = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }

  /// Stream user's active vehicle
  Stream<VehicleModel?> streamActiveVehicle(String userId) {
    return _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return snapshot.docs.first.data();
        });
  }

  /// Update vehicle
  ///
  /// Writes ONLY user-editable fields. Immutable fields (id, ownerId,
  /// createdAt) and server-maintained aggregates (totalRides, averageRating)
  /// are intentionally excluded so a stale client edit cannot clobber stats
  /// updated concurrently by [updateVehicleStats].
  Future<void> updateVehicle(VehicleModel vehicle) async {
    // FIX VE-1 (update path): reject a plate already registered to a DIFFERENT
    // vehicle, mirroring the create-path uniqueness check. Matches on the
    // current vehicle's own id are allowed (no-op / unchanged plate).
    final plateQuery = await _vehiclesCollection
        .where('licensePlate', isEqualTo: vehicle.licensePlate)
        .limit(2)
        .get();
    final conflict = plateQuery.docs.any((doc) => doc.id != vehicle.id);
    if (conflict) {
      throw StateError(
        'A vehicle with plate "${vehicle.licensePlate}" is already registered.',
      );
    }

    await _firestore
        .collection(AppConstants.vehiclesCollection)
        .doc(vehicle.id)
        .update({
          'make': vehicle.make,
          'model': vehicle.model,
          'year': vehicle.year,
          'color': vehicle.color,
          'licensePlate': vehicle.licensePlate,
          'capacity': vehicle.capacity,
          'imageUrl': vehicle.imageUrl,
          'imageUrls': vehicle.imageUrls,
          'isActive': vehicle.isActive,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Set vehicle as active (deactivates others)
  Future<void> setActiveVehicle(String userId, String vehicleId) async {
    // Resolve the user's vehicle refs first (Firestore transactions cannot run
    // queries). The actual reads + writes happen inside the transaction below
    // so the deactivate-others / activate-one mutation is applied atomically;
    // concurrent calls from two devices can no longer leave two vehicles active.
    final userVehicles = await _vehiclesCollection
        .where('ownerId', isEqualTo: userId)
        .get();

    // Ownership check: ensure vehicleId belongs to this user, giving a clear
    // error instead of a cryptic permission-denied at commit time.
    final ownsVehicle = userVehicles.docs.any((d) => d.id == vehicleId);
    if (!ownsVehicle) {
      throw ArgumentError(
        'Vehicle $vehicleId does not belong to user $userId.',
      );
    }

    final refs = userVehicles.docs.map((d) => d.reference).toList();

    await _firestore.runTransaction((transaction) async {
      // Re-read inside the transaction so we operate on current state and
      // Firestore can detect/retry on concurrent writes.
      for (final ref in refs) {
        await transaction.get(ref);
      }
      for (final ref in refs) {
        // VE-2 (cross-feature): keep isActive and isDefault in sync. The
        // offer-ride screen auto-selects firstWhere((v) => v.isDefault); since
        // setActiveVehicle is the canonical write path for the chosen vehicle,
        // write both flags so that selection is no longer permanently ignored.
        final selected = ref.id == vehicleId;
        transaction.update(ref, {'isActive': selected, 'isDefault': selected});
      }
    });
  }

  /// Delete vehicle
  Future<void> deleteVehicle(String vehicleId) async {
    // Referential-integrity guard at the repository boundary (not just the
    // view model): refuse to delete a vehicle still referenced by an
    // active/in-progress ride. This is checked here so the invariant holds
    // even when deleteVehicle is reached directly. Note this read-then-delete
    // is not fully atomic against a ride created concurrently; closing that
    // window would require a denormalized in-use flag or a Cloud Function.
    final activeRides = await _firestore
        .collection(AppConstants.ridesCollection)
        .where('vehicleId', isEqualTo: vehicleId)
        .where('status', whereIn: ['draft', 'active', 'full', 'inProgress'])
        .limit(1)
        .get();
    if (activeRides.docs.isNotEmpty) {
      throw StateError(
        'Vehicle $vehicleId is linked to an active ride and cannot be deleted.',
      );
    }

    // Get vehicle first to delete associated images and to know the owner so
    // its id can be removed from the owner's vehicleIds in the same batch.
    final vehicle = await getVehicleById(vehicleId);

    // Delete the Firestore document first (authoritative record).
    // If this fails (e.g. network error), Storage files are left intact and
    // no data is lost. Storage cleanup is best-effort afterwards.
    //
    // VE-4 (state-sync): atomically delete the vehicle document AND remove its
    // id from the owner's vehicleIds, mirroring ProfileRepository.removeVehicle
    // so the management-screen delete path no longer leaves a dangling id that
    // setDefaultVehicle would later batch.update against a missing doc.
    if (vehicle != null) {
      final batch = _firestore.batch();
      batch.delete(_vehiclesCollection.doc(vehicleId));
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(vehicle.ownerId),
        {
          'vehicleIds': FieldValue.arrayRemove([vehicleId]),
        },
      );
      await batch.commit();
    } else {
      // Vehicle doc already gone (or never loaded); best-effort delete so the
      // call remains idempotent.
      await _vehiclesCollection.doc(vehicleId).delete();
    }

    if (vehicle != null) {
      // Delete vehicle image from storage (best-effort)
      if (vehicle.imageUrl != null) {
        try {
          await _storage.refFromURL(vehicle.imageUrl!).delete();
        } on Exception catch (e, st) {
          TalkerService.error(
            'Vehicle image cleanup failed (best-effort)',
            e,
            st,
          );
        }
      }

      // Delete additional images (best-effort)
      for (final url in vehicle.imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } on Exception catch (e, st) {
          TalkerService.error(
            'Vehicle additional image cleanup failed (best-effort)',
            e,
            st,
          );
        }
      }
    }
  }

  /// Upload vehicle image
  Future<String> uploadVehicleImage({
    required String vehicleId,
    required String imagePath,
    required List<int> imageBytes,
  }) async {
    final ref = _storage
        .ref()
        .child('vehicles')
        .child(vehicleId)
        .child(imagePath);
    final snapshot = await ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    if (snapshot.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        message: 'Upload did not complete successfully (state: ${snapshot.state})',
      );
    }
    return snapshot.ref.getDownloadURL();
  }

  /// Best-effort delete of a previously stored vehicle image by its download
  /// URL. Used when a vehicle photo is replaced so the superseded Storage
  /// object is not orphaned (uploads use a new timestamped name each time).
  Future<void> deleteVehicleImageByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on Exception catch (e, st) {
      TalkerService.error(
        'Superseded vehicle image cleanup failed (best-effort)',
        e,
        st,
      );
    }
  }

  /// Update vehicle stats after ride
  Future<void> updateVehicleStats({
    required String vehicleId,
    required double newRating,
  }) async {
    final docRef = _firestore
        .collection(AppConstants.vehiclesCollection)
        .doc(vehicleId);

    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;

      final data = snap.data()!;
      final currentTotalRides = (data['totalRides'] as num?)?.toInt() ?? 0;
      final currentAverageRating =
          (data['averageRating'] as num?)?.toDouble() ?? 0.0;

      final newTotalRides = currentTotalRides + 1;
      final newAverageRating =
          ((currentAverageRating * currentTotalRides) + newRating) /
          newTotalRides;

      transaction.update(docRef, {
        'totalRides': newTotalRides,
        'averageRating': newAverageRating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}

/// Provider for streaming user vehicles
@riverpod
Stream<List<VehicleModel>> userVehiclesStream(Ref ref, String userId) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.streamUserVehicles(userId);
}

/// Provider for streaming active vehicle
@riverpod
Stream<VehicleModel?> activeVehicleStream(Ref ref, String userId) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.streamActiveVehicle(userId);
}
