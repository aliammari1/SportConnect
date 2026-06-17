import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Premium feedback overlays for success, error, and booking confirmation.
class FeedbackAnimations {
  FeedbackAnimations._();

  static Future<void> showSuccess(
    BuildContext context, {
    String? message,
    VoidCallback? onDismissed,
  }) {
    unawaited(HapticFeedback.mediumImpact());
    final l10n = AppLocalizations.of(context);

    return _showFeedbackDialog(
      context,
      config: _FeedbackConfig.success(
        message: message ?? l10n.success,
        details: l10n.your_action_was_completed_successfully,
        barrierLabel: l10n.dismissSuccess,
      ),
      autoDismiss: true,
      onDismissed: onDismissed,
    );
  }

  static Future<void> showError(
    BuildContext context, {
    String? message,
    VoidCallback? onDismissed,
  }) {
    unawaited(HapticFeedback.heavyImpact());
    final l10n = AppLocalizations.of(context);

    return _showFeedbackDialog(
      context,
      config: _FeedbackConfig.error(
        title: l10n.somethingWentWrong,
        message: message ?? l10n.somethingWentWrong,
        barrierLabel: l10n.dismissError,
      ),
      autoDismiss: true,
      onDismissed: onDismissed,
    );
  }

  static Future<void> showBookingConfirmation(
    BuildContext context, {
    required String rideInfo,
    required String dateTime,
    VoidCallback? onDismissed,
  }) {
    unawaited(HapticFeedback.mediumImpact());

    final l10n = AppLocalizations.of(context);

    return _showFeedbackDialog(
      context,
      config: _FeedbackConfig.booking(
        title: l10n.requestSentTitle,
        message: rideInfo,
        details: dateTime,
        primaryActionLabel: l10n.great,
        barrierLabel: l10n.bookingRequestSent,
      ),
      autoDismiss: false,
      onDismissed: onDismissed,
    );
  }

  static Future<void> _showFeedbackDialog(
    BuildContext context, {
    required _FeedbackConfig config,
    required bool autoDismiss,
    VoidCallback? onDismissed,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: config.barrierLabel,
      barrierColor: Colors.black.withValues(alpha: 0.56),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, _, _) {
        return _PremiumFeedbackOverlay(
          config: config,
          autoDismiss: autoDismiss,
          onDismissed: onDismissed,
        );
      },
      transitionBuilder: (_, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _PremiumFeedbackOverlay extends StatefulWidget {
  const _PremiumFeedbackOverlay({
    required this.config,
    required this.autoDismiss,
    this.onDismissed,
  });

  final _FeedbackConfig config;
  final bool autoDismiss;
  final VoidCallback? onDismissed;

  @override
  State<_PremiumFeedbackOverlay> createState() =>
      _PremiumFeedbackOverlayState();
}

class _PremiumFeedbackOverlayState extends State<_PremiumFeedbackOverlay> {
  Timer? _dismissTimer;
  bool _didDismiss = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoDismiss) {
      _dismissTimer = Timer(const Duration(milliseconds: 1800), _dismiss);
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _dismiss() {
    if (_didDismiss || !mounted) return;

    _didDismiss = true;
    Navigator.of(context, rootNavigator: true).pop();
    widget.onDismissed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = widget.config;

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        if (!_didDismiss) {
          _didDismiss = true;
          widget.onDismissed?.call();
        }
      },
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420.w),
                child:
                    Container(
                      padding: EdgeInsets.all(22.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(28.r),
                        border: Border.all(
                          color: config.color.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 32,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _FeedbackIcon(config: config),
                          SizedBox(height: 20.h),
                          Text(
                            config.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: config.isCompact ? 20.sp : 22.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              color: theme.colorScheme.onSurface,
                            ),
                          ).animate().fadeIn(
                            delay: 120.ms,
                            duration: 260.ms,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            config.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.35,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ).animate().fadeIn(
                            delay: 180.ms,
                            duration: 260.ms,
                          ),
                          if (config.details != null) ...[
                            SizedBox(height: 14.h),
                            _DetailsPill(
                              icon: config.detailsIcon,
                              label: config.details!,
                              color: config.color,
                            ).animate().fadeIn(
                              delay: 240.ms,
                              duration: 260.ms,
                            ),
                          ],
                          if (config.primaryActionLabel != null) ...[
                            SizedBox(height: 24.h),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _dismiss,
                                style: FilledButton.styleFrom(
                                  backgroundColor: config.color,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  config.primaryActionLabel!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(
                              delay: 300.ms,
                              duration: 260.ms,
                            ),
                          ],
                        ],
                      ),
                    ).animate().slideY(
                      begin: 0.06,
                      end: 0,
                      duration: 260.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackIcon extends StatelessWidget {
  const _FeedbackIcon({required this.config});

  final _FeedbackConfig config;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color.withValues(alpha: 0.10),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: 1200.ms,
              curve: Curves.easeInOut,
            ),
        Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    config.color.withValues(alpha: 0.95),
                    config.color.withValues(alpha: 0.72),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: config.color.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 38.sp,
              ),
            )
            .animate()
            .scale(
              begin: const Offset(0.2, 0.2),
              end: const Offset(1, 1),
              duration: 520.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 180.ms),
      ],
    );
  }
}

class _DetailsPill extends StatelessWidget {
  const _DetailsPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: color,
          ),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackConfig {
  const _FeedbackConfig({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.barrierLabel,
    this.details,
    this.detailsIcon = Icons.schedule_rounded,
    this.primaryActionLabel,
    this.isCompact = false,
  });

  factory _FeedbackConfig.success({
    required String message,
    required String details,
    required String barrierLabel,
  }) {
    return _FeedbackConfig(
      title: message,
      message: details,
      icon: Icons.check_rounded,
      color: AppColors.success,
      barrierLabel: barrierLabel,
      isCompact: true,
    );
  }

  factory _FeedbackConfig.error({
    required String title,
    required String message,
    required String barrierLabel,
  }) {
    return _FeedbackConfig(
      title: title,
      message: message,
      icon: Icons.close_rounded,
      color: AppColors.error,
      barrierLabel: barrierLabel,
      isCompact: true,
    );
  }

  factory _FeedbackConfig.booking({
    required String title,
    required String message,
    required String details,
    required String primaryActionLabel,
    required String barrierLabel,
  }) {
    return _FeedbackConfig(
      title: title,
      message: message,
      details: details,
      detailsIcon: Icons.event_available_rounded,
      primaryActionLabel: primaryActionLabel,
      icon: Icons.send_rounded,
      color: AppColors.primary,
      barrierLabel: barrierLabel,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final String barrierLabel;
  final String? details;
  final IconData detailsIcon;
  final String? primaryActionLabel;
  final bool isCompact;
}
