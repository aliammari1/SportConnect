// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for notifications screen

@ProviderFor(NotificationViewModel)
final notificationViewModelProvider = NotificationViewModelProvider._();

/// ViewModel for notifications screen
final class NotificationViewModelProvider
    extends $NotifierProvider<NotificationViewModel, NotificationState> {
  /// ViewModel for notifications screen
  NotificationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationViewModelHash();

  @$internal
  @override
  NotificationViewModel create() => NotificationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationState>(value),
    );
  }
}

String _$notificationViewModelHash() =>
    r'a220da6d502d08b3643e79356f8ba5461b06ba2b';

/// ViewModel for notifications screen

abstract class _$NotificationViewModel extends $Notifier<NotificationState> {
  NotificationState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<NotificationState, NotificationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NotificationState, NotificationState>,
              NotificationState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Stream provider for user notifications

@ProviderFor(userNotifications)
final userNotificationsProvider = UserNotificationsProvider._();

/// Stream provider for user notifications

final class UserNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NotificationModel>>,
          List<NotificationModel>,
          Stream<List<NotificationModel>>
        >
    with
        $FutureModifier<List<NotificationModel>>,
        $StreamProvider<List<NotificationModel>> {
  /// Stream provider for user notifications
  UserNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<NotificationModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<NotificationModel>> create(Ref ref) {
    return userNotifications(ref);
  }
}

String _$userNotificationsHash() => r'9898eec51299a56db7d31259fc73e87d47303316';
