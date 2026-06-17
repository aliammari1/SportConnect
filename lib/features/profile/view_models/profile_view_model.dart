import 'dart:async';
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/user_facing_error.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/features/auth/repositories/auth_repository.dart';
import 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/profile/repositories/support_repository.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';

part 'profile_view_model.g.dart';

/// Profile Edit State
class ProfileEditState {
  const ProfileEditState({
    this.username = '',
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.expertise = Expertise.rookie,
    this.addressResult,
    this.newPhotoFile,
    this.imageRemoved = false,
    this.hasChanges = false,
    this.isLoading = false,
    this.isSaved = false,
    this.error,
  });

  factory ProfileEditState.fromUser(UserModel user) {
    return ProfileEditState(
      username: user.username,
      phoneNumber: switch (user) {
        final RiderModel rider => rider.phoneNumber,
        final DriverModel driver => driver.phoneNumber,
        _ => null,
      },
      dateOfBirth: switch (user) {
        final RiderModel rider => rider.dateOfBirth,
        final DriverModel driver => driver.dateOfBirth,
        _ => null,
      },
      gender: switch (user) {
        final RiderModel rider => rider.gender,
        final DriverModel driver => driver.gender,
        _ => null,
      },
      expertise: user.expertise,
    );
  }
  final String username;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final Expertise expertise;
  final AddressResult? addressResult;
  final File? newPhotoFile;
  final bool imageRemoved;
  final bool hasChanges;
  final bool isLoading;
  final bool isSaved;
  final String? error;

  ProfileEditState copyWith({
    String? username,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    Expertise? expertise,
    AddressResult? addressResult,
    bool clearAddressResult = false,
    File? newPhotoFile,
    bool clearNewPhotoFile = false,
    bool? imageRemoved,
    bool? hasChanges,
    bool? isLoading,
    bool? isSaved,
    String? error,
  }) {
    return ProfileEditState(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      expertise: expertise ?? this.expertise,
      addressResult: clearAddressResult
          ? null
          : (addressResult ?? this.addressResult),
      newPhotoFile: clearNewPhotoFile
          ? null
          : (newPhotoFile ?? this.newPhotoFile),
      imageRemoved: imageRemoved ?? this.imageRemoved,
      hasChanges: hasChanges ?? this.hasChanges,
      isLoading: isLoading ?? this.isLoading,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }
}

class ContactSupportState {
  const ContactSupportState({
    this.selectedCategory = defaultCategory,
    this.subject = '',
    this.message = '',
    this.attachedFiles = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
    this.subjectError,
    this.messageError,
  });
  static const defaultCategory = 'General';

  final String selectedCategory;
  final String subject;
  final String message;
  final List<File> attachedFiles;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;
  final String? subjectError;
  final String? messageError;

  ContactSupportState copyWith({
    String? selectedCategory,
    String? subject,
    String? message,
    List<File>? attachedFiles,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool clearError = false,
    String? subjectError,
    String? messageError,
    bool clearSubjectError = false,
    bool clearMessageError = false,
  }) {
    return ContactSupportState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      subjectError: clearSubjectError
          ? null
          : (subjectError ?? this.subjectError),
      messageError: clearMessageError
          ? null
          : (messageError ?? this.messageError),
    );
  }
}

class ReportIssueFormArgs {
  const ReportIssueFormArgs({this.rideId, this.reportedUserId});

  final String? rideId;
  final String? reportedUserId;

  @override
  bool operator ==(Object other) {
    return other is ReportIssueFormArgs &&
        other.rideId == rideId &&
        other.reportedUserId == reportedUserId;
  }

  @override
  int get hashCode => Object.hash(rideId, reportedUserId);
}

class ReportIssueFormState {
  const ReportIssueFormState({
    this.selectedType,
    this.severity = 'medium',
    this.description = '',
    this.attachedFiles = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.typeError,
    this.descriptionError,
    this.errorMessage,
  });
  static const _unset = Object();

  final String? selectedType;
  final String severity;
  final String description;
  final List<File> attachedFiles;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? typeError;
  final String? descriptionError;
  final String? errorMessage;

