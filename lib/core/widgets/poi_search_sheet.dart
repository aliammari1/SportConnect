import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// POI (Points of Interest) Search Widget
///
/// Allows users to search for nearby places like:
/// - Gas stations
/// - Restaurants
/// - Parking
/// - Sports facilities
/// - Public transport
/// - And more...
///
/// Works worldwide (France, etc.) using Overpass API (Free & Open Source)
class POISearchSheet extends ConsumerStatefulWidget {
  const POISearchSheet({
    required this.currentLocation,
    required this.onPOISelected,
    super.key,
    this.initialRadius = 2000, // 2km default
  });
  final LatLng currentLocation;
  final void Function(PointOfInterest poi) onPOISelected;
  final double initialRadius;

  /// Show POI search bottom sheet
  static Future<void> show(
    BuildContext context, {
    required LatLng currentLocation,
    required void Function(PointOfInterest poi) onPOISelected,
    double initialRadius = 2000,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).nearbyPlaces,
      forceMaxHeight: true,
      maxHeightFactor: 0.85,
      child: POISearchSheet(
        currentLocation: currentLocation,
        onPOISelected: onPOISelected,
        initialRadius: initialRadius,
      ),
    );
  }

  @override
  ConsumerState<POISearchSheet> createState() => _POISearchSheetState();
}

class _POISearchSheetState extends ConsumerState<POISearchSheet> {
  POIType? _selectedType;
  List<PointOfInterest> _results = [];
  bool _isLoading = false;
  double _searchRadius = 2000;

  @override
  void initState() {
    super.initState();
    _searchRadius = widget.initialRadius;
  }

  Future<void> _searchPOI(POIType type) async {
    setState(() {
      _selectedType = type;
      _isLoading = true;
    });

    final requestedRadius = _searchRadius;
    final results = await ref
        .read(mapServiceProvider)
        .searchPOI(
          center: widget.currentLocation,
          radiusMeters: requestedRadius,
          type: type,
        );

    // Discard stale responses: ignore if the selected category or radius
    // changed (e.g. another tap/slider change) while this request was awaiting.
    if (!mounted ||
        _selectedType != type ||
        _searchRadius != requestedRadius) {
      return;
    }

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }

  List<_POICategory> _buildCategories(AppLocalizations l10n) => [
    _POICategory(
      type: POIType.gasStation,
      label: l10n.gas_stations,
      icon: Icons.local_gas_station_rounded,
      color: const Color(0xFFFF6B6B),
    ),
    _POICategory(
      type: POIType.parking,
      label: l10n.parking,
      icon: Icons.local_parking_rounded,
      color: const Color(0xFF4ECDC4),
    ),
    _POICategory(
      type: POIType.restaurant,
      label: l10n.restaurants,
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFFFBE0B),
    ),
    _POICategory(
      type: POIType.sportsCenter,
      label: l10n.sports,
      icon: Icons.sports_soccer_rounded,
      color: AppColors.primary,
    ),
    _POICategory(
      type: POIType.university,
      label: l10n.universities,
      icon: Icons.school_rounded,
      color: const Color(0xFF9B59B6),
    ),
    _POICategory(
      type: POIType.hospital,
      label: l10n.hospitals,
      icon: Icons.local_hospital_rounded,
      color: const Color(0xFFE74C3C),
    ),
    _POICategory(
      type: POIType.publicTransport,
      label: l10n.transport,
      icon: Icons.directions_bus_rounded,
      color: const Color(0xFF3498DB),
    ),
    _POICategory(
      type: POIType.cafe,
      label: l10n.cafe,
      icon: Icons.local_cafe_rounded,
      color: const Color(0xFF8B4513),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _buildCategories(l10n);
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildIntro(l10n),
          _buildRadiusSlider(),
          _buildCategoryList(categories),
          const Divider(height: 1),
          Expanded(child: _buildResults(categories, l10n)),
        ],
      ),
    );
  }

  Widget _buildIntro(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.secondary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.explore_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.explore_nearby_stops,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    AppLocalizations.of(context).findUsefulSpotsAlongYour,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildRadiusSlider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).searchRadius,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _formatDistance(_searchRadius),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.1),
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            ),
            child: AdaptiveSlider(
              value: _searchRadius,
              min: 500,
              max: 10000,
              divisions: 19,
              onChanged: (value) {
                unawaited(HapticFeedback.selectionClick());
                setState(() => _searchRadius = value);
              },
              onChangeEnd: (value) {
                if (_selectedType != null) {
                  unawaited(_searchPOI(_selectedType!));
                }
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildCategoryList(List<_POICategory> categories) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedType == category.type;

          return GestureDetector(
                onTap: () {
                  unawaited(HapticFeedback.selectionClick());
                  unawaited(_searchPOI(category.type));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color : AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? category.color : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category.icon,
                        color: isSelected ? Colors.white : category.color,
                        size: 26.sp,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: (index * 50).ms)
              .fadeIn()
              .scale(begin: const Offset(0.9, 0.9));
        },
      ),
    );
  }

  Widget _buildResults(
    List<_POICategory> categories,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
      return ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return Skeletonizer(
            containersColor: AppColors.surfaceVariant,
            child: _buildSkeletonCard(),
          );
        },
      );
    }

    if (_selectedType == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 50.sp,
                    color: AppColors.primary,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).selectACategoryToSearch,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).tapOnAnyCategoryAbove,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 50.sp,
                color: AppColors.warning,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).noResultsFound,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context).tryIncreasingTheSearchRadius,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _results.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final poi = _results[index];
        return _buildPOICard(poi, index, categories, l10n);
      },
    );
  }

  Widget _buildPOICard(
    PointOfInterest poi,
    int index,
    List<_POICategory> categories,
    AppLocalizations l10n,
  ) {
    final category = categories.firstWhere(
      (c) => c.type == _selectedType,
      orElse: () => categories.first,
    );

    // Calculate distance from current location
    final distance = MapService.calculateDistance(
      widget.currentLocation,
      poi.location,
    );

    // Get address from tags
    final address =
        poi.tags['addr:street'] ??
        poi.tags['addr:city'] ??
        poi.tags['addr:full'];

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        widget.onPOISelected(poi);
        context.pop();
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(category.icon, color: category.color, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name ?? l10n.unknown,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_walk_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDistance(distance),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (poi.tags['opening_hours'] != null) ...[
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            poi.tags['opening_hours']!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.navigation_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 10.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 10.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.border.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _POICategory {
  const _POICategory({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
  final POIType type;
  final String label;
  final IconData icon;
  final Color color;
}
