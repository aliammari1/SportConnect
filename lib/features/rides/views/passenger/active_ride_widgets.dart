import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class MapCircleButton extends StatelessWidget {
  const MapCircleButton({required this.icon, required this.onTap, super.key});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      color: Colors.white,
      shape: const CircleBorder(),
      customBorder: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 20.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class ActivePhaseBadge extends StatelessWidget {
  const ActivePhaseBadge({required this.phase, this.rideStatus, super.key});

  final ActiveRidePhase phase;
  final RideStatus? rideStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color color;
    String label;
    IconData icon;
    switch (phase) {
      case ActiveRidePhase.pickingUp:
        color = AppColors.warning;
        if (rideStatus == RideStatus.inProgress) {
          label = 'Driver at Pickup';
          icon = Icons.how_to_reg;
        } else {
          label = l10n.headingToPickup;
          icon = Icons.person_pin_circle;
        }
      case ActiveRidePhase.enRoute:
        color = AppColors.primary;
        label = l10n.tripInProgress;
        icon = Icons.navigation;
      case ActiveRidePhase.arriving:
        color = AppColors.success;
        label = l10n.headingToDestination;
        icon = Icons.near_me;
      case ActiveRidePhase.completed:
        color = AppColors.success;
        label = l10n.rideCompleted;
        icon = Icons.check_circle;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class RideStatusBadge extends StatelessWidget {
  const RideStatusBadge({required this.status, super.key});

  final RideStatus status;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case RideStatus.draft:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.2);
        textColor = AppColors.textSecondary;
        label = 'Draft';
        icon = Icons.edit_outlined;
      case RideStatus.active:
        bgColor = AppColors.info.withValues(alpha: 0.2);
        textColor = AppColors.info;
        label = 'Active';
        icon = Icons.check_circle_outline;
      case RideStatus.full:
        bgColor = AppColors.warning.withValues(alpha: 0.2);
        textColor = AppColors.warning;
        label = 'Full';
        icon = Icons.people;
      case RideStatus.inProgress:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'In Progress';
        icon = Icons.directions_car;
      case RideStatus.completed:
        bgColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'Completed';
        icon = Icons.done_all;
      case RideStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.2);
        textColor = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class RideStatusStep extends StatelessWidget {
  const RideStatusStep({
    required this.label,
    required this.isCompleted,
    required this.icon,
    super.key,
  });

  final String label;
  final bool isCompleted;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isCompleted ? Colors.white : AppColors.textTertiary,
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isCompleted
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (isCompleted)
          Icon(Icons.check, size: 20.sp, color: AppColors.success),
      ],
    );
  }
}

class RideStatusDivider extends StatelessWidget {
  const RideStatusDivider({required this.isActive, super.key});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.w),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 24.h,
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ],
      ),
    );
  }
}

class NightSafetyBanner extends StatelessWidget {
  const NightSafetyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.15),
            const Color(0xFF283593).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.nightlight_round,
            size: 20.sp,
            color: const Color(0xFF5C6BC0),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              l10n.night_ride_stay_alert_and_share_your_trip_with_someone_you_trust,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.shield_rounded,
            size: 18.sp,
            color: const Color(0xFF5C6BC0),
          ),
        ],
      ),
    );
  }
}

class RouteDeviationAlert extends StatelessWidget {
  const RouteDeviationAlert({required this.rideState, super.key});

  final ActiveRideState rideState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deviationDistance = l10n.distanceKmValue(
      (rideState.routeDeviationMeters / 1000).toStringAsFixed(1),
    );
    return Container(
      margin: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22.sp,
            color: AppColors.error,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.routeDeviationDetected,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  rideState.remainingEtaMinutes != null
                      ? l10n.driverOffRouteEta(
                          deviationDistance,
                          rideState.remainingEtaMinutes!,
                        )
                      : l10n.driverOffPlannedRoute(deviationDistance),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TripProgressBar extends StatelessWidget {
  const TripProgressBar({
    required this.ride,
    required this.rideState,
    super.key,
  });

  final RideModel ride;
  final ActiveRideState rideState;

  @override
  Widget build(BuildContext context) {
    var progress = 0.0;
    if (ride.distanceKm != null && ride.distanceKm! > 0) {
      final remaining = rideState.remainingDistanceKm ?? ride.distanceKm!;
      progress = ((ride.distanceKm! - remaining) / ride.distanceKm!).clamp(
        0.0,
        1.0,
      );
    }
    return Padding(
      padding: adaptiveScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Progress',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${progress * 100}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

class RideInfoTile extends StatelessWidget {
  const RideInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniRouteRow extends StatelessWidget {
  const MiniRouteRow({
    required this.icon,
    required this.color,
    required this.text,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Self-contained pulsing marker that manages its own [AnimationController].
///
/// Extracting the animation into a separate [StatefulWidget] prevents the
/// 60 fps animation rebuild from being coupled to the parent's state changes
/// (GPS updates, ETA recalculations, etc.) and avoids animation stutter when
/// the parent rebuilds.
class PulsingLocationMarker extends StatefulWidget {
  const PulsingLocationMarker({
    required this.heading,
    required this.outerSize,
    required this.innerSize,
    required this.iconSize,
    this.icon = Icons.navigation,
    this.reverse = false,
    this.color = AppColors.primaryDark,
    super.key,
  });

  final double heading;
  final double outerSize;
  final double innerSize;
  final double iconSize;
  final IconData icon;
  final Color color;
  final bool reverse;

  @override
  State<PulsingLocationMarker> createState() => _PulsingLocationMarkerState();
}

class _PulsingLocationMarkerState extends State<PulsingLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: widget.reverse);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: widget.heading * 3.14159 / 180,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.outerSize * (1 + _controller.value * 0.3),
                height: widget.outerSize * (1 + _controller.value * 0.3),
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: 0.3 * (1 - _controller.value),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: widget.innerSize,
                height: widget.innerSize,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.iconSize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  const InfoItem({
    required this.icon,
    required this.value,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: AppColors.primary),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