  ReportIssueFormState copyWith({
    Object? selectedType = _unset,
    String? severity,
    String? description,
    List<File>? attachedFiles,
    bool? isSubmitting,
    bool? isSubmitted,
    String? typeError,
    String? descriptionError,
    String? errorMessage,
    bool clearTypeError = false,
    bool clearDescriptionError = false,
    bool clearError = false,
  }) {
    return ReportIssueFormState(
      selectedType: selectedType == _unset
          ? this.selectedType
          : selectedType as String?,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      typeError: clearTypeError ? null : (typeError ?? this.typeError),
      descriptionError: clearDescriptionError
          ? null
          : (descriptionError ?? this.descriptionError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// keepAlive: action-only VM - accessed from notification/background contexts.
@Riverpod(keepAlive: true)
class ProfileActionsViewModel extends _$ProfileActionsViewModel {
  @override
  void build() {
    return;
  }

  Future<List<UserModel>> searchUsers({required String query}) {
    final currentUser = ref.read(currentUserProvider).value;
    final blockedUsers = switch (currentUser) {
      final RiderModel rider => rider.asRider?.blockedUsers ?? <String>[],
      final DriverModel driver => driver.asDriver?.blockedUsers ?? <String>[],
      _ => <String>[],
    };
    final excludedIds = <String>{
      if (currentUser != null) currentUser.uid,
      ...blockedUsers,
    };
    return ref
        .read(profileRepositoryProvider)
        .searchUsers(
          query: query,
          excludeUserIds: excludedIds,
          excludeUsersWhoBlockedId: currentUser?.uid,
        );
  }

  Future<UserModel?> getUserById(String userId) {
    return ref.read(profileRepositoryProvider).getUserById(userId);
  }

  Future<List<UserModel>> getUsersByIds(Iterable<String> userIds) async {
    final ids = userIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (ids.isEmpty) return const <UserModel>[];

    final repository = ref.read(profileRepositoryProvider);
    final users = await Future.wait(ids.map(repository.getUserById));

    final usersById = <String, UserModel>{};
    for (final user in users.whereType<UserModel>()) {
      usersById[user.uid] = user;
    }

    // Keep the same order as blocked IDs and preserve unknown IDs as fallback entries.
    return ids
        .map(
          (id) =>
              usersById[id] ??
              UserModel.rider(uid: id, email: '', username: id),
        )
        .toList(growable: false);
  }

  Future<List<UserModel>> getBlockedUsersForCurrentUser() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      return const <UserModel>[];
    }
    final blockedUsers = switch (currentUser) {
      final RiderModel rider => rider.asRider?.blockedUsers ?? <String>[],
      final DriverModel driver => driver.asDriver?.blockedUsers ?? <String>[],
      _ => <String>[],
    };
    if (blockedUsers.isEmpty) {
      return const <UserModel>[];
    }
    return getUsersByIds(blockedUsers);
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) {
    return ref
        .read(profileRepositoryProvider)
        .unblockUser(currentUserId, blockedUserId);
  }

  Future<void> unblockCurrentUser(String blockedUserId) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw StateError('No current user found while trying to unblock user.');
    }

    await unblockUser(
      currentUserId: currentUser.uid,
      blockedUserId: blockedUserId,
    );
  }

  Future<void> updateProfile(String uid, Map<String, dynamic> updates) {
    return ref.read(profileRepositoryProvider).updateProfile(uid, updates);
  }

  Future<void> updateProfilePhoto(String uid, File imageFile) {
    return ref
        .read(profileRepositoryProvider)
        .updateProfilePhoto(uid, imageFile);
  }

  Future<void> setDefaultVehicle(String uid, String vehicleId) {
    return ref
        .read(profileRepositoryProvider)
        .setDefaultVehicle(uid, vehicleId);
  }

  Future<void> removeVehicle(String uid, String vehicleId) {
    return ref.read(profileRepositoryProvider).removeVehicle(uid, vehicleId);
  }

