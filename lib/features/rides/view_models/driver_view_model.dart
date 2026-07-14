import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';
import 'package:sport_connect/features/rides/services/ride_request_service.dart';

part 'driver_view_model.g.dart';

@riverpod
Stream<RideModel?> activeDriverRide(Ref ref) async* {
  // 1. Watch the auth state. Using valueOrNull is cleaner in 3.0.
  final userId = await ref.watch(currentAuthUidProvider.future);

  if (userId == null) {
    yield null;
    return;
  }

  // 2. Watch the repository to ensure we react to any config changes.
  final repository = ref.watch(rideRepositoryProvider);

  yield* repository.streamRidesByDriver(userId).map((rides) {
    // 3. Use 'where' and 'fold' for a more declarative approach.
    return rides
        .where((ride) => ride.status == RideStatus.inProgress)
        .fold<RideModel?>(null, (active, ride) {
          if (active == null) return ride;

          final currentTs =
              active.updatedAt ?? active.createdAt ?? active.departureTime;
          final nextTs = ride.updatedAt ?? ride.createdAt ?? ride.departureTime;

          return nextTs.isAfter(currentTs) ? ride : active;
        });
  });
}

@riverpod
Stream<List<RideModel>> pastDriverRides(Ref ref) {
  final authUid = ref.watch(currentAuthUidProvider);

  return authUid.when(
    data: (userId) {
      if (userId == null) return Stream.value([]);

      return ref
          .watch(rideRepositoryProvider)
          .streamRidesByDriver(userId)
          .map(
            (rides) => rides
                .where(
                  (r) =>
                      r.status == RideStatus.completed ||
                      r.status == RideStatus.cancelled,
                )
                .toList(),
          );
    },
    loading: () => const Stream.empty(),
    error: (_, _) => const Stream.empty(),
  );
}

/// Aggregated dashboard state owned entirely by [DriverViewModel].
class DriverState {
  const DriverState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.lastStatusChange,
    this.lastRefreshAt,
    this.pendingRequestActionIds = const <String>{},
    this.activeRideAsync = const AsyncLoading(),
    this.user = const AsyncLoading(),
    this.stats = const AsyncLoading(),
    this.pendingRequests = const AsyncLoading(),
    this.acceptedRequests = const AsyncLoading(),
    this.rejectedRequests = const AsyncLoading(),
    this.upcomingRides = const AsyncLoading(),
    this.earningsTransactions = const AsyncLoading(),
  });
  static const _unset = Object();

  // ── Action state ──────────────────────────────────────────────────────────
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final DateTime? lastStatusChange;
  final DateTime? lastRefreshAt;
  final Set<String> pendingRequestActionIds;

  // ── Derived from streams ──────────────────────────────────────────────────
  final AsyncValue<RideModel?> activeRideAsync;

  // ── Aggregated data ───────────────────────────────────────────────────────
  final AsyncValue<UserModel?> user;
  final AsyncValue<DriverStats> stats;

  /// Pending bookings waiting for driver action.
  final AsyncValue<List<RideBooking>> pendingRequests;

  /// Accepted bookings.
  final AsyncValue<List<RideBooking>> acceptedRequests;

  /// Rejected/cancelled bookings.
  final AsyncValue<List<RideBooking>> rejectedRequests;

  final AsyncValue<List<RideModel>> upcomingRides;
  final AsyncValue<List<EarningsTransaction>> earningsTransactions;

  UserModel? get currentUser => user is AsyncData<UserModel?>
      ? (user as AsyncData<UserModel?>).value
      : null;
  DriverStats? get currentStats => stats is AsyncData<DriverStats>
      ? (stats as AsyncData<DriverStats>).value
      : null;
  RideModel? get activeRide => activeRideAsync is AsyncData<RideModel?>
      ? (activeRideAsync as AsyncData<RideModel?>).value
      : null;
  bool get hasActiveRide => activeRide != null;
  bool get hasProfileData => currentUser != null;

  List<RideBooking> get pendingRequestPreview =>
      (pendingRequests is AsyncData<List<RideBooking>>
              ? (pendingRequests as AsyncData<List<RideBooking>>).value
              : const <RideBooking>[])
          .take(2)
          .toList(growable: false);

  List<RideModel> get upcomingRidePreview =>
      (upcomingRides is AsyncData<List<RideModel>>
              ? (upcomingRides as AsyncData<List<RideModel>>).value
              : const <RideModel>[])
          .take(3)
          .toList(growable: false);

  int get pendingRequestCount => pendingRequests is AsyncData<List<RideBooking>>
      ? (pendingRequests as AsyncData<List<RideBooking>>).value.length
      : 0;
  bool get hasPendingRequests => pendingRequestCount > 0;
  bool get hasUpcomingRides =>
      upcomingRides is AsyncData<List<RideModel>> &&
      (upcomingRides as AsyncData<List<RideModel>>).value.isNotEmpty;
  bool isRequestActionInProgress(String bookingId) =>
      pendingRequestActionIds.contains(bookingId);

  DriverState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    Object? errorMessage = _unset,
    DateTime? lastStatusChange,
    DateTime? lastRefreshAt,
    Set<String>? pendingRequestActionIds,
    AsyncValue<RideModel?>? activeRideAsync,
    AsyncValue<UserModel?>? user,
    AsyncValue<DriverStats>? stats,
    AsyncValue<List<RideBooking>>? pendingRequests,
    AsyncValue<List<RideBooking>>? acceptedRequests,
    AsyncValue<List<RideBooking>>? rejectedRequests,
    AsyncValue<List<RideModel>>? upcomingRides,
    AsyncValue<List<EarningsTransaction>>? earningsTransactions,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      lastStatusChange: lastStatusChange ?? this.lastStatusChange,
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      pendingRequestActionIds:
          pendingRequestActionIds ?? this.pendingRequestActionIds,
      activeRideAsync: activeRideAsync ?? this.activeRideAsync,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      acceptedRequests: acceptedRequests ?? this.acceptedRequests,
      rejectedRequests: rejectedRequests ?? this.rejectedRequests,
      upcomingRides: upcomingRides ?? this.upcomingRides,
      earningsTransactions: earningsTransactions ?? this.earningsTransactions,
    );
  }
}

