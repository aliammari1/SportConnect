import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_config.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.settingsAbout,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: adaptiveScreenPadding(context).copyWith(bottom: 32.h),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Icon(
                    Icons.sports_rounded,
                    size: 34.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.appName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.appVersion(AppConfig.appVersion),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.sportconnectDescription,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 28.h),
            _InfoCard(
              children: [
                _LinkTile(
                  icon: Icons.description_outlined,
                  title: l10n.settingsTermsConditions,
                  onTap: () => context.push(AppRoutes.terms.path),
                ),
                _Divider(),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  onTap: () => context.push(AppRoutes.privacy.path),
                ),
                _Divider(),
                _LinkTile(
                  icon: Icons.help_center_outlined,
                  title: l10n.settingsHelpCenter,
                  onTap: () => context.push(AppRoutes.helpCenter.path),
                ),
                _Divider(),
                _LinkTile(
                  icon: Icons.code_rounded,
                  title: l10n.open_source_licenses,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConfig.appName,
                    applicationVersion: AppConfig.appVersion,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            Text(
              l10n.copyrightNotice,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
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
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16.w,
      endIndent: 16.w,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}
