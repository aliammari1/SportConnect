import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

part 'event_view_model.g.dart';

// ---------------------------------------------------------------------------
// Create-event form state
// ---------------------------------------------------------------------------

class CreateEventSubmissionResult {
  const CreateEventSubmissionResult({required this.event, this.warningMessage});

  final EventModel event;
  final String? warningMessage;
}

class CreateEventFormState {
  CreateEventFormState({
    this.title = '',
    this.description = '',
    this.type = EventType.running,
    DateTime? startsAt,
    this.endsAt,
    this.location,
    this.maxParticipants = 0,
    this.imageFile,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.costSplitEnabled = false,
    this.isSubmitting = false,
    this.isUploadingImage = false,
    this.hasAttemptedSubmit = false,
    this.error,
    this.warningMessage,
  }) : startsAt = startsAt ?? DateTime.now().add(const Duration(hours: 2));

  factory CreateEventFormState.initial() => CreateEventFormState(
    startsAt: DateTime.now().add(const Duration(hours: 2)),
  );

  final String title;
  final String description;
  final EventType type;
  final DateTime startsAt;
  final DateTime? endsAt;
  final LocationPoint? location;
  final int maxParticipants;
  final File? imageFile;
  final bool isRecurring;
  final RecurrencePattern? recurringPattern;
  final DateTime? recurringEndDate;
  final bool costSplitEnabled;
  final bool isSubmitting;
  final bool isUploadingImage;
  final bool hasAttemptedSubmit;
  final String? error;
  final String? warningMessage;

