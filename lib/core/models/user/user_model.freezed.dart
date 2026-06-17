// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
UserModel _$UserModelFromJson(
  Map<String, dynamic> json
) {
        switch (json['role']) {
                  case 'rider':
          return RiderModel.fromJson(
            json
          );
                case 'driver':
          return DriverModel.fromJson(
            json
          );
                case 'pending':
          return PendingUserModel.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'role',
  'UserModel',
  'Invalid union type "${json['role']}"!'
);
        }
      
}

/// @nodoc
mixin _$UserModel {

 String get uid; String get email; String get username; String? get photoUrl; String? get phoneNumber;@TimestampConverter() DateTime? get dateOfBirth; String get fcmToken;// Verification & status
 bool get isEmailVerified; bool get isBanned;// Expertise
 Expertise get expertise;// Timestamps
@TimestampConverter() DateTime? get createdAt;@TimestampConverter() DateTime? get updatedAt;
/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserModelCopyWith<UserModel> get copyWith => _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,username,photoUrl,phoneNumber,dateOfBirth,fcmToken,isEmailVerified,isBanned,expertise,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel(uid: $uid, email: $email, username: $username, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, fcmToken: $fcmToken, isEmailVerified: $isEmailVerified, isBanned: $isBanned, expertise: $expertise, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res>  {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) = _$UserModelCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String username, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String fcmToken, bool isEmailVerified, bool isBanned, Expertise expertise,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$UserModelCopyWithImpl<$Res>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? username = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? fcmToken = null,Object? isEmailVerified = null,Object? isBanned = null,Object? expertise = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RiderModel value)?  rider,TResult Function( DriverModel value)?  driver,TResult Function( PendingUserModel value)?  pending,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that);case DriverModel() when driver != null:
return driver(_that);case PendingUserModel() when pending != null:
return pending(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RiderModel value)  rider,required TResult Function( DriverModel value)  driver,required TResult Function( PendingUserModel value)  pending,}){
final _that = this;
switch (_that) {
case RiderModel():
return rider(_that);case DriverModel():
return driver(_that);case PendingUserModel():
return pending(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RiderModel value)?  rider,TResult? Function( DriverModel value)?  driver,TResult? Function( PendingUserModel value)?  pending,}){
final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that);case DriverModel() when driver != null:
return driver(_that);case PendingUserModel() when pending != null:
return pending(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  String? stripeCustomerId,  bool isStripeCustomerCreated, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  rider,TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  List<String> vehicleIds,  String? stripeAccountId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  driver,TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  Expertise expertise,  bool isEmailVerified,  bool isBanned,  String fcmToken,  String? selectedRoleIntent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  pending,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.stripeCustomerId,_that.isStripeCustomerCreated,_that.createdAt,_that.updatedAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.vehicleIds,_that.stripeAccountId,_that.createdAt,_that.updatedAt);case PendingUserModel() when pending != null:
return pending(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.expertise,_that.isEmailVerified,_that.isBanned,_that.fcmToken,_that.selectedRoleIntent,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  String? stripeCustomerId,  bool isStripeCustomerCreated, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  rider,required TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  List<String> vehicleIds,  String? stripeAccountId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  driver,required TResult Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  Expertise expertise,  bool isEmailVerified,  bool isBanned,  String fcmToken,  String? selectedRoleIntent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)  pending,}) {final _that = this;
switch (_that) {
case RiderModel():
return rider(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.stripeCustomerId,_that.isStripeCustomerCreated,_that.createdAt,_that.updatedAt);case DriverModel():
return driver(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.vehicleIds,_that.stripeAccountId,_that.createdAt,_that.updatedAt);case PendingUserModel():
return pending(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.expertise,_that.isEmailVerified,_that.isBanned,_that.fcmToken,_that.selectedRoleIntent,_that.createdAt,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  String? stripeCustomerId,  bool isStripeCustomerCreated, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  rider,TResult? Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  String? gender,  String fcmToken,  String? address,  double? latitude,  double? longitude,  bool isEmailVerified,  bool isBanned,  bool isPremium,  String? premiumPlan, @TimestampConverter()  DateTime? premiumUpdatedAt,  List<String> blockedUsers,  RatingBreakdown rating,  GamificationStats gamification,  UserPreferences preferences,  Expertise expertise,  List<String> vehicleIds,  String? stripeAccountId, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  driver,TResult? Function( String uid,  String email,  String username,  String? photoUrl,  String? phoneNumber, @TimestampConverter()  DateTime? dateOfBirth,  Expertise expertise,  bool isEmailVerified,  bool isBanned,  String fcmToken,  String? selectedRoleIntent, @TimestampConverter()  DateTime? createdAt, @TimestampConverter()  DateTime? updatedAt)?  pending,}) {final _that = this;
switch (_that) {
case RiderModel() when rider != null:
return rider(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.stripeCustomerId,_that.isStripeCustomerCreated,_that.createdAt,_that.updatedAt);case DriverModel() when driver != null:
return driver(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.gender,_that.fcmToken,_that.address,_that.latitude,_that.longitude,_that.isEmailVerified,_that.isBanned,_that.isPremium,_that.premiumPlan,_that.premiumUpdatedAt,_that.blockedUsers,_that.rating,_that.gamification,_that.preferences,_that.expertise,_that.vehicleIds,_that.stripeAccountId,_that.createdAt,_that.updatedAt);case PendingUserModel() when pending != null:
return pending(_that.uid,_that.email,_that.username,_that.photoUrl,_that.phoneNumber,_that.dateOfBirth,_that.expertise,_that.isEmailVerified,_that.isBanned,_that.fcmToken,_that.selectedRoleIntent,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class RiderModel extends UserModel {
  const RiderModel({required this.uid, required this.email, required this.username, this.photoUrl, this.phoneNumber, @TimestampConverter() this.dateOfBirth, this.gender, this.fcmToken = '', this.address, this.latitude, this.longitude, this.isEmailVerified = false, this.isBanned = false, this.isPremium = false, this.premiumPlan, @TimestampConverter() this.premiumUpdatedAt, final  List<String> blockedUsers = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats(), this.preferences = const UserPreferences(), this.expertise = Expertise.rookie, this.stripeCustomerId, this.isStripeCustomerCreated = false, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, final  String? $type}): _blockedUsers = blockedUsers,$type = $type ?? 'rider',super._();
  factory RiderModel.fromJson(Map<String, dynamic> json) => _$RiderModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String username;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override@TimestampConverter() final  DateTime? dateOfBirth;
 final  String? gender;
@override@JsonKey() final  String fcmToken;
// Address & location
 final  String? address;
 final  double? latitude;
 final  double? longitude;
// Verification & status
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isBanned;
@JsonKey() final  bool isPremium;
 final  String? premiumPlan;
// 'monthly' | 'yearly'
@TimestampConverter() final  DateTime? premiumUpdatedAt;
// Social
 final  List<String> _blockedUsers;
// Social
@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}

// Rider-specific: Passenger rating
@JsonKey() final  RatingBreakdown rating;
// Rider-specific: Gamification
@JsonKey() final  GamificationStats gamification;
// Preferences
@JsonKey() final  UserPreferences preferences;
// Expertise
@override@JsonKey() final  Expertise expertise;
 final  String? stripeCustomerId;
@JsonKey() final  bool isStripeCustomerCreated;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

@JsonKey(name: 'role')
final String $type;


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RiderModelCopyWith<RiderModel> get copyWith => _$RiderModelCopyWithImpl<RiderModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RiderModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RiderModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.premiumPlan, premiumPlan) || other.premiumPlan == premiumPlan)&&(identical(other.premiumUpdatedAt, premiumUpdatedAt) || other.premiumUpdatedAt == premiumUpdatedAt)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.stripeCustomerId, stripeCustomerId) || other.stripeCustomerId == stripeCustomerId)&&(identical(other.isStripeCustomerCreated, isStripeCustomerCreated) || other.isStripeCustomerCreated == isStripeCustomerCreated)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,username,photoUrl,phoneNumber,dateOfBirth,gender,fcmToken,address,latitude,longitude,isEmailVerified,isBanned,isPremium,premiumPlan,premiumUpdatedAt,const DeepCollectionEquality().hash(_blockedUsers),rating,gamification,preferences,expertise,stripeCustomerId,isStripeCustomerCreated,createdAt,updatedAt]);

