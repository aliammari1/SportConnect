import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sport_connect/core/services/map_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/app_map_tile_layer.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

const LatLng _defaultMapCenter = LatLng(48.8566, 2.3522);

final LatLngBounds _franceMapBounds = LatLngBounds(
  const LatLng(41, -5.5),
  const LatLng(51.5, 10),
);

const double _minInlineMapZoom = 10.5;
const double _initialInlineMapZoom = 13;
const double _selectedInlineMapZoom = 15;
const double _maxInlineMapZoom = 18;

/// France-only address autocomplete input with inline expandable suggestions,
/// inline expandable map selection, current-location support, final draft
/// confirmation, and keyboard-aware scrolling.
///
/// Interaction model:
/// - compact trigger row
/// - expands in place, like the DOB picker
/// - user can search, use current location, or pick on map
/// - typing collapses the map and hides quick actions
/// - suggestions appear directly under the search box
/// - quick actions reappear after suggestion selection or search clear
/// - each path creates a draft address preview
/// - user confirms with "Use this address"
class AddressAutocompleteField extends ConsumerStatefulWidget {
  const AddressAutocompleteField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.initialLocation,
    this.onSelected,
    this.showMapPicker = true,
    this.accentColor,
    this.fillColor,
    this.enabled = true,
    this.validator,
  });

  final String? label;
  final String? hint;
  final String? initialValue;
  final LatLng? initialLocation;
  final ValueChanged<AddressResult>? onSelected;
  final bool showMapPicker;
  final Color? accentColor;
  final Color? fillColor;
  final bool enabled;
  final String? Function(String?)? validator;

  @override
  ConsumerState<AddressAutocompleteField> createState() =>
      AddressAutocompleteFieldState();
}

