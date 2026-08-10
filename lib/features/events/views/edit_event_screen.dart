import 'dart:async';
import 'dart:io';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/models/location/location_point.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/map_location_picker.dart';
import 'package:sport_connect/core/widgets/premium_button.dart';
import 'package:sport_connect/features/events/models/event_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Full-screen event editing form.
///
/// Loads the event by [eventId]. On success, pops with the updated [EventModel].
class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({required this.eventId, super.key});

  final String eventId;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  final DateFormat _dateFormat = DateFormat('EEE, MMM d, yyyy');
  final DateFormat _timeFormat = DateFormat('h:mm a');

  bool _isSyncingTextControllers = false;

  EditEventFormViewModel get _editForm =>
      ref.read(editEventFormViewModelProvider(widget.eventId).notifier);

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onTitleChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onDescriptionChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventActions = ref.watch(
      eventDetailViewModelProvider(widget.eventId),
    );
    final editState = ref.watch(editEventFormViewModelProvider(widget.eventId));

    ref
      ..listen(
        eventDetailViewModelProvider(widget.eventId),
        _onEventActionStateChanged,
      )
      ..listen(
        editEventFormViewModelProvider(widget.eventId),
        _onEditStateChanged,
      );

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 22.sp,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.pop(),
        ),
        title: AppLocalizations.of(context).editEventTitle,
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthForm,
        child: _buildBody(editState, eventActions),
      ),
    );
  }

  void _onEventActionStateChanged(
    EventDetailState? previous,
    EventDetailState next,
  ) {
    _showNewError(previous?.error, next.error);
  }

  void _onEditStateChanged(
    EditEventFormState? previous,
    EditEventFormState next,
  ) {
    if (next.isLoaded && previous?.isLoaded != true) {
      _syncTextControllers(next);
    }

    _showNewError(previous?.error, next.error);

    final savedEvent = next.savedEvent;
    if (savedEvent != null && previous?.savedEvent == null && context.mounted) {
      context.pop(savedEvent);
    }
  }

  void _showNewError(String? previousError, String? nextError) {
    if (nextError == null || nextError == previousError || !context.mounted) {
      return;
    }

    AdaptiveSnackBar.show(
      context,
      message: _localizedEventError(nextError),
      type: AdaptiveSnackBarType.error,
    );
  }

  void _syncTextControllers(EditEventFormState state) {
    // Detach listeners around the assignment. The previous flag-based guard
    // (`_isSyncingTextControllers`) relied on the synchronous nature of
    // ChangeNotifier.notifyListeners — but in practice `controller.text = ...`
    // and an immediate reset of the flag can leave a small window where the
    // listener fires after the flag is back to false, causing the freshly
    // hydrated value to be immediately overwritten by a stale setTitle call.
    // Removing the listeners for the duration of the sync is the only fully
    // race-free approach.
    _titleController.removeListener(_onTitleChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    try {
      _titleController.text = state.title;
      _descriptionController.text = state.description;
    } finally {
      _titleController.addListener(_onTitleChanged);
      _descriptionController.addListener(_onDescriptionChanged);
    }
    // Defensive: keep the flag check in dispose() ordering intact. Future
    // refactors that bypass the listener detach should still skip via flag.
    _isSyncingTextControllers = false;
  }

  void _onTitleChanged() {
    if (_isSyncingTextControllers) return;
    _editForm.setTitle(_titleController.text);
  }

  void _onDescriptionChanged() {
    if (_isSyncingTextControllers) return;
    _editForm.setDescription(_descriptionController.text);
  }

  Widget _buildBody(
    EditEventFormState editState,
    EventDetailState eventActions,
  ) {
    if (editState.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (!editState.isLoaded) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Text(
            AppLocalizations.of(context).eventUnableToLoadOriginal,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final formItems = <Widget>[
      _buildSportTypeSelector(editState),
      SizedBox(height: 20.h),
      _buildTitleField(editState),
      SizedBox(height: 14.h),
      _buildDescriptionField(),
      SizedBox(height: 20.h),
      _buildImagePicker(editState),
      SizedBox(height: 20.h),
      _buildLocationPicker(editState),
      SizedBox(height: 20.h),
      _buildWhenSection(editState),
      SizedBox(height: 20.h),
      _buildParticipantSlider(editState),
      SizedBox(height: 20.h),
      _buildRecurringSection(editState),
      SizedBox(height: 32.h),
      _buildSubmitButton(eventActions.isLoading || editState.isSubmitting),
    ];

    return ListView.builder(
      padding: adaptiveScreenPadding(context),
      itemCount: formItems.length,
      itemBuilder: (context, index) => formItems[index],
    );
  }

  Widget _buildSportTypeSelector(EditEventFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context).eventSportType),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: EventType.values.map((type) {
            final isSelected = state.type == type;
            return GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                _editForm.setType(type);
              },
              child: AnimatedContainer(
                duration: 150.ms,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type.color.withValues(alpha: 0.13)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected ? type.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(type.icon, size: 14.sp, color: type.color),
                    SizedBox(width: 6.w),
                    Text(
                      AppLocalizations.of(context).running,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? type.color
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }

  Widget _buildTitleField(EditEventFormState state) {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: _titleController,
      maxLength: 100,
      textCapitalization: TextCapitalization.words,
      decoration: _fieldDecoration(
        l10n.eventTitleField,
        Icons.title_rounded,
        errorText: _titleErrorText(state),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 60.ms);
  }

  Widget _buildDescriptionField() {
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: _descriptionController,
      maxLines: 3,
      minLines: 2,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: _fieldDecoration(
        l10n.eventDescriptionField,
        Icons.notes_rounded,
      ),
    ).animate().fadeIn(duration: 250.ms, delay: 140.ms);
  }

  Widget _buildImagePicker(EditEventFormState state) {
    final existingImageUrl = state.visibleImageUrl;
    final hasImage = state.imageFile != null || existingImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context).eventCoverImage),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              image: _imageDecoration(state.imageFile, existingImageUrl),
            ),
            child: hasImage ? _buildRemoveImageButton() : _buildAddImageHint(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 160.ms);
  }

  DecorationImage? _imageDecoration(File? imageFile, String? imageUrl) {
    if (imageFile != null) {
      return DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return DecorationImage(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildRemoveImageButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.black54,
          child: IconButton(
            icon: Icon(Icons.close, size: 16.sp, color: Colors.white),
            padding: EdgeInsets.zero,
            onPressed: _editForm.clearSelectedImage,
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageHint() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 36.sp,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context).eventTapToAddPhoto,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: kMaxWidthWide,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image == null || !mounted) return;
    _editForm.setImageFile(File(image.path));
  }

  Widget _buildLocationPicker(EditEventFormState state) {
    final hasLocation = state.location != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(AppLocalizations.of(context).eventLocationField),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickLocation,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasLocation ? AppColors.success : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasLocation
                      ? Icons.check_circle_rounded
                      : Icons.location_on_outlined,
                  size: 20.sp,
                  color: hasLocation
                      ? AppColors.success
                      : AppColors.textTertiary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    state.location?.address ??
                        AppLocalizations.of(context).eventTapToPickLocation,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: hasLocation
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 180.ms);
  }

  Future<void> _pickLocation() async {
    final result = await MapLocationPicker.show(
      context,
      title: AppLocalizations.of(context).eventLocationTitle,
    );

    if (result == null || !mounted) return;
    _editForm.setLocation(
      LocationPoint(
        latitude: result.location.latitude,
        longitude: result.location.longitude,
        address: result.address,
      ),
    );
  }

  Widget _buildWhenSection(EditEventFormState state) {
    final startsAt = state.startsAt!;
    final endsAt = state.endsAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          AppLocalizations.of(context).eventWhenField.replaceAll(' *', ''),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _DateTimeChip(
                icon: Icons.calendar_today_rounded,
                label: _dateFormat.format(startsAt),
                onTap: () => _pickDate(state, isStart: true),
              ),
            ),
            SizedBox(width: 8.w),
            _DateTimeChip(
              icon: Icons.access_time_rounded,
              label: _timeFormat.format(startsAt),
              onTap: () => _pickTime(state, isStart: true),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              AppLocalizations.of(context).eventEndLabel,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: endsAt == null
                  ? _buildAddEndTimeButton(state)
                  : _buildEndDateTimeControls(state, endsAt),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 220.ms);
  }

  Widget _buildAddEndTimeButton(EditEventFormState state) {
    return GestureDetector(
      onTap: () => _pickTime(state, isStart: false),
      child: Text(
        AppLocalizations.of(context).eventAddEndTime,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEndDateTimeControls(EditEventFormState state, DateTime endsAt) {
    return Row(
      children: [
        Flexible(
          child: _DateTimeChip(
            icon: Icons.calendar_today_rounded,
            label: _dateFormat.format(endsAt),
            onTap: () => _pickDate(state, isStart: false),
          ),
        ),
        SizedBox(width: 6.w),
        _DateTimeChip(
          icon: Icons.access_time_rounded,
          label: _timeFormat.format(endsAt),
          onTap: () => _pickTime(state, isStart: false),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => _editForm.setEndsAt(null),
          child: Icon(
            Icons.close_rounded,
            size: 18.sp,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantSlider(EditEventFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel(AppLocalizations.of(context).eventMaxParticipants),
            const Spacer(),
            Text(
              state.maxParticipants == 0
                  ? AppLocalizations.of(context).eventUnlimited
                  : '${state.maxParticipants}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        AdaptiveSlider(
          value: state.maxParticipants.toDouble(),
          max: 100,
          divisions: 20,
          activeColor: AppColors.primary,
          label: state.maxParticipants == 0
              ? AppLocalizations.of(context).eventUnlimited
              : '${state.maxParticipants}',
          onChanged: (value) => _editForm.setMaxParticipants(value.round()),
        ),
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 260.ms);
  }

  Widget _buildRecurringSection(EditEventFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          value: state.isRecurring,
          onChanged: (value) {
            unawaited(HapticFeedback.selectionClick());
            _editForm.setRecurring(value: value);
          },
          title: Text(
            AppLocalizations.of(context).eventRecurring,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context).eventRecurringSubtitle,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          secondary: Icon(
            Icons.repeat_rounded,
            size: 22.sp,
            color: AppColors.primary,
          ),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
        if (state.isRecurring) ...[
          SizedBox(height: 12.h),
          _buildRecurrencePatternButton(state),
          SizedBox(height: 12.h),
          _buildRecurringEndDateButton(state),
        ],
      ],
    ).animate().fadeIn(duration: 250.ms, delay: 280.ms);
  }

  Widget _buildRecurrencePatternButton(EditEventFormState state) {
    return GestureDetector(
      onTap: _showRecurrencePatternPicker,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18.sp,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 10.w),
                Text(
                  state.recurringPattern != null
                      ? _recurrenceLabel(
                          AppLocalizations.of(context),
                          state.recurringPattern!,
                        )
                      : AppLocalizations.of(
                          context,
                        ).select_a_recurrence_pattern,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: state.recurringPattern != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 18.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringEndDateButton(EditEventFormState state) {
    return GestureDetector(
      onTap: () => _pickRecurringEndDate(state),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.event_repeat_rounded,
              size: 18.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: 10.w),
            Text(
              state.recurringEndDate != null
                  ? AppLocalizations.of(context).eventRepeatsUntil(
                      DateFormat('MMM d, y').format(state.recurringEndDate!),
                    )
                  : AppLocalizations.of(context).eventRepeatEndDate,
              style: TextStyle(
                fontSize: 12.sp,
                color: state.recurringEndDate != null
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRecurrencePatternPicker() async {
    final state = ref.read(editEventFormViewModelProvider(widget.eventId));
    final patterns = state.applicablePatterns;

    await AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).repeat,
      maxHeightFactor: 0.7,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                AppLocalizations.of(context).repeat,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
            if (patterns.isEmpty)
              Padding(
                padding: adaptiveScreenPadding(
                  context,
                ).copyWith(bottom: 8.h, top: 8.h),
                child: Text(
                  '${AppLocalizations.of(context).no_recurrence_pattern_fits_this_startend_window}'
                  '${AppLocalizations.of(context).extend_end_time_or_set_a_later_repeat_end_date}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...patterns.map(_buildRecurrencePatternOption),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrencePatternOption(RecurrencePattern pattern) {
    final state = ref.read(editEventFormViewModelProvider(widget.eventId));
    final isSelected = state.recurringPattern == pattern;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: GestureDetector(
        onTap: () {
          _editForm.setRecurringPattern(pattern);
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 20.sp,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
              SizedBox(width: 12.w),
              Text(
                _recurrenceLabel(AppLocalizations.of(context), pattern),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickRecurringEndDate(EditEventFormState state) async {
    final now = DateTime.now();
    final firstDate = _dateOnly(state.startsAt ?? now);
    final latestAllowed = now.add(const Duration(days: 365));
    final lastDate = latestAllowed.isAfter(firstDate)
        ? latestAllowed
        : firstDate.add(const Duration(days: 365));
    final initialDate = _clampDate(
      state.recurringEndDate ?? firstDate.add(const Duration(days: 30)),
      firstDate,
      lastDate,
    );

    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initialDate,
    );

    if (picked == null || !mounted) return;
    _editForm.setRecurringEndDate(picked);
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return PremiumButton(
      text: AppLocalizations.of(context).eventSaveChanges,
      icon: Icons.check_rounded,
      fullWidth: true,
      isLoading: isSubmitting,
      onPressed: _submit,
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _editForm.submit();
  }

  Future<void> _pickDate(
    EditEventFormState state, {
    required bool isStart,
  }) async {
    final now = DateTime.now();
    final currentValue = isStart
        ? state.startsAt!
        : (state.endsAt ?? state.startsAt!);
    final firstDate = DateTime(2000);
    final lastDate = now.add(const Duration(days: 365));
    final initialDate = _clampDate(currentValue, firstDate, lastDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked == null || !mounted) return;

    final latestState = ref.read(
      editEventFormViewModelProvider(widget.eventId),
    );
    final base = isStart
        ? latestState.startsAt!
        : (latestState.endsAt ?? latestState.startsAt!);
    final nextValue = DateTime(
      picked.year,
      picked.month,
      picked.day,
      base.hour,
      base.minute,
    );

    if (isStart) {
      _editForm.setStartsAt(nextValue);
    } else {
      _editForm.setEndsAt(nextValue);
    }
  }

  Future<void> _pickTime(
    EditEventFormState state, {
    required bool isStart,
  }) async {
    final currentValue = isStart
        ? state.startsAt!
        : (state.endsAt ?? state.startsAt!);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentValue),
    );

    if (picked == null || !mounted) return;

    final latestState = ref.read(
      editEventFormViewModelProvider(widget.eventId),
    );
    final base = isStart
        ? latestState.startsAt!
        : (latestState.endsAt ?? latestState.startsAt!);
    final nextValue = DateTime(
      base.year,
      base.month,
      base.day,
      picked.hour,
      picked.minute,
    );

    if (isStart) {
      _editForm.setStartsAt(nextValue);
    } else {
      _editForm.setEndsAt(nextValue);
    }
  }

  InputDecoration _fieldDecoration(
    String label,
    IconData icon, {
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      errorText: errorText,
      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
      prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textTertiary),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  String? _titleErrorText(EditEventFormState state) {
    if (!state.hasAttemptedSubmit) return null;

    final title = state.title.trim();
    if (title.isEmpty) return AppLocalizations.of(context).eventTitleRequired;
    if (title.length < 3) {
      return AppLocalizations.of(context).eventTitleMinLength;
    }
    return null;
  }

  String _localizedEventError(String error) {
    final l10n = AppLocalizations.of(context);
    switch (error) {
      case 'Unable to load event details. Please try again later.':
      case 'Unable to load the original event.':
        return l10n.eventUnableToLoadOriginal;
      case 'Unable to update event. Please try again.':
        return l10n.eventUnableToUpdate;
      case 'Please sign in to create an event.':
        return l10n.eventSignInRequired;
      case 'Title is required':
        return l10n.eventTitleRequired;
      case 'Title must be at least 3 characters':
        return l10n.eventTitleMinLength;
      case 'Please select a location.':
      case 'Please pick a location.':
        return l10n.selectLocationError;
      case 'Start time must be in the future.':
        return l10n.eventStartTimeFuture;
      case 'End time must be after start time.':
        return l10n.eventEndTimeAfterStart;
      default:
        return error;
    }
  }

  String _recurrenceLabel(AppLocalizations l10n, RecurrencePattern pattern) {
    return switch (pattern) {
      RecurrencePattern.daily => l10n.every_day,
      RecurrencePattern.weekly => l10n.every_week,
      RecurrencePattern.biweekly => l10n.every_2_weeks,
      RecurrencePattern.monthly => l10n.every_month,
      RecurrencePattern.yearly => l10n.every_year,
    };
  }
}

class _DateTimeChip extends StatelessWidget {
  const _DateTimeChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
  if (value.isBefore(min)) return min;
  if (value.isAfter(max)) return max;
  return value;
}
