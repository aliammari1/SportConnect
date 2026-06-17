import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/gamification_widgets.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/rating_value.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/home/view_models/home_view_model.dart';
import 'package:sport_connect/features/home/view_models/rider_home_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Scrollable content-first feed for the Rider Home Screen.
/// Replaces the blank map with an engaging, social feed.
class RiderHomeFeed extends ConsumerWidget {
  const RiderHomeFeed({required this.onSearchTap, super.key});

  /// Callback when the compact search bar is tapped.
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(homeViewModelProvider.select((s) => s.user));

    // Hero (greeting + XP) spans the full width in every layout.
    final hero = MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: _GreetingHeader(user: user, onSearchTap: onSearchTap),
        ),
        SliverToBoxAdapter(child: _GamificationStrip(user: user)),
      ],
    );

    // On a tablet in landscape, use the extra width as a two-column dashboard
    // (rides on the left; events + map on the right) instead of one narrow
    // column. Phones and tablet-portrait keep the single-column feed unchanged.
    final size = MediaQuery.sizeOf(context);
    final isWideLandscape = size.shortestSide >= 600 && size.width > size.height;

    if (isWideLandscape) {
      return CustomScrollView(
        slivers: [
          hero,
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _NextRideSection(),
                        _NearbyRidesSection(),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _EventsNearYouSection(),
                        _MapToggleCard(
                          onTap: () => ref
                              .read(riderHomeViewModelProvider.notifier)
                              .showMap(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        hero,

        // ── Contextual feed ──────────────────────────────────
        MultiSliver(
          children: const [
            SliverToBoxAdapter(child: _NextRideSection()),
            SliverToBoxAdapter(child: _EventsNearYouSection()),
            SliverToBoxAdapter(child: _NearbyRidesSection()),
          ],
        ),

        // ── Map discovery ────────────────────────────────────
        SliverToBoxAdapter(
          child: _MapToggleCard(
            onTap: () =>
                ref.read(riderHomeViewModelProvider.notifier).showMap(),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Greeting Header
// ─────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.user, required this.onSearchTap});

  final AsyncValue<UserModel?> user;
  final VoidCallback onSearchTap;

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final greeting = _getGreeting(l10n);
    final userName = user.whenOrNull(
      data: (u) => u?.username.split(' ').first,
    );

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row with avatar and notifications
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName != null
                            ? '$greeting, $userName!'
                            : '$greeting!',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.whereTo,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification bell
                GestureDetector(
                  onTap: () => context.push(AppRoutes.notifications.path),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.15),

            SizedBox(height: 16.h),

            // Compact search bar
            GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22.sp,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          l10n.whereAreYouGoing,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Gamification Strip
// ─────────────────────────────────────────────────────────────

class _GamificationStrip extends StatelessWidget {
  const _GamificationStrip({required this.user});

  final AsyncValue<dynamic> user;

  @override
  Widget build(BuildContext context) {
    final userData = user.whenOrNull<UserModel?>(data: (u) => u as UserModel?);
    if (userData == null) return const SizedBox.shrink();

    final level = userData.userLevel;
    final gamification = switch (userData) {
      final RiderModel rider => rider.gamification,
      final DriverModel driver => driver.gamification,
      _ => null,
    };
    final totalXP = gamification?.totalXP ?? 0;
    final int streak;
    switch (userData) {
      case RiderModel(:final gamification):
        streak = gamification.currentStreak;
      case DriverModel(:final gamification):
        streak = gamification.currentStreak;
      case _:
        streak = 0;
    }

    return Padding(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 4.h, top: 4.h),
      child: Row(
        children: [
          Expanded(
            child: XPProgressBar(
              currentXP: totalXP,
              maxXP: level.maxXP.isFinite ? level.maxXP.toInt() : totalXP,
              level: level.level,
            ),
          ),
          if (streak > 0) ...[
            SizedBox(width: 12.w),
            StreakCounter(days: streak),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}

// ─────────────────────────────────────────────────────────────
// Next Ride Section
// ─────────────────────────────────────────────────────────────

class _NextRideSection extends ConsumerWidget {
  const _NextRideSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAuthUidProvider).value;
    if (userId == null) return const SizedBox.shrink();

    final bookingsAsync = ref.watch(bookingsByPassengerProvider(userId));

    return bookingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (bookings) {
        // Find upcoming accepted and pending bookings (exclude rejected/cancelled)
        final upcoming = bookings
            .where(
              (b) =>
                  b.status == BookingStatus.accepted ||
                  b.status == BookingStatus.pending,
            )
            .toList();

        if (upcoming.isEmpty) return const SizedBox.shrink();

        // Take the first accepted, or first pending
        final nextBooking = upcoming.firstWhere(
          (b) => b.status == BookingStatus.accepted,
          orElse: () => upcoming.first,
        );

        return _NextRideCard(booking: nextBooking);
      },
    );
  }
}

class _NextRideCard extends ConsumerWidget {
  const _NextRideCard({required this.booking});

  final RideBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rideAsync = ref.watch(rideStreamProvider(booking.rideId));

    return rideAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (ride) {
        if (ride == null) return const SizedBox.shrink();
        // Skip completed/cancelled
        if (ride.status == RideStatus.completed ||
            ride.status == RideStatus.cancelled) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: adaptiveScreenPadding(
            context,
          ).copyWith(bottom: 8.h, top: 8.h),
          child: GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              if (ride.status == RideStatus.inProgress) {
                context.push(
                  '${AppRoutes.riderActiveRide.path}?rideId=${ride.id}',
                );
              } else if (booking.status == BookingStatus.pending) {
                // Pending booking → show pending/waiting screen
                context.push(
                  AppRoutes.rideBookingPending.path.replaceFirst(
                    ':rideId',
                    ride.id,
                  ),
                );
              } else if (booking.status == BookingStatus.accepted &&
                  booking.paidAt == null &&
                  ride.pricePerSeatInCents > 0) {
                // Accepted but payment required (priced ride, unpaid) → go to
                // payment screen. Free rides skip this and go to countdown.
                context.push(
                  AppRoutes.rideBookingPending.path.replaceFirst(
                    ':rideId',
                    ride.id,
                  ),
                );
              } else {
                // Accepted and paid (or no payment required) → go to countdown
                context.push(
                  AppRoutes.rideCountdown.path.replaceFirst(
                    ':bookingId',
                    booking.id,
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.upcomingRidesTitle.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          // Show booking status badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: booking.status == BookingStatus.accepted
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : Colors.orange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              booking.status == BookingStatus.accepted
                                  ? l10n.bookingConfirmed
                                  : l10n.waitingForDriverApproval,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: booking.status == BookingStatus.accepted
                                    ? Colors.green.withValues(alpha: 0.9)
                                    : Colors.orange.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (ride.status == RideStatus.inProgress)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            l10n.rideInProgress,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Route
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${ride.origin.address.isNotEmpty ? ride.origin.address : ride.origin.city ?? ride.origin.address} → '
                          '${ride.destination.address.isNotEmpty ? ride.destination.address : ride.destination.city ?? ride.destination.address}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Details row
                  Row(
                    children: [
                      // Driver info
                      DriverInfoWidget(
                        driverId: ride.driverId,
                        builder: (ctx, name, photo, rating) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PremiumAvatar(
                              imageUrl: photo,
                              name: name,
                              size: 28.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            RatingValue(
                              rating: rating.average,
                              gap: 0,
                              valueStyle: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Date/Time
                      Text(
                        _formatDepartureShort(ride.departureTime, context),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // View Details button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        l10n.viewDetails,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
      },
    );
  }

  String _formatDepartureShort(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localDt = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final departureDay = DateTime(localDt.year, localDt.month, localDt.day);
    final time =
        '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';

    if (departureDay == today) return '${l10n.today}, $time';
    if (departureDay == today.add(const Duration(days: 1))) {
      return '${l10n.tomorrow}, $time';
    }
    return '${localDt.day}/${localDt.month}, $time';
  }
}

// ─────────────────────────────────────────────────────────────
// Events Near You Section
// ─────────────────────────────────────────────────────────────

class _EventsNearYouSection extends ConsumerWidget {
  const _EventsNearYouSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eventsAsync = ref.watch(upcomingEventsStreamProvider);

    return eventsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (events) {
        if (events.isEmpty) return const SizedBox.shrink();

        // Show up to 10 upcoming events
        final upcoming = events.take(10).toList();

        return Padding(
          padding: EdgeInsets.only(left: 20.w, top: 8.h, bottom: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20.w),
                child: Row(
                  children: [
                    _SectionTitle(
                      icon: Icons.emoji_events_rounded,
                      title: l10n.events,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.goNamed(
                        AppRoutes.events.name,
                        extra: {'resetBranch': true},
                      ),
                      child: Text(
                        l10n.seeAll,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                // Headroom so the 2-line title + icon + date row never
                // overflow when fonts render taller (text scaling / tablet
                // scaling). The previous 130.h was too tight and produced
                // overflow stripes on the home events carousel.
                height: 158.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(right: 20.w),
                  itemCount: upcoming.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) =>
                      _EventCard(event: upcoming[index]),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        context.pushNamed(
          AppRoutes.eventDetail.name,
          pathParameters: {'id': event.id},
        );
      },
      child: Container(
        width: 140.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: event.type.color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport icon + type
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: event.type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                event.type.icon,
                color: event.type.color,
                size: 22.sp,
              ),
            ),

            SizedBox(height: 8.h),

            // Title
            Text(
              event.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            // Date + participants
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 11.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    _formatEventDate(event.startsAt, context),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatEventDate(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(dt.year, dt.month, dt.day);

    if (eventDay == today) return l10n.today;
    if (eventDay == today.add(const Duration(days: 1))) return l10n.tomorrow;

    final weekday = DateFormat.E(
      Localizations.localeOf(context).toString(),
    ).format(dt);
    return '$weekday, ${dt.day}/${dt.month}';
  }
}

// ─────────────────────────────────────────────────────────────
// Nearby Rides Section
// ─────────────────────────────────────────────────────────────

class _NearbyRidesSection extends ConsumerWidget {
  const _NearbyRidesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final (anchor, searchRadius) = ref.watch(
      riderHomeViewModelProvider.select(
        (s) => (
          s.nearbyQueryAnchor ?? s.currentLocation ?? const LatLng(0, 0),
          s.searchRadius,
        ),
      ),
    );
    final nearbyRides = ref.watch(
      nearbyRidesStreamProvider(anchor, searchRadius),
    );

    return nearbyRides.when(
      loading: () => Padding(
        padding: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              icon: Icons.directions_car_rounded,
              title: l10n.availableRides,
            ),
            SizedBox(height: 12.h),
            const SkeletonLoader(itemCount: 3),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (rides) {
        if (rides.isEmpty) {
          return Padding(
            padding: adaptiveScreenPadding(
              context,
            ).copyWith(bottom: 8.h, top: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  icon: Icons.directions_car_rounded,
                  title: l10n.availableRides,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 36.sp,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.noRidesAvailableNearby,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12.h),
                      TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.searchRides.path),
                        child: Text(
                          l10n.findARide,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
        }

        // Show up to 5 nearby rides
        final displayRides = rides.take(5).toList();

        return Padding(
          padding: adaptiveScreenPadding(
            context,
          ).copyWith(bottom: 8.h, top: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SectionTitle(
                    icon: Icons.directions_car_rounded,
                    title: l10n.availableRides,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.searchRides.path),
                    child: Text(
                      l10n.seeAll,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ...displayRides.map(
                (ride) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _NearbyRideCard(ride: ride),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
      },
    );
  }
}

class _NearbyRideCard extends StatelessWidget {
  const _NearbyRideCard({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        context.pushNamed(
          AppRoutes.rideDetail.name,
          pathParameters: {'id': ride.id},
        );
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Route row
            Row(
              children: [
                // Route dots
                Column(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 1.5.w,
                      height: 20.h,
                      color: AppColors.border,
                    ),
                    Icon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 14.sp,
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.origin.address.isNotEmpty
                            ? ride.origin.address
                            : ride.origin.city ?? ride.origin.address,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        ride.destination.address.isNotEmpty
                            ? ride.destination.address
                            : ride.destination.city ?? ride.destination.address,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Price badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    l10n.value5(
                      (ride.pricePerSeatInCents / 100).toStringAsFixed(2),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Info chips row
            Row(
              children: [
                // Driver
                DriverInfoWidget(
                  driverId: ride.driverId,
                  builder: (ctx, name, photo, rating) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PremiumAvatar(imageUrl: photo, name: name, size: 24.w),
                      SizedBox(width: 6.w),
                      Text(
                        name.split(' ').first,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      RatingValue(
                        rating: rating.average,
                        iconSize: 12,
                        gap: 0,
                        valueStyle: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Departure time
                Icon(
                  Icons.schedule_rounded,
                  size: 13.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${ride.departureTime.hour.toString().padLeft(2, '0')}:${ride.departureTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 10.w),
                // Seats
                Icon(
                  Icons.event_seat_rounded,
                  size: 13.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4.w),
                Text(
                  l10n.seatsAvailableCount(ride.availableSeats),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Map Toggle Card
// ─────────────────────────────────────────────────────────────

class _MapToggleCard extends StatelessWidget {
  const _MapToggleCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: adaptiveScreenPadding(context).copyWith(bottom: 8.h, top: 8.h),
      child: GestureDetector(
        onTap: () {
          unawaited(HapticFeedback.mediumImpact());
          onTap();
        },
        child: Container(
          padding: adaptiveScreenPadding(
            context,
          ).copyWith(bottom: 16.h, top: 16.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.map_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.exploreOnMap,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.findRidesNearYou,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.adaptive.arrow_forward_rounded,
                color: AppColors.textSecondary,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }
}

// ─────────────────────────────────────────────────────────────
// Shared Section Title Widget
// ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
