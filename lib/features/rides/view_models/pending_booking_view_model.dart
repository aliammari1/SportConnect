import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/services/stripe_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/features/payments/view_models/payment_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

part 'pending_booking_view_model.g.dart';

enum PendingBookingEffectType {
  navigateCountdown,
  navigateMyRides,
  navigateActiveRide,
  snackbar,
}

@immutable
class PendingBookingEffect {
  const PendingBookingEffect._({
    required this.type,
    this.bookingId,
    this.message,
  });

  const PendingBookingEffect.navigateCountdown(String bookingId)
    : this._(
        type: PendingBookingEffectType.navigateCountdown,
        bookingId: bookingId,
      );

  const PendingBookingEffect.navigateMyRides({String? message})
    : this._(type: PendingBookingEffectType.navigateMyRides, message: message);

  const PendingBookingEffect.navigateActiveRide(String rideId)
    : this._(
        type: PendingBookingEffectType.navigateActiveRide,
        bookingId: rideId,
      );

  const PendingBookingEffect.snackbar(String message)
    : this._(type: PendingBookingEffectType.snackbar, message: message);

  final PendingBookingEffectType type;
  final String? bookingId;
  final String? message;
}

@immutable
class PendingBookingState {
  const PendingBookingState({
    required this.rideId,
    this.currentUserId,
    this.rideAsync = const AsyncValue.loading(),
    this.bookingData,
    this.expiresAt,
    this.timeRemaining = Duration.zero,
    this.isProcessingPayment = false,
    this.isCancelling = false,
    this.paymentFailed = false,
    this.paymentSubmittedIntentId,
    this.lastError,
    this.osrmRoutePoints,
    this.loadedRouteKey,
    this.loadingRouteKey,
    this.isLoadingOsrmRoute = false,
  });

  static const _unset = Object();

  final String rideId;
  final String? currentUserId;
  final AsyncValue<RideModel?> rideAsync;
  final RideBooking? bookingData;
  final DateTime? expiresAt;
  final Duration timeRemaining;
  final bool isProcessingPayment;
  final bool isCancelling;
  final bool paymentFailed;

  /// The paymentIntentId of a charge that has been captured client-side but
  /// whose `paidAt` has not yet been written by the Stripe webhook. While set,
  /// the Complete Payment CTA is suppressed so the user is not asked to pay
  /// again (and does not perceive a double charge) in the window between charge
  /// capture and webhook delivery. Cleared once the streamed booking confirms
  /// payment (paidAt != null) or carries the matching paymentIntentId.
  final String? paymentSubmittedIntentId;

  final String? lastError;
  final List<LatLng>? osrmRoutePoints;
  final String? loadedRouteKey;
  final String? loadingRouteKey;
  final bool isLoadingOsrmRoute;

  RideModel? get ride => rideAsync.value;
  RideBooking? get booking => bookingData;

  bool get isAcceptedNeedsPayment =>
      booking?.status == BookingStatus.accepted &&
      booking?.paidAt == null &&
      // Suppress the CTA once a charge has been captured for this booking,
      // independent of the streamed paidAt (written asynchronously by the
      // Stripe webhook). Avoids re-showing "Complete Payment" / a perceived
      // double charge between capture and webhook delivery.
      paymentSubmittedIntentId == null;

  bool get isPending => booking?.status == BookingStatus.pending;

  bool get hasResolvableError =>
      paymentFailed || lastError != null || rideAsync.hasError;

  PendingBookingState copyWith({
    String? currentUserId,
    AsyncValue<RideModel?>? rideAsync,
    Object? bookingData = _unset,
    Object? expiresAt = _unset,
    Duration? timeRemaining,
    bool? isProcessingPayment,
    bool? isCancelling,
    bool? paymentFailed,
    Object? paymentSubmittedIntentId = _unset,
    Object? lastError = _unset,
    Object? osrmRoutePoints = _unset,
    Object? loadedRouteKey = _unset,
    Object? loadingRouteKey = _unset,
    bool? isLoadingOsrmRoute,
  }) {
    return PendingBookingState(
      rideId: rideId,
      currentUserId: currentUserId ?? this.currentUserId,
      rideAsync: rideAsync ?? this.rideAsync,
      bookingData: bookingData == _unset
          ? this.bookingData
          : bookingData as RideBooking?,
      expiresAt: expiresAt == _unset ? this.expiresAt : expiresAt as DateTime?,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      isCancelling: isCancelling ?? this.isCancelling,
      paymentFailed: paymentFailed ?? this.paymentFailed,
      paymentSubmittedIntentId: paymentSubmittedIntentId == _unset
          ? this.paymentSubmittedIntentId
          : paymentSubmittedIntentId as String?,
      lastError: lastError == _unset ? this.lastError : lastError as String?,
      osrmRoutePoints: osrmRoutePoints == _unset
          ? this.osrmRoutePoints
          : osrmRoutePoints as List<LatLng>?,
      loadedRouteKey: loadedRouteKey == _unset
          ? this.loadedRouteKey
          : loadedRouteKey as String?,
      loadingRouteKey: loadingRouteKey == _unset
          ? this.loadingRouteKey
          : loadingRouteKey as String?,
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
    );
  }
}

