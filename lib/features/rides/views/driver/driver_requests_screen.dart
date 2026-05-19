import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/core/theme/platform_adaptive.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/repositories/driver_stats_repository.dart';
import 'package:sport_connect/features/rides/services/ride_request_service.dart';
import 'package:sport_connect/features/rides/view_models/driver_requests_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Driver Requests Screen — shows pending/accepted/declined bookings.
class DriverRequestsScreen extends ConsumerStatefulWidget {
  const DriverRequestsScreen({super.key});

  @override
  ConsumerState<DriverRequestsScreen> createState() =>
      _DriverRequestsScreenState();
}

class _DriverRequestsScreenState extends ConsumerState<DriverRequestsScreen> {
  final Set<String> _requestActionIds = {};

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(
      pendingRideRequestsProvider.select(
        (requests) => requests.whenOrNull(data: (list) => list.length) ?? 0,
      ),
    );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: AppLocalizations.of(context).rideRequests,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: AdaptiveTabBarView(
          tabs: [
            if (pendingCount > 0)
              '${AppLocalizations.of(context).pending} ($pendingCount)'
            else
              AppLocalizations.of(context).pending,
            AppLocalizations.of(context).accepted,
            AppLocalizations.of(context).declined,
          ],
          selectedColor: Colors.white,
          backgroundColor: AppColors.primary,
          children: [
            _buildPendingBookings(),
            _buildAcceptedBookings(),
            _buildDeclinedBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBookings() {
    final pendingAsync = ref.watch(pendingRideRequestsProvider);
    return pendingAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64.sp,
                  color: AppColors.textTertiary,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noPendingRequests,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).newRideRequestsWillAppear,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Dismissible(
              key: ValueKey('booking_${booking.id}_$index'),
              confirmDismiss: (direction) async {
                unawaited(HapticFeedback.mediumImpact());
                if (direction == DismissDirection.startToEnd) {
                  _handleAccept(booking);
                } else {
                  _handleDecline(booking);
                }
                return false;
              },
              background: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              child: _PendingBookingCard(
                booking: booking,
                onAccept: () => _handleAccept(booking),
                onDecline: () => _handleDecline(booking),
                onMessage: () => _handleMessagePassenger(booking),
                onViewProfile: () => _handleViewProfile(booking),
              ),
            );
          },
        );
      },
      loading: () => const SkeletonLoader(),
      error: (_, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).failedToLoadRequests,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => ref.invalidate(pendingRideRequestsProvider),
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptedBookings() {
    final acceptedAsync = ref.watch(acceptedRideRequestsProvider);
    return acceptedAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64.sp,
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noAcceptedRequestsYet,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).acceptedRequestsWillAppearHere,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _AcceptedBookingCard(
              booking: booking,
              onMessage: () => _handleMessagePassenger(booking),
              onViewDetails: () => _handleViewRideDetails(booking),
            );
          },
        );
      },
      loading: () => const SkeletonLoader(),
      error: (_, _) => Center(
        child: Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
      ),
    );
  }

  Widget _buildDeclinedBookings() {
    final rejectedAsync = ref.watch(rejectedRideRequestsProvider);
    return rejectedAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64.sp,
                  color: AppColors.success.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context).noDeclinedRequests,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context).youHavenTDeclinedAny,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: bookings.length,
          itemBuilder: (context, index) =>
              _DeclinedBookingCard(booking: bookings[index]),
        );
      },
      loading: () => const SkeletonLoader(),
      error: (_, _) => Center(
        child: Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
      ),
    );
  }

  bool _beginRequestAction(String bookingId) {
    if (_requestActionIds.contains(bookingId)) return false;
    setState(() => _requestActionIds.add(bookingId));
    return true;
  }

  void _endRequestAction(String bookingId) {
    if (!mounted) return;
    setState(() => _requestActionIds.remove(bookingId));
  }

  Future<bool> _acceptRideRequest(RideBooking booking) async {
    if (!_beginRequestAction(booking.id)) return false;
    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .acceptRequest(booking.id);
      if (!mounted) return false;
      return switch (result) {
        Success() => _refreshAfterAccept(),
        Failure() => false,
      };
    } finally {
      _endRequestAction(booking.id);
    }
  }

  Future<bool> _declineRideRequest(RideBooking booking, String reason) async {
    if (!_beginRequestAction(booking.id)) return false;
    try {
      final result = await ref
          .read(rideRequestServiceProvider.notifier)
          .rejectRequest(booking.id, reason);
      if (!mounted) return false;
      return switch (result) {
        Success() => _refreshAfterDecline(),
        Failure() => false,
      };
    } finally {
      _endRequestAction(booking.id);
    }
  }

  bool _refreshAfterAccept() {
    ref
      ..invalidate(pendingRideRequestsProvider)
      ..invalidate(acceptedRideRequestsProvider)
      ..invalidate(upcomingDriverRidesProvider);
    return true;
  }

  bool _refreshAfterDecline() {
    ref
      ..invalidate(pendingRideRequestsProvider)
      ..invalidate(rejectedRideRequestsProvider);
    return true;
  }

  void _handleAccept(RideBooking booking) {
    unawaited(HapticFeedback.heavyImpact());
    final scaffoldContext = context;
    final formattedDate = DateFormat(
      'EEE, MMM d',
    ).format(booking.createdAt ?? DateTime.now());
    showDialog<void>(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog.adaptive(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PlatformAdaptive.dialogRadius),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: AppColors.success),
            ),
            SizedBox(width: 12.w),
            Text(AppLocalizations.of(dialogContext).acceptRequest),
          ],
        ),
        content: Text(
          AppLocalizations.of(dialogContext).youAreAboutToAccept(
            'this passenger',
            formattedDate,
            DateFormat('HH:mm').format(booking.createdAt ?? DateTime.now()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(AppLocalizations.of(dialogContext).actionCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              dialogContext.pop();
              final accepted = await _acceptRideRequest(booking);
              if (!mounted || !scaffoldContext.mounted) return;
              final l10n = AppLocalizations.of(scaffoldContext);
              AdaptiveSnackBar.show(
                scaffoldContext,
                message: accepted
                    ? l10n.requestAcceptedValueHasBeen('Passenger')
                    : l10n.failedToAcceptRequest,
                type: accepted
                    ? AdaptiveSnackBarType.success
                    : AdaptiveSnackBarType.error,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text(AppLocalizations.of(dialogContext).accept),
          ),
        ],
      ),
    );
  }

  void _handleDecline(RideBooking booking) {
    unawaited(HapticFeedback.lightImpact());
    final scaffoldContext = context;
    AppModalSheet.show<void>(
      context: scaffoldContext,
      title: AppLocalizations.of(scaffoldContext).declineRequest,
      maxHeightFactor: 0.7,
      child: _DeclineReasonSheet(
        bookingId: booking.id,
        onDecline: (reason) async {
          scaffoldContext.pop();
          final declined = await _declineRideRequest(booking, reason);
          if (!mounted || !scaffoldContext.mounted) return;
          final l10n = AppLocalizations.of(scaffoldContext);
          AdaptiveSnackBar.show(
            scaffoldContext,
            message: declined
                ? l10n.requestDeclined
                : l10n.failedToDeclineRequest,
            type: declined
                ? AdaptiveSnackBarType.success
                : AdaptiveSnackBarType.error,
          );
        },
      ),
    );
  }

  void _handleViewProfile(RideBooking booking) {
    // Navigate to passenger profile
  }

  void _handleViewRideDetails(RideBooking booking) {
    context.pushNamed(
      AppRoutes.rideDetail.name,
      pathParameters: {'id': booking.rideId},
    );
  }

  Future<void> _handleMessagePassenger(RideBooking booking) async {
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
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null || !mounted) {
        if (mounted) context.pop();
        return;
      }

      final passengerProfile = await ref.read(
        userProfileProvider(booking.passengerId).future,
      );

      if (passengerProfile == null || !mounted) {
        if (mounted) context.pop();
        return;
      }

      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: passengerProfile.uid,
          userName1: currentUser.username,
          userName2: passengerProfile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: passengerProfile.photoUrl,
        ).future,
      );

      if (!mounted) return;

      context.pop();

      context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        queryParameters: {
          'receiverId': passengerProfile.uid,
          'receiverName': passengerProfile.username,
          if (passengerProfile.photoUrl != null)
            'receiverPhotoUrl': passengerProfile.photoUrl,
        },
        extra: passengerProfile,
      );
    } on Exception {
      if (!mounted) return;

      context.pop();

      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).failedToCreateChatTryAgain,
        type: AdaptiveSnackBarType.error,
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// PENDING BOOKING CARD — fetches passenger profile lazily
// ─────────────────────────────────────────────────────────────────