/// ViewModel for all driver dashboard screens.
@riverpod
class DriverViewModel extends _$DriverViewModel {
  Future<void>? _refreshOperation;

  @override
  DriverState build() {
    ref.listen(currentUserProvider, (_, next) {
      state = state.copyWith(user: next);
    });
    ref.listen(driverStatsProvider, (_, next) {
      state = state.copyWith(stats: next);
    });
    ref.listen(pendingRideRequestsProvider, (_, next) {
      state = state.copyWith(pendingRequests: next);
    });
    ref.listen(acceptedRideRequestsProvider, (_, next) {
      state = state.copyWith(acceptedRequests: next);
    });
    ref.listen(rejectedRideRequestsProvider, (_, next) {
      state = state.copyWith(rejectedRequests: next);
    });
    ref.listen(upcomingDriverRidesProvider, (_, next) {
      state = state.copyWith(upcomingRides: next);
    });
    ref.listen(earningsTransactionsProvider, (_, next) {
      state = state.copyWith(earningsTransactions: next);
    });
    ref.listen(activeDriverRideProvider, (_, next) {
      state = state.copyWith(activeRideAsync: next);
    });

    return DriverState(
      user: ref.read(currentUserProvider),
      stats: ref.read(driverStatsProvider),
      activeRideAsync: ref.read(activeDriverRideProvider),
      pendingRequests: ref.read(pendingRideRequestsProvider),
      acceptedRequests: ref.read(acceptedRideRequestsProvider),
      rejectedRequests: ref.read(rejectedRideRequestsProvider),
      upcomingRides: ref.read(upcomingDriverRidesProvider),
      earningsTransactions: ref.read(earningsTransactionsProvider),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  Future<void> refresh() {
    final existingOperation = _refreshOperation;
    if (existingOperation != null) return existingOperation;

    final refreshOperation = _runRefresh();
    _refreshOperation = refreshOperation;
    return refreshOperation.whenComplete(() {
      if (identical(_refreshOperation, refreshOperation)) {
        _refreshOperation = null;
      }
    });
  }

  Future<void> _runRefresh() async {
    if (!ref.mounted) return;

    state = state.copyWith(isRefreshing: true, errorMessage: null);

    try {
      await Future.wait<void>([
        ref.refresh(currentUserProvider.future),
        ref.refresh(driverStatsProvider.future),
        ref.refresh(activeDriverRideProvider.future),
        ref.refresh(pendingRideRequestsProvider.future),
        ref.refresh(acceptedRideRequestsProvider.future),
        ref.refresh(rejectedRideRequestsProvider.future),
        ref.refresh(upcomingDriverRidesProvider.future),
        ref.refresh(earningsTransactionsProvider.future),
      ]);

      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        lastRefreshAt: DateTime.now(),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Failed to refresh dashboard: $e',
      );
    }
  }

  /// Accept a pending booking.
  Future<bool> acceptRideRequest(String rideId, String bookingId) async {
    if (rideId.isEmpty || bookingId.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing booking data.');
      return false;
    }
    if (state.pendingRequestActionIds.contains(bookingId)) return false;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pendingRequestActionIds: {...state.pendingRequestActionIds, bookingId},
    );

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .acceptRequest(bookingId);

      if (!ref.mounted) return false;

      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(bookingId),
      );
      ref.invalidate(pendingRideRequestsProvider);
      ref.invalidate(acceptedRideRequestsProvider);
      ref.invalidate(upcomingDriverRidesProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(bookingId),
        errorMessage: 'Failed to accept booking: $e',
      );
      return false;
    }
  }

  /// Decline a pending booking.
  Future<bool> declineRideRequest(String rideId, String bookingId) async {
    if (rideId.isEmpty || bookingId.isEmpty) {
      state = state.copyWith(errorMessage: 'Missing booking data.');
      return false;
    }
    if (state.pendingRequestActionIds.contains(bookingId)) return false;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      pendingRequestActionIds: {...state.pendingRequestActionIds, bookingId},
    );

    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .rejectRequest(bookingId, 'Declined by driver');

      if (!ref.mounted) return false;

      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(bookingId),
      );
      ref.invalidate(pendingRideRequestsProvider);
      ref.invalidate(rejectedRideRequestsProvider);

      return switch (result) {
        Success() => true,
        Failure(:final message) => throw Exception(message),
      };
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        isLoading: false,
        pendingRequestActionIds: {...state.pendingRequestActionIds}
          ..remove(bookingId),
        errorMessage: 'Failed to decline booking: $e',
      );
      return false;
    }
  }
}
