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
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/core/widgets/permission_dialog_helper.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/vehicles/models/vehicle_model.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_management_view_model.dart';
import 'package:sport_connect/features/vehicles/view_models/vehicle_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class VehicleManagementScreen extends ConsumerWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(vehicleViewModelProvider);

    ref.listen(vehicleViewModelProvider, (prev, next) {
      if (next.actionType == null || next.actionType == prev?.actionType) {
        return;
      }
      final message = next.actionMessage;
      if (message != null) {
        AdaptiveSnackBar.show(
          context,
          message: message,
          type: AdaptiveSnackBarType.success,
        );
      }
      ref.read(vehicleViewModelProvider.notifier).clearAction();
    });

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          onPressed: () => context.pop(),
          icon: Icon(Icons.adaptive.arrow_back_rounded),
        ),
        title: l10n.myVehicles,
      ),
      body: state.userId == null
          ? _SignInRequiredView()
          : state.vehicles.when(
              loading: () => const SkeletonLoader(
                type: SkeletonType.compactTile,
                itemCount: 3,
              ),
              error: (e, _) => _ErrorView(error: e),
              data: (vehicles) => _VehicleListView(
                vehicles: vehicles,
                userId: state.userId!,
              ),
            ),
    );
  }
}

// ─── Main list view ──────────────────────────────────────────────────────────

class _VehicleListView extends ConsumerWidget {
  const _VehicleListView({required this.vehicles, required this.userId});

  final List<VehicleModel> vehicles;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (vehicles.isEmpty) {
      return _EmptyState(onAdd: () => _openAddSheet(context, ref));
    }