  Future<void> updateVehicle(String uid, VehicleModel vehicle) {
    return ref.read(profileRepositoryProvider).updateVehicle(uid, vehicle);
  }

  Future<void> addVehicle(String uid, VehicleModel vehicle) {
    return ref.read(profileRepositoryProvider).addVehicle(uid, vehicle);
  }

  /// Submits a report about a user or ride.
  Future<String> submitReport({
    required String reporterId,
    required String reporterEmail,
    required String type,
    required String severity,
    required String description,
    String? reportedUserId,
    String? rideId,
    List<File> attachments = const [],
  }) {
    return ref
        .read(supportRepositoryProvider)
        .submitReport(
          reporterId: reporterId,
          reporterEmail: reporterEmail,
          type: type,
          severity: severity,
          description: description,
          reportedUserId: reportedUserId,
          rideId: rideId,
          attachments: attachments,
        );
  }

  /// Submits a support ticket on behalf of the user.
  Future<String> submitSupportTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String category,
    required String subject,
    required String message,
    List<File> attachments = const [],
  }) {
    return ref
        .read(supportRepositoryProvider)
        .submitSupportTicket(
          userId: userId,
          userEmail: userEmail,
          userName: userName,
          category: category,
          subject: subject,
          message: message,
          attachments: attachments,
        );
  }
}

@riverpod
Future<List<UserModel>> blockedUsers(Ref ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) {
    return const [];
  }
  final blockedUsers = switch (currentUser) {
    final RiderModel rider => rider.asRider?.blockedUsers ?? <String>[],
    final DriverModel driver => driver.asDriver?.blockedUsers ?? <String>[],
    _ => <String>[],
  };
  if (blockedUsers.isEmpty) {
    return const <UserModel>[];
  }
  final actions = ref.watch(profileActionsViewModelProvider.notifier);
  return actions.getUsersByIds(blockedUsers);
}

@riverpod
class ReportIssueFormViewModel extends _$ReportIssueFormViewModel {
  static const int maxAttachments = 5;
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int minDescriptionLength = 20;

  late final ReportIssueFormArgs _args;

  @override
  ReportIssueFormState build(ReportIssueFormArgs args) {
    _args = args;
    return const ReportIssueFormState();
  }

  void selectType(String type) {
    state = state.copyWith(
      selectedType: type,
      clearTypeError: true,
      clearError: true,
    );
  }

  void setSeverity(String severity) {
    state = state.copyWith(severity: severity, clearError: true);
  }

  void updateDescription(String description) {
    state = state.copyWith(
      description: description,
      clearDescriptionError: true,
      clearError: true,
    );
  }

  Future<void> addAttachment(File file) async {
    if (state.attachedFiles.length >= maxAttachments) {
      state = state.copyWith(
        errorMessage: 'Maximum $maxAttachments files allowed',
      );
      return;
    }

    if (state.attachedFiles.any((existing) => existing.path == file.path)) {
      state = state.copyWith(errorMessage: 'That file is already attached.');
      return;
    }

    final size = await file.length();
    if (!ref.mounted) return;
    if (size > maxFileSizeBytes) {
      state = state.copyWith(errorMessage: 'File exceeds 10 MB limit');
      return;
    }

    state = state.copyWith(
      attachedFiles: [...state.attachedFiles, file],
      clearError: true,
    );
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= state.attachedFiles.length) {
      return;
    }

