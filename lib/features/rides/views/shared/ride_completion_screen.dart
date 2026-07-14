import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/stripe_config.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/core/widgets/driver_info_widget.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_completion_view_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

/// Ride Completion / Trip Summary screen shown after a ride finishes.
///
/// Displays:
/// - Success confetti-style header
/// - Route summary with origin/destination
/// - Trip duration, distance, and CO2 saved
/// - Fare breakdown (base, service fee, total)
/// - Driver/rider info with avatar and rating
/// - Share receipt
/// - Rating & review CTA
class RideCompletionScreen extends ConsumerStatefulWidget {
  const RideCompletionScreen({required this.rideId, super.key});
  final String rideId;

  @override
  ConsumerState<RideCompletionScreen> createState() =>
      _RideCompletionScreenState();
}

class _RideCompletionScreenState extends ConsumerState<RideCompletionScreen> {
  int? _averageSpeedKmh(RideModel ride) {
    final distanceKm = ride.route.distanceKm;
    final durationMinutes = ride.route.durationMinutes;
    if (distanceKm == null || durationMinutes == null) return null;
    if (!distanceKm.isFinite || durationMinutes <= 0) return null;

    final speed = distanceKm / (durationMinutes / 60);
    if (!speed.isFinite || speed < 0) return null;
    return speed.round();
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final uiState = ref.watch(rideCompletionUiViewModelProvider(widget.rideId));
    final bookings =
        ref.watch(
          bookingsByRideProvider(widget.rideId).select((a) => a.value),
        ) ??
        const <RideBooking>[];
    final l10n = AppLocalizations.of(context);
    final maxWidth = context.screenWidth >= Breakpoints.medium
        ? 1440.0
        : kMaxWidthForm;

    ref.listen<RideCompletionUiState>(
      rideCompletionUiViewModelProvider(widget.rideId),
      (previous, next) {
        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage &&
            context.mounted) {
          AdaptiveSnackBar.show(
            context,
            message: next.errorMessage!,
            type: AdaptiveSnackBarType.error,
          );
        }
      },
    );

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: maxWidth,
        child: rideAsync.when(
          loading: () => const SkeletonLoader(),
          error: (e, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.somethingWentWrong,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).unable_to_load_ride_completion_details,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.invalidate(rideStreamProvider(widget.rideId)),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (ride) {
            if (ride == null) {
              return Center(child: Text(l10n.rideNotFound));
            }
            return _buildContent(context, ref, ride, l10n, bookings, uiState);
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
    List<RideBooking> bookings,
    RideCompletionUiState uiState,
  ) {
    final useTabletLayout = context.screenWidth >= Breakpoints.medium;

    Widget routeMapSection() {
      if (uiState.osrmRouteRideId != ride.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(rideCompletionUiViewModelProvider(widget.rideId).notifier)
              .ensureRouteLoaded(ride);
        });
      }
      return _buildCompletedRouteMap(ride, uiState);
    }

