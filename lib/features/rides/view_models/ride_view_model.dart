import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/deep_link_service.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/utils/geo/geo.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';
import 'package:sport_connect/features/messaging/models/message_model.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';
import 'package:sport_connect/features/notifications/repositories/notification_repository.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_capacity.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_preferences.dart';
import 'package:sport_connect/features/rides/models/ride/ride_pricing.dart';
import 'package:sport_connect/features/rides/models/ride/ride_route.dart';
import 'package:sport_connect/features/rides/models/ride/ride_schedule.dart';
import 'package:sport_connect/features/rides/models/ride_search_filters.dart';
import 'package:sport_connect/features/rides/repositories/booking_repository.dart'
    show BookingRepository, bookingRepositoryProvider;
import 'package:sport_connect/features/rides/repositories/dispute_repository.dart'
    show DisputeRepository, disputeRepositoryProvider;
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/rides/services/ride_service.dart';
import 'package:uuid/uuid.dart';

part 'ride_view_model.g.dart';

/// State for ride creation/editing
class RideFormState {
  const RideFormState({
    this.origin,
    this.destination,
    this.departureTime,
    this.availableSeats = 3,
    this.pricePerSeatInCents = 0.0,
    this.isLoading = false,
    this.error,
  });
  final LocationPoint? origin;
  final LocationPoint? destination;
  final DateTime? departureTime;
  final int availableSeats;
  final double pricePerSeatInCents;
  final bool isLoading;
  final String? error;

  RideFormState copyWith({
    LocationPoint? origin,
    LocationPoint? destination,
    DateTime? departureTime,
    int? availableSeats,
    double? pricePerSeatInCents,
    bool? isLoading,
    String? error,
  }) {
    return RideFormState(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureTime: departureTime ?? this.departureTime,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeatInCents: pricePerSeatInCents ?? this.pricePerSeatInCents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isValid => origin != null && destination != null && departureTime != null;
}

class RideDetailUiState {
  const RideDetailUiState({
    this.selectedSeats = 1,
    this.isBooking = false,
    this.isReminderEnabled = true,
    this.pickupLocation,
    this.routeInfo,
    this.isLoadingRoute = false,
  });

  final int selectedSeats;
  final bool isBooking;
  final bool isReminderEnabled;
  final LocationPoint? pickupLocation;
  final RouteInfo? routeInfo;
  final bool isLoadingRoute;

  RideDetailUiState copyWith({
    int? selectedSeats,
    bool? isBooking,
    bool? isReminderEnabled,
    LocationPoint? pickupLocation,
    bool clearPickupLocation = false,
    RouteInfo? routeInfo,
    bool clearRouteInfo = false,
    bool? isLoadingRoute,
  }) {
    return RideDetailUiState(
      selectedSeats: selectedSeats ?? this.selectedSeats,
      isBooking: isBooking ?? this.isBooking,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      pickupLocation: clearPickupLocation ? null : (pickupLocation ?? this.pickupLocation),
      routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
    );
  }
}

@riverpod
class RideDetailUiViewModel extends _$RideDetailUiViewModel {
  @override
  RideDetailUiState build(String rideId) => const RideDetailUiState();

  Future<RouteInfo?> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingRoute || state.routeInfo != null) {
      return state.routeInfo;
    }

    state = state.copyWith(isLoadingRoute: true);

    try {
      final fromCoords = LatLng(ride.origin.latitude, ride.origin.longitude);
      final toCoords = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );

      final waypoints = ride.route.waypoints
          .map((wp) => LatLng(wp.location.latitude, wp.location.longitude))
          .toList();

      final route = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: fromCoords,
            destination: toCoords,
            waypoints: waypoints.isNotEmpty ? waypoints : null,
          );

      if (!ref.mounted) return null;
      state = state.copyWith(routeInfo: route, isLoadingRoute: false);
      return route;
    } catch (_) {
      if (!ref.mounted) return null;
      state = state.copyWith(isLoadingRoute: false);
      return null;
    }
  }

  void setSelectedSeats(int seats) {
    if (seats < 1) return;
    state = state.copyWith(selectedSeats: seats);
  }

  void setBooking(bool value) {
    state = state.copyWith(isBooking: value);
  }

  void setReminderEnabled(bool value) {
    state = state.copyWith(isReminderEnabled: value);
  }

  void setPickupLocation(LocationPoint location) {
    state = state.copyWith(pickupLocation: location);
  }

  void clearPickupLocation() {
    state = state.copyWith(clearPickupLocation: true);
  }

  Future<String> generateRideShareLink(RideModel ride) {
    return ref
        .read(deepLinkServiceProvider)
        .generateRideLink(
          rideId: ride.id,
          fromCity: ride.origin.city ?? ride.origin.address,
          toCity: ride.destination.city ?? ride.destination.address,
          priceInCents: ride.pricePerSeatInCents,
          seats: ride.remainingSeats,
          departureTime: ride.departureTime,
        );
  }
}

/// Delegates ride operations through the [RideService] for validated
/// business logic. Falls back to the repository only for operations
/// that don't require additional validation (start, complete, stream).
// keepAlive: action-only VM - accessed from notification/background contexts.
@Riverpod(keepAlive: true)
class RideActionsViewModel extends _$RideActionsViewModel {
  @override
  void build() {
    return;
  }

  Future<String> createRide(RideModel ride) {
    return ref.read(rideServiceProvider.notifier).createRide(ride);
  }

  Future<void> cancelRide(String rideId, String reason) {
    return ref.read(rideServiceProvider.notifier).cancelRide(rideId, reason);
  }

  Future<void> startRide(String rideId) {
    return ref.read(rideRepositoryProvider).startRide(rideId);
  }

  Future<void> completeRide(String rideId) {
    // Route through RideService so XP reward + driver stats are recorded
    return ref.read(rideServiceProvider.notifier).completeRide(rideId);
  }

  Future<void> updateBookingStatus({
    required String rideId,
    required String bookingId,
    required BookingStatus newStatus,
  }) {
    return ref
        .read(rideRepositoryProvider)
        .updateBookingStatus(
          rideId: rideId,
          bookingId: bookingId,
          newStatus: newStatus,
        );
  }

  Future<void> bookRide({
    required String rideId,
    required RideBooking booking,
  }) {
    return ref.read(rideRepositoryProvider).bookRide(rideId: rideId, booking: booking);
  }

  Future<void> cancelBooking({
    required String rideId,
    required String bookingId,
  }) {
    return ref.read(rideRepositoryProvider).cancelBooking(rideId: rideId, bookingId: bookingId);
  }

  Stream<RideModel?> streamRideById(String rideId) {
    return ref.read(rideRepositoryProvider).streamRideById(rideId);
  }

  /// Fetches a one-shot list of all bookings for a ride (driver-side).
  ///
  /// Used by screens that need to look up a specific booking ID before
  /// performing a follow-up action (e.g. rating, cancellation).
  Future<List<RideBooking>> getBookingsByRideId(
    String rideId,
    String driverId,
  ) {
    return ref.read(bookingRepositoryProvider).getBookingsByRideId(rideId, driverId);
  }

  /// Returns the current passenger's booking for a ride, or null.
  Future<RideBooking?> getPassengerBookingForRide(
    String rideId,
    String passengerId,
  ) {
    return ref.read(bookingRepositoryProvider).getPassengerBookingForRide(rideId, passengerId);
  }

  /// One-shot fetch of a single ride by ID.
  ///
  /// Used for deep-link / route-based prefill scenarios where we only
  /// need the current snapshot, not a live stream.
  Future<RideModel?> getRideById(String rideId) {
    return ref.read(rideRepositoryProvider).getRideById(rideId);
  }

  /// Pushes the driver's GPS coordinates to Firestore.
  ///
  /// A missed location ping must not interrupt navigation flow; failure
  /// handling is delegated to the underlying repository/service layer.
  Future<void> updateLiveLocation(
    String rideId,
    double latitude,
    double longitude, {
    double heading = 0,
  }) {
    return ref
        .read(rideRepositoryProvider)
        .updateLiveLocation(rideId, latitude, longitude, heading: heading);
  }

  // ==================== Section 7 delegates ====================

  Future<void> markPassengerNoShow({
    required String rideId,
    required String bookingId,
    required String passengerId,
  }) {
    return ref
        .read(rideServiceProvider.notifier)
        .markPassengerNoShow(
          rideId: rideId,
          bookingId: bookingId,
          passengerId: passengerId,
        );
  }

  Future<String> createReturnRide(String originalRideId) {
    return ref.read(rideRepositoryProvider).createReturnRide(originalRideId);
  }

  Future<void> updatePickupOrder(String rideId, List<String> passengerIds) {
    return ref.read(rideRepositoryProvider).updatePickupOrder(rideId, passengerIds);
  }

  Future<void> recordActualDistance(String rideId, double distanceKm) {
    return ref.read(rideRepositoryProvider).recordActualDistance(rideId, distanceKm);
  }
}

class CancellationReasonState {
  const CancellationReasonState({
    this.selectedReason,
    this.commentText = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.validationMessage,
    this.errorMessage,
    this.wasInProgress = false,
  });
  static const _unset = Object();

  final String? selectedReason;
  final String commentText;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? validationMessage;
  final String? errorMessage;

  /// Whether the ride had already started (status == inProgress) at the
  /// moment cancellation was submitted — determines which refund message the
  /// screen should show, since the real Cloud Function rule
  /// (onBookingCancelled / onRideCancelled) is a simple un-tiered "full
  /// refund pre-ride, no refund mid-ride" rule.
  final bool wasInProgress;

  CancellationReasonState copyWith({
    Object? selectedReason = _unset,
    String? commentText,
    bool? isSubmitting,
    bool? isSubmitted,
    String? validationMessage,
    String? errorMessage,
    bool clearValidation = false,
    bool clearError = false,
    bool? wasInProgress,
  }) {
    return CancellationReasonState(
      selectedReason: selectedReason == _unset ? this.selectedReason : selectedReason as String?,
      commentText: commentText ?? this.commentText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      validationMessage: clearValidation ? null : (validationMessage ?? this.validationMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      wasInProgress: wasInProgress ?? this.wasInProgress,
    );
  }
}

@riverpod
class CancellationReasonViewModel extends _$CancellationReasonViewModel {
  late final String _rideId;

  @override
  CancellationReasonState build(String rideId) {
    _rideId = rideId;
    return const CancellationReasonState();
  }

  void selectReason(String reason) {
    state = state.copyWith(
      selectedReason: reason,
      clearValidation: true,
      clearError: true,
    );
  }

  void updateComment(String comment) {
    state = state.copyWith(commentText: comment, clearError: true);
  }

  Future<void> submit() async {
    if (state.isSubmitting) {
      return;
    }

    final selectedReason = state.selectedReason;
    if (selectedReason == null || selectedReason.isEmpty) {
      state = state.copyWith(
        validationMessage: 'Please select a cancellation reason',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      isSubmitted: false,
      clearValidation: true,
      clearError: true,
    );

    try {
      final comment = state.commentText.trim();
      final reason = comment.isNotEmpty ? '$selectedReason | $comment' : selectedReason;

      // Capture whether the ride had already started BEFORE cancelling it, so
      // the confirmation message can accurately reflect the refund rule that
      // actually applied instead of always implying a refund is coming.
      final rideBeforeCancel = ref.read(rideStreamProvider(_rideId)).value;
      final wasInProgress = rideBeforeCancel?.status == RideStatus.inProgress;

      await ref.read(rideActionsViewModelProvider.notifier).cancelRide(_rideId, reason);
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
        wasInProgress: wasInProgress,
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to cancel ride. Please try again.',
      );
    }
  }
}

class DisputeFormState {
  const DisputeFormState({
    this.selectedDisputeType,
    this.description = '',
    this.attachedFiles = const [],
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.typeError,
    this.descriptionError,
    this.errorMessage,
  });
  static const _unset = Object();

  final String? selectedDisputeType;
  final String description;
  final List<File> attachedFiles;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? typeError;
  final String? descriptionError;
  final String? errorMessage;