    final sorted = [...vehicles]
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return b.totalRides.compareTo(a.totalRides);
      });
    final active = sorted.firstWhere(
      (v) => v.isActive,
      orElse: () => sorted.first,
    );

    return Stack(
      children: [
        MaxWidthContainer(
          maxWidth: context.isTablet ? kMaxWidthWide : kMaxWidthContent,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: adaptiveScreenPadding(context).copyWith(bottom: 120.h),
            itemCount: 3 + (context.isTablet ? 1 : sorted.length),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return _StatsHero(
                    total: sorted.length,
                    activeName: active.isActive ? active.displayName : null,
                  ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.05, end: 0);
                case 1:
                  return _AddVehicleBanner(onTap: () => _openAddSheet(context, ref))
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 320.ms)
                      .slideY(begin: 0.05, end: 0);
                case 2:
                  return SizedBox(height: 20.h);
                default:
                  final vehicleIndex = index - 3;
                  if (context.isTablet) {
                    // Tablet uses a single GridView item
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sorted.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.isExpandedOrLarger ? 3 : 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        childAspectRatio: context.isExpandedOrLarger ? 1.18 : 0.96,
                      ),
                      itemBuilder: (context, vi) {
                        final vehicle = sorted[vi];
                        return _VehicleCard(
                              vehicle: vehicle,
                              onSetActive: vehicle.isActive
                                  ? null
                                  : () => ref
                                        .read(vehicleViewModelProvider.notifier)
                                        .setActiveVehicle(vehicle.id),
                              onEdit: () => _openEditSheet(context, ref, vehicle),
                              onDelete: () => _confirmDelete(context, ref, vehicle),
                              onTap: () => _openDetailsSheet(context, ref, vehicle),
                            )
                            .animate(
                              delay: Duration(milliseconds: 120 + vi * 60),
                            )
                            .fadeIn(duration: 320.ms)
                            .slideY(begin: 0.06, end: 0);
                      },
                    );
                  }
                  final v = sorted[vehicleIndex];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _VehicleCard(
                          vehicle: v,
                          onSetActive: v.isActive
                              ? null
                              : () => ref
                                    .read(vehicleViewModelProvider.notifier)
                                    .setActiveVehicle(v.id),
                          onEdit: () => _openEditSheet(context, ref, v),
                          onDelete: () => _confirmDelete(context, ref, v),
                          onTap: () => _openDetailsSheet(context, ref, v),
                        )
                        .animate(
                          delay: Duration(milliseconds: 120 + vehicleIndex * 80),
                        )
                        .fadeIn(duration: 320.ms)
                        .slideY(begin: 0.06, end: 0),
                  );
              }
            },
          ),
        ),
        if (!context.isTablet)
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 24.h,
            child: SafeArea(
              top: false,
              child: _FloatingAddButton(
                onPressed: () => _openAddSheet(context, ref),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),
            ),
          ),
      ],
    );
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      AppModalSheet.show<void>(
        context: context,
        title: l10n.addVehicle,
        forceMaxHeight: true,
        maxHeightFactor: 0.92,
        child: _VehicleFormSheet(
          onSave: (vehicle) async {
            final ok = await ref
                .read(vehicleViewModelProvider.notifier)
                .createVehicle(vehicle.copyWith(ownerId: userId));
            if (ok && context.mounted) context.pop();
          },
        ),
      ),
    );
  }

  void _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
  ) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      AppModalSheet.show<void>(
        context: context,
        title: l10n.editVehicle,
        forceMaxHeight: true,
        maxHeightFactor: 0.92,
        child: _VehicleFormSheet(
          vehicle: vehicle,
          onSave: (updated) async {
            final ok = await ref
                .read(vehicleViewModelProvider.notifier)
                .updateVehicle(updated);
            if (ok && context.mounted) context.pop();
          },
        ),
      ),
    );
  }

  void _openDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
  ) {
    unawaited(
      AppModalSheet.show<void>(
        context: context,
        title: vehicle.displayName,
        maxHeightFactor: 0.85,
        child: _VehicleDetailsSheet(
          vehicle: vehicle,
          onEdit: () {
            context.pop();
            _openEditSheet(context, ref, vehicle);
          },
          onDelete: () {
            context.pop();
            _confirmDelete(context, ref, vehicle);
          },
          onSetActive: vehicle.isActive
              ? null
              : () {
                  context.pop();
                  unawaited(
                    ref
                        .read(vehicleViewModelProvider.notifier)
                        .setActiveVehicle(vehicle.id),
                  );
                },
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VehicleModel vehicle,
  ) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      showAdaptiveDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog.adaptive(
          title: Text(l10n.deleteVehicle),
          content: Text(l10n.areYouSureYouWant4(vehicle.displayName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                unawaited(
                  ref
                      .read(vehicleViewModelProvider.notifier)
                      .deleteVehicle(vehicle.id),
                );
              },
              child: Text(
                l10n.actionDelete,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero stats card ─────────────────────────────────────────────────────────

class _StatsHero extends StatelessWidget {
  const _StatsHero({
    required this.total,
    required this.activeName,
  });

  final int total;
  final String? activeName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.yourFleet,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      activeName ?? l10n.noActiveVehicle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  value: '$total',
                  label: total == 1 ? l10n.vehicle : l10n.vehicles,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: AppColors.divider,
              ),
              Expanded(
                child: _HeroStat(
                  value: activeName == null ? '—' : '1',
                  label: l10n.active,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

String _vehicleValidationMessage(AppLocalizations l10n, String raw) {
  switch (raw) {
    case 'Invalid year':
      return l10n.invalid_year;
    case 'Vehicle too old':
      return l10n.vehicle_is_too_old;
    case 'License plate too short':
      return l10n.license_plate_is_too_short;
    case 'License plate too long':
      return l10n.license_plate_is_too_long;
    case 'Invalid characters':
      return l10n.invalid_license_plate_format;
    default:
      return raw;
  }
}

// ─── Inline add CTA banner ───────────────────────────────────────────────────

class _AddVehicleBanner extends StatelessWidget {
  const _AddVehicleBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).addVehicle,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    AppLocalizations.of(
                      context,
                    ).register_a_new_car_for_carpool_rides,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vehicle card ────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  final VehicleModel vehicle;
  final VoidCallback? onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isActive = vehicle.isActive;

    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border.withValues(alpha: 0.5),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroImageStrip(vehicle: vehicle),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            _PlateChip(plate: vehicle.licensePlate),
                          ],
                        ),
                      ),
                      _CardActionsMenu(
                        isActive: isActive,
                        onSetActive: onSetActive,
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _MetaPill(
                        icon: Icons.airline_seat_recline_normal_rounded,
                        label: '${vehicle.capacity} ${l10n.seats}',
                        color: AppColors.primary,
                      ),
                      if (vehicle.totalRides > 0)
                        _MetaPill(
                          icon: Icons.route_rounded,
                          label: '${vehicle.totalRides} rides',
                          color: AppColors.warning,
                        ),
                      if (vehicle.averageRating > 0)
                        _MetaPill(
                          icon: Icons.star_rounded,
                          label: vehicle.averageRating.toStringAsFixed(1),
                          color: AppColors.starFilled,
                        ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Container(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      if (isActive)
                        _ActiveBadge()
                      else if (onSetActive != null)
                        _SetActiveButton(onPressed: onSetActive!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroImageStrip extends StatelessWidget {
  const _HeroImageStrip({required this.vehicle});
  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final hasImage = vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Container(
        height: 112.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasImage ? null : AppColors.primarySurface,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              CachedNetworkImage(
                imageUrl: vehicle.imageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                errorWidget: (_, _, _) => _carIconBackground(),
                placeholder: (_, _) => _carIconBackground(),
              )
            else
              _carIconBackground(),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.18),
                    ],
                  ),
                ),
              ),
            ),
            if (vehicle.isActive)
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        AppLocalizations.of(context).active.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _carIconBackground() {
    return Center(
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 64.sp,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}

class _CardActionsMenu extends StatelessWidget {
  const _CardActionsMenu({
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isActive;
  final VoidCallback? onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptivePopupMenuButton.icon<String>(
      icon: Icons.more_vert_rounded,
      items: [
        if (!isActive && onSetActive != null)
          AdaptivePopupMenuItem<String>(
            label: l10n.setActive,
            icon: Icons.check_circle_outline_rounded,
            value: 'active',
          ),
        AdaptivePopupMenuItem<String>(
          label: l10n.editVehicle,
          icon: Icons.edit_outlined,
          value: 'edit',
        ),
        AdaptivePopupMenuItem<String>(
          label: l10n.deleteVehicle,
          icon: Icons.delete_outline_rounded,
          value: 'delete',
        ),
      ],
      onSelected: (_, entry) {
        switch (entry.value) {
          case 'active':
            onSetActive?.call();
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
    );
  }
}

class _PlateChip extends StatelessWidget {
  const _PlateChip({required this.plate});
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        plate.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 1.1,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Colors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            AppLocalizations.of(context).in_use,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SetActiveButton extends StatelessWidget {
  const _SetActiveButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        unawaited(HapticFeedback.lightImpact());
        onPressed();
      },
      icon: Icon(Icons.check_circle_outline_rounded, size: 16.sp),
      label: Text(
        AppLocalizations.of(context).setActive,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ─── Floating add button ─────────────────────────────────────────────────────

class _FloatingAddButton extends StatelessWidget {
  const _FloatingAddButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        unawaited(HapticFeedback.lightImpact());
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              AppLocalizations.of(context).addVehicle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                size: 44.sp,
                color: AppColors.primary,
              ),
            ).animate().scale(
              duration: 420.ms,
              curve: Curves.easeOutBack,
              begin: const Offset(0.6, 0.6),
              end: const Offset(1, 1),
            ),
            SizedBox(height: 28.h),
            Text(
              l10n.noVehiclesAdded,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.addYourFirstVehicleTo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            SizedBox(height: 32.h),
            PremiumButton(
              text: l10n.addVehicle,
              icon: Icons.add_rounded,
              onPressed: onAdd,
              style: PremiumButtonStyle.gradient,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInRequiredView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 64.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).pleaseSignInToManage,
            style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context).errorValue(error),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add / Edit form sheet ───────────────────────────────────────────────────

class _VehicleFormSheet extends ConsumerStatefulWidget {
  const _VehicleFormSheet({required this.onSave, this.vehicle});

  final VehicleModel? vehicle;
  final Future<void> Function(VehicleModel) onSave;

  @override
  ConsumerState<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<_VehicleFormSheet> {
  late final FormGroup _form;

  String get _key => widget.vehicle?.id ?? '__new_vehicle__';

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _form = FormGroup({
      'make': FormControl<String>(
        value: v?.make ?? '',
        validators: [Validators.required, Validators.minLength(2)],
      ),
      'model': FormControl<String>(
        value: v?.model ?? '',
        validators: [Validators.required, Validators.minLength(1)],
      ),
      'year': FormControl<String>(
        value: v?.year.toString() ?? '',
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = (control.value as String?)?.trim();
            if (value == null || value.isEmpty) return null;
            final year = int.tryParse(value);
            if (year == null) return {'vehicleYear': 'Invalid year'};
            if (year < 1980) return {'vehicleYear': 'Vehicle too old'};
            if (year > DateTime.now().year + 1) {
              return {'vehicleYear': 'Invalid year'};
            }
            return null;
          }),
        ],
      ),
      'color': FormControl<String>(
        value: v?.color ?? '',
        validators: [Validators.required],
      ),
      'license_plate': FormControl<String>(
        value: v?.licensePlate ?? '',
        validators: [
          Validators.required,
          Validators.delegate((control) {
            final value = (control.value as String?)?.trim().toUpperCase();
            if (value == null || value.isEmpty) return null;
            if (value.length < 2) {
              return {'licensePlate': 'License plate too short'};
            }
            if (value.length > 12) {
              return {'licensePlate': 'License plate too long'};
            }
            if (!RegExp(r'^[A-Z0-9\-\s]+$').hasMatch(value)) {
              return {'licensePlate': 'Invalid characters'};
            }
            return null;
          }),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(addVehicleSheetUiViewModelProvider(_key).notifier)
          .init(widget.vehicle);
    });
  }

  Future<void> _pickImage() async {
    final accepted = await PermissionDialogHelper.showCameraRationale(
      context,
      customMessage: AppLocalizations.of(context).uploadVehiclePhotoPermission,
    );
    if (!accepted || !mounted) return;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ref
          .read(addVehicleSheetUiViewModelProvider(_key).notifier)
          .setImageFile(File(image.path));
    }
  }

  Future<void> _save() async {
    _form.markAllAsTouched();
    if (!_form.valid) return;

    final notifier = ref.read(
      addVehicleSheetUiViewModelProvider(_key).notifier,
    );
    final ui = ref.read(addVehicleSheetUiViewModelProvider(_key));
    notifier.setLoading(true);

    final values = _form.value;
    final vehicle = VehicleModel(
      id: widget.vehicle?.id ?? '',
      ownerId: widget.vehicle?.ownerId ?? '',
      make: (values['make']! as String).trim(),
      model: (values['model']! as String).trim(),
      year: int.parse((values['year']! as String).trim()),
      color: (values['color']! as String).trim(),
      licensePlate: (values['license_plate']! as String).trim().toUpperCase(),
      capacity: ui.capacity,
      imageUrl: widget.vehicle?.imageUrl,
      isActive: widget.vehicle?.isActive ?? false,
    );

    unawaited(HapticFeedback.mediumImpact());
    await widget.onSave(vehicle);
    if (mounted) notifier.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.vehicle != null;
    final ui = ref.watch(addVehicleSheetUiViewModelProvider(_key));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: ReactiveForm(
              formGroup: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImagePickerHero(
                    imageFile: ui.imageFile,
                    existingUrl: widget.vehicle?.imageUrl,
                    onTap: _pickImage,
                  ),
                  SizedBox(height: 20.h),

                  _FormSectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: l10n.vehicle_details,
                  ),
                  SizedBox(height: 12.h),
                  _FormCard(
                    children: [
                      _formField(
                        name: 'make',
                        label: l10n.make,
                        hint: l10n.vehicleMakeHint,
                        icon: Icons.business_rounded,
                      ),
                      SizedBox(height: 14.h),
                      _formField(
                        name: 'model',
                        label: l10n.model,
                        hint: l10n.vehicleModelHint,
                        icon: Icons.directions_car_rounded,
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _formField(
                              name: 'year',
                              label: l10n.year,
                              hint: l10n.vehicleYearHint,
                              icon: Icons.calendar_today_rounded,
                              keyboardType: TextInputType.number,
                              validationMessages: {
                                ValidationMessage.required: (_) =>
                                    l10n.pleaseEnterValue(l10n.year),
                                'vehicleYear': (e) => _vehicleValidationMessage(
                                  l10n,
                                  e as String,
                                ),
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _formField(
                              name: 'color',
                              label: l10n.color,
                              hint: l10n.vehicleColorHint,
                              icon: Icons.palette_rounded,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _formField(
                        name: 'license_plate',
                        label: l10n.licensePlate,
                        hint: l10n.licensePlateHint,
                        icon: Icons.confirmation_number_rounded,
                        textCapitalization: TextCapitalization.characters,
                        validationMessages: {
                          ValidationMessage.required: (_) =>
                              l10n.pleaseEnterValue(l10n.licensePlate),
                          'licensePlate': (e) =>
                              _vehicleValidationMessage(l10n, e as String),
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  _FormSectionHeader(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    title: l10n.passengerCapacity,
                  ),
                  SizedBox(height: 12.h),
                  _CapacitySelector(
                    selected: ui.capacity,
                    onChanged: (v) => ref
                        .read(addVehicleSheetUiViewModelProvider(_key).notifier)
                        .setCapacity(v),
                  ),

                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 14.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: PremiumButton(
              text: isEditing ? l10n.saveChanges : l10n.addVehicle,
              icon: isEditing ? Icons.check_rounded : Icons.add_rounded,
              isLoading: ui.isLoading,
              onPressed: ui.isLoading ? null : _save,
              style: PremiumButtonStyle.gradient,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required String name,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Map<String, String Function(Object)>? validationMessages,
  }) {
    return AdaptiveReactiveTextField(
      formControlName: name,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20.sp),
      validationMessages:
          validationMessages ??
          {
            ValidationMessage.required: (_) =>
                AppLocalizations.of(context).pleaseEnterValue(label),
          },
    );
  }
}

class _ImagePickerHero extends StatelessWidget {
  const _ImagePickerHero({
    required this.imageFile,
    required this.existingUrl,
    required this.onTap,
  });

  final File? imageFile;
  final String? existingUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = imageFile != null;
    final hasExisting =
        !hasFile && existingUrl != null && existingUrl!.isNotEmpty;
    final hasImage = hasFile || hasExisting;

    return AdaptiveTapSurface(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        height: 132.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasFile)
                Image.file(imageFile!, fit: BoxFit.cover)
              else if (hasExisting)
                CachedNetworkImage(
                  imageUrl: existingUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => _placeholder(context),
                  placeholder: (_, _) => _placeholder(context),
                )
              else
                _placeholder(context),
              if (hasImage)
                Positioned(
                  right: 12.w,
                  bottom: 12.h,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: const BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              size: 26.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            AppLocalizations.of(context).addPhoto,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            l10n.riders_see_this_photo_before_booking,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSectionHeader extends StatelessWidget {
  const _FormSectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _CapacitySelector extends StatelessWidget {
  const _CapacitySelector({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final seats = i + 1;
        final isSelected = seats == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 6 ? 6.w : 0),
            child: GestureDetector(
              onTap: () {
                unawaited(HapticFeedback.selectionClick());
                onChanged(seats);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$seats',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Details sheet ───────────────────────────────────────────────────────────

class _VehicleDetailsSheet extends StatelessWidget {
  const _VehicleDetailsSheet({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
    required this.onSetActive,
  });

  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailsHero(vehicle: vehicle),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Expanded(
                      child: _DetailMetric(
                        icon: Icons.airline_seat_recline_normal_rounded,
                        label: l10n.capacity,
                        value: '${vehicle.capacity}',
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _DetailMetric(
                        icon: Icons.route_rounded,
                        label: l10n.totalRides,
                        value: '${vehicle.totalRides}',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _FormCard(
                  children: [
                    _DetailRow(label: l10n.color, value: vehicle.color),
                    _Separator(),
                    _DetailRow(label: l10n.year, value: '${vehicle.year}'),
                    _Separator(),
                    _DetailRow(
                      label: l10n.licensePlate,
                      value: vehicle.licensePlate.toUpperCase(),
                    ),
                    if (vehicle.averageRating > 0) ...[
                      _Separator(),
                      _DetailRow(
                        label: l10n.rating,
                        value: vehicle.averageRating.toStringAsFixed(1),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                if (onSetActive != null) ...[
                  PremiumButton(
                    text: l10n.setActive,
                    icon: Icons.bolt_rounded,
                    onPressed: onSetActive,
                    style: PremiumButtonStyle.gradient,
                  ),
                  SizedBox(height: 10.h),
                ],
                Row(
                  children: [
                    Expanded(
                      child: PremiumButton(
                        text: l10n.editVehicle,
                        icon: Icons.edit_outlined,
                        onPressed: onEdit,
                        style: PremiumButtonStyle.outline,
                        size: ButtonSize.medium,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: PremiumButton(
                        text: l10n.actionDelete,
                        icon: Icons.delete_outline_rounded,
                        onPressed: onDelete,
                        style: PremiumButtonStyle.danger,
                        size: ButtonSize.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({required this.vehicle});
  final VehicleModel vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: [
          Container(
            height: 130.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: vehicle.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(),
                      placeholder: (_, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            vehicle.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              vehicle.licensePlate.toUpperCase(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            alignment: WrapAlignment.center,
            children: [
              _heroChip(
                vehicle.isActive
                    ? AppLocalizations.of(context).active
                    : AppLocalizations.of(context).inactive,
                vehicle.isActive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 64.sp,
        color: AppColors.primary,
      ),
    );
  }

  Widget _heroChip(String label, bool emphasized) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: emphasized ? AppColors.primary : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: emphasized ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}