    final header = _buildSuccessHeader(
      context,
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8));
    final routeMap = routeMapSection().animate().fadeIn(delay: 100.ms);
    final impactCard = _buildImpactCard(
      context,
      ride,
      bookings,
    ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05);
    final summaryCard = _buildTripSummaryCard(
      context,
      ride,
      l10n,
      bookings,
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05);
    final fareCard = _buildFareBreakdownCard(
      context,
      ride,
      l10n,
      bookings,
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05);
    final participantCard = _buildParticipantCard(
      context,
      ref,
      ride,
      l10n,
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05);
    final actionsPanel = _buildActionPanel(
      context,
      ref,
      ride,
      l10n,
      uiState,
    );

    if (!useTabletLayout) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              header,
              SizedBox(height: 24.h),
              routeMap,
              SizedBox(height: 16.h),
              impactCard,
              SizedBox(height: 16.h),
              summaryCard,
              SizedBox(height: 16.h),
              fareCard,
              SizedBox(height: 16.h),
              participantCard,
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: actionsPanel,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      header,
                      SizedBox(height: 24.h),
                      routeMap,
                      SizedBox(height: 16.h),
                      impactCard,
                      SizedBox(height: 16.h),
                      summaryCard,
                    ],
                  ),
                ),
                SizedBox(width: 24.w),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      fareCard,
                      SizedBox(height: 16.h),
                      participantCard,
                      SizedBox(height: 16.h),
                      actionsPanel,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPanel(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
    RideCompletionUiState uiState,
  ) {
    return Column(
      children: [
        Builder(
          builder: (ctx) {
            final uid = ref.read(currentAuthUidProvider).value;
            final isDriver = uid == ride.driverId;

            return SizedBox(
              width: double.infinity,
              child: isDriver
                  ? PremiumButton(
                      text: AppLocalizations.of(context).ratePassenger,
                      onPressed: () {
                        unawaited(HapticFeedback.mediumImpact());
                        context.push(
                          AppRoutes.driverRatePassenger.path.replaceFirst(
                            ':rideId',
                            widget.rideId,
                          ),
                        );
                      },
                      icon: Icons.star_rounded,
                    )
                  : PremiumButton(
                      text: AppLocalizations.of(context).rateAndReview,
                      onPressed: () async {
                        unawaited(HapticFeedback.mediumImpact());
                        final driverProfile = await ref.read(
                          userProfileProvider(ride.driverId).future,
                        );

                        if (!ctx.mounted) return;

                        ctx.push(
                          '${AppRoutes.submitReview.path}'
                          '?rideId=${widget.rideId}'
                          '&revieweeId=${ride.driverId}'
                          '&revieweeName=${Uri.encodeComponent(driverProfile?.username ?? l10n.driver)}'
                          '&reviewType=driverReview',
                        );
                      },
                      icon: Icons.star_rounded,
                    ),
            );
          },
        ).animate().fadeIn(delay: 550.ms),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: uiState.isGeneratingPdf
                  ? const Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : PremiumButton(
                      text: AppLocalizations.of(context).shareReceipt,
                      onPressed: () async {
                        unawaited(HapticFeedback.lightImpact());
                        final l10n = AppLocalizations.of(context);
                        await ref
                            .read(
                              rideCompletionUiViewModelProvider(
                                widget.rideId,
                              ).notifier,
                            )
                            .shareReceipt(
                              ride,
                              receiptTitle: l10n.receiptTitle,
                              fromLabel: l10n.fromLabel,
                              toLabel: l10n.toLabel,
                              dateLabel: l10n.dateLabel,
                              driverLabel: l10n.driver,
                              baseFareLabel: l10n.receiptBaseFare,
                              serviceFeeLabel: l10n.receiptServiceFee,
                              totalLabel: l10n.totalLabel,
                              rideIdLabel: l10n.receiptRideId,
                            );
                      },
                      style: PremiumButtonStyle.secondary,
                      icon: Icons.receipt_long_rounded,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: PremiumButton(
                text: AppLocalizations.of(context).reportIssue,
                onPressed: () {
                  context.pushNamed(
                    AppRoutes.dispute.name,
                    pathParameters: {'id': widget.rideId},
                  );
                },
                style: PremiumButtonStyle.ghost,
                icon: Icons.flag_outlined,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 650.ms),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: PremiumButton(
            text: AppLocalizations.of(context).bookThisRouteAgain,
            onPressed: () {
              unawaited(HapticFeedback.lightImpact());
              context.pushNamed(
                AppRoutes.searchRides.name,
                extra: <String, dynamic>{
                  'address': ride.destination.address,
                  'latitude': ride.destination.latitude,
                  'longitude': ride.destination.longitude,
                },
              );
            },
            style: PremiumButtonStyle.secondary,
            icon: Icons.replay_rounded,
          ),
        ).animate().fadeIn(delay: 700.ms),
        SizedBox(height: 16.h),
        Builder(
          builder: (_) {
            final uid = ref.read(currentAuthUidProvider).value;
            final isDriver = uid == ride.driverId;

            if (isDriver) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: PremiumButton(
                  text: AppLocalizations.of(context).instantPayout,
                  onPressed: () {
                    unawaited(HapticFeedback.lightImpact());
                    context.goNamed(
                      AppRoutes.driverEarnings.name,
                      extra: {'resetBranch': true},
                    );
                  },
                  icon: Icons.euro_rounded,
                ),
              ).animate().fadeIn(delay: 720.ms);
            }
            return const SizedBox.shrink();
          },
        ),
        TextButton(
          onPressed: () {
            final uid = ref.read(currentAuthUidProvider).value;
            final isDriver = uid == ride.driverId;
            context.goNamed(
              isDriver ? AppRoutes.driverHome.name : AppRoutes.home.name,
              extra: {'resetBranch': true},
            );
          },
          child: Text(
            l10n.goHome,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().fadeIn(delay: 750.ms),
      ],
    );
  }

  Widget _buildSuccessHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withValues(alpha: 0.15),
                AppColors.success.withValues(alpha: 0.05),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_rounded,
            size: 64.sp,
            color: AppColors.success,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          AppLocalizations.of(context).trip_completed,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context).thanks_for_riding_with_sportconnect,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildImpactCard(
    BuildContext context,
    RideModel ride,
    List<RideBooking> bookings,
  ) {
    final l10n = AppLocalizations.of(context);
    // Estimate: carpooling saves ~120g CO2/km on average
    final riders = bookings.length.clamp(1, 10);
    final distanceKm = ride.route.distanceKm ?? 15.0;
    final totalSharedKm = (riders * distanceKm).toStringAsFixed(1);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: adaptiveScreenPadding(context).copyWith(bottom: 16.h, top: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF43A047).withValues(alpha: 0.12),
            const Color(0xFF66BB6A).withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF43A047).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.route_rounded,
              size: 24.sp,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.rideSharedDistanceSummary(totalSharedKm),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  l10n.rideCarpooledWithCount(riders),
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

  Widget _buildCompletedRouteMap(
    RideModel ride,
    RideCompletionUiState uiState,
  ) {
    final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
    final dest = LatLng(ride.destination.latitude, ride.destination.longitude);
    final center = LatLng(
      (origin.latitude + dest.latitude) / 2,
      (origin.longitude + dest.longitude) / 2,
    );

    final routePoints = uiState.osrmRoutePoints ?? [origin, dest];

    return Container(
      height: 160.h,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
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
                    color: AppColors.success,
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
          // "Completed" badge overlay
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    AppLocalizations.of(context).completed,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
                  color: AppColors.surface,
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
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDistance,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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
                            color: AppColors.textSecondary,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    if (ride.route.durationMinutes != null) ...[
                      Icon(
                        Icons.schedule_rounded,
                        size: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        ride.route.formattedDuration,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
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

  Widget _buildTripSummaryCard(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
    List<RideBooking> bookings,
  ) {
    final averageSpeedKmh = _averageSpeedKmh(ride);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trip_summary,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          // Route
          _buildRouteRow(
            Icons.trip_origin_rounded,
            AppColors.success,
            ride.origin.address,
          ),
          _buildRouteLine(),
          _buildRouteRow(
            Icons.location_on_rounded,
            AppColors.error,
            ride.destination.address,
          ),

          Divider(height: 28.h, color: AppColors.border),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                Icons.calendar_today_rounded,
                AppLocaleFormatters.formatMediumDate(
                  context,
                  ride.departureTime,
                ),
                l10n.date,
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.access_time_rounded,
                AppLocaleFormatters.formatTime(context, ride.departureTime),
                l10n.timeLabel,
              ),
              _buildStatDivider(),
              _buildStatItem(
                Icons.people_rounded,
                '${bookings.length}',
                l10n.ridersLabel,
              ),
            ],
          ),

          // Distance / Duration / Speed row
          if (ride.route.distanceKm != null ||
              ride.route.durationMinutes != null) ...[
            SizedBox(height: 12.h),
            const Divider(height: 1, color: AppColors.border),
            SizedBox(height: 12.h),
            Row(
              children: [
                if (ride.route.distanceKm != null)
                  _buildStatItem(
                    Icons.straighten_rounded,
                    ride.route.formattedDistance,
                    l10n.distance,
                  ),
                if (ride.route.distanceKm != null &&
                    ride.route.durationMinutes != null)
                  _buildStatDivider(),
                if (ride.route.durationMinutes != null)
                  _buildStatItem(
                    Icons.timer_outlined,
                    ride.route.formattedDuration,
                    l10n.duration,
                  ),
                if (averageSpeedKmh != null) ...[
                  _buildStatDivider(),
                  _buildStatItem(
                    Icons.speed_rounded,
                    l10n.avgSpeedKmhValue('$averageSpeedKmh'),
                    l10n.avgSpeedLabel,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Padding(
      padding: EdgeInsets.only(left: 9.w),
      child: Container(height: 24.h, width: 2, color: AppColors.border),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.primary),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 32.h, width: 1, color: AppColors.border);
  }

  Widget _buildFareBreakdownCard(
    BuildContext context,
    RideModel ride,
    AppLocalizations l10n,
    List<RideBooking> bookings,
  ) {
    // Determine actual seats booked by the current user
    final currentUid = ref.read(currentAuthUidProvider).value;
    final isDriver = currentUid == ride.driverId;
    final myBooking = bookings
        .where((b) => b.passengerId == currentUid)
        .firstOrNull;
    final seatsBooked = myBooking?.seatsBooked ?? 1;

    final pricePerSeatInCents = ride.pricePerSeatInCents;
    final baseFare = isDriver
        ? pricePerSeatInCents * (ride.bookedSeats > 0 ? ride.bookedSeats : 1)
        : pricePerSeatInCents * seatsBooked;
    // Use the real platform fee percentage (StripeConfig.platformFeePercent,
    // mirrored server-side as PLATFORM_FEE_PERCENT in functions/src/index.ts)
    // instead of a hardcoded 10% — this screen was showing users a materially
    // incorrect fee (the actual rate is 15%).
    final feeRate = StripeConfig.platformFeePercent / 100;
    final serviceFee = (baseFare * feeRate).roundToDouble();
    final total = baseFare + serviceFee;
    final pricePerSeat = pricePerSeatInCents / 100;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.fare_breakdown,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l10n.paid,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFareRow(
            isDriver
                ? l10n.baseFareSeatCount(
                    ride.bookedSeats > 0 ? ride.bookedSeats : 1,
                  )
                : seatsBooked > 1
                ? l10n.baseFareSeatsByPrice(
                    seatsBooked,
                    AppLocaleFormatters.formatCurrency(context, pricePerSeat),
                  )
                : l10n.receiptBaseFare,
            AppLocaleFormatters.formatCurrencyFromCents(context, baseFare),
          ),
          SizedBox(height: 8.h),
          _buildFareRow(
            l10n.serviceFeeWithRate(
              '${StripeConfig.platformFeePercent.toStringAsFixed(0)}%',
            ),
            AppLocaleFormatters.formatCurrency(context, serviceFee / 100),
          ),
          Divider(height: 24.h),
          _buildFareRow(
            l10n.total,
            AppLocaleFormatters.formatCurrency(context, total / 100),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(
    BuildContext context,
    WidgetRef ref,
    RideModel ride,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DriverInfoWidget(
        driverId: ride.driverId,
        builder: (context, displayName, photoUrl, rating) {
          return Row(
            children: [
              PremiumAvatar(imageUrl: photoUrl, name: displayName),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          l10n.rideCompletionDriverRating(
                            rating.average.toStringAsFixed(1),
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
              ),
              IconButton(
                tooltip: AppLocalizations.of(context).messageDriver,
                onPressed: () async {
                  unawaited(HapticFeedback.lightImpact());
                  final currentUser = ref.read(currentUserProvider).value;
                  if (currentUser == null) return;

                  try {
                    final chat = await ref.read(
                      getOrCreateChatProvider(
                        userId1: currentUser.uid,
                        userId2: ride.driverId,
                        userName1: currentUser.username,
                        userName2: displayName,
                        userPhoto1: currentUser.photoUrl,
                        userPhoto2: photoUrl,
                      ).future,
                    );

                    if (!context.mounted) return;

                    final driverUser = UserModel.driver(
                      uid: ride.driverId,
                      email: '',
                      username: displayName,
                      photoUrl: photoUrl,
                    );

                    context.pushNamed(
                      AppRoutes.chatDetail.name,
                      pathParameters: {'id': chat.id},
                      extra: driverUser,
                    );
                  } on Exception {
                    if (!context.mounted) return;
                    AdaptiveSnackBar.show(
                      context,
                      message: AppLocalizations.of(
                        context,
                      ).failed_to_open_chat_please_try_again,
                      type: AdaptiveSnackBarType.error,
                    );
                  }
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primarySurface,
                ),
                icon: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