  DisputeFormState copyWith({
    Object? selectedDisputeType = _unset,
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
    return DisputeFormState(
      selectedDisputeType: selectedDisputeType == _unset
          ? this.selectedDisputeType
          : selectedDisputeType as String?,
      description: description ?? this.description,
      attachedFiles: attachedFiles ?? this.attachedFiles,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      typeError: clearTypeError ? null : (typeError ?? this.typeError),
      descriptionError: clearDescriptionError ? null : (descriptionError ?? this.descriptionError),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class DisputeFormViewModel extends _$DisputeFormViewModel {
  static const int maxAttachments = 5;
  static const int maxFileSizeBytes = 10 * 1024 * 1024;
  static const int minDescriptionLength = 20;

  late final String _rideId;

  @override
  DisputeFormState build(String rideId) {
    _rideId = rideId;
    return const DisputeFormState();
  }

  void selectType(String disputeType) {
    state = state.copyWith(
      selectedDisputeType: disputeType,
      clearTypeError: true,
      clearError: true,
    );
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
    final typeError = state.selectedDisputeType == null ? 'Please select a dispute type' : null;
    final description = state.description.trim();
    final descriptionError = description.isEmpty
        ? 'Please describe your issue'
        : (description.length < minDescriptionLength
              ? 'Please provide more detail (at least $minDescriptionLength characters)'
              : null);

    state = state.copyWith(
      typeError: typeError,
      descriptionError: descriptionError,
      clearError: true,
    );

    return typeError == null && descriptionError == null;
  }

  Future<void> submit({
    required String userId,
    required String userEmail,
    String? rideSummary,
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
          .read(disputeViewModelProvider.notifier)
          .submitDispute(
            rideId: _rideId,
            userId: userId,
            userEmail: userEmail,
            disputeType: state.selectedDisputeType!,
            description: state.description.trim(),
            rideSummary: rideSummary,
            attachments: state.attachedFiles,
          );
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, isSubmitted: true);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit dispute. Please try again.',
      );
    }
  }
}

/// Streams the driver's live GPS location for a ride.
@riverpod
Stream<({double latitude, double longitude})?> driverLiveLocation(
  Ref ref,
  String rideId,
) async* {
  final userId = ref.watch(currentAuthUidProvider).value;
  final ride = ref.watch(rideStreamProvider(rideId)).value;
  if (userId == null || ride == null) {
    yield null;
    return;
  }

  final rideHasActiveTracking =
      ride.status == RideStatus.active || ride.status == RideStatus.inProgress;
  if (!rideHasActiveTracking) {
    yield null;
    return;
  }

  if (ride.driverId == userId) {
    yield* ref.watch(rideRepositoryProvider).streamLiveLocation(rideId);
    return;
  }

  final bookings = ref.watch(bookingsByPassengerProvider(userId)).value;
  final hasPaidSeat =
      bookings?.any((booking) {
        if (booking.rideId != rideId) return false;
        final hasPayment =
            (booking.paymentIntentId?.trim().isNotEmpty ?? false) || booking.paidAt != null;
        return hasPayment && booking.status != BookingStatus.cancelled;
      }) ??
      false;

  if (!hasPaidSeat) {
    yield null;
    return;
  }

  yield* ref.watch(rideRepositoryProvider).streamLiveLocation(rideId);
}

@riverpod
Stream<String?> ridePhaseStream(Ref ref, String rideId) {
  return ref.watch(rideRepositoryProvider).streamRidePhase(rideId);
}

/// Ride Form View Model
@riverpod
class RideFormViewModel extends _$RideFormViewModel {
  @override
  RideFormState build() => const RideFormState();

  void setOrigin(LocationPoint origin) {
    state = state.copyWith(origin: origin);
  }

  void setDestination(LocationPoint destination) {
    state = state.copyWith(destination: destination);
  }

  void setDepartureTime(DateTime time) {
    state = state.copyWith(departureTime: time);
  }

  void setSeats(int seats) {
    state = state.copyWith(availableSeats: seats);
  }

  void setPrice(double price) {
    state = state.copyWith(pricePerSeatInCents: price);
  }

  Future<String?> createRide({
    required String driverId,
    required LocationPoint origin,
    required LocationPoint destination,
    required DateTime departureTime,
    required int availableSeats,
    required int pricePerSeatInCents,
    String currency = 'EUR',
  }) async {
    if (!state.isValid) {
      state = state.copyWith(error: 'Please fill all required fields');
      return null;
    }

    state = state.copyWith(isLoading: true);

    try {
      final ride = RideModel(
        id: '',
        driverId: driverId,
        route: RideRoute(origin: origin, destination: destination),
        schedule: RideSchedule(departureTime: departureTime),
        capacity: RideCapacity(available: availableSeats),
        pricing: RidePricing(
          pricePerSeatInCents: pricePerSeatInCents,
        ),
        preferences: const RidePreferences(),
        status: RideStatus.active,
      );

      // Route through RideService so validation rules are applied consistently
      final rideId = await ref.read(rideServiceProvider.notifier).createRide(ride);
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false);
      return rideId;
    } catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<String?> submitRideModel(RideModel ride) async {
    state = state.copyWith(isLoading: true);

    try {
      final rideId = await ref.read(rideServiceProvider.notifier).createRide(ride);

      if (!ref.mounted) return rideId;
      state = state.copyWith(isLoading: false);
      return rideId;
    } catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const RideFormState();
  }
}

/// Search state - includes both committed filters and draft UI state
enum RideSearchResultViewMode { list, map }

/// Semantic search-input failures; the UI owns the localized copy.
enum RideSearchInputError { missingLocations, sameLocation, pastDate, invalidSeats }

class RideSearchState {
  RideSearchState({
    this.rides = const [],
    this.allSearchResults = const [],
    this.isLoading = false,
    this.error,
    this.filters = const RideSearchFilters(),
    this.hasMore = true,
    this.draftOrigin,
    this.draftDestination,
    DateTime? draftDate,
    this.draftSeats = 1,
    this.selectedDateChip = 0,
    this.hasSearched = false,
    this.draftMaxPrice = 100,
    this.draftFemaleOnly = false,
    this.draftPetFriendly = false,
    this.draftNoSmoking = false,
    this.draftLuggageRequired = false,
    this.draftMinRating = 0,
    this.draftSortBy = 'recommended',
    this.isFilterPanelOpen = false,
    this.resultViewMode = RideSearchResultViewMode.list,
    this.visibleResultCount = 20,
    this.lastCompletedQueryKey,
    this.pendingQueryKey,
  }) : draftDate = draftDate ?? DateTime.now();
  static const _unset = Object();

  final List<RideModel> rides;
  final List<RideModel> allSearchResults;
  final bool isLoading;
  final String? error;
  final RideSearchFilters filters;
  final bool hasMore;

  // Draft search/filter state (not yet committed to search)
  final LocationPoint? draftOrigin;
  final LocationPoint? draftDestination;
  final DateTime draftDate;
  final int draftSeats;
  final int selectedDateChip; // 0=Today, 1=Tomorrow, 2=Custom
  final bool hasSearched;

  // Draft filter state
  final int draftMaxPrice;
  final bool draftFemaleOnly;
  final bool draftPetFriendly;
  final bool draftNoSmoking;
  final bool draftLuggageRequired;
  final double draftMinRating;
  final String draftSortBy;
  final bool isFilterPanelOpen;
  final RideSearchResultViewMode resultViewMode;
  final int visibleResultCount;
  final String? lastCompletedQueryKey;
  final String? pendingQueryKey;

  RideSearchState copyWith({
    List<RideModel>? rides,
    List<RideModel>? allSearchResults,
    bool? isLoading,
    Object? error = _unset,
    RideSearchFilters? filters,
    bool? hasMore,
    Object? draftOrigin = _unset,
    Object? draftDestination = _unset,
    DateTime? draftDate,
    int? draftSeats,
    int? selectedDateChip,
    bool? hasSearched,
    int? draftMaxPrice,
    bool? draftFemaleOnly,
    bool? draftPetFriendly,
    bool? draftNoSmoking,
    bool? draftLuggageRequired,
    double? draftMinRating,
    String? draftSortBy,
    bool? isFilterPanelOpen,
    RideSearchResultViewMode? resultViewMode,
    int? visibleResultCount,
    Object? lastCompletedQueryKey = _unset,
    Object? pendingQueryKey = _unset,
  }) {
    return RideSearchState(
      rides: rides ?? this.rides,
      allSearchResults: allSearchResults ?? this.allSearchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error == _unset ? this.error : error as String?,
      filters: filters ?? this.filters,
      hasMore: hasMore ?? this.hasMore,
      draftOrigin: draftOrigin == _unset ? this.draftOrigin : draftOrigin as LocationPoint?,
      draftDestination: draftDestination == _unset
          ? this.draftDestination
          : draftDestination as LocationPoint?,
      draftDate: draftDate ?? this.draftDate,
      draftSeats: draftSeats ?? this.draftSeats,
      selectedDateChip: selectedDateChip ?? this.selectedDateChip,
      hasSearched: hasSearched ?? this.hasSearched,
      draftMaxPrice: draftMaxPrice ?? this.draftMaxPrice,
      draftFemaleOnly: draftFemaleOnly ?? this.draftFemaleOnly,
      draftPetFriendly: draftPetFriendly ?? this.draftPetFriendly,
      draftNoSmoking: draftNoSmoking ?? this.draftNoSmoking,
      draftLuggageRequired: draftLuggageRequired ?? this.draftLuggageRequired,
      draftMinRating: draftMinRating ?? this.draftMinRating,
      draftSortBy: draftSortBy ?? this.draftSortBy,
      isFilterPanelOpen: isFilterPanelOpen ?? this.isFilterPanelOpen,
      resultViewMode: resultViewMode ?? this.resultViewMode,
      visibleResultCount: visibleResultCount ?? this.visibleResultCount,
      lastCompletedQueryKey: lastCompletedQueryKey == _unset
          ? this.lastCompletedQueryKey
          : lastCompletedQueryKey as String?,
      pendingQueryKey: pendingQueryKey == _unset
          ? this.pendingQueryKey
          : pendingQueryKey as String?,
    );
  }

  bool get hasActiveFilters =>
      draftFemaleOnly ||
      draftPetFriendly ||
      draftNoSmoking ||
      draftLuggageRequired ||
      draftMaxPrice < 100 ||
      draftMinRating > 0;

  int get activeFilterCount {
    var count = 0;
    if (draftMaxPrice < 100) count++;
    if (draftFemaleOnly) count++;
    if (draftPetFriendly) count++;
    if (draftNoSmoking) count++;
    if (draftLuggageRequired) count++;
    if (draftMinRating > 0) count++;
    return count;
  }
}

class RideSearchResultsData {
  const RideSearchResultsData({
    this.allResults = const [],
    this.visibleResults = const [],
    this.totalCount = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.error,
    this.hasSearched = false,
    this.viewMode = RideSearchResultViewMode.list,
  });

  final List<RideModel> allResults;
  final List<RideModel> visibleResults;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final bool hasSearched;
  final RideSearchResultViewMode viewMode;
}

@riverpod
RideSearchResultsData rideSearchResults(Ref ref) {
  // 1. Watch the search state (the primary dependency)
  final searchState = ref.watch(rideSearchViewModelProvider);

  // Helper to keep the logic DRY - in 3.0, we keep this inside the function
  // or as a private top-level function if preferred.
  RideSearchResultsData createData({
    required List<RideModel> source,
    required bool hasSearched,
    bool isLoading = false,
    String? error,
  }) {
    final filtered = _applyRideSearchPresentation(source, searchState);
    final visible = filtered.take(searchState.visibleResultCount).toList();

    return RideSearchResultsData(
      allResults: filtered,
      visibleResults: visible,
      totalCount: filtered.length,
      hasMore: visible.length < filtered.length,
      isLoading: isLoading,
      error: error,
      hasSearched: hasSearched,
      viewMode: searchState.resultViewMode,
    );
  }

  // 2. Logic Branching
  if (searchState.hasSearched) {
    return createData(
      source: searchState.allSearchResults,
      isLoading: searchState.isLoading,
      error: searchState.error,
      hasSearched: true,
    );
  }

  // 3. Conditional watching
  // Riverpod 3.0 handles conditional watches perfectly.
  // activeRidesProvider is only watched if hasSearched is false.
  final activeRidesAsync = ref.watch(activeRidesProvider);

  return activeRidesAsync.maybeWhen(
    data: (rides) => createData(
      source: rides,
      hasSearched: false,
    ),
    error: (err, _) => createData(
      source: const [],
      error: err.toString(),
      hasSearched: false,
    ),
    // Fallback covers loading and any unhandled states
    orElse: () => createData(
      source: const [],
      isLoading: activeRidesAsync.isLoading,
      hasSearched: false,
    ),
  );
}

List<RideModel> _applyRideSearchPresentation(
  List<RideModel> rides,
  RideSearchState state,
) {
  final filtered = rides.where((ride) {
    // Only apply date filter when user has performed an explicit search.
    // Pre-search discovery should show rides on all upcoming dates.
    if (state.hasSearched && !_isSameCalendarDay(ride.departureTime, state.draftDate)) {
      return false;
    }
    if (ride.remainingSeats < state.draftSeats) {
      return false;
    }
    if (state.draftMaxPrice < 100 && ride.pricePerSeatInCents > state.draftMaxPrice * 100) {
      return false;
    }
    if (state.draftFemaleOnly && !ride.isWomenOnly) {
      return false;
    }
    if (state.draftPetFriendly && !ride.allowPets) {
      return false;
    }
    // "No Smoking" filter: exclude rides that allow smoking
    if (state.draftNoSmoking && ride.allowSmoking) {
      return false;
    }
    if (state.draftLuggageRequired && !ride.allowLuggage) {
      return false;
    }
    if (state.draftMinRating > 0 && ride.averageRating < state.draftMinRating) {
      return false;
    }
    return true;
  }).toList();

  switch (state.draftSortBy) {
    case 'price_low':
      filtered.sort(
        (a, b) => a.pricePerSeatInCents.compareTo(b.pricePerSeatInCents),
      );
    case 'price_high':
      filtered.sort(
        (a, b) => b.pricePerSeatInCents.compareTo(a.pricePerSeatInCents),
      );
    case 'rating':
      filtered.sort((a, b) => b.averageRating.compareTo(a.averageRating));
    case 'duration':
      filtered.sort(
        (a, b) => (a.durationMinutes ?? 1 << 20).compareTo(
          b.durationMinutes ?? 1 << 20,
        ),
      );
    case 'departure':
      filtered.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    default:
      final now = DateTime.now();
      filtered.sort((a, b) {
        final scoreA = (a.remainingSeats * 10) + (100 - a.departureTime.difference(now).inMinutes);
        final scoreB = (b.remainingSeats * 10) + (100 - b.departureTime.difference(now).inMinutes);
        return scoreB.compareTo(scoreA);
      });
  }

  return filtered;
}

bool _isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Ride Search View Model
///
/// Uses client-side batching: the Firestore geo query returns all matches
/// (up to 100) since cursor pagination isn't possible with latitude
/// inequality filters. Results are stored in [_allResults] and surfaced
/// in pages of [_pageSize] via [loadMore].
@riverpod
class RideSearchViewModel extends _$RideSearchViewModel {
  static const _pageSize = 20;
  int _latestSearchRequestId = 0;

  @override
  RideSearchState build() => RideSearchState();

  // --- Draft state setters ---

  void setDraftOrigin(LocationPoint? origin) {
    state = state.copyWith(
      draftOrigin: origin,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void setDraftDestination(LocationPoint? destination) {
    state = state.copyWith(
      draftDestination: destination,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void swapLocations() {
    state = state.copyWith(
      draftOrigin: state.draftDestination,
      draftDestination: state.draftOrigin,
      visibleResultCount: _pageSize,
      error: null,
    );
  }

  void setDraftDate(DateTime date) {
    state = state.copyWith(draftDate: date, visibleResultCount: _pageSize);
  }

  void setDraftSeats(int seats) {
    if (seats < 1 || seats > 4) return;
    state = state.copyWith(draftSeats: seats, visibleResultCount: _pageSize);
  }

  void setSelectedDateChip(int chip) {
    state = state.copyWith(selectedDateChip: chip);
  }

  void setDraftMaxPrice(int price) {
    state = state.copyWith(
      draftMaxPrice: price.clamp(5, 100),
      visibleResultCount: _pageSize,
    );
  }

  void setDraftFemaleOnly(bool value) {
    state = state.copyWith(
      draftFemaleOnly: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftPetFriendly(bool value) {
    state = state.copyWith(
      draftPetFriendly: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftNoSmoking(bool value) {
    state = state.copyWith(
      draftNoSmoking: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftLuggageRequired(bool value) {
    state = state.copyWith(
      draftLuggageRequired: value,
      visibleResultCount: _pageSize,
    );
  }

  void setDraftMinRating(double rating) {
    state = state.copyWith(
      draftMinRating: rating.clamp(0, 5).toDouble(),
      visibleResultCount: _pageSize,
    );
  }

  void setDraftSortBy(String sortBy) {
    const supportedSorts = {
      'recommended',
      'price_low',
      'price_high',
      'rating',
      'departure',
      'duration',
    };
    state = state.copyWith(
      draftSortBy: supportedSorts.contains(sortBy) ? sortBy : 'recommended',
      visibleResultCount: _pageSize,
    );
  }

  void resetFilters() {
    state = state.copyWith(
      draftMaxPrice: 100,
      draftFemaleOnly: false,
      draftPetFriendly: false,
      draftNoSmoking: false,
      draftLuggageRequired: false,
      draftMinRating: 0,
      draftSortBy: 'recommended',
      visibleResultCount: _pageSize,
    );
  }

  void setFilterPanelOpen(bool isOpen) {
    state = state.copyWith(isFilterPanelOpen: isOpen);
  }

  void setResultViewMode(RideSearchResultViewMode viewMode) {
    state = state.copyWith(resultViewMode: viewMode);
  }

  void resetPagination() {
    state = state.copyWith(visibleResultCount: _pageSize);
  }

  /// Initialize draft state with an initial destination (e.g., from event detail).
  void setInitialDestination(Map<String, dynamic> destination) {
    final address = destination['destinationAddress'] as String?;
    final lat = destination['destinationLat'] as double?;
    final lng = destination['destinationLng'] as double?;
    if (address != null && lat != null && lng != null) {
      state = state.copyWith(
        draftDestination: LocationPoint(
          address: address,
          latitude: lat,
          longitude: lng,
        ),
        visibleResultCount: _pageSize,
      );
    }
  }

  void updateFilters(RideSearchFilters filters) {
    state = state.copyWith(filters: filters, visibleResultCount: _pageSize);
  }

  /// Validates and executes a search with current draft state.
  /// Returns error message if validation fails, null on success.
  Future<RideSearchInputError?> searchRides({bool forceRefresh = false}) async {
    // Validation: origin and destination required
    if (state.draftOrigin == null || state.draftDestination == null) {
      return RideSearchInputError.missingLocations;
    }

    // Validation: prevent same origin and destination
    if (state.draftOrigin!.latitude == state.draftDestination!.latitude &&
        state.draftOrigin!.longitude == state.draftDestination!.longitude) {
      return RideSearchInputError.sameLocation;
    }

    // Validation: date must not be in the past
    final now = DateTime.now();
    if (state.draftDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return RideSearchInputError.pastDate;
    }

    // Validation: seats must be valid
    if (state.draftSeats < 1 || state.draftSeats > 4) {
      return RideSearchInputError.invalidSeats;
    }

    final queryKey = _buildDraftQueryKey(state);
    if (state.pendingQueryKey == queryKey) {
      return null;
    }
    if (!forceRefresh && state.hasSearched && state.lastCompletedQueryKey == queryKey) {
      return null;
    }

    final requestId = ++_latestSearchRequestId;

    state = state.copyWith(
      isLoading: true,
      error: null,
      pendingQueryKey: queryKey,
      visibleResultCount: _pageSize,
    );

    // Build committed filters from draft state
    final filters = RideSearchFilters(
      origin: state.draftOrigin,
      destination: state.draftDestination,
      departureDate: state.draftDate,
      minSeats: state.draftSeats,
      maxPrice: state.draftMaxPrice < 100 ? state.draftMaxPrice * 100 : null,
      womenOnly: state.draftFemaleOnly,
      allowPets: state.draftPetFriendly,
      allowSmoking: state.draftNoSmoking,
      minDriverRating: state.draftMinRating > 0 ? state.draftMinRating : null,
      sortBy: state.draftSortBy == 'recommended' ? 'departure_time' : state.draftSortBy,
    );

    // Capture repository before awaiting
    final repository = ref.read(rideRepositoryProvider);

    try {
      var rides = await repository.searchRides(
        originLat: filters.origin!.latitude,
        originLng: filters.origin!.longitude,
        destLat: filters.destination!.latitude,
        destLng: filters.destination!.longitude,
        date: filters.departureDate ?? DateTime.now(),
        minSeats: filters.minSeats,
        maxPriceInCents: filters.maxPrice,
      );

      // Post-filter by preferences not supported in Firestore query
      if (filters.womenOnly) {
        rides = rides.where((r) => r.preferences.isWomenOnly).toList();
      }
      if (filters.allowPets) {
        rides = rides.where((r) => r.preferences.allowPets).toList();
      }
      // allowSmoking in filters means "user wants no smoking"
      if (filters.allowSmoking) {
        rides = rides.where((r) => !r.preferences.allowSmoking).toList();
      }
      if (state.draftLuggageRequired) {
        rides = rides.where((r) => r.preferences.allowLuggage).toList();
      }
      if (filters.minDriverRating != null) {
        rides = rides.where((r) => r.averageRating >= filters.minDriverRating!).toList();
      }

      // If provider was disposed while awaiting, bail out safely
      if (!ref.mounted || requestId != _latestSearchRequestId) return null;

      // Store full result set, surface first page
      final firstPage = rides.take(_pageSize).toList();

      state = state.copyWith(
        rides: firstPage,
        allSearchResults: rides,
        isLoading: false,
        error: null,
        filters: filters,
        hasSearched: true,
        hasMore: rides.length > _pageSize,
        visibleResultCount: _pageSize,
        lastCompletedQueryKey: queryKey,
        pendingQueryKey: null,
      );

      return null; // Success
    } catch (e, st) {
      if (!ref.mounted || requestId != _latestSearchRequestId) return null;
      TalkerService.error('Ride search failed', e, st);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        pendingQueryKey: null,
      );
      // Runtime failures surface through state.error (the results list shows
      // a retryable error view); null means "no input validation problem".
      return null;
    }
  }

  void clearResults() {
    state = state.copyWith(
      rides: const [],
      allSearchResults: const [],
      hasMore: true,
      visibleResultCount: _pageSize,
      lastCompletedQueryKey: null,
      pendingQueryKey: null,
      error: null,
    );
  }

  /// Reveals the next page of results from the cached [_allResults].
  void loadMore() {
    if (!state.hasMore || state.isLoading) return;

    final nextVisibleCount = state.visibleResultCount + _pageSize;
    final visibleRides = state.allSearchResults.take(nextVisibleCount).toList();
    final allShown = visibleRides.length >= state.allSearchResults.length;

    state = state.copyWith(
      rides: visibleRides,
      hasMore: !allShown,
      visibleResultCount: nextVisibleCount,
    );
  }
}

String _buildDraftQueryKey(RideSearchState state) {
  final origin = state.draftOrigin;
  final destination = state.draftDestination;
  final date = DateTime(
    state.draftDate.year,
    state.draftDate.month,
    state.draftDate.day,
  );

  return [
    origin?.latitude.toStringAsFixed(6) ?? '',
    origin?.longitude.toStringAsFixed(6) ?? '',
    destination?.latitude.toStringAsFixed(6) ?? '',
    destination?.longitude.toStringAsFixed(6) ?? '',
    date.toIso8601String(),
    state.draftSeats,
    state.draftMaxPrice.toStringAsFixed(2),
    state.draftFemaleOnly,
    state.draftPetFriendly,
    state.draftNoSmoking,
    state.draftLuggageRequired,
    state.draftMinRating.toStringAsFixed(1),
    state.draftSortBy,
  ].join('|');
}

// ---------------------------------------------------------------------------
// Ride Detail State — aggregates ride stream + bookings stream
// ---------------------------------------------------------------------------

/// Immutable UI state for any screen that shows a single ride with bookings.
class RideDetailState {
  const RideDetailState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
    this.isActing = false,
    this.actionError,
  });

  /// Real-time ride data from Firestore.
  final AsyncValue<RideModel?> ride;

  /// Live bookings for this ride (from the separate bookings sub-collection).
  final List<RideBooking> bookings;

  /// Whether a ride-detail action is currently in flight.
  final bool isActing;

  /// Error from the last action (book, accept, reject, cancel, etc.).
  final String? actionError;

  // Sentinel to distinguish "not passed" from "explicitly null".
  static const _unset = Object();

  RideDetailState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
    bool? isActing,
    Object? actionError = _unset,
  }) => RideDetailState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
    isActing: isActing ?? this.isActing,
    actionError: actionError == _unset ? this.actionError : actionError as String?,
  );
}

/// Single Ride Detail View Model — views watch only this, never separate
/// stream/booking providers directly.
@riverpod
class RideDetailViewModel extends _$RideDetailViewModel {
  @override
  RideDetailState build(String rideId) {
    final rideAsync = ref.watch(rideStreamProvider(rideId));
    final bookings = ref.watch(bookingsByRideProvider(rideId)).value ?? const <RideBooking>[];
    return RideDetailState(ride: rideAsync, bookings: bookings);
  }

  Future<bool> bookRide({
    required String passengerId,
    int seats = 1,
    String? note,

    /// Optional passenger pickup location — stored on the booking and later
    /// added to the ride's route as a waypoint when the driver accepts.
    LocationPoint? pickupLocation,
  }) async {
    final ride = state.ride.value;
    if (ride == null) return false;

    try {
      state = state.copyWith(isActing: true, actionError: null);
      final booking = RideBooking(
        id: const Uuid().v4(),
        rideId: ride.id,
        passengerId: passengerId,
        driverId: ride.driverId,
        seatsBooked: seats,
        note: note,
        pickupLocation: pickupLocation,
        createdAt: DateTime.now(),
      );
      await ref.read(rideRepositoryProvider).bookRide(rideId: ride.id, booking: booking);
      if (!ref.mounted) return false;
      state = state.copyWith(actionError: null);

      // Notify the driver that a new booking request has arrived.
      // Fire-and-forget: a notification failure must never break the booking.
      try {
        final passenger = ref.read(currentUserProvider).value;
        if (passenger != null) {
          final notificationRepo = ref.read(notificationRepositoryProvider);
          final origin = ride.origin.city ?? ride.origin.address;
          final dest = ride.destination.city ?? ride.destination.address;
          await notificationRepo.sendRideBookingRequest(
            toUserId: ride.driverId,
            fromUserId: passengerId,
            fromUserName: passenger.username,
            fromUserPhoto: passenger.photoUrl,
            rideId: ride.id,
            rideName: '$origin → $dest',
          );
        }
      } catch (e, st) {
        TalkerService.error('Failed to send booking notification', e, st);
        // Notification failure is non-fatal
      }

      // NOTE: The passenger is auto-joined to the linked event on booking
      // ACCEPTANCE (see acceptBooking), not on request. Joining on request left
      // a passenger as an event member for a ride that was later rejected or
      // cancelled, with no reconciliation. The event<->ride membership now
      // tracks the accepted booking state instead.

      // Award small XP to passenger for booking a ride
      if (!ref.mounted) return true;
      try {
        final profileRepo = ref.read(profileRepositoryProvider);
        await profileRepo.addXP(passengerId, 5);
      } catch (e, st) {
        TalkerService.error('Failed to award XP for booking', e, st);
        // XP failure is non-fatal
      }

      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e, st) {
      if (!ref.mounted) return false;
      TalkerService.error('Failed to book ride', e, st);
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      // 1. Mark booking as accepted.
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: bookingId,
            newStatus: BookingStatus.accepted,
          );
      if (!ref.mounted) return false;

      // 2. Send the passenger notification. Seat reservation, OTP generation,
      // and pickup waypoint insertion are handled atomically in the repository.
      final idx = state.bookings.indexWhere((b) => b.id == bookingId);
      if (idx >= 0) {
        final booking = state.bookings[idx];

        try {
          final notificationRepo = ref.read(notificationRepositoryProvider);
          final driver = ref.read(currentUserProvider).value;
          final origin = ride.origin.city ?? ride.origin.address;
          final dest = ride.destination.city ?? ride.destination.address;
          await notificationRepo.sendRideBookingAccepted(
            toUserId: booking.passengerId,
            driverName: driver?.username ?? 'Driver',
            driverPhoto: driver?.photoUrl,
            rideId: ride.id,
            rideName: '$origin → $dest',
          );
        } catch (_) {
          // Notification failure is non-fatal.
        }

        // 3. Auto-join the linked event now that the booking is ACCEPTED.
        // Gating the join on acceptance (rather than on request) ensures the
        // passenger only becomes an event member for a ride they were actually
        // accepted on; rejected/cancelled requests never create event
        // membership. Non-fatal: acceptance still succeeds on failure.
        if (!ref.mounted) return true;
        if (ride.eventId != null && ride.eventId!.isNotEmpty) {
          try {
            await ref.read(eventRepositoryProvider).joinEvent(ride.eventId!, booking.passengerId);
          } catch (e, st) {
            TalkerService.error('Failed to auto-join event on accept', e, st);
          }
        }

        // 4. Award XP to passenger for confirmed booking
        if (!ref.mounted) return true;
        try {
          final profileRepo = ref.read(profileRepositoryProvider);
          await profileRepo.addXP(booking.passengerId, 10);
        } catch (_) {
          // XP failure is non-fatal
        }
      }

      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> rejectBooking(String bookingId) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    // Capture the booking before its status changes so we can reconcile event
    // membership for the affected passenger afterwards.
    final rejectedBooking = state.bookings.where((b) => b.id == bookingId).firstOrNull;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref
          .read(rideRepositoryProvider)
          .updateBookingStatus(
            rideId: ride.id,
            bookingId: bookingId,
            newStatus: BookingStatus.rejected,
          );

      if (!ref.mounted) return true;

      // Reconcile event membership: a rejected booking should not leave the
      // passenger joined to the linked event. Leave only when they have no
      // other active (pending/accepted) booking for the same event — see
      // _leaveEventIfNoOtherBooking.
      if (rejectedBooking != null && ride.eventId != null && ride.eventId!.isNotEmpty) {
        await _leaveEventIfNoOtherBooking(
          eventId: ride.eventId!,
          passengerId: rejectedBooking.passengerId,
          excludeBookingId: bookingId,
        );
      }

      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  /// Removes the passenger from the linked event unless they still hold another
  /// active (pending or accepted) booking on a ride tied to the same event.
  ///
  /// Best-effort: a failure here must never break the reject/cancel flow.
  Future<void> _leaveEventIfNoOtherBooking({
    required String eventId,
    required String passengerId,
    required String excludeBookingId,
  }) async {
    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final rideRepo = ref.read(rideRepositoryProvider);

      final passengerBookings = await bookingRepo.getBookingsByPassengerId(
        passengerId,
      );
      if (!ref.mounted) return;

      for (final other in passengerBookings) {
        if (other.id == excludeBookingId) continue;
        if (other.status != BookingStatus.pending && other.status != BookingStatus.accepted) {
          continue;
        }
        final otherRide = await rideRepo.getRideById(other.rideId);
        if (otherRide?.eventId == eventId) {
          // Another active booking ties the passenger to this event — keep
          // their membership.
          return;
        }
        if (!ref.mounted) return;
      }

      await ref.read(eventRepositoryProvider).leaveEvent(eventId, passengerId);
    } catch (e, st) {
      TalkerService.error('Failed to reconcile event membership', e, st);
    }
  }

  Future<bool> startRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideRepositoryProvider).startRide(ride.id);
      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> completeRide() async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> cancelRide({String reason = 'Cancelled by user'}) async {
    final ride = state.ride.value;
    if (ride == null) return false;
    try {
      state = state.copyWith(isActing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).cancelRide(ride.id, reason);
      if (!ref.mounted) return true;
      state = state.copyWith(isActing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isActing: false, actionError: e.toString());
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Active Ride State — for driver / passenger active-ride screens
// ---------------------------------------------------------------------------

enum ActiveRidePhase { pickingUp, enRoute, arriving, completed }

enum ActiveRideLocationInitResult {
  ready,
  permissionRequired,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  error,
}

/// Immutable state for active-ride screens that need live ride + bookings.
class ActiveRideState {
  const ActiveRideState({
    this.ride = const AsyncValue.loading(),
    this.bookings = const [],
    this.phase = ActiveRidePhase.pickingUp,
    this.driverLiveLocation,
    this.currentLocation,
    this.isLoadingLocation = true,
    this.hasInitializedLocation = false,
    this.locationServicesEnabled = true,
    this.locationPermissionGranted = false,
    this.locationPermissionDeniedForever = false,
    this.locationError,
    this.userHeading = 0,
    this.currentSpeedKmh = 0,
    this.isNavigationExpanded = true,
    this.showPassengerDetails = false,
    this.isProcessing = false,
    this.pickedUpPassengerIds = const <String>{},
    this.nearbyPOIs = const <PointOfInterest>[],
    this.showPOIMarkers = false,
    this.osrmRoutePoints,
    this.remainingRoutePoints,
    this.loadedRouteKey,
    this.loadingRouteKey,
    this.isLoadingOsrmRoute = false,
    this.remainingDistanceKm,
    this.remainingEtaMinutes,
    this.isOffRoute = false,
    this.routeDeviationMeters = 0,
    this.passedWaypointIndices = const <int>{},
    this.waypointEtaMinutes = const <int, int>{},
    this.hasSkippedReview = false,
    this.hasAutoNavigatedToCompletion = false,
    this.actionError,
    // 7A: Pickup order
    this.pickupOrder = const <String>[],
    // 7B: No-show tracking
    this.noShowPassengerIds = const <String>{},
    // 7D: Quick messages
    this.latestQuickMessage,
    // 7F: Fare tracking
    this.actualDistanceKm = 0,
    // 7G: Ride timeout
    this.rideTimeoutMinutes,
    this.hasShownTimeoutWarning = false,
    // 7I: Connectivity
    this.isConnected = true,
    this.pendingLocationWrites = 0,
    // 7J: Delay
    this.rideDelayMinutes = 0,
    this.hasNotifiedDelay = false,
    // E4: Last driver location update time (for unavailable banner)
    this.lastDriverLocationUpdate,
    // Proximity detection one-shot flags
    this.pickupProximityFired = false,
    this.destinationProximityFired = false,
  });
  static const _unset = Object();

  final AsyncValue<RideModel?> ride;
  final List<RideBooking> bookings;
  final ActiveRidePhase phase;
  final ({double latitude, double longitude})? driverLiveLocation;
  final LatLng? currentLocation;
  final bool isLoadingLocation;
  final bool hasInitializedLocation;
  final bool locationServicesEnabled;
  final bool locationPermissionGranted;
  final bool locationPermissionDeniedForever;
  final String? locationError;
  final double userHeading;
  final double currentSpeedKmh;
  final bool isNavigationExpanded;
  final bool showPassengerDetails;
  final bool isProcessing;
  final Set<String> pickedUpPassengerIds;
  final List<PointOfInterest> nearbyPOIs;
  final bool showPOIMarkers;
  final List<LatLng>? osrmRoutePoints;
  final List<LatLng>? remainingRoutePoints;
  final String? loadedRouteKey;
  final String? loadingRouteKey;
  final bool isLoadingOsrmRoute;
  final double? remainingDistanceKm;
  final int? remainingEtaMinutes;
  final bool isOffRoute;
  final double routeDeviationMeters;
  final Set<int> passedWaypointIndices;
  final Map<int, int> waypointEtaMinutes;
  final bool hasSkippedReview;
  final bool hasAutoNavigatedToCompletion;
  final String? actionError;
  // 7A: Ordered pickup list (passenger IDs in pickup sequence)
  final List<String> pickupOrder;
  // 7B: Passengers marked as no-show
  final Set<String> noShowPassengerIds;
  // 7D: Latest quick message received during ride
  final String? latestQuickMessage;
  // 7F: Actual distance driven (cumulative GPS odometer)
  final double actualDistanceKm;
  // 7G: Minutes past estimated duration (null = not timed out)
  final int? rideTimeoutMinutes;
  final bool hasShownTimeoutWarning;
  // 7I: Network connectivity status
  final bool isConnected;
  final int pendingLocationWrites;
  // 7J: Detected departure delay
  final int rideDelayMinutes;
  final bool hasNotifiedDelay;
  // E4: Last driver location update time (for unavailable banner)
  final DateTime? lastDriverLocationUpdate;
  final bool pickupProximityFired;
  final bool destinationProximityFired;

  RideModel? get currentRide => ride.value;

  ActiveRideState copyWith({
    AsyncValue<RideModel?>? ride,
    List<RideBooking>? bookings,
    ActiveRidePhase? phase,
    Object? driverLiveLocation = _unset,
    Object? currentLocation = _unset,
    bool? isLoadingLocation,
    bool? hasInitializedLocation,
    bool? locationServicesEnabled,
    bool? locationPermissionGranted,
    bool? locationPermissionDeniedForever,
    Object? locationError = _unset,
    double? userHeading,
    double? currentSpeedKmh,
    bool? isNavigationExpanded,
    bool? showPassengerDetails,
    bool? isProcessing,
    Set<String>? pickedUpPassengerIds,
    List<PointOfInterest>? nearbyPOIs,
    bool? showPOIMarkers,
    Object? osrmRoutePoints = _unset,
    Object? remainingRoutePoints = _unset,
    Object? loadedRouteKey = _unset,
    Object? loadingRouteKey = _unset,
    bool? isLoadingOsrmRoute,
    Object? remainingDistanceKm = _unset,
    Object? remainingEtaMinutes = _unset,
    bool? isOffRoute,
    double? routeDeviationMeters,
    Set<int>? passedWaypointIndices,
    Map<int, int>? waypointEtaMinutes,
    bool? hasSkippedReview,
    bool? hasAutoNavigatedToCompletion,
    Object? actionError = _unset,
    List<String>? pickupOrder,
    Set<String>? noShowPassengerIds,
    Object? latestQuickMessage = _unset,
    double? actualDistanceKm,
    Object? rideTimeoutMinutes = _unset,
    bool? hasShownTimeoutWarning,
    bool? isConnected,
    int? pendingLocationWrites,
    int? rideDelayMinutes,
    bool? hasNotifiedDelay,
    Object? lastDriverLocationUpdate = _unset,
    bool? pickupProximityFired,
    bool? destinationProximityFired,
  }) => ActiveRideState(
    ride: ride ?? this.ride,
    bookings: bookings ?? this.bookings,
    phase: phase ?? this.phase,
    driverLiveLocation: driverLiveLocation == _unset
        ? this.driverLiveLocation
        : driverLiveLocation as ({double latitude, double longitude})?,
    currentLocation: currentLocation == _unset ? this.currentLocation : currentLocation as LatLng?,
    isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    hasInitializedLocation: hasInitializedLocation ?? this.hasInitializedLocation,
    locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
    locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
    locationPermissionDeniedForever:
        locationPermissionDeniedForever ?? this.locationPermissionDeniedForever,
    locationError: locationError == _unset ? this.locationError : locationError as String?,
    userHeading: userHeading ?? this.userHeading,
    currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
    isNavigationExpanded: isNavigationExpanded ?? this.isNavigationExpanded,
    showPassengerDetails: showPassengerDetails ?? this.showPassengerDetails,
    isProcessing: isProcessing ?? this.isProcessing,
    pickedUpPassengerIds: pickedUpPassengerIds ?? this.pickedUpPassengerIds,
    nearbyPOIs: nearbyPOIs ?? this.nearbyPOIs,
    showPOIMarkers: showPOIMarkers ?? this.showPOIMarkers,
    osrmRoutePoints: osrmRoutePoints == _unset
        ? this.osrmRoutePoints
        : osrmRoutePoints as List<LatLng>?,
    remainingRoutePoints: remainingRoutePoints == _unset
        ? this.remainingRoutePoints
        : remainingRoutePoints as List<LatLng>?,
    loadedRouteKey: loadedRouteKey == _unset ? this.loadedRouteKey : loadedRouteKey as String?,
    loadingRouteKey: loadingRouteKey == _unset ? this.loadingRouteKey : loadingRouteKey as String?,
    isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
    remainingDistanceKm: remainingDistanceKm == _unset
        ? this.remainingDistanceKm
        : remainingDistanceKm as double?,
    remainingEtaMinutes: remainingEtaMinutes == _unset
        ? this.remainingEtaMinutes
        : remainingEtaMinutes as int?,
    isOffRoute: isOffRoute ?? this.isOffRoute,
    routeDeviationMeters: routeDeviationMeters ?? this.routeDeviationMeters,
    passedWaypointIndices: passedWaypointIndices ?? this.passedWaypointIndices,
    waypointEtaMinutes: waypointEtaMinutes ?? this.waypointEtaMinutes,
    hasSkippedReview: hasSkippedReview ?? this.hasSkippedReview,
    hasAutoNavigatedToCompletion: hasAutoNavigatedToCompletion ?? this.hasAutoNavigatedToCompletion,
    actionError: actionError == _unset ? this.actionError : actionError as String?,
    pickupOrder: pickupOrder ?? this.pickupOrder,
    noShowPassengerIds: noShowPassengerIds ?? this.noShowPassengerIds,
    latestQuickMessage: latestQuickMessage == _unset
        ? this.latestQuickMessage
        : latestQuickMessage as String?,
    actualDistanceKm: actualDistanceKm ?? this.actualDistanceKm,
    rideTimeoutMinutes: rideTimeoutMinutes == _unset
        ? this.rideTimeoutMinutes
        : rideTimeoutMinutes as int?,
    hasShownTimeoutWarning: hasShownTimeoutWarning ?? this.hasShownTimeoutWarning,
    isConnected: isConnected ?? this.isConnected,
    pendingLocationWrites: pendingLocationWrites ?? this.pendingLocationWrites,
    rideDelayMinutes: rideDelayMinutes ?? this.rideDelayMinutes,
    hasNotifiedDelay: hasNotifiedDelay ?? this.hasNotifiedDelay,
    lastDriverLocationUpdate: lastDriverLocationUpdate == _unset
        ? this.lastDriverLocationUpdate
        : lastDriverLocationUpdate as DateTime?,
    pickupProximityFired: pickupProximityFired ?? this.pickupProximityFired,
    destinationProximityFired: destinationProximityFired ?? this.destinationProximityFired,
  );
}

/// ViewModel for active-ride screens — views watch only this provider.
@riverpod
class ActiveRideViewModel extends _$ActiveRideViewModel {
  StreamSubscription<Position>? _positionStreamSubscription;
  Future<ActiveRideLocationInitResult>? _locationInitializationOperation;
  DateTime? _lastLocationWriteTime;

  // B6: EMA smoothing — keep last 3 ETA values for weighted average
  final List<int> _recentEtaValues = [];
  static const int _etaWindowSize = 3;
  static const double _maxEtaChangeRatio = 0.30;

  // G2: Debounce ETA recalculation — max 1/sec
  DateTime? _lastEtaUpdateTime;

  // RTDB writes are cheap — update at most once every 3 seconds (no backoff)
  static const int _writeIntervalSeconds = 3;

  @override
  ActiveRideState build(String rideId) {
    ref
      ..onDispose(() {
        final positionStreamSubscription = _positionStreamSubscription;
        if (positionStreamSubscription != null) {
          unawaited(positionStreamSubscription.cancel());
        }
      })
      ..listen(rideStreamProvider(rideId), (_, next) {
        Future.microtask(() {
          if (!ref.mounted) return;
          _handleRideUpdate(next);
        });
      })
      ..listen(bookingsByRideProvider(rideId), (_, next) {
        Future.microtask(() {
          if (!ref.mounted) return;
          _handleBookingsUpdate(next.value ?? const <RideBooking>[]);
        });
      })
      ..listen(driverLiveLocationProvider(rideId), (_, next) {
        Future.microtask(() {
          if (!ref.mounted) return;
          _handleDriverLiveLocationUpdate(next.value);
        });
      });

    // Sync picked-up passengers from Firestore so the driver's confirmed
    // pickups survive app restarts and are visible to all parties.
    ref.listen(pickedUpPassengersStreamProvider(rideId), (_, next) {
      Future.microtask(() {
        if (!ref.mounted) return;
        final ids = next.value;
        if (ids != null) {
          state = state.copyWith(pickedUpPassengerIds: ids.toSet());
        }
      });
    });

    final rideAsync = ref.read(rideStreamProvider(rideId));
    final bookings = ref.read(bookingsByRideProvider(rideId)).value ?? const <RideBooking>[];
    final driverLiveLocation = ref.read(driverLiveLocationProvider(rideId)).value;

    Future<void>.microtask(() {
      if (!ref.mounted) return;
      _handleRideUpdate(ref.read(rideStreamProvider(rideId)));
      // F1: Restore any pending location writes from a previous session
      restorePendingLocationWrite();
    });

    return ActiveRideState(
      ride: rideAsync,
      bookings: bookings,
      phase: _derivePhase(rideAsync.value),
      driverLiveLocation: driverLiveLocation,
    );
  }

  void skipReviewPrompt() {
    if (state.hasSkippedReview) return;
    state = state.copyWith(hasSkippedReview: true);
  }

  void markCompletionNavigationHandled() {
    if (state.hasAutoNavigatedToCompletion) return;
    state = state.copyWith(hasAutoNavigatedToCompletion: true);
  }

  Future<ActiveRideLocationInitResult> initializeLocationTracking({
    bool requestPermission = false,
  }) {
    final existingOperation = _locationInitializationOperation;
    if (existingOperation != null) {
      return existingOperation;
    }

    final initializationOperation = _runLocationInitialization(
      requestPermission: requestPermission,
    );
    _locationInitializationOperation = initializationOperation;
    return initializationOperation.whenComplete(() {
      if (identical(
        _locationInitializationOperation,
        initializationOperation,
      )) {
        _locationInitializationOperation = null;
      }
    });
  }

  Future<ActiveRideLocationInitResult> _runLocationInitialization({
    required bool requestPermission,
  }) async {
    state = state.copyWith(
      isLoadingLocation: true,
      hasInitializedLocation: true,
      locationError: null,
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: false,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: false,
          locationError: 'location-services-disabled',
        );
        return ActiveRideLocationInitResult.servicesDisabled;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && requestPermission) {
        permission = await Geolocator.requestPermission();
      }

      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: true,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: true,
          locationError: 'location-permission-denied-forever',
        );
        return ActiveRideLocationInitResult.permissionDeniedForever;
      }

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationServicesEnabled: true,
          locationPermissionGranted: false,
          locationPermissionDeniedForever: false,
          locationError: requestPermission ? 'location-permission-denied' : null,
        );
        return requestPermission
            ? ActiveRideLocationInitResult.permissionDenied
            : ActiveRideLocationInitResult.permissionRequired;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      state = state.copyWith(
        currentLocation: LatLng(position.latitude, position.longitude),
        userHeading: _sanitizeHeading(position.heading),
        currentSpeedKmh: _speedKmhFrom(position),
        isLoadingLocation: false,
        locationServicesEnabled: true,
        locationPermissionGranted: true,
        locationPermissionDeniedForever: false,
        locationError: null,
      );

      _publishLiveLocation(position, force: true);
      _startLocationStream();
      _updateDynamicEta(state.currentRide);
      return ActiveRideLocationInitResult.ready;
    } catch (e, st) {
      TalkerService.error(
        'Error initializing active ride location',
        e,
        st,
      );
      if (!ref.mounted) return ActiveRideLocationInitResult.error;

      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'location-init-failed',
      );
      return ActiveRideLocationInitResult.error;
    }
  }

  void _startLocationStream() {
    _positionStreamSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
          (position) {
            if (!ref.mounted) return;

            final newPosition = LatLng(position.latitude, position.longitude);
            // 7F: Accumulate actual driven distance from the previous fix
            // before currentLocation is overwritten below.
            _accumulateDistance(newPosition);

            state = state.copyWith(
              currentLocation: newPosition,
              userHeading: _sanitizeHeading(position.heading),
              currentSpeedKmh: _speedKmhFrom(position),
              isLoadingLocation: false,
              locationServicesEnabled: true,
              locationPermissionGranted: true,
              locationPermissionDeniedForever: false,
              locationError: null,
            );

            final now = DateTime.now();
            _publishLiveLocation(position);

            // G2: Debounce ETA + off-route checks to max 1/sec
            if (_lastEtaUpdateTime == null ||
                now.difference(_lastEtaUpdateTime!).inMilliseconds >= 1000) {
              _lastEtaUpdateTime = now;
              _updateDynamicEta(state.currentRide);
              _checkDriverOffRoute(state.currentRide);
              // 7G/7J: Re-evaluate ride-timeout and departure-delay on the same
              // debounced cadence as the other periodic location checks.
              _checkRideTimeout();
              _checkDepartureDelay();
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            TalkerService.error(
              'Active ride GPS stream failed',
              error,
              stackTrace,
            );
            if (!ref.mounted) return;
            state = state.copyWith(
              isLoadingLocation: false,
              locationError: 'location-stream-failed',
            );
          },
        );
  }

  void _publishLiveLocation(Position position, {bool force = false}) {
    final now = DateTime.now();
    if (!force &&
        _lastLocationWriteTime != null &&
        now.difference(_lastLocationWriteTime!).inSeconds < _writeIntervalSeconds) {
      return;
    }

    _lastLocationWriteTime = now;
    final heading = _sanitizeHeading(position.heading);

    unawaited(
      _persistPendingLocation(rideId, position.latitude, position.longitude),
    );
    unawaited(
      ref
          .read(rideActionsViewModelProvider.notifier)
          .updateLiveLocation(
            rideId,
            position.latitude,
            position.longitude,
            heading: heading,
          )
          .then((_) {
            if (!ref.mounted) return;
            _clearPendingWrites();
            unawaited(_clearPersistedLocation());
          })
          .catchError((Object e, StackTrace st) {
            if (ref.mounted && state.pendingLocationWrites == 0) {
              _incrementPendingWrites();
            }
            TalkerService.error(
              'Failed to write live location update',
              e,
              st,
            );
          }),
    );
    _checkProximity(position);
  }

  void toggleNavigationExpanded() {
    state = state.copyWith(isNavigationExpanded: !state.isNavigationExpanded);
  }

  void showPassengerDetails() {
    if (state.showPassengerDetails) return;
    state = state.copyWith(showPassengerDetails: true);
  }

  void hidePassengerDetails() {
    if (!state.showPassengerDetails) return;
    state = state.copyWith(showPassengerDetails: false);
  }

  void selectPoi(PointOfInterest poi) {
    state = state.copyWith(
      nearbyPOIs: <PointOfInterest>[poi],
      showPOIMarkers: true,
    );
  }

  void clearPoiMarkers() {
    state = state.copyWith(
      nearbyPOIs: const <PointOfInterest>[],
      showPOIMarkers: false,
    );
  }

  /// Verify OTP and mark passenger as picked up if it matches.
  ///
  /// The OTP is generated when the driver accepts the booking and is shown
  /// to the passenger. The driver enters it here to confirm the pickup.
  /// Returns true on success, false if OTP doesn't match.
  Future<bool> confirmPickupWithOtp({
    required String passengerId,
    required String bookingId,
    required String enteredOtp,
  }) async {
    final booking = state.bookings.where((b) => b.id == bookingId).firstOrNull;
    if (booking == null) {
      state = state.copyWith(actionError: 'Booking not found');
      return false;
    }

    if (booking.pickupOtp == null || booking.pickupOtp != enteredOtp.trim()) {
      state = state.copyWith(
        actionError: 'Incorrect OTP — ask the passenger for their code',
      );
      return false;
    }

    markPassengerPickedUp(passengerId);
    return true;
  }

  void transitionToArriving() {
    if (state.isProcessing || state.phase != ActiveRidePhase.enRoute) {
      return;
    }

    state = state.copyWith(phase: ActiveRidePhase.arriving);

    // Persist phase to Firestore so passengers see the transition
    final rideId = state.currentRide?.id;
    if (rideId != null) {
      unawaited(
        ref.read(rideRepositoryProvider).updateRidePhase(rideId, 'arriving'),
      );
    }
  }

  Future<bool> startRide() async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      await ref.read(rideRepositoryProvider).startRide(ride.id);
      if (!ref.mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        actionError: null,
        phase: ActiveRidePhase.pickingUp,
      );

      // Auto-compute optimal pickup order when there are multiple passengers
      unawaited(computeOptimalPickupOrder());

      // H2: Notify all passengers that driver has arrived / ride is starting
      _notifyPassengersDriverArrived(ride);

      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  /// H2: Notify all accepted passengers that the driver has arrived / ride started.
  void _notifyPassengersDriverArrived(RideModel ride) {
    final notificationRepo = ref.read(notificationRepositoryProvider);
    final driver = ref.read(currentUserProvider).value;
    final driverName = driver?.username ?? 'Your driver';
    final driverPhoto = driver?.photoUrl;
    final origin = ride.origin.city ?? ride.origin.address;
    final dest = ride.destination.city ?? ride.destination.address;
    final rideName = '$origin → $dest';

    for (final booking in state.bookings) {
      if (booking.status != BookingStatus.accepted) continue;
      unawaited(
        notificationRepo
            .sendDriverArrivedAtPickup(
              toUserId: booking.passengerId,
              driverName: driverName,
              driverPhoto: driverPhoto,
              rideId: ride.id,
              rideName: rideName,
            )
            .catchError((e, st) {
              TalkerService.error(
                'Failed to send driver arrived notification to ${booking.passengerId}',
                e,
              );
            }),
      );
    }
  }

  /// Transitions from pickingUp → enRoute after driver confirms all pickups.
  /// Forward-only: only valid when current phase is [ActiveRidePhase.pickingUp].
  Future<bool> departFromPickup() async {
    if (state.isProcessing || state.phase != ActiveRidePhase.pickingUp) {
      return false;
    }

    state = state.copyWith(phase: ActiveRidePhase.enRoute);

    final rideId = state.currentRide?.id;
    if (rideId != null) {
      unawaited(
        ref.read(rideRepositoryProvider).updateRidePhase(rideId, 'enRoute'),
      );
    }
    return true;
  }

  Future<bool> completeRide() async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;
    // Forward-only: cannot complete during pickup phase
    if (state.phase == ActiveRidePhase.pickingUp) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      // 7F: Persist the GPS-accumulated actual distance for fare
      // reconciliation before marking the ride complete.
      await _recordActualDistance();
      await ref.read(rideServiceProvider.notifier).completeRide(ride.id);
      if (!ref.mounted) return false;

      state = state.copyWith(
        isProcessing: false,
        actionError: null,
        phase: ActiveRidePhase.completed,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  Future<bool> cancelRide({String reason = 'Cancelled by user'}) async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      await ref.read(rideServiceProvider.notifier).cancelRide(ride.id, reason);
      if (!ref.mounted) return false;

      state = state.copyWith(isProcessing: false, actionError: null);
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  // ==================== 7A: PICKUP ORDER ====================

  /// Compute optimal pickup order using OSRM trip optimization.
  Future<void> computeOptimalPickupOrder() async {
    final ride = state.currentRide;
    if (ride == null) return;

    final acceptedBookings = state.bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();
    if (acceptedBookings.length <= 1) {
      // Single passenger — no optimization needed
      if (acceptedBookings.isNotEmpty) {
        state = state.copyWith(
          pickupOrder: [acceptedBookings.first.passengerId],
        );
      }
      return;
    }

    // Build waypoints from passenger pickup locations
    final points = <LatLng>[
      LatLng(ride.origin.latitude, ride.origin.longitude),
    ];
    final passengerByIndex = <int, String>{};
    for (var i = 0; i < acceptedBookings.length; i++) {
      final pickup = acceptedBookings[i].pickupLocation;
      if (pickup != null) {
        passengerByIndex[points.length] = acceptedBookings[i].passengerId;
        points.add(LatLng(pickup.latitude, pickup.longitude));
      } else {
        // Use ride origin as fallback
        passengerByIndex[points.length] = acceptedBookings[i].passengerId;
        points.add(LatLng(ride.origin.latitude, ride.origin.longitude));
      }
    }
    points.add(LatLng(ride.destination.latitude, ride.destination.longitude));

    // Use OSRM trip endpoint for optimal ordering
    final tripResult = await ref.read(routingServiceProvider).getOptimalTrip(points: points);
    if (tripResult == null || !ref.mounted) {
      // Fallback: keep booking creation order
      state = state.copyWith(
        pickupOrder: acceptedBookings.map((b) => b.passengerId).toList(),
      );
      return;
    }

    // The trip result reorders the points — extract passenger order
    // For now use distance-based sort from driver's current location
    final driverLoc = state.currentLocation ?? LatLng(ride.origin.latitude, ride.origin.longitude);
    final sorted = List<RideBooking>.from(acceptedBookings)
      ..sort((a, b) {
        final aLoc = a.pickupLocation;
        final bLoc = b.pickupLocation;
        if (aLoc == null && bLoc == null) return 0;
        if (aLoc == null) return 1;
        if (bLoc == null) return -1;
        final aDist = _distKm(
          driverLoc,
          LatLng(aLoc.latitude, aLoc.longitude),
        );
        final bDist = _distKm(
          driverLoc,
          LatLng(bLoc.latitude, bLoc.longitude),
        );
        return aDist.compareTo(bDist);
      });

    final order = sorted.map((b) => b.passengerId).toList();
    state = state.copyWith(pickupOrder: order);

    // Persist to Firestore so passengers can see their queue position
    unawaited(
      ref.read(rideRepositoryProvider).updatePickupOrder(ride.id, order),
    );
  }

  /// Mark a passenger as picked up — persists to Firestore.
  void markPassengerPickedUp(String passengerId) {
    final nextPickedUp = <String>{...state.pickedUpPassengerIds};
    if (!nextPickedUp.add(passengerId)) return; // Already picked up

    state = state.copyWith(pickedUpPassengerIds: nextPickedUp);

    final rideId = state.currentRide?.id;
    if (rideId != null) {
      unawaited(
        ref.read(rideRepositoryProvider).markPassengerPickedUp(rideId, passengerId),
      );
    }
  }

  /// Get a passenger's position in the pickup queue (1-based).
  int getPickupQueuePosition(String passengerId) {
    final idx = state.pickupOrder.indexOf(passengerId);
    return idx >= 0 ? idx + 1 : 0;
  }

  // ==================== 7B: NO-SHOW HANDLING ====================

  /// Mark a passenger as no-show locally (not committed to Firestore yet).
  /// Call [commitNoShow] after undo window expires to persist.
  void localMarkNoShow({required String passengerId}) {
    final nextNoShow = <String>{...state.noShowPassengerIds, passengerId};
    final nextPickedUp = <String>{...state.pickedUpPassengerIds}..remove(passengerId);
    state = state.copyWith(
      noShowPassengerIds: nextNoShow,
      pickedUpPassengerIds: nextPickedUp,
    );
  }

  /// Undo a local-only no-show mark before Firestore commit.
  void undoNoShow({required String passengerId}) {
    final nextNoShow = <String>{...state.noShowPassengerIds}..remove(passengerId);
    state = state.copyWith(noShowPassengerIds: nextNoShow);
  }

  /// Commit a no-show to Firestore (called after undo window expires).
  Future<bool> commitNoShow({
    required String passengerId,
    required String bookingId,
  }) async {
    final ride = state.currentRide;
    if (ride == null) return false;

    try {
      await ref
          .read(rideServiceProvider.notifier)
          .markPassengerNoShow(
            rideId: ride.id,
            bookingId: bookingId,
            passengerId: passengerId,
          );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(actionError: e.toString());
      return false;
    }
  }

  /// Mark a passenger as no-show, cancel their booking, and notify them.
  /// @deprecated Use localMarkNoShow + commitNoShow with undo window instead.
  Future<bool> markPassengerNoShow({
    required String passengerId,
    required String bookingId,
  }) async {
    final ride = state.currentRide;
    if (ride == null || state.isProcessing) return false;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);

      await ref
          .read(rideServiceProvider.notifier)
          .markPassengerNoShow(
            rideId: ride.id,
            bookingId: bookingId,
            passengerId: passengerId,
          );

      if (!ref.mounted) return false;

      final nextNoShow = <String>{...state.noShowPassengerIds, passengerId};
      // Also remove from picked-up set if mistakenly marked
      final nextPickedUp = <String>{...state.pickedUpPassengerIds}..remove(passengerId);

      state = state.copyWith(
        isProcessing: false,
        noShowPassengerIds: nextNoShow,
        pickedUpPassengerIds: nextPickedUp,
      );
      return true;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return false;
    }
  }

  // ==================== 7D: QUICK MESSAGES ====================

  /// Send a quick message to a chat (pre-defined in-ride messages).
  Future<void> sendQuickMessage({
    required String chatId,
    required String message,
    required String senderId,
    required String senderName,
  }) async {
    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.sendMessage(
        MessageModel(
          id: '',
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
          content: message,
          createdAt: DateTime.now(),
        ),
      );
    } catch (e) {
      TalkerService.error('Failed to send quick message: $e');
    }
  }

