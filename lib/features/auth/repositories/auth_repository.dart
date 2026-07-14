import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/models/social_sign_in_result.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseServiceProvider),
    ref.watch(pushNotificationServiceProvider),
    ref.watch(vehicleRepositoryProvider),
  );
}

AuthException mapAppleAuthException(
  FirebaseAuthException e, {
  bool isReauthentication = false,
}) {
  switch (e.code) {
    case 'invalid-credential':
    case 'missing-or-invalid-nonce':
      return AuthException(
        code: isReauthentication
            ? 'apple-reauth-invalid-credential'
            : 'apple-sign-in-invalid-credential',
        message: isReauthentication
            ? 'Apple re-authentication could not be verified. Please try again.'
            : 'Apple sign-in could not be verified. Please try again.',
      );
    case 'account-exists-with-different-credential':
      return const AuthException(
        code: 'account-exists-with-different-credential',
        message:
            'An account already exists with a different sign-in method. '
            'Try signing in with email/password or the original provider.',
      );
    case 'network-request-failed':
      return const AuthException(
        code: 'network-request-failed',
        message: 'Network error. Please check your internet connection.',
      );
    case 'too-many-requests':
      return const AuthException(
        code: 'too-many-requests',
        message: 'Too many attempts. Please try again later',
      );
    default:
      return AuthException(
        code: e.code,
        message:
            e.message ??
            (isReauthentication
                ? 'Apple re-authentication failed. Please try again.'
                : 'Apple sign-in failed. Please try again.'),
      );
  }
}

/// Repository for authentication operations - Firebase only
class AuthRepository {
  /// Creates an [AuthRepository] with optional dependency injection.
  ///
  /// Defaults to production Firebase instances when no arguments are provided.
  /// Pass custom instances in tests to enable mocking.
  AuthRepository(
    this._firebaseService,
    this._pushNotificationService,
    this._vehicleRepository,
  );
  final FirebaseService _firebaseService;
  final PushNotificationService _pushNotificationService;
  final VehicleRepository _vehicleRepository;

