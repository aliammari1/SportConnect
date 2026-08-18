// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream provider for a user's notification preferences.

@ProviderFor(notificationPreferencesStream)
final notificationPreferencesStreamProvider =
    NotificationPreferencesStreamFamily._();

/// Stream provider for a user's notification preferences.

final class NotificationPreferencesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationPreferences>,
          NotificationPreferences,
          Stream<NotificationPreferences>
        >
    with
        $FutureModifier<NotificationPreferences>,
        $StreamProvider<NotificationPreferences> {
  /// Stream provider for a user's notification preferences.
  NotificationPreferencesStreamProvider._({
    required NotificationPreferencesStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notificationPreferencesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesStreamHash();

  @override
  String toString() {
    return r'notificationPreferencesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<NotificationPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationPreferences> create(Ref ref) {
    final argument = this.argument as String;
    return notificationPreferencesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationPreferencesStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationPreferencesStreamHash() =>
    r'31977a83d44fb5fa10b94056d902ce2b86b3e595';

/// Stream provider for a user's notification preferences.

final class NotificationPreferencesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<NotificationPreferences>, String> {
  NotificationPreferencesStreamFamily._()
    : super(
        retry: null,
        name: r'notificationPreferencesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for a user's notification preferences.

  NotificationPreferencesStreamProvider call(String userId) =>
      NotificationPreferencesStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'notificationPreferencesStreamProvider';
}

/// ViewModel backing the notification preferences screen: exposes the live
/// preferences plus per-field setters that persist to Firestore.

@ProviderFor(NotificationPreferencesViewModel)
final notificationPreferencesViewModelProvider =
    NotificationPreferencesViewModelProvider._();

/// ViewModel backing the notification preferences screen: exposes the live
/// preferences plus per-field setters that persist to Firestore.
final class NotificationPreferencesViewModelProvider
    extends
        $NotifierProvider<
          NotificationPreferencesViewModel,
          NotificationPreferencesState
        > {
  /// ViewModel backing the notification preferences screen: exposes the live
  /// preferences plus per-field setters that persist to Firestore.
  NotificationPreferencesViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPreferencesViewModelHash();

  @$internal
  @override
  NotificationPreferencesViewModel create() =>
      NotificationPreferencesViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPreferencesState>(value),
    );
  }
}

String _$notificationPreferencesViewModelHash() =>
    r'7a39478e6b568ebcc7bca3b02bb9df220bdd19df';

/// ViewModel backing the notification preferences screen: exposes the live
/// preferences plus per-field setters that persist to Firestore.

abstract class _$NotificationPreferencesViewModel
    extends $Notifier<NotificationPreferencesState> {
  NotificationPreferencesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<NotificationPreferencesState, NotificationPreferencesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                NotificationPreferencesState,
                NotificationPreferencesState
              >,
              NotificationPreferencesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