  /// Update the latest quick message displayed on the ride screen.
  void setLatestQuickMessage(String? message) {
    state = state.copyWith(latestQuickMessage: message);

    // Auto-dismiss after 5 seconds
    if (message != null) {
      Future.delayed(const Duration(seconds: 5), () {
        if (ref.mounted && state.latestQuickMessage == message) {
          state = state.copyWith(latestQuickMessage: null);
        }
      });
    }
  }

  // ==================== 7F: FARE ADJUSTMENT ====================

  /// Accumulate actual distance driven from GPS position updates.
  void _accumulateDistance(LatLng newPosition) {
    final prevPos = state.currentLocation;
    if (prevPos == null) return;

    final segmentKm = _distKm(prevPos, newPosition);
    // Only count reasonable segments (filter GPS jumps > 5km)
    if (segmentKm > 0.001 && segmentKm < 5.0) {
      state = state.copyWith(
        actualDistanceKm: state.actualDistanceKm + segmentKm,
      );
    }
  }

  /// Calculate fare discrepancy between planned and actual distance.
  /// Returns positive if over, negative if under.
  double getFareDiscrepancyPercent() {
    final ride = state.currentRide;
    if (ride == null) return 0;
    final planned = ride.distanceKm ?? ride.route.distanceKm ?? 0;
    if (planned <= 0 || state.actualDistanceKm <= 0) return 0;
    return ((state.actualDistanceKm - planned) / planned) * 100;
  }