class AddressAutocompleteFieldState
    extends ConsumerState<AddressAutocompleteField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _searchFocusNode;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnimation;
  late final MapController _mapController;

  final GlobalKey _fieldKey = GlobalKey();

  Timer? _debounce;

  bool _expanded = false;
  bool _mapExpanded = false;
  bool _isSearching = false;
  bool _isReverseGeocoding = false;
  bool _isGettingCurrentLocation = false;
  bool _hasInteracted = false;

  String? _errorText;
  String? _searchError;

  LatLng? _selectedLocation;
  LatLng? _draftMapLocation;
  String? _draftMapAddress;
  AddressResult? _draftAddress;

  List<SearchResult> _suggestions = const [];

  String get text => _controller.text;
  LatLng? get location => _selectedLocation;

  void setText(String? value) {
    final nextText = value?.trim() ?? '';
    if (_controller.text == nextText) return;

    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _draftMapAddress = nextText.isEmpty ? null : nextText;
  }

  String? validate() {
    if (!mounted) return null;

    _hasInteracted = true;
    final error = widget.validator?.call(_controller.text);

    setState(() {
      _errorText = error;
    });

    return error;
  }

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue ?? '');
    _searchFocusNode = FocusNode();
    _mapController = MapController();

    _selectedLocation = _safeLatLngOrNull(widget.initialLocation);
    _draftMapLocation = _safeLatLngOrNull(widget.initialLocation);
    _draftMapAddress = widget.initialValue;

    if ((widget.initialValue ?? '').trim().isNotEmpty &&
        _draftMapLocation != null) {
      _draftAddress = AddressResult(
        address: _shortAddress(widget.initialValue!),
        fullAddress: widget.initialValue!,
        location: _draftMapLocation!,
      );
    }

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchFocusNode.dispose();
    _expandController.dispose();
    super.dispose();
  }

  bool _isFiniteLatLng(LatLng location) {
    return location.latitude.isFinite &&
        location.longitude.isFinite &&
        location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }

  bool _isLocationInFrance(LatLng location) {
    if (!_isFiniteLatLng(location)) return false;

    return location.latitude >= 41.0 &&
        location.latitude <= 51.5 &&
        location.longitude >= -5.5 &&
        location.longitude <= 10.0;
  }

  LatLng? _safeLatLngOrNull(LatLng? location) {
    if (location == null) return null;
    if (!_isFiniteLatLng(location)) return null;
    return location;
  }

  LatLng _safeLatLngOrDefault(LatLng? location) {
    if (location != null &&
        _isFiniteLatLng(location) &&
        _isLocationInFrance(location)) {
      return location;
    }

    return _defaultMapCenter;
  }

  void _ensureFieldVisible({
    Duration delay = const Duration(milliseconds: 320),
  }) {
    Future.delayed(delay, () {
      if (!mounted) return;

      final fieldContext = _fieldKey.currentContext;
      if (fieldContext == null) return;

      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  void _openPanel({bool focus = true}) {
    if (!widget.enabled) return;

    if (!_expanded) {
      setState(() => _expanded = true);
      _expandController.forward();
    }

    if (focus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _searchFocusNode.requestFocus();
        _ensureFieldVisible();
      });
    } else {
      _ensureFieldVisible(delay: const Duration(milliseconds: 120));
    }

    final query = _controller.text.trim();
    if (query.length >= 2 && _suggestions.isEmpty) {
      unawaited(_search(query));
    }
  }

  void _closePanel() {
    if (!_expanded) return;

    _searchFocusNode.unfocus();

    setState(() {
      _expanded = false;
      _mapExpanded = false;
    });

    _expandController.reverse();

    if (_hasInteracted && widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(_controller.text);
      });
    }
  }

  void _togglePanel() {
    unawaited(HapticFeedback.selectionClick());

    if (_expanded) {
      _closePanel();
    } else {
      _openPanel();
    }
  }

  void _onQueryChanged(String value) {
    _hasInteracted = true;
    _debounce?.cancel();

    final query = value.trim();
    final wasMapExpanded = _mapExpanded;

    setState(() {
      // Search mode is now active.
      // Collapse the map and hide quick actions so suggestions are visible.
      if (_mapExpanded) {
        _mapExpanded = false;
        _isReverseGeocoding = false;
      }

      _selectedLocation = null;
      _draftAddress = null;
      _draftMapLocation = null;
      _draftMapAddress = null;
      _searchError = null;

      if (_errorText != null && widget.validator != null) {
        _errorText = widget.validator!(_controller.text);
      }

      if (query.length < 2) {
        _isSearching = false;
        _suggestions = const [];
      }
    });

    if (wasMapExpanded) {
      _ensureFieldVisible(delay: const Duration(milliseconds: 180));
    } else {
      _ensureFieldVisible(delay: const Duration(milliseconds: 80));
    }

    if (query.length < 2) return;

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 360), () {
      unawaited(_search(query));
    });
  }

  Future<void> _search(String query) async {
    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await ref
          .read(mapServiceProvider)
          .searchPlaces(
            query,
            limit: 8,
          );

      if (!mounted) return;

      final filtered = results
          .where(
            (result) =>
                _isFranceResult(result) &&
                _isFiniteLatLng(result.location) &&
                _isLocationInFrance(result.location),
          )
          .take(5)
          .toList();

      setState(() {
        _suggestions = filtered;
        _isSearching = false;
      });

      _ensureFieldVisible(delay: const Duration(milliseconds: 80));
    } on Object catch (e, st) {
      TalkerService.warning('Address search failed: $e');
      TalkerService.error('Address search error', e, st);
      if (!mounted) return;

      setState(() {
        _suggestions = const [];
        _isSearching = false;
        _searchError = AppLocalizations.of(
          context,
        ).unable_to_search_addresses_try_again;
      });

      _ensureFieldVisible(delay: const Duration(milliseconds: 80));
    }
  }

  bool _isFranceResult(SearchResult result) {
    final display = result.displayName.toLowerCase();

    return display.contains('france') || display.endsWith(', fr');
  }

  Future<bool> _ensureLocationAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        AppLocalizations.of(context).locationServicesOffDescription,
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse) {
      return true;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse) {
        return true;
      }

      if (permission == LocationPermission.denied) {
        throw Exception(AppLocalizations.of(context).errorPermissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        AppLocalizations.of(context).locationPermissionBlockedDescription,
      );
    }

    return false;
  }

  Future<LatLng> _getCurrentLatLng() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 12),
      ),
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _useCurrentLocation() async {
    if (!widget.enabled || _isGettingCurrentLocation) return;

    unawaited(HapticFeedback.selectionClick());
    _searchFocusNode.unfocus();

    setState(() {
      _isGettingCurrentLocation = true;
      _searchError = null;
      _errorText = null;
    });

    try {
      final hasAccess = await _ensureLocationAccess();
      if (!hasAccess || !mounted) return;

      final location = await _getCurrentLatLng();
      if (!_isFiniteLatLng(location)) {
        setState(() {
          _errorText = AppLocalizations.of(
            context,
          ).unable_to_read_a_valid_current_location;
        });
        return;
      }

      if (!_isLocationInFrance(location)) {
        setState(() {
          _errorText = AppLocalizations.of(
            context,
          ).your_current_location_appears_to_be_outside_france;
        });
        return;
      }

      final result = await ref
          .read(mapServiceProvider)
          .reverseGeocode(location);

      if (!mounted) return;

      final fullAddress =
          result?.displayName ?? AppLocalizations.of(context).selectedLocation;
      final draft = AddressResult(
        address: _shortAddress(fullAddress),
        fullAddress: fullAddress,
        location: location,
      );

      setState(() {
        _draftAddress = draft;
        _draftMapLocation = location;
        _draftMapAddress = fullAddress;
        _suggestions = const [];
        _searchError = null;
      });

      if (_mapExpanded) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final safeLocation = _safeLatLngOrDefault(location);
          _mapController.move(safeLocation, _selectedInlineMapZoom);
        });
      }

      _ensureFieldVisible(delay: const Duration(milliseconds: 120));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _searchError = e.toString().replaceFirst('Exception: ', '');
      });

      _ensureFieldVisible(delay: const Duration(milliseconds: 120));
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  void _selectSuggestion(SearchResult result) {
    if (!_isFiniteLatLng(result.location) ||
        !_isLocationInFrance(result.location)) {
      setState(() {
        _errorText = AppLocalizations.of(
          context,
        ).invalid_address_location_please_choose_another_result;
        _searchError = null;
      });
      return;
    }

    final fullAddress = result.displayName;
    final shortAddress = _shortAddress(fullAddress);

    unawaited(HapticFeedback.selectionClick());
    _searchFocusNode.unfocus();

    setState(() {
      _mapExpanded = false;

      _draftAddress = AddressResult(
        address: shortAddress,
        fullAddress: fullAddress,
        location: result.location,
      );

      _draftMapLocation = result.location;
      _draftMapAddress = fullAddress;
      _searchError = null;
      _errorText = null;
    });

    _ensureFieldVisible(delay: const Duration(milliseconds: 260));
  }

  void _clearAddress() {
    unawaited(HapticFeedback.selectionClick());

    _debounce?.cancel();

    setState(() {
      _controller.clear();
      _selectedLocation = null;
      _draftMapLocation = null;
      _draftMapAddress = null;
      _draftAddress = null;
      _suggestions = const [];
      _searchError = null;
      _hasInteracted = true;

      if (widget.validator != null) {
        _errorText = widget.validator!(_controller.text);
      }
    });

    widget.onSelected?.call(const AddressResult.empty());

    _openPanel();
  }

  void _toggleMapExpansion() {
    if (!widget.enabled) return;

    unawaited(HapticFeedback.selectionClick());
    _searchFocusNode.unfocus();

    final nextValue = !_mapExpanded;
    final center = _safeLatLngOrDefault(_draftMapLocation ?? _selectedLocation);

    setState(() {
      _mapExpanded = nextValue;

      _draftMapLocation ??= center;
    });

    if (nextValue) {
      _ensureFieldVisible(delay: const Duration(milliseconds: 260));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _mapController.move(
          center,
          _selectedLocation == null
              ? _initialInlineMapZoom
              : _selectedInlineMapZoom,
        );
      });
    } else {
      _ensureFieldVisible(delay: const Duration(milliseconds: 120));
    }
  }

  Future<void> _selectMapPoint(LatLng location) async {
    unawaited(HapticFeedback.lightImpact());

    if (!_isFiniteLatLng(location)) {
      setState(() {
        _errorText = 'Invalid map position. Please choose another point.';
        _searchError = null;
      });
      return;
    }

    if (!_isLocationInFrance(location)) {
      setState(() {
        _errorText = 'Please select a location in France.';
        _searchError = null;
      });
      return;
    }

    setState(() {
      _draftMapLocation = location;
      _draftMapAddress = 'Selected location';
      _draftAddress = null;
      _isReverseGeocoding = true;
      _errorText = null;
      _searchError = null;
    });

    final result = await ref.read(mapServiceProvider).reverseGeocode(location);

    if (!mounted) return;

    final fullAddress = result?.displayName ?? 'Selected location';

    setState(() {
      _draftMapAddress = fullAddress;
      _draftAddress = AddressResult(
        address: _shortAddress(fullAddress),
        fullAddress: fullAddress,
        location: location,
      );
      _isReverseGeocoding = false;
    });

    _ensureFieldVisible(delay: const Duration(milliseconds: 120));
  }

  void _confirmDraftAddress() {
    final draft = _draftAddress;

    if (draft == null) {
      setState(() {
        _errorText = 'Please select an address.';
      });
      return;
    }

    if (!_isFiniteLatLng(draft.location) ||
        !_isLocationInFrance(draft.location)) {
      setState(() {
        _errorText = 'Invalid selected location. Please choose another point.';
      });
      return;
    }

    unawaited(HapticFeedback.mediumImpact());

    setState(() {
      _controller.text = draft.fullAddress;
      _selectedLocation = draft.location;
      _draftMapLocation = draft.location;
      _draftMapAddress = draft.fullAddress;
      _hasInteracted = true;
      _suggestions = const [];
      _searchError = null;

      if (widget.validator != null) {
        _errorText = widget.validator!(_controller.text);
      }
    });

    widget.onSelected?.call(draft);

    _closePanel();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? AppColors.primary;
    final cardBg = widget.fillColor ?? AppColors.surface;
    final hasError = _errorText != null;
    final hasValue = _controller.text.trim().isNotEmpty;
    final hasSelectedLocation =
        _selectedLocation != null && hasValue && !hasError;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final query = _controller.text.trim();
    final isSearchMode =
        query.length >= 2 && _draftAddress == null && !_mapExpanded;
    final showQuickActions = !isSearchMode;

    final mapCenter = _safeLatLngOrDefault(
      _draftMapLocation ?? _selectedLocation,
    );

    return Column(
      key: _fieldKey,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: hasError ? AppColors.error : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: hasSelectedLocation
                    ? _SmallStatusPill(
                        key: const ValueKey('selected-address'),
                        accent: accent,
                        text: AppLocalizations.of(context).selected,
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('no-selected-address'),
                      ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
        Semantics(
          button: true,
          label: widget.label ?? AppLocalizations.of(context).address,
          hint: hasValue
              ? AppLocalizations.of(context).selected_address
              : AppLocalizations.of(context).searchAddressCityOrPlace,
          child: GestureDetector(
            onTap: _togglePanel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.055)
                    : accent.withValues(alpha: 0.06),
                borderRadius: _expanded
                    ? BorderRadius.vertical(top: Radius.circular(14.r))
                    : BorderRadius.circular(14.r),
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : _expanded || hasSelectedLocation
                      ? accent
                      : accent.withValues(alpha: 0.2),
                  width: _expanded || hasError ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasSelectedLocation
                        ? Icons.location_on_rounded
                        : Icons.search_rounded,
                    color: hasError ? AppColors.error : accent,
                    size: 21.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.label != null)
                          Text(
                            hasSelectedLocation
                                ? AppLocalizations.of(context).addressSelected
                                : AppLocalizations.of(context).address,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: hasError
                                  ? AppColors.error
                                  : accent.withValues(alpha: 0.75),
                            ),
                          ),
                        if (widget.label != null) SizedBox(height: 2.h),
                        Text(
                          hasValue
                              ? _shortAddress(_controller.text)
                              : widget.hint ??
                                    AppLocalizations.of(
                                      context,
                                    ).searchAddressCityOrPlace,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: hasValue
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withValues(alpha: 0.38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasValue && !_expanded)
                    IconButton(
                      tooltip: AppLocalizations.of(context).clearAddress,
                      onPressed: widget.enabled ? _clearAddress : null,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 36.w,
                        minHeight: 36.h,
                      ),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 18.sp,
                      ),
                    )
                  else
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: hasError ? AppColors.error : accent,
                        size: 24.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(14.r),
              ),
              border: Border(
                left: BorderSide(
                  color: hasError ? AppColors.error : accent,
                  width: 2,
                ),
                right: BorderSide(
                  color: hasError ? AppColors.error : accent,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: hasError ? AppColors.error : accent,
                  width: 2,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _InlineSearchBox(
                    controller: _controller,
                    focusNode: _searchFocusNode,
                    hint:
                        widget.hint ??
                        AppLocalizations.of(context).searchAddressCityOrPlace,
                    accent: accent,
                    enabled: widget.enabled,
                    isLoading: _isSearching,
                    onChanged: _onQueryChanged,
                    onClear: _controller.text.trim().isEmpty
                        ? null
                        : _clearAddress,
                  ),
                  if (!_mapExpanded &&
                      _draftAddress == null &&
                      (query.length >= 2 ||
                          _isSearching ||
                          _searchError != null)) ...[
                    SizedBox(height: 12.h),
                    _SuggestionArea(
                      query: query,
                      suggestions: _suggestions,
                      isSearching: _isSearching,
                      searchError: _searchError,
                      accent: accent,
                      keyboardOpen: keyboardOpen,
                      onSelect: _selectSuggestion,
                    ),
                  ],
                  if (_draftAddress != null) ...[
                    SizedBox(height: 12.h),
                    _SelectedAddressPreview(
                      address: _draftAddress!,
                      accent: accent,
                      onConfirm: _confirmDraftAddress,
                    ),
                  ],
                  if (showQuickActions) ...[
                    SizedBox(height: 10.h),
                    _InlineCurrentLocationOption(
                      accent: accent,
                      isLoading: _isGettingCurrentLocation,
                      onTap: _useCurrentLocation,
                    ),
                    if (widget.showMapPicker) ...[
                      SizedBox(height: 10.h),
                      _InlineMapToggle(
                        accent: accent,
                        expanded: _mapExpanded,
                        onTap: _toggleMapExpansion,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _mapExpanded
                            ? Padding(
                                padding: EdgeInsets.only(top: 10.h),
                                child: _InlineMapExpansion(
                                  mapController: _mapController,
                                  accent: accent,
                                  center: mapCenter,
                                  selectedLocation: _safeLatLngOrNull(
                                    _draftMapLocation,
                                  ),
                                  selectedAddress: _draftMapAddress,
                                  isReverseGeocoding: _isReverseGeocoding,
                                  bounds: _franceMapBounds,
                                  minZoom: _minInlineMapZoom,
                                  initialZoom: _initialInlineMapZoom,
                                  maxZoom: _maxInlineMapZoom,
                                  onTap: _selectMapPoint,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ],
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: _closePanel,
                    style: TextButton.styleFrom(
                      minimumSize: Size(double.infinity, 44.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      _draftAddress == null
                          ? AppLocalizations.of(context).actionCancel
                          : AppLocalizations.of(context).notNow,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: hasError
              ? Padding(
                  key: ValueKey(_errorText),
                  padding: EdgeInsets.only(top: 7.h, left: 2.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 13.sp,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 160.ms).slideY(begin: -0.15)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _InlineSearchBox extends StatefulWidget {
  const _InlineSearchBox({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.accent,
    required this.enabled,
    required this.isLoading,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final Color accent;
  final bool enabled;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  State<_InlineSearchBox> createState() => _InlineSearchBoxState();
}

class _InlineSearchBoxState extends State<_InlineSearchBox> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _InlineSearchBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.accent.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 13.w),
          Icon(
            Icons.search_rounded,
            color: widget.accent,
            size: 20.sp,
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.isLoading) ...[
            SizedBox(width: 8.w),
            SizedBox(
              width: 17.w,
              height: 17.w,
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
              ),
            ),
            SizedBox(width: 13.w),
          ] else if (hasText && widget.onClear != null) ...[
            IconButton(
              tooltip: AppLocalizations.of(context).clearAddress,
              onPressed: widget.onClear,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 40.w,
                minHeight: 40.h,
              ),
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 18.sp,
              ),
            ),
          ] else ...[
            SizedBox(width: 12.w),
          ],
        ],
      ),
    );
  }
}

class _InlineCurrentLocationOption extends StatelessWidget {
  const _InlineCurrentLocationOption({
    required this.accent,
    required this.isLoading,
    required this.onTap,
  });

  final Color accent;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(12.r),
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.065),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: accent.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: isLoading
                  ? Padding(
                      padding: EdgeInsets.all(8.w),
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    )
                  : Icon(
                      Icons.my_location_rounded,
                      color: accent,
                      size: 18.sp,
                    ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading
                        ? 'Getting your location...'
                        : 'Use current location',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Fastest way to set your pickup point',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.arrow_forward_rounded,
                color: accent,
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineMapToggle extends StatelessWidget {
  const _InlineMapToggle({
    required this.accent,
    required this.expanded,
    required this.onTap,
  });

  final Color accent;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: expanded ? accent : accent.withValues(alpha: 0.18),
            width: expanded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: expanded ? accent : accent.withOpacity(0.13),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.map_rounded,
                color: expanded ? Colors.white : accent,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).pickOnMap,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Expand map for exact pickup point',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: accent,
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMapExpansion extends StatelessWidget {
  const _InlineMapExpansion({
    required this.mapController,
    required this.accent,
    required this.center,
    required this.selectedLocation,
    required this.selectedAddress,
    required this.isReverseGeocoding,
    required this.bounds,
    required this.minZoom,
    required this.initialZoom,
    required this.maxZoom,
    required this.onTap,
  });

  final MapController mapController;
  final Color accent;
  final LatLng center;
  final LatLng? selectedLocation;
  final String? selectedAddress;
  final bool isReverseGeocoding;
  final LatLngBounds bounds;
  final double minZoom;
  final double initialZoom;
  final double maxZoom;
  final ValueChanged<LatLng> onTap;

  bool _isFiniteLatLng(LatLng location) {
    return location.latitude.isFinite &&
        location.longitude.isFinite &&
        location.latitude >= -90 &&
        location.latitude <= 90 &&
        location.longitude >= -180 &&
        location.longitude <= 180;
  }

  @override
  Widget build(BuildContext context) {
    final selected =
        selectedLocation != null && _isFiniteLatLng(selectedLocation!)
        ? selectedLocation
        : null;

    final safeCenter = _isFiniteLatLng(center) ? center : _defaultMapCenter;

    return Container(
      decoration: BoxDecoration(
        color: accent.withOpacity(0.045),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: accent.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(13.r),
            ),
            child: SizedBox(
              height: 210.h,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: safeCenter,
                      initialZoom: initialZoom,
                      minZoom: minZoom,
                      maxZoom: maxZoom,
                      cameraConstraint: CameraConstraint.containCenter(
                        bounds: bounds,
                      ),
                      interactionOptions: const InteractionOptions(
                        flags:
                            InteractiveFlag.drag |
                            InteractiveFlag.flingAnimation |
                            InteractiveFlag.pinchZoom |
                            InteractiveFlag.doubleTapZoom,
                      ),
                      onTap: (_, point) {
                        if (!_isFiniteLatLng(point)) return;
                        onTap(point);
                      },
                    ),
                    children: [
                      const AppMapTileLayer(),
                      if (selected != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: selected,
                              width: 54.w,
                              height: 54.w,
                              child: _MapMarker(accent: accent),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Positioned(
                    left: 12.w,
                    right: 12.w,
                    top: 12.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 9.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.94),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 17.sp,
                            color: accent,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Tap the map to set the exact point',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.location_on_rounded,
                    color: accent,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isReverseGeocoding
                        ? Row(
                            key: const ValueKey('reverse-loading'),
                            children: [
                              SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accent,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                AppLocalizations.of(context).finding_address,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: ValueKey(selectedAddress),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selected == null
                                    ? AppLocalizations.of(
                                        context,
                                      ).noPointSelected
                                    : _shortAddress(
                                        selectedAddress ??
                                            AppLocalizations.of(
                                              context,
                                            ).selected_location,
                                      ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                selected == null
                                    ? AppLocalizations.of(
                                        context,
                                      ).tapMapToChoosePoint
                                    : AppLocalizations.of(
                                        context,
                                      ).locationPreviewReady,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: accent,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3.w,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.35),
              blurRadius: 18,
              offset: Offset(0, 8.h),
            ),
          ],
        ),
        child: Icon(
          Icons.location_on_rounded,
          color: Colors.white,
          size: 23.sp,
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.76, 0.76),
      duration: 220.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _SuggestionArea extends StatelessWidget {
  const _SuggestionArea({
    required this.query,
    required this.suggestions,
    required this.isSearching,
    required this.searchError,
    required this.accent,
    required this.keyboardOpen,
    required this.onSelect,
  });

  final String query;
  final List<SearchResult> suggestions;
  final bool isSearching;
  final String? searchError;
  final Color accent;
  final bool keyboardOpen;
  final ValueChanged<SearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (query.length < 2) {
      return const SizedBox.shrink(
        key: ValueKey('idle'),
      );
    }

    if (searchError != null) {
      return _PanelHint(
        key: const ValueKey('search-error'),
        icon: Icons.wifi_off_rounded,
        title: l10n.search_unavailable,
        message: searchError!,
        accent: accent,
      );
    }

    if (isSearching && suggestions.isEmpty) {
      return ConstrainedBox(
        key: const ValueKey('loading'),
        constraints: BoxConstraints(
          maxHeight: keyboardOpen ? 185.h : 320.h,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8.h),
                child: const _SuggestionSkeleton(),
              ),
            ),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return _PanelHint(
        key: const ValueKey('empty'),
        icon: Icons.search_off_rounded,
        title: l10n.no_address_found,
        message: l10n.try_another_street_or_choose_the_exact_point_on_map,
        accent: accent,
      );
    }

    return ConstrainedBox(
      key: const ValueKey('suggestions'),
      constraints: BoxConstraints(
        maxHeight: keyboardOpen ? 185.h : 320.h,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
              child: Text(
                l10n.suggestions.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.25,
                  color: accent.withOpacity(0.58),
                ),
              ),
            ),
            ...List.generate(suggestions.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == suggestions.length - 1 ? 0 : 8.h,
                ),
                child: _SuggestionTile(
                  result: suggestions[index],
                  accent: accent,
                  onTap: () => onSelect(suggestions[index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.result,
    required this.accent,
    required this.onTap,
  });

  final SearchResult result;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final parts = result.displayName
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    final primary = parts.isEmpty ? result.displayName.trim() : parts.first;
    final secondary = parts.skip(1).join(', ').trim();

    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.045),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: accent.withOpacity(0.12),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.11),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.place_rounded,
                color: accent,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (secondary.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      secondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAddressPreview extends StatelessWidget {
  const _SelectedAddressPreview({
    required this.address,
    required this.accent,
    required this.onConfirm,
  });

  final AddressResult address;
  final Color accent;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.075),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: accent.withOpacity(0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).selected_address,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address.fullAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
              icon: Icon(
                Icons.check_rounded,
                size: 18.sp,
              ),
              label: Text(
                AppLocalizations.of(context).use_this_address,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHint extends StatelessWidget {
  const _PanelHint({
    required this.icon,
    required this.title,
    required this.message,
    required this.accent,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.045),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: accent.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: accent,
            size: 21.sp,
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionSkeleton extends StatelessWidget {
  const _SuggestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.045),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 9.h,
                      width: 160.w,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .fade(begin: 0.55, end: 1, duration: 850.ms);
  }
}

class _SmallStatusPill extends StatelessWidget {
  const _SmallStatusPill({
    required this.accent,
    required this.text,
    super.key,
  });

  final Color accent;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: 12.sp,
            color: accent,
          ),
          SizedBox(width: 3.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

String _shortAddress(String value) {
  final parts = value
      .split(',')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return value.trim();

  return parts.first;
}

/// Result from address autocomplete selection.
class AddressResult {
  const AddressResult({
    required this.address,
    required this.fullAddress,
    required this.location,
  });

  const AddressResult.empty()
    : address = '',
      fullAddress = '',
      location = const LatLng(0, 0);

  final String address;
  final String fullAddress;
  final LatLng location;
}