  CollectionReference<UserModel> get _usersCollection => _firebaseService
      .firestore
      .collection(AppConstants.usersCollection)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromJson(snap.data()!),
        toFirestore: (user, _) => {
          ...user.toJson(),
          if (user.createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

  /// Get current user stream
  Stream<User?> get authStateChanges =>
      _firebaseService.auth.authStateChanges();

  /// Get current user
  User? get currentUser => _firebaseService.auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _firebaseService.auth.currentUser != null;

  /// Get current user ID

  String? get currentUserId => _firebaseService.auth.currentUser?.uid;

  /// Sign in with email and password

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        final userData = await getUserData(credential.user!.uid);
        if (userData != null && userData.isBanned) {
          await _firebaseService.auth.signOut();
          throw const AuthException(
            code: 'account-disabled',
            message: 'Your account has been suspended. Please contact support.',
          );
        }
        return userData;
      }
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Sign in error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Sign in error', e, st);
      rethrow;
    }
    return null;
  }

  /// Register with email and password

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String username,
    required UserRole role,
    String? phone,
    DateTime? dateOfBirth,
    Expertise expertise = Expertise.rookie,
    File? profileImage,
  }) async {
    UserCredential? credential;
    try {
      credential = await _firebaseService.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        String? photoUrl;
        final uid = credential.user!.uid;

        // 2. 📸 Upload Image to Storage (if one was selected)
        if (profileImage != null) {
          photoUrl = await _uploadProfileImage(profileImage, uid);
        }

        // Keep signup users pending until role-specific setup is complete.
        final userModel = UserModel.pending(
          uid: uid,
          email: email.trim(),
          username: username.trim(),
          photoUrl: photoUrl,
          phoneNumber: phone?.trim(),
          dateOfBirth: dateOfBirth,
          expertise: expertise,
          selectedRoleIntent: role.name,
        );

        // Write user document and onboardingPath atomically via a single set to
        // avoid a partial write that would misroute the user on next launch.
        await _firebaseService.firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .set({
              ...userModel.toJson(),
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              'onboardingPath': role.name,
            });
        await credential.user!.updateDisplayName(username);

        if (photoUrl != null) {
          await credential.user!.updatePhotoURL(photoUrl);
        }

        // Auto-send email verification after registration
        if (!credential.user!.emailVerified) {
          await credential.user!.sendEmailVerification();
        }

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Register error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      if (credential?.user != null) {
        TalkerService.warning('Rolling back user creation due to error');
        // Best-effort: remove any Firestore doc already written at line 182 so
        // the rollback does not leave an orphaned users/{uid} document whose
        // Auth account no longer exists.
        try {
          await _firebaseService.firestore
              .collection(AppConstants.usersCollection)
              .doc(credential!.user!.uid)
              .delete();
        } on Exception catch (cleanupError) {
          TalkerService.warning(
            'Failed to roll back Firestore user doc (best-effort): $cleanupError',
          );
        }
        await credential!.user!.delete();
      }
      TalkerService.error('Register error', e, st);
      rethrow;
    }
    return null;
  }

  Future<String?> _uploadProfileImage(File image, String uid) async {
    // FIX A-8: Validate file size before upload (max 5 MB)
    const maxSizeBytes = 5 * 1024 * 1024; // 5 MB
    final sizeInBytes = await image.length();
    if (sizeInBytes > maxSizeBytes) {
      final sizeMb = (sizeInBytes / (1024 * 1024)).toStringAsFixed(1);
      throw Exception(
        'Profile image must be smaller than 5 MB (current: $sizeMb MB)',
      );
    }

    try {
      // Create a reference: users/{uid}/profile/profile.jpg
      final ref = _firebaseService.storage
          .ref()
          .child('users')
          .child(uid)
          .child('profile')
          .child('profile.jpg');

      // Upload the file
      final uploadTask = await ref.putFile(image);

      // Get the download URL
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } on Exception catch (e, st) {
      TalkerService.error('Image upload failed', e, st);
      // We return null so the registration doesn't fail completely
      // just because the image failed.
      return null;
    }
  }

  /// Get user data from Firestore

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } on Exception catch (e, st) {
      TalkerService.error('Get user data error', e, st);
    }
    return null;
  }

  Stream<UserModel?> getUserDataStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    });
  }

  /// Sign out

  Future<void> signOut() async {
    try {
      final uid = _firebaseService.auth.currentUser?.uid;
      if (uid != null) {
        await _pushNotificationService.deleteFcmToken(uid);
      }
      await _firebaseService.auth.signOut();
      unawaited(_signOutGoogleBestEffort());
      TalkerService.info('User signed out');
    } on Exception catch (e, st) {
      TalkerService.error('Sign out error', e, st);
      rethrow;
    }
  }

  Future<void> _signOutGoogleBestEffort() async {
    try {
      await GoogleSignIn.instance.signOut().timeout(const Duration(seconds: 2));
    } catch (e) {
      TalkerService.warning('Google sign-out cleanup skipped: $e');
    }
  }

  /// Clears ONLY the Google provider session (not the Firebase session), so the
  /// Google account chooser reappears on the next sign-in. Used by the
  /// onboarding account-switch flow to let the user pick a different account
  /// while keeping the current Firebase user signed in until the new credential
  /// replaces it (so a cancelled switch is a no-op, not a sign-out).
  Future<void> signOutGoogleProvider() => _signOutGoogleBestEffort();

  /// Delete user account and all associated data

  Future<void> deleteAccount() async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final uid = user.uid;

      // FIX A-9: Capture the driver's vehicle IDs (if any) now, before the
      // user's own Firestore doc is deleted later in this flow (it is queued
      // for deletion in `refs` below and only actually removed after the Auth
      // account is deleted) — so the best-effort vehicle cleanup further down
      // still has something to iterate over even though it also runs in the
      // post-Auth-deletion phase.
      final currentUserModel = await getUserData(uid);
      final vehicleIdsToDelete = currentUserModel is DriverModel
          ? currentUserModel.vehicleIds
          : const <String>[];

      // FIX A-1: Block deletion if the user has a ride currently in progress.
      // Orphaning an active ride leaves passengers with no driver and no refund.
      final activeRideQuery = await _firebaseService.firestore
          .collection(AppConstants.ridesCollection)
          .where('driverId', isEqualTo: uid)
          .where('status', isEqualTo: 'inProgress')
          .limit(1)
          .get();
      if (activeRideQuery.docs.isNotEmpty) {
        throw Exception(
          'Cannot delete account while a ride is in progress. '
          'Please complete or cancel the active ride first.',
        );
      }

      // Collect all document references to delete
      final refs = <DocumentReference>[_usersCollection.doc(uid)];

      // User's rides
      final ridesQuery = await _firebaseService.firestore
          .collection(AppConstants.ridesCollection)
          .where('driverId', isEqualTo: uid)
          .get();
      refs.addAll(ridesQuery.docs.map((d) => d.reference));

      // User's bookings
      final bookingsQuery = await _firebaseService.firestore
          .collection(AppConstants.bookingsCollection)
          .where('passengerId', isEqualTo: uid)
          .get();
      refs.addAll(bookingsQuery.docs.map((d) => d.reference));

      // FIX A-2: Delete driver financial records so a deleted UID doesn't
      // leave dangling references in driver_connected_accounts and driver_stats.
      final driverConnectedRef = _firebaseService.firestore
          .collection(AppConstants.connectedAccountsCollection)
          .doc(uid);
      if ((await driverConnectedRef.get()).exists) refs.add(driverConnectedRef);

      final driverStatsRef = _firebaseService.firestore
          .collection(AppConstants.driverStatsCollection)
          .doc(uid);
      if ((await driverStatsRef.get()).exists) refs.add(driverStatsRef);

      // FIX A-3: Delete reviews *written by* this user so deleted users'
      // names don't persist on other people's profiles.
      final reviewsByUserQuery = await _firebaseService.firestore
          .collection(AppConstants.reviewsCollection)
          .where('reviewerId', isEqualTo: uid)
          .get();
      refs.addAll(reviewsByUserQuery.docs.map((d) => d.reference));

      // User's messages
      final messagesQuery = await _firebaseService.firestore
          .collection(AppConstants.messagesCollection)
          .where('senderId', isEqualTo: uid)
          .get();
      refs.addAll(messagesQuery.docs.map((d) => d.reference));

      // User's chats: remove the user from participantIds.
      // Chat deletion is blocked by security rules.
      // Collect the chat references now (read phase); the participant-removal
      // writes are deferred until AFTER the Auth account is deleted so an early
      // deletion failure does not leave other users' chats mutated.
      final chatsQuery = await _firebaseService.firestore
          .collection(AppConstants.chatsCollection)
          .where('participantIds', arrayContains: uid)
          .get();
      final chatRefsToUpdate = <DocumentReference>[];
      // Run the per-chat message queries in parallel rather than sequentially
      // (avoids an N+1 chain of round-trips for users in many chats).
      final chatMessageSnaps = await Future.wait(
        chatsQuery.docs.map(
          (chatDoc) => chatDoc.reference
              .collection(AppConstants.messagesCollection)
              .where('senderId', isEqualTo: uid)
              .get(),
        ),
      );
      for (final snap in chatMessageSnaps) {
        refs.addAll(snap.docs.map((d) => d.reference));
      }
      chatRefsToUpdate.addAll(chatsQuery.docs.map((d) => d.reference));

      // Archive financial records before deletion — retained 10 years per
      // article L.123-22 of the French Code de commerce (legal obligation).
      // Each collection uses a different field to identify the user:
      //   payments  → riderId (passenger) or driverId
      //   payouts   → driverId
      //   bookings  → passengerId or driverId
      // We run separate queries for each role and merge-write into
      // archived_transactions so no document is double-archived (doc ID is
      // the same, so a second write is a safe no-op).
      Future<void> archiveDocs(
        String collection,
        String field,
      ) async {
        final snap = await _firebaseService.firestore
            .collection(collection)
            .where(field, isEqualTo: uid)
            .get();
        if (snap.docs.isEmpty) return;
        // Batch the archive writes (in chunks of 499 to respect the 500-op
        // Firestore batch limit) instead of one sequential await per doc.
        const batchLimit = 499;
        for (var i = 0; i < snap.docs.length; i += batchLimit) {
          final chunk = snap.docs.sublist(
            i,
            i + batchLimit > snap.docs.length
                ? snap.docs.length
                : i + batchLimit,
          );
          final batch = _firebaseService.firestore.batch();
          for (final doc in chunk) {
            batch.set(
              _firebaseService.firestore
                  .collection(AppConstants.archivedTransactionsCollection)
                  .doc(doc.id),
              {
                ...doc.data(),
                'originalCollection': collection,
                'archivedAt': FieldValue.serverTimestamp(),
                'archivedReason': 'account_deletion',
              },
              SetOptions(merge: true),
            );
          }
          await batch.commit();
        }
      }

      // FIX A-1 / A-6: Revoke the Apple token and delete the Auth account
      // FIRST, before any irreversible Firestore/Storage cleanup. This ensures
      // that a cancelled Apple prompt or a 'requires-recent-login' failure
      // aborts the whole deletion while the user's data is still intact, rather
      // than leaving an orphaned Auth account whose data was already wiped.

      // Revoke the Apple auth token before deleting the account, as required
      // by Apple App Store Guidelines §5.1.1 for apps that support Sign in with
      // Apple. Without this, the Apple session remains active after deletion.
      final hasAppleProvider = user.providerData.any(
        (info) => info.providerId == 'apple.com',
      );
      if (hasAppleProvider) {
        try {
          final rawNonce = _generateNonce();
          final nonce = _sha256ofString(rawNonce);
          final appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: const [],
            nonce: nonce,
          );
          await _firebaseService.auth.revokeTokenWithAuthorizationCode(
            appleCredential.authorizationCode,
          );
        } on SignInWithAppleAuthorizationException catch (e) {
          // If the user cancels the Apple prompt, abort the deletion.
          if (e.code == AuthorizationErrorCode.canceled) {
            throw const AuthException(
              code: 'apple-sign-in-canceled',
              message: 'Sign-in was cancelled.',
            );
          }
          TalkerService.warning(
            'Apple token revocation failed (best-effort): $e',
          );
        } on Exception catch (e) {
          TalkerService.warning(
            'Apple token revocation failed (best-effort): $e',
          );
        }
      }

      // Delete the Auth account first. If this throws (e.g.
      // 'requires-recent-login') the catch block below surfaces the error and
      // no user data has been touched yet, so the operation is safely retryable
      // after re-authentication.
      await user.delete();

      // Auth deletion succeeded — now perform the (best-effort) data cleanup.
      // archive financial records, then delete the remaining documents.

      // Remove the user from the chats they participated in. Batch the updates
      // (chunks of 499 to respect the 500-op Firestore batch limit) instead of
      // a sequential await per chat.
      if (chatRefsToUpdate.isNotEmpty) {
        const chatBatchLimit = 499;
        for (var i = 0; i < chatRefsToUpdate.length; i += chatBatchLimit) {
          final chunk = chatRefsToUpdate.sublist(
            i,
            i + chatBatchLimit > chatRefsToUpdate.length
                ? chatRefsToUpdate.length
                : i + chatBatchLimit,
          );
          final batch = _firebaseService.firestore.batch();
          for (final chatRef in chunk) {
            batch.update(chatRef, {
              'participantIds': FieldValue.arrayRemove([uid]),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
          await batch.commit();
        }
      }

      // payments — user may appear as passenger (riderId) or driver (driverId)
      await archiveDocs(AppConstants.paymentsCollection, 'riderId');
      await archiveDocs(AppConstants.paymentsCollection, 'driverId');
      // payouts — driver only
      await archiveDocs(AppConstants.payoutsCollection, 'driverId');
      // bookings — user may appear as passenger or as the ride's driver
      await archiveDocs(AppConstants.bookingsCollection, 'passengerId');
      await archiveDocs(AppConstants.bookingsCollection, 'driverId');

      // Commit in chunks of 499 to stay within Firestore batch limit (500)
      const batchLimit = 499;
      for (var i = 0; i < refs.length; i += batchLimit) {
        final chunk = refs.sublist(
          i,
          i + batchLimit > refs.length ? refs.length : i + batchLimit,
        );
        final batch = _firebaseService.firestore.batch();
        chunk.forEach(batch.delete);
        await batch.commit();
      }

      // FIX A-9: Best-effort delete of the driver's vehicles (Firestore doc +
      // Storage images), reusing VehicleRepository.deleteVehicle so the image
      // cleanup logic isn't duplicated here. Runs per-vehicle in its own
      // try/catch so one vehicle failing (e.g. still linked to an active/full/
      // draft ride, which the earlier in-progress-only check above does not
      // cover) doesn't block cleanup of the rest. The onAuthUserDeleted Cloud
      // Function is the safety net for anything skipped here.
      for (final vehicleId in vehicleIdsToDelete) {
        try {
          await _vehicleRepository.deleteVehicle(vehicleId);
        } on Exception catch (e, st) {
          TalkerService.error(
            'Vehicle cleanup failed for $vehicleId (best-effort)',
            e,
            st,
          );
        }
      }

      // Clean up storage (profile images)
      try {
        final storagePrefixes = ['users/$uid/profile', 'users/$uid/cover'];
        for (final prefixPath in storagePrefixes) {
          final result = await _firebaseService.storage
              .ref(prefixPath)
              .listAll();
          for (final ref in result.items) {
            await ref.delete();
          }
        }
      } on FirebaseException catch (e) {
        TalkerService.warning(
          'Storage cleanup failed (best-effort): ${e.code}',
        );
      }
      // FIX A-10: Use disconnect() rather than signOut(). signOut() only
      // clears the local session — it does NOT revoke the Google OAuth grant
      // server-side, unlike the Apple revocation above. disconnect() revokes
      // the granted scopes server-side (and signs the local session out as
      // part of that), which is the Google equivalent of what Apple's
      // revokeTokenWithAuthorizationCode already does. Unlike Apple, there is
      // no prior App Store rejection requiring this to be a hard blocker, so a
      // failure here is logged (not silently swallowed) but does not abort an
      // otherwise-successful account deletion.
      try {
        await GoogleSignIn.instance.disconnect();
      } on Exception catch (e) {
        TalkerService.warning(
          'Google account disconnect failed (best-effort): $e',
        );
      }

      TalkerService.info('User account and data deleted: $uid');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Delete account error: ${e.code}');
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          code: e.code,
          message: 'Please re-authenticate before deleting your account',
        );
      }
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Delete account error', e, st);
      rethrow;
    }
  }

  /// Sign in with Google

  Future<SocialSignInResult> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      final userCredential = await _firebaseService.auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        final existingUser = await getUserData(userCredential.user!.uid);

        if (existingUser != null) {
          if (existingUser.isBanned) {
            await _firebaseService.auth.signOut();
            throw const AuthException(
              code: 'account-disabled',
              message:
                  'Your account has been suspended. Please contact support.',
            );
          }

          // A pending user never finished role selection + onboarding.
          // Treat them as new so the router sends them back through onboarding,
          // not directly into the app.
          final isPending = existingUser.role == UserRole.pending;

          // Only write back if fully onboarded — writing a pending doc with
          // merge:true is a no-op at best and can corrupt timestamps at worst.
          if (!isPending) {
            await _usersCollection
                .doc(userCredential.user!.uid)
                .set(existingUser, SetOptions(merge: true));
          }

          return SocialSignInResult(user: existingUser, isNewUser: isPending);
        } else {
          final newUser = UserModel.pending(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            username: userCredential.user!.displayName ?? 'User',
            photoUrl: userCredential.user!.photoURL,
            isEmailVerified: true,
          );

          await _usersCollection.doc(userCredential.user!.uid).set(newUser);

          TalkerService.info('New user created via Google sign in');
          return SocialSignInResult(user: newUser, isNewUser: true);
        }
      }

      throw Exception('Google sign-in failed: no user returned');
    } on GoogleSignInException catch (e) {
      TalkerService.error(
        'GoogleSignInException: code=${e.code.name} description=${e.description}',
      );
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException(
          code: 'google-sign-in-canceled',
          message: 'Sign-in was cancelled.',
        );
      }
      _firebaseService.recordError(
        e,
        StackTrace.current,
        reason: 'GoogleSignIn non-canceled: ${e.code.name}',
      );
      throw AuthException(
        code: 'google-sign-in-failed',
        message: 'Google sign-in failed (${e.code.name}). Please try again.',
      );
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Google sign in error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Google sign in error', e, st);
      rethrow;
    }
  }

  /// Sign in with Apple

  Future<SocialSignInResult> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw const AuthException(
          code: 'apple-sign-in-failed',
          message: 'Apple did not return an identity token. Please try again.',
        );
      }

      final oauthCredential = _appleCredentialWithIdToken(
        idToken: idToken,
        rawNonce: rawNonce,
        givenName: appleCredential.givenName,
        familyName: appleCredential.familyName,
      );

      final userCredential = await _firebaseService.auth.signInWithCredential(
        oauthCredential,
      );

      if (userCredential.user != null) {
        final existingUser = await getUserData(userCredential.user!.uid);

        if (existingUser != null) {
          if (existingUser.isBanned) {
            await _firebaseService.auth.signOut();
            throw const AuthException(
              code: 'account-disabled',
              message:
                  'Your account has been suspended. Please contact support.',
            );
          }

          // A pending user never finished role selection + onboarding.
          // Treat them as new so the router sends them back through onboarding,
          // not directly into the app.
          final isPending = existingUser.role == UserRole.pending;

          if (!isPending) {
            await _usersCollection
                .doc(userCredential.user!.uid)
                .set(existingUser, SetOptions(merge: true));
          }

          return SocialSignInResult(user: existingUser, isNewUser: isPending);
        } else {
          var displayName = 'User';
          if (appleCredential.givenName != null) {
            displayName =
                '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
                    .trim();
          } else if (userCredential.user!.displayName != null) {
            displayName = userCredential.user!.displayName!;
          }

          final newUser = UserModel.pending(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? appleCredential.email ?? '',
            username: displayName,
            isEmailVerified: true,
          );

          await _usersCollection.doc(userCredential.user!.uid).set(newUser);

          TalkerService.info('New user created via Apple sign in');
          return SocialSignInResult(user: newUser, isNewUser: true);
        }
      }

      throw Exception('Apple sign-in failed: no user returned');
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        TalkerService.info('Apple sign-in cancelled by user');
        throw const AuthException(
          code: 'apple-sign-in-canceled',
          message: 'Sign-in was cancelled.',
        );
      } else {
        TalkerService.error(
          'Apple sign-in error: code=${e.code.name} message=${e.message}',
        );
        throw AuthException(
          code: 'apple-sign-in-failed',
          message: 'Apple sign-in failed (${e.code.name}). Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Apple sign in Firebase error: ${e.code}');
      throw mapAppleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Apple sign in error', e, st);
      rethrow;
    }
  }

  /// Best practice (Apple): on launch, verify the user's Sign in with Apple
  /// credential is still valid. If the user revoked access for this app (e.g.
  /// via iOS Settings → Apple ID → Sign in with Apple), sign them out so they
  /// re-authenticate.
  ///
  /// Conservative & best-effort: only acts on a definitive [CredentialState.revoked]
  /// (never on the ambiguous `notFound`, which is normal on a device where the
  /// user didn't natively sign in), is skipped on non-Apple platforms, and is
  /// skipped against the Auth emulator (the native Apple API can't validate
  /// emulator/test identifiers). Reads the Apple user identifier directly from
  /// the Firebase user's `apple.com` provider data — no extra local storage.
  Future<void> verifyAppleCredentialState() async {
    if (AppConfig.useEmulators) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    final user = _firebaseService.auth.currentUser;
    if (user == null) return;

    String? appleUserId;
    for (final info in user.providerData) {
      if (info.providerId == 'apple.com' &&
          info.uid != null &&
          info.uid!.isNotEmpty) {
        appleUserId = info.uid;
        break;
      }
    }
    if (appleUserId == null) return;

    try {
      final state = await SignInWithApple.getCredentialState(appleUserId);
      if (state == CredentialState.revoked) {
        TalkerService.info('Apple credential revoked — signing out.');
        await _firebaseService.auth.signOut();
      }
    } on Exception catch (e) {
      // Never block the app if the platform check fails.
      TalkerService.warning('Apple credential-state check failed: $e');
    }
  }

  /// Helpers
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  OAuthCredential _appleCredentialWithIdToken({
    required String idToken,
    required String rawNonce,
    String? givenName,
    String? familyName,
  }) {
    return AppleAuthProvider.credentialWithIDToken(
      idToken,
      rawNonce,
      AppleFullPersonName(
        givenName: givenName,
        familyName: familyName,
      ),
    );
  }

  /// Create or update user document in Firestore.
  ///
  /// Useful for syncing Firebase Auth user with Firestore document.

  Future<UserModel> createUserDocument(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user, SetOptions(merge: true));
      TalkerService.info('User document created/updated for ${user.uid}');
      return user;
    } on Exception catch (e, st) {
      TalkerService.error('Create user document error', e, st);
      rethrow;
    }
  }

  /// Update user gamification stats (XP, rides, etc.).

  Future<void> updateUserStats({
    required String userId,
    int? xpIncrement,
    int? ridesOfferedIncrement,
    int? ridesCompletedIncrement,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'gamification.totalXP': FieldValue.increment(xpIncrement ?? 0),
        'gamification.totalRides': FieldValue.increment(
          ridesCompletedIncrement ?? 0,
        ),
      });
      TalkerService.info('User stats updated for $userId');
    } on Exception catch (e, st) {
      TalkerService.error('Update user stats error', e, st);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email.trim());
      TalkerService.info('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Password reset error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Password reset error', e, st);
      rethrow;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      await user.updatePassword(newPassword);
      TalkerService.info('Password updated successfully');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Update password error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Update password error', e, st);
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(File image, String uid) async {
    return _uploadProfileImage(image, uid);
  }

  /// Resolves a [PendingUserModel] into a fully-typed [RiderModel] or [DriverModel].
  ///
  /// Called exactly once per user — when they complete role selection after
  /// a social sign-in. Reads the existing pending document to preserve all
  /// fields written at sign-in (email, username, photoUrl, fcmToken, etc.),
  /// then replaces it with a complete typed document.
  ///
  /// Throws [StateError] if:
  /// - No document exists for [uid]
  /// - [role] is [UserRole.pending] (cannot finalize into pending)

  Future<UserModel> finalizeRoleAs(String uid, UserRole role) async {
    assert(
      role != UserRole.pending,
      'finalizeRoleAs: cannot finalize into pending role',
    );

    try {
      final existing = await getUserData(uid);
      if (existing == null) {
        throw StateError('finalizeRoleAs: no user document found for $uid');
      }

      final rawDoc = await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      final rawData = rawDoc.data() ?? const <String, dynamic>{};

      final phoneNumber = rawData['phoneNumber'] as String?;
      final gender = rawData['gender'] as String?;
      final address = rawData['address'] as String?;
      final latitude = (rawData['latitude'] as num?)?.toDouble();
      final longitude = (rawData['longitude'] as num?)?.toDouble();
      final dateOfBirthTs = rawData['dateOfBirth'] as Timestamp?;
      final dateOfBirth = dateOfBirthTs?.toDate();
      final vehicleIds = (rawData['vehicleIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false);
      final stripeAccountId = rawData['stripeAccountId'] as String?;

      // Guard against double-finalization — if already finalized, return as-is
      // without overwriting onboarding data written by the first call.
      if (existing.role != UserRole.pending) {
        TalkerService.warning(
          'finalizeRoleAs: user $uid already has role ${existing.role.name}, skipping.',
        );
        return existing;
      }

      final finalized = switch (role) {
        UserRole.rider => UserModel.rider(
          uid: existing.uid,
          email: existing.email,
          username: existing.username,
          photoUrl: existing.photoUrl,
          phoneNumber: phoneNumber,
          gender: gender,
          address: address,
          latitude: latitude,
          longitude: longitude,
          dateOfBirth: dateOfBirth,
          expertise: existing.expertise,
          isEmailVerified: existing.isEmailVerified,
          isBanned: existing.isBanned,
          fcmToken: existing.fcmToken,
          createdAt: existing.createdAt,
        ),
        UserRole.driver => UserModel.driver(
          uid: existing.uid,
          email: existing.email,
          username: existing.username,
          photoUrl: existing.photoUrl,
          phoneNumber: phoneNumber,
          gender: gender,
          address: address,
          latitude: latitude,
          longitude: longitude,
          dateOfBirth: dateOfBirth,
          expertise: existing.expertise,
          isEmailVerified: existing.isEmailVerified,
          isBanned: existing.isBanned,
          fcmToken: existing.fcmToken,
          vehicleIds: vehicleIds,
          stripeAccountId: stripeAccountId,
          createdAt: existing.createdAt,
        ),
        UserRole.pending => throw StateError(
          'finalizeRoleAs: cannot finalize into pending role',
        ),
      };

      await _usersCollection.doc(uid).set(finalized);

      TalkerService.info('User $uid finalized role as ${role.name}');

      return finalized;
    } on Exception catch (e, st) {
      TalkerService.error('finalizeRoleAs error', e, st);
      rethrow;
    }
  }

  AuthException _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        // Return a single generic message for all credential errors to prevent
        // email enumeration — an attacker must not be able to tell whether the
        // email or password was wrong.
        return AuthException(
          code: 'invalid-credential',
          message: 'Invalid email or password',
        );
      case 'email-already-in-use':
        return AuthException(code: e.code, message: 'Email already in use');
      case 'invalid-email':
        return AuthException(code: e.code, message: 'Invalid email address');
      case 'weak-password':
        return AuthException(code: e.code, message: 'Password is too weak');
      case 'too-many-requests':
        return AuthException(
          code: e.code,
          message: 'Too many attempts. Please try again later',
        );
      case 'requires-recent-login':
        return AuthException(
          code: e.code,
          message: 'Please re-authenticate to continue',
        );
      case 'account-exists-with-different-credential':
        return AuthException(
          code: e.code,
          message:
              'An account already exists with a different sign-in method. '
              'Try signing in with email/password or the original provider.',
        );
      default:
        return AuthException(
          code: e.code,
          message: e.message ?? 'An unknown error occurred',
        );
    }
  }

  /// Re-authenticate user with email/password for sensitive operations.
  ///
  /// Required before [deleteAccount] or [updatePassword] when the session
  /// is too old (Firebase throws `requires-recent-login`).

  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user is currently signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      TalkerService.info('User re-authenticated successfully');
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Re-authentication error: ${e.code}');
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Re-authentication error', e, st);
      rethrow;
    }
  }

  /// Re-authenticate user with Google credential for sensitive operations.

  Future<void> reauthenticateWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();

      // FIX A-7: Verify the Google account email matches the current user's email
      final currentEmail = _firebaseService.auth.currentUser?.email;
      if (currentEmail != null && googleUser.email != currentEmail) {
        throw const AuthException(
          code: 'email-mismatch',
          message:
              'The selected Google account does not match your account email. '
              'Please choose the correct account.',
        );
      }

      // idToken alone is sufficient for reauthentication.
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.reauthenticateWithCredential(credential);
      TalkerService.info('User re-authenticated with Google');
    } on Exception catch (e, st) {
      TalkerService.error('Google re-authentication error', e, st);
      rethrow;
    }
  }

  /// Re-authenticate user with Apple credential for sensitive operations.
  Future<void> reauthenticateWithApple() async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [],
        nonce: nonce,
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null) {
        throw const AuthException(
          code: 'apple-sign-in-failed',
          message: 'Apple did not return an identity token. Please try again.',
        );
      }

      final oauthCredential = _appleCredentialWithIdToken(
        idToken: idToken,
        rawNonce: rawNonce,
      );
      await user.reauthenticateWithCredential(oauthCredential);
      TalkerService.info('User re-authenticated with Apple');
    } on SignInWithAppleAuthorizationException catch (e, st) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException(
          code: 'apple-sign-in-canceled',
          message: 'Sign-in was cancelled.',
        );
      }
      TalkerService.error(
        'Apple re-authentication error: ${e.code.name}',
        e,
        st,
      );
      throw const AuthException(
        code: 'apple-sign-in-failed',
        message: 'Apple re-authentication failed. Please try again.',
      );
    } on FirebaseAuthException catch (e, st) {
      TalkerService.error(
        'Apple re-authentication Firebase error: ${e.code}',
        e,
        st,
      );
      throw mapAppleAuthException(e, isReauthentication: true);
    } on Exception catch (e, st) {
      TalkerService.error('Apple re-authentication error', e, st);
      rethrow;
    }
  }

  // =========================================================================
  // Email Verification
  // =========================================================================

  /// Send a verification email to the current user.

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseService.auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // FIX A-5: Enforce a 60-second cooldown between verification email sends
      const cooldownSeconds = 60;
      final rawUserDoc = await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      final lastSentTs =
          rawUserDoc.data()?['lastEmailVerificationSentAt'] as Timestamp?;
      if (lastSentTs != null) {
        final elapsed = DateTime.now()
            .difference(lastSentTs.toDate())
            .inSeconds;
        if (elapsed < cooldownSeconds) {
          final remaining = cooldownSeconds - elapsed;
          throw Exception(
            'Please wait $remaining seconds before requesting another verification email.',
          );
        }
      }

      await user.sendEmailVerification();
      await _firebaseService.firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
            'lastEmailVerificationSentAt': FieldValue.serverTimestamp(),
          });
      TalkerService.info('Verification email sent to ${user.email}');
    } on FirebaseAuthException catch (e, st) {
      TalkerService.error('Send verification email error: ${e.code}', e, st);
      throw _handleAuthException(e);
    } on Exception catch (e, st) {
      TalkerService.error('Send verification email error', e, st);
      rethrow;
    }
  }

  /// Check whether the current user's email is verified.
  ///
  /// Reloads the user first to get the latest status from Firebase.

  Future<bool> isEmailVerified() async {
    final user = _firebaseService.auth.currentUser;
    if (user == null) return false;
    await user.reload();
    final refreshedUser = _firebaseService.auth.currentUser;
    final verified = refreshedUser?.emailVerified ?? false;
    // FIX A-7: Force an ID-token refresh once verification is detected so that
    // request.auth.token.email_verified becomes true immediately for
    // Security-Rules-gated reads, instead of waiting for the ~hourly refresh.
    if (verified && refreshedUser != null) {
      await refreshedUser.getIdToken(true);
    }
    return verified;
  }

  /// Reload the current Firebase Auth user to refresh cached properties
  /// such as [User.emailVerified].

  Future<void> reloadUser() async {
    await _firebaseService.auth.currentUser?.reload();
  }
}