  /// Persist actual distance to Firestore on ride completion.
  Future<void> _recordActualDistance() async {
    final ride = state.currentRide;
    if (ride == null || state.actualDistanceKm <= 0) return;
    try {
      await ref.read(rideRepositoryProvider).recordActualDistance(ride.id, state.actualDistanceKm);
    } catch (e) {
      TalkerService.error('Failed to record actual distance: $e');
    }
  }

  // ==================== 7G: RIDE TIMEOUT ====================

  /// Check if ride has exceeded estimated duration. Called periodically.
  void _checkRideTimeout() {
    final ride = state.currentRide;
    if (ride == null || ride.status != RideStatus.inProgress) return;

    final timeout = ref.read(rideServiceProvider.notifier).checkRideTimeout(ride);
    if (timeout == null) {
      if (state.rideTimeoutMinutes != null) {
        state = state.copyWith(rideTimeoutMinutes: null);
      }
      return;
    }

    state = state.copyWith(rideTimeoutMinutes: timeout);
  }

  void dismissTimeoutWarning() {
    state = state.copyWith(hasShownTimeoutWarning: true);
  }

  // ==================== 7H: RETURN RIDE ====================

  Future<String?> createReturnRide() async {
    final ride = state.currentRide;
    if (ride == null) return null;

    try {
      state = state.copyWith(isProcessing: true, actionError: null);
      final returnRideId = await ref.read(rideServiceProvider.notifier).createReturnRide(ride.id);
      if (!ref.mounted) return null;

      state = state.copyWith(isProcessing: false);
      return returnRideId;
    } catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(isProcessing: false, actionError: e.toString());
      return null;
    }
  }

