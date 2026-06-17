// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideSummary _$RideSummaryFromJson(Map json) => _RideSummary(
  id: json['id'] as String,
  driverId: json['driverId'] as String,
  originAddress: json['originAddress'] as String,
  destinationAddress: json['destinationAddress'] as String,
  departureTime: const RequiredTimestampConverter().fromJson(
    json['departureTime'],
  ),
  formattedPrice: json['formattedPrice'] as String,
  seatsAvailable: (json['seatsAvailable'] as num).toInt(),
  isBookable: json['isBookable'] as bool,
);

Map<String, dynamic> _$RideSummaryToJson(_RideSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'originAddress': instance.originAddress,
      'destinationAddress': instance.destinationAddress,
      'departureTime': const RequiredTimestampConverter().toJson(
        instance.departureTime,
      ),
      'formattedPrice': instance.formattedPrice,
      'seatsAvailable': instance.seatsAvailable,
      'isBookable': instance.isBookable,
    };
