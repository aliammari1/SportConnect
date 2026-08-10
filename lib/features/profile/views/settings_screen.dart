import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/admin_access_provider.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/auth/models/auth_exception.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';
import 'package:sport_connect/features/auth/views/reauth_dialog.dart';
import 'package:sport_connect/features/payments/services/premium_iap_service.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsViewModelProvider);
    final settingsViewModel = ref.read(settingsViewModelProvider.notifier);
    final currentLocale = settings.locale ?? Localizations.localeOf(context);

    final isDriver = ref.watch(
      currentUserProvider.select(
        (value) => value.value?.role == UserRole.driver,
      ),
    );
    final hasAdminAccess = ref.watch(adminAccessProvider).value ?? false;
    final premiumMeta = ref.watch(premiumMetadataProvider);

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
        title: l10n.settingsTitle,
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: adaptiveScreenPadding(
            context,
          ).copyWith(top: 8.h, bottom: 32.h),
          children: [
            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.premium,
              Icons.workspace_premium_rounded,
              color: AppColors.warning,
            ),
            SizedBox(height: 12.h),
            premiumMeta.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (meta) => meta.isPremium
                  ? _buildActivePremiumCard(l10n, meta)
                  : _buildCard([
                      _buildNavTile(
                        title: l10n.premium,
                        subtitle:
                            l10n.unlock_smart_matching_priority_rides_more,
                        icon: Icons.workspace_premium_rounded,
                        onTap: () =>
                            context.push(AppRoutes.premiumSubscribe.path),
                        color: AppColors.warning,
                      ),
                    ]),
            ),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.settingsAppearance,
              Icons.palette_outlined,
            ),
            SizedBox(height: 12.h),
            _buildCard([
              _buildLanguageTile(
                l10n: l10n,
                currentLocale: currentLocale,
                onChanged: (code) async {
                  if (code == null) return;

                  await settingsViewModel.setLanguage(code);
                },
              ),
            ]),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.settingsNotifications,
              Icons.notifications_outlined,
            ),
            SizedBox(height: 12.h),
            _buildCard([
              _buildNavTile(
                title: l10n.notificationPreferences,
                subtitle: l10n.customizeWhatNotificationsYouReceive,
                icon: Icons.tune_rounded,
                onTap: () =>
                    context.push(AppRoutes.notificationPreferences.path),
              ),
            ]),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.settingsPrivacySafety,
              Icons.shield_outlined,
            ),
            SizedBox(height: 12.h),
            _buildCard([
              _buildSwitchTile(
                title: l10n.analytics_crash_reports,
                subtitle: l10n.allow_anonymous_usage_data_and_crash_reports,
                icon: Icons.analytics_outlined,
                value: settings.analyticsCollectionEnabled,
                onChanged: (value) async {
                  await settingsViewModel.setAnalyticsCollectionEnabled(
                    value: value,
                  );
                },
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsBlockedUsers,
                subtitle: l10n.settingsBlockedUsersDesc,
                icon: Icons.block_outlined,
                onTap: _openBlockedUsersScreen,
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.data_processing_notice,
                subtitle: l10n.how_we_collect_use_and_protect_your_data,
                icon: Icons.info_outline_rounded,
                onTap: _showDataProcessingNotice,
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.withdraw_consent,
                subtitle: l10n.manage_or_withdraw_your_data_consent,
                icon: Icons.remove_circle_outline,
                onTap: _showWithdrawConsentDialog,
              ),
            ]),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.settingsAccount,
              Icons.account_circle_outlined,
            ),
            SizedBox(height: 12.h),
            _buildCard([
              _buildNavTile(
                title: l10n.settingsEditProfile,
                subtitle: l10n.settingsEditProfileDesc,
                icon: Icons.edit_outlined,
                onTap: () => context.push(AppRoutes.editProfile.path),
              ),
              if (isDriver) ...[
                _buildDivider(),
                _buildNavTile(
                  // (l10n.vehicles is lowercase and used elsewhere as a
                  // count-based plural noun, e.g. vehicle_management_screen.dart)
                  title: l10n.settingsVehiclesTitle,
                  subtitle: l10n.manage_your_vehicles,
                  icon: Icons.directions_car_outlined,
                  onTap: () => context.push(AppRoutes.driverVehicles.path),
                ),
              ],
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsPaymentMethods,
                subtitle: l10n.settingsPaymentMethodsDesc,
                icon: Icons.payment_outlined,
                onTap: () => context.push(AppRoutes.managePaymentMethods.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.paymentHistory,
                subtitle: l10n.view_your_past_rides_and_charges,
                icon: Icons.receipt_long_rounded,
                onTap: () => context.push(AppRoutes.paymentHistory.path),
              ),
              if (hasAdminAccess) ...[
                _buildDivider(),
                _buildNavTile(
                  title: l10n.adminDashboard,
                  subtitle: l10n.adminDashboardSettingsSubtitle,
                  icon: Icons.admin_panel_settings_outlined,
                  onTap: () => context.push(AppRoutes.adminDashboard.path),
                ),
              ],
              _buildDivider(),
              _buildNavTile(
                title: l10n.changePassword,
                subtitle: l10n.update_your_account_password,
                icon: Icons.lock_outline_rounded,
                onTap: () => context.push(AppRoutes.changePassword.path),
              ),
            ]),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.settingsSupport,
              Icons.help_outline_rounded,
            ),
            SizedBox(height: 12.h),
            _buildCard([
              _buildNavTile(
                title: l10n.settingsHelpCenter,
                subtitle: l10n.settingsHelpCenterDesc,
                icon: Icons.help_center_outlined,
                onTap: () => context.push(AppRoutes.helpCenter.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.contactSupport,
                subtitle: l10n.get_help_from_our_team,
                icon: Icons.support_agent_outlined,
                onTap: () => context.push(AppRoutes.contactSupport.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsReportProblem,
                subtitle: l10n.settingsReportProblemDesc,
                icon: Icons.bug_report_outlined,
                onTap: () => context.push(AppRoutes.reportIssue.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsTermsConditions,
                icon: Icons.description_outlined,
                onTap: () => context.push(AppRoutes.terms.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsPrivacyPolicy,
                icon: Icons.privacy_tip_outlined,
                onTap: () => context.push(AppRoutes.privacy.path),
              ),
              _buildDivider(),
              _buildNavTile(
                title: l10n.settingsAbout,
                subtitle: l10n.settingsAboutDesc,
                icon: Icons.article_outlined,
                onTap: () => context.push(AppRoutes.about.path),
              ),
            ]),

            SizedBox(height: 32.h),
            _buildSectionHeader(
              l10n.accountActions,
              Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            _buildDangerCard([
              _buildNavTile(
                title: l10n.signOut,
                subtitle: l10n.logOutOfYourAccount,
                icon: Icons.logout_rounded,
                onTap: _showLogoutDialog,
                color: AppColors.warning,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  child: _buildNavTile(
                    title: l10n.settingsDeleteAccount,
                    subtitle: l10n.settingsDeleteAccountDesc,
                    icon: Icons.delete_forever_rounded,
                    onTap: _showDeleteAccountDialog,
                    color: AppColors.error,
                  ),
                ),
              ),
            ]),

            SizedBox(height: 48.h),
            _buildFooter(l10n),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final c = color ?? AppColors.primary;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: c, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textSecondary,
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

  Widget _buildDangerCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.15)),
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

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
    Color? color,
  }) {
    final c = color ?? AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: c),
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
                      color: color ?? AppColors.textPrimary,
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

  Widget _buildLanguageTile({
    required AppLocalizations l10n,
    required Locale currentLocale,
    required ValueChanged<String?> onChanged,
  }) {
    final options = {'en': l10n.languageEnglish, 'fr': l10n.languageFrench};

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            Icons.language_outlined,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.settingsLanguageDesc,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentLocale.languageCode,
                isDense: true,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18.sp,
                ),
                items: options.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: AppColors.primary,
            size: 28.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          l10n.appTitle,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.appVersion(AppConfig.appVersion),
          style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  void _openBlockedUsersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _BlockedUsersScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDataProcessingNotice() {
    final l10n = AppLocalizations.of(context);
    AppModalSheet.show<void>(
      context: context,
      title: l10n.dataProcessingNotice,
      forceMaxHeight: true,
      maxHeightFactor: 0.86,
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: ListView(
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.verified_user_outlined,
              size: 48.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.dataProcessingNotice,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            _buildConsentInfoItem(
              l10n.personalInformation,
              l10n.personalInformationDescription,
              Icons.person_outline,
            ),
            _buildConsentInfoItem(
              l10n.locationData,
              l10n.locationDataDescription,
              Icons.location_on_outlined,
            ),
            _buildConsentInfoItem(
              l10n.paymentData,
              l10n.paymentDataDescription,
              Icons.payment_outlined,
            ),
            _buildConsentInfoItem(
              l10n.usageData,
              l10n.usageDataDescription,
              Icons.analytics_outlined,
            ),
            _buildConsentInfoItem(
              l10n.yourRights,
              l10n.yourRightsDescription,
              Icons.gavel_outlined,
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.by_using_sportconnect_you_consent_to_the_data_processing_described_above_and_in_our_privacy_policy,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentInfoItem(
    String title,
    String description,
    IconData icon,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20.sp),
          SizedBox(width: 12.w),
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
                SizedBox(height: 4.h),
                Text(
                  description,
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
    );
  }

  void _showWithdrawConsentDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).withdrawConsent,
      builder: (dialogContext) => AlertDialog.adaptive(
        backgroundColor: AppColors.surface.withValues(
          alpha: PlatformAdaptive.dialogAlpha,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          AppLocalizations.of(context).withdrawConsent,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).withdrawConsentDescription,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            _buildConsentInfoItem(
              l10n.analytics_crash_reports,
              l10n.allow_anonymous_usage_data_and_crash_reports,
              Icons.analytics_outlined,
            ),
            _buildConsentInfoItem(
              l10n.settingsShowLocation,
              l10n.settingsShowLocationDesc,
              Icons.location_off_outlined,
            ),
            _buildConsentInfoItem(
              l10n.settingsDeleteAccount,
              l10n.settingsDeleteAccountDesc,
              Icons.delete_forever_outlined,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(
              AppLocalizations.of(dialogContext).actionClose,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsLogout,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Text(
          AppLocalizations.of(dialogContext).settingsLogout,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppLocalizations.of(dialogContext).areYouSureYouWant5,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(dialogContext).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();

              await ref.read(authActionsViewModelProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(AppLocalizations.of(dialogContext).settingsLogout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    var confirmText = '';

    showDialog<void>(
      context: context,
      barrierLabel: AppLocalizations.of(context).settingsDeleteAccount,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContentContext, setDialogState) => AlertDialog.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).settingsDeleteAccount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).thisActionCannotBeUndone2,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).rideHistoryAndBookings,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).profileAndAchievements,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).messagesAndConnections,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).paymentInformation,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).deleteAccountSignInRevoked,
                ),
                _buildDeleteWarningItem(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).deleteAccountStripeClosureNotice,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(
                    dialogContentContext,
                  ).typeDeleteToConfirm,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _DeleteAccountConfirmField(
                  onTextChanged: (v) =>
                      setDialogState(() => confirmText = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: Text(
                AppLocalizations.of(dialogContentContext).actionCancel,
              ),
            ),
            ElevatedButton(
              onPressed:
                  confirmText ==
                      AppLocalizations.of(
                        dialogContentContext,
                      ).deleteKeyword
                  ? () async {
                      dialogContext.pop();

                      if (!context.mounted) return;

                      showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      );

                      try {
                        await ref
                            .read(authActionsViewModelProvider.notifier)
                            .deleteAccount();

                        if (!context.mounted) return;

                        context.pop();
                      } on AuthException catch (e) {
                        if (!context.mounted) return;

                        context.pop();

                        if (e.code == 'requires-recent-login') {
                          final ok = await showReauthDialog(context, ref);

                          if (!ok || !context.mounted) return;

                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          );

                          try {
                            await ref
                                .read(
                                  authActionsViewModelProvider.notifier,
                                )
                                .deleteAccount();

                            if (!context.mounted) return;

                            context.pop();
                          } catch (error) {
                            if (!context.mounted) return;

                            context.pop();

                            AdaptiveSnackBar.show(
                              context,
                              message: AppLocalizations.of(
                                context,
                              ).failedToDeleteAccountValue(error),
                              type: AdaptiveSnackBarType.error,
                            );
                          }

                          return;
                        }

                        AdaptiveSnackBar.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          ).failedToDeleteAccountValue(e),
                          type: AdaptiveSnackBarType.error,
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        context.pop();

                        AdaptiveSnackBar.show(
                          context,
                          message: AppLocalizations.of(
                            context,
                          ).failedToDeleteAccountValue(e),
                          type: AdaptiveSnackBarType.error,
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                disabledBackgroundColor: AppColors.error.withValues(alpha: 0.3),
              ),
              child: Text(
                AppLocalizations.of(dialogContentContext).settingsDeleteAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(Icons.close_rounded, color: AppColors.error, size: 15.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePremiumCard(AppLocalizations l10n, PremiumMetadata meta) {
    final planLabel = switch (meta.plan) {
      'monthly' => l10n.monthly,
      'yearly' => l10n.yearly,
      _ => l10n.premium,
    };
    final dateLabel = meta.updatedAt != null
        ? AppLocaleFormatters.formatMediumDate(context, meta.updatedAt!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.warning,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sportconnect_premium,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (dateLabel != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          '${l10n.active} $dateLabel',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    planLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.warning.withValues(alpha: 0.2)),
          _buildNavTile(
            title: l10n.manage_subscription,
            subtitle: l10n.cancel_or_change_your_plan_in_the_store,
            icon: Icons.subscriptions,
            onTap: _manageSubscription,
          ),
          _buildDivider(),
          _buildNavTile(
            title: l10n.restore_purchases,
            subtitle: l10n.reapply_your_active_subscription,
            icon: Icons.restore_rounded,
            onTap: _restorePurchases,
          ),
        ],
      ),
    );
  }

  Future<void> _manageSubscription() async {
    final l10n = AppLocalizations.of(context);
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse('https://play.google.com/store/account/subscriptions');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: l10n.could_not_open_subscription_management,
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  Future<void> _restorePurchases() async {
    final result = await ref
        .read(premiumIapServiceProvider.notifier)
        .restorePurchases();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    AdaptiveSnackBar.show(
      context,
      message: result.isSuccess
          ? l10n.purchasesRestoredSuccessfully
          : (result.errorMessage ?? l10n.couldNotRestorePurchases),
      type: result.isSuccess
          ? AdaptiveSnackBarType.success
          : AdaptiveSnackBarType.error,
    );
  }
}

class _BlockedUsersScreen extends ConsumerStatefulWidget {
  const _BlockedUsersScreen();

  @override
  ConsumerState<_BlockedUsersScreen> createState() =>
      _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<_BlockedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

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
        title: l10n.settingsBlockedUsers,
      ),
      body: blockedUsersAsync.when(
        loading: () => const SkeletonLoader(type: SkeletonType.profileCard),
        error: (_, _) => Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              l10n.failedToLoadChats,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (blockedUsers) {
          if (blockedUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block_outlined,
                      size: 56.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.noBlockedUsers,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.usersYouBlockWillAppear,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final normalizedQuery = _query.trim().toLowerCase();
          final filteredUsers = blockedUsers
              .where((user) {
                if (normalizedQuery.isEmpty) return true;

                return user.username.toLowerCase().contains(
                      normalizedQuery,
                    ) ||
                    user.email.toLowerCase().contains(normalizedQuery) ||
                    user.uid.toLowerCase().contains(normalizedQuery);
              })
              .toList(growable: false);

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 10.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchUsers,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: l10n.clearSearchTooltip,
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredUsers.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noResultsFound2,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator.adaptive(
                        onRefresh: () async {
                          ref
                            ..invalidate(blockedUsersProvider)
                            ..invalidate(currentUserProvider);

                          await Future<void>.delayed(
                            const Duration(milliseconds: 250),
                          );
                        },
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                          itemCount: filteredUsers.length,
                          separatorBuilder: (_, _) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final displayName = user.username.isNotEmpty
                                ? user.username
                                : user.uid;

                            return Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: AppColors.border.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (user.photoUrl != null)
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                            user.photoUrl!,
                                          ),
                                    )
                                  else
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.14),
                                      child: Text(
                                        displayName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (user.email.isNotEmpty)
                                          Text(
                                            user.email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final shouldUnblock =
                                          await showDialog<bool>(
                                            context: context,
                                            barrierLabel: l10n.unblockUser,
                                            builder: (dialogContext) =>
                                                AlertDialog.adaptive(
                                                  title: Text(l10n.unblockUser),
                                                  content: Text(
                                                    l10n.unblockUserDialogMessage(
                                                      displayName,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          dialogContext.pop(
                                                            false,
                                                          ),
                                                      child: Text(
                                                        l10n.actionCancel,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          dialogContext.pop(
                                                            true,
                                                          ),
                                                      child: Text(
                                                        l10n.actionUnblock,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          ) ??
                                          false;

                                      if (!context.mounted) return;
                                      if (!shouldUnblock) return;

                                      try {
                                        await ref
                                            .read(
                                              profileActionsViewModelProvider
                                                  .notifier,
                                            )
                                            .unblockCurrentUser(user.uid);

                                        if (!context.mounted) return;

                                        ref.invalidate(blockedUsersProvider);
                                        ref.invalidate(currentUserProvider);

                                        AdaptiveSnackBar.show(
                                          context,
                                          message: l10n.userUnblocked,
                                          type: AdaptiveSnackBarType.success,
                                        );
                                      } on Object catch (e, st) {
                                        TalkerService.warning(
                                          'Failed to unblock user ${user.uid}: $e',
                                        );
                                        TalkerService.error(
                                          'Unblock user flow error',
                                          e,
                                          st,
                                        );
                                        if (!context.mounted) return;

                                        AdaptiveSnackBar.show(
                                          context,
                                          message:
                                              l10n.couldNotUnblockUserTryAgain,
                                          type: AdaptiveSnackBarType.error,
                                        );
                                      }
                                    },
                                    child: Text(l10n.actionUnblock),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Stateful widget that owns the [TextEditingController] used inside the
/// delete-account confirmation dialog. Extracting this avoids the previous
/// anti-pattern of declaring `var confirmText = ''` inside the StatefulBuilder
/// builder with no controller at all — that left the field's internal text
/// unobservable from outside the dialog and made programmatic clearing
/// impossible. The controller here is disposed when the dialog is dismissed.
class _DeleteAccountConfirmField extends StatefulWidget {
  const _DeleteAccountConfirmField({required this.onTextChanged});

  final ValueChanged<String> onTextChanged;

  @override
  State<_DeleteAccountConfirmField> createState() =>
      _DeleteAccountConfirmFieldState();
}

class _DeleteAccountConfirmFieldState
    extends State<_DeleteAccountConfirmField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => widget.onTextChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).typeDeleteToConfirm,
        hintText: AppLocalizations.of(context).deleteKeyword,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
    );
  }
}