    final updatedFiles = [...state.attachedFiles]..removeAt(index);
    state = state.copyWith(attachedFiles: updatedFiles, clearError: true);
  }

  bool _validate() {
    final description = state.description.trim();
    final typeError = state.selectedType == null
        ? 'Please select an issue type'
        : null;
    String? descriptionError;

    if (description.isEmpty) {
      descriptionError = 'Please describe the issue';
    } else if (description.length < minDescriptionLength) {
      descriptionError =
          'Please provide at least $minDescriptionLength characters '
          '(${description.length}/$minDescriptionLength)';
    }

    state = state.copyWith(
      typeError: typeError,
      descriptionError: descriptionError,
      clearError: true,
    );

    return typeError == null && descriptionError == null;
  }

  Future<void> submit({
    required String reporterId,
    required String reporterEmail,
  }) async {
    if (state.isSubmitting || !_validate()) {
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      isSubmitted: false,
      clearError: true,
    );

    try {
      await ref
          .read(profileActionsViewModelProvider.notifier)
          .submitReport(
            reporterId: reporterId,
            reporterEmail: reporterEmail,
            type: state.selectedType!,
            severity: state.severity,
            description: state.description.trim(),
            reportedUserId: _args.reportedUserId,
            rideId: _args.rideId,
            attachments: state.attachedFiles,
          );

      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit report. Please try again.',
      );
    }
  }
}

/// Current User Profile Stream
@riverpod
Stream<UserModel?> currentUserProfile(Ref ref, String uid) {
  final repository = ref.read(profileRepositoryProvider);
  return repository.streamUser(uid);
}

/// Other User Profile
@riverpod
Future<UserModel?> userProfile(Ref ref, String uid) async {
  final repository = ref.read(profileRepositoryProvider);
  final profile = await repository.getUserById(uid);
  final cacheLink = ref.keepAlive();
  final cacheTimer = Timer(const Duration(minutes: 5), cacheLink.close);
  ref.onDispose(cacheTimer.cancel);
  return profile;
}

/// Profile Edit View Model
@riverpod
class ProfileEditViewModel extends _$ProfileEditViewModel {
  @override
  ProfileEditState build(String uid) {
    return const ProfileEditState();
  }

  void initFromUser(UserModel user) {
    state = ProfileEditState.fromUser(user);
  }

  void markChanged() {
    if (state.hasChanges) return;
    state = state.copyWith(hasChanges: true, isSaved: false);
  }

  void clearChanges() {
    state = state.copyWith(hasChanges: false);
  }

  void setDisplayName(String name) {
    state = state.copyWith(username: name, hasChanges: true, isSaved: false);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(
      phoneNumber: phone,
      hasChanges: true,
      isSaved: false,
    );
  }

  void setDateOfBirth(DateTime date) {
    state = state.copyWith(dateOfBirth: date, hasChanges: true, isSaved: false);
  }

  void setGender(String gender) {
    state = state.copyWith(gender: gender, hasChanges: true, isSaved: false);
  }

  void setExpertise(Expertise expertise) {
    state = state.copyWith(
      expertise: expertise,
      hasChanges: true,
      isSaved: false,
    );
  }

  void setAddressResult(AddressResult? result) {
    state = state.copyWith(
      addressResult: result,
      clearAddressResult: result == null,
      hasChanges: true,
      isSaved: false,
    );
  }

  void setPhotoFile(File? file) {
    state = state.copyWith(
      newPhotoFile: file,
      clearNewPhotoFile: file == null,
      imageRemoved: false,
      hasChanges: true,
      isSaved: false,
    );
  }

  void removePhoto() {
    state = state.copyWith(
      clearNewPhotoFile: true,
      imageRemoved: true,
      hasChanges: true,
      isSaved: false,
    );
  }

  Future<bool> saveProfile() async {
    if (state.username.trim().isEmpty) {
      state = state.copyWith(error: 'Display name is required');
      return false;
    }

    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);

      // Upload photo if changed
      if (state.newPhotoFile != null) {
        await repository.updateProfilePhoto(uid, state.newPhotoFile!);
        if (!ref.mounted) return false;
      }

      // Update profile
      await repository.updateProfile(uid, {
        'username': state.username,
        'phoneNumber': state.phoneNumber,
        'dateOfBirth': state.dateOfBirth,
        'gender': state.gender,
        'expertise': state.expertise.name,
      });

