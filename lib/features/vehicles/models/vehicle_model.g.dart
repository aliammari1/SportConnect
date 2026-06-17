// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleModel _$VehicleModelFromJson(Map json) => _VehicleModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  make: json['make'] as String,
  model: json['model'] as String,
  year: (json['year'] as num).toInt(),
  color: json['color'] as String,
  licensePlate: json['licensePlate'] as String,
  ownerName: json['ownerName'] as String? ?? 'Unknown',
  ownerPhotoUrl: json['ownerPhotoUrl'] as String?,
  capacity: (json['capacity'] as num?)?.toInt() ?? 4,
  imageUrl: json['imageUrl'] as String?,
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? false,
  isDefault: json['isDefault'] as bool? ?? false,
  type:
      $enumDecodeNullable(_$VehicleTypeEnumMap, json['type']) ??
      VehicleType.unknown,
  fuelType:
      $enumDecodeNullable(_$VehicleFuelTypeEnumMap, json['fuelType']) ??
      VehicleFuelType.unknown,
  transmission:
      $enumDecodeNullable(_$VehicleTransmissionEnumMap, json['transmission']) ??
      VehicleTransmission.unknown,
  verificationStatus:
      $enumDecodeNullable(
        _$VehicleVerificationStatusEnumMap,
        json['verificationStatus'],
      ) ??
      VehicleVerificationStatus.unverified,
  verifiedAt: const TimestampConverter().fromJson(json['verifiedAt']),
  rejectionReason: json['rejectionReason'] as String?,
  totalRides: (json['totalRides'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$VehicleModelToJson(_VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
      'ownerName': instance.ownerName,
      'ownerPhotoUrl': instance.ownerPhotoUrl,
      'capacity': instance.capacity,
      'imageUrl': instance.imageUrl,
      'imageUrls': instance.imageUrls,
      'isActive': instance.isActive,
      'isDefault': instance.isDefault,
      'type': _$VehicleTypeEnumMap[instance.type]!,
      'fuelType': _$VehicleFuelTypeEnumMap[instance.fuelType]!,
      'transmission': _$VehicleTransmissionEnumMap[instance.transmission]!,
      'verificationStatus':
          _$VehicleVerificationStatusEnumMap[instance.verificationStatus]!,
      'verifiedAt': const TimestampConverter().toJson(instance.verifiedAt),
      'rejectionReason': instance.rejectionReason,
      'totalRides': instance.totalRides,
      'averageRating': instance.averageRating,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$VehicleTypeEnumMap = {
  VehicleType.sedan: 'sedan',
  VehicleType.suv: 'suv',
  VehicleType.hatchback: 'hatchback',
  VehicleType.van: 'van',
  VehicleType.pickup: 'pickup',
  VehicleType.motorcycle: 'motorcycle',
  VehicleType.other: 'other',
  VehicleType.unknown: 'unknown',
};

const _$VehicleFuelTypeEnumMap = {
  VehicleFuelType.petrol: 'petrol',
  VehicleFuelType.diesel: 'diesel',
  VehicleFuelType.hybrid: 'hybrid',
  VehicleFuelType.electric: 'electric',
  VehicleFuelType.lpg: 'lpg',
  VehicleFuelType.other: 'other',
  VehicleFuelType.unknown: 'unknown',
};

const _$VehicleTransmissionEnumMap = {
  VehicleTransmission.manual: 'manual',
  VehicleTransmission.automatic: 'automatic',
  VehicleTransmission.unknown: 'unknown',
};

const _$VehicleVerificationStatusEnumMap = {
  VehicleVerificationStatus.unverified: 'unverified',
  VehicleVerificationStatus.pending: 'pending',
  VehicleVerificationStatus.verified: 'verified',
  VehicleVerificationStatus.rejected: 'rejected',
};
