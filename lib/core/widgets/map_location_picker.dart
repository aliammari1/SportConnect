import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Full-screen Location Picker with Search and Map
///
/// Features:
/// - Nominatim search (works in France, worldwide)
/// - Popular cities quick picks (France)
/// - Interactive map for precise location
/// - Current location detection
/// - Multiple map styles
class MapLocationPicker extends ConsumerStatefulWidget {
  const MapLocationPicker({
    super.key,
    this.title = 'Select Location',
    this.initialLocation,
    this.countryCode,
    this.showQuickPicks = true,
  });
  final String title;
  final LatLng? initialLocation;
  final String? countryCode; // 'fr' for France, null for all
  final bool showQuickPicks;

  /// Show the location picker and return selected location
  static Future<LocationPickerResult?> show(
    BuildContext context, {
    String title = 'Select Location',
    LatLng? initialLocation,
    String? countryCode,
    bool showQuickPicks = true,
  }) {
    return AppModalSheet.show<LocationPickerResult>(
      context: context,
      useRootNavigator: true,
      forceMaxHeight: true,
      maxHeightFactor: 0.72,
      title: title,
      child: MapLocationPicker(
        title: title,
        initialLocation: initialLocation,
        countryCode: countryCode,
        showQuickPicks: showQuickPicks,
      ),
    );
  }

  @override
  ConsumerState<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends ConsumerState<MapLocationPicker>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final FocusNode _searchFocusNode = FocusNode();

  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  Timer? _debounce;

  LatLng? _selectedLocation;
  String? _selectedAddress;

  late final AnimationController _markerBounceController;
  late final AnimationController _pulseController;
  late final AnimationController _confirmButtonController;

  // Get popular cities based on country code
  List<PopularLocation> get _popularCities {
    if (widget.countryCode == 'fr') {
      return MapService.franceCities;
    } else {
      return [...MapService.franceCities.take(5)];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _markerBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _confirmButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (_selectedLocation != null) {
      _reverseGeocode(_selectedLocation!);
    } else {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _markerBounceController.dispose();
    _pulseController.dispose();
    _confirmButtonController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final svc = ref.read(locationServiceProvider);

      if (!await svc.isServiceEnabled()) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        return;
      }

      if (await svc.isPermissionPermanentlyDenied()) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        return;
      }

      if (!await svc.checkPermission()) {
        if (!mounted) return;
        final accepted = await PermissionDialogHelper.showLocationRationale(
          context,
        );
        if (!mounted) return;
        if (!accepted) {
          setState(() => _isLoadingLocation = false);
          return;
        }
        final granted = await svc.requestPermission();
        if (!mounted) return;
        if (!granted) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      final position = await svc.getCurrentLocation();
      if (!mounted) return;
      if (position == null) {
        setState(() => _isLoadingLocation = false);
        return;
      }
      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
        _isLoadingLocation = false;
      });

