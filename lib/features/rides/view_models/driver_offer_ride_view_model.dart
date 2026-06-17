import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/routing_service.dart'
    show routingServiceProvider;
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/repositories/event_repository.dart';
import 'package:sport_connect/features/messaging/repositories/chat_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_capacity.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_preferences.dart';
import 'package:sport_connect/features/rides/models/ride/ride_pricing.dart';
import 'package:sport_connect/features/rides/models/ride/ride_route.dart';
import 'package:sport_connect/features/rides/models/ride/ride_schedule.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/rides/services/ride_service.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/vehicles/repositories/vehicle_repository.dart';
import 'package:uuid/uuid.dart';

part 'driver_offer_ride_view_model.g.dart';

/// Sentinel value used in [copyWith] to distinguish "not provided" from "null".
const _sentinel = Object();

/// Form state for creating or editing a ride offer
class DriverOfferRideFormState {
  const DriverOfferRideFormState({
    this.currentStep = 0,
    this.fromLocation,
    this.fromAddress = '',
    this.toLocation,
    this.toAddress = '',
    this.departureDate,
    this.departureTime,
    this.waypoints = const [],
    this.selectedVehicleId,
    this.availableSeats = 3,
    this.pricePerSeatInCents = 1500,
    this.isRecurring = false,
    this.recurringDays = const [],
    this.recurringEndDate,
    this.allowPets = false,
    this.allowSmoking = false,
    this.allowLuggage = true,
    this.isWomenOnly = false,
    this.eventId,
    this.eventName,
    this.selectedEvent,
    this.isLoadingSelectedEvent = false,
    this.osrmRoutePoints,
    this.isLoadingRoute = false,
    this.routeDistanceKm,
    this.routeDurationMinutes,
    this.isSubmitting = false,
    this.submissionError,
    this.existingRideId,
  });
  // Step management
  final int currentStep;

  // Step 1: Route
  final LocationPoint? fromLocation;
  final String fromAddress;
  final LocationPoint? toLocation;
  final String toAddress;
  final DateTime? departureDate;
  final TimeOfDay? departureTime;
  final List<LocationPoint> waypoints;

  // Step 2: Details
  final String? selectedVehicleId;
  final int availableSeats;
  final int pricePerSeatInCents;
  final bool isRecurring;
  final List<int> recurringDays;
  final DateTime? recurringEndDate;

  // Step 3: Preferences
  final bool allowPets;
  final bool allowSmoking;
  final bool allowLuggage;
  final bool isWomenOnly;

  // Event attachment
  final String? eventId;
  final String? eventName;
  final EventModel? selectedEvent;
  final bool isLoadingSelectedEvent;

  // Route preview state
  final List<LatLng>? osrmRoutePoints;
  final bool isLoadingRoute;
  final double? routeDistanceKm;
  final int? routeDurationMinutes;

  // Submission state
  final bool isSubmitting;
  final String? submissionError;

  // Edit mode
  final String? existingRideId;

