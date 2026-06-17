import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/rides/models/ride/ride_model.dart';
import 'package:sport_connect/features/rides/repositories/ride_repository.dart';

part 'driver_requests_view_model.g.dart';

/// One-shot ride lookup for request cards.
///
/// Request lists do not need a live ride stream per row; a short-lived cache
/// removes repeated Firestore reads when switching tabs or revisiting the list.
// The concrete provider-family type lives in riverpod's private src and is not
// part of the public API, so the type is intentionally inferred here.
// ignore: specify_nonobvious_property_types
final requestCardRideProvider =
    FutureProvider.autoDispose.family<RideModel?, String>((ref, rideId) async {
      final ride = await ref.read(rideRepositoryProvider).getRideById(rideId);
      final cacheLink = ref.keepAlive();
      final cacheTimer = Timer(const Duration(minutes: 5), cacheLink.close);
      ref.onDispose(cacheTimer.cancel);
      return ride;
    });

class DeclineReasonSheetState {
  const DeclineReasonSheetState({this.selectedReason, this.otherText = ''});

  final String? selectedReason;
  final String otherText;

  DeclineReasonSheetState copyWith({
    String? selectedReason,
    bool clearSelectedReason = false,
    String? otherText,
  }) {
    return DeclineReasonSheetState(
      selectedReason: clearSelectedReason
          ? null
          : (selectedReason ?? this.selectedReason),
      otherText: otherText ?? this.otherText,
    );
  }

  bool get canSubmit =>
      selectedReason != null &&
      (selectedReason != 'Other' || otherText.trim().isNotEmpty);

  String get resolvedReason =>
      selectedReason == 'Other' ? otherText.trim() : selectedReason!;
}

@riverpod
class DeclineReasonSheetViewModel extends _$DeclineReasonSheetViewModel {
  @override
  DeclineReasonSheetState build(String arg) => const DeclineReasonSheetState();

  void selectReason(String reason) {
    state = state.copyWith(
      selectedReason: reason,
      otherText: reason == 'Other' ? state.otherText : '',
    );
  }

  void setOtherText(String value) {
    state = state.copyWith(otherText: value);
  }
}
