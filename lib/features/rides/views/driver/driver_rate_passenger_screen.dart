import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/driver_rate_passenger_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/features/rides/views/shared/ride_completion_screen.dart'
    show RideCompletionScreen;
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

/// Post-ride screen where a driver rates their passenger(s).
///
/// Route: `/driver/rate-passenger/:rideId`
///
/// Navigated to from [RideCompletionScreen] when the authenticated user is
/// the driver of the completed ride.  The driver selects a passenger (if
/// multiple bookings), picks a 1-5 star rating, optionally adds a comment,
/// and submits the review via the view model.
class DriverRatePassengerScreen extends ConsumerStatefulWidget {
  const DriverRatePassengerScreen({required this.rideId, super.key});

  /// The completed ride ID.
  final String rideId;

  @override
  ConsumerState<DriverRatePassengerScreen> createState() =>
      _DriverRatePassengerScreenState();
}

class _DriverRatePassengerScreenState
    extends ConsumerState<DriverRatePassengerScreen> {
  // Tracks passengers already rated during this on-screen session so the
  // selectable list can exclude them and the screen can decide when every
  // passenger on the ride has been rated. Session-local only — the view
  // model (out of scope for this change) does not persist a rated/unrated
  // flag per booking.
  final Set<String> _ratedBookingIds = {};

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(rideDetailViewModelProvider(widget.rideId));
    final formState = ref.watch(
      driverPassengerRatingViewModelProvider(widget.rideId),
    );

    final bookings = vmState.bookings
        .where(
          (b) =>
              b.status == BookingStatus.accepted ||
              b.status == BookingStatus.completed,
        )
        .toList();

    // Passengers already rated this session are excluded from the
    // selectable list so the driver is guided toward whoever is left.
    final unratedBookings = bookings
        .where((b) => !_ratedBookingIds.contains(b.id))
        .toList();

    if (unratedBookings.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(
              driverPassengerRatingViewModelProvider(widget.rideId).notifier,
            )
            .syncBookings(unratedBookings);
      });
    }

    ref.listen(driverPassengerRatingViewModelProvider(widget.rideId), (
      previous,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: next.errorMessage!,
          type: AdaptiveSnackBarType.error,
        );
      }
      if (next.isSubmitted &&
          previous?.isSubmitted != true &&
          context.mounted) {
        final justRatedBookingId = next.selectedBookingId;
        if (justRatedBookingId != null) {
          setState(() => _ratedBookingIds.add(justRatedBookingId));
        }

        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).ratingSubmittedThankYou,
          type: AdaptiveSnackBarType.success,
        );

        final remaining = bookings
            .where((b) => !_ratedBookingIds.contains(b.id))
            .toList();

        if (remaining.isEmpty) {
          // Every passenger on this ride has been rated.
          context.go(AppRoutes.driverRides.path);
          return;
        }

        // More passengers still need a rating: reset the form and advance
        // to the next unrated one instead of leaving the screen.
        ref
            .read(
              driverPassengerRatingViewModelProvider(widget.rideId).notifier,
            )
          ..selectBooking(remaining.first)
          ..setRating(0)
          ..setComment('');
      }
    });

    return vmState.ride.when(
      data: (ride) {
        if (ride == null) {
          return _buildAdaptiveScaffold(
            body: MaxWidthContainer(
              maxWidth: kMaxWidthFormNarrow,
              child: Center(
                child: Text(AppLocalizations.of(context).rideNotFound),
              ),
            ),
          );
        }
        return _buildContent(ride, unratedBookings, formState);
      },
      loading: () => _buildAdaptiveScaffold(
        body: const SkeletonLoader(
          type: SkeletonType.profileCard,
          itemCount: 3,
        ),
      ),
      error: (e, _) => _buildAdaptiveScaffold(
        body: MaxWidthContainer(
          maxWidth: kMaxWidthFormNarrow,
          child: Center(
            child: Text(AppLocalizations.of(context).errorValue(e)),
          ),
        ),
      ),
    );
  }

  AdaptiveScaffold _buildAdaptiveScaffold({required Widget body}) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).ratePassenger,
      ),
      body: body,
    );
  }

  Widget _buildContent(
    RideModel ride,
    List<RideBooking> bookings,
    DriverPassengerRatingState formState,
  ) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).ratePassenger,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthFormNarrow,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppLocalizations.of(context).how_was_your_passenger,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(),
              SizedBox(height: 6.h),
              Text(
                AppLocalizations.of(
                  context,
                ).your_honest_feedback_helps_build_a_safer_more_reliable_community,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 100.ms),

              SizedBox(height: 28.h),

              if (bookings.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).no_accepted_passengers_to_rate_for_this_ride,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                )
              else ...[
                // Passenger list (always shown, single-select)
                if (bookings.length > 1) ...[
                  Text(
                    AppLocalizations.of(context).select_passenger_to_rate,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
                ...bookings.asMap().entries.map(
                  (entry) => _buildPassengerTile(
                    entry.value,
                    isSelected: formState.selectedBookingId == entry.value.id,
                  ).animate().slideY(delay: (entry.key * 80).ms),
                ),

                SizedBox(height: 28.h),

                // Star rating
                Text(
                  AppLocalizations.of(context).ratePassengerTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starValue = (index + 1).toDouble();
                      return GestureDetector(
                        onTap: () {
                          unawaited(HapticFeedback.selectionClick());
                          ref
                              .read(
                                driverPassengerRatingViewModelProvider(
                                  widget.rideId,
                                ).notifier,
                              )
                              .setRating(starValue);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child:
                              Icon(
                                    formState.rating >= starValue
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: formState.rating >= starValue
                                        ? AppColors.warning
                                        : AppColors.divider,
                                    size: 44.sp,
                                  )
                                  .animate(
                                    target: formState.rating >= starValue
                                        ? 1
                                        : 0,
                                  )
                                  .scale(
                                    begin: const Offset(0.85, 0.85),
                                    end: const Offset(1, 1),
                                    duration: 200.ms,
                                    curve: Curves.easeOut,
                                  ),
                        ),
                      );
                    }),
                  ),
                ),

                if (formState.rating > 0) ...[
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      _getRatingLabel(formState.rating),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 200.ms),
                  ),
                ],

                SizedBox(height: 24.h),

                // Comment field
                Text(
                  AppLocalizations.of(context).additional_comments_optional,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  onChanged: (v) => ref
                      .read(
                        driverPassengerRatingViewModelProvider(
                          widget.rideId,
                        ).notifier,
                      )
                      .setComment(v),
                  controller: TextEditingController(text: formState.comment)
                    ..selection = TextSelection.collapsed(
                      offset: formState.comment.length,
                    ),
                  maxLines: 4,
                  maxLength: 300,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    ).ratePassengerCommentHint,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    counterStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Submit button
                PremiumButton(
                  text: AppLocalizations.of(context).submitRating,
                  isLoading: formState.isSubmitting,
                  isDisabled: !formState.canSubmit,
                  onPressed: formState.canSubmit ? _submitRating : null,
                ),
                SizedBox(height: 12.h),
                Center(
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.driverRides.path),
                    child: Text(
                      AppLocalizations.of(context).skipForNow,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerTile(RideBooking booking, {required bool isSelected}) {
    final passengerAsync = ref.watch(userProfileProvider(booking.passengerId));

    return GestureDetector(
      onTap: () {
        unawaited(HapticFeedback.selectionClick());
        ref
            .read(
              driverPassengerRatingViewModelProvider(widget.rideId).notifier,
            )
            .selectBooking(booking);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            passengerAsync.when(
              data: (profile) => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withAlpha(30),
                backgroundImage: profile?.photoUrl != null
                    ? CachedNetworkImageProvider(profile!.photoUrl!)
                    : null,
                child: profile?.photoUrl == null
                    ? Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 22.sp,
                      )
                    : null,
              ),
              loading: () => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.surface,
                child: SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (_, _) => CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Name & seats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  passengerAsync.when(
                    data: (profile) => Text(
                      profile?.username ??
                          AppLocalizations.of(context).passenger,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    loading: () => Container(
                      height: 14.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    error: (_, _) => Text(
                      AppLocalizations.of(context).passenger,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${booking.seatsBooked} seat${booking.seatsBooked > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(double rating) {
    final l10n = AppLocalizations.of(context);
    if (rating >= 5) return l10n.ratingExcellent;
    if (rating >= 4) return l10n.ratingGood;
    if (rating >= 3) return l10n.ratingAverage;
    if (rating >= 2) return l10n.ratingBelowAverage;
    return l10n.ratingPoor;
  }

  Future<void> _submitRating() async {
    final formState = ref.read(
      driverPassengerRatingViewModelProvider(widget.rideId),
    );
    if (formState.selectedPassengerId == null || formState.rating <= 0) return;
    unawaited(HapticFeedback.mediumImpact());

    try {
      final passengerProfile = ref
          .read(userProfileProvider(formState.selectedPassengerId!))
          .value;

      await ref
          .read(driverPassengerRatingViewModelProvider(widget.rideId).notifier)
          .submit(
            revieweeName:
                passengerProfile?.username ??
                AppLocalizations.of(context).passenger,
            revieweePhotoUrl: passengerProfile?.photoUrl,
          );
    } on Exception catch (e) {
      if (mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(
            context,
          ).failedToSubmitValue(e.toString()),
          type: AdaptiveSnackBarType.error,
        );
      }
    }
  }
}
