import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Walking distance and directions to pickup point (#19, #45)
class WalkingDistanceCard extends StatelessWidget {
  const WalkingDistanceCard({
    required this.distanceMeters,
    required this.walkingMinutes,
    super.key,
    this.onGetDirections,
  });

  /// Estimate walking minutes from distance (avg 80m/min)
  factory WalkingDistanceCard.fromDistance({
    required double distanceMeters,
    Key? key,
    VoidCallback? onGetDirections,
  }) {
    return WalkingDistanceCard(
      key: key,
      distanceMeters: distanceMeters,
      walkingMinutes: (distanceMeters / 80).ceil(),
      onGetDirections: onGetDirections,
    );
  }
  final double distanceMeters;
  final int walkingMinutes;
  final VoidCallback? onGetDirections;

  String get _formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_walk_rounded,
              size: 20.sp,
              color: AppColors.info,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$walkingMinutes min walk to pickup',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _formattedDistance,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          if (onGetDirections != null)
            TextButton.icon(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                onGetDirections!();
              },
              icon: Icon(Icons.navigation_rounded, size: 16.sp),
              label: Text(
                AppLocalizations.of(context).directions,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
        ],
      ),
    );
  }
}

/// Estimated wait time display (#51)
class EstimatedWaitTime extends StatelessWidget {
  const EstimatedWaitTime({
    required this.waitMinutes,
    super.key,
    this.isDriverEnRoute = false,
  });
  final int waitMinutes;
  final bool isDriverEnRoute;

  @override
  Widget build(BuildContext context) {
    final color = waitMinutes <= 5
        ? AppColors.success
        : waitMinutes <= 15
        ? AppColors.warning
        : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDriverEnRoute
                ? Icons.directions_car_rounded
                : Icons.schedule_rounded,
            size: 16.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          Text(
            isDriverEnRoute
                ? AppLocalizations.of(context).driverArrivingIn(waitMinutes)
                : AppLocalizations.of(context).estimatedWait(waitMinutes),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pickup pin drop widget (#44)
class PickupPinDropCard extends StatelessWidget {
  const PickupPinDropCard({
    required this.onDropPin,
    super.key,
    this.currentAddress,
    this.onClearPin,
  });
  final String? currentAddress;
  final VoidCallback onDropPin;
  final VoidCallback? onClearPin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPin = currentAddress != null;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: hasPin
            ? AppColors.success.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: hasPin
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasPin ? Icons.location_on_rounded : Icons.add_location_alt_rounded,
            size: 24.sp,
            color: hasPin ? AppColors.success : AppColors.primary,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPin
                      ? AppLocalizations.of(context).customPickupPoint
                      : AppLocalizations.of(context).dropPinForPickup,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (hasPin)
                  Text(
                    currentAddress!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (hasPin && onClearPin != null)
            IconButton(
              onPressed: onClearPin,
              icon: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColors.textTertiary,
              ),
              tooltip: AppLocalizations.of(context).clearPin,
            ),
          if (!hasPin)
            TextButton(
              onPressed: () {
                unawaited(HapticFeedback.lightImpact());
                onDropPin();
              },
              child: Text(AppLocalizations.of(context).setPin),
            ),
        ],
      ),
    );
  }
}

/// No-show marking dialog (#40)
class NoShowDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String passengerName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierLabel: AppLocalizations.of(context).markNoShow,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).markNoShow),
        content: Text(
          AppLocalizations.of(context).markNoShowPrompt(passengerName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          ElevatedButton(
            onPressed: () {
              unawaited(HapticFeedback.mediumImpact());
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: Text(AppLocalizations.of(context).markNoShow),
          ),
        ],
      ),
    );
  }
}

/// Vehicle quick switch bottom sheet (#41)
class VehicleQuickSwitchSheet extends StatelessWidget {
  const VehicleQuickSwitchSheet({
    required this.vehicles,
    required this.onSelect,
    super.key,
    this.currentVehicleId,
  });
  final List<VehicleOption> vehicles;
  final String? currentVehicleId;
  final ValueChanged<String> onSelect;

