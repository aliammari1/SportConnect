import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Provides pre-permission rationale dialogs before requesting runtime
/// permissions.
///
/// Both Apple App Store and Google Play Store require showing a
/// user-friendly explanation *before* the system permission prompt.
class PermissionDialogHelper {
  PermissionDialogHelper._();

  /// Shows a rationale dialog for location permission.
  ///
  /// Returns `true` if the user accepts, `false` if they decline.
  static Future<bool> showLocationRationale(
    BuildContext context, {
    String? customMessage,
  }) {
    return _showRationale(
      context,
      icon: Icons.location_on_outlined,
      iconColor: AppColors.primary,
      title: AppLocalizations.of(context).permissionLocationAccessTitle,
      message:
          customMessage ??
          AppLocalizations.of(context).permissionLocationAccessMessage,
    );
  }

  /// Shows a rationale dialog for location sharing in chat.
  static Future<bool> showLocationSharingRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.share_location_outlined,
      iconColor: AppColors.primary,
      title: AppLocalizations.of(context).permissionShareLocationTitle,
      message: AppLocalizations.of(context).permissionShareLocationMessage,
    );
  }

  /// Shows a rationale dialog for location tracking during active rides.
  static Future<bool> showRideTrackingRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.navigation_outlined,
      iconColor: AppColors.primary,
      title: AppLocalizations.of(context).permissionRideNavigationTitle,
      message: AppLocalizations.of(context).permissionRideNavigationMessage,
    );
  }

  /// Shows a rationale dialog for camera/photo access.
  static Future<bool> showCameraRationale(
    BuildContext context, {
    String? customMessage,
  }) {
    return _showRationale(
      context,
      icon: Icons.camera_alt_outlined,
      iconColor: AppColors.secondary,
      title: AppLocalizations.of(context).permissionCameraPhotosTitle,
      message:
          customMessage ??
          AppLocalizations.of(context).permissionCameraPhotosMessage,
    );
  }

  /// Shows a rationale dialog for notification permission.
  static Future<bool> showNotificationRationale(BuildContext context) {
    return _showRationale(
      context,
      icon: Icons.notifications_outlined,
      iconColor: AppColors.primary,
      title: AppLocalizations.of(context).permissionStayUpdatedTitle,
      message: AppLocalizations.of(context).permissionStayUpdatedMessage,
    );
  }

  /// Core pre-permission primer.
  ///
  /// Rendered as a width-capped centred card (not a narrow system
  /// AlertDialog), so it stays readable and never overflows on tablets/iPad
  /// while following the platform best practice of priming the user with a
  /// clear feature headline + benefit and two unambiguous choices
  /// ("Not now" / "Continue") BEFORE the OS permission prompt.
  static Future<bool> _showRationale(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        child: ConstrainedBox(
          // Cap the width so the primer is a tidy centred card on iPad
          // instead of stretching or cramming into a narrow system dialog.
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 28.sp),
                ),
                SizedBox(height: 18.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.divider),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PlatformAdaptive.buttonRadiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.actionCancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              PlatformAdaptive.buttonRadiusMd,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.actionContinue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }
}
