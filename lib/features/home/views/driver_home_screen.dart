import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/location_service.dart';
import 'package:sport_connect/core/services/push_notification_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/features/home/view_models/driver_location_view_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/profile/view_models/settings_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/driver_stats.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/services/ride_request_service.dart';
import 'package:sport_connect/features/rides/view_models/driver_requests_view_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

Widget _animateDriverHome(
  Widget child,
  Widget Function(Animate animation) builder,
) {
  return builder(child.animate());
}

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  bool _hasAutoNavigatedToActiveRide = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverLocationViewModelProvider.notifier).initialize();
      _requestNotificationPermission();
    });
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final pns = ref.read(pushNotificationServiceProvider);
      if (await pns.hasPermission()) return;
      if (!mounted) return;

      final settings = ref.read(settingsViewModelProvider);
      final settingsNotifier = ref.read(settingsViewModelProvider.notifier);
      if (settings.notificationDialogShown) return;

      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      final accepted = await PermissionDialogHelper.showNotificationRationale(
        context,
      );
      if (!mounted) return;

      await settingsNotifier.setNotificationDialogShown();
      if (!accepted) return;

      await pns.requestPermission();
    } on Exception catch (e, st) {
      // Permission prompts should never block the driver dashboard.
      TalkerService.warning('Notification permission prompt failed: $e');
      TalkerService.error('Notification permission flow error', e, st);
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final accepted = await PermissionDialogHelper.showLocationRationale(
        context,
      );
      if (!mounted) return;
      if (!accepted) return;

      await ref
          .read(driverLocationViewModelProvider.notifier)
          .requestPermission();
    } on Exception catch (e, st) {
      // Keep the home screen usable even if permission handling fails.
      TalkerService.warning('Location permission flow failed: $e');
      TalkerService.error('Location permission flow error', e, st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (
      isLoadingLocation,
      locationGranted,
      locationDenied,
      locationDeniedForever,
      servicesDisabled,
    ) = ref.watch(
      driverLocationViewModelProvider.select(
        (state) => (
          state.isLoading,
          state.locationGranted,
          state.locationDenied,
          state.locationDeniedForever,
          state.servicesDisabled,
        ),
      ),
    );

    final activeRide = ref.watch(
      activeDriverRideProvider.select((value) => value.value),
    );

    if (!_hasAutoNavigatedToActiveRide &&
        activeRide != null &&
        activeRide.status == RideStatus.inProgress) {
      _hasAutoNavigatedToActiveRide = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.push(
          '${AppRoutes.driverActiveRide.path}?rideId=${activeRide.id}',
        );
      });
    }

    return AdaptiveScaffold(
      body: _DriverDashboard(
        isLoadingLocation: isLoadingLocation,
        locationGranted: locationGranted,
        locationDenied: locationDenied,
        locationDeniedForever: locationDeniedForever,
        servicesDisabled: servicesDisabled,
        onRetryLocation: _requestLocationPermission,
        onOpenSettings: () {
          final service = ref.read(locationServiceProvider);
          if (servicesDisabled) {
            service.openLocationSettings();
          } else {
            service.openAppSettings();
          }
        },
      ),
    );
  }
}

class _DriverHomeUserData {
  const _DriverHomeUserData({
    required this.username,
    required this.level,
    required this.maxXP,
    required this.totalXP,
    required this.streak,
    this.photoUrl,
  });

  factory _DriverHomeUserData.from(UserModel user) {
    final level = user.userLevel;
    final gamification = switch (user) {
      RiderModel(:final gamification) => gamification,
      DriverModel(:final gamification) => gamification,
      _ => null,
    };

    final totalXP = gamification?.totalXP ?? 0;
    final streak = gamification?.currentStreak ?? 0;

    return _DriverHomeUserData(
      username: user.username,
      photoUrl: user.photoUrl,
      level: level.level,
      maxXP: level.maxXP.isFinite ? level.maxXP.toInt() : totalXP,
      totalXP: totalXP,
      streak: streak,
    );
  }