      if (!ref.mounted) return true;
      state = state.copyWith(
        isLoading: false,
        isSaved: true,
        hasChanges: false,
      );
      return true;
    } on Exception catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
      return false;
    }
  }

  Future<bool> saveUserProfile({
    required UserModel updatedUser,
    File? newPhotoFile,
    bool removePhoto = false,
  }) async {
    state = state.copyWith(isLoading: true, isSaved: false);

    try {
      var photoUrl = updatedUser.photoUrl;

      if (newPhotoFile != null) {
        photoUrl = await ref
            .read(authRepositoryProvider)
            .uploadProfileImage(newPhotoFile, updatedUser.uid);
        if (!ref.mounted) return false;
      } else if (removePhoto) {
        // Delete the Storage file before clearing the Firestore URL so the
        // file is not left as an orphan. deleteProfilePhoto also sets
        // photoUrl to null in Firestore; we set it here too so the in-memory
        // user object is consistent.
        await ref
            .read(profileRepositoryProvider)
            .deleteProfilePhoto(updatedUser.uid);
        if (!ref.mounted) return false;
        photoUrl = null;
      }

      final finalUser = updatedUser.map(
        rider: (rider) => rider.copyWith(photoUrl: photoUrl),
        driver: (driver) => driver.copyWith(photoUrl: photoUrl),
        pending: (value) => value, // No editing
      );

      // PROF-3: persist only the user-editable subset. Writing the full
      // toJson() map would let the client silently overwrite server-managed
      // fields (email, role, isBanned, isPremium, rating, gamification,
      // stripe IDs, createdAt). These must stay server-controlled and be
      // locked down by Firestore Security Rules. We pick the safe keys from
      // the serialized map so value conversions (timestamps, enums) match.
      const editableFields = <String>{
        'username',
        'phoneNumber',
        'dateOfBirth',
        'gender',
        'address',
        'expertise',
        'photoUrl',
      };
      final serialized = finalUser.toJson();
      final editableUpdates = <String, dynamic>{
        for (final key in editableFields)
          if (serialized.containsKey(key)) key: serialized[key],
      };

      await ref
          .read(profileRepositoryProvider)
          .updateProfile(finalUser.uid, editableUpdates);

      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isSaved: true,
        hasChanges: false,
      );
      return true;
    } on Exception catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        isSaved: false,
        error: userFacingError(e),
      );
      return false;
    }
  }
}

@riverpod
class ContactSupportViewModel extends _$ContactSupportViewModel {
  @override
  ContactSupportState build() => const ContactSupportState();

  static const int maxAttachments = 5;
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category, clearError: true);
  }

  void setSubject(String subject) {
    state = state.copyWith(
      subject: subject,
      clearError: true,
      clearSubjectError: true,
    );
  }

  void setMessage(String message) {
    state = state.copyWith(
      message: message,
      clearError: true,
      clearMessageError: true,
    );
  }

  Future<void> addAttachment(File file) async {
    if (state.attachedFiles.length >= maxAttachments) {
      state = state.copyWith(
        errorMessage: 'Maximum $maxAttachments files allowed',
      );
      return;
    }

    if (state.attachedFiles.any((existing) => existing.path == file.path)) {
      state = state.copyWith(errorMessage: 'That file is already attached.');
      return;
    }

    final size = await file.length();
    if (!ref.mounted) return;
    if (size > maxFileSizeBytes) {
      state = state.copyWith(errorMessage: 'File exceeds 10 MB limit');
      return;
    }

    state = state.copyWith(
      attachedFiles: [...state.attachedFiles, file],
      clearError: true,
    );
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= state.attachedFiles.length) {
      return;
    }

    final updatedFiles = [...state.attachedFiles]..removeAt(index);
    state = state.copyWith(attachedFiles: updatedFiles, clearError: true);
  }

  bool _validate() {
    final subject = state.subject.trim();
    final message = state.message.trim();
    final subjectError = subject.isEmpty
        ? 'Please enter a subject'
        : (subject.length < 3 ? 'Subject must be at least 3 characters' : null);
    final messageError = message.isEmpty
        ? 'Please describe your issue'
        : (message.length < 10
              ? 'Please provide at least 10 characters'
              : null);

    state = state.copyWith(
      subjectError: subjectError,
      messageError: messageError,
      clearError: true,
    );

    return subjectError == null && messageError == null;
  }

  Future<void> submitTicket({
    required String userId,
    required String userEmail,
    required String userName,
  }) async {
    if (state.isSubmitting || !_validate()) {
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      isSubmitted: false,
      clearError: true,
    );

    try {
      await ref
          .read(supportRepositoryProvider)
          .submitSupportTicket(
            userId: userId,
            userEmail: userEmail,
            userName: userName,
            category: state.selectedCategory,
            subject: state.subject.trim(),
            message: state.message.trim(),
            attachments: state.attachedFiles,
          );

      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit your request. Please try again.',
      );
    }
  }

  void reset() {
    state = const ContactSupportState();
  }
}

