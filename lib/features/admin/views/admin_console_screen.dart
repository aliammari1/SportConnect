import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/features/admin/views/admin_design_system.dart';
import 'package:sport_connect/features/admin/views/admin_kit.dart';
import 'package:sport_connect/features/admin/views/admin_money_tab.dart';
import 'package:sport_connect/features/admin/views/admin_ops_pages.dart';
import 'package:sport_connect/features/admin/views/admin_people_tab.dart';
import 'package:sport_connect/features/admin/views/admin_rides_tab.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

enum AdminTab { overview, rides, people, money, more }

/// Ops console shell: adaptive rail / bottom bar hosting the five tabs.
class AdminConsoleScreen extends ConsumerStatefulWidget {
  const AdminConsoleScreen({super.key});

  @override
  ConsumerState<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends ConsumerState<AdminConsoleScreen> {
  AdminTab _tab = AdminTab.overview;

  void _navigate(AdminTab t) => setState(() => _tab = t);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final body = IndexedStack(
      index: _tab.index,
      children: [
        _Overview(onNavigate: _navigate),
        const AdminRidesTab(),
        const AdminPeopleTab(),
        const AdminMoneyTab(),
        const AdminMoreTab(),
      ],
    );

    final appBar = AdaptiveAppBar(
      useNativeToolbar: false,
      leading: IconButton(
        icon: const Icon(Icons.home_outlined),
        onPressed: () => context.go(AppRoutes.home.path),
      ),
      title: l10n.opsConsoleTitle,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return AdaptiveScaffold(
            appBar: appBar,
            body: Row(
              children: [
                SizedBox(
                  width: 220.w,
                  child: _Rail(tab: _tab, onNavigate: _navigate),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }
        return AdaptiveScaffold(
          appBar: appBar,
          bottomNavigationBar: AdaptiveBottomNavigationBar(
            useNativeBottomBar: true,
            items: [
              for (final t in AdminTab.values)
                AdaptiveNavigationDestination(icon: _icon(t, false), label: _label(t, l10n)),
            ],
            selectedIndex: _tab.index,
            onTap: (i) {
              HapticFeedback.selectionClick();
              _navigate(AdminTab.values[i]);
            },
          ),
          body: body,
        );
      },
    );
  }

  String _label(AdminTab t, AppLocalizations l10n) => switch (t) {
        AdminTab.overview => l10n.tabOverview,
        AdminTab.rides => l10n.tabRides,
        AdminTab.people => l10n.tabPeople,
        AdminTab.money => l10n.tabMoney,
        AdminTab.more => l10n.tabMore,
      };

  IconData _icon(AdminTab t, bool selected) => switch (t) {
        AdminTab.overview => selected
            ? Icons.space_dashboard_rounded
            : Icons.space_dashboard_outlined,
        AdminTab.rides =>
          selected ? Icons.directions_car_rounded : Icons.directions_car_outlined,
        AdminTab.people =>
          selected ? Icons.people_rounded : Icons.people_outline_rounded,
        AdminTab.money =>
          selected ? Icons.payments_rounded : Icons.payments_outlined,
        AdminTab.more => Icons.more_horiz_rounded,
      };
}

class _Rail extends StatelessWidget {
  const _Rail({required this.tab, required this.onNavigate});

  final AdminTab tab;
  final ValueChanged<AdminTab> onNavigate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String label(AdminTab t) => switch (t) {
          AdminTab.overview => l10n.tabOverview,
          AdminTab.rides => l10n.tabRides,
          AdminTab.people => l10n.tabPeople,
          AdminTab.money => l10n.tabMoney,
          AdminTab.more => l10n.tabMore,
        };
    IconData icon(AdminTab t, bool selected) => switch (t) {
          AdminTab.overview => selected
              ? Icons.space_dashboard_rounded
              : Icons.space_dashboard_outlined,
          AdminTab.rides =>
            selected ? Icons.directions_car_rounded : Icons.directions_car_outlined,
          AdminTab.people =>
            selected ? Icons.people_rounded : Icons.people_outline_rounded,
          AdminTab.money =>
            selected ? Icons.payments_rounded : Icons.payments_outlined,
          AdminTab.more => Icons.more_horiz_rounded,
        };

    Widget item(AdminTab value) {
      final selected = tab == value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: OpsDS.s2.w, vertical: 2.h),
        child: Material(
          color: selected ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(OpsDS.rSm),
          child: InkWell(
            borderRadius: BorderRadius.circular(OpsDS.rSm),
            onTap: () => onNavigate(value),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: OpsDS.s3.w, vertical: 10.h),
              child: Row(
                children: [
                  Container(width: 3.w, height: 18.h,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(OpsDS.rPill),
                    ),
                  ),
                  SizedBox(width: OpsDS.s3.w),
                  Icon(icon(value, selected),
                      size: 17.sp,
                      color:
                          selected ? AppColors.primary : AppColors.textSecondary),
                  SizedBox(width: OpsDS.s3.w),
                  Expanded(
                    child: Text(
                      label(value),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: OpsDS.s2.h),
        for (final t in AdminTab.values) item(t),
      ],
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.onNavigate});

  final ValueChanged<AdminTab> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(opsOverviewProvider);
    final disputes = ref.watch(adminDisputesProvider);
    final refunds = ref.watch(adminRefundRequestsProvider);

    return overview.when(
      loading: () => ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(OpsDS.padScreen.w),
        children: [
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: BorderRadius.circular(OpsDS.rLg),
            ),
          ).animate(onPlay: (c) => c.repeat()).fade(begin: 0.4, end: 1),
          SizedBox(height: OpsDS.s3.h),
          GridView.count(
            crossAxisCount: MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: OpsDS.s2.w,
            crossAxisSpacing: OpsDS.s2.w,
            childAspectRatio: 1.35,
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(OpsDS.rCard),
                ),
              ).animate(onPlay: (c) => c.repeat()).fade(begin: 0.4, end: 1),
            ),
          ),
        ],
      ),
      error: (e, _) => KitErrorState(
        error: e,
        onRetry: () => ref.invalidate(opsOverviewProvider),
      ),
      data: (data) {
        int n(String key) => (data[key] as num?)?.toInt() ?? 0;
        final total = n('totalBookings7d');
        final cancelled = n('cancelledBookings7d');
        final cancelRate =
            total == 0 ? '—' : '${(cancelled / total * 100).toStringAsFixed(0)}%';

        final attention = <_Attention>[
          if ((refunds.value?.length ?? 0) > 0)
            _Attention(
              icon: Icons.undo_rounded,
              status: KitStatus.pending,
              label: AppLocalizations.of(context).refundsQueue,
              count: refunds.value!.length,
              tab: AdminTab.money,
            ),
          if ((disputes.value?.length ?? 0) > 0 || n('openDisputes') > 0)
            _Attention(
              icon: Icons.gavel_outlined,
              status: KitStatus.danger,
              label: AppLocalizations.of(context).kpiOpenDisputes,
              count: disputes.value?.length ?? n('openDisputes'),
              tab: AdminTab.people,
            ),
        ];

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(opsOverviewProvider),
          child: ListView(
            padding: EdgeInsets.all(OpsDS.padScreen.w),
            children: [
              KitHeroHeader(
                eyebrow: AppLocalizations.of(context).kpiPaymentVolume,
                value: '€${(n('volumeCents7d') / 100).toStringAsFixed(2)}',
                footnote: 'last 7 days',
                trailing: const KitPulseDot(),
              ).animate().fadeIn(duration: OpsDS.durSlow).slideY(
                    begin: 0.06,
                    curve: OpsDS.curveEase,
                  ),
              SizedBox(height: OpsDS.s3.h),
              GridView.count(
                crossAxisCount:
                    MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: OpsDS.s2.w,
                crossAxisSpacing: OpsDS.s2.w,
                childAspectRatio: 1.35,
                children: [
                  KitStatCard(
                    icon: Icons.directions_car_rounded,
                    accent: KitStatus.info.color,
                    label: AppLocalizations.of(context).kpiRidesToday,
                    value: '${n('ridesToday')}',
                  ),
                  KitStatCard(
                    icon: Icons.check_circle_outline_rounded,
                    accent: KitStatus.live.color,
                    label: AppLocalizations.of(context).kpiBookingsCompleted,
                    value: '${n('completedBookings7d')}',
                  ),
                  KitStatCard(
                    icon: Icons.person_add_alt_1_rounded,
                    accent: KitStatus.premium.color,
                    label: AppLocalizations.of(context).kpiNewUsers,
                    value: '${n('newUsers7d')}',
                  ),
                  KitStatCard(
                    icon: Icons.trending_down_rounded,
                    accent: KitStatus.pending.color,
                    label: AppLocalizations.of(context).kpiCancellationRate,
                    value: cancelRate,
                  ),
                ],
              )
                  .animate(delay: 120.ms)
                  .fadeIn(duration: OpsDS.durMed)
                  .slideY(begin: 0.04, curve: OpsDS.curveEase),
              if (attention.isNotEmpty) ...[
                KitSectionHeader(title: 'Needs attention', icon: Icons.notifications_active_outlined),
                for (final item in attention)
                  KitTile(
                    status: item.status,
                    leading: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: item.status.bg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, size: 17.sp, color: item.status.color),
                    ),
                    title: item.label,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KitCountBadge(item.count, color: item.status.color),
                        Icon(Icons.chevron_right_rounded,
                            size: 18.sp, color: AppColors.textTertiary),
                      ],
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onNavigate(item.tab);
                    },
                  ).animate().fadeIn(duration: OpsDS.durMed, delay: 200.ms),
              ],
              KitSectionHeader(title: 'Quick actions'),
              GridView.count(
                crossAxisCount:
                    MediaQuery.sizeOf(context).width > 700 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: OpsDS.s2.w,
                crossAxisSpacing: OpsDS.s2.w,
                childAspectRatio: 1.6,
                children: [
                  KitQuickAction(
                    icon: Icons.flag_outlined,
                    label: AppLocalizations.of(context).reportsQueue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminReportsPage()),
                    ),
                  ),
                  KitQuickAction(
                    icon: Icons.support_agent_outlined,
                    label: AppLocalizations.of(context).supportInbox,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminSupportPage()),
                    ),
                  ),
                  KitQuickAction(
                    icon: Icons.send_outlined,
                    label: AppLocalizations.of(context).broadcastPush,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminCommsPage()),
                    ),
                  ),
                  KitQuickAction(
                    icon: Icons.tune_rounded,
                    label: AppLocalizations.of(context).platformSettings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminSettingsAuditPage()),
                    ),
                  ),
                ],
              ).animate(delay: 260.ms).fadeIn(duration: OpsDS.durMed),
            ],
          ),
        );
      },
    );
  }
}

class _Attention {
  const _Attention({
    required this.icon,
    required this.status,
    required this.label,
    required this.count,
    required this.tab,
  });

  final IconData icon;
  final KitStatus status;
  final String label;
  final int count;
  final AdminTab tab;
}
