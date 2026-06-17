// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideBooking _$RideBookingFromJson(Map json) => _RideBooking(
  id: json['id'] as String,
  rideId: json['rideId'] as String,
  passengerId: json['passengerId'] as String,
  driverId: json['driverId'] as String?,
  seatsBooked: (json['seatsBooked'] as num?)?.toInt() ?? 1,
  status:
      $enumDecodeNullable(_$BookingStatusEnumMap, json['status']) ??
      BookingStatus.pending,
  pickupLocation: json['pickupLocation'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['pickupLocation'] as Map),
        ),
  dropoffLocation: json['dropoffLocation'] == null
      ? null
      : LocationPoint.fromJson(
          Map<String, dynamic>.from(json['dropoffLocation'] as Map),
        ),
  note: json['note'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  respondedAt: const TimestampConverter().fromJson(json['respondedAt']),
  paymentIntentId: json['paymentIntentId'] as String?,
  paidAt: const TimestampConverter().fromJson(json['paidAt']),
  pickupOtp: json['pickupOtp'] as String?,
  pricePerSeatInCents: (json['pricePerSeatInCents'] as num?)?.toInt(),
  cancelledAt: const TimestampConverter().fromJson(json['cancelledAt']),
);

Map<String, dynamic> _$RideBookingToJson(_RideBooking instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rideId': instance.rideId,
      'passengerId': instance.passengerId,
      'driverId': instance.driverId,
      'seatsBooked': instance.seatsBooked,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'pickupLocation': instance.pickupLocation?.toJson(),
      'dropoffLocation': instance.dropoffLocation?.toJson(),
      'note': instance.note,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'respondedAt': const TimestampConverter().toJson(instance.respondedAt),
      'paymentIntentId': instance.paymentIntentId,
      'paidAt': const TimestampConverter().toJson(instance.paidAt),
      'pickupOtp': instance.pickupOtp,
      'pricePerSeatInCents': instance.pricePerSeatInCents,
      'cancelledAt': const TimestampConverter().toJson(instance.cancelledAt),
    };

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.accepted: 'accepted',
  BookingStatus.rejected: 'rejected',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
};