  CreateEventFormState copyWith({
    String? title,
    String? description,
    EventType? type,
    DateTime? startsAt,
    DateTime? endsAt,
    bool clearEndsAt = false,
    LocationPoint? location,
    bool clearLocation = false,
    int? maxParticipants,
    File? imageFile,
    bool clearImageFile = false,
    bool? isRecurring,
    RecurrencePattern? recurringPattern,
    bool clearRecurringPattern = false,
    DateTime? recurringEndDate,
    bool clearRecurringEndDate = false,
    bool? costSplitEnabled,
    bool? isSubmitting,
    bool? isUploadingImage,
    bool? hasAttemptedSubmit,
    String? error,
    bool clearError = false,
    String? warningMessage,
    bool clearWarningMessage = false,
  }) {
    return CreateEventFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      location: clearLocation ? null : (location ?? this.location),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageFile: clearImageFile ? null : (imageFile ?? this.imageFile),
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: clearRecurringPattern
          ? null
          : (recurringPattern ?? this.recurringPattern),
      recurringEndDate: clearRecurringEndDate
          ? null
          : (recurringEndDate ?? this.recurringEndDate),
      costSplitEnabled: costSplitEnabled ?? this.costSplitEnabled,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      error: clearError ? null : (error ?? this.error),
      warningMessage: clearWarningMessage
          ? null
          : (warningMessage ?? this.warningMessage),
    );
  }

  bool get isBusy => isSubmitting || isUploadingImage;

  /// Get applicable recurrence patterns based on duration between start and end dates
  List<RecurrencePattern> get applicablePatterns {
    if (!isRecurring) return RecurrencePattern.values;
    return _allowedPatternsForWindow(
      startsAt: startsAt,
      endsAt: endsAt,
      recurringEndDate: recurringEndDate,
    );
  }

  String? get titleError {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'Title is required';
    if (normalized.length < 3) {
      return 'Title must be at least 3 characters';
    }
    return null;
  }

  String? get locationError {
    if (location == null) return 'Please pick a location.';
    return null;
  }

  String? get startsAtError {
    if (!startsAt.isAfter(DateTime.now())) {
      return 'Start time must be in the future.';
    }
    return null;
  }

  String? get endsAtError {
    final end = endsAt;
    if (end != null && !end.isAfter(startsAt)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  String? get recurringError {
    if (!isRecurring) return null;
    if (recurringPattern == null) {
      return 'Select a recurrence pattern.';
    }
    final endDate = recurringEndDate;
    if (endDate != null && _dateOnly(endDate).isBefore(_dateOnly(startsAt))) {
      return 'Repeat end date must be on or after the start date.';
    }
    return null;
  }

  String? get submissionBlockReason {
    if (isBusy) return 'Please wait for the current submission to finish.';
    return titleError ??
        locationError ??
        startsAtError ??
        endsAtError ??
        recurringError;
  }

  bool get canSubmit => submissionBlockReason == null;

  String get participantLabel {
    if (maxParticipants == 0) return 'Unlimited';
    return '$maxParticipants spots';
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

List<RecurrencePattern> _allowedPatternsForWindow({
  required DateTime startsAt,
  DateTime? endsAt,
  DateTime? recurringEndDate,
}) {
  var patterns = RecurrencePattern.values;

  // 1) Do not offer patterns that would overlap with the same event occurrence.
  // Example: a 14-day event should not repeat daily or weekly.
  if (endsAt != null && endsAt.isAfter(startsAt)) {
    final occurrenceDuration = endsAt.difference(startsAt);
    patterns = patterns.where((pattern) {
      final recurrenceGap = pattern
          .nextOccurrenceFrom(startsAt)
          .difference(startsAt);
      return recurrenceGap >= occurrenceDuration;
    }).toList();
  }

  // 2) If repeat-until is set, keep only patterns that can occur within that
  // window at least once.
  if (recurringEndDate != null) {
    patterns = patterns.where((pattern) {
      final nextOccurrence = pattern.nextOccurrenceFrom(startsAt);
      return !nextOccurrence.isAfter(recurringEndDate);
    }).toList();
  }

  return patterns;
}

@riverpod
class CreateEventFormViewModel extends _$CreateEventFormViewModel {
  @override
  CreateEventFormState build() => CreateEventFormState.initial();

  void setTitle(String value) {
    state = state.copyWith(title: value, clearError: true);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value, clearError: true);
  }

  void setType(EventType type) {
    state = state.copyWith(type: type, clearError: true);
  }

  void setStartsAt(DateTime value) {
    final nextStartsAt = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    final currentEnd = state.endsAt;
    final nextEndsAt = currentEnd != null && !currentEnd.isAfter(nextStartsAt)
        ? nextStartsAt.add(const Duration(hours: 2))
        : currentEnd;
    final recurringEndDate = state.recurringEndDate;
    final normalizedRecurringEndDate =
        recurringEndDate != null &&
            _dateOnly(recurringEndDate).isBefore(_dateOnly(nextStartsAt))
        ? _dateOnly(nextStartsAt)
        : recurringEndDate;

    final nextAllowedPatterns = _allowedPatternsForWindow(
      startsAt: nextStartsAt,
      endsAt: nextEndsAt,
      recurringEndDate: normalizedRecurringEndDate,
    );
    final shouldClearPattern =
        state.recurringPattern != null &&
        !nextAllowedPatterns.contains(state.recurringPattern);

    state = state.copyWith(
      startsAt: nextStartsAt,
      endsAt: nextEndsAt,
      recurringEndDate: normalizedRecurringEndDate,
      clearRecurringPattern: shouldClearPattern,
      clearError: true,
    );
  }

  void setEndsAt(DateTime? value) {
    final nextAllowedPatterns = _allowedPatternsForWindow(
      startsAt: state.startsAt,
      endsAt: value,
      recurringEndDate: state.recurringEndDate,
    );
    final shouldClearPattern =
        state.recurringPattern != null &&
        !nextAllowedPatterns.contains(state.recurringPattern);

    state = state.copyWith(
      endsAt: value,
      clearEndsAt: value == null,
      clearRecurringPattern: shouldClearPattern,
      clearError: true,
    );
  }

  void setLocation(LocationPoint? value) {
    state = state.copyWith(
      location: value,
      clearLocation: value == null,
      clearError: true,
    );
  }

  void setMaxParticipants(int value) {
    state = state.copyWith(maxParticipants: value, clearError: true);
  }

  void setImageFile(File? file) {
    state = state.copyWith(
      imageFile: file,
      clearImageFile: file == null,
      clearError: true,
      clearWarningMessage: true,
    );
  }

  void setIsRecurring({required bool value}) {
    state = state.copyWith(
      isRecurring: value,
      clearRecurringPattern: !value,
      clearRecurringEndDate: !value,
      clearError: true,
    );
  }

  void setRecurringPattern(RecurrencePattern pattern) {
    state = state.copyWith(recurringPattern: pattern, clearError: true);
  }

  void setRecurringEndDate(DateTime? value) {
    final normalizedValue = value == null ? null : _dateOnly(value);
    final nextAllowedPatterns = _allowedPatternsForWindow(
      startsAt: state.startsAt,
      endsAt: state.endsAt,
      recurringEndDate: normalizedValue,
    );
    final shouldClearPattern =
        state.recurringPattern != null &&
        !nextAllowedPatterns.contains(state.recurringPattern);

    state = state.copyWith(
      recurringEndDate: normalizedValue,
      clearRecurringEndDate: normalizedValue == null,
      clearRecurringPattern: shouldClearPattern,
      clearError: true,
    );
  }

  void setCostSplitEnabled({required bool value}) {
    state = state.copyWith(costSplitEnabled: value, clearError: true);
  }

  void clearFeedback() {
    state = state.copyWith(clearError: true, clearWarningMessage: true);
  }

  Future<CreateEventSubmissionResult?> submit() async {
    if (state.isBusy) return null;

    state = state.copyWith(
      hasAttemptedSubmit: true,
      clearError: true,
      clearWarningMessage: true,
    );

    final authUser = ref.read(authStateProvider).value;
    if (authUser == null) {
      state = state.copyWith(error: 'Please sign in to create an event.');
      return null;
    }

    final validationError = state.submissionBlockReason;
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    final repo = ref.read(eventRepositoryProvider);
    final imageFile = state.imageFile;

    // Pre-generate the event ID so we can upload the cover image before
    // writing the Firestore document (fail-fast: if upload fails the event
    // is never created in a partial state).
    final eventId = repo.generateEventId();

    state = state.copyWith(isSubmitting: true);

    String? imageUrl;
    if (imageFile != null) {
      state = state.copyWith(isUploadingImage: true);
      try {
        imageUrl = await repo.uploadEventImage(eventId, imageFile);
        if (!ref.mounted) return null;
      } on Exception catch (e, st) {
        TalkerService.error('createEvent image upload failed', e, st);
        if (!ref.mounted) return null;
        state = state.copyWith(
          isSubmitting: false,
          isUploadingImage: false,
          error: 'Unable to upload cover image. Please try again.',
        );
        return null;
      } finally {
        if (ref.mounted) {
          state = state.copyWith(isUploadingImage: false);
        }
      }
    }

    final draft = EventModel(
      id: eventId,
      creatorId: authUser.uid,
      title: state.title.trim(),
      type: state.type,
      location: state.location!,
      startsAt: state.startsAt,
      endsAt: state.endsAt,
      description: state.description.trim().isEmpty
          ? null
          : state.description.trim(),
      organizerName: authUser.displayName,
      maxParticipants: state.maxParticipants,
      participantIds: [authUser.uid],
      isRecurring: state.isRecurring,
      recurringPattern: state.recurringPattern,
      recurringEndDate: state.recurringEndDate,
      costSplitEnabled: state.costSplitEnabled,
      imageUrl: imageUrl,
    );

    try {
      await repo.createEvent(draft);
      if (!ref.mounted) return null;

      state = state.copyWith(isSubmitting: false);
      return CreateEventSubmissionResult(event: draft);
    } on Exception catch (e, st) {
      TalkerService.error('createEvent submit failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        isUploadingImage: false,
        error: 'Unable to create event: $e',
      );
      return null;
    }
  }
}

class EditEventFormState {
  const EditEventFormState({
    this.title = '',
    this.description = '',
    this.type = EventType.running,
    this.startsAt,
    this.endsAt,
    this.location,
    this.maxParticipants = 0,
    this.imageFile,
    this.existingImageUrl,
    this.removeExistingImage = false,
    this.isRecurring = false,
    this.recurringPattern,
    this.recurringEndDate,
    this.costSplitEnabled = false,
    this.isLoading = false,
    this.isSubmitting = false,
    this.hasAttemptedSubmit = false,
    this.savedEvent,
    this.error,
  });

  const EditEventFormState.loading() : this(isLoading: true);

  factory EditEventFormState.fromEvent(EventModel event) => EditEventFormState(
    title: event.title,
    description: event.description ?? '',
    type: event.type,
    startsAt: event.startsAt,
    endsAt: event.endsAt,
    location: event.location,
    maxParticipants: event.maxParticipants,
    existingImageUrl: event.imageUrl,
    isRecurring: event.isRecurring,
    recurringPattern: event.recurringPattern,
    recurringEndDate: event.recurringEndDate,
    costSplitEnabled: event.costSplitEnabled,
  );

  final String title;
  final String description;
  final EventType type;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final LocationPoint? location;
  final int maxParticipants;
  final File? imageFile;
  final String? existingImageUrl;
  final bool removeExistingImage;
  final bool isRecurring;
  final RecurrencePattern? recurringPattern;
  final DateTime? recurringEndDate;
  final bool costSplitEnabled;
  final bool isLoading;
  final bool isSubmitting;
  final bool hasAttemptedSubmit;
  final EventModel? savedEvent;
  final String? error;

  static const _sentinel = Object();

  EditEventFormState copyWith({
    String? title,
    String? description,
    EventType? type,
    DateTime? startsAt,
    Object? endsAt = _sentinel,
    LocationPoint? location,
    bool clearLocation = false,
    int? maxParticipants,
    Object? imageFile = _sentinel,
    Object? existingImageUrl = _sentinel,
    bool? removeExistingImage,
    bool? isRecurring,
    RecurrencePattern? recurringPattern,
    bool clearRecurringPattern = false,
    Object? recurringEndDate = _sentinel,
    bool? costSplitEnabled,
    bool? isLoading,
    bool? isSubmitting,
    bool? hasAttemptedSubmit,
    Object? savedEvent = _sentinel,
    String? error,
    bool clearError = false,
  }) {
    return EditEventFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startsAt: startsAt ?? this.startsAt,
      endsAt: identical(endsAt, _sentinel) ? this.endsAt : endsAt as DateTime?,
      location: clearLocation ? null : (location ?? this.location),
      maxParticipants: maxParticipants ?? this.maxParticipants,
      imageFile: identical(imageFile, _sentinel)
          ? this.imageFile
          : imageFile as File?,
      existingImageUrl: identical(existingImageUrl, _sentinel)
          ? this.existingImageUrl
          : existingImageUrl as String?,
      removeExistingImage: removeExistingImage ?? this.removeExistingImage,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringPattern: clearRecurringPattern
          ? null
          : (recurringPattern ?? this.recurringPattern),
      recurringEndDate: identical(recurringEndDate, _sentinel)
          ? this.recurringEndDate
          : recurringEndDate as DateTime?,
      costSplitEnabled: costSplitEnabled ?? this.costSplitEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasAttemptedSubmit: hasAttemptedSubmit ?? this.hasAttemptedSubmit,
      savedEvent: identical(savedEvent, _sentinel)
          ? this.savedEvent
          : savedEvent as EventModel?,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get isLoaded => !isLoading && startsAt != null;

  bool get isSaved => savedEvent != null;

  bool get canSubmit => submissionBlockReason == null;

  bool get hasExistingImage =>
      !removeExistingImage && (existingImageUrl?.isNotEmpty ?? false);

  String? get visibleImageUrl => hasExistingImage ? existingImageUrl : null;

  List<RecurrencePattern> get applicablePatterns {
    if (!isRecurring) return RecurrencePattern.values;

    final start = startsAt;
    if (start == null) return RecurrencePattern.values;

    return _allowedPatternsForWindow(
      startsAt: start,
      endsAt: endsAt,
      recurringEndDate: recurringEndDate,
    );
  }

  String? get titleError {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'Title is required';
    if (normalized.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? get locationError {
    if (location == null) return 'Please select a location.';
    return null;
  }

  String? get startsAtError {
    if (startsAt == null) return 'Start time is required';
    return null;
  }

  String? get endsAtError {
    final start = startsAt;
    final end = endsAt;
    if (start != null && end != null && !end.isAfter(start)) {
      return 'End time must be after start time.';
    }
    return null;
  }

  String? get recurringError {
    if (!isRecurring) return null;
    if (recurringPattern == null) return 'Select a recurrence pattern.';

    final start = startsAt;
    final endDate = recurringEndDate;
    if (start != null &&
        endDate != null &&
        _dateOnly(endDate).isBefore(_dateOnly(start))) {
      return 'Repeat end date must be on or after the start date.';
    }
    return null;
  }

  String? get submissionBlockReason {
    if (isLoading) return 'Event is still loading.';
    if (isSubmitting) {
      return 'Please wait for the current submission to finish.';
    }
    return titleError ??
        locationError ??
        startsAtError ??
        endsAtError ??
        recurringError;
  }
}

@riverpod
class EditEventFormViewModel extends _$EditEventFormViewModel {
  late final String _eventId;
  EventModel? _loadedEvent;

  @override
  EditEventFormState build(String eventId) {
    _eventId = eventId;

    // Keep the fetch inside the watched provider instance. Calling this only
    // from the screen with ref.read(...) can start the fetch on an auto-disposed
    // instance, then leave the watched provider stuck in its initial loading
    // state.
    unawaited(Future<void>.microtask(_loadEvent));

    return const EditEventFormState.loading();
  }

  Future<void> reloadEvent() => _loadEvent(force: true);

  Future<void> _loadEvent({bool force = false}) async {
    if (!ref.mounted) return;
    if (!force && _loadedEvent?.id == _eventId && state.isLoaded) return;

    state = state.copyWith(
      isLoading: true,
      savedEvent: null,
      clearError: true,
    );

    try {
      final event = await ref
          .read(eventRepositoryProvider)
          .getEventById(_eventId);
      if (!ref.mounted) return;

      if (event == null) {
        state = const EditEventFormState(
          error: 'Unable to load event details. Please try again later.',
        );
        return;
      }

      _loadedEvent = event;
      state = EditEventFormState.fromEvent(event);
    } on Exception catch (e, st) {
      TalkerService.error('Failed to load event for editing', e, st);
      if (!ref.mounted) return;
      state = const EditEventFormState(
        error: 'Unable to load event details. Please try again later.',
      );
    }
  }

  void setTitle(String value) {
    state = state.copyWith(
      title: value,
      savedEvent: null,
      clearError: true,
    );
  }

  void setDescription(String value) {
    state = state.copyWith(
      description: value,
      savedEvent: null,
      clearError: true,
    );
  }

  void setType(EventType value) {
    state = state.copyWith(
      type: value,
      savedEvent: null,
      clearError: true,
    );
  }

  void setStartsAt(DateTime value) {
    final nextStart = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    final currentEnd = state.endsAt;
    final nextEnd = currentEnd != null && !currentEnd.isAfter(nextStart)
        ? nextStart.add(const Duration(hours: 2))
        : currentEnd;
    final recurringEnd = state.recurringEndDate;
    final nextRecurringEnd =
        recurringEnd != null &&
            _dateOnly(recurringEnd).isBefore(_dateOnly(nextStart))
        ? _dateOnly(nextStart)
        : recurringEnd;
    final allowedPatterns = _allowedPatternsForWindow(
      startsAt: nextStart,
      endsAt: nextEnd,
      recurringEndDate: nextRecurringEnd,
    );

    state = state.copyWith(
      startsAt: nextStart,
      endsAt: nextEnd,
      recurringEndDate: nextRecurringEnd,
      clearRecurringPattern:
          state.recurringPattern != null &&
          !allowedPatterns.contains(state.recurringPattern),
      savedEvent: null,
      clearError: true,
    );
  }

  void setEndsAt(DateTime? value) {
    final start = state.startsAt;
    final allowedPatterns = start == null
        ? RecurrencePattern.values
        : _allowedPatternsForWindow(
            startsAt: start,
            endsAt: value,
            recurringEndDate: state.recurringEndDate,
          );

    state = state.copyWith(
      endsAt: value,
      clearRecurringPattern:
          state.recurringPattern != null &&
          !allowedPatterns.contains(state.recurringPattern),
      savedEvent: null,
      clearError: true,
    );
  }

  void setLocation(LocationPoint value) {
    state = state.copyWith(
      location: value,
      savedEvent: null,
      clearError: true,
    );
  }

  void setMaxParticipants(int value) {
    state = state.copyWith(
      maxParticipants: value,
      savedEvent: null,
      clearError: true,
    );
  }

  void setImageFile(File? value) {
    state = state.copyWith(
      imageFile: value,
      removeExistingImage: false,
      savedEvent: null,
      clearError: true,
    );
  }

  void clearSelectedImage() {
    final isRemovingExistingImage =
        state.imageFile == null && state.hasExistingImage;

    state = state.copyWith(
      imageFile: null,
      existingImageUrl: isRemovingExistingImage ? null : state.existingImageUrl,
      removeExistingImage: isRemovingExistingImage || state.removeExistingImage,
      savedEvent: null,
      clearError: true,
    );
  }

  void setRecurring({required bool value}) {
    state = state.copyWith(
      isRecurring: value,
      clearRecurringPattern: !value,
      recurringEndDate: value ? state.recurringEndDate : null,
      savedEvent: null,
      clearError: true,
    );
  }

  void setRecurringPattern(RecurrencePattern pattern) {
    state = state.copyWith(
      recurringPattern: pattern,
      savedEvent: null,
      clearError: true,
    );
  }

  void setRecurringEndDate(DateTime? value) {
    final normalized = value == null ? null : _dateOnly(value);
    final start = state.startsAt;
    final allowedPatterns = start == null
        ? RecurrencePattern.values
        : _allowedPatternsForWindow(
            startsAt: start,
            endsAt: state.endsAt,
            recurringEndDate: normalized,
          );

    state = state.copyWith(
      recurringEndDate: normalized,
      clearRecurringPattern:
          state.recurringPattern != null &&
          !allowedPatterns.contains(state.recurringPattern),
      savedEvent: null,
      clearError: true,
    );
  }

  void setCostSplitEnabled({required bool value}) {
    state = state.copyWith(
      costSplitEnabled: value,
      savedEvent: null,
      clearError: true,
    );
  }

  Future<EventModel?> submit() async {
    final original = _loadedEvent;
    if (original == null) {
      state = state.copyWith(error: 'Unable to load the original event.');
      return null;
    }

    state = state.copyWith(
      hasAttemptedSubmit: true,
      savedEvent: null,
      clearError: true,
    );

    final validationError = state.submissionBlockReason;
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(eventRepositoryProvider);
      final imageFile = state.imageFile;
      final imageUrl = imageFile == null
          ? state.visibleImageUrl
          : await repo.uploadEventImage(_eventId, imageFile);

      if (!ref.mounted) return null;

      final updated = original.copyWith(
        title: state.title.trim(),
        type: state.type,
        location: state.location!,
        startsAt: state.startsAt!,
        endsAt: state.endsAt,
        description: state.description.trim().isEmpty
            ? null
            : state.description.trim(),
        imageUrl: imageUrl,
        maxParticipants: state.maxParticipants,
        isRecurring: state.isRecurring,
        recurringPattern: state.recurringPattern,
        recurringEndDate: state.recurringEndDate,
        costSplitEnabled: state.costSplitEnabled,
        updatedAt: DateTime.now(),
      );

      await repo.updateEvent(updated);
      if (!ref.mounted) return null;

      await _notifyParticipantsOfRelevantChanges(original, updated);
      if (!ref.mounted) return null;

      _loadedEvent = updated;
      state = EditEventFormState.fromEvent(updated).copyWith(
        savedEvent: updated,
      );
      return updated;
    } on Exception catch (e, st) {
      TalkerService.error('editEvent submit failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        error: 'Unable to update event. Please try again.',
      );
      return null;
    }
  }

  /// Notifies every joined participant (excluding the organizer) when an
  /// edit changes a participant-relevant field — date/time or location.
  /// Purely cosmetic edits (title wording, description, image, max
  /// participants, recurrence, cost-split toggle) intentionally do not
  /// trigger a notification. Failures are isolated per-recipient (mirroring
  /// [EventDetailViewModel.cancelEvent]'s fan-out) so one bad send can't
  /// surface as an "update failed" error after the event has already saved.
  Future<void> _notifyParticipantsOfRelevantChanges(
    EventModel original,
    EventModel updated,
  ) async {
    final changedLabels = <String>[
      if (original.startsAt != updated.startsAt ||
          original.endsAt != updated.endsAt)
        'date/time',
      if (original.location != updated.location) 'location',
    ];
    if (changedLabels.isEmpty) return;

    final otherParticipantIds = updated.participantIds
        .where((uid) => uid != updated.creatorId)
        .toList();
    if (otherParticipantIds.isEmpty) return;

    final organizer = ref.read(currentUserProvider).value;
    final notifRepo = ref.read(notificationRepositoryProvider);
    final changeSummary = changedLabels.join(' and ');

    await Future.wait([
      for (final uid in otherParticipantIds)
        notifRepo
            .sendEventUpdated(
              toUserId: uid,
              organizerName:
                  organizer?.username ?? updated.organizerName ?? 'Organizer',
              organizerPhoto: organizer?.photoUrl,
              eventId: updated.id,
              eventTitle: updated.title,
              changeSummary: changeSummary,
            )
            .catchError((Object e) {
              TalkerService.error(
                'Failed to send event-updated notification to $uid',
                e,
              );
            }),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Selection state (used inside event-picker sheets)
// ---------------------------------------------------------------------------

class EventSelectionState {
  const EventSelectionState({
    this.selectedEvent,
    this.filterType,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  final EventModel? selectedEvent;
  final EventType? filterType;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  EventSelectionState copyWith({
    EventModel? selectedEvent,
    bool clearSelectedEvent = false,
    EventType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return EventSelectionState(
      selectedEvent: clearSelectedEvent
          ? null
          : (selectedEvent ?? this.selectedEvent),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class EventSelectionViewModel extends _$EventSelectionViewModel {
  @override
  EventSelectionState build() => const EventSelectionState();

  /// Sets the currently selected event.
  void selectEvent(EventModel event) {
    state = state.copyWith(selectedEvent: event, clearError: true);
  }

  /// Clears the current selection.
  void clearSelection() {
    state = state.copyWith(clearSelectedEvent: true);
  }

  /// Sets or clears the sport-type filter chip.
  void setFilterType(EventType? type) {
    if (type == state.filterType || type == null) {
      state = state.copyWith(clearFilterType: true);
    } else {
      state = state.copyWith(filterType: type);
    }
  }

  /// Sets the search query for client-side filtering.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Creates a new event and auto-selects it on success.
  Future<EventModel?> createEvent({
    required String creatorId,
    required String title,
    required EventType type,
    required LocationPoint location,
    required DateTime startsAt,
    DateTime? endsAt,
    String? description,
    String? organizerName,
    int maxParticipants = 0,
    bool isRecurring = false,
    RecurrencePattern? recurringPattern,
    DateTime? recurringEndDate,
    bool costSplitEnabled = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final event = EventModel(
        id: '',
        creatorId: creatorId,
        title: title.trim(),
        type: type,
        location: location,
        startsAt: startsAt,
        endsAt: endsAt,
        description: description?.trim().isEmpty ?? true
            ? null
            : description!.trim(),
        organizerName: organizerName?.trim().isEmpty ?? true
            ? null
            : organizerName!.trim(),
        maxParticipants: maxParticipants,
        participantIds: [creatorId],
        isRecurring: isRecurring,
        recurringPattern: recurringPattern,
        recurringEndDate: recurringEndDate,
        costSplitEnabled: costSplitEnabled,
      );

      final eventId = await ref
          .read(eventRepositoryProvider)
          .createEvent(event);

      // Guard against provider disposal during the async gap
      if (!ref.mounted) return null;

      final created = event.copyWith(id: eventId);
      state = state.copyWith(isLoading: false, selectedEvent: created);
      return created;
    } on Exception catch (e, st) {
      TalkerService.error('createEvent failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to create event: $e',
      );
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Event detail view model — manages join/leave and single-event actions
// ---------------------------------------------------------------------------

class EventDetailState {
  const EventDetailState({
    this.isLoading = false,
    this.isJoining = false,
    this.isLeaving = false,
    this.isDeleting = false,
    this.error,
    this.successMessage,
  });

  final bool isLoading;
  final bool isJoining;
  final bool isLeaving;
  final bool isDeleting;
  final String? error;
  final String? successMessage;

  EventDetailState copyWith({
    bool? isLoading,
    bool? isJoining,
    bool? isLeaving,
    bool? isDeleting,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return EventDetailState(
      isLoading: isLoading ?? this.isLoading,
      isJoining: isJoining ?? this.isJoining,
      isLeaving: isLeaving ?? this.isLeaving,
      isDeleting: isDeleting ?? this.isDeleting,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

@riverpod
class EventDetailViewModel extends _$EventDetailViewModel {
  @override
  EventDetailState build(String eventId) => const EventDetailState();

  /// Joins the current user to the event.
  Future<bool> joinEvent(String userId) async {
    state = state.copyWith(
      isJoining: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(eventRepositoryProvider).joinEvent(eventId, userId);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isJoining: false,
        successMessage: 'You joined the event!',
      );

      return true;
    } on Exception catch (e, st) {
      TalkerService.error('joinEvent failed', e, st);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isJoining: false,
        error: 'Unable to join event: $e',
      );

      return false;
    }
  }

  /// Leaves the event.
  Future<bool> leaveEvent(String userId) async {
    state = state.copyWith(
      isLeaving: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).leaveEvent(eventId, userId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        successMessage: 'You left the event.',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('leaveEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLeaving: false,
        error: 'Unable to leave event. Please try again.',
      );
      return false;
    }
  }

  /// Ensures the event group chat exists and contains the requesting user.
  /// Premium entitlement is enforced server-side inside the repository
  /// transaction; no client-side cache check is performed here to avoid
  /// stale-state disagreements.
  Future<String?> ensureEventGroupChat(EventModel event, String userId) async {
    try {
      return await ref
          .read(eventRepositoryProvider)
          .ensureEventGroupChat(event: event, userId: userId);
    } on Exception catch (e, st) {
      TalkerService.error('ensureEventGroupChat failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Updates the event with new data.
  Future<bool> updateEvent(EventModel event) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(eventRepositoryProvider).updateEvent(event);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Event updated successfully.',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('updateEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to update event. Please try again.',
      );
      return false;
    }
  }

  /// Uploads a cover image and updates the event's imageUrl.
  Future<String?> uploadImage(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(eventRepositoryProvider);
      final url = await repo.uploadEventImage(eventId, file);
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false);
      return url;
    } on Exception catch (e, st) {
      TalkerService.error('uploadImage failed', e, st);
      if (!ref.mounted) return null;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to upload image. Please try again.',
      );
      return null;
    }
  }

  /// Removes the event. This is the single participant-facing "remove this
  /// event" action (there used to be a separate hard-"Delete" action too,
  /// but it left participants stranded with zero notification, so it was
  /// folded into this method — see the owner-actions widget in
  /// event_detail_screen.dart).
  ///
  /// * If anyone besides the organizer has joined, the event is
  ///   soft-cancelled (kept for history, hidden from active listings) and
  ///   every joined participant is notified via
  ///   [NotificationRepository.sendEventCancelled].
  /// * If nobody besides the organizer has joined, there is no one to
  ///   notify, so the event is hard-deleted instead of leaving an inactive
  ///   doc behind indefinitely.
  Future<bool> cancelEvent({String? reason}) async {
    state = state.copyWith(isDeleting: true, clearError: true);
    try {
      final event = await ref
          .read(eventRepositoryProvider)
          .getEventById(eventId);
      if (event == null) throw Exception('Event not found');
      if (!ref.mounted) return false;

      final otherParticipantIds = event.participantIds
          .where((uid) => uid != event.creatorId)
          .toList();

      if (otherParticipantIds.isEmpty) {
        await ref.read(eventRepositoryProvider).deleteEvent(eventId);
      } else {
        await ref.read(eventRepositoryProvider).cancelEvent(eventId);
        if (!ref.mounted) return false;

        // Notify every joined participant (fire-and-forget; don't let
        // failures block cancel). Dispatch concurrently so fan-out latency
        // does not grow linearly with attendee count; each send is isolated
        // so one failure does not abort the rest.
        final organizer = ref.read(currentUserProvider).value;
        final notifRepo = ref.read(notificationRepositoryProvider);
        await Future.wait([
          for (final uid in otherParticipantIds)
            notifRepo
                .sendEventCancelled(
                  toUserId: uid,
                  organizerName: organizer?.username ??
                      event.organizerName ??
                      'Organizer',
                  organizerPhoto: organizer?.photoUrl,
                  eventId: eventId,
                  eventTitle: event.title,
                  reason: reason,
                )
                .catchError((Object e) {
                  TalkerService.error(
                    'Failed to send cancellation notification to $uid',
                    e,
                  );
                }),
        ]);
      }

      if (!ref.mounted) return false;
      state = state.copyWith(
        isDeleting: false,
        successMessage: 'Event cancelled.',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('cancelEvent failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isDeleting: false,
        error: 'Unable to cancel event. Please try again.',
      );
      return false;
    }
  }

  /// Clears any error or success message.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  // ── Event-Ride Integration methods ──

  /// Sets the ride status for a participant (#24 RSVP with Ride Status).
  Future<bool> setRideStatus(String userId, String status) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref
          .read(eventRepositoryProvider)
          .setRideStatus(eventId, userId, status);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Ride status updated!',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('setRideStatus failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to update ride status.',
      );
      return false;
    }
  }

  /// Sets the post-event meetup pin location (#30).
  Future<bool> setMeetupPin(LocationPoint location) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref.read(eventRepositoryProvider).setMeetupPin(eventId, location);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Meetup point set!',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('setMeetupPin failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to set meetup point.',
      );
      return false;
    }
  }

  /// Sets the chat group ID for this event (#29).
  Future<bool> setChatGroup(String chatGroupId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await ref
          .read(eventRepositoryProvider)
          .setChatGroupId(eventId, chatGroupId);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Event chat created!',
      );
      return true;
    } on Exception catch (e, st) {
      TalkerService.error('setChatGroup failed', e, st);
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to create event chat.',
      );
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Event list view model — browse / discover screen
// ---------------------------------------------------------------------------

/// UI state for the event list (discover) screen.
class EventListState {
  const EventListState({
    this.allEvents = const [],
    this.filteredEvents = const [],
    this.filterType,
    this.searchQuery = '',
    this.searchFieldKey = 0,
    this.isLoading = false,
    this.error,
    this.radiusKm,
    this.userLatitude,
    this.userLongitude,
    this.isLoadingLocation = false,
  });

  final List<EventModel> allEvents;
  final List<EventModel> filteredEvents;
  final EventType? filterType;
  final String searchQuery;
  final int searchFieldKey;
  final bool isLoading;
  final String? error;

  /// Active radius filter in km — null means "everywhere".
  final double? radiusKm;
  final double? userLatitude;
  final double? userLongitude;
  final bool isLoadingLocation;

  bool get hasLocationFilter =>
      radiusKm != null && userLatitude != null && userLongitude != null;

  EventListState copyWith({
    List<EventModel>? allEvents,
    List<EventModel>? filteredEvents,
    EventType? filterType,
    bool clearFilterType = false,
    String? searchQuery,
    int? searchFieldKey,
    bool? isLoading,
    String? error,
    bool clearError = false,
    double? radiusKm,
    bool clearRadius = false,
    double? userLatitude,
    double? userLongitude,
    bool? isLoadingLocation,
  }) {
    return EventListState(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchQuery: searchQuery ?? this.searchQuery,
      searchFieldKey: searchFieldKey ?? this.searchFieldKey,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
      userLatitude: clearRadius ? null : (userLatitude ?? this.userLatitude),
      userLongitude: clearRadius ? null : (userLongitude ?? this.userLongitude),
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    );
  }
}

/// ViewModel for the event list screen.
///
/// Watches the upcoming events stream and applies client-side filtering
/// by type and search query.  Views should watch only this provider.
@riverpod
class EventListViewModel extends _$EventListViewModel {
  // Persisted across stream rebuilds via instance variables (not frozen state).
  EventType? _filterType;
  String _searchQuery = '';
  int _searchFieldKey = 0;
  double? _radiusKm;
  double? _userLat;
  double? _userLng;

  @override
  EventListState build() {
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);
    final all = eventsAsync.value ?? const [];
    return EventListState(
      allEvents: all,
      filteredEvents: _applyFilters(all),
      filterType: _filterType,
      searchQuery: _searchQuery,
      searchFieldKey: _searchFieldKey,
      isLoading: eventsAsync.isLoading,
      error: eventsAsync.error?.toString(),
      radiusKm: _radiusKm,
      userLatitude: _userLat,
      userLongitude: _userLng,
    );
  }

  /// Toggles or clears the sport-type filter.
  void setFilterType(EventType? type) {
    _filterType = type;
    state = _withFiltersApplied();
  }

  /// Updates the search query for client-side text search.
  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    state = _withFiltersApplied();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchFieldKey += 1;
    state = _withFiltersApplied();
  }

  /// Sets (or clears) the location radius filter.
  /// Provide [lat]/[lng] from the device location service.
  void setRadiusFilter({double? radiusKm, double? lat, double? lng}) {
    _radiusKm = radiusKm;
    _userLat = lat;
    _userLng = lng;
    state = _withFiltersApplied();
  }

  /// Fetches device location and applies radius filter — call from view.
  Future<void> applyRadiusFilterWithLocation(double radiusKm) async {
    try {
      final position = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      if (!ref.mounted) return;
      if (position != null) {
        setRadiusFilter(
          radiusKm: radiusKm,
          lat: position.latitude,
          lng: position.longitude,
        );
      } else {
        clearRadiusFilter();
      }
    } on Exception catch (e) {
      TalkerService.error('Failed to get location for radius filter', e);
      if (!ref.mounted) return;
      clearRadiusFilter();
    }
  }

  void clearRadiusFilter() {
    _radiusKm = null;
    _userLat = null;
    _userLng = null;
    state = state.copyWith(
      filteredEvents: _applyFilters(state.allEvents),
      clearRadius: true,
    );
  }

  // ── Private ──

  EventListState _withFiltersApplied() {
    return state.copyWith(
      filteredEvents: _applyFilters(state.allEvents),
      filterType: _filterType,
      clearFilterType: _filterType == null,
      searchQuery: _searchQuery,
      searchFieldKey: _searchFieldKey,
      radiusKm: _radiusKm,
      clearRadius: _radiusKm == null,
      userLatitude: _userLat,
      userLongitude: _userLng,
    );
  }

  List<EventModel> _applyFilters(List<EventModel> events) {
    var filtered = events.where((e) => e.isActive).toList();
    if (_filterType != null) {
      filtered = filtered.where((e) => e.type == _filterType).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) =>
                e.title.toLowerCase().contains(_searchQuery) ||
                e.location.address.toLowerCase().contains(_searchQuery) ||
                (e.organizerName?.toLowerCase().contains(_searchQuery) ??
                    false),
          )
          .toList();
    }
    if (_radiusKm != null && _userLat != null && _userLng != null) {
      filtered = filtered.where((e) {
        final dist = _haversineKm(
          _userLat!,
          _userLng!,
          e.location.latitude,
          e.location.longitude,
        );
        return dist <= _radiusKm!;
      }).toList();
    }
    return filtered;
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

// ---------------------------------------------------------------------------
// Stream providers
// ---------------------------------------------------------------------------

@riverpod
Stream<List<EventModel>> upcomingEventsStream(Ref ref) {
  return ref.watch(eventRepositoryProvider).streamUpcomingEvents();
}

@riverpod
Stream<List<EventModel>> eventsByTypeStream(Ref ref, EventType type) {
  return ref.watch(eventRepositoryProvider).streamEventsByType(type);
}

@riverpod
Stream<List<EventModel>> eventsByCreatorStream(Ref ref, String creatorId) {
  return ref.watch(eventRepositoryProvider).streamEventsByCreator(creatorId);
}

@riverpod
Stream<List<EventModel>> joinedEventsStream(Ref ref, String userId) {
  return ref.watch(eventRepositoryProvider).streamJoinedEvents(userId);
}

@riverpod
Stream<EventModel?> eventById(Ref ref, String eventId) {
  return ref.watch(eventRepositoryProvider).streamEventById(eventId);
}

/// Streams rides linked to a specific event by querying rides with matching eventId.
@riverpod
Stream<List<RideModel>> eventLinkedRides(Ref ref, String eventId) {
  return ref.watch(rideRepositoryProvider).streamRidesByEventId(eventId);
}