  // ==================== 7I: CONNECTIVITY ====================

  void updateConnectivityStatus(bool isConnected) {
    if (state.isConnected == isConnected) return;
    state = state.copyWith(isConnected: isConnected);

    if (isConnected && state.pendingLocationWrites > 0) {
      // Flush pending location write
      _flushPendingLocation();
    }
  }

  void _incrementPendingWrites() {
    state = state.copyWith(
      pendingLocationWrites: state.pendingLocationWrites + 1,
    );
  }

  void _clearPendingWrites() {
    if (state.pendingLocationWrites > 0) {
      state = state.copyWith(pendingLocationWrites: 0);
    }
  }

  void _flushPendingLocation() {
    final ride = state.currentRide;
    final loc = state.currentLocation;
    if (ride == null || loc == null) return;

    // F1: Persist pending location to SharedPreferences for app restart
    unawaited(_persistPendingLocation(ride.id, loc.latitude, loc.longitude));

    unawaited(
      ref
          .read(rideRepositoryProvider)
          .updateLiveLocation(ride.id, loc.latitude, loc.longitude)
          .then((_) {
            if (ref.mounted) {
              _clearPendingWrites();
              unawaited(_clearPersistedLocation());
            }
          })
          .catchError((e, st) {
            TalkerService.error(
              'Failed to write live location update',
              e,
            );
          }),
    );
  }

