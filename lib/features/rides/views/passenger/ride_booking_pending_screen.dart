import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/pending_booking_view_model.dart';
import 'package:sport_connect/features/rides/views/passenger/ride_countdown_screen.dart'
    show RideCountdownScreen;
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Shown immediately after a passenger submits a booking request.
///
/// Streams the booking status in real-time and auto-navigates when the
/// driver responds:
/// - Accepted → [RideCountdownScreen]
/// - Rejected / Cancelled → back to My Rides
class RideBookingPendingScreen extends ConsumerStatefulWidget {
  const RideBookingPendingScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<RideBookingPendingScreen> createState() =>
      _RideBookingPendingScreenState();
}

class _RideBookingPendingScreenState
    extends ConsumerState<RideBookingPendingScreen> {
  void _showStatusSnackBar(String message, {Color? backgroundColor}) {
    if (!context.mounted) return;
    AdaptiveSnackBar.show(
      context,
      message: message,
      type: AdaptiveSnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingBookingViewModelProvider(widget.rideId));
    final notifier = ref.read(
      pendingBookingViewModelProvider(widget.rideId).notifier,
    );

    ref.listen(pendingBookingViewModelProvider(widget.rideId), (_, _) {
      final vm = ref.read(
        pendingBookingViewModelProvider(widget.rideId).notifier,
      );
      while (vm.hasPendingEffects) {
        final effect = vm.takeEffect();
        if (effect == null || !context.mounted) {
          continue;
        }

        switch (effect.type) {
          case PendingBookingEffectType.navigateCountdown:
            final bookingId = effect.bookingId;
            if (bookingId != null) {
              context.pushReplacement(
                AppRoutes.rideCountdown.path.replaceFirst(
                  ':bookingId',
                  bookingId,
                ),
              );
            }
          case PendingBookingEffectType.navigateMyRides:
            context.go(AppRoutes.riderMyRides.path);
            if (effect.message != null) {
              _showStatusSnackBar(
                effect.message!,
                backgroundColor: AppColors.error,
              );
            }
          case PendingBookingEffectType.navigateActiveRide:
            final rideId = effect.bookingId;
            if (rideId != null) {
              context.pushReplacement(
                '${AppRoutes.riderActiveRide.path}?rideId=$rideId',
              );
            }
          case PendingBookingEffectType.snackbar:
            if (effect.message != null) {
              _showStatusSnackBar(effect.message!);
            }
        }
      }
    });

    return state.rideAsync.when(
      data: (ride) => ride == null
          ? _buildError('Ride not found')
          : _buildContent(ride, state.booking, state, notifier),
      loading: _buildLoading,
      error: (e, _) => _buildError(e.toString()),
    );
  }

  Widget _buildLoading() {
    return const AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
      ),
      body: SkeletonLoader(),
    );
  }

  Widget _buildError(String message) {
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).bookingRequestTitle,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    RideModel ride,
    RideBooking? booking,
    PendingBookingState state,
    PendingBookingViewModel notifier,
  ) {
    final isAcceptedNeedsPayment =
        booking?.status == BookingStatus.accepted && booking?.paidAt == null;
    final hours = state.timeRemaining.inHours;
    final minutes = state.timeRemaining.inMinutes.remainder(60);
    final seconds = state.timeRemaining.inSeconds.remainder(60);
    final expiryText =
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).bookingRequestTitle,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24.w,
            32.h,
            24.w,
            32.h + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            children: [
              // Animated icon
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  color: isAcceptedNeedsPayment
                      ? AppColors.primary.withAlpha(30)
                      : AppColors.success.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAcceptedNeedsPayment
                      ? Icons.payment_rounded
                      : Icons.mark_email_read_rounded,
                  color: isAcceptedNeedsPayment
                      ? AppColors.primary
                      : AppColors.success,
                  size: 48.sp,
                ),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              SizedBox(height: 20.h),

              Text(
                isAcceptedNeedsPayment
                    ? AppLocalizations.of(context).bookingAcceptedTitle
                    : AppLocalizations.of(context).requestSentTitle,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 8.h),

              Text(
                isAcceptedNeedsPayment
                    ? AppLocalizations.of(context).completePaymentMessage
                    : AppLocalizations.of(context).waitingForConfirmation,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 300.ms),

              SizedBox(height: 24.h),

              // Route map preview
              _buildRouteMapPreview(ride).animate().fadeIn(delay: 350.ms),

              SizedBox(height: 16.h),

              // Ride info card
              _buildRideCard(ride).animate().slideY(delay: 400.ms),

              SizedBox(height: 16.h),

              // Driver info — shows who confirmed/offered the ride
              _buildDriverInfoCard(ride).animate().fadeIn(delay: 500.ms),

              SizedBox(height: 24.h),

              // Payment section when driver accepted and online payment is needed
              if (isAcceptedNeedsPayment && booking != null) ...[
                if (state.isProcessingPayment)
                  Column(
                    children: [
                      SizedBox(height: 8.h),
                      const CircularProgressIndicator.adaptive(),
                      SizedBox(height: 12.h),
                      Text(
                        AppLocalizations.of(context).processingPaymentLoading,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                else
                  PremiumButton(
                    text: AppLocalizations.of(context).completePaymentButton,
                    onPressed: notifier.processPayment,
                  ),
                SizedBox(height: 32.h),
              ],

              // Expiry countdown (only when pending)
              if (!isAcceptedNeedsPayment &&
                  booking?.createdAt != null &&
                  state.timeRemaining > Duration.zero)
                _buildExpiryChip(expiryText).animate().fadeIn(delay: 500.ms),

              if (!isAcceptedNeedsPayment) SizedBox(height: 32.h),

              // Cancel request button (only when pending)
              if (booking != null &&
                  booking.status == BookingStatus.pending) ...[
                PremiumButton(
                  text: AppLocalizations.of(context).cancelRequestButton,
                  isLoading: state.isCancelling,
                  style: PremiumButtonStyle.danger,
                  onPressed: notifier.cancelBooking,
                ),
                SizedBox(height: 12.h),
              ],

              TextButton(
                onPressed: () => context.go(AppRoutes.riderMyRides.path),
                child: Text(
                  AppLocalizations.of(context).viewAllMyRidesButton,
                  style: TextStyle(color: AppColors.primary, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteMapPreview(RideModel ride) {
    final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dest = LatLng(ride.destination.latitude, ride.destination.longitude);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    final routePoints =
        ref
            .watch(pendingBookingViewModelProvider(widget.rideId))
            .osrmRoutePoints ??
        [origin, dest];

    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 10,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              const AppMapTileLayer(),
              const CurrentLocationLayer(),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6,
                    color: Colors.white,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                  ),
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: AppColors.primary,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: origin,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.trip_origin_rounded,
                      color: AppColors.success,
                      size: 22.sp,
                    ),
                  ),
                  Marker(
                    point: dest,
                    width: 28.w,
                    height: 28.w,
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.error,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Distance / duration overlay
          if (ride.route.distanceKm != null ||
              ride.route.durationMinutes != null)
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ride.route.distanceKm != null) ...[
                      Icon(
                        Icons.straighten_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDistance,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (ride.route.distanceKm != null &&
                        ride.route.durationMinutes != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          '·',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    if (ride.route.durationMinutes != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDuration,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard(RideModel ride) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Row(
            children: [
              DriverAvatarWidget(driverId: ride.driverId, radius: 22),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 12.sp,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          rating.average.toStringAsFixed(1),
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  AppLocalizations.of(context).yourDriverLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRideCard(RideModel ride) {
    final dep = ride.schedule.departureTime;
    final depText = DateFormat.yMd().add_Hm().format(dep);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin
          Row(
            children: [
              Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.primary,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.origin.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.5.w),
            child: SizedBox(
              height: 18.h,
              child: VerticalDivider(
                width: 1.w,
                color: AppColors.divider,
                thickness: 1.5,
              ),
            ),
          ),
          // Destination
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppColors.error,
                size: 18.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  ride.route.destination.shortDisplay,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          // Metadata row
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4.w),
              Text(
                depText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.euro_rounded,
                size: 14.sp,
                color: AppColors.success,
              ),
              Text(
                CurrencyFormatter.perUnitFromCents(
                  ride.pricing.pricePerSeatInCents,
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryChip(String expiryText) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: AppColors.warning, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            AppLocalizations.of(context).expiresInLabel,
            style: TextStyle(fontSize: 12.sp, color: AppColors.warningDark),
          ),
          Text(
            expiryText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.warningDark,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
