import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/features/admin/views/admin_design_system.dart';
import 'package:sport_connect/features/admin/views/admin_kit.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Rides oversight: segmented live/upcoming/completed/cancelled streams.
class AdminRidesTab extends ConsumerStatefulWidget {
  const AdminRidesTab({super.key});

  @override
  ConsumerState<AdminRidesTab> createState() => _AdminRidesTabState();
}

class _AdminRidesTabState extends ConsumerState<AdminRidesTab> {
  AdminRideSegment _seg = AdminRideSegment.upcoming;

  String _pretty(String s) => switch (s) {
        'inProgress' => 'Live',
        'active' => 'Active',
        _ => s[0].toUpperCase() + s.substring(1),
      };

  String _relative(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (!diff.isNegative && diff.inHours < 24) return 'in ${diff.inHours}h';
    if (diff.isNegative && diff.inHours.abs() < 24) {
      return '${diff.inHours.abs()}h ago';
    }
    return DateFormat.MMMd().add_Hm().format(dt);
  }

  void _select(AdminRideSegment seg) {
    HapticFeedback.selectionClick();
    setState(() => _seg = seg);
  }

  @override
  Widget build(BuildContext context) {
    final ridesAsync = ref.watch(adminRidesSegmentProvider(_seg));
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(OpsDS.padScreen.w, OpsDS.s3.h,
              OpsDS.padScreen.w, OpsDS.s2.h),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<AdminRideSegment>(
              segments: [
                for (final seg in AdminRideSegment.values)
                  ButtonSegment(value: seg, label: Text(switch (seg) {
                    AdminRideSegment.live => l10n.sectionLiveNow,
                    AdminRideSegment.upcoming => l10n.sectionUpcoming,
                    AdminRideSegment.completed => l10n.sectionCompleted,
                    AdminRideSegment.cancelled => l10n.sectionCancelled,
                  })),
              ],
              selected: {_seg},
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  TextStyle(fontSize: 11.sp),
                ),
              ),
              onSelectionChanged: (s) => _select(s.first),
            ),
          ),
        ),
        Expanded(
          child: ridesAsync.when(
            loading: () => const KitShimmerList(items: 6),
            error: (e, _) => KitErrorState(
              error: e,
              onRetry: () => ref.invalidate(adminRidesSegmentProvider(_seg)),
            ),
            data: (rides) {
              if (rides.isEmpty) {
                return KitEmptyState(
                  icon: Icons.search_off_rounded,
                  title: AppLocalizations.of(context).noResults,
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(adminRidesSegmentProvider(_seg)),
                child: ListView.builder(
                  padding: EdgeInsets.all(OpsDS.padScreen.w),
                  itemCount: rides.length,
                  itemBuilder: (context, i) {
                    final ride = rides[i];
                    final dep = ride.schedule.departureTime.toLocal();
                    return KitTile(
                      status: kitStatusFrom(ride.status.name),
                      leading: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(OpsDS.rSm),
                        ),
                        child: Icon(Icons.directions_car_rounded,
                            size: 17.sp, color: AppColors.primaryDark),
                      ),
                      title:
                          '${ride.route.origin.shortDisplay} → ${ride.route.destination.shortDisplay}',
                      subtitle:
                          '${DateFormat.MMMd().format(dep)} · ${DateFormat.Hm().format(dep)} · ${_relative(dep)}',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KitStatusPill(
                            kitStatusFrom(ride.status.name),
                            label: _pretty(ride.status.name),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 18.sp, color: AppColors.textTertiary),
                        ],
                      ),
                      onTap: () => _showActions(ride),
                    )
                        .animate()
                        .fadeIn(
                          duration: OpsDS.durMed,
                          delay: Duration(
                              milliseconds: 40 * i.clamp(0, 6)),
                        )
                        .slideX(begin: 0.03, curve: OpsDS.curveEase);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showActions(RideModel ride) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(OpsDS.rSheet.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          OpsDS.s5.w,
          OpsDS.s4.h,
          OpsDS.s5.w,
          MediaQuery.paddingOf(ctx).bottom + OpsDS.s5.h,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: OpsDS.s4.h),
              Text(
                '${ride.route.origin.shortDisplay} → '
                '${ride.route.destination.shortDisplay}',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: OpsDS.s3.h),
              KitInfoRow(
                label: 'Status',
                value: _pretty(ride.status.name),
              ),
              KitInfoRow(
                label: 'Departure',
                value: DateFormat.MMMEd().add_Hm().format(ride.schedule.departureTime.toLocal()),
              ),
              SizedBox(height: OpsDS.s5.h),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await ref
                        .read(adminRepositoryProvider)
                        .adminCancelRide(rideId: ride.id);
                    if (!mounted) return;
                    ref.invalidate(adminRidesSegmentProvider(_seg));
                    AdaptiveSnackBar.show(
                      context,
                      message: l10n.actionCancelRide,
                      type: AdaptiveSnackBarType.success,
                    );
                  } on Exception catch (e) {
                    if (!mounted) return;
                    AdaptiveSnackBar.show(
                      context,
                      message: e.toString(),
                      type: AdaptiveSnackBarType.error,
                    );
                  }
                },
                icon: const Icon(Icons.cancel_rounded),
                label: Text(l10n.actionCancelRide),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
