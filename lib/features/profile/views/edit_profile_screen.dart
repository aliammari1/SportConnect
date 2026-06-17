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
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/address_autocomplete_field.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/expertise_picker.dart';
import 'package:sport_connect/core/widgets/form_card.dart';
import 'package:sport_connect/core/widgets/form_section_header.dart';
import 'package:sport_connect/core/widgets/intl_phone_input.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/premium_avatar.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

const _kGenderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = FormGroup({
    'name': FormControl<String>(
      validators: [
        Validators.required,
        Validators.minLength(2),
        Validators.maxLength(60),
        Validators.delegate((control) {
          final value = (control.value as String?)?.trim();
          if (value == null || value.isEmpty) return null;
          if (RegExp('[0-9]').hasMatch(value)) {
            return {'name': 'name_cannot_contain_numbers'};
          }
          if (!RegExp(r"^[\p{L}\s\-'.]+$", unicode: true).hasMatch(value)) {
            return {'name': 'name_contains_invalid_characters'};
          }
          return null;
        }),
      ],
    ),
    'email': FormControl<String>(),
  });

  final _phoneKey = GlobalKey<IntlPhoneInputState>();
  final _addressKey = GlobalKey<AddressAutocompleteFieldState>();
  final _imagePicker = ImagePicker();

  UserModel? _user;
  bool _initialized = false;
  StreamSubscription<Map<String, Object?>?>? _formChangesSub;

  @override
  void dispose() {
    _formChangesSub?.cancel();
    _form.dispose();
    super.dispose();
  }

  void _hydrate(UserModel user) {
    _user = user;
    _initialized = true;
    _form.patchValue({'name': user.username, 'email': user.email});
    _formChangesSub?.cancel();
    _formChangesSub = _form.valueChanges.listen((_) {
      if (!mounted) return;
      ref.read(profileEditViewModelProvider(user.uid).notifier).markChanged();
    });
    // _hydrate is invoked from a post-frame callback (not during build), so the
    // FormGroup patch, stream subscription, and provider mutation below all run
    // outside the build phase and cannot trigger "modify a provider while the
    // widget tree was building".
    ref
        .read(profileEditViewModelProvider(user.uid).notifier)
        .initFromUser(user);
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final user = _user;
    if (user == null) return;

    _form.markAllAsTouched();
    if (!_form.valid) return;

    final phoneError = _phoneKey.currentState?.validate();
    if (phoneError != null) return;

    final notifier = ref.read(profileEditViewModelProvider(user.uid).notifier);
    final editState = ref.read(profileEditViewModelProvider(user.uid));

    final name = (_form.control('name').value as String?)?.trim() ?? '';
    final phone = editState.phoneNumber?.trim().isNotEmpty == true
        ? editState.phoneNumber
        : null;
    final address =
        editState.addressResult?.address ?? _addressKey.currentState?.text;

    final updated = user.map(
      rider: (r) => r.copyWith(
        username: name,
        phoneNumber: phone ?? r.phoneNumber,
        address: address ?? r.address,
        gender: editState.gender ?? r.gender,
        dateOfBirth: editState.dateOfBirth ?? r.dateOfBirth,
        expertise: editState.expertise,
      ),
      driver: (d) => d.copyWith(
        username: name,
        phoneNumber: phone ?? d.phoneNumber,
        address: address ?? d.address,
        gender: editState.gender ?? d.gender,
        dateOfBirth: editState.dateOfBirth ?? d.dateOfBirth,
        expertise: editState.expertise,
      ),
      pending: (p) => p,
    );

    unawaited(HapticFeedback.mediumImpact());
    await notifier.saveUserProfile(
      updatedUser: updated,
      newPhotoFile: editState.newPhotoFile,
      removePhoto: editState.imageRemoved,
    );
  }

  // ─── Photo handling ────────────────────────────────────────────────────────

  void _showPhotoSheet() {
    final user = _user;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(profileEditViewModelProvider(user.uid).notifier);
    final hasExisting =
        (user.photoUrl?.isNotEmpty ?? false) &&
        !ref.read(profileEditViewModelProvider(user.uid)).imageRemoved;

    unawaited(
      AppModalSheet.show<void>(
        context: context,
        title: l10n.changeProfilePhoto,
        maxHeightFactor: 0.6,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PhotoActionTile(
                icon: Icons.camera_alt_rounded,
                color: AppColors.primary,
                label: l10n.takePhoto,
                onTap: () async {
                  context.pop();
                  await _pickPhoto(ImageSource.camera, notifier);
                },
              ),
              SizedBox(height: 8.h),
              _PhotoActionTile(
                icon: Icons.photo_library_rounded,
                color: AppColors.secondary,
                label: l10n.chooseFromGallery,
                onTap: () async {
                  context.pop();
                  await _pickPhoto(ImageSource.gallery, notifier);
                },
              ),
              if (hasExisting) ...[
                SizedBox(height: 8.h),
                _PhotoActionTile(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.error,
                  label: l10n.removePhoto,
                  destructive: true,
                  onTap: () {
                    context.pop();
                    notifier.removePhoto();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(
    ImageSource source,
    ProfileEditViewModel notifier,
  ) async {
    final l10n = AppLocalizations.of(context);
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: source == ImageSource.camera
          ? l10n.profilePhotoCameraPermission
          : l10n.profilePhotoLibraryPermission,
    );
    if (!accepted) return;
    final image = await _imagePicker.pickImage(source: source);
    if (image != null) notifier.setPhotoFile(File(image.path));
  }

  String _genderLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'Male':
        return l10n.genderMale;
      case 'Female':
        return l10n.genderFemale;
      case 'Other':
        return l10n.other;
      case 'Prefer not to say':
        return l10n.preferNotToSay;
      default:
        return value;
    }
  }

  // ─── Pickers ───────────────────────────────────────────────────────────────

  void _showGenderPicker() {
    final user = _user;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(profileEditViewModelProvider(user.uid).notifier);
    final current = ref.read(profileEditViewModelProvider(user.uid)).gender;

    unawaited(
      AppModalSheet.show<void>(
        context: context,
        title: l10n.selectGender,
        maxHeightFactor: 0.55,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _kGenderOptions
                .map(
                  (g) => _GenderOption(
                    label: g,
                    selected: g == current,
                    onTap: () {
                      notifier.setGender(g);
                      context.pop();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final user = _user;
    if (user == null) return;
    final notifier = ref.read(profileEditViewModelProvider(user.uid).notifier);
    final current =
        ref.read(profileEditViewModelProvider(user.uid)).dateOfBirth ??
        DateTime(1990);

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1920),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) notifier.setDateOfBirth(picked);
  }

  Future<bool> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final result = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.discardChanges),
        content: Text(l10n.youHaveUnsavedChanges),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.discard,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider.select((a) => a.value));

    // Hydration mutates the FormGroup, opens a stream subscription, and mutates
    // a provider — all side effects that must not run synchronously inside
    // build(). Schedule it for after this frame so it runs once a non-null user
    // is available, whether the provider was already resolved on first build or
    // resolves on a later rebuild.
    if (user != null && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _initialized) return;
        _hydrate(user);
      });
    }

    // Register the save-result listener unconditionally. The uid is derived
    // from the watched user (falling back to the lazily-hydrated _user) so the
    // listener is declared every build and no isSaved/error transition is
    // missed before _user is set.
    final listenUid = user?.uid ?? _user?.uid;
    if (listenUid != null) {
      ref.listen(profileEditViewModelProvider(listenUid), (prev, next) {
        if (!context.mounted) return;
        if (next.isSaved && prev?.isSaved != true) {
          AdaptiveSnackBar.show(
            context,
            message: l10n.profileUpdated,
            type: AdaptiveSnackBarType.success,
          );
          context.pop();
        }
        if (next.error != null && next.error != prev?.error) {
          AdaptiveSnackBar.show(
            context,
            message: l10n.errorValue(next.error!),
            type: AdaptiveSnackBarType.error,
          );
        }
      });
    }

    final editState = _user == null
        ? const ProfileEditState()
        : ref.watch(profileEditViewModelProvider(_user!.uid));

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () async {
            if (!editState.hasChanges || await _confirmDiscard()) {
              if (context.mounted) context.pop();
            }
          },
          icon: Icon(Icons.adaptive.arrow_back_rounded),
        ),
        title: l10n.settingsEditProfile,
      ),
      body: PopScope(
        canPop: !editState.hasChanges,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (await _confirmDiscard() && context.mounted) context.pop();
        },
        child: user == null
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, user, editState),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    UserModel user,
    ProfileEditState editState,
  ) {
    final isDriver = user.isDriver;

    return MaxWidthContainer(
      maxWidth: context.isTabletOrLarger ? 1120 : kMaxWidthFormNarrow,
      child: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: adaptiveScreenPadding(context).copyWith(bottom: 120.h),
            children: [
              ResponsiveLayoutBuilder(
                phone: (_) => Column(
                  children: [
                    _AvatarHeader(
                          user: user,
                          editState: editState,
                          onTap: _showPhotoSheet,
                        )
                        .animate()
                        .fadeIn(duration: 320.ms)
                        .slideY(
                          begin: 0.05,
                          end: 0,
                        ),
                    SizedBox(height: 28.h),
                    _buildFormSections(context, user, editState, isDriver),
                  ],
                ),
                tablet: (_) => ReactiveForm(
                  formGroup: _form,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _ProfileOverviewCard(
                                  user: user,
                                  editState: editState,
                                  onTapAvatar: _showPhotoSheet,
                                )
                                .animate()
                                .fadeIn(
                                  duration: 320.ms,
                                )
                                .slideY(begin: 0.05, end: 0),
                            SizedBox(height: 20.h),
                            _buildDriverQuickCard(context, user, isDriver),
                          ],
                        ),
                      ),
                      SizedBox(width: 24.w),
                      Expanded(
                        flex: 7,
                        child: _buildFormSections(
                          context,
                          user,
                          editState,
                          isDriver,
                          wrapInForm: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _SaveBar(
              enabled: editState.hasChanges,
              isLoading: editState.isLoading,
              onPressed: _save,
              label: AppLocalizations.of(context).saveChanges,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSections(
    BuildContext context,
    UserModel user,
    ProfileEditState editState,
    bool isDriver, {
    bool wrapInForm = true,
  }) {
    // Two-column form only in landscape-width (≥ 1100); portrait iPad uses a
    // single column so the fields aren't squeezed into a narrow half-pane.
    final content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1100) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _formSectionChildren(context, user, editState, isDriver),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _leftFormSectionChildren(context, user, editState),
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _rightFormSectionChildren(
                  context,
                  user,
                  editState,
                  isDriver,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!wrapInForm) return content;
    return ReactiveForm(formGroup: _form, child: content);
  }

  List<Widget> _formSectionChildren(
    BuildContext context,
    UserModel user,
    ProfileEditState editState,
    bool isDriver,
  ) {
    return [
      ..._leftFormSectionChildren(context, user, editState),
      SizedBox(height: 24.h),
      ..._rightFormSectionChildren(context, user, editState, isDriver),
    ];
  }

  List<Widget> _leftFormSectionChildren(
    BuildContext context,
    UserModel user,
    ProfileEditState editState,
  ) {
    final l10n = AppLocalizations.of(context);

    return [
      FormSectionHeader(
        icon: Icons.person_outline_rounded,
        title: l10n.personalInformation,
        padding: EdgeInsets.only(left: 4.w),
      ),
      SizedBox(height: 12.h),
      FormCard(
        children: [
          AdaptiveReactiveTextField(
            formControlName: 'name',
            labelText: l10n.authFullName,
            prefixIcon: Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
            validationMessages: {
              ValidationMessage.required: (_) => l10n.requiredField,
              ValidationMessage.minLength: (_) => l10n.nameMinLengthError,
              ValidationMessage.maxLength: (_) => l10n.nameTooLongError,
              'name': (error) => switch (error as String) {
                'name_cannot_contain_numbers' =>
                  l10n.name_cannot_contain_numbers,
                'name_contains_invalid_characters' =>
                  l10n.name_contains_invalid_characters,
                _ => error,
              },
            },
          ),
          SizedBox(height: 14.h),
          AdaptiveReactiveTextField(
            formControlName: 'email',
            readOnly: true,
            labelText: l10n.authEmail,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
            suffixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 16.sp,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 14.h),
          IntlPhoneInput(
            key: _phoneKey,
            label: l10n.phone_number,
            hint: l10n.phoneNumberHint,
            accentColor: AppColors.primary,
            fillColor: AppColors.primary.withValues(alpha: 0.06),
            initialValue: switch (user) {
              final RiderModel r => r.asRider?.phoneNumber,
              final DriverModel d => d.asDriver?.phoneNumber,
              _ => null,
            },
            onChanged: (phone) {
              ref
                  .read(profileEditViewModelProvider(user.uid).notifier)
                  .setPhoneNumber(phone.fullNumber);
            },
          ),
        ],
      ),
      SizedBox(height: 24.h),
      FormSectionHeader(
        icon: Icons.tune_rounded,
        title: l10n.aboutYou,
        padding: EdgeInsets.only(left: 4.w),
      ),
      SizedBox(height: 12.h),
      FormCard(
        children: [
          AddressAutocompleteField(
            key: _addressKey,
            label: l10n.address,
            hint: l10n.searchAddressCityOrPlace,
            accentColor: AppColors.primary,
            initialValue: switch (user) {
              final RiderModel r => r.asRider?.address,
              final DriverModel d => d.asDriver?.address,
              _ => null,
            },
            onSelected: (result) => ref
                .read(profileEditViewModelProvider(user.uid).notifier)
                .setAddressResult(result),
          ),
          SizedBox(height: 16.h),
          ExpertisePicker(
            label: l10n.expertiseLevel,
            value: editState.expertise,
            accent: AppColors.primary,
            textColor: AppColors.textPrimary,
            cardBg: AppColors.surface,
            onChanged: (level) => ref
                .read(profileEditViewModelProvider(user.uid).notifier)
                .setExpertise(level),
          ),
        ],
      ),
    ];
  }

  List<Widget> _rightFormSectionChildren(
    BuildContext context,
    UserModel user,
    ProfileEditState editState,
    bool isDriver,
  ) {
    final l10n = AppLocalizations.of(context);
    final children = <Widget>[
      FormSectionHeader(
        icon: Icons.badge_outlined,
        title: l10n.demographics,
        padding: EdgeInsets.only(left: 4.w),
      ),
      SizedBox(height: 12.h),
      FormCard(
        children: [
          _PickerTile(
            icon: Icons.wc_rounded,
            label: l10n.gender,
            value: editState.gender == null
                ? '—'
                : _genderLabel(context, editState.gender!),
            onTap: _showGenderPicker,
          ),
          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.5),
          ),
          _PickerTile(
            icon: Icons.cake_outlined,
            label: l10n.birthday,
            value: editState.dateOfBirth == null
                ? '—'
                : AppLocaleFormatters.formatMediumDate(
                    context,
                    editState.dateOfBirth!,
                  ),
            onTap: _selectDateOfBirth,
          ),
        ],
      ),
    ];

    if (isDriver) {
      children
        ..add(SizedBox(height: 24.h))
        ..add(
          FormSectionHeader(
            icon: Icons.directions_car_outlined,
            title: l10n.driverSettings,
            padding: EdgeInsets.only(left: 4.w),
          ),
        )
        ..add(SizedBox(height: 12.h))
        ..add(
          FormCard(
            children: [
              _PickerTile(
                icon: Icons.directions_car_rounded,
                label: l10n.myVehicles,
                value: '${user.asDriver?.vehicles.length ?? 0} ${l10n.active}',
                onTap: () => context.push(AppRoutes.driverVehicles.path),
              ),
            ],
          ),
        );
    }

    return children;
  }

  Widget _buildDriverQuickCard(
    BuildContext context,
    UserModel user,
    bool isDriver,
  ) {
    if (!isDriver) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final vehicleCount = user.asDriver?.vehicles.length ?? 0;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.driverVehicles.path),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.secondary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: AppColors.primary,
                size: 26.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.myVehicles,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$vehicleCount ${l10n.active}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.user,
    required this.editState,
    required this.onTap,
  });

  final UserModel user;
  final ProfileEditState editState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildImage()),
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2.5),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            l10n.changePhoto,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    const size = 110.0;
    if (editState.newPhotoFile != null) {
      return Image.file(
        editState.newPhotoFile!,
        width: size.w,
        height: size.w,
        fit: BoxFit.cover,
      );
    }
    final url = user.photoUrl;
    if (url != null && url.isNotEmpty && !editState.imageRemoved) {
      return CachedNetworkImage(
        imageUrl: url,
        width: size.w,
        height: size.w,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => PremiumAvatar(
          name: user.username,
          size: size,
          borderColor: Colors.transparent,
        ),
      );
    }
    return PremiumAvatar(
      name: user.username,
      size: size,
      borderColor: Colors.transparent,
    );
  }
}

class _ProfileOverviewCard extends StatelessWidget {
  const _ProfileOverviewCard({
    required this.user,
    required this.editState,
    required this.onTapAvatar,
  });

  final UserModel user;
  final ProfileEditState editState;
  final VoidCallback onTapAvatar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.05),
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarHeader(
            user: user,
            editState: editState,
            onTap: onTapAvatar,
          ),
          SizedBox(height: 20.h),
          Text(
            user.username,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            l10n.settingsEditProfileDesc,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoActionTile extends StatelessWidget {
  const _PhotoActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: destructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.6),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Text(
                _displayLabel(context, label),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'Male':
        return l10n.genderMale;
      case 'Female':
        return l10n.genderFemale;
      case 'Other':
        return l10n.other;
      case 'Prefer not to say':
        return l10n.preferNotToSay;
      default:
        return value;
    }
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: PremiumButton(
          text: label,
          icon: Icons.check_rounded,
          onPressed: enabled ? onPressed : null,
          isLoading: isLoading,
          style: PremiumButtonStyle.gradient,
        ),
      ),
    );
  }
}
