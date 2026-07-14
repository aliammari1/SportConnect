import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/features/notifications/models/notification_model.dart';
import 'package:sport_connect/features/notifications/view_models/notification_preferences_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Notification Preferences screen: lets the user control the individual
/// notification types, quiet hours, and sound/vibration behaviour promised in
/// the Privacy Policy ("Settings → Notifications"). Persists to Firestore via
/// [NotificationPreferencesViewModel] so preferences sync across devices and
/// can eventually be read server-side before a push is sent.
class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(notificationPreferencesViewModelProvider);
    final viewModel = ref.read(
      notificationPreferencesViewModelProvider.notifier,
    );

    ref.listen(notificationPreferencesViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AdaptiveSnackBar.show(
          context,
          message: next.errorMessage!,
          type: AdaptiveSnackBarType.error,
        );
        viewModel.clearError();
      }
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textPrimary,
            size: 20.sp,
          ),
        ),
        title: l10n.notificationPreferences,
      ),
      body: MaxWidthContainer(
        child: state.preferences.when(
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, _) => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                l10n.something_went_wrong_please_try_again,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          data: (prefs) => _NotificationPreferencesBody(
            l10n: l10n,
            prefs: prefs,
            isSaving: state.isSaving,
            viewModel: viewModel,
          ),
        ),
      ),
    );
  }
}

class _NotificationPreferencesBody extends StatelessWidget {
  const _NotificationPreferencesBody({
    required this.l10n,
    required this.prefs,
    required this.isSaving,
    required this.viewModel,
  });