  DriverOfferRideFormState copyWith({
    int? currentStep,
    LocationPoint? fromLocation,
    String? fromAddress,
    Object? toLocation = _sentinel,
    String? toAddress,
    DateTime? departureDate,
    TimeOfDay? departureTime,
    List<LocationPoint>? waypoints,
    String? selectedVehicleId,
    int? availableSeats,
    int? pricePerSeatInCents,
    bool? isRecurring,
    List<int>? recurringDays,
    Object? recurringEndDate = _sentinel,
    bool? allowPets,
    bool? allowSmoking,
    bool? allowLuggage,
    bool? isWomenOnly,
    Object? eventId = _sentinel,
    Object? eventName = _sentinel,
    Object? selectedEvent = _sentinel,
    bool? isLoadingSelectedEvent,
    List<LatLng>? osrmRoutePoints,
    bool? isLoadingRoute,
    Object? routeDistanceKm = _sentinel,
    Object? routeDurationMinutes = _sentinel,
    bool? isSubmitting,
    Object? submissionError = _sentinel,
    String? existingRideId,
  }) {
    return DriverOfferRideFormState(
      currentStep: currentStep ?? this.currentStep,
      fromLocation: fromLocation ?? this.fromLocation,
      fromAddress: fromAddress ?? this.fromAddress,
      toLocation: toLocation == _sentinel
          ? this.toLocation
          : toLocation as LocationPoint?,
      toAddress: toAddress ?? this.toAddress,
      departureDate: departureDate ?? this.departureDate,
      departureTime: departureTime ?? this.departureTime,
      waypoints: waypoints ?? this.waypoints,
      selectedVehicleId: selectedVehicleId ?? this.selectedVehicleId,
      availableSeats: availableSeats ?? this.availableSeats,
      pricePerSeatInCents: pricePerSeatInCents ?? this.pricePerSeatInCents,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
      recurringEndDate: recurringEndDate == _sentinel
          ? this.recurringEndDate
          : recurringEndDate as DateTime?,
      allowPets: allowPets ?? this.allowPets,
      allowSmoking: allowSmoking ?? this.allowSmoking,
      allowLuggage: allowLuggage ?? this.allowLuggage,
      isWomenOnly: isWomenOnly ?? this.isWomenOnly,
      eventId: eventId == _sentinel ? this.eventId : eventId as String?,
      eventName: eventName == _sentinel ? this.eventName : eventName as String?,
      selectedEvent: selectedEvent == _sentinel
          ? this.selectedEvent
          : selectedEvent as EventModel?,
      isLoadingSelectedEvent:
          isLoadingSelectedEvent ?? this.isLoadingSelectedEvent,
      osrmRoutePoints: osrmRoutePoints ?? this.osrmRoutePoints,
      isLoadingRoute: isLoadingRoute ?? this.isLoadingRoute,
      routeDistanceKm: routeDistanceKm == _sentinel
          ? this.routeDistanceKm
          : routeDistanceKm as double?,
      routeDurationMinutes: routeDurationMinutes == _sentinel
          ? this.routeDurationMinutes
          : routeDurationMinutes as int?,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: submissionError == _sentinel
          ? this.submissionError
          : submissionError as String?,
      existingRideId: existingRideId ?? this.existingRideId,
    );
  }

  /// Returns the combined departure DateTime, or null if incomplete
  DateTime? get fullDepartureDateTime {
    if (departureDate == null || departureTime == null) return null;
    return DateTime(
      departureDate!.year,
      departureDate!.month,
      departureDate!.day,
      departureTime!.hour,
      departureTime!.minute,
    );
  }

  /// Validation: check if locations are identical
  bool get hasSameOriginAndDestination {
    if (fromLocation == null || toLocation == null) return false;
    return fromLocation!.latitude == toLocation!.latitude &&
        fromLocation!.longitude == toLocation!.longitude;
  }

  /// Check if basic route data is complete
  bool get hasCompleteRoute =>
      fromLocation != null &&
      toLocation != null &&
      !hasSameOriginAndDestination;

  /// Check if date/time is complete
  bool get hasCompleteDateTime => fullDepartureDateTime != null;

  /// Validation: seats must be at least 1
  bool get hasValidSeats => availableSeats >= 1 && availableSeats <= 8;

  // R-12: Currency-aware minimum prices (approx. equivalent of €1).
  static const _minPriceEur = 1.0;

  /// Validation: price must be at least €1.
  bool get hasValidPrice => pricePerSeatInCents >= (_minPriceEur * 100);

  /// Validation: recurring config is consistent
  bool get hasValidRecurring =>
      !isRecurring || (recurringDays.isNotEmpty && recurringEndDate != null);

  /// Check if form is complete enough to submit
  bool get canSubmit =>
      hasCompleteRoute &&
      hasCompleteDateTime &&
      selectedVehicleId != null &&
      selectedEvent != null &&
      hasValidSeats &&
      hasValidPrice &&
      hasValidRecurring &&
      !isSubmitting;

  /// Human-readable reason why submission is blocked
  String? get submissionBlockReason {
    if (isSubmitting) return 'Submitting ride, please wait...';
    if (fromLocation == null || toLocation == null) {
      return 'Please set origin and destination in Step 1';
    }
    if (hasSameOriginAndDestination) {
      return 'Origin and destination cannot be the same location';
    }
    if (departureDate == null || departureTime == null) {
      return 'Please set a departure date and time in Step 1';
    }
    final departure = fullDepartureDateTime!;
    if (departure.isBefore(DateTime.now())) {
      return 'Departure time must be in the future — go back to Step 1';
    }
    final minutesUntilDeparture = departure
        .difference(DateTime.now())
        .inMinutes;
    if (minutesUntilDeparture < 15) {
      return 'Departure must be at least 15 minutes from now';
    }
    // FIX R-14: Cap advance booking at 90 days to prevent rides set years
    // in the future from polluting search results.
    const maxAdvanceDays = 90;
    if (departure.difference(DateTime.now()).inDays > maxAdvanceDays) {
      return 'Departure cannot be more than $maxAdvanceDays days in the future';
    }
    if (selectedVehicleId == null) {
      return 'Please select a vehicle in Step 2';
    }
    if (selectedEvent == null) {
      return 'Please select an event for this ride';
    }
    if (!hasValidSeats) {
      return 'Number of seats must be between 1 and 8 — go back to Step 2';
    }
    if (!hasValidPrice) {
      return 'Price per seat must be at least €${_minPriceEur.toStringAsFixed(0)} — go back to Step 2';
    }
    if (isRecurring && recurringDays.isEmpty) {
      return 'Please select at least one recurring day';
    }
    if (isRecurring && recurringEndDate == null) {
      return 'Please set a recurring end date';
    }
    return null;
  }
}