      _mapController.move(location, 15);
      _reverseGeocode(location);
      _animateMarker();
    } on Exception {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _animateMarker() {
    _markerBounceController.forward(from: 0);
  }

  Future<void> _reverseGeocode(LatLng location) async {
    final result = await ref.read(mapServiceProvider).reverseGeocode(location);
    if (result != null && mounted) {
      setState(() {
        _selectedAddress = result.displayName;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchPlaces(query);
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final results = await ref
        .read(mapServiceProvider)
        .searchPlaces(
          query,
          countryCode: widget.countryCode ?? 'FR',
          nearLocation: _selectedLocation,
          limit: 8,
        );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(SearchResult result) {
    unawaited(HapticFeedback.selectionClick());
    final location = result.location;

    setState(() {
      _selectedLocation = location;
      _selectedAddress = result.displayName;
      _searchResults = [];
      _searchController.clear();
    });

    _searchFocusNode.unfocus();
    _mapController.move(location, 16);
    _animateMarker();
  }

  void _selectCity(PopularLocation city) {
    unawaited(HapticFeedback.selectionClick());

    setState(() {
      _selectedLocation = city.location;
      _selectedAddress = city.name;
      _searchResults = [];
      _searchController.clear();
    });

    _searchFocusNode.unfocus();
    _mapController.move(city.location, 13);
    _animateMarker();
  }

  void _onMapTap(LatLng position) {
    unawaited(HapticFeedback.lightImpact());

    setState(() {
      _selectedLocation = position;
      _searchResults = [];
    });

    _searchFocusNode.unfocus();
    _reverseGeocode(position);
    _animateMarker();
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      context.pop(
        LocationPickerResult(
          location: _selectedLocation!,
          address: _selectedAddress ?? 'Selected Location',
        ),
      );
    }
  }

  Future<void> _openSelectedLocationInMaps() async {
    final location = _selectedLocation;
    if (location == null) return;

    try {
      final maps = await MapLauncher.installedMaps;
      if (!mounted) return;
      if (maps.isEmpty) {
        AdaptiveSnackBar.show(
          context,
          message: 'No map apps are available on this device.',
          type: AdaptiveSnackBarType.warning,
        );
        return;
      }

      final map = maps.firstWhere(
        (item) => item.mapType == MapType.google,
        orElse: () => maps.first,
      );
      await map.showMarker(
        coords: Coords(location.latitude, location.longitude),
        title: _selectedAddress ?? 'Selected Location',
      );
    } on Exception {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: 'Unable to open maps right now.',
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          _buildSearchBar(),
          if (_searchResults.isNotEmpty)
            _buildSearchResults()
          else if (widget.showQuickPicks && _searchController.text.isEmpty)
            _buildQuickPicks(),
          Expanded(child: _buildMap()),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _searchFocusNode.hasFocus
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
            width: _searchFocusNode.hasFocus ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _searchFocusNode.hasFocus
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: _searchFocusNode.hasFocus ? 15 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 16.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: _searchFocusNode.hasFocus
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.search_rounded,
                color: _searchFocusNode.hasFocus
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onTap: () => setState(() {}), // Trigger rebuild for focus state
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(
                    context,
                  ).searchAddressCityOrPlace,
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
            if (_isSearching)
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child:
                    SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(
                          duration: 1000.ms,
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
              )
            else if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.lightImpact());
                  _searchController.clear();
                  setState(() => _searchResults = []);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: -0.1);
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: BoxConstraints(maxHeight: 250.h),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: _searchResults.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: AppColors.border, indent: 56.w),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return _buildSearchResultItem(result, index);
        },
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1);
  }

  Widget _buildSearchResultItem(SearchResult result, int index) {
    return AdaptiveListTile(
      onTap: () => _selectSearchResult(result),
      leading: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          _getPlaceIcon(result.addressType),
          color: AppColors.primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        result.shortName,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        result.displayName,
        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        Icons.adaptive.arrow_forward_rounded,
        size: 16.sp,
        color: AppColors.textTertiary,
      ),
    ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: 0.1);
  }

  IconData _getPlaceIcon(String? type) {
    if (type == null) return Icons.location_on_rounded;
    switch (type.toLowerCase()) {
      case 'city':
      case 'town':
      case 'village':
        return Icons.location_city_rounded;
      case 'road':
      case 'street':
        return Icons.add_road_rounded;
      case 'station':
        return Icons.train_rounded;
      case 'airport':
        return Icons.flight_rounded;
      case 'university':
      case 'school':
        return Icons.school_rounded;
      case 'stadium':
      case 'sports_centre':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Widget _buildQuickPicks() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 16.sp, color: AppColors.warning),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context).popularCities,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _popularCities.length,
              separatorBuilder: (_, _) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final city = _popularCities[index];
                return _buildCityChip(city, index);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }

  Widget _buildCityChip(PopularLocation city, int index) {
    final isSelected =
        _selectedLocation?.latitude == city.location.latitude &&
        _selectedLocation?.longitude == city.location.longitude;

    // Determine flag based on location (France)
    const flag = '🇫🇷';
    const country = 'France';

    return GestureDetector(
      onTap: () => _selectCity(city),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  country,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2);
  }

  Widget _buildMap() {
    return Stack(
      children: [
        // Map
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _selectedLocation ??
                  const LatLng(36.8, 10.18), // Default: Tunis
              initialZoom: _selectedLocation != null ? 14 : 6,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              AppMapTileLayer(
                subdomains:
                    MapService.standardTileProvider.subdomains ?? const [],
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppColors.primary,
                    child: Icon(
                      Icons.navigation_rounded,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                  ),
                  markerSize: Size.square(28.w),
                  accuracyCircleColor: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  headingSectorColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 70,
                      height: 70,
                      child: _buildSelectedMarker(),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Current location button
        Positioned(
          right: 16.w,
          bottom: 16.h,
          child: Column(
            children: [
              _buildMapButton(
                icon: Icons.my_location_rounded,
                onTap: _getCurrentLocation,
                isLoading: _isLoadingLocation,
              ),
            ],
          ),
        ),

        // Attribution
        Positioned(
          left: 8.w,
          bottom: 8.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              MapService.standardTileProvider.attribution,
              style: TextStyle(fontSize: 9.sp, color: AppColors.textTertiary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedMarker() {
    return AnimatedBuilder(
      animation: Listenable.merge([_markerBounceController, _pulseController]),
      builder: (context, child) {
        final bounce = 1 - (0.3 * (1 - _markerBounceController.value));
        final pulse = 1 + (0.15 * (0.5 - (_pulseController.value - 0.5).abs()));
        return Transform.scale(
          scale: bounce,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(
                      alpha: 0.15 * (1 - _pulseController.value),
                    ),
                  ),
                ),
              ),
              // Marker
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                  Container(
                    width: 4.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Icon(icon, color: AppColors.primary, size: 22.sp),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected address preview
            if (_selectedAddress != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).selectedLocation,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _selectedAddress!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      tooltip: AppLocalizations.of(context).openInMaps,
                      onPressed: _openSelectedLocationInMaps,
                      icon: Icon(
                        Icons.near_me_rounded,
                        color: AppColors.primary,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1),

            // Confirm button with gradient
            GestureDetector(
              onTapDown: (_) {
                if (_selectedLocation != null) {
                  unawaited(HapticFeedback.lightImpact());
                  _confirmButtonController.forward();
                }
              },
              onTapUp: (_) {
                _confirmButtonController.reverse();
                if (_selectedLocation != null) {
                  _confirmSelection();
                }
              },
              onTapCancel: () => _confirmButtonController.reverse(),
              child: AnimatedBuilder(
                animation: _confirmButtonController,
                builder: (context, child) {
                  final scale = 1 - (0.03 * _confirmButtonController.value);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        gradient: _selectedLocation != null
                            ? AppColors.primaryGradient
                            : null,
                        color: _selectedLocation == null
                            ? AppColors.border
                            : null,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: _selectedLocation != null
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            color: _selectedLocation != null
                                ? Colors.white
                                : AppColors.textTertiary,
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            AppLocalizations.of(context).confirmLocation,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: _selectedLocation != null
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.15);
  }
}

/// Result returned from the location picker
class LocationPickerResult {
  const LocationPickerResult({required this.location, required this.address});
  final LatLng location;
  final String address;
}
