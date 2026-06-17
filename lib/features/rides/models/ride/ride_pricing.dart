import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sport_connect/core/utils/currency_formatter.dart';

part 'ride_pricing.freezed.dart';
part 'ride_pricing.g.dart';

/// Ride pricing information
@freezed
abstract class RidePricing with _$RidePricing {
  const factory RidePricing({
    required int pricePerSeatInCents,
  }) = _RidePricing;
  const RidePricing._();

  factory RidePricing.fromJson(Map<String, dynamic> json) =>
      _$RidePricingFromJson(json);

  /// Get formatted price
  String get formattedPrice => CurrencyFormatter.fromCents(pricePerSeatInCents);

  /// Whether this is a free ride (e.g. a friendly carpool with no charge).
  bool get isFree => pricePerSeatInCents <= 0;

  /// Calculate total price for seats
  int totalForSeats(int seats) => pricePerSeatInCents * seats;

  /// Formatted total price for the given number of seats.
  String formattedTotalForSeats(int seats) =>
      CurrencyFormatter.fromCents(totalForSeats(seats));
}