@riverpod
class DriverOfferRideViewModel extends _$DriverOfferRideViewModel {
  @override
  DriverOfferRideFormState build() => const DriverOfferRideFormState();

  // --- Step Management ---
  void setStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  // --- Route (Step 1) ---
  void setFromLocation(LocationPoint location, String address) {
    state = state.copyWith(fromLocation: location, fromAddress: address);
    _triggerRoutePreview();
  }

  void setToLocation(LocationPoint location, String address) {
    state = state.copyWith(toLocation: location, toAddress: address);
    _triggerRoutePreview();
  }

  void swapLocations() {
    state = state.copyWith(
      fromLocation: state.toLocation,
      fromAddress: state.toAddress,
      toLocation: state.fromLocation,
      toAddress: state.fromAddress,
    );
    _triggerRoutePreview();
  }

  void setDepartureDate(DateTime date) {
    state = state.copyWith(departureDate: date);
  }

  void setDepartureTime(TimeOfDay time) {
    state = state.copyWith(departureTime: time);
  }

  void setWaypoints(List<LocationPoint> waypoints) {
    state = state.copyWith(waypoints: waypoints);
    _triggerRoutePreview();
  }

  void addWaypoint(LocationPoint waypoint) {
    final updated = [...state.waypoints, waypoint];
    state = state.copyWith(waypoints: updated);
    _triggerRoutePreview();
  }

  void removeWaypoint(int index) {
    final updated = List<LocationPoint>.from(state.waypoints)..removeAt(index);
    state = state.copyWith(waypoints: updated);
    _triggerRoutePreview();
  }

  // --- Details (Step 2) ---
  void setVehicle(String vehicleId) {
    state = state.copyWith(selectedVehicleId: vehicleId);
  }

  void setVehicleModel(VehicleModel vehicle) {
    state = state.copyWith(
      selectedVehicleId: vehicle.id,
      availableSeats: state.availableSeats.clamp(1, vehicle.capacity),
    );
  }

  void setSeats(int seats) {
    // Clamp to valid range
    final clamped = seats.clamp(1, 8);
    state = state.copyWith(availableSeats: clamped);
  }

  void setPrice(int priceInCents) {
    // Ensure minimum price
    final clamped = priceInCents < 100 ? 100 : priceInCents;
    state = state.copyWith(pricePerSeatInCents: clamped);
  }

  void setRecurring(bool recurring) {
    if (recurring) {
      // Default end date: 4 weeks from departure (or 4 weeks from now)
      final baseDate = state.departureDate ?? DateTime.now();
      state = state.copyWith(
        isRecurring: true,
        recurringEndDate:
            state.recurringEndDate ?? baseDate.add(const Duration(days: 28)),
      );
    } else {
      state = state.copyWith(
        isRecurring: false,
        recurringDays: const [],
        recurringEndDate: null,
      );
    }
  }

  void setRecurringDays(List<int> days) {
    state = state.copyWith(recurringDays: days);
  }

  void setRecurringEndDate(DateTime? endDate) {
    state = state.copyWith(recurringEndDate: endDate);
  }

  // --- Preferences (Step 3) ---
  void setAllowPets(bool allow) {
    state = state.copyWith(allowPets: allow);
  }

  void setAllowSmoking(bool allow) {
    state = state.copyWith(allowSmoking: allow);
  }

  void setAllowLuggage(bool allow) {
    state = state.copyWith(allowLuggage: allow);
  }

  void setWomenOnly(bool womenOnly) {
    state = state.copyWith(isWomenOnly: womenOnly);
  }

  // --- Event ---
  void setEvent(EventModel event) {
    state = state.copyWith(
      eventId: event.id,
      eventName: event.title,
      selectedEvent: event,
      isLoadingSelectedEvent: false,
      toLocation: event.location,
      toAddress: event.location.address,
    );
    _triggerRoutePreview();
  }

