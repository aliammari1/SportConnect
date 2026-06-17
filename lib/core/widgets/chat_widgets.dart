import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Unread badge count (#57)
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, required this.child, super.key});
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;
    return Badge(
      label: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      backgroundColor: AppColors.error,
      child: child,
    );
  }
}

/// Location pin message bubble (#59)
class LocationPinBubble extends StatelessWidget {
  const LocationPinBubble({
    required this.latitude,
    required this.longitude,
    super.key,
    this.label,
    this.isMe = true,
    this.onTap,
  });
  final double latitude;
  final double longitude;
  final String? label;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.08)
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static map preview centered on the shared coordinates.
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                height: 100.h,
                child: IgnorePointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latitude, longitude),
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      const AppMapTileLayer(),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latitude, longitude),
                            width: 32.w,
                            height: 32.w,
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 32.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(
                  Icons.pin_drop_rounded,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    label ?? l10n.sharedLocation,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14.sp,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ],
            ),
            Text(
              '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
              style: TextStyle(
                fontSize: 11.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
