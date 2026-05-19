import 'dart:async' show StreamSubscription, unawaited;

import 'package:geolocator/geolocator.dart' show Position;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/services/location_service.dart';

part 'driver_location_view_model.g.dart';

class DriverLocationState {
  const DriverLocationState({
    this.isLoading = true,
    this.hasInitialized = false,
    this.locationGranted = false,
    this.locationDenied = false,
    this.locationDeniedForever = false,
    this.servicesDisabled = false,
    this.currentPosition,
    this.errorMessage,
  });
  final bool isLoading;
  final bool hasInitialized;
  final bool locationGranted;
  final bool locationDenied;
  final bool locationDeniedForever;
  final bool servicesDisabled;
  final Position? currentPosition;
  final String? errorMessage;

  DriverLocationState copyWith({
    bool? isLoading,
    bool? hasInitialized,
    bool? locationGranted,
    bool? locationDenied,
    bool? locationDeniedForever,
    bool? servicesDisabled,
    Position? currentPosition,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverLocationState(
      isLoading: isLoading ?? this.isLoading,
      hasInitialized: hasInitialized ?? this.hasInitialized,
      locationGranted: locationGranted ?? this.locationGranted,
      locationDenied: locationDenied ?? this.locationDenied,
      locationDeniedForever:
          locationDeniedForever ?? this.locationDeniedForever,
      servicesDisabled: servicesDisabled ?? this.servicesDisabled,
      currentPosition: currentPosition ?? this.currentPosition,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class DriverLocationViewModel extends _$DriverLocationViewModel {
  StreamSubscription<Position>? _positionSubscription;
  Future<void>? _initializeOperation;
  Future<void>? _permissionOperation;

  @override
  DriverLocationState build() {
    ref.onDispose(() => _positionSubscription?.cancel());
    return const DriverLocationState();
  }

  Future<void> initialize({bool force = false}) {
    if (state.hasInitialized && !force) return Future.value();
    final existing = _initializeOperation;
    if (existing != null) return existing;
    final op = _runInitialize(force: force);
    _initializeOperation = op;
    return op.whenComplete(() {
      if (identical(_initializeOperation, op)) _initializeOperation = null;
    });
  }

  Future<void> _runInitialize({required bool force}) async {
    await Future<void>.value();
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final svc = ref.read(locationServiceProvider);
      final servicesEnabled = await svc.isServiceEnabled();
      if (!ref.mounted) return;

      if (!servicesEnabled) {
        state = state.copyWith(
          isLoading: false,
          hasInitialized: true,
          servicesDisabled: true,
          locationGranted: false,
          locationDenied: false,
          locationDeniedForever: false,
        );
        return;
      }

      final permanentlyDenied = await svc.isPermissionPermanentlyDenied();
      final granted = !permanentlyDenied && await svc.checkPermission();
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        servicesDisabled: false,
        locationGranted: granted,
        locationDenied: false,
        locationDeniedForever: permanentlyDenied,
      );

      if (granted) {
        await _fetchCurrentPosition();
        if (!ref.mounted) return;
        _startLocationTracking();
      }
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        errorMessage: 'location-init-failed',
      );
    }
  }

  Future<void> requestPermission() {
    final existing = _permissionOperation;
    if (existing != null) return existing;
    final op = _runRequestPermission();
    _permissionOperation = op;
    return op.whenComplete(() {
      if (identical(_permissionOperation, op)) _permissionOperation = null;
    });
  }

  Future<void> _runRequestPermission() async {
    await Future<void>.value();
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final svc = ref.read(locationServiceProvider);
      final servicesEnabled = await svc.isServiceEnabled();
      if (!ref.mounted) return;

      if (!servicesEnabled) {
        state = state.copyWith(
          isLoading: false,
          hasInitialized: true,
          servicesDisabled: true,
          locationGranted: false,
          locationDenied: false,
        );
        return;
      }

      final granted = await svc.requestPermission();
      if (!ref.mounted) return;
      final permanentlyDenied = await svc.isPermissionPermanentlyDenied();
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        locationGranted: granted,
        locationDenied: !granted && !permanentlyDenied,
        servicesDisabled: false,
        locationDeniedForever: permanentlyDenied && !granted,
      );

      if (granted) {
        await _fetchCurrentPosition();
        if (!ref.mounted) return;
        _startLocationTracking();
      }
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        hasInitialized: true,
        errorMessage: 'location-request-failed',
      );
    }
  }

  Future<void> _fetchCurrentPosition() async {
    final position = await ref
        .read(locationServiceProvider)
        .getCurrentLocation();
    if (!ref.mounted || position == null) return;
    state = state.copyWith(
      currentPosition: position,
      locationGranted: true,
      locationDenied: false,
      servicesDisabled: false,
    );
  }

  void _startLocationTracking() {
    unawaited(_positionSubscription?.cancel());
    _positionSubscription = ref
        .read(locationServiceProvider)
        .getLocationStream()
        .listen(
          (position) {
            if (!ref.mounted) return;
            state = state.copyWith(
              currentPosition: position,
              locationGranted: true,
            );
          },
          onError: (Object _) {
            if (!ref.mounted) return;
            state = state.copyWith(errorMessage: 'location-stream-failed');
          },
        );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