  final AppLocalizations l10n;
  final NotificationPreferences prefs;
  final bool isSaving;
  final NotificationPreferencesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: adaptiveScreenPadding(context).copyWith(top: 8.h, bottom: 32.h),
      children: [
        if (isSaving) ...[
          SizedBox(
            height: 2.h,
            child: const LinearProgressIndicator(minHeight: 2),
          ),
          SizedBox(height: 8.h),
        ],
        SizedBox(height: isSaving ? 0 : 16.h),
        Text(
          l10n.customizeWhatNotificationsYouReceive,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 24.h),

        _buildCard([
          _buildSwitchTile(
            title: l10n.settingsPushNotifications,
            subtitle: l10n.settingsPushNotificationsDesc,
            icon: Icons.notifications_active_outlined,
            value: prefs.pushEnabled,
            onChanged: viewModel.setPushEnabled,
          ),
        ]),

        SizedBox(height: 32.h),
        _buildSectionHeader(
          l10n.settingsNotificationCategories,
          Icons.category_outlined,
        ),
        SizedBox(height: 12.h),
        _buildGatedGroup(
          enabled: prefs.pushEnabled,
          child: _buildCard([
            _buildSwitchTile(
              title: l10n.settingsRideReminders,
              subtitle: l10n.settingsRideRemindersDesc,
              icon: Icons.directions_car_outlined,
              value: prefs.rideNotifications,
              onChanged: viewModel.setRideNotifications,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsChatMessages,
              subtitle: l10n.settingsChatMessagesDesc,
              icon: Icons.chat_bubble_outline_rounded,
              value: prefs.messageNotifications,
              onChanged: viewModel.setMessageNotifications,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsSocialNotifications,
              subtitle: l10n.settingsSocialNotificationsDesc,
              icon: Icons.person_outline_rounded,
              value: prefs.socialNotifications,
              onChanged: viewModel.setSocialNotifications,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsGamificationNotifications,
              subtitle: l10n.settingsGamificationNotificationsDesc,
              icon: Icons.emoji_events_outlined,
              value: prefs.gamificationNotifications,
              onChanged: viewModel.setGamificationNotifications,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsMarketingTips,
              subtitle: l10n.settingsMarketingTipsDesc,
              icon: Icons.campaign_outlined,
              value: prefs.promotionNotifications,
              onChanged: viewModel.setPromotionNotifications,
            ),
          ]),
        ),

        SizedBox(height: 32.h),
        _buildSectionHeader(l10n.settingsQuietHours, Icons.bedtime_outlined),
        SizedBox(height: 12.h),
        _buildCard([
          _buildSwitchTile(
            title: l10n.settingsQuietHours,
            subtitle: l10n.settingsQuietHoursDesc,
            icon: Icons.do_not_disturb_on_outlined,
            value: prefs.quietHoursEnabled,
            onChanged: viewModel.setQuietHoursEnabled,
          ),
          if (prefs.quietHoursEnabled) ...[
            _buildDivider(),
            _buildTimeTile(
              context: context,
              title: l10n.settingsQuietHoursStart,
              icon: Icons.bedtime_outlined,
              time: _parseTimeOfDay(prefs.quietHoursStart),
              onPicked: viewModel.setQuietHoursStart,
            ),
            _buildDivider(),
            _buildTimeTile(
              context: context,
              title: l10n.settingsQuietHoursEnd,
              icon: Icons.wb_sunny_outlined,
              time: _parseTimeOfDay(prefs.quietHoursEnd),
              onPicked: viewModel.setQuietHoursEnd,
            ),
          ],
        ]),

        SizedBox(height: 32.h),
        _buildSectionHeader('Sound & Vibration', Icons.volume_up_outlined),
        SizedBox(height: 12.h),
        _buildCard([
          _buildSwitchTile(
            title: l10n.soundEffects,
            subtitle: l10n.playSoundsForNewRequests,
            icon: Icons.volume_up_outlined,
            value: prefs.soundEnabled,
            onChanged: viewModel.setSoundEnabled,
          ),
          _buildDivider(),
          _buildSwitchTile(
            title: l10n.vibration,
            subtitle: l10n.vibrateForImportantAlerts,
            icon: Icons.vibration_rounded,
            value: prefs.vibrationEnabled,
            onChanged: viewModel.setVibrationEnabled,
          ),
        ]),

        SizedBox(height: 32.h),
        _buildSectionHeader(
          l10n.settingsEmailNotifications,
          Icons.email_outlined,
        ),
        SizedBox(height: 12.h),
        _buildCard([
          _buildSwitchTile(
            title: l10n.settingsEmailNotifications,
            subtitle: l10n.settingsEmailNotificationsDesc,
            icon: Icons.email_outlined,
            value: prefs.emailEnabled,
            onChanged: viewModel.setEmailEnabled,
          ),
          if (prefs.emailEnabled) ...[
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsEmailRideSummary,
              subtitle: l10n.settingsEmailRideSummaryDesc,
              icon: Icons.receipt_long_outlined,
              value: prefs.emailRideSummary,
              onChanged: viewModel.setEmailRideSummary,
            ),
            _buildDivider(),
            _buildSwitchTile(
              title: l10n.settingsEmailWeeklyDigest,
              subtitle: l10n.settingsEmailWeeklyDigestDesc,
              icon: Icons.calendar_view_week_outlined,
              value: prefs.emailWeeklyDigest,
              onChanged: viewModel.setEmailWeeklyDigest,
            ),
          ],
        ]),
      ],
    );
  }

  /// Dims and disables [child] when [enabled] is false, reflecting that the
  /// per-category toggles are gated by the master push switch (see
  /// [NotificationPreferences.isTypeEnabled]).
  Widget _buildGatedGroup({required bool enabled, required Widget child}) {
    if (enabled) return child;
    return Opacity(
      opacity: 0.45,
      child: IgnorePointer(child: child),
    );
  }

  TimeOfDay _parseTimeOfDay(String value) {
    final parts = value.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return TimeOfDay(
      hour: (hour ?? 22).clamp(0, 23),
      minute: (minute ?? 0).clamp(0, 59),
    );
  }

  String _formatStorageTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.textSecondary),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AdaptiveSwitch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required TimeOfDay time,
    required Future<void> Function(String value) onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked == null) return;
        await onPicked(_formatStorageTime(picked));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.textSecondary),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Builder(
              builder: (context) => Text(
                time.format(context),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
