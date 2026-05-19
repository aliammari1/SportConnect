// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CreateEventFormViewModel)
final createEventFormViewModelProvider = CreateEventFormViewModelProvider._();

final class CreateEventFormViewModelProvider
    extends $NotifierProvider<CreateEventFormViewModel, CreateEventFormState> {
  CreateEventFormViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createEventFormViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createEventFormViewModelHash();

  @$internal
  @override
  CreateEventFormViewModel create() => CreateEventFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateEventFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateEventFormState>(value),
    );
  }
}

String _$createEventFormViewModelHash() =>
    r'a4bef0a4a60321c8209c1cd4ce3674fa37d02c9b';

abstract class _$CreateEventFormViewModel
    extends $Notifier<CreateEventFormState> {
  CreateEventFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreateEventFormState, CreateEventFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateEventFormState, CreateEventFormState>,
              CreateEventFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(EditEventFormViewModel)
final editEventFormViewModelProvider = EditEventFormViewModelFamily._();

final class EditEventFormViewModelProvider
    extends $NotifierProvider<EditEventFormViewModel, EditEventFormState> {
  EditEventFormViewModelProvider._({
    required EditEventFormViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'editEventFormViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editEventFormViewModelHash();

  @override
  String toString() {
    return r'editEventFormViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditEventFormViewModel create() => EditEventFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditEventFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditEventFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditEventFormViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editEventFormViewModelHash() =>
    r'886ddc5be2653d06f5b172ed9aa5effa2fbbe230';

final class EditEventFormViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          EditEventFormViewModel,
          EditEventFormState,
          EditEventFormState,
          EditEventFormState,
          String
        > {
  EditEventFormViewModelFamily._()
    : super(
        retry: null,
        name: r'editEventFormViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EditEventFormViewModelProvider call(String eventId) =>
      EditEventFormViewModelProvider._(argument: eventId, from: this);

  @override
  String toString() => r'editEventFormViewModelProvider';
}

abstract class _$EditEventFormViewModel extends $Notifier<EditEventFormState> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  EditEventFormState build(String eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EditEventFormState, EditEventFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditEventFormState, EditEventFormState>,
              EditEventFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(EventSelectionViewModel)
final eventSelectionViewModelProvider = EventSelectionViewModelProvider._();

final class EventSelectionViewModelProvider
    extends $NotifierProvider<EventSelectionViewModel, EventSelectionState> {
  EventSelectionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSelectionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventSelectionViewModelHash();

  @$internal
  @override
  EventSelectionViewModel create() => EventSelectionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSelectionState>(value),
    );
  }
}

String _$eventSelectionViewModelHash() =>
    r'0dcafdf43d06f4eb7d7de42d447c921f96cc8816';

abstract class _$EventSelectionViewModel
    extends $Notifier<EventSelectionState> {
  EventSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EventSelectionState, EventSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventSelectionState, EventSelectionState>,
              EventSelectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(EventDetailViewModel)
final eventDetailViewModelProvider = EventDetailViewModelFamily._();

final class EventDetailViewModelProvider
    extends $NotifierProvider<EventDetailViewModel, EventDetailState> {
  EventDetailViewModelProvider._({
    required EventDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventDetailViewModelHash();

  @override
  String toString() {
    return r'eventDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventDetailViewModel create() => EventDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventDetailViewModelHash() =>
    r'4b45bf3bb7ba4b353a647fccf1cb8b0e0a084ba9';

final class EventDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          EventDetailViewModel,
          EventDetailState,
          EventDetailState,
          EventDetailState,
          String
        > {
  EventDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'eventDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventDetailViewModelProvider call(String eventId) =>
      EventDetailViewModelProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventDetailViewModelProvider';
}

abstract class _$EventDetailViewModel extends $Notifier<EventDetailState> {
  late final _$args = ref.$arg as String;
  String get eventId => _$args;

  EventDetailState build(String eventId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EventDetailState, EventDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventDetailState, EventDetailState>,
              EventDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// ViewModel for the event list screen.
///
/// Watches the upcoming events stream and applies client-side filtering
/// by type and search query.  Views should watch only this provider.

@ProviderFor(EventListViewModel)
final eventListViewModelProvider = EventListViewModelProvider._();

/// ViewModel for the event list screen.
///
/// Watches the upcoming events stream and applies client-side filtering
/// by type and search query.  Views should watch only this provider.
final class EventListViewModelProvider
    extends $NotifierProvider<EventListViewModel, EventListState> {
  /// ViewModel for the event list screen.
  ///
  /// Watches the upcoming events stream and applies client-side filtering
  /// by type and search query.  Views should watch only this provider.
  EventListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventListViewModelHash();

  @$internal
  @override
  EventListViewModel create() => EventListViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventListState>(value),
    );
  }
}

String _$eventListViewModelHash() =>
    r'b135739bb42fd3bba7f976039b8585828f1a76ec';

/// ViewModel for the event list screen.
///
/// Watches the upcoming events stream and applies client-side filtering
/// by type and search query.  Views should watch only this provider.

abstract class _$EventListViewModel extends $Notifier<EventListState> {
  EventListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EventListState, EventListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventListState, EventListState>,
              EventListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(upcomingEventsStream)
final upcomingEventsStreamProvider = UpcomingEventsStreamProvider._();

final class UpcomingEventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  UpcomingEventsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    return upcomingEventsStream(ref);
  }
}

String _$upcomingEventsStreamHash() =>
    r'8c8ed02563a5ddd1ec266a9f650ddf2f72327497';

@ProviderFor(eventsByTypeStream)
final eventsByTypeStreamProvider = EventsByTypeStreamFamily._();

final class EventsByTypeStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  EventsByTypeStreamProvider._({
    required EventsByTypeStreamFamily super.from,
    required EventType super.argument,
  }) : super(
         retry: null,
         name: r'eventsByTypeStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsByTypeStreamHash();

  @override
  String toString() {
    return r'eventsByTypeStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    final argument = this.argument as EventType;
    return eventsByTypeStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByTypeStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsByTypeStreamHash() =>
    r'5b2b2ae5aafee87bfa2bfa209018f271d8aa3244';

final class EventsByTypeStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, EventType> {
  EventsByTypeStreamFamily._()
    : super(
        retry: null,
        name: r'eventsByTypeStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventsByTypeStreamProvider call(EventType type) =>
      EventsByTypeStreamProvider._(argument: type, from: this);

  @override
  String toString() => r'eventsByTypeStreamProvider';
}

@ProviderFor(eventsByCreatorStream)
final eventsByCreatorStreamProvider = EventsByCreatorStreamFamily._();

final class EventsByCreatorStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  EventsByCreatorStreamProvider._({
    required EventsByCreatorStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventsByCreatorStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsByCreatorStreamHash();

  @override
  String toString() {
    return r'eventsByCreatorStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    final argument = this.argument as String;
    return eventsByCreatorStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByCreatorStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsByCreatorStreamHash() =>
    r'28278a027f4d4985937a30756f67e9fa819fb143';

final class EventsByCreatorStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, String> {
  EventsByCreatorStreamFamily._()
    : super(
        retry: null,
        name: r'eventsByCreatorStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventsByCreatorStreamProvider call(String creatorId) =>
      EventsByCreatorStreamProvider._(argument: creatorId, from: this);

  @override
  String toString() => r'eventsByCreatorStreamProvider';
}

@ProviderFor(joinedEventsStream)
final joinedEventsStreamProvider = JoinedEventsStreamFamily._();

final class JoinedEventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  JoinedEventsStreamProvider._({
    required JoinedEventsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'joinedEventsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$joinedEventsStreamHash();

  @override
  String toString() {
    return r'joinedEventsStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    final argument = this.argument as String;
    return joinedEventsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinedEventsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$joinedEventsStreamHash() =>
    r'c7512c9c41fc741860321c32040eb9d42a3d9ca5';

final class JoinedEventsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, String> {
  JoinedEventsStreamFamily._()
    : super(
        retry: null,
        name: r'joinedEventsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  JoinedEventsStreamProvider call(String userId) =>
      JoinedEventsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'joinedEventsStreamProvider';
}

@ProviderFor(eventById)
final eventByIdProvider = EventByIdFamily._();

final class EventByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventModel?>,
          EventModel?,
          Stream<EventModel?>
        >
    with $FutureModifier<EventModel?>, $StreamProvider<EventModel?> {
  EventByIdProvider._({
    required EventByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventByIdHash();

  @override
  String toString() {
    return r'eventByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<EventModel?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<EventModel?> create(Ref ref) {
    final argument = this.argument as String;
    return eventById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventByIdHash() => r'99b3bd74dab8bae92131799c7e3b5a16bea1b5bc';

final class EventByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<EventModel?>, String> {
  EventByIdFamily._()
    : super(
        retry: null,
        name: r'eventByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventByIdProvider call(String eventId) =>
      EventByIdProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventByIdProvider';
}

/// Streams rides linked to a specific event by querying rides with matching eventId.

@ProviderFor(eventLinkedRides)
final eventLinkedRidesProvider = EventLinkedRidesFamily._();

/// Streams rides linked to a specific event by querying rides with matching eventId.

final class EventLinkedRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// Streams rides linked to a specific event by querying rides with matching eventId.
  EventLinkedRidesProvider._({
    required EventLinkedRidesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventLinkedRidesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventLinkedRidesHash();

  @override
  String toString() {
    return r'eventLinkedRidesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return eventLinkedRides(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventLinkedRidesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventLinkedRidesHash() => r'fee8b15d6625e823031dea717797370c987f2939';

/// Streams rides linked to a specific event by querying rides with matching eventId.

final class EventLinkedRidesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, String> {
  EventLinkedRidesFamily._()
    : super(
        retry: null,
        name: r'eventLinkedRidesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Streams rides linked to a specific event by querying rides with matching eventId.

  EventLinkedRidesProvider call(String eventId) =>
      EventLinkedRidesProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventLinkedRidesProvider';
}