  static Future<void> show(
    BuildContext context, {
    required List<VehicleOption> vehicles,
    required ValueChanged<String> onSelect,
    String? currentVehicleId,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).switchVehicle,
      maxHeightFactor: 0.65,
      child: VehicleQuickSwitchSheet(
        vehicles: vehicles,
        currentVehicleId: currentVehicleId,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Title and drag handle are provided by AppModalSheet's always-visible
    // top bar (see VehicleQuickSwitchSheet.show), so they are not repeated here.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...vehicles.map((v) => _buildVehicleTile(context, v)),
        ],
      ),
    );
  }

  Widget _buildVehicleTile(BuildContext context, VehicleOption vehicle) {
    final isSelected = vehicle.id == currentVehicleId;
    final theme = Theme.of(context);
    return AdaptiveListTile(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        Navigator.pop(context);
        onSelect(vehicle.id);
      },
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (isSelected ? AppColors.primary : AppColors.textSecondary)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          Icons.directions_car_rounded,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      title: Text(
        vehicle.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(vehicle.plate),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}

/// Simple vehicle option model
class VehicleOption {
  const VehicleOption({
    required this.id,
    required this.name,
    required this.plate,
  });
  final String id;
  final String name;
  final String plate;
}

/// Ladies-only ride filter UI chip (#64)
class LadiesOnlyFilter extends StatelessWidget {
  const LadiesOnlyFilter({
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isEnabled,
      onSelected: (value) {
        unawaited(HapticFeedback.selectionClick());
        onChanged(value);
      },
      avatar: Icon(
        Icons.female_rounded,
        size: 16.sp,
        color: isEnabled ? Colors.pink : AppColors.textSecondary,
      ),
      label: Text(
        'Ladies Only',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w400,
          color: isEnabled ? Colors.pink : AppColors.textSecondary,
        ),
      ),
      selectedColor: Colors.pink.withValues(alpha: 0.12),
      checkmarkColor: Colors.pink,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: isEnabled
              ? Colors.pink.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
    );
  }
}

/// Ride sharing link widget (#67)
class RideSharingLink extends StatelessWidget {
  const RideSharingLink({
    required this.rideId,
    required this.onShare,
    super.key,
    this.onCopyLink,
  });
  final String rideId;
  final VoidCallback onShare;
  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              onShare();
            },
            icon: Icon(Icons.adaptive.share_rounded, size: 18.sp),
            label: Text(AppLocalizations.of(context).shareRide),
          ),
        ),
        if (onCopyLink != null) ...[
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              onCopyLink!();
            },
            icon: Icon(Icons.copy_rounded, size: 20.sp),
            tooltip: AppLocalizations.of(context).copyLink,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ],
    );
  }
}

/// Vehicle photo match card (#68)
class VehiclePhotoMatchCard extends StatelessWidget {
  const VehiclePhotoMatchCard({
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    super.key,
    this.vehiclePhotoUrl,
  });
  final String? vehiclePhotoUrl;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: vehiclePhotoUrl != null
                ? CachedNetworkImage(
                    imageUrl: vehiclePhotoUrl!,
                    width: 72.w,
                    height: 56.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _placeholderIcon(),
                    placeholder: (_, _) => _placeholderIcon(),
                  )
                : _placeholderIcon(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$vehicleMake $vehicleModel',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _parseColor(vehicleColor),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      vehicleColor,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    licensePlate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.verified_rounded, color: AppColors.info, size: 24.sp),
        ],
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 72.w,
      height: 56.h,
      color: AppColors.surfaceVariant,
      child: Icon(
        Icons.directions_car_rounded,
        size: 28.sp,
        color: AppColors.textTertiary,
      ),
    );
  }

  Color _parseColor(String colorName) {
    final map = {
      'black': Colors.black,
      'white': Colors.white,
      'silver': Colors.grey.shade400,
      'gray': Colors.grey,
      'grey': Colors.grey,
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'brown': Colors.brown,
      'orange': Colors.orange,
      'navy': Colors.indigo,
      'beige': const Color(0xFFF5F5DC),
    };
    return map[colorName.toLowerCase()] ?? Colors.grey;
  }
}
