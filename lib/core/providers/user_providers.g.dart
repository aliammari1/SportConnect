// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth state changes provider (Firebase User)

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Auth state changes provider (Firebase User)

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Auth state changes provider (Firebase User)
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'169a42479efd2b01fd3524bbea2d445a2dde7019';

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

/// Current user data provider (Firestore User Model)
///
/// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
/// instance is shared and its Firestore listener is properly cancelled when
/// the provider is disposed. Creating a bare [AuthRepository()] here on every
/// rebuild would accumulate orphaned snapshot listeners.

final class CurrentUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserModel?>,
          UserModel?,
          Stream<UserModel?>
        >
    with $FutureModifier<UserModel?>, $StreamProvider<UserModel?> {
  /// Current user data provider (Firestore User Model)
  ///
  /// Uses [authRepositoryProvider] (via DI) so that only one [AuthRepository]
  /// instance is shared and its Firestore listener is properly cancelled when
  /// the provider is disposed. Creating a bare [AuthRepository()] here on every
  /// rebuild would accumulate orphaned snapshot listeners.
  CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $StreamProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<UserModel?> create(Ref ref) {
    return currentUser(ref);
  }
}

String _$currentUserHash() => r'8fb437f3a273823195bbc1fa96755275d07e0569';

@ProviderFor(currentAuthUid)
final currentAuthUidProvider = CurrentAuthUidProvider._();

final class CurrentAuthUidProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  CurrentAuthUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAuthUidProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAuthUidHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentAuthUid(ref);
  }
}

String _$currentAuthUidHash() => r'31cac2c5a4ca796492b0bbc020c2fd6c7584e818';

/// Derived from [currentUserProvider] — no extra Firestore listener.
///
/// Premium state (isPremium / premiumPlan / premiumUpdatedAt) now lives on
/// [UserModel], so this reuses the single shared user-document listener instead
/// of opening a second snapshot on users/{uid}. That removes the divergence
/// window where the two listeners could momentarily disagree. The provider keeps
/// returning a [Stream] so existing [AsyncValue] consumers are unaffected.

@ProviderFor(premiumMetadata)
final premiumMetadataProvider = PremiumMetadataProvider._();

/// Derived from [currentUserProvider] — no extra Firestore listener.
///
/// Premium state (isPremium / premiumPlan / premiumUpdatedAt) now lives on
/// [UserModel], so this reuses the single shared user-document listener instead
/// of opening a second snapshot on users/{uid}. That removes the divergence
/// window where the two listeners could momentarily disagree. The provider keeps
/// returning a [Stream] so existing [AsyncValue] consumers are unaffected.

final class PremiumMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<PremiumMetadata>,
          PremiumMetadata,
          Stream<PremiumMetadata>
        >
    with $FutureModifier<PremiumMetadata>, $StreamProvider<PremiumMetadata> {
  /// Derived from [currentUserProvider] — no extra Firestore listener.
  ///
  /// Premium state (isPremium / premiumPlan / premiumUpdatedAt) now lives on
  /// [UserModel], so this reuses the single shared user-document listener instead
  /// of opening a second snapshot on users/{uid}. That removes the divergence
  /// window where the two listeners could momentarily disagree. The provider keeps
  /// returning a [Stream] so existing [AsyncValue] consumers are unaffected.
  PremiumMetadataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumMetadataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumMetadataHash();

  @$internal
  @override
  $StreamProviderElement<PremiumMetadata> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PremiumMetadata> create(Ref ref) {
    return premiumMetadata(ref);
  }
}

String _$premiumMetadataHash() => r'dd887ef3249fc00badc40add31f1a122cb482fb7';

/// Pending user's selected role intent during onboarding setup.
///
/// Derived from [currentUserProvider] — no extra Firestore listener.

@ProviderFor(selectedRoleIntent)
final selectedRoleIntentProvider = SelectedRoleIntentProvider._();

/// Pending user's selected role intent during onboarding setup.
///
/// Derived from [currentUserProvider] — no extra Firestore listener.

final class SelectedRoleIntentProvider
    extends $FunctionalProvider<UserRole?, UserRole?, UserRole?>
    with $Provider<UserRole?> {
  /// Pending user's selected role intent during onboarding setup.
  ///
  /// Derived from [currentUserProvider] — no extra Firestore listener.
  SelectedRoleIntentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRoleIntentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRoleIntentHash();

  @$internal
  @override
  $ProviderElement<UserRole?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRole? create(Ref ref) {
    return selectedRoleIntent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRole? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRole?>(value),
    );
  }
}

String _$selectedRoleIntentHash() =>
    r'5d0f84d219591885f141439e72d648556f9085fe';