  void clearEvent() {
    state = state.copyWith(
      eventId: null,
      eventName: null,
      selectedEvent: null,
      toLocation: null,
      toAddress: '',
    );
  }

  Future<void> loadSelectedEvent(String eventId) async {
    if (state.isLoadingSelectedEvent || state.selectedEvent?.id == eventId) {
      return;
    }

    state = state.copyWith(isLoadingSelectedEvent: true);
    try {
      final event = await ref
          .read(eventRepositoryProvider)
          .getEventById(eventId);
      if (!ref.mounted) return;
      state = state.copyWith(
        selectedEvent: event,
        eventId: event?.id ?? state.eventId,
        eventName: event?.title ?? state.eventName,
        isLoadingSelectedEvent: false,
      );
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingSelectedEvent: false);
    }
  }

  // --- Route Preview ---
  Future<void> _triggerRoutePreview() async {
    if (state.fromLocation == null || state.toLocation == null) {
      state = state.copyWith();
      return;
    }

    if (state.isLoadingRoute) return;

    state = state.copyWith(isLoadingRoute: true);

    try {
      final origin = LatLng(
        state.fromLocation!.latitude,
        state.fromLocation!.longitude,
      );
      final dest = LatLng(
        state.toLocation!.latitude,
        state.toLocation!.longitude,
      );

      final waypoints = state.waypoints.isNotEmpty
          ? state.waypoints
                .map((wp) => LatLng(wp.latitude, wp.longitude))
                .toList()
          : null;

      final routeInfo = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: origin,
            destination: dest,
            waypoints: waypoints,
          );

      if (!ref.mounted) return;

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        isLoadingRoute: false,
        routeDistanceKm: routeInfo?.distanceKm,
        routeDurationMinutes: routeInfo?.durationMinutes.round(),
      );
    } on Exception {
      // Fallback: no route preview, just reset loading state
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingRoute: false);
    }
  }

  // --- Initialization (Edit Mode) ---
  void initializeFromExistingRide(RideModel ride) {
    state = DriverOfferRideFormState(
      existingRideId: ride.id,
      fromLocation: ride.route.origin,
      fromAddress: ride.route.origin.address,
      toLocation: ride.route.destination,
      toAddress: ride.route.destination.address,
      departureDate: ride.schedule.departureTime,
      departureTime: TimeOfDay.fromDateTime(ride.schedule.departureTime),
      waypoints: ride.route.waypoints.map((wp) => wp.location).toList(),
      selectedVehicleId: ride.vehicleId,
      availableSeats: ride.capacity.available,
      pricePerSeatInCents: ride.pricing.pricePerSeatInCents,
      isRecurring: ride.schedule.isRecurring,
      recurringDays: ride.schedule.recurringDays,
      recurringEndDate: ride.schedule.recurringEndDate,
      allowPets: ride.preferences.allowPets,
      allowSmoking: ride.preferences.allowSmoking,
      allowLuggage: ride.preferences.allowLuggage,
      isWomenOnly: ride.preferences.isWomenOnly,
      eventId: ride.eventId,
      eventName: ride.eventName,
      routeDistanceKm: ride.route.distanceKm,
      routeDurationMinutes: ride.route.durationMinutes,
    );
    _triggerRoutePreview();
  }

  void initializeFromPrefill(DriverRidePrefill prefill) {
    state = state.copyWith(
      eventId: prefill.eventId,
      eventName: prefill.eventName,
      fromLocation: prefill.origin,
      fromAddress: prefill.origin?.address,
      toLocation: prefill.destination,
      toAddress: prefill.destination?.address,
    );
    if (prefill.origin != null && prefill.destination != null) {
      _triggerRoutePreview();
    }
  }

  // --- Submission ---
  // FIX R-15: Track the last successful submission timestamp so that a very
  // fast double-tap cannot create duplicate rides even if isSubmitting is
  // cleared briefly between the two taps.
  DateTime? _lastSubmittedAt;

  Future<String?> submitRide(String driverId) async {
    // Guard against duplicate submissions — primary check
    if (state.isSubmitting) return null;

    // Secondary guard: reject if last submission was < 3 seconds ago
    final now = DateTime.now();
    if (_lastSubmittedAt != null &&
        now.difference(_lastSubmittedAt!).inSeconds < 3) {
      return null;
    }

    // Validate before submission
    if (!state.canSubmit || state.submissionBlockReason != null) {
      state = state.copyWith(
        submissionError: state.submissionBlockReason ?? 'Form is incomplete',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true);
    _lastSubmittedAt = now;

    try {
      final departure = state.fullDepartureDateTime;

      if (state.selectedEvent == null || state.eventId == null) {
        state = state.copyWith(
          isSubmitting: false,
          submissionError: 'Please select an event for this ride',
        );
        return null;
      }

      // Resolve vehicle info for denormalization on the ride document
      String? vehicleInfo;
      final tags = <String>[];
      if (state.selectedVehicleId != null) {
        final vehicle = await ref
            .read(vehicleRepositoryProvider)
            .getVehicleById(state.selectedVehicleId!);
        if (!ref.mounted) {
          state = state.copyWith(isSubmitting: false);
          return null;
        }
        // VE-2: Confirm the vehicle still exists and belongs to this driver.
        if (vehicle == null) {
          state = state.copyWith(
            isSubmitting: false,
            submissionError:
                'The selected vehicle no longer exists. Please choose another vehicle.',
          );
          return null;
        }
        if (vehicle.ownerId != driverId) {
          state = state.copyWith(
            isSubmitting: false,
            submissionError:
                'The selected vehicle does not belong to your account.',
          );
          return null;
        }
        vehicleInfo = vehicle.fullDisplayName;
      }

      // When editing, preserve the existing booked count and bookingIds
      var existingBooked = 0;
      var existingBookingIds = <String>[];
      if (state.existingRideId != null) {
        final existing = await ref
            .read(rideRepositoryProvider)
            .getRideById(state.existingRideId!);
        if (!ref.mounted) {
          state = state.copyWith(isSubmitting: false);
          return null;
        }
        if (existing != null) {
          existingBooked = existing.capacity.booked;
          existingBookingIds = existing.bookingIds;
        }
      }

      final ride = RideModel(
        id: state.existingRideId ?? const Uuid().v4(),
        driverId: driverId,
        route: RideRoute(
          origin: state.fromLocation!,
          destination: state.toLocation!,
          waypoints: state.waypoints
              .asMap()
              .entries
              .map((e) => RouteWaypoint(location: e.value, order: e.key))
              .toList(),
          distanceKm: state.routeDistanceKm,
          durationMinutes: state.routeDurationMinutes,
        ),
        schedule: RideSchedule(
          departureTime: departure!,
          isRecurring: state.isRecurring,
          recurringDays: state.recurringDays,
          recurringEndDate: state.recurringEndDate,
        ),
        capacity: RideCapacity(
          available: state.availableSeats,
          booked: existingBooked,
        ),
        bookingIds: existingBookingIds,
        pricing: RidePricing(
          pricePerSeatInCents: state.pricePerSeatInCents,
        ),
        preferences: RidePreferences(
          allowPets: state.allowPets,
          allowSmoking: state.allowSmoking,
          allowLuggage: state.allowLuggage,
          isWomenOnly: state.isWomenOnly,
        ),
        eventId: state.eventId,
        eventName: state.eventName,
        status: RideStatus.active,
        createdAt: DateTime.now(),
        vehicleId: state.selectedVehicleId,
        vehicleInfo: vehicleInfo,
        tags: tags,
      );

      final isEditing = state.existingRideId != null;
      final String rideId;

      if (isEditing) {
        await ref.read(rideServiceProvider.notifier).updateRide(ride);
        rideId = ride.id;
      } else {
        rideId = await ref.read(rideServiceProvider.notifier).createRide(ride);
        if (!ref.mounted) {
          state = state.copyWith(isSubmitting: false);
          return rideId;
        }
        final rideName =
            '${ride.route.origin.shortDisplay} → ${ride.route.destination.shortDisplay}';
        await ref
            .read(chatRepositoryProvider)
            .createRideChat(
              rideId: rideId,
              driverId: driverId,
              driverName:
                  ref.read(currentUserProvider).value?.username ?? driverId,
              rideName: rideName,
            );
      }

      if (!ref.mounted) return rideId;

      state = state.copyWith(isSubmitting: false);
      return rideId;
    } on Exception catch (e) {
      if (!ref.mounted) return null;
      state = state.copyWith(
        isSubmitting: false,
        submissionError: e.toString(),
      );
      return null;
    }
  }

  /// Reset the form to initial state
  void reset() {
    state = const DriverOfferRideFormState();
  }

  /// Clear submission error
  void clearSubmissionError() {
    state = state.copyWith(submissionError: null);
  }
}