/// Social Actions View Model
@Riverpod(keepAlive: true)
class SocialActionsViewModel extends _$SocialActionsViewModel {
  @override
  SocialState build(String currentUserId, String targetUserId) {
    _checkFollowStatus();
    return const SocialState();
  }

  Future<void> _checkFollowStatus() async {
    try {
      final repository = ref.read(profileRepositoryProvider);
      final currentUser = await repository.getUserById(currentUserId);
      final blockedUsers = switch (currentUser) {
        final RiderModel rider => rider.asRider?.blockedUsers ?? <String>[],
        final DriverModel driver => driver.asDriver?.blockedUsers ?? <String>[],
        _ => <String>[],
      };
      if (!ref.mounted) return;
      if (currentUser != null) {
        state = state.copyWith(
          isFollowing: false,
          isBlocked: blockedUsers.contains(targetUserId),
        );
      }
    } on Exception catch (e, st) {
      // PROF-8: log instead of silently swallowing so a failed block-status
      // load leaves a diagnostic trail rather than just defaulting to
      // isBlocked=false with no trace.
      TalkerService.error(
        'SocialActionsViewModel._checkFollowStatus failed for '
        'currentUserId=$currentUserId, targetUserId=$targetUserId',
        e,
        st,
      );
    }
  }

  Future<void> toggleBlock() async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);

      if (state.isBlocked) {
        await repository.unblockUser(currentUserId, targetUserId);
      } else {
        await repository.blockUser(currentUserId, targetUserId);
      }

      if (!ref.mounted) return;
      state = state.copyWith(
        isBlocked: !state.isBlocked,
        // When blocking, clear follow status; when unblocking, preserve it.
        isFollowing: state.isBlocked && state.isFollowing,
        isLoading: false,
      );
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }
}

class SocialState {
  const SocialState({
    this.isFollowing = false,
    this.isBlocked = false,
    this.isLoading = false,
    this.error,
  });
  final bool isFollowing;
  final bool isBlocked;
  final bool isLoading;
  final String? error;

  SocialState copyWith({
    bool? isFollowing,
    bool? isBlocked,
    bool? isLoading,
    String? error,
  }) {
    return SocialState(
      isFollowing: isFollowing ?? this.isFollowing,
      isBlocked: isBlocked ?? this.isBlocked,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Vehicle Management View Model
@riverpod
class VehicleViewModel extends _$VehicleViewModel {
  @override
  VehicleState build(String uid) {
    return const VehicleState();
  }

  Future<void> addVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.addVehicle(uid, vehicle);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateVehicle(uid, vehicle);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> removeVehicle(String vehicleId) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.removeVehicle(uid, vehicleId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }

  Future<void> setDefault(String vehicleId) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.setDefaultVehicle(uid, vehicleId);
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false);
    } on Exception catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: userFacingError(e));
    }
  }
}

class VehicleState {
  const VehicleState({this.isLoading = false, this.error});
  final bool isLoading;
  final String? error;

  VehicleState copyWith({bool? isLoading, String? error}) {
    return VehicleState(isLoading: isLoading ?? this.isLoading, error: error);
  }
}

/// Leaderboard Provider
@riverpod
Future<List<LeaderboardEntry>> leaderboard(Ref ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getLeaderboard();
}

/// User Rank Provider
@riverpod
Future<int> userRank(Ref ref, String uid) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.getUserRank(uid);
}
