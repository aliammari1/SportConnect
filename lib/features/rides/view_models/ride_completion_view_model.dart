import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/services/pdf_receipt_service.dart';
import 'package:sport_connect/core/services/routing_service.dart';
import 'package:sport_connect/core/utils/share_sheet_origin.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/view_models/ride_view_model.dart';

part 'ride_completion_view_model.g.dart';

class RideCompletionUiState {
  const RideCompletionUiState({
    this.isGeneratingPdf = false,
    this.osrmRoutePoints,
    this.osrmRouteRideId,
    this.isLoadingOsrmRoute = false,
    this.errorMessage,
  });

  final bool isGeneratingPdf;
  final List<LatLng>? osrmRoutePoints;
  final String? osrmRouteRideId;
  final bool isLoadingOsrmRoute;
  final String? errorMessage;

  RideCompletionUiState copyWith({
    bool? isGeneratingPdf,
    List<LatLng>? osrmRoutePoints,
    bool clearOsrmRoutePoints = false,
    String? osrmRouteRideId,
    bool clearOsrmRouteRideId = false,
    bool? isLoadingOsrmRoute,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RideCompletionUiState(
      isGeneratingPdf: isGeneratingPdf ?? this.isGeneratingPdf,
      osrmRoutePoints: clearOsrmRoutePoints
          ? null
          : (osrmRoutePoints ?? this.osrmRoutePoints),
      osrmRouteRideId: clearOsrmRouteRideId
          ? null
          : (osrmRouteRideId ?? this.osrmRouteRideId),
      isLoadingOsrmRoute: isLoadingOsrmRoute ?? this.isLoadingOsrmRoute,
      errorMessage: clearError ? null : errorMessage,
    );
  }
}

@riverpod
class RideCompletionUiViewModel extends _$RideCompletionUiViewModel {
  late final String _rideId;

  @override
  RideCompletionUiState build(String rideId) {
    _rideId = rideId;
    return const RideCompletionUiState();
  }

  Future<void> ensureRouteLoaded(RideModel ride) async {
    if (state.isLoadingOsrmRoute || state.osrmRouteRideId == ride.id) return;
    state = state.copyWith(
      isLoadingOsrmRoute: true,
      osrmRouteRideId: ride.id,
      clearError: true,
    );

    try {
      final origin = LatLng(ride.origin.latitude, ride.origin.longitude);
      final dest = LatLng(
        ride.destination.latitude,
        ride.destination.longitude,
      );
      final waypoints = ride.route.waypoints.isNotEmpty
          ? ride.route.waypoints
                .map(
                  (wp) => LatLng(wp.location.latitude, wp.location.longitude),
                )
                .toList()
          : null;
      final routeInfo = await ref
          .read(routingServiceProvider)
          .getRoute(
            origin: origin,
            destination: dest,
            waypoints: waypoints,
          );
      if (!ref.mounted) return;
      state = state.copyWith(
        osrmRoutePoints: routeInfo?.coordinates,
        isLoadingOsrmRoute: false,
      );
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingOsrmRoute: false);
    }
  }

  Future<void> shareReceipt(
    RideModel ride, {
    required String receiptTitle,
    required String fromLabel,
    required String toLabel,
    required String dateLabel,
    required String driverLabel,
    required String baseFareLabel,
    required String serviceFeeLabel,
    required String totalLabel,
    required String rideIdLabel,
  }) async {
    if (state.isGeneratingPdf) return;
    state = state.copyWith(isGeneratingPdf: true, clearError: true);

    try {
      final driverProfile = await ref.read(
        userProfileProvider(ride.driverId).future,
      );
      if (!ref.mounted) return;
      final driverName = driverProfile?.username ?? 'Driver';
      final driverPhone = driverProfile?.asDriver?.phoneNumber;
      final currentUser = ref.read(currentUserProvider).value;
      final passengerName = currentUser?.username;
      final baseFare = ride.pricePerSeatInCents;
      final allBookings = ref.read(bookingsByRideProvider(ride.id)).value ?? [];
      final seatsBooked =
          allBookings
              .where((b) => b.passengerId == currentUser?.uid)
              .firstOrNull
              ?.seatsBooked ??
          1;
      final serviceFee = (baseFare * seatsBooked * 0.10).round();

      final pdfBytes = await PdfReceiptService.instance.generateRideReceipt(
        rideId: ride.id,
        fromAddress: ride.origin.address,
        toAddress: ride.destination.address,
        departureTime: ride.departureTime,
        completedTime: DateTime.now(),
        driverName: driverName,
        driverPhone: driverPhone,
        pricePerSeatInCents: ride.pricePerSeatInCents,
        seatsBooked: seatsBooked,
        serviceFeeInCents: serviceFee,
        passengerName: passengerName,
      );

      if (!ref.mounted) return;
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'SportConnect_Receipt_${ride.id.substring(0, 8)}.pdf',
      );
      if (!ref.mounted) return;
      state = state.copyWith(isGeneratingPdf: false);
    } on Exception {
      try {
        final driverProfile = await ref.read(
          userProfileProvider(ride.driverId).future,
        );
        if (!ref.mounted) return;
        final driverName = driverProfile?.username ?? 'Driver';
        final baseFare = ride.pricePerSeatInCents;
        final serviceFee = (baseFare * 0.10).round();
        final total = baseFare + serviceFee;

        final receipt =
            '''
$receiptTitle
${'=' * 30}
$fromLabel: ${ride.origin.address}
$toLabel: ${ride.destination.address}
$dateLabel: ${DateFormat('MMM d, yyyy h:mm a').format(ride.departureTime)}
$driverLabel: $driverName

$baseFareLabel: €${(baseFare / 100).toStringAsFixed(2)}
$serviceFeeLabel: €${(serviceFee / 100).toStringAsFixed(2)}
$totalLabel: €${(total / 100).toStringAsFixed(2)}
${'=' * 30}
$rideIdLabel: ${ride.id}'''
                .trimLeft();

        await SharePlus.instance.share(
          ShareParams(
            text: receipt,
            sharePositionOrigin: shareSheetOrigin(),
          ),
        );
        if (!ref.mounted) return;
        state = state.copyWith(isGeneratingPdf: false);
      } on Exception catch (e) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isGeneratingPdf: false,
          errorMessage: 'Unable to share receipt: $e',
        );
      }
    }
  }
}
