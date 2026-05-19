import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/animations/feedback_animations.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class RideBookingReviewScreen extends ConsumerStatefulWidget {
  const RideBookingReviewScreen({
    required this.rideId,
    super.key,
  });

  final String rideId;

  @override
  ConsumerState<RideBookingReviewScreen> createState() =>
      _RideBookingReviewScreenState();
}

class _RideBookingReviewScreenState
    extends ConsumerState<RideBookingReviewScreen> {
  final MapController _mapController = MapController();
  bool _hasCenteredRoute = false;

  RideDetailUiState get _uiState =>
      ref.watch(rideDetailUiViewModelProvider(widget.rideId));

  RideDetailUiViewModel get _uiNotifier =>
      ref.read(rideDetailUiViewModelProvider(widget.rideId).notifier);

  Future<void> _ensureRouteLoaded(RideModel ride) async {
    final route = await _uiNotifier.ensureRouteLoaded(ride);

    if (!mounted || route == null || route.coordinates.length < 2) return;
    if (_hasCenteredRoute) return;

    _hasCenteredRoute = true;

    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    final bounds = LatLngBounds.fromPoints(route.coordinates);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: EdgeInsets.all(38.w),
      ),
    );
  }

  Future<void> _confirmBooking(RideModel ride) async {
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();
    final user = ref.read(currentUserProvider).value;
    final uiState = ref.read(rideDetailUiViewModelProvider(widget.rideId));

    if (user == null) {
      await FeedbackAnimations.showError(
        context,
        message: l10n.pleaseLogInToBook,
      );
      return;
    }

    unawaited(HapticFeedback.heavyImpact());
    _uiNotifier.setBooking(true);

    try {
      final success = await ref
          .read(rideDetailViewModelProvider(widget.rideId).notifier)
          .bookRide(
            passengerId: user.uid,
            seats: uiState.selectedSeats,
            pickupLocation: uiState.pickupLocation,
          );

      if (!mounted) return;

      _uiNotifier.setBooking(false);

      if (!success) {
        await FeedbackAnimations.showError(
          context,
          message: l10n.failedToBookRidePlease,
        );
        return;
      }

      await FeedbackAnimations.showBookingConfirmation(
        context,
        rideInfo:
            '${_placeTitle(ride.origin.address, ride.origin.city)} → '
            '${_placeTitle(ride.destination.address, ride.destination.city)}',
        dateTime: DateFormat.MMMd(
          localeName,
        ).add_jm().format(ride.departureTime),
      );

      if (!mounted) return;

      context.pushReplacement(
        AppRoutes.rideBookingPending.path.replaceFirst(':rideId', ride.id),
      );
    } catch (e) {
      if (!mounted) return;

      _uiNotifier.setBooking(false);

      await FeedbackAnimations.showError(
        context,
        message: l10n.errorValue(e),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref
        .watch(rideDetailViewModelProvider(widget.rideId))
        .ride;
    final maxWidth = context.screenWidth >= Breakpoints.medium
        ? 1440.0
        : kMaxWidthForm;

    return AdaptiveScaffold(
      body: MaxWidthContainer(
        maxWidth: maxWidth,
        child: rideAsync.when(
          loading: _buildLoadingState,
          error: (error, _) => _buildErrorState(error.toString()),
          data: (ride) {
            if (ride == null) {
              return _buildErrorState(
                AppLocalizations.of(context).rideNotFound,
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _ensureRouteLoaded(ride);
            });

            return _buildContent(ride);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Container(
          width: 58.w,
          height: 58.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 28,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 42.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              AppLocalizations.of(context).errorLoadingRide,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                height: 1.4,
              ),
            ),
            SizedBox(height: 28.h),
            _PrimaryActionButton(
              label: AppLocalizations.of(context).goBack,
              icon: Icons.arrow_back_rounded,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RideModel ride) {
    final uiState = _uiState;
    final selectedSeats = uiState.selectedSeats.clamp(1, ride.remainingSeats);
    final currencySymbol = _currencySymbol('eur');
    final pricePerSeat = ride.pricePerSeatInCents / 100;
    final fare = pricePerSeat * selectedSeats;
    final serviceFee = _serviceFee(fare);
    final total = fare + serviceFee;
    final isBooking = uiState.isBooking;
    final useTabletLayout = context.screenWidth >= Breakpoints.medium;

    if (useTabletLayout) {
      return _buildTabletContent(
        ride: ride,
        selectedSeats: selectedSeats,
        currencySymbol: currencySymbol,
        pricePerSeat: pricePerSeat,
        fare: fare,
        serviceFee: serviceFee,
        total: total,
        isBooking: isBooking,
      );
    }

    return _buildMobileContent(
      ride: ride,
      selectedSeats: selectedSeats,
      currencySymbol: currencySymbol,
      pricePerSeat: pricePerSeat,
      fare: fare,
      serviceFee: serviceFee,
      total: total,
      isBooking: isBooking,
    );
  }

  Widget _buildMobileContent({
    required RideModel ride,
    required int selectedSeats,
    required String currencySymbol,
    required double pricePerSeat,
    required double fare,
    required double serviceFee,
    required double total,
    required bool isBooking,
  }) {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    title: AppLocalizations.of(context).complete_booking,
                    subtitle: AppLocalizations.of(
                      context,
                    ).review_your_ride_before_sending_the_request,
                    onBack: () => context.pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
                    child: _BookingProgressHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                    child: _RideSummaryHero(
                      ride: ride,
                      controller: _mapController,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: _PassengerOptionsCard(
                      ride: ride,
                      selectedSeats: selectedSeats,
                      onDecrease: selectedSeats <= 1
                          ? null
                          : () {
                              unawaited(HapticFeedback.selectionClick());
                              _uiNotifier.setSelectedSeats(selectedSeats - 1);
                            },
                      onIncrease: selectedSeats >= ride.remainingSeats
                          ? null
                          : () {
                              unawaited(HapticFeedback.selectionClick());
                              _uiNotifier.setSelectedSeats(selectedSeats + 1);
                            },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: _LocationTimelineCard(ride: ride),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: _PriceBreakdownCard(
                      currencySymbol: currencySymbol,
                      selectedSeats: selectedSeats,
                      pricePerSeat: pricePerSeat,
                      fare: fare,
                      serviceFee: serviceFee,
                      total: total,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 134.h),
                    child: const _TrustAndPolicyCard(),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BookingFooter(
                currencySymbol: currencySymbol,
                total: total,
                isLoading: isBooking,
                onPressed: isBooking ? null : () => _confirmBooking(ride),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletContent({
    required RideModel ride,
    required int selectedSeats,
    required String currencySymbol,
    required double pricePerSeat,
    required double fare,
    required double serviceFee,
    required double total,
    required bool isBooking,
  }) {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        title: AppLocalizations.of(context).complete_booking,
                        subtitle: AppLocalizations.of(
                          context,
                        ).review_your_ride_before_sending_the_request,
                        onBack: () => context.pop(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 0),
                        child: _BookingProgressHeader(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 20.h, 8.w, 0),
                        child: _RideSummaryHero(
                          ride: ride,
                          controller: _mapController,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 0),
                        child: _LocationTimelineCard(ride: ride),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 24.h),
                        child: const _TrustAndPolicyCard(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24.w),
              SizedBox(
                width: responsiveValue<double>(
                  context,
                  compact: 360,
                  medium: 380,
                  expanded: 420,
                  large: 440,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _PassengerOptionsCard(
                        ride: ride,
                        selectedSeats: selectedSeats,
                        onDecrease: selectedSeats <= 1
                            ? null
                            : () {
                                unawaited(HapticFeedback.selectionClick());
                                _uiNotifier.setSelectedSeats(selectedSeats - 1);
                              },
                        onIncrease: selectedSeats >= ride.remainingSeats
                            ? null
                            : () {
                                unawaited(HapticFeedback.selectionClick());
                                _uiNotifier.setSelectedSeats(selectedSeats + 1);
                              },
                      ),
                      SizedBox(height: 16.h),
                      _PriceBreakdownCard(
                        currencySymbol: currencySymbol,
                        selectedSeats: selectedSeats,
                        pricePerSeat: pricePerSeat,
                        fare: fare,
                        serviceFee: serviceFee,
                        total: total,
                      ),
                      SizedBox(height: 16.h),
                      _TabletBookingSidebar(
                        currencySymbol: currencySymbol,
                        total: total,
                        isLoading: isBooking,
                        onPressed: isBooking
                            ? null
                            : () => _confirmBooking(ride),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 20.w, 0),
      child: SizedBox(
        height: 78.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: _GlassIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
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

class _BookingProgressHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          _ProgressStep(
            number: '1',
            label: AppLocalizations.of(context).ride,
            isDone: true,
            isActive: false,
          ),
          Expanded(
            child: Container(
              height: 2.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          _ProgressStep(
            number: '2',
            label: AppLocalizations.of(context).review,
            isDone: false,
            isActive: true,
          ),
          Expanded(
            child: Container(
              height: 2.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              color: AppColors.border,
            ),
          ),
          _ProgressStep(
            number: '3',
            label: AppLocalizations.of(context).pending,
            isDone: false,
            isActive: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08);
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.number,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final String number;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isDone
        ? AppColors.success
        : isActive
        ? AppColors.primary
        : AppColors.surfaceVariant;

    final textColor = isActive || isDone
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  )
                : Text(
                    number,
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RideSummaryHero extends ConsumerWidget {
  const _RideSummaryHero({
    required this.ride,
    required this.controller,
  });

  final RideModel ride;
  final MapController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(rideDetailUiViewModelProvider(ride.id));
    final route = uiState.routeInfo;
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toLanguageTag();

    return _PremiumCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Column(
          children: [
            SizedBox(
              height: 190.h,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: controller,
                    options: MapOptions(
                      initialCenter: LatLng(
                        ride.origin.latitude,
                        ride.origin.longitude,
                      ),
                      initialZoom: 12.4,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      const AppMapTileLayer(),
                      if (route != null && route.coordinates.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: route.coordinates,
                              color: AppColors.primary,
                              strokeWidth: 5.5.w,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          _mapMarker(
                            point: LatLng(
                              ride.origin.latitude,
                              ride.origin.longitude,
                            ),
                            color: AppColors.primary,
                            icon: Icons.sports_score_rounded,
                          ),
                          _mapMarker(
                            point: LatLng(
                              ride.destination.latitude,
                              ride.destination.longitude,
                            ),
                            color: AppColors.success,
                            icon: Icons.location_on_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.78),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    top: 18.h,
                    right: 18.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_placeTitle(ride.origin.address, ride.origin.city)} '
                          'to ${_placeTitle(ride.destination.address, ride.destination.city)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        _HeroMetaPill(
                          icon: Icons.calendar_month_rounded,
                          label: DateFormat.MMMEd(
                            localeName,
                          ).add_jm().format(ride.departureTime),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    bottom: 16.h,
                    child: _HeroMetaPill(
                      icon: Icons.event_seat_rounded,
                      label: l10n.seatsLeftCount(ride.remainingSeats),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Row(
                children: [
                  const _SoftIcon(
                    icon: Icons.route_rounded,
                    color: AppColors.primary,
                    background: AppColors.primarySurface,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route?.formattedDistance ??
                              l10n.routeDistanceFallback,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          route?.formattedDuration ??
                              l10n.estimatedMinutes(
                                ride.route.durationMinutes ?? 60,
                              ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _MiniBadge(
                    label: AppLocalizations.of(context).secure,
                    color: AppColors.success,
                    icon: Icons.verified_user_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.08);
  }

  Marker _mapMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
  }) {
    return Marker(
      point: point,
      width: 46.w,
      height: 46.w,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.w),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22.sp),
      ),
    );
  }
}

class _HeroMetaPill extends StatelessWidget {
  const _HeroMetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerOptionsCard extends StatelessWidget {
  const _PassengerOptionsCard({
    required this.ride,
    required this.selectedSeats,
    required this.onDecrease,
    required this.onIncrease,
  });

  final RideModel ride;
  final int selectedSeats;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        children: [
          _OptionRow(
            icon: Icons.event_seat_rounded,
            title: AppLocalizations.of(context).seats,
            subtitle: AppLocalizations.of(
              context,
            ).choose_how_many_seats_you_need,
            trailing: _SeatStepper(
              value: selectedSeats,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
            ),
          ),
          _SoftDivider(),
          _OptionRow(
            icon: Icons.account_circle_rounded,
            title: AppLocalizations.of(context).booking_request,
            subtitle: AppLocalizations.of(
              context,
            ).the_driver_will_approve_your_request,
            trailing: _MiniBadge(
              label: AppLocalizations.of(context).pending,
              color: AppColors.primary,
              icon: Icons.schedule_rounded,
            ),
          ),
          _SoftDivider(),
          _OptionRow(
            icon: Icons.shield_rounded,
            title: AppLocalizations.of(context).protected_booking,
            subtitle: AppLocalizations.of(
              context,
            ).your_request_is_safely_recorded_in_sportconnect,
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 340.ms, delay: 70.ms).slideY(begin: 0.08);
  }
}

class _LocationTimelineCard extends StatelessWidget {
  const _LocationTimelineCard({required this.ride});

  final RideModel ride;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        children: [
          _TimelinePoint(
            color: AppColors.primary,
            icon: Icons.radio_button_checked_rounded,
            label: AppLocalizations.of(context).pickup_point,
            title: _placeTitle(ride.origin.address, ride.origin.city),
            subtitle: ride.origin.address,
            showLine: true,
          ),
          SizedBox(height: 4.h),
          _TimelinePoint(
            color: AppColors.success,
            icon: Icons.location_on_rounded,
            label: AppLocalizations.of(context).dropoff_point,
            title: _placeTitle(ride.destination.address, ride.destination.city),
            subtitle: ride.destination.address,
            showLine: false,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 340.ms, delay: 110.ms).slideY(begin: 0.08);
  }
}

class _TimelinePoint extends StatelessWidget {
  const _TimelinePoint({
    required this.color,
    required this.icon,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.showLine,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34.w,
            child: Column(
              children: [
                Icon(icon, color: color, size: 24.sp),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2.w,
                      margin: EdgeInsets.symmetric(vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 18.h : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _GlassIconButton(
            icon: Icons.navigation_rounded,
            onPressed: () {},
            size: 44,
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdownCard extends StatelessWidget {
  const _PriceBreakdownCard({
    required this.currencySymbol,
    required this.selectedSeats,
    required this.pricePerSeat,
    required this.fare,
    required this.serviceFee,
    required this.total,
  });

  final String currencySymbol;
  final int selectedSeats;
  final double pricePerSeat;
  final double fare;
  final double serviceFee;
  final double total;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).price_summary,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 16.h),
          _PriceLine(
            label: AppLocalizations.of(context).seat_price,
            value: '$currencySymbol${pricePerSeat.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12.h),
          _PriceLine(
            label: AppLocalizations.of(context).seats_selected,
            value: '$selectedSeats',
          ),
          SizedBox(height: 12.h),
          _PriceLine(
            label: AppLocalizations.of(context).fare,
            value: '$currencySymbol${fare.toStringAsFixed(2)}',
          ),
          SizedBox(height: 12.h),
          _PriceLine(
            label: AppLocalizations.of(context).service_fee,
            value: '$currencySymbol${serviceFee.toStringAsFixed(2)}',
            info: true,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Divider(color: AppColors.border, height: 1),
          ),
          _PriceLine(
            label: AppLocalizations.of(context).total,
            value: '$currencySymbol${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 340.ms, delay: 150.ms).slideY(begin: 0.08);
  }
}

class _TrustAndPolicyCard extends StatelessWidget {
  const _TrustAndPolicyCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Row(
        children: [
          const _SoftIcon(
            icon: Icons.verified_user_rounded,
            color: AppColors.primary,
            background: AppColors.primarySurface,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).cancellation_policy,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(
                    context,
                  ).you_can_cancel_before_the_driver_accepts_your_request,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: 24.sp,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 340.ms, delay: 190.ms).slideY(begin: 0.08);
  }
}

class _BookingFooter extends StatelessWidget {
  const _BookingFooter({
    required this.currencySymbol,
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final String currencySymbol;
  final double total;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: Offset(0, -12.h),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: AppColors.textPrimary),
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).totaln,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: '$currencySymbol${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),
            SizedBox(
              width: 196.w,
              child: _PrimaryActionButton(
                label: isLoading
                    ? AppLocalizations.of(context).bookingInProgress
                    : AppLocalizations.of(context).sendRequest,
                icon: Icons.arrow_forward_rounded,
                isLoading: isLoading,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletBookingSidebar extends StatelessWidget {
  const _TabletBookingSidebar({
    required this.currencySymbol,
    required this.total,
    required this.isLoading,
    required this.onPressed,
  });

  final String currencySymbol;
  final double total;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context).bookingRequestTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(
              context,
            ).review_your_ride_before_sending_the_request,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            AppLocalizations.of(context).total,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$currencySymbol${total.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 20.h),
          _PrimaryActionButton(
            label: isLoading
                ? AppLocalizations.of(context).bookingInProgress
                : AppLocalizations.of(context).sendRequest,
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 22,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SoftIcon(
          icon: icon,
          color: AppColors.success,
          background: AppColors.success.withValues(alpha: 0.1),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        trailing,
      ],
    );
  }
}

class _SeatStepper extends StatelessWidget {
  const _SeatStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrease,
          ),
          SizedBox(
            width: 34.w,
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tight(Size(34.w, 34.w)),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: onPressed == null
            ? AppColors.textSecondary.withValues(alpha: 0.35)
            : AppColors.primary,
        size: 20.sp,
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.info = false,
  });

  final String label;
  final String value;
  final bool isTotal;
  final bool info;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isTotal ? 17.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
        if (info) ...[
          SizedBox(width: 6.w),
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            size: 16.sp,
          ),
        ],
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? AppColors.success : AppColors.textPrimary,
            fontSize: isTotal ? 20.sp : 15.sp,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  const _SoftIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 23.sp),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      color: Colors.white,
      shape: const CircleBorder(),
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 21.sp,
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.55),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.w,
                height: 22.w,
                child: const CircularProgressIndicator.adaptive(
                  backgroundColor: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(icon, size: 21.sp),
                ],
              ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Divider(
        color: AppColors.border.withValues(alpha: 0.75),
        height: 1,
      ),
    );
  }
}

double _serviceFee(double fare) {
  if (fare <= 0) return 0;
  return 2;
}

String _placeTitle(String address, String? city) {
  final cleanCity = city?.trim();

  if (cleanCity != null && cleanCity.isNotEmpty) {
    return cleanCity;
  }

  final parts = address
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  return parts.isEmpty ? address : parts.first;
}

String _currencySymbol(String currency) {
  switch (currency.toLowerCase()) {
    case 'eur':
    case 'euro':
      return '€';
    case 'usd':
      return r'$';
    case 'gbp':
      return '£';
    default:
      return currency.toUpperCase();
  }
}