  final String username;
  final String? photoUrl;
  final int level;
  final int maxXP;
  final int totalXP;
  final int streak;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _DriverHomeUserData &&
            other.username == username &&
            other.photoUrl == photoUrl &&
            other.level == level &&
            other.maxXP == maxXP &&
            other.totalXP == totalXP &&
            other.streak == streak;
  }

  @override
  int get hashCode => Object.hash(
    username,
    photoUrl,
    level,
    maxXP,
    totalXP,
    streak,
  );
}

class _DriverDashboard extends ConsumerWidget {
  const _DriverDashboard({
    required this.isLoadingLocation,
    required this.locationGranted,
    required this.locationDenied,
    required this.locationDeniedForever,
    required this.servicesDisabled,
    required this.onRetryLocation,
    required this.onOpenSettings,
  });

  final bool isLoadingLocation;
  final bool locationGranted;
  final bool locationDenied;
  final bool locationDeniedForever;
  final bool servicesDisabled;
  final VoidCallback onRetryLocation;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(
      currentUserProvider.select(
        (value) => value.whenData(
          (user) => user == null ? null : _DriverHomeUserData.from(user),
        ),
      ),
    );
    final activeRide = ref.watch(
      activeDriverRideProvider.select((value) => value.value),
    );
    final driverStats = ref.watch(driverStatsProvider);
    final pendingRequests = ref.watch(pendingRideRequestsProvider);
    final upcomingRides = ref.watch(upcomingDriverRidesProvider);

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await Future.wait<Object?>([
          ref.refresh(currentUserProvider.future),
          ref.refresh(activeDriverRideProvider.future),
          ref.refresh(driverStatsProvider.future),
          ref.refresh(pendingRideRequestsProvider.future),
          ref.refresh(upcomingDriverRidesProvider.future),
        ]);
      },
      child: MaxWidthContainer(
        maxWidth: responsiveValue<double>(
          context,
          compact: kMaxWidthWide,
          medium: 1120,
          expanded: 1440,
          large: 1520,
          extraLarge: 1600,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 360;
            final hPad = isSmall ? 14.0 : 20.0;
            final isWideDashboard =
                constraints.maxWidth >= Breakpoints.medium ||
                (context.isTabletOrLarger && context.isLandscape);

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(context, user, l10n, hPad),
                ),
                if (!locationGranted && !isLoadingLocation)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 4.h, hPad, 12.h),
                      child: _buildLocationBanner(l10n),
                    ),
                  ),
                if (isWideDashboard)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 8.h, hPad, 0),
                      child: _buildWideDashboardBody(
                        context: context,
                        ref: ref,
                        l10n: l10n,
                        activeRide: activeRide,
                        pendingRequests: pendingRequests,
                        upcomingRides: upcomingRides,
                        driverStats: driverStats,
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 8.h, hPad, 0),
                      child: _buildDriverCommandCenter(
                        context: context,
                        l10n: l10n,
                        activeRide: activeRide,
                        pendingRequests: pendingRequests,
                        upcomingRides: upcomingRides,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 18.h, hPad, 0),
                      child: _buildTodaySnapshot(l10n, driverStats),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 22.h, hPad, 0),
                      child: _buildPendingRequests(
                        context,
                        ref,
                        l10n,
                        pendingRequests,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 22.h, hPad, 0),
                      child: _buildUpcomingRides(context, l10n, upcomingRides),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 32.h + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWideDashboardBody({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required RideModel? activeRide,
    required AsyncValue<List<RideBooking>> pendingRequests,
    required AsyncValue<List<RideModel>> upcomingRides,
    required AsyncValue<DriverStats> driverStats,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: _buildDriverCommandCenter(
                context: context,
                l10n: l10n,
                activeRide: activeRide,
                pendingRequests: pendingRequests,
                upcomingRides: upcomingRides,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              flex: 5,
              child: _buildTodaySnapshot(l10n, driverStats),
            ),
          ],
        ),
        SizedBox(height: 22.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPendingRequests(
                context,
                ref,
                l10n,
                pendingRequests,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: _buildUpcomingRides(context, l10n, upcomingRides),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AsyncValue<_DriverHomeUserData?> user,
    AppLocalizations l10n,
    double hPad,
  ) {
    final topPad = MediaQuery.paddingOf(context).top;

    final header = Container(
      padding: EdgeInsets.fromLTRB(hPad, topPad + 12.h, hPad, 10.h),
      color: AppColors.background,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.goNamed(
              AppRoutes.profile.name,
              extra: {'resetBranch': true},
            ),
            child: user.when(
              data: (userData) => PremiumAvatar(
                imageUrl: userData?.photoUrl,
                name: userData?.username ?? l10n.driver,
                size: 48.w,
                hasBorder: true,
              ),
              loading: () => CircleAvatar(radius: 24.w),
              error: (_, _) => CircleAvatar(radius: 24.w),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(l10n),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                user.when(
                  data: (userData) => Text(
                    userData?.username ?? l10n.driver,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Text(
                    l10n.loading,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  error: (_, _) => Text(
                    l10n.driver,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            tooltip: l10n.notificationsTooltip,
            icon: Icons.notifications_outlined,
            showBadge: true,
            onTap: () => context.push(AppRoutes.notifications.path),
          ),
          SizedBox(width: 6.w),
          _HeaderIconButton(
            tooltip: l10n.events,
            icon: Icons.event_outlined,
            onTap: () => context.goNamed(AppRoutes.myEvents.name),
          ),
        ],
      ),
    );

    return _animateDriverHome(
      header,
      (animation) => animation.fadeIn(duration: 250.ms),
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildLocationBanner(AppLocalizations l10n) {
    final shouldOpenSettings = locationDeniedForever || servicesDisabled;
    final shouldRequestPermission =
        !locationDenied && !locationDeniedForever && !servicesDisabled;
    final message = locationDenied
        ? l10n.locationNotEnabledDescription
        : l10n.enableLocationForBetterExperience;

    final banner = _SoftCard(
      padding: EdgeInsets.all(14.w),
      borderColor: AppColors.warning.withAlpha(70),
      backgroundColor: AppColors.warning.withAlpha(18),
      child: Row(
        children: [
          const _IconBubble(
            icon: Icons.location_off_rounded,
            color: AppColors.warning,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationRequired,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (shouldOpenSettings || shouldRequestPermission)
            TextButton(
              onPressed: shouldOpenSettings ? onOpenSettings : onRetryLocation,
              child: Text(
                shouldOpenSettings ? l10n.openSettings : l10n.enable,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );

    return _animateDriverHome(
      banner,
      (animation) => animation.fadeIn(duration: 250.ms).slideY(begin: -0.06),
    );
  }

  Widget _buildDriverCommandCenter({
    required BuildContext context,
    required AppLocalizations l10n,
    required RideModel? activeRide,
    required AsyncValue<List<RideBooking>> pendingRequests,
    required AsyncValue<List<RideModel>> upcomingRides,
  }) {
    if (activeRide != null) {
      return _ActiveRideCard(ride: activeRide);
    }

    return pendingRequests.when(
      data: (requests) {
        if (requests.isNotEmpty) {
          return _MainActionCard(
            icon: Icons.person_add_alt_1_rounded,
            title: l10n.passengerRequestCount(requests.length),
            subtitle:
                l10n.review_and_respond_before_passengers_choose_another_ride,
            actionLabel: l10n.viewAll,
            color: AppColors.primary,
            onTap: () => context.push(AppRoutes.driverRequests.path),
          );
        }

        final nextRide = upcomingRides.whenOrNull(
          data: (rides) => rides.isEmpty ? null : rides.first,
        );

        if (nextRide != null) {
          return _NextRideCard(
            ride: nextRide,
            isHero: true,
            onTap: () => context.pushNamed(
              AppRoutes.rideDetail.name,
              pathParameters: {'id': nextRide.id},
            ),
          );
        }

        return _MainActionCard(
          icon: Icons.add_road_rounded,
          title: l10n.ready_for_your_next_trip,
          subtitle: l10n.publish_a_ride_and_start_receiving_passenger_requests,
          actionLabel: l10n.offerRide,
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.driverOfferRide.path),
        );
      },
      loading: () => _buildShimmerCard(height: 128),
      error: (_, _) => _MainActionCard(
        icon: Icons.add_road_rounded,
        title: l10n.ready_for_your_next_trip,
        subtitle: l10n.publish_a_ride_and_start_receiving_passenger_requests,
        actionLabel: l10n.offerRide,
        color: AppColors.primary,
        onTap: () => context.push(AppRoutes.driverOfferRide.path),
      ),
    );
  }

  Widget _buildTodaySnapshot(
    AppLocalizations l10n,
    AsyncValue<DriverStats> stats,
  ) {
    return stats.when(
      data: (driverStats) {
        final today = (driverStats.earningsTodayInCents / 100).toStringAsFixed(
          2,
        );
        final month = (driverStats.earningsThisMonthInCents / 100)
            .toStringAsFixed(0);

        final card = _SoftCard(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todaySEarnings,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      l10n.value6(today),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 46.h,
                color: AppColors.border,
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MiniMetric(
                        label: l10n.totalRides,
                        value: '${driverStats.totalRides}',
                      ),
                      SizedBox(height: 8.h),
                      _MiniMetric(
                        label: l10n.driverThisMonth,
                        value: l10n.value6(month),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        return _animateDriverHome(
          card,
          (animation) => animation.fadeIn(duration: 300.ms, delay: 100.ms),
        );
      },
      loading: () => _buildShimmerCard(height: 104),
      error: (_, _) => _buildErrorCard(l10n.failedToLoadEarnings),
    );
  }

  Widget _buildPendingRequests(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AsyncValue<List<RideBooking>> requestsAsync,
  ) {
    final section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: l10n.rideRequests,
          actionText: l10n.viewAll,
          onActionTap: () => context.push(AppRoutes.driverRequests.path),
        ),
        SizedBox(height: 12.h),
        requestsAsync.when(
          data: (requests) {
            final preview = requests.take(2).toList(growable: false);
            if (preview.isEmpty) {
              return _EmptyPanel(
                icon: Icons.inbox_outlined,
                title: l10n.noPendingRequests,
                subtitle: l10n.newRideRequestsWillAppear,
              );
            }

            return Column(
              children: [
                for (final request in preview)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _RequestCard(
                      request: request,
                      isProcessing: false,
                      onAccept: () async {
                        unawaited(HapticFeedback.heavyImpact());

                        final result = await ref
                            .read(rideRequestServiceProvider.notifier)
                            .acceptRequest(request.id);

                        if (!context.mounted) return;

                        if (result is Success) {
                          ref.invalidate(pendingRideRequestsProvider);
                          ref.invalidate(upcomingDriverRidesProvider);
                        }
                      },
                      onDecline: () async {
                        unawaited(HapticFeedback.lightImpact());

                        final result = await ref
                            .read(rideRequestServiceProvider.notifier)
                            .rejectRequest(request.id, 'Declined by driver');

                        if (!context.mounted) return;

                        if (result is Success) {
                          ref.invalidate(pendingRideRequestsProvider);
                        }
                      },
                    ),
                  ),
              ],
            );
          },
          loading: () => _buildShimmerCard(height: 150),
          error: (_, _) => _buildErrorCard(l10n.failedToLoadRequests),
        ),
      ],
    );

    return _animateDriverHome(
      section,
      (animation) => animation.fadeIn(duration: 300.ms, delay: 150.ms),
    );
  }

  Widget _buildUpcomingRides(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<RideModel>> ridesAsync,
  ) {
    final section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.upcomingRides),
        SizedBox(height: 12.h),
        ridesAsync.when(
          data: (rides) {
            final preview = rides.take(3).toList(growable: false);
            if (preview.isEmpty) {
              return _EmptyPanel(
                icon: Icons.event_available_outlined,
                title: l10n.noUpcomingRides,
                subtitle: l10n.createARideToStartEarning,
              );
            }

            return Column(
              children: [
                for (final ride in preview)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _NextRideCard(
                      ride: ride,
                      onTap: () => context.pushNamed(
                        AppRoutes.rideDetail.name,
                        pathParameters: {'id': ride.id},
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => _buildShimmerCard(height: 108),
          error: (_, _) => _buildErrorCard(l10n.failedToLoadRides),
        ),
      ],
    );

    return _animateDriverHome(
      section,
      (animation) => animation.fadeIn(duration: 300.ms, delay: 200.ms),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    final card = Container(
      height: height.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
      ),
    );

    return Skeletonizer(
      containersColor: AppColors.surface,
      child: card,
    );
  }

  Widget _buildErrorCard(String message) {
    return _SoftCard(
      padding: EdgeInsets.all(14.w),
      backgroundColor: AppColors.error.withAlpha(18),
      borderColor: AppColors.error.withAlpha(45),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final button = AdaptiveTapSurface(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: AppColors.border.withAlpha(100)),
      ),
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: SizedBox(
        width: 42.w,
        height: 42.w,
        child: Icon(
          icon,
          size: 21.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );

    return Tooltip(
      message: tooltip,
      child: showBadge
          ? Badge(
              smallSize: 8.w,
              backgroundColor: AppColors.error,
              child: button,
            )
          : button,
    );
  }
}

class _MainActionCard extends StatelessWidget {
  const _MainActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final card = _SoftCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBubble(icon: icon, color: color, size: 44.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                unawaited(HapticFeedback.mediumImpact());
                onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return _animateDriverHome(
      card,
      (animation) => animation.fadeIn(duration: 300.ms).slideY(begin: 0.04),
    );
  }
}

class _ActiveRideCard extends StatelessWidget {
  const _ActiveRideCard({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final origin = ride.origin.city ?? ride.origin.address;
    final destination = ride.destination.city ?? ride.destination.address;

    final card = _SoftCard(
      padding: EdgeInsets.all(18.w),
      borderColor: AppColors.success.withAlpha(80),
      backgroundColor: AppColors.success.withAlpha(18),
      child: Row(
        children: [
          _IconBubble(
            icon: Icons.navigation_rounded,
            color: AppColors.success,
            size: 46.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).rideInProgress,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$origin → $destination',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          FilledButton(
            onPressed: () {
              unawaited(HapticFeedback.mediumImpact());
              context.push(
                '${AppRoutes.driverActiveRide.path}?rideId=${ride.id}',
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.r),
              ),
            ),
            child: Icon(Icons.arrow_forward_rounded, size: 18.sp),
          ),
        ],
      ),
    );

    return _animateDriverHome(
      card,
      (animation) => animation.fadeIn(duration: 300.ms).slideY(begin: 0.04),
    );
  }
}

class _NextRideCard extends StatelessWidget {
  const _NextRideCard({
    required this.ride,
    required this.onTap,
    this.isHero = false,
  });

  final RideModel ride;
  final VoidCallback onTap;
  final bool isHero;

  @override
  Widget build(BuildContext context) {
    final origin = ride.route.origin.city ?? ride.route.origin.address;
    final destination =
        ride.route.destination.city ?? ride.route.destination.address;
    final departure = ride.schedule.departureTime;
    final earned =
        ((ride.pricing.pricePerSeatInCents * ride.capacity.booked) / 100)
            .toStringAsFixed(2);

    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onTap();
      },
      child: _SoftCard(
        padding: EdgeInsets.all(isHero ? 18.w : 14.w),
        child: Row(
          children: [
            _DateTile(date: departure, isLarge: isHero),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isHero) ...[
                    Text(
                      AppLocalizations.of(context).next_ride,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Text(
                    AppLocalizations.of(
                      context,
                    ).valueValue2(origin, destination),
                    style: TextStyle(
                      fontSize: isHero ? 17.sp : 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocaleFormatters.formatTime(context, departure),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.people_outline_rounded,
                        size: 14.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AppLocalizations.of(context).valueValue(
                          ride.capacity.booked,
                          ride.capacity.available,
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context).value6(earned),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.success,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  AppLocalizations.of(context).earned,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({
    required this.request,
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
  });

  final RideBooking request;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      userProfileProvider(request.passengerId).select((value) => value.value),
    );
    final ride = ref.watch(
      requestCardRideProvider(request.rideId).select((value) => value.value),
    );

    final passengerName = profile?.username ?? '…';
    final passengerRating = profile?.asRider?.rating.average ?? 0.0;
    final pricePerSeatInCents = ride?.pricePerSeatInCents ?? 0.0;
    final total = pricePerSeatInCents * request.seatsBooked;
    final pickupAddress =
        request.pickupLocation?.address ?? ride?.origin.address ?? '—';
    final dropoffAddress =
        request.dropoffLocation?.address ?? ride?.destination.address ?? '—';

    return _SoftCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          Row(
            children: [
              PremiumAvatar(name: passengerName, size: 44.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passengerName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.starFilled,
                          size: 14.sp,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          passengerRating > 0
                              ? passengerRating.toStringAsFixed(1)
                              : AppLocalizations.of(context).kNew,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.event_seat_rounded,
                          size: 14.sp,
                          color: AppColors.textTertiary,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          AppLocalizations.of(context).valueSeatValue(
                            request.seatsBooked,
                            request.seatsBooked > 1 ? 's' : '',
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (total > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    ).value6((total / 100).toStringAsFixed(2)),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          _RoutePreview(
            pickupAddress: pickupAddress,
            dropoffAddress: dropoffAddress,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 15.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  AppLocaleFormatters.formatMediumDateTime(
                    context,
                    request.createdAt ?? DateTime.now(),
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isProcessing || profile == null
                      ? null
                      : () => _openMessageChat(context, ref, profile),
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 15.sp),
                  label: Text(
                    AppLocalizations.of(context).messageButton,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withAlpha(70)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withAlpha(70)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                  child: Text(
                    AppLocalizations.of(context).decline,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                  ),
                  child: isProcessing
                      ? SizedBox(
                          width: 17.w,
                          height: 17.w,
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).accept,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openMessageChat(
    BuildContext context,
    WidgetRef ref,
    UserModel passenger,
  ) async {
    final currentUser = ref.read(currentUserProvider).value;

    if (currentUser == null) {
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).pleaseLoginToViewChats,
        type: AdaptiveSnackBarType.error,
      );
      return;
    }

    unawaited(HapticFeedback.lightImpact());

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: AppLocalizations.of(context).creatingChatLabel,
        builder: (_) => const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ),
    );

    try {
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: passenger.uid,
          userName1: currentUser.username,
          userName2: passenger.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passenger.photoUrl,
        ).future,
      );

      if (!context.mounted) return;

      context.pop();
      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        queryParameters: {
          'receiverId': passenger.uid,
          'receiverName': passenger.username,
          if (passenger.photoUrl != null)
            'receiverPhotoUrl': passenger.photoUrl,
        },
        extra: passenger,
      );
    } on Exception {
      if (!context.mounted) return;

      context.pop();
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToCreateChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }
}

class _RoutePreview extends StatelessWidget {
  const _RoutePreview({
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  final String pickupAddress;
  final String dropoffAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 1, height: 22.h, color: AppColors.border),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickupAddress,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 9.h),
                Text(
                  dropoffAddress,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.date, this.isLarge = false});

  final DateTime date;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLarge ? 58.w : 52.w,
      padding: EdgeInsets.symmetric(vertical: isLarge ? 10.h : 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(14),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withAlpha(35)),
      ),
      child: Column(
        children: [
          Text(
            AppLocaleFormatters.formatMonthLabel(context, date),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            AppLocaleFormatters.formatDayNumber(context, date),
            style: TextStyle(
              fontSize: isLarge ? 21.sp : 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _SoftCard(
      padding: EdgeInsets.all(16.w),
      backgroundColor: AppColors.surface.withAlpha(230),
      child: Row(
        children: [
          _IconBubble(icon: icon, color: AppColors.textTertiary, size: 42.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.25,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionText != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionText!,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: borderColor ?? AppColors.border.withAlpha(95),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.icon,
    required this.color,
    this.size,
  });

  final IconData icon;
  final Color color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final bubbleSize = size ?? 40.w;

    return Container(
      width: bubbleSize,
      height: bubbleSize,
      decoration: BoxDecoration(
        color: color.withAlpha(16),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(icon, color: color, size: 21.sp),
    );
  }
}