@riverpod
class PendingBookingViewModel extends _$PendingBookingViewModel {
  final Queue<PendingBookingEffect> _effects = Queue<PendingBookingEffect>();
  Timer? _countdownTimer;
  String? _lastLifecycleEffectKey;

  @override
  PendingBookingState build(String rideId) {
    final currentUserId = ref.watch(currentAuthUidProvider).value;
    final initialRideState = ref.watch(rideDetailViewModelProvider(rideId));
    final initialBookings = currentUserId == null
        ? const <RideBooking>[]
        : (ref.watch(
                bookingsByPassengerProvider(
                  currentUserId,
                ).select((a) => a.value),
              ) ??
              const <RideBooking>[]);
    final initialBooking = _latestBookingForRide(initialBookings, rideId);
    final initialExpiresAt = _deadlineFor(
      initialBooking,
      initialRideState.ride.value,
    );
    final initialTimeRemaining = initialExpiresAt == null
        ? Duration.zero
        : (() {
            final remaining = initialExpiresAt.difference(DateTime.now());
            return remaining.isNegative ? Duration.zero : remaining;
          })();

    ref.onDispose(() {
      _countdownTimer?.cancel();
    });

    ref.listen<RideDetailState>(
      rideDetailViewModelProvider(rideId),
      (_, next) => syncRideState(next),
    );
    ref.listen(paymentViewModelProvider, (_, _) {});
    if (currentUserId != null) {
      ref.listen<AsyncValue<List<RideBooking>>>(
        bookingsByPassengerProvider(currentUserId),
        (_, next) => syncPassengerBookings(next),
      );
    }

    if (initialBooking?.createdAt != null) {
      Future.microtask(() {
        if (!ref.mounted) return;
        _syncCountdown(initialBooking);
      });
    }

    final initialRide = initialRideState.ride.value;
    if (initialRide != null) {
      Future.microtask(() {
        if (!ref.mounted) return;
        unawaited(ensureOsrmRouteLoaded(initialRide));
      });
    }

    Future.microtask(() {
      if (!ref.mounted) return;
      _emitLifecycleEffects();
    });

    return PendingBookingState(
      rideId: rideId,
      currentUserId: currentUserId,
      rideAsync: initialRideState.ride,
      bookingData: initialBooking,
      expiresAt: initialExpiresAt,
      timeRemaining: initialTimeRemaining,
      lastError: initialRideState.ride.hasError
          ? initialRideState.ride.error.toString()
          : null,
    );
  }

  bool get hasPendingEffects => _effects.isNotEmpty;

  PendingBookingEffect? takeEffect() {
    if (_effects.isEmpty) return null;
    return _effects.removeFirst();
  }

  void syncRideState(RideDetailState rideState) {
    state = state.copyWith(
      rideAsync: rideState.ride,
      lastError: rideState.ride.hasError
          ? rideState.ride.error.toString()
          : state.lastError,
    );

    final ride = rideState.ride.value;
    if (ride != null) {
      unawaited(ensureOsrmRouteLoaded(ride));
      _syncCountdown(state.booking);
    }
    _emitLifecycleEffects();
  }

  void syncPassengerBookings(AsyncValue<List<RideBooking>> bookingsAsync) {
    final bookings = bookingsAsync.value;
    final matchingBooking = _latestBookingForRide(bookings, state.rideId);

    final previousDeadline = _deadlineFor(state.booking, state.rideAsync.value);

    // Clear the captured-charge suppression once the streamed booking confirms
    // payment server-side (paidAt written by the webhook) or carries the same
    // paymentIntentId we submitted. Otherwise keep suppressing the CTA.
    final submittedIntentId = state.paymentSubmittedIntentId;
    final paymentConfirmed =
        submittedIntentId != null &&
        matchingBooking != null &&
        (matchingBooking.paidAt != null ||
            matchingBooking.paymentIntentId == submittedIntentId);

    state = state.copyWith(
      bookingData: matchingBooking,
      paymentSubmittedIntentId: paymentConfirmed ? null : submittedIntentId,
      lastError: bookingsAsync.hasError
          ? bookingsAsync.error.toString()
          : state.lastError,
    );

    if (_deadlineFor(matchingBooking, state.rideAsync.value) !=
        previousDeadline) {
      _syncCountdown(matchingBooking);
    } else if (matchingBooking == null) {
      _stopCountdown();
    }

    _emitLifecycleEffects();
  }