class _PendingBookingCard extends ConsumerWidget {
  const _PendingBookingCard({
    required this.booking,
    required this.onAccept,
    required this.onDecline,
    required this.onMessage,
    required this.onViewProfile,
  });

  final RideBooking booking;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onMessage;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      userProfileProvider(booking.passengerId).select((a) => a.value),
    );
    final ride = ref.watch(
      requestCardRideProvider(booking.rideId).select((a) => a.value),
    );
    final pickupAddress =
        booking.pickupLocation?.address ?? ride?.origin.address ?? '—';
    final dropoffAddress =
        booking.dropoffLocation?.address ?? ride?.destination.address ?? '—';
    final passengerName = profile?.username ?? '…';
    final passengerPhoto = profile?.photoUrl;
    final passengerRating = profile?.asRider?.rating.average ?? 0.0;
    final pricePerSeatInCents = ride?.pricePerSeatInCents ?? 0.0;
    final formattedDate = DateFormat(
      'EEE, MMM d',
    ).format(booking.createdAt ?? DateTime.now());
    final formattedTime = DateFormat(
      'HH:mm',
    ).format(booking.createdAt ?? DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        boxShadow: AppSpacing.shadowMd,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16.sp,
                  color: AppColors.warning,
                ),
                SizedBox(width: 6.w),
                Text(
                  AppLocalizations.of(context).requestedValue(formattedDate),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.warning,
                  ),
                ),
                const Spacer(),
                if (pricePerSeatInCents > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '€${((pricePerSeatInCents * booking.seatsBooked) / 100).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Passenger info
                GestureDetector(
                  onTap: onViewProfile,
                  child: Row(
                    children: [
                      PremiumAvatar(
                        imageUrl: passengerPhoto,
                        name: passengerName,
                        size: 54.w,
                        hasBorder: true,
                        borderColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  passengerName,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16.sp,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.starFilled,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  passengerRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  AppLocalizations.of(context).valueSeatValue2(
                                    booking.seatsBooked,
                                    booking.seatsBooked > 1 ? 's' : '',
                                  ),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.adaptive.arrow_forward_rounded,
                        size: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                // Route
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              pickupAddress,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 5.w),
                        child: Row(
                          children: [
                            Container(
                              width: 2,
                              height: 28.h,
                              color: AppColors.border,
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).valueSeatValueRequested(
                                booking.seatsBooked,
                                booking.seatsBooked > 1 ? 's' : '',
                              ),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.error,
                            size: 14.sp,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              dropoffAddress,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                // Time / seats chips
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: AppLocalizations.of(
                        context,
                      ).dateAtTime(formattedDate, formattedTime),
                    ),
                    SizedBox(width: 8.w),
                    _InfoChip(
                      icon: Icons.airline_seat_recline_normal_rounded,
                      label:
                          '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                    ),
                  ],
                ),
                // Passenger note
                if (booking.note != null && booking.note!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            booking.note!,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                // Actions
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: profile == null ? null : onMessage,
                        icon: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18.sp,
                        ),
                        label: Text(
                          AppLocalizations.of(context).messagePassenger,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.45),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onDecline,
                            icon: Icon(Icons.close_rounded, size: 18.sp),
                            label: Text(AppLocalizations.of(context).decline),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onAccept,
                            icon: Icon(Icons.check_rounded, size: 18.sp),
                            label: Text(AppLocalizations.of(context).accept),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// ACCEPTED BOOKING CARD
// ─────────────────────────────────────────────────────────────────

class _AcceptedBookingCard extends ConsumerWidget {
  const _AcceptedBookingCard({
    required this.booking,
    required this.onMessage,
    required this.onViewDetails,
  });
  final RideBooking booking;
  final VoidCallback onMessage;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(
      userProfileProvider(booking.passengerId).select((a) => a.value),
    );
    final ride = ref.watch(
      requestCardRideProvider(booking.rideId).select((a) => a.value),
    );
    final pickupAddress =
        booking.pickupLocation?.address ?? ride?.origin.address ?? '—';
    final dropoffAddress =
        booking.dropoffLocation?.address ?? ride?.destination.address ?? '—';
    final passengerName = profile?.username ?? '…';
    final pricePerSeatInCents = ride?.pricePerSeatInCents ?? 0.0;
    final formattedDate = DateFormat(
      'EEE, MMM d',
    ).format(booking.createdAt ?? DateTime.now());

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      passengerName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (booking.respondedAt != null)
                      Text(
                        AppLocalizations.of(context).acceptedValue(
                          DateFormat('MMM d').format(booking.respondedAt!),
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              if (pricePerSeatInCents > 0)
                Text(
                  '€${((pricePerSeatInCents * booking.seatsBooked) / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '$pickupAddress → $dropoffAddress',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Text(
                AppLocalizations.of(context).valueAtValue(
                  formattedDate,
                  DateFormat(
                    'HH:mm',
                  ).format(booking.createdAt ?? DateTime.now()),
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(
                Icons.people_rounded,
                size: 14.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(width: 4.w),
              Text(
                AppLocalizations.of(context).valueSeats(booking.seatsBooked),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onMessage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(AppLocalizations.of(context).message),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(AppLocalizations.of(context).viewDetails),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DECLINED BOOKING CARD
// ─────────────────────────────────────────────────────────────────

class _DeclinedBookingCard extends ConsumerWidget {
  const _DeclinedBookingCard({required this.booking});
  final RideBooking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerName =
        ref
            .watch(
              userProfileProvider(booking.passengerId).select((a) => a.value),
            )
            ?.username ??
        '…';
    final ride = ref.watch(
      requestCardRideProvider(booking.rideId).select((a) => a.value),
    );
    final pickupAddress =
        booking.pickupLocation?.address ?? ride?.origin.address ?? '—';
    final dropoffAddress =
        booking.dropoffLocation?.address ?? ride?.destination.address ?? '—';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel_rounded,
              color: AppColors.error,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passengerName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (booking.respondedAt != null)
                  Text(
                    AppLocalizations.of(context).declinedValue(
                      DateFormat('MMM d').format(booking.respondedAt!),
                    ),
                    style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                  ),
                SizedBox(height: 4.h),
                Text(
                  '$pickupAddress → $dropoffAddress',
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
}

// ─────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DeclineReasonSheet extends StatefulWidget {
  const _DeclineReasonSheet({required this.bookingId, required this.onDecline});
  final String bookingId;
  final Future<void> Function(String) onDecline;

  @override
  State<_DeclineReasonSheet> createState() => _DeclineReasonSheetState();
}

class _DeclineReasonSheetState extends State<_DeclineReasonSheet> {
  final _reasons = [
    'Schedule conflict',
    'Route not convenient',
    'Vehicle unavailable',
    'Personal emergency',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(
          declineReasonSheetViewModelProvider(widget.bookingId),
        );
        final notifier = ref.read(
          declineReasonSheetViewModelProvider(widget.bookingId).notifier,
        );

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 20.h),
              Text(
                AppLocalizations.of(context).declineRequest,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              ..._reasons.map(
                (reason) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: InkWell(
                    onTap: () => notifier.selectReason(reason),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: state.selectedReason == reason
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: state.selectedReason == reason
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.selectedReason == reason
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: state.selectedReason == reason
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            reason,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: state.selectedReason == reason
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (state.selectedReason == 'Other') ...[
                SizedBox(height: 12.h),
                TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).pleaseSpecify,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 2,
                  onChanged: notifier.setOtherText,
                ),
              ],
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(AppLocalizations.of(context).actionCancel),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.canSubmit
                          ? () => widget.onDecline(state.resolvedReason)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: Text(AppLocalizations.of(context).decline),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.viewInsetsOf(context).bottom),
            ],
          ),
        );
      },
    );
  }
}
