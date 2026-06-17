import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/map_service.dart';

/// A [TileLayer] that automatically uses the app-wide cached tile provider.
///
/// Drop-in replacement for bare [TileLayer] calls across all map screens.
/// Falls back to flutter_map's default [NetworkTileProvider] while the cache
/// store is initialising (typically <50 ms after first app launch).
class AppMapTileLayer extends ConsumerWidget {
  const AppMapTileLayer({
    super.key,
    this.urlTemplate,
    this.subdomains = const [],
  });

  /// OSM tile URL template. Defaults to [MapService.standardTileProvider].
  final String? urlTemplate;

  /// Subdomain list for parallel tile loading (e.g. `['a', 'b', 'c']`).
  final List<String> subdomains;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tileProvider = ref.watch(
      mapTileProviderProvider.select((a) => a.value),
    );
    return TileLayer(
      urlTemplate: urlTemplate ?? MapService.standardTileProvider.urlTemplate,
      subdomains: subdomains,
      userAgentPackageName: AppConstants.userAgent,
      tileProvider: tileProvider,
    );
  }
}