  /// F1: Persist pending location write so it survives app kill.
  static Future<void> _persistPendingLocation(
    String rideId,
    double lat,
    double lng,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_loc_ride', rideId);
    await prefs.setDouble('pending_loc_lat', lat);
    await prefs.setDouble('pending_loc_lng', lng);
  }

  /// F1: Clear persisted pending location after successful write.
  static Future<void> _clearPersistedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_loc_ride');
    await prefs.remove('pending_loc_lat');
    await prefs.remove('pending_loc_lng');
  }

  /// F1: Restore and flush any pending location write from a previous session.
  Future<void> restorePendingLocationWrite() async {
    final prefs = await SharedPreferences.getInstance();
    final rideId = prefs.getString('pending_loc_ride');
    final lat = prefs.getDouble('pending_loc_lat');
    final lng = prefs.getDouble('pending_loc_lng');
    if (rideId == null || lat == null || lng == null) return;

    try {
      await ref.read(rideRepositoryProvider).updateLiveLocation(rideId, lat, lng);
      await _clearPersistedLocation();
    } catch (_) {
      // Will retry on next GPS update
    }
  }

  // ==================== 7J: DELAY DETECTION ====================

  /// Check if the ride departure is delayed (ride status still active past departure time).
  void _checkDepartureDelay() {
    final ride = state.currentRide;
    if (ride == null) return;

    // Only check for active rides (not yet started)
    if (ride.status != RideStatus.active && ride.status != RideStatus.full) {
      if (state.rideDelayMinutes > 0) {
        state = state.copyWith(rideDelayMinutes: 0);
      }
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(ride.departureTime)) {
      final delayMin = now.difference(ride.departureTime).inMinutes;
      state = state.copyWith(rideDelayMinutes: delayMin);

      // Auto-notify passengers once when delay exceeds 5 minutes
      if (delayMin >= 5 && !state.hasNotifiedDelay) {
        state = state.copyWith(hasNotifiedDelay: true);
        unawaited(
          ref
              .read(rideServiceProvider.notifier)
              .notifyRideDelay(ride: ride, delayMinutes: delayMin),
        );
      }
    }
  }

  void _handleRideUpdate(AsyncValue<RideModel?> rideAsync) {
    final ride = rideAsync.value;
    // Derive phase from the ride document's ridePhase field — single source
    // of truth. No separate stream needed since ridePhase lives in the ride
    // doc and arrives with every rideStreamProvider snapshot.
    final phase = _derivePhase(ride);

    state = state.copyWith(ride: rideAsync, phase: phase);

    if (ride == null) {
      _clearDynamicEta();
      _clearPassengerRouteTracking();
      return;
    }

    if (ride.status != RideStatus.completed && state.hasAutoNavigatedToCompletion) {
      state = state.copyWith(hasAutoNavigatedToCompletion: false);
    }

    unawaited(_ensureOsrmRouteLoaded(ride));
    _updateDynamicEta(ride);
    _computeWaypointEtas(ride);
    _updatePassengerRouteTracking(ride, state.driverLiveLocation);
  }

  void _handleBookingsUpdate(List<RideBooking> bookings) {
    final validPassengerIds = bookings.map((booking) => booking.passengerId).toSet();
    final pickedUpPassengerIds = state.pickedUpPassengerIds
        .where(validPassengerIds.contains)
        .toSet();

    state = state.copyWith(
      bookings: bookings,
      pickedUpPassengerIds: pickedUpPassengerIds,
    );
  }

  void _handleDriverLiveLocationUpdate(
    ({double latitude, double longitude})? driverLiveLocation,
  ) {
    state = state.copyWith(
      driverLiveLocation: driverLiveLocation,
      lastDriverLocationUpdate: driverLiveLocation != null ? DateTime.now() : null,
    );
    _updatePassengerRouteTracking(state.currentRide, driverLiveLocation);
    // Recalculate ETAs on every driver-location tick so the passenger screen
    // shows live remaining time and per-waypoint ETAs (not stale snapshots).
    _updateDynamicEta(state.currentRide);
    final ride = state.currentRide;
    if (ride != null) _computeWaypointEtas(ride);
  }

  /// Derives the ride phase from the ride document's persisted `ridePhase`
  /// field and the ride status. The persisted phase takes priority so
  /// passengers see the driver's granular progress.
  ActiveRidePhase _derivePhase(RideModel? ride) {
    if (ride == null) return ActiveRidePhase.pickingUp;
    if (ride.status == RideStatus.completed) {
      return ActiveRidePhase.completed;
    }
    // Use the ridePhase field persisted in the ride document
    final phase = _parsePhase(ride.ridePhase);
    if (phase != null) return phase;
    // Fallback: ride is in-progress but no phase stored yet → pickingUp
    // (driver just started, hasn't confirmed pickups)
    if (ride.status == RideStatus.inProgress) {
      return ActiveRidePhase.pickingUp;
    }
    return ActiveRidePhase.pickingUp;
  }

  static ActiveRidePhase? _parsePhase(String? phaseStr) {
    return switch (phaseStr) {
      'pickingUp' => ActiveRidePhase.pickingUp,
      'enRoute' => ActiveRidePhase.enRoute,
      'arriving' => ActiveRidePhase.arriving,
      'completed' => ActiveRidePhase.completed,
      _ => null,
    };
  }

  Future<void> _ensureOsrmRouteLoaded(RideModel ride) async {
    final routeKey = _routeKeyFor(ride);
    final alreadyLoaded = state.loadedRouteKey == routeKey && state.osrmRoutePoints != null;
    final isLoadingSameRoute = state.isLoadingOsrmRoute && state.loadingRouteKey == routeKey;

    if (alreadyLoaded || isLoadingSameRoute) {
      return;
    }

    state = state.copyWith(
      isLoadingOsrmRoute: true,
      loadingRouteKey: routeKey,
      osrmRoutePoints: state.loadedRouteKey == routeKey ? state.osrmRoutePoints : null,
      loadedRouteKey: state.loadedRouteKey == routeKey ? state.loadedRouteKey : null,
      remainingDistanceKm: state.loadedRouteKey == routeKey ? state.remainingDistanceKm : null,
      remainingEtaMinutes: state.loadedRouteKey == routeKey ? state.remainingEtaMinutes : null,
    );

    try {
      final waypoints = ride.route.waypoints
          .map(
            (waypoint) => LatLng(waypoint.location.latitude, waypoint.location.longitude),
          )
          .toList(growable: false);

      final routeInfo = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: LatLng(ride.origin.latitude, ride.origin.longitude),
            destination: LatLng(
              ride.destination.latitude,
              ride.destination.longitude,
            ),
            waypoints: waypoints.isEmpty ? null : waypoints,
          );

      if (!ref.mounted || state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
      _updateDynamicEta(ride);
      _updatePassengerRouteTracking(ride, state.driverLiveLocation);
    } catch (e, st) {
      TalkerService.error(
        'Error loading active ride OSRM route',
        e,
        st,
      );
      if (!ref.mounted || state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    }
  }

  void _updateDynamicEta(RideModel? ride) {
    // Driver uses own GPS; passenger uses the Firestore-synced driver location.
    final dl = state.driverLiveLocation;
    final effectiveLocation =
        state.currentLocation ?? (dl != null ? LatLng(dl.latitude, dl.longitude) : null);

    final routePoints = state.osrmRoutePoints;
    if (ride == null ||
        effectiveLocation == null ||
        routePoints == null ||
        routePoints.length < 2) {
      _clearDynamicEta();
      return;
    }

    var minimumDistance = double.infinity;
    var closestIndex = 0;
    for (var index = 0; index < routePoints.length; index++) {
      final distance = _distKm(effectiveLocation, routePoints[index]);
      if (!distance.isFinite) continue;
      if (distance < minimumDistance) {
        minimumDistance = distance;
        closestIndex = index;
      }
    }

    if (!minimumDistance.isFinite) {
      _clearDynamicEta();
      return;
    }

    var remainingDistance = _distKm(
      effectiveLocation,
      routePoints[closestIndex],
    );
    for (var index = closestIndex; index < routePoints.length - 1; index++) {
      remainingDistance += _distKm(
        routePoints[index],
        routePoints[index + 1],
      );
    }

    // B4: Floor remaining distance at zero (driver may overshoot)
    remainingDistance = math.max(0, remainingDistance);

    final totalDistance = ride.distanceKm ?? ride.route.distanceKm ?? 0;
    final totalDuration = ride.durationMinutes ?? ride.route.durationMinutes ?? 0;
    if (!remainingDistance.isFinite ||
        !totalDistance.isFinite ||
        !totalDuration.isFinite ||
        totalDistance <= 0 ||
        totalDuration <= 0) {
      _clearDynamicEta();
      return;
    }

    final ratio = (remainingDistance / totalDistance).clamp(0.0, 1.0);
    final rawEta = (ratio * totalDuration).round().clamp(0, 999);

    // B6: EMA smoothing — cap single-update change to ±30%
    final smoothedEta = _smoothEta(rawEta);

    // Build the remaining-portion polyline: effective position + route from closest point onward
    final remaining = <LatLng>[
      effectiveLocation,
      ...routePoints.sublist(closestIndex),
    ];

    state = state.copyWith(
      remainingRoutePoints: remaining,
      remainingDistanceKm: remainingDistance,
      remainingEtaMinutes: smoothedEta,
    );
  }

  /// B6: Smooth ETA using exponential moving average over last 3 values.
  /// Caps single-update change to ±30% to prevent jarring jumps.
  int _smoothEta(int rawEta) {
    if (_recentEtaValues.isEmpty) {
      _recentEtaValues.add(rawEta);
      return rawEta;
    }

    final previous = _recentEtaValues.last;
    if (previous > 0) {
      final maxDelta = (previous * _maxEtaChangeRatio).ceil();
      rawEta = rawEta.clamp(previous - maxDelta, previous + maxDelta);
    }

    _recentEtaValues.add(rawEta);
    if (_recentEtaValues.length > _etaWindowSize) {
      _recentEtaValues.removeAt(0);
    }

    // Weighted average: most recent gets highest weight
    var weightedSum = 0.0;
    var totalWeight = 0.0;
    for (var i = 0; i < _recentEtaValues.length; i++) {
      final weight = (i + 1).toDouble();
      weightedSum += _recentEtaValues[i] * weight;
      totalWeight += weight;
    }
    return (weightedSum / totalWeight).round().clamp(0, 999);
  }

  void _clearDynamicEta() {
    _recentEtaValues.clear();
    state = state.copyWith(
      remainingRoutePoints: null,
      remainingDistanceKm: null,
      remainingEtaMinutes: null,
    );
  }

  /// Compute ETA (minutes from now) for each upcoming waypoint.
  ///
  /// Uses the driver's current GPS position (driver side) or the
  /// Firestore-synced live location (passenger side) as the starting point so
  /// ETAs reflect remaining travel time, not time from the route origin.
  void _computeWaypointEtas(RideModel ride) {
    final routePoints = state.osrmRoutePoints;
    if (routePoints == null || routePoints.length < 2 || ride.route.waypoints.isEmpty) {
      state = state.copyWith(waypointEtaMinutes: const <int, int>{});
      return;
    }

    // Resolve effective position: driver GPS first, Firestore location as fallback.
    final dl = state.driverLiveLocation;
    final effectivePos =
        state.currentLocation ?? (dl != null ? LatLng(dl.latitude, dl.longitude) : null);

    // Find the route index nearest to the driver's current position.
    var driverNearestIdx = 0;
    if (effectivePos != null) {
      var minDist = double.infinity;
      for (var i = 0; i < routePoints.length; i++) {
        final d = _distKm(effectivePos, routePoints[i]);
        if (d < minDist) {
          minDist = d;
          driverNearestIdx = i;
        }
      }
    }

    // Compute cumulative distance from driver's nearest point to end of route.
    final cumulativeFromDriver = <double>[0];
    for (var i = driverNearestIdx + 1; i < routePoints.length; i++) {
      cumulativeFromDriver.add(
        cumulativeFromDriver.last + _distKm(routePoints[i - 1], routePoints[i]),
      );
    }
    final remainingRouteKm = cumulativeFromDriver.last;
    if (!remainingRouteKm.isFinite || remainingRouteKm <= 0) return;

    // Use the live remaining ETA when available; fall back to proportional estimate.
    final remainingEtaMin =
        (state.remainingEtaMinutes ?? ride.durationMinutes ?? ride.route.durationMinutes ?? 0)
            .toDouble();
    if (!remainingEtaMin.isFinite || remainingEtaMin <= 0) return;

    final etas = <int, int>{};
    for (final wp in ride.route.waypoints) {
      // B1: Skip already-passed waypoints — no phantom ETAs.
      if (state.passedWaypointIndices.contains(wp.order)) continue;

      final wpLatLng = LatLng(wp.location.latitude, wp.location.longitude);

      // Find the route index nearest to this waypoint, searching only ahead
      // of the driver to avoid snapping to already-travelled segments.
      var nearestRouteIdx = driverNearestIdx;
      var minWpDist = double.infinity;
      for (var i = driverNearestIdx; i < routePoints.length; i++) {
        final d = _distKm(wpLatLng, routePoints[i]);
        if (d < minWpDist) {
          minWpDist = d;
          nearestRouteIdx = i;
        }
      }

      final idxFromDriver = nearestRouteIdx - driverNearestIdx;
      if (idxFromDriver < 0 || idxFromDriver >= cumulativeFromDriver.length) {
        continue;
      }
      final distToWp = cumulativeFromDriver[idxFromDriver];
      final fraction = (distToWp / remainingRouteKm).clamp(0.0, 1.0);
      if (!fraction.isFinite) continue;
      etas[wp.order] = (fraction * remainingEtaMin).round();
    }

    state = state.copyWith(waypointEtaMinutes: etas);
  }

  DateTime? _lastRouteRecalcTime;

  /// Check if the driver is off-route based on local GPS and trigger
  /// route recalculation when necessary.
  void _checkDriverOffRoute(RideModel? ride) {
    final currentLocation = state.currentLocation;
    final routePoints = state.osrmRoutePoints;
    if (ride == null ||
        ride.status != RideStatus.inProgress ||
        currentLocation == null ||
        routePoints == null ||
        routePoints.length < 2) {
      return;
    }

    // Use perpendicular distance to route SEGMENTS (not nearest point).
    // This prevents false positives on long routes where OSRM returns sparse
    // geometry — a driver can be between two points 2 km apart but still
    // perfectly on the correct road.
    var minDistMeters = double.infinity;
    for (var i = 0; i < routePoints.length - 1; i++) {
      final d = _perpDistToSegmentMeters(
        currentLocation,
        routePoints[i],
        routePoints[i + 1],
      );
      if (d < minDistMeters) minDistMeters = d;
    }
    // Also check the final point
    final lastDist = _distKm(currentLocation, routePoints.last) * 1000;
    if (lastDist < minDistMeters) minDistMeters = lastDist;

    // Adaptive threshold: scales with average segment length so that long
    // routes with sparse OSRM geometry don't generate constant false positives.
    double totalRouteMeters = 0;
    for (var i = 0; i < routePoints.length - 1; i++) {
      totalRouteMeters += _distKm(routePoints[i], routePoints[i + 1]) * 1000;
    }
    final avgSegmentMeters = totalRouteMeters / (routePoints.length - 1);
    // Threshold: 40% of avg segment length, clamped between 150 m and 400 m.
    final offRouteThreshold = (avgSegmentMeters * 0.4).clamp(150.0, 400.0);

    final isOffRoute = minDistMeters.isFinite && minDistMeters > offRouteThreshold;
    if (isOffRoute != state.isOffRoute || isOffRoute) {
      state = state.copyWith(
        isOffRoute: isOffRoute,
        routeDeviationMeters: minDistMeters.isFinite ? minDistMeters : 0,
      );
    }

    if (isOffRoute) {
      unawaited(_recalculateRouteFromPosition(currentLocation, ride));
    }
  }

  /// Returns the perpendicular distance (metres) from point [p] to the segment [a]→[b].
  /// Uses a flat-earth projection — accurate for segments up to ~50 km.
  double _perpDistToSegmentMeters(LatLng p, LatLng a, LatLng b) {
    const latMeters = 110574.0;
    final lngMeters = 111320.0 * math.cos(a.latitude * math.pi / 180);

    final px = (p.longitude - a.longitude) * lngMeters;
    final py = (p.latitude - a.latitude) * latMeters;
    final bx = (b.longitude - a.longitude) * lngMeters;
    final by = (b.latitude - a.latitude) * latMeters;

    final segLenSq = bx * bx + by * by;
    if (segLenSq < 1.0) {
      // Degenerate (zero-length) segment — fall back to point distance.
      return _distKm(p, a) * 1000;
    }

    final t = ((px * bx + py * by) / segLenSq).clamp(0.0, 1.0);
    final dx = px - t * bx;
    final dy = py - t * by;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Recalculate the OSRM route from the given position when off-route.
  /// Throttled to at most once every 30 seconds.
  Future<void> _recalculateRouteFromPosition(
    LatLng position,
    RideModel ride,
  ) async {
    final now = DateTime.now();
    if (_lastRouteRecalcTime != null && now.difference(_lastRouteRecalcTime!).inSeconds < 30) {
      return;
    }
    _lastRouteRecalcTime = now;

    // Only include waypoints the driver has not yet passed.
    final remainingWaypoints = ride.route.waypoints
        .where((wp) => !state.passedWaypointIndices.contains(wp.order))
        .map((wp) => LatLng(wp.location.latitude, wp.location.longitude))
        .toList(growable: false);

    ref.read(routingServiceProvider).clearRouteCache();

    final routeInfo = await ref
        .read(routingServiceProvider)
        .getRoute(
          origin: position,
          destination: LatLng(
            ride.destination.latitude,
            ride.destination.longitude,
          ),
          waypoints: remainingWaypoints.isEmpty ? null : remainingWaypoints,
        );

    if (!ref.mounted || routeInfo == null) return;

    state = state.copyWith(osrmRoutePoints: routeInfo.coordinates);
    _updateDynamicEta(ride);
    _computeWaypointEtas(ride);
  }

  void _updatePassengerRouteTracking(
    RideModel? ride,
    ({double latitude, double longitude})? driverLiveLocation,
  ) {
    if (ride == null ||
        ride.status != RideStatus.inProgress ||
        driverLiveLocation == null ||
        state.osrmRoutePoints == null ||
        state.osrmRoutePoints!.length < 2) {
      _clearPassengerRouteTracking();
      return;
    }

    final driverPosition = LatLng(
      driverLiveLocation.latitude,
      driverLiveLocation.longitude,
    );
    var minimumDistanceMeters = double.infinity;
    final pts = state.osrmRoutePoints ?? [];
    for (var i = 0; i < pts.length - 1; i++) {
      final d = _perpDistToSegmentMeters(driverPosition, pts[i], pts[i + 1]);
      if (d < minimumDistanceMeters) minimumDistanceMeters = d;
    }
    final lastPtDist = _distKm(driverPosition, pts.last) * 1000;
    if (lastPtDist < minimumDistanceMeters) minimumDistanceMeters = lastPtDist;

    double totalMeters = 0;
    for (var i = 0; i < pts.length - 1; i++) {
      totalMeters += _distKm(pts[i], pts[i + 1]) * 1000;
    }
    final avgSeg = totalMeters / (pts.length - 1);
    final threshold = (avgSeg * 0.4).clamp(150.0, 400.0);

    final isOffRoute = minimumDistanceMeters.isFinite && minimumDistanceMeters > threshold;
    final newPassedIndices = _getPassedWaypointIndices(
      driverPosition,
      state.osrmRoutePoints!,
      ride,
    );

    // B2: Hysteresis — once a waypoint is marked passed, never unmark it.
    // Merge new detections with existing set to prevent GPS jitter from
    // flipping waypoints back to "unpassed".
    final mergedPassedIndices = <int>{
      ...state.passedWaypointIndices,
      ...newPassedIndices,
    };

    state = state.copyWith(
      isOffRoute: isOffRoute,
      routeDeviationMeters: minimumDistanceMeters.isFinite ? minimumDistanceMeters : 0,
      passedWaypointIndices: mergedPassedIndices,
    );

    // Trigger route recalculation when the driver is detected off-route
    if (isOffRoute) {
      unawaited(_recalculateRouteFromPosition(driverPosition, ride));
    }
  }

  Set<int> _getPassedWaypointIndices(
    LatLng driverPosition,
    List<LatLng> routePoints,
    RideModel ride,
  ) {
    if (routePoints.length < 2) return const <int>{};

    var driverIndex = 0;
    var minimumDriverDistance = double.infinity;
    for (var index = 0; index < routePoints.length; index++) {
      final distance = _distKm(driverPosition, routePoints[index]);
      if (distance < minimumDriverDistance) {
        minimumDriverDistance = distance;
        driverIndex = index;
      }
    }

    final passedWaypointIndices = <int>{};
    for (var waypointIndex = 0; waypointIndex < ride.route.waypoints.length; waypointIndex++) {
      final waypoint = ride.route.waypoints[waypointIndex];
      final waypointLatLng = LatLng(
        waypoint.location.latitude,
        waypoint.location.longitude,
      );

      var nearestWaypointIndex = 0;
      var minimumWaypointDistance = double.infinity;
      for (var routeIndex = 0; routeIndex < routePoints.length; routeIndex++) {
        final distance = _distKm(waypointLatLng, routePoints[routeIndex]);
        if (distance < minimumWaypointDistance) {
          minimumWaypointDistance = distance;
          nearestWaypointIndex = routeIndex;
        }
      }

      if (driverIndex >= nearestWaypointIndex) {
        passedWaypointIndices.add(waypoint.order);
      }
    }

    return passedWaypointIndices;
  }

  void _clearPassengerRouteTracking() {
    state = state.copyWith(
      isOffRoute: false,
      routeDeviationMeters: 0,
      passedWaypointIndices: const <int>{},
    );
  }

  String _routeKeyFor(RideModel ride) {
    final buffer = StringBuffer()
      ..write(ride.id)
      ..write('|')
      ..write(ride.origin.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.origin.longitude.toStringAsFixed(6))
      ..write('|')
      ..write(ride.destination.latitude.toStringAsFixed(6))
      ..write(',')
      ..write(ride.destination.longitude.toStringAsFixed(6));

    for (final waypoint in ride.route.waypoints) {
      buffer
        ..write('|')
        ..write(waypoint.location.latitude.toStringAsFixed(6))
        ..write(',')
        ..write(waypoint.location.longitude.toStringAsFixed(6));
    }

    return buffer.toString();
  }

  double _sanitizeHeading(double heading) {
    return heading.isFinite && heading >= 0 ? heading : 0;
  }

  double _speedKmhFrom(Position position) {
    final speed = position.speed;
    if (!speed.isFinite || speed < 0) return 0;
    return speed * 3.6;
  }

  double _distKm(LatLng a, LatLng b) =>
      GeoDistanceService.calculateDistance(
        GeoPoint(latitude: a.latitude, longitude: a.longitude),
        GeoPoint(latitude: b.latitude, longitude: b.longitude),
      ) /
      1000.0;

  void _checkProximity(Position position) {
    final ride = state.currentRide;
    if (ride == null) return;
    final driver = GeoPoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!state.pickupProximityFired &&
        GeoCircleService.isInsideCircle(
          point: driver,
          circle: GeoCircle(
            center: GeoPoint(
              latitude: ride.origin.latitude,
              longitude: ride.origin.longitude,
            ),
            radius: 150,
          ),
        )) {
      unawaited(_onEnterPickupZone());
    }
    if (!state.destinationProximityFired &&
        GeoCircleService.isInsideCircle(
          point: driver,
          circle: GeoCircle(
            center: GeoPoint(
              latitude: ride.destination.latitude,
              longitude: ride.destination.longitude,
            ),
            radius: 180,
          ),
        )) {
      unawaited(_onEnterDestinationZone());
    }
  }

  Future<void> _onEnterPickupZone() async {
    state = state.copyWith(pickupProximityFired: true);
    final ride = state.currentRide;
    if (ride == null) return;
    final driver = ref.read(currentUserProvider).value;
    final driverName = driver?.username ?? 'Driver';
    final driverPhoto = driver?.photoUrl;
    final rideName =
        '${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}';
    final notificationRepo = ref.read(notificationRepositoryProvider);
    for (final booking in state.bookings) {
      try {
        await notificationRepo.sendDriverArrivedAtPickup(
          toUserId: booking.passengerId,
          driverName: driverName,
          rideId: ride.id,
          rideName: rideName,
          driverPhoto: driverPhoto,
        );
      } catch (e, st) {
        TalkerService.error('Pickup arrival notification failed', e, st);
      }
    }
  }

  Future<void> _onEnterDestinationZone() async {
    state = state.copyWith(destinationProximityFired: true);
    transitionToArriving();
    final ride = state.currentRide;
    if (ride == null) return;
    final driver = ref.read(currentUserProvider).value;
    final driverName = driver?.username ?? 'Driver';
    final rideName =
        '${ride.origin.city ?? ride.origin.address} → ${ride.destination.city ?? ride.destination.address}';
    final notificationRepo = ref.read(notificationRepositoryProvider);
    for (final booking in state.bookings) {
      try {
        await notificationRepo.sendDriverArrivingAtDestination(
          toUserId: booking.passengerId,
          driverName: driverName,
          rideId: ride.id,
          rideName: rideName,
        );
      } catch (e, st) {
        TalkerService.error('Destination arrival notification failed', e, st);
      }
    }
  }
}