  RideBooking? _latestBookingForRide(
    List<RideBooking>? bookings,
    String rideId,
  ) {
    final matches = bookings
        ?.where((booking) => booking.rideId == rideId)
        .toList(growable: false);
    if (matches == null || matches.isEmpty) {
      return null;
    }

    matches.sort((a, b) {
      final aTimestamp = a.createdAt ?? a.respondedAt ?? DateTime(1970);
      final bTimestamp = b.createdAt ?? b.respondedAt ?? DateTime(1970);
      return bTimestamp.compareTo(aTimestamp);
    });

    return matches.first;
  }

  Future<void> ensureOsrmRouteLoaded(RideModel ride) async {
    final routeKey = _routeKeyFor(ride);
    final alreadyLoaded =
        state.loadedRouteKey == routeKey && state.osrmRoutePoints != null;
    final isLoadingSameRoute =
        state.isLoadingOsrmRoute && state.loadingRouteKey == routeKey;
    if (alreadyLoaded || isLoadingSameRoute) {
      return;
    }

    state = state.copyWith(
      isLoadingOsrmRoute: true,
      loadingRouteKey: routeKey,
      osrmRoutePoints: state.loadedRouteKey == routeKey
          ? state.osrmRoutePoints
          : null,
      loadedRouteKey: state.loadedRouteKey == routeKey
          ? state.loadedRouteKey
          : null,
    );

    try {
      final waypoints = ride.route.waypoints
          .map(
            (waypoint) =>
                LatLng(waypoint.location.latitude, waypoint.location.longitude),
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

      if (!ref.mounted) {
        return;
      }

      if (state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    } catch (e, st) {
      TalkerService.error(
        'Error loading pending booking OSRM route',
        e,
        st,
      );
      if (!ref.mounted) {
        return;
      }

      if (state.loadingRouteKey != routeKey) {
        return;
      }

      state = state.copyWith(
        loadedRouteKey: routeKey,
        loadingRouteKey: null,
        isLoadingOsrmRoute: false,
      );
    }
  }

  Future<void> processPayment() async {
    if (state.isProcessingPayment || !state.isAcceptedNeedsPayment) {
      return;
    }

    final ride = state.ride;
    final booking = state.booking;
    if (ride == null || booking == null) {
      return;
    }

    state = state.copyWith(
      isProcessingPayment: true,
      paymentFailed: false,
      lastError: null,
    );

    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('User not found');
      }

      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );
      if (!ref.mounted) {
        return;
      }

      if (driverProfile == null) {
        throw Exception('Driver profile not found');
      }

      final driverModel = driverProfile.asDriver;
      if (driverModel == null) {
        throw Exception('Driver profile is not a driver account');
      }

      final driverStripeAccountId = driverModel.stripeAccountId;
      if (driverStripeAccountId == null || driverStripeAccountId.isEmpty) {
        throw StripePaymentException(
          'Driver has not set up payment processing yet.',
        );
      }

      final customerId = await ref
          .read(paymentViewModelProvider.notifier)
          .getOrCreateCustomer(
            userId: user.uid,
            email: user.email,
            name: user.username,
            phone: switch (user) {
              final RiderModel rider => rider.asRider?.phoneNumber,
              final DriverModel driver => driver.asDriver?.phoneNumber,
              _ => null,
            },
          );
      if (!ref.mounted) {
        return;
      }

      final totalAmount = ride.pricePerSeatInCents * booking.seatsBooked;
      final paymentData = await ref
          .read(stripeServiceProvider)
          .createPaymentIntent(
            rideId: ride.id,
            riderId: user.uid,
            riderName: user.username,
            driverId: ride.driverId,
            driverName: driverProfile.username,
            amountInCents: totalAmount,
            currency: 'eur',
            customerId: customerId,
            driverStripeAccountId: driverStripeAccountId,
            description: '${ride.origin.address} → ${ride.destination.address}',
          );
      if (!ref.mounted) {
        return;
      }

      final paymentSuccess = await ref
          .read(stripeServiceProvider)
          .processPaymentWithSheet(
            paymentIntentClientSecret: paymentData['clientSecret'] as String,
            customerId: customerId,
            ephemeralKeySecret: paymentData['ephemeralKey'] as String?,
          );
      if (!ref.mounted) {
        return;
      }

      if (!paymentSuccess) {
        state = state.copyWith(
          isProcessingPayment: false,
          paymentFailed: true,
          lastError: 'Payment cancelled.',
        );
        _enqueueEffect(
          const PendingBookingEffect.snackbar(
            'Payment cancelled. Tap "Complete Payment" to retry.',
          ),
        );
        return;
      }

      final paymentIntentId = paymentData['paymentIntentId'] as String;
      // The charge has been captured. Record the submitted intent id so the
      // Complete Payment CTA is suppressed regardless of streamed booking
      // state. Cleared in syncPassengerBookings once the stream confirms.
      state = state.copyWith(paymentSubmittedIntentId: paymentIntentId);
      var reconciled = true;
      try {
        if (!ref.mounted) {
          return;
        }

        // Stripe-authoritative reconciliation: stamps paidAt/paymentIntentId
        // immediately so no screen re-shows "Complete Payment" while waiting
        // for webhook delivery. The webhook remains the source for downstream
        // effects (driver balance, notifications).
        await ref
            .read(stripeServiceProvider)
            .verifyBookingPayment(
              bookingId: booking.id,
              paymentIntentId: paymentIntentId,
            );
      } catch (e, st) {
        // The Stripe charge has already been captured, but persisting the
        // captured paymentIntentId to the booking failed. Log for manual
        // reconciliation; never silently swallow it.
        reconciled = false;
        TalkerService.error(
          'Failed to mark booking paid after successful charge '
          '(captured paymentIntentId=$paymentIntentId, bookingId=${booking.id})',
          e,
          st,
        );
      }

      if (!ref.mounted) {
        return;
      }

      // Keep the captured paymentIntentId on the local booking either way so it
      // is available for audit/refund/retry. Do NOT synthesize paidAt locally —
      // it is owned by the Stripe webhook; the captured intent id (tracked via
      // paymentSubmittedIntentId) is what suppresses the Complete Payment CTA.
      final updatedBooking = booking.copyWith(
        paymentIntentId: paymentIntentId,
      );

      if (!reconciled) {
        // The charge succeeded (paymentFailed stays false) but the server-side
        // booking was not marked paid. Do NOT optimistically navigate away as
        // fully complete: surface a recoverable "finalizing" error so the user
        // can retry reconciliation instead of being asked to pay again.
        // Reconciliation explicitly failed, so allow the retry path to run by
        // clearing the submitted-intent suppression (the CTA must re-appear).
        state = state.copyWith(
          bookingData: updatedBooking,
          isProcessingPayment: false,
          paymentFailed: false,
          paymentSubmittedIntentId: null,
          lastError:
              'Payment received. Finalizing your booking failed — please tap '
              '"Complete Payment" again to retry (you will not be charged twice).',
        );
        _enqueueEffect(
          const PendingBookingEffect.snackbar(
            'Payment received. Finalizing your booking failed — tap '
            '"Complete Payment" to retry.',
          ),
        );
        return;
      }

      _lastLifecycleEffectKey =
          '${booking.id}|${BookingStatus.accepted.name}|$paymentIntentId';
      state = state.copyWith(
        bookingData: updatedBooking,
        isProcessingPayment: false,
        paymentFailed: false,
        lastError: null,
      );
      _enqueueEffect(PendingBookingEffect.navigateCountdown(booking.id));
    } on StripePaymentException catch (error) {
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        isProcessingPayment: false,
        paymentFailed: true,
        lastError: error.message,
      );
      _enqueueEffect(
        PendingBookingEffect.snackbar('Payment failed: ${error.message}'),
      );
    } catch (e, st) {
      TalkerService.error('Pending booking payment failed', e, st);
      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        isProcessingPayment: false,
        paymentFailed: true,
        lastError: e.toString(),
      );
      _enqueueEffect(PendingBookingEffect.snackbar('Payment error: $e'));
    }
  }

  Future<void> cancelBooking() async {
    if (state.isCancelling || !state.isPending) {
      return;
    }

    final booking = state.booking;
    if (booking == null) {
      return;
    }

    state = state.copyWith(isCancelling: true, lastError: null);

    try {
      await ref
          .read(rideActionsViewModelProvider.notifier)
          .cancelBooking(rideId: state.rideId, bookingId: booking.id);

      if (!ref.mounted) return;
      _lastLifecycleEffectKey =
          '${booking.id}|${BookingStatus.cancelled.name}|${booking.paymentIntentId ?? ''}';
      state = state.copyWith(
        bookingData: booking.copyWith(status: BookingStatus.cancelled),
        isCancelling: false,
      );
      _enqueueEffect(const PendingBookingEffect.navigateMyRides());
    } catch (e, st) {
      if (!ref.mounted) return;
      TalkerService.error(
        'Pending booking cancellation failed',
        e,
        st,
      );
      state = state.copyWith(isCancelling: false, lastError: e.toString());
      _enqueueEffect(
        const PendingBookingEffect.snackbar(
          'Failed to cancel. Please try again.',
        ),
      );
    }
  }

  void _emitLifecycleEffects() {
    // Check if the ride went inProgress — redirect to active ride screen
    final ride = state.ride;
    if (ride != null && ride.status == RideStatus.inProgress) {
      final booking = state.booking;
      final hasAcceptedBooking =
          booking != null && booking.status == BookingStatus.accepted;
      if (hasAcceptedBooking) {
        final effectKey = 'ride-started|${ride.id}';
        if (_lastLifecycleEffectKey != effectKey) {
          _lastLifecycleEffectKey = effectKey;
          _enqueueEffect(PendingBookingEffect.navigateActiveRide(ride.id));
          return;
        }
      }
    }

    final booking = state.booking;
    if (booking == null || state.isProcessingPayment) {
      return;
    }

    final effectKey =
        '${booking.id}|${booking.status.name}|${booking.paymentIntentId ?? ''}';
    if (_lastLifecycleEffectKey == effectKey) {
      return;
    }

    switch (booking.status) {
      case BookingStatus.accepted:
        if (state.isAcceptedNeedsPayment) {
          return;
        }
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(PendingBookingEffect.navigateCountdown(booking.id));
        return;
      case BookingStatus.rejected:
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(
          const PendingBookingEffect.snackbar(
            'Your booking was declined by the driver.',
          ),
        );
        _enqueueEffect(const PendingBookingEffect.navigateMyRides());
        return;
      case BookingStatus.cancelled:
        _lastLifecycleEffectKey = effectKey;
        _enqueueEffect(
          const PendingBookingEffect.snackbar('Booking has been cancelled.'),
        );
        _enqueueEffect(const PendingBookingEffect.navigateMyRides());
        return;
      case BookingStatus.pending:
      case BookingStatus.completed:
        return;
    }
  }

  DateTime? _deadlineFor(RideBooking? booking, RideModel? ride) {
    if (booking?.createdAt == null) return null;

    if (booking!.status != BookingStatus.accepted || ride == null) {
      return booking.createdAt!.add(const Duration(hours: 24));
    }

    final acceptedAt = booking.respondedAt ?? booking.createdAt!;
    final remainingUntilDeparture = ride.departureTime.difference(acceptedAt);
    final paymentWindow = switch (remainingUntilDeparture) {
      final value when value > const Duration(hours: 24) => const Duration(
        hours: 12,
      ),
      final value when value > const Duration(hours: 4) => const Duration(
        hours: 2,
      ),
      final value when value > const Duration(hours: 1) => const Duration(
        minutes: 30,
      ),
      _ => const Duration(minutes: 10),
    };

    final deadline = acceptedAt.add(paymentWindow);
    final finalCutoff = ride.departureTime.subtract(const Duration(minutes: 5));
    if (deadline.isAfter(finalCutoff)) return finalCutoff;
    return deadline;
  }

  void _syncCountdown(RideBooking? booking) {
    _countdownTimer?.cancel();

    final expiresAt = _deadlineFor(booking, state.rideAsync.value);
    if (expiresAt == null) {
      state = state.copyWith(expiresAt: null, timeRemaining: Duration.zero);
      return;
    }

    state = state.copyWith(expiresAt: expiresAt);
    _tickCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickCountdown();
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(expiresAt: null, timeRemaining: Duration.zero);
  }

  void _tickCountdown() {
    final expiresAt = state.expiresAt;
    if (expiresAt == null) {
      return;
    }

    final remaining = expiresAt.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _countdownTimer?.cancel();
      state = state.copyWith(timeRemaining: Duration.zero);
      return;
    }

    state = state.copyWith(timeRemaining: remaining);
  }

  void _enqueueEffect(PendingBookingEffect effect) {
    _effects.add(effect);
    // Trigger a state update to notify listeners
    state = state.copyWith();
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
}
