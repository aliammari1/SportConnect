import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Reads the current user's active bookings and renders the appropriate
/// trip status banner (in-progress, confirmed, or awaiting driver).
/// Returns an empty box when there is nothing to show.
class ActiveTripBanner extends ConsumerWidget {
  const ActiveTripBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAuthUidProvider).value;
    if (userId == null) return const SizedBox.shrink();

    final bookings = ref.watch(
      bookingsByPassengerProvider(
        userId,
      ).select((a) => a.value ?? const <RideBooking>[]),
    );

    final accepted = bookings
        .where((b) => b.status == BookingStatus.accepted)
        .toList();
    final pending = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();

    if (accepted.isEmpty && pending.isEmpty) return const SizedBox.shrink();

    if (accepted.isNotEmpty) {
      // Resolve each accepted booking's ride so we can choose the genuinely
      // active trip: an in-progress ride wins, otherwise the soonest future
      // departure. Bookings whose ride is completed/cancelled are ignored.
      // Sorting on booking.createdAt (the previous behaviour) could surface a
      // far-future ride while hiding an imminent or in-progress one.
      final candidates = <(RideBooking, RideModel)>[];
      for (final booking in accepted) {
        final ride = ref.watch(
          rideStreamProvider(booking.rideId).select((a) => a.value),
        );
        if (ride == null) continue;
        if (ride.status == RideStatus.completed ||
            ride.status == RideStatus.cancelled) {
          continue;
        }
        candidates.add((booking, ride));
      }

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) {
          final aInProgress = a.$2.status == RideStatus.inProgress;
          final bInProgress = b.$2.status == RideStatus.inProgress;
          if (aInProgress != bInProgress) return aInProgress ? -1 : 1;
          return a.$2.departureTime.compareTo(b.$2.departureTime);
        });
        final (booking, ride) = candidates.first;
        return _acceptedBanner(context, booking, ride);
      }
    }

    return _pendingChip(context, pending);
  }

  Widget _acceptedBanner(
    BuildContext context,
    RideBooking booking,
    RideModel? ride,
  ) {
    final l10n = AppLocalizations.of(context);
    final isInProgress = ride?.status == RideStatus.inProgress;
    // Use paidAt (the explicit payment-completion timestamp) as the source of
    // truth for paid state, matching rider_home_feed.dart. Free rides
    // (pricePerSeatInCents == 0) never get a paidAt and must not be routed to
    // the payment screen, so they only count as needing payment when priced.
    final needsPayment =
        !isInProgress &&
        booking.paidAt == null &&
        (ride?.pricePerSeatInCents ?? 0) > 0;

    final IconData icon;
    final String title;
    final String subtitle;
    final VoidCallback onTap;
    final Color color;

    if (isInProgress) {
      icon = Icons.navigation_rounded;
      title = l10n.rideInProgress;
      subtitle = ride != null
          ? '${ride.origin.address.isNotEmpty ? ride.origin.address : ride.origin.city ?? ride.origin.address} → ${ride.destination.address.isNotEmpty ? ride.destination.address : ride.destination.city ?? ride.destination.address}'
          : l10n.tapToOpenNavigation;
      onTap = () => context.push(
        '${AppRoutes.riderActiveRide.path}?rideId=${booking.rideId}',
      );
      color = AppColors.success;
    } else if (needsPayment) {
      icon = Icons.payment_rounded;
      title = l10n.completePayment;
      subtitle = l10n.bookingAcceptedPaymentRequired;
      onTap = () => context.pushNamed(
        AppRoutes.rideBookingPending.name,
        pathParameters: {'rideId': booking.rideId},
      );
      color = AppColors.warning;
    } else {
      icon = Icons.access_time_rounded;
      title = l10n.bookingConfirmed;
      subtitle = ride != null
          ? l10n.departingValue(_formatDeparture(ride.departureTime, context))
          : l10n.tapToViewCountdown;
      onTap = () => context.pushNamed(
        AppRoutes.rideCountdown.name,
        pathParameters: {'bookingId': booking.id},
      );
      color = AppColors.primary;
    }

    return GestureDetector(
      onTap: onTap,
      child:
          Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(9.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.87),
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideY(begin: 0.25, curve: Curves.easeOutCubic),
    );
  }

  Widget _pendingChip(BuildContext context, List<RideBooking> pending) {
    if (pending.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.riderMyRides.name),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.awaitingDriverCount(pending.length),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }

  String _formatDeparture(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final diff = dt.difference(DateTime.now());
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    if (diff.inDays == 0) return l10n.departingTodayAt(h, m);
    if (diff.inDays == 1) return l10n.departingTomorrow;
    return l10n.departingInDays(diff.inDays);
  }
}