/// User's Rides Provider (as driver)
@riverpod
Future<List<RideModel>> myRidesAsDriver(Ref ref, String userId) async {
  final repository = ref.read(rideRepositoryProvider);
  return repository.getRidesByDriver(userId);
}

/// User's Rides Stream Provider (as driver) - Real-time
@riverpod
Stream<List<RideModel>> myRidesAsDriverStream(Ref ref, String userId) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamRidesByDriver(userId);
}

/// User's Rides as Passenger Stream Provider
@riverpod
Stream<List<RideModel>> myRidesAsPassengerStream(Ref ref, String userId) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamRidesAsPassenger(userId);
}

/// Nearby Rides Stream Provider
@riverpod
Stream<List<RideModel>> nearbyRides(
  Ref ref, {
  required double latitude,
  required double longitude,
}) {
  final repository = ref.read(rideRepositoryProvider);
  return repository.streamNearbyRides(latitude: latitude, longitude: longitude);
}

/// Real-time stream of bookings for a given ride, scoped to the current user's role.
///
/// • Driver  → all bookings for the ride (filtered by driverId so Firestore
///             security rules can allow the collection query).
/// • Passenger → only their own booking (filtered by passengerId).
///
/// The role is determined lazily from [rideStreamProvider] so there is no
/// extra Firestore read — the ride document is already being watched.
@riverpod
Stream<List<RideBooking>> bookingsByRide(Ref ref, String rideId) async* {
  final uid = await ref.watch(currentAuthUidProvider.future);
  if (uid == null) return;

  // Once the ride snapshot is available, use driverId to determine role.
  final ride = await ref.watch(rideStreamProvider(rideId).future);
  if (ride != null && ride.driverId != uid) {
    // Current user is a passenger — stream only their own booking.
    yield* ref.read(bookingRepositoryProvider).streamPassengerBookingForRide(rideId, uid);
    return;
  }

  // Current user is the driver (or ride hasn't loaded yet — driver query is
  // safe to retry because it returns empty for non-drivers).
  yield* ref.read(bookingRepositoryProvider).streamBookingsByRideId(rideId, uid);
}

