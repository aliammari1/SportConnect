import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/repositories/review_repository.dart';
import 'package:sport_connect/features/rides/models/booking/ride_booking.dart';

part 'driver_rate_passenger_view_model.g.dart';

class DriverPassengerRatingState {
  const DriverPassengerRatingState({
    this.rating = 0,
    this.comment = '',
    this.isSubmitting = false,
    this.selectedBookingId,
    this.selectedPassengerId,
    this.errorMessage,
    this.isSubmitted = false,
  });

  final double rating;
  final String comment;
  final bool isSubmitting;
  final String? selectedBookingId;
  final String? selectedPassengerId;
  final String? errorMessage;
  final bool isSubmitted;

  DriverPassengerRatingState copyWith({
    double? rating,
    String? comment,
    bool? isSubmitting,
    String? selectedBookingId,
    bool clearSelectedBookingId = false,
    String? selectedPassengerId,
    bool clearSelectedPassengerId = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSubmitted,
  }) {
    return DriverPassengerRatingState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      selectedBookingId: clearSelectedBookingId
          ? null
          : (selectedBookingId ?? this.selectedBookingId),
      selectedPassengerId: clearSelectedPassengerId
          ? null
          : (selectedPassengerId ?? this.selectedPassengerId),
      errorMessage: clearError ? null : errorMessage,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  bool get canSubmit =>
      rating > 0 && selectedPassengerId != null && !isSubmitting;
}

@riverpod
class DriverPassengerRatingViewModel extends _$DriverPassengerRatingViewModel {
  late final String _rideId;

  @override
  DriverPassengerRatingState build(String rideId) {
    _rideId = rideId;
    return const DriverPassengerRatingState();
  }

  void syncBookings(List<RideBooking> bookings) {
    if (bookings.length == 1 && state.selectedBookingId == null) {
      final booking = bookings.first;
      state = state.copyWith(
        selectedBookingId: booking.id,
        selectedPassengerId: booking.passengerId,
        clearError: true,
      );
      return;
    }

    final selectedBookingStillExists = bookings.any(
      (booking) => booking.id == state.selectedBookingId,
    );
    if (!selectedBookingStillExists && state.selectedBookingId != null) {
      state = state.copyWith(
        clearSelectedBookingId: true,
        clearSelectedPassengerId: true,
        clearError: true,
      );
    }
  }

  void selectBooking(RideBooking booking) {
    state = state.copyWith(
      selectedBookingId: booking.id,
      selectedPassengerId: booking.passengerId,
      clearError: true,
      isSubmitted: false,
    );
  }

  void setRating(double rating) {
    state = state.copyWith(
      rating: rating,
      clearError: true,
      isSubmitted: false,
    );
  }

  void setComment(String comment) {
    state = state.copyWith(
      comment: comment,
      clearError: true,
      isSubmitted: false,
    );
  }

  Future<void> submit({
    required String revieweeName,
    String? revieweePhotoUrl,
  }) async {
    if (state.isSubmitting) return;
    if (state.selectedPassengerId == null) {
      state = state.copyWith(
        errorMessage: 'Please select a passenger to rate.',
      );
      return;
    }
    if (state.rating <= 0) {
      state = state.copyWith(errorMessage: 'Please provide a rating.');
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      state = state.copyWith(
        errorMessage: 'You must be signed in to submit a rating.',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      isSubmitted: false,
    );

    try {
      await ref
          .read(reviewRepositoryProvider)
          .createReview(
            currentUser.uid,
            CreateReviewRequest(
              rideId: _rideId,
              revieweeId: state.selectedPassengerId!,
              revieweeName: revieweeName,
              revieweePhotoUrl: revieweePhotoUrl,
              type: ReviewType.rider,
              rating: state.rating,
              comment: state.comment.trim().isEmpty
                  ? null
                  : state.comment.trim(),
            ),
          );
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: true,
        clearError: true,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isSubmitting: false,
        isSubmitted: false,
        errorMessage: 'Failed to submit rating: $e',
      );
    }
  }
}
