import 'package:latlong2/latlong.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/home/repositories/home_repository.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';

part 'home_view_model.g.dart';

/// State for the home screen.
///
/// All location/map/route state previously held here was dead code: the only
/// consumers ever read `homeViewModelProvider.select((s) => s.user)`, and the
/// notifier (and its mutating methods) was never accessed. The live
/// location/map/route logic lives in `RiderHomeViewModel`. This state is now
/// reduced to the single field that is actually consumed.
class HomeState {
  const HomeState({this.user = const AsyncLoading()});

  /// Current authenticated user.
  final AsyncValue<UserModel?> user;

  HomeState copyWith({AsyncValue<UserModel?>? user}) {
    return HomeState(user: user ?? this.user);
  }
}

/// ViewModel for the home screen.
///
/// Exposes the current authenticated user for the home surfaces. Map,
/// location and routing concerns are owned by `RiderHomeViewModel`.
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    ref.listen(currentUserProvider, (_, next) {
      state = state.copyWith(user: next);
    });

    return HomeState(user: ref.read(currentUserProvider));
  }
}

/// VM-layer stream provider for nearby rides (wraps home repository).
@riverpod
Stream<List<RideModel>> nearbyRidesStream(
  Ref ref,
  LatLng location,
  double radiusKm,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamNearbyRides(center: location, radiusKm: radiusKm);
}
