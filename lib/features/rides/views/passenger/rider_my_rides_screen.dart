import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_master_detail_scaffold.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/rider_view_ride_screen.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────────────────

class RiderMyRidesScreen extends ConsumerStatefulWidget {
  const RiderMyRidesScreen({super.key});

  @override
  ConsumerState<RiderMyRidesScreen> createState() => _RiderMyRidesScreenState();
}

class _RiderMyRidesScreenState extends ConsumerState<RiderMyRidesScreen> {
  @override
  Widget build(BuildContext context) {
    final userIdAsync = ref.watch(currentAuthUidProvider);

    return userIdAsync.when(
      loading: () => const _RidesLoadingShell(),
      error: (e, _) => _RidesErrorShell(message: e.toString()),
      data: (userId) {
        if (userId == null) return const _SignInPromptShell();
        final ridesAsync = ref.watch(
          myRidesAsPassengerStreamProvider(userId),
        );
        return ridesAsync.when(
          loading: () => const _RidesLoadingShell(),
          error: (e, _) => _RidesErrorShell(message: e.toString()),
          data: (rides) => _RidesContent(
            rides: rides,
            userId: userId,
            onRefresh: () async =>
                ref.invalidate(myRidesAsPassengerStreamProvider(userId)),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// MAIN CONTENT
// ─────────────────────────────────────────────────────────────────

class _RidesContent extends StatefulWidget {
  const _RidesContent({
    required this.rides,
    required this.userId,
    required this.onRefresh,
  });

  final List<RideModel> rides;
  final String userId;
  final Future<void> Function() onRefresh;

  @override
  State<_RidesContent> createState() => _RidesContentState();
}

class _RidesContentState extends State<_RidesContent> {
  String? _selectedRideId;

  bool get _usesTwoPaneLayout => context.screenWidth >= Breakpoints.medium;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    final active = widget.rides
        .where((r) => r.status == RideStatus.inProgress)
        .toList();
    final upcoming =
        widget.rides
            .where(
              (r) =>
                  r.status == RideStatus.active && r.departureTime.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
    final history =
        widget.rides
            .where(
              (r) =>
                  r.status == RideStatus.completed ||
                  r.status == RideStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => b.departureTime.compareTo(a.departureTime));

    return AdaptiveScaffold(
      body: AdaptiveMasterDetailScaffold(
        master: _buildRidesList(
          active: active,
          upcoming: upcoming,
          history: history,
        ),
        detail: _buildTabletDetail(l10n),
        phone: _buildRidesList(
          active: active,
          upcoming: upcoming,
          history: history,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.searchRides.path),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.search_rounded),
        label: Text(l10n.findACarpoolNow),
      ),
    );
  }

  Widget _buildRidesList({
    required List<RideModel> active,
    required List<RideModel> upcoming,
    required List<RideModel> history,
  }) {
    return RefreshIndicator.adaptive(
      color: AppColors.primary,
      onRefresh: widget.onRefresh,
      child: CustomScrollView(
        slivers: [
          _SliverHeader(
            rideCount: widget.rides.length,
          ),
          if (active.isNotEmpty) _ActiveSection(rides: active),
          _TabBody(
            active: active,
            upcoming: upcoming,
            history: history,
            onRideTap: _openRide,
          ),
        ],
      ),
    );
  }

  Widget _buildTabletDetail(AppLocalizations l10n) {
    final selectedRideId = _selectedRideId;
    if (selectedRideId == null) {
      return TabletEmptyDetail(
        icon: Icons.directions_car_outlined,
        title: l10n.rideDetails,
        message: l10n.noRidesYetSubtitle,
      );
    }

    return RiderViewRideScreen(
      key: ValueKey('rider_ride_$selectedRideId'),
      rideId: selectedRideId,
    );
  }

  void _openRide(String rideId) {
    if (_usesTwoPaneLayout) {
      setState(() => _selectedRideId = rideId);
      return;
    }

    context.pushNamed(
      AppRoutes.riderViewRide.name,
      pathParameters: {'id': rideId},
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SLIVER HEADER
// ─────────────────────────────────────────────────────────────────

class _SliverHeader extends StatelessWidget {
  const _SliverHeader({required this.rideCount});

  final int rideCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canPop = context.canPop();

    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      automaticallyImplyLeading: false, // ← stops Flutter reserving space
      leading: canPop
          ? IconButton(
              tooltip: l10n.goBackTooltip,
              icon: Icon(
                Icons.adaptive.arrow_back_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () => context.pop(),
            )
          : null,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        // left padding: 56 when back button present, 20 when not
        titlePadding: EdgeInsets.only(
          left: canPop ? 50 : 20,
          bottom: 60,
        ),
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l10n.myTrips),
              TextSpan(
                text: '  ·  $rideCount ${l10n.navRides.toLowerCase()}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// TAB BODY (sliver that fills remaining space)
// ─────────────────────────────────────────────────────────────────

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.active,
    required this.upcoming,
    required this.history,
    required this.onRideTap,
  });

  final List<RideModel> active;
  final List<RideModel> upcoming;
  final List<RideModel> history;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: AdaptiveTabBarView(
        tabs: [
          AppLocalizations.of(context).activeRide,
          AppLocalizations.of(context).upcoming,
          AppLocalizations.of(context).history,
        ],
        selectedColor: Colors.white,
        backgroundColor: AppColors.primary,
        children: [
          _ActiveTab(rides: active, onRideTap: onRideTap),
          _UpcomingTab(rides: upcoming, onRideTap: onRideTap),
          _HistoryTab(rides: history, onRideTap: onRideTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE SECTION (inline banner above tabs)
// ─────────────────────────────────────────────────────────────────

class _ActiveSection extends StatelessWidget {
  const _ActiveSection({required this.rides});
  final List<RideModel> rides;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        child: Column(
          children: [for (final r in rides) _ActiveRideCard(ride: r)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE RIDE CARD
// ─────────────────────────────────────────────────────────────────

class _ActiveRideCard extends StatelessWidget {
  const _ActiveRideCard({required this.ride});
  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () =>
          context.push('${AppRoutes.riderActiveRide.path}?rideId=${ride.id}'),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PulsingDot(),
                SizedBox(width: 8.w),
                Text(
                  l10n.rideInProgress,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    l10n.value5(
                      (ride.pricePerSeatInCents / 100).toStringAsFixed(2),
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _RouteRow(
              origin: ride.origin.address,
              destination: ride.destination.address,
              light: true,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                DriverAvatarWidget(driverId: ride.driverId, radius: 14.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: DriverNameWidget(
                    driverId: ride.driverId,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.adaptive.arrow_forward_rounded,
                  size: 14.sp,
                  color: Colors.white70,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05, end: 0),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .scaleXY(begin: 1, end: 1.4, duration: 800.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(begin: 1.4, end: 1, duration: 800.ms, curve: Curves.easeInOut);
  }
}

// ─────────────────────────────────────────────────────────────────
// ACTIVE TAB (shows active + in-progress rides or empty)
// ─────────────────────────────────────────────────────────────────

class _ActiveTab extends StatelessWidget {
  const _ActiveTab({required this.rides, required this.onRideTap});
  final List<RideModel> rides;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (rides.isEmpty) {
      return _EmptyState(
        icon: Icons.directions_car_outlined,
        title: l10n.noRidesYetTitle,
        subtitle: l10n.noRidesYetSubtitle,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: rides.length,
      itemBuilder: (context, i) => _UpcomingRideCard(
        ride: rides[i],
        onTap: () => onRideTap(rides[i].id),
      ).animate().fadeIn(delay: (i * 60).ms, duration: 350.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UPCOMING TAB
// ─────────────────────────────────────────────────────────────────

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab({required this.rides, required this.onRideTap});
  final List<RideModel> rides;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (rides.isEmpty) {
      return _EmptyState(
        icon: Icons.calendar_today_outlined,
        title: l10n.noRidesYetTitle,
        subtitle: l10n.noRidesYetSubtitle,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: rides.length,
      itemBuilder: (context, i) => _UpcomingRideCard(
        ride: rides[i],
        onTap: () => onRideTap(rides[i].id),
      ).animate().fadeIn(delay: (i * 60).ms, duration: 350.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// UPCOMING RIDE CARD
// ─────────────────────────────────────────────────────────────────

class _UpcomingRideCard extends StatelessWidget {
  const _UpcomingRideCard({required this.ride, this.onTap});
  final RideModel ride;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dt = ride.departureTime;
    final dayName = DateFormat('EEE').format(dt);
    final dayNum = DateFormat('d').format(dt);
    final month = DateFormat('MMM').format(dt);
    final time = DateFormat('HH:mm').format(dt);

    return GestureDetector(
      onTap:
          onTap ??
          () => context.pushNamed(
            AppRoutes.riderViewRide.name,
            pathParameters: {'id': ride.id},
          ),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Date block
              Container(
                width: 64.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      dayNum,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      month.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Route & info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RouteRow(
                        origin: ride.origin.address,
                        destination: ride.destination.address,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          DriverAvatarWidget(
                            driverId: ride.driverId,
                            radius: 12.r,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: DriverNameWidget(
                              driverId: ride.driverId,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              l10n.value5(
                                (ride.pricePerSeatInCents / 100)
                                    .toStringAsFixed(2),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HISTORY TAB
// ─────────────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.rides, required this.onRideTap});
  final List<RideModel> rides;
  final ValueChanged<String> onRideTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (rides.isEmpty) {
      return _EmptyState(
        icon: Icons.history_rounded,
        title: l10n.noRidesYetTitle,
        subtitle: l10n.noRidesYetSubtitle,
      );
    }

    // Group by month
    final grouped = <String, List<RideModel>>{};
    for (final ride in rides) {
      final key = DateFormat('MMMM yyyy').format(ride.departureTime);
      grouped.putIfAbsent(key, () => []).add(ride);
    }

    final keys = grouped.keys.toList();
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
      itemCount: keys.length,
      itemBuilder: (context, gi) {
        final month = keys[gi];
        final monthRides = grouped[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, top: gi == 0 ? 0 : 16.h),
              child: Text(
                month,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...monthRides.asMap().entries.map(
              (e) => _HistoryTile(
                ride: e.value,
                index: gi * 10 + e.key,
                onTap: () => onRideTap(e.value.id),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// HISTORY TILE
// ─────────────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.ride, required this.index, this.onTap});
  final RideModel ride;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCancelled = ride.status == RideStatus.cancelled;
    final date = DateFormat('d MMM · HH:mm').format(ride.departureTime);

    return GestureDetector(
      onTap:
          onTap ??
          () => context.pushNamed(
            AppRoutes.riderViewRide.name,
            pathParameters: {'id': ride.id},
          ),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isCancelled
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.successLight.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCancelled
                    ? Icons.cancel_outlined
                    : Icons.check_circle_outline_rounded,
                size: 20.sp,
                color: isCancelled ? AppColors.error : AppColors.success,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ride.origin.address} → ${ride.destination.address}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.value5(
                    (ride.pricePerSeatInCents / 100).toStringAsFixed(2),
                  ),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isCancelled
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 40).ms, duration: 300.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHARED ROUTE ROW
// ─────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.origin,
    required this.destination,
    this.light = false,
  });

  final String origin;
  final String destination;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final primaryColor = light ? Colors.white : AppColors.textPrimary;
    final secondaryColor = light
        ? Colors.white.withValues(alpha: 0.75)
        : AppColors.textSecondary;
    final dotColor = light ? Colors.white : AppColors.primary;
    final lineColor = light
        ? Colors.white.withValues(alpha: 0.4)
        : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1.5, height: 20.h, color: lineColor),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
            ),
          ],
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                origin,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Text(
                destination,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child:
            Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 34.sp, color: AppColors.primary),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SHELL STATES (loading / error / sign-in)
// ─────────────────────────────────────────────────────────────────

class _RidesLoadingShell extends StatelessWidget {
  const _RidesLoadingShell();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.myTrips,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            const SkeletonLoader(itemCount: 1),
            SizedBox(height: 12.h),
            const SkeletonLoader(type: SkeletonType.compactTile),
          ],
        ),
      ),
    );
  }
}

class _RidesErrorShell extends StatelessWidget {
  const _RidesErrorShell({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.myTrips,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.couldNotLoadRides,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInPromptShell extends StatelessWidget {
  const _SignInPromptShell();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: l10n.myTrips,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 56.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.signInToSeeYourRides,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              PremiumButton(
                text: l10n.logIn,
                onPressed: () => context.go(AppRoutes.login.path),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
