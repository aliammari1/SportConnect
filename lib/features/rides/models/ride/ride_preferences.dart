import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_preferences.freezed.dart';
part 'ride_preferences.g.dart';

/// Ride preferences and rules
@freezed
abstract class RidePreferences with _$RidePreferences {
  const factory RidePreferences({
    @Default(false) bool allowPets,
    @Default(false) bool allowSmoking,
    @Default(true) bool allowLuggage,
    @Default(false) bool isWomenOnly,
  }) = _RidePreferences;
  const RidePreferences._();

  factory RidePreferences.fromJson(Map<String, dynamic> json) =>
      _$RidePreferencesFromJson(json);

  /// Whether any preference restricts who can join or what they can bring.
  bool get hasRestrictions =>
      isWomenOnly || !allowLuggage || !allowPets || !allowSmoking;

  /// Whether the ride has explicitly permissive allowances worth highlighting.
  bool get isPetFriendly => allowPets;
}