@override
String toString() {
  return 'UserModel.rider(uid: $uid, email: $email, username: $username, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, fcmToken: $fcmToken, address: $address, latitude: $latitude, longitude: $longitude, isEmailVerified: $isEmailVerified, isBanned: $isBanned, isPremium: $isPremium, premiumPlan: $premiumPlan, premiumUpdatedAt: $premiumUpdatedAt, blockedUsers: $blockedUsers, rating: $rating, gamification: $gamification, preferences: $preferences, expertise: $expertise, stripeCustomerId: $stripeCustomerId, isStripeCustomerCreated: $isStripeCustomerCreated, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RiderModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $RiderModelCopyWith(RiderModel value, $Res Function(RiderModel) _then) = _$RiderModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String username, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String? gender, String fcmToken, String? address, double? latitude, double? longitude, bool isEmailVerified, bool isBanned, bool isPremium, String? premiumPlan,@TimestampConverter() DateTime? premiumUpdatedAt, List<String> blockedUsers, RatingBreakdown rating, GamificationStats gamification, UserPreferences preferences, Expertise expertise, String? stripeCustomerId, bool isStripeCustomerCreated,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$RatingBreakdownCopyWith<$Res> get rating;$GamificationStatsCopyWith<$Res> get gamification;$UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$RiderModelCopyWithImpl<$Res>
    implements $RiderModelCopyWith<$Res> {
  _$RiderModelCopyWithImpl(this._self, this._then);

  final RiderModel _self;
  final $Res Function(RiderModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? username = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? fcmToken = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? isEmailVerified = null,Object? isBanned = null,Object? isPremium = null,Object? premiumPlan = freezed,Object? premiumUpdatedAt = freezed,Object? blockedUsers = null,Object? rating = null,Object? gamification = null,Object? preferences = null,Object? expertise = null,Object? stripeCustomerId = freezed,Object? isStripeCustomerCreated = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(RiderModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,premiumPlan: freezed == premiumPlan ? _self.premiumPlan : premiumPlan // ignore: cast_nullable_to_non_nullable
as String?,premiumUpdatedAt: freezed == premiumUpdatedAt ? _self.premiumUpdatedAt : premiumUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,stripeCustomerId: freezed == stripeCustomerId ? _self.stripeCustomerId : stripeCustomerId // ignore: cast_nullable_to_non_nullable
as String?,isStripeCustomerCreated: null == isStripeCustomerCreated ? _self.isStripeCustomerCreated : isStripeCustomerCreated // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<$Res> get rating {
  
  return $RatingBreakdownCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GamificationStatsCopyWith<$Res> get gamification {
  
  return $GamificationStatsCopyWith<$Res>(_self.gamification, (value) {
    return _then(_self.copyWith(gamification: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class DriverModel extends UserModel {
  const DriverModel({required this.uid, required this.email, required this.username, this.photoUrl, this.phoneNumber, @TimestampConverter() this.dateOfBirth, this.gender, this.fcmToken = '', this.address, this.latitude, this.longitude, this.isEmailVerified = false, this.isBanned = false, this.isPremium = false, this.premiumPlan, @TimestampConverter() this.premiumUpdatedAt, final  List<String> blockedUsers = const [], this.rating = const RatingBreakdown(), this.gamification = const GamificationStats(), this.preferences = const UserPreferences(), this.expertise = Expertise.rookie, final  List<String> vehicleIds = const [], this.stripeAccountId, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, final  String? $type}): _blockedUsers = blockedUsers,_vehicleIds = vehicleIds,$type = $type ?? 'driver',super._();
  factory DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String username;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override@TimestampConverter() final  DateTime? dateOfBirth;
 final  String? gender;
@override@JsonKey() final  String fcmToken;
// Address & location
 final  String? address;
 final  double? latitude;
 final  double? longitude;
// Verification & status
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isBanned;
@JsonKey() final  bool isPremium;
 final  String? premiumPlan;
// 'monthly' | 'yearly'
@TimestampConverter() final  DateTime? premiumUpdatedAt;
// Social
 final  List<String> _blockedUsers;
// Social
@JsonKey() List<String> get blockedUsers {
  if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_blockedUsers);
}

// Driver-specific: Driver rating
@JsonKey() final  RatingBreakdown rating;
// Driver-specific: Gamification
@JsonKey() final  GamificationStats gamification;
// Preferences
@JsonKey() final  UserPreferences preferences;
// Expertise
@override@JsonKey() final  Expertise expertise;
// Driver-specific: Vehicle IDs
 final  List<String> _vehicleIds;
// Driver-specific: Vehicle IDs
@JsonKey() List<String> get vehicleIds {
  if (_vehicleIds is EqualUnmodifiableListView) return _vehicleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vehicleIds);
}

// Driver-specific: Stripe Connect
 final  String? stripeAccountId;
// Timestamps
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

@JsonKey(name: 'role')
final String $type;


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.premiumPlan, premiumPlan) || other.premiumPlan == premiumPlan)&&(identical(other.premiumUpdatedAt, premiumUpdatedAt) || other.premiumUpdatedAt == premiumUpdatedAt)&&const DeepCollectionEquality().equals(other._blockedUsers, _blockedUsers)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.gamification, gamification) || other.gamification == gamification)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&const DeepCollectionEquality().equals(other._vehicleIds, _vehicleIds)&&(identical(other.stripeAccountId, stripeAccountId) || other.stripeAccountId == stripeAccountId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,username,photoUrl,phoneNumber,dateOfBirth,gender,fcmToken,address,latitude,longitude,isEmailVerified,isBanned,isPremium,premiumPlan,premiumUpdatedAt,const DeepCollectionEquality().hash(_blockedUsers),rating,gamification,preferences,expertise,const DeepCollectionEquality().hash(_vehicleIds),stripeAccountId,createdAt,updatedAt]);

@override
String toString() {
  return 'UserModel.driver(uid: $uid, email: $email, username: $username, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, gender: $gender, fcmToken: $fcmToken, address: $address, latitude: $latitude, longitude: $longitude, isEmailVerified: $isEmailVerified, isBanned: $isBanned, isPremium: $isPremium, premiumPlan: $premiumPlan, premiumUpdatedAt: $premiumUpdatedAt, blockedUsers: $blockedUsers, rating: $rating, gamification: $gamification, preferences: $preferences, expertise: $expertise, vehicleIds: $vehicleIds, stripeAccountId: $stripeAccountId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String username, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, String? gender, String fcmToken, String? address, double? latitude, double? longitude, bool isEmailVerified, bool isBanned, bool isPremium, String? premiumPlan,@TimestampConverter() DateTime? premiumUpdatedAt, List<String> blockedUsers, RatingBreakdown rating, GamificationStats gamification, UserPreferences preferences, Expertise expertise, List<String> vehicleIds, String? stripeAccountId,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});


$RatingBreakdownCopyWith<$Res> get rating;$GamificationStatsCopyWith<$Res> get gamification;$UserPreferencesCopyWith<$Res> get preferences;

}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? username = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? gender = freezed,Object? fcmToken = null,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? isEmailVerified = null,Object? isBanned = null,Object? isPremium = null,Object? premiumPlan = freezed,Object? premiumUpdatedAt = freezed,Object? blockedUsers = null,Object? rating = null,Object? gamification = null,Object? preferences = null,Object? expertise = null,Object? vehicleIds = null,Object? stripeAccountId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(DriverModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,premiumPlan: freezed == premiumPlan ? _self.premiumPlan : premiumPlan // ignore: cast_nullable_to_non_nullable
as String?,premiumUpdatedAt: freezed == premiumUpdatedAt ? _self.premiumUpdatedAt : premiumUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blockedUsers: null == blockedUsers ? _self._blockedUsers : blockedUsers // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as RatingBreakdown,gamification: null == gamification ? _self.gamification : gamification // ignore: cast_nullable_to_non_nullable
as GamificationStats,preferences: null == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as UserPreferences,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,vehicleIds: null == vehicleIds ? _self._vehicleIds : vehicleIds // ignore: cast_nullable_to_non_nullable
as List<String>,stripeAccountId: freezed == stripeAccountId ? _self.stripeAccountId : stripeAccountId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RatingBreakdownCopyWith<$Res> get rating {
  
  return $RatingBreakdownCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GamificationStatsCopyWith<$Res> get gamification {
  
  return $GamificationStatsCopyWith<$Res>(_self.gamification, (value) {
    return _then(_self.copyWith(gamification: value));
  });
}/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserPreferencesCopyWith<$Res> get preferences {
  
  return $UserPreferencesCopyWith<$Res>(_self.preferences, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class PendingUserModel extends UserModel {
  const PendingUserModel({required this.uid, required this.email, required this.username, this.photoUrl, this.phoneNumber, @TimestampConverter() this.dateOfBirth, this.expertise = Expertise.rookie, this.isEmailVerified = false, this.isBanned = false, this.fcmToken = '', this.selectedRoleIntent, @TimestampConverter() this.createdAt, @TimestampConverter() this.updatedAt, final  String? $type}): $type = $type ?? 'pending',super._();
  factory PendingUserModel.fromJson(Map<String, dynamic> json) => _$PendingUserModelFromJson(json);

@override final  String uid;
@override final  String email;
@override final  String username;
@override final  String? photoUrl;
@override final  String? phoneNumber;
@override@TimestampConverter() final  DateTime? dateOfBirth;
@override@JsonKey() final  Expertise expertise;
@override@JsonKey() final  bool isEmailVerified;
@override@JsonKey() final  bool isBanned;
@override@JsonKey() final  String fcmToken;
 final  String? selectedRoleIntent;
@override@TimestampConverter() final  DateTime? createdAt;
@override@TimestampConverter() final  DateTime? updatedAt;

@JsonKey(name: 'role')
final String $type;


/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PendingUserModelCopyWith<PendingUserModel> get copyWith => _$PendingUserModelCopyWithImpl<PendingUserModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PendingUserModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PendingUserModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.username, username) || other.username == username)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.expertise, expertise) || other.expertise == expertise)&&(identical(other.isEmailVerified, isEmailVerified) || other.isEmailVerified == isEmailVerified)&&(identical(other.isBanned, isBanned) || other.isBanned == isBanned)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.selectedRoleIntent, selectedRoleIntent) || other.selectedRoleIntent == selectedRoleIntent)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,email,username,photoUrl,phoneNumber,dateOfBirth,expertise,isEmailVerified,isBanned,fcmToken,selectedRoleIntent,createdAt,updatedAt);

@override
String toString() {
  return 'UserModel.pending(uid: $uid, email: $email, username: $username, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, expertise: $expertise, isEmailVerified: $isEmailVerified, isBanned: $isBanned, fcmToken: $fcmToken, selectedRoleIntent: $selectedRoleIntent, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PendingUserModelCopyWith<$Res> implements $UserModelCopyWith<$Res> {
  factory $PendingUserModelCopyWith(PendingUserModel value, $Res Function(PendingUserModel) _then) = _$PendingUserModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String username, String? photoUrl, String? phoneNumber,@TimestampConverter() DateTime? dateOfBirth, Expertise expertise, bool isEmailVerified, bool isBanned, String fcmToken, String? selectedRoleIntent,@TimestampConverter() DateTime? createdAt,@TimestampConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$PendingUserModelCopyWithImpl<$Res>
    implements $PendingUserModelCopyWith<$Res> {
  _$PendingUserModelCopyWithImpl(this._self, this._then);

  final PendingUserModel _self;
  final $Res Function(PendingUserModel) _then;

/// Create a copy of UserModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? username = null,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? dateOfBirth = freezed,Object? expertise = null,Object? isEmailVerified = null,Object? isBanned = null,Object? fcmToken = null,Object? selectedRoleIntent = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(PendingUserModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as Expertise,isEmailVerified: null == isEmailVerified ? _self.isEmailVerified : isEmailVerified // ignore: cast_nullable_to_non_nullable
as bool,isBanned: null == isBanned ? _self.isBanned : isBanned // ignore: cast_nullable_to_non_nullable
as bool,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,selectedRoleIntent: freezed == selectedRoleIntent ? _self.selectedRoleIntent : selectedRoleIntent // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
