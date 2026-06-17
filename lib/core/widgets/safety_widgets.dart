import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Incident report flow (#70)
class IncidentReportSheet extends StatefulWidget {
  const IncidentReportSheet({
    required this.rideId,
    required this.onSubmit,
    super.key,
  });
  final String rideId;
  final ValueChanged<IncidentReport> onSubmit;

  static Future<void> show(
    BuildContext context, {
    required String rideId,
    required ValueChanged<IncidentReport> onSubmit,
  }) {
    return AppModalSheet.show<void>(
      context: context,
      title: AppLocalizations.of(context).reportIncident,
      maxHeightFactor: 0.86,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: IncidentReportSheet(rideId: rideId, onSubmit: onSubmit),
      ),
    );
  }

  @override
  State<IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<IncidentReportSheet> {
  IncidentType? _selectedType;
  final _descriptionController = TextEditingController();
  IncidentSeverity _severity = IncidentSeverity.low;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Title and drag handle are provided by AppModalSheet's always-visible
    // top bar (see IncidentReportSheet.show), so they are not repeated here.
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type selection
          Text(
            AppLocalizations.of(context).incidentType,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: IncidentType.values.map((type) {
              final selected = type == _selectedType;
              return ChoiceChip(
                label: Text(type.localizedLabel(context)),
                selected: selected,
                onSelected: (v) => setState(() => _selectedType = type),
                avatar: Icon(type.icon, size: 16.sp),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          // Severity
          Text(
            AppLocalizations.of(context).severity,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          SegmentedButton<IncidentSeverity>(
            segments: IncidentSeverity.values
                .map(
                  (s) => ButtonSegment(
                    value: s,
                    label: Text(s.localizedLabel(context)),
                  ),
                )
                .toList(),
            selected: {_severity},
            onSelectionChanged: (s) => setState(() => _severity = s.first),
          ),
          SizedBox(height: 16.h),
          // Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).describeWhatHappened,
              alignLabelWithHint: true,
            ),
          ),
          SizedBox(height: 20.h),
          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedType == null
                  ? null
                  : () {
                      unawaited(HapticFeedback.mediumImpact());
                      widget.onSubmit(
                        IncidentReport(
                          rideId: widget.rideId,
                          type: _selectedType!,
                          severity: _severity,
                          description: _descriptionController.text.trim(),
                        ),
                      );
                      Navigator.pop(context);
                    },
              child: Text(AppLocalizations.of(context).submitReport),
            ),
          ),
        ],
      ),
    );
  }
}

enum IncidentType {
  unsafeDriving,
  harassment,
  routeDeviation,
  vehicleIssue,
  noShow,
  other;

  IconData get icon {
    switch (this) {
      case IncidentType.unsafeDriving:
        return Icons.speed_rounded;
      case IncidentType.harassment:
        return Icons.report_gmailerrorred_rounded;
      case IncidentType.routeDeviation:
        return Icons.wrong_location_rounded;
      case IncidentType.vehicleIssue:
        return Icons.car_crash_rounded;
      case IncidentType.noShow:
        return Icons.person_off_rounded;
      case IncidentType.other:
        return Icons.adaptive.more_rounded;
    }
  }
}

enum IncidentSeverity {
  low,
  medium,
  high;

  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case IncidentSeverity.low:
        return l10n.severityLow;
      case IncidentSeverity.medium:
        return l10n.severityMedium;
      case IncidentSeverity.high:
        return l10n.severityHigh;
    }
  }
}

extension IncidentTypeL10n on IncidentType {
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case IncidentType.unsafeDriving:
        return l10n.incidentTypeUnsafeDriving;
      case IncidentType.harassment:
        return l10n.incidentTypeHarassment;
      case IncidentType.routeDeviation:
        return l10n.incidentTypeRouteDeviation;
      case IncidentType.vehicleIssue:
        return l10n.incidentTypeVehicleIssue;
      case IncidentType.noShow:
        return l10n.incidentTypeNoShow;
      case IncidentType.other:
        return l10n.incidentTypeOther;
    }
  }
}

class IncidentReport {
  const IncidentReport({
    required this.rideId,
    required this.type,
    required this.severity,
    required this.description,
  });
  final String rideId;
  final IncidentType type;
  final IncidentSeverity severity;
  final String description;
}

/// Drive history transparency card (#71)
class DriveHistoryCard extends StatelessWidget {
  const DriveHistoryCard({
    required this.totalRides,
    required this.averageRating,
    required this.cancelCount,
    required this.noShowCount,
    required this.memberSince,
    super.key,
    this.isVerified = false,
  });
  final int totalRides;
  final double averageRating;
  final int cancelCount;
  final int noShowCount;
  final DateTime memberSince;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = DateTime.now().difference(memberSince).inDays ~/ 30;
    final reliability = totalRides > 0
        ? ((totalRides - cancelCount - noShowCount) / totalRides * 100).round()
        : 100;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 20.sp, color: AppColors.info),
              SizedBox(width: 8.w),
              Text(
                'Driver History',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isVerified)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 14.sp,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Verified',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _statBadge(
                context,
                '$totalRides',
                'Rides',
                Icons.directions_car_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                averageRating.toStringAsFixed(1),
                'Rating',
                Icons.star_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                '$reliability%',
                'Reliable',
                Icons.verified_user_rounded,
              ),
              SizedBox(width: 8.w),
              _statBadge(
                context,
                '${months}mo',
                'Member',
                Icons.calendar_month_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBadge(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