@riverpod
Stream<List<String>> pickedUpPassengersStream(Ref ref, String rideId) {
  return ref.watch(rideRepositoryProvider).streamPickedUpPassengers(rideId);
}

/// Real-time stream of a single booking by ID.
///
/// Wraps [BookingRepository.streamBookingById] so views never import the
/// repository layer directly.
@riverpod
Stream<RideBooking?> bookingStream(Ref ref, String bookingId) {
  return ref.read(bookingRepositoryProvider).streamBookingById(bookingId);
}

/// Real-time stream of all bookings for a given passenger.
///
/// Used on the pending-booking screen where the passenger polls for
/// status changes before being auto-navigated.
///
/// Auto-disposes (no keepAlive) so a sign-out/sign-in does not retain the
/// previous user's Firestore subscription, and watches [currentAuthUidProvider]
/// so it bails out and re-runs whenever the authenticated user changes —
/// preventing one account from observing another account's bookings.
@riverpod
Stream<List<RideBooking>> bookingsByPassenger(
  Ref ref,
  String passengerId,
) async* {
  // Guard against leaking another user's bookings: only stream when the
  // authenticated uid matches the requested passenger. Watching the provider
  // also invalidates this stream automatically on auth change.
  final authUid = await ref.watch(currentAuthUidProvider.future);
  if (authUid == null || authUid != passengerId) {
    yield const <RideBooking>[];
    return;
  }

  final bookingRepository = ref.watch(bookingRepositoryProvider);

  // Emit immediately so the provider has a first value.
  yield const <RideBooking>[];

  yield* bookingRepository.streamBookingsByPassengerId(passengerId);
}

/// All Active Rides Stream Provider (for search screen)
@riverpod
Stream<List<RideModel>> activeRides(Ref ref) {
  return ref.watch(rideRepositoryProvider).streamActiveRides();
}

/// Single Ride Stream Provider (for active ride screens)
@riverpod
Stream<RideModel?> rideStream(Ref ref, String rideId) {
  return ref.watch(rideRepositoryProvider).streamRideById(rideId);
}

/// Ride reliability stats for a user (cancel & no-show counts).
///
/// Streams the user's ride history (completed + cancelled) and counts
/// how many were cancelled by the driver.
@riverpod
Stream<({int cancelCount, int noShowCount})> userRideReliability(
  Ref ref,
  String userId,
) {
  return ref.watch(rideRepositoryProvider).getRideHistory(userId).map((rides) {
    final cancelCount = rides.where((r) => r.status == RideStatus.cancelled).length;
    return (cancelCount: cancelCount, noShowCount: 0);
  });
}

// ─── Dispute ──────────────────────────────────────────────────────────────────

/// Delegates dispute submission through [DisputeRepository].
@riverpod
class DisputeViewModel extends _$DisputeViewModel {
  @override
  void build() {
    return;
  }

  /// Submits a dispute and optionally uploads file attachments.
  ///
  /// Returns the new dispute document ID.
  Future<String> submitDispute({
    required String rideId,
    required String userId,
    required String? userEmail,
    required String disputeType,
    required String description,
    String? rideSummary,
    List<File> attachments = const [],
  }) async {
    final repo = ref.read(disputeRepositoryProvider);
    final disputeId = await repo.submitDispute(
      rideId: rideId,
      userId: userId,
      userEmail: userEmail,
      disputeType: disputeType,
      description: description,
      rideSummary: rideSummary,
    );

    if (attachments.isNotEmpty) {
      await repo.uploadAttachments(disputeId: disputeId, files: attachments);
    }

    return disputeId;
  }
}
