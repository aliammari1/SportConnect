import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/admin/views/admin_design_system.dart';

/// Uppercase section label with an optional trailing action.
class KitSectionHeader extends StatelessWidget {
  const KitSectionHeader({
    required this.title, super.key,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, OpsDS.s5.h, 4.w, OpsDS.s2.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: AppColors.textSecondary),
            SizedBox(width: OpsDS.s2.w),
          ],
          Expanded(child: Text(title, style: OpsDS.sectionHeader(context))),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// KPI card: icon chip, tabular value, meta label, optional delta and sparkline.
class KitStatCard extends StatelessWidget {
  const KitStatCard({
    required this.icon, required this.accent, required this.label, required this.value, super.key,
    this.deltaText,
    this.deltaUp = true,
    this.spark,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final String? deltaText;
  final bool deltaUp;
  final List<double>? spark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(OpsDS.s3.w),
      decoration: OpsDS.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(OpsDS.rSm),
                ),
                child: Icon(icon, size: 15.sp, color: accent),
              ),
              if (deltaText != null) ...[
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (deltaUp ? KitStatus.live : KitStatus.danger)
                        .color
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(OpsDS.rPill),
                  ),
                  child: Text(
                    deltaText!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: deltaUp
                          ? KitStatus.live.color
                          : KitStatus.danger.color,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: OpsDS.s2.h),
          Text(value, style: OpsDS.kpiValue(context)),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: OpsDS.meta(context),
          ),
          if (spark != null && spark!.length > 1) ...[
            SizedBox(height: OpsDS.s2.h),
            SizedBox(
              height: 22.h,
              width: double.infinity,
              child: CustomPaint(painter: _SparklinePainter(spark!, accent)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.points, this.color);

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minP = points.reduce(math.min);
    final maxP = points.reduce(math.max);
    final span = (maxP - minP) == 0 ? 1.0 : maxP - minP;
    final step = size.width / (points.length - 1);

    Offset at(int i) => Offset(
          i * step,
          size.height -
              ((points[i] - minP) / span) * size.height * 0.86 -
              size.height * 0.07,
        );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas
      ..drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.18),
              color.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.points.length != points.length || old.color != color;
}

/// Stadium status chip with a colored dot.
class KitStatusPill extends StatelessWidget {
  const KitStatusPill(this.status, {super.key, this.label});

  final KitStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: status.bg,
        borderRadius: BorderRadius.circular(OpsDS.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            (label ?? status.label).toUpperCase(),
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small filled count badge.
class KitCountBadge extends StatelessWidget {
  const KitCountBadge(this.count, {super.key, this.color});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      constraints: BoxConstraints(minWidth: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(OpsDS.rPill),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Standard ops list row: card surface, optional status rail, press feedback.
class KitTile extends StatelessWidget {
  const KitTile({
    required this.title, super.key,
    this.leading,
    this.subtitle,
    this.trailing,
    this.status,
    this.onTap,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final KitStatus? status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: OpsDS.s2.h),
      child: Material(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(OpsDS.rCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              children: [
                if (status != null)
                  Container(width: 4.w, color: status!.color),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: OpsDS.s3.w,
                      vertical: OpsDS.s3.h,
                    ),
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          SizedBox(width: OpsDS.s3.w),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (subtitle != null && subtitle!.isNotEmpty)
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: OpsDS.meta(context),
                                ),
                            ],
                          ),
                        ),
                        if (trailing != null) ...[
                          SizedBox(width: OpsDS.s2.w),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Borderless rounded search field on an input-fill surface.
class KitSearchField extends StatelessWidget {
  const KitSearchField({
    required this.onChanged, required this.hintText, super.key,
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: OpsDS.body(context),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: OpsDS.meta(context),
        prefixIcon:
            Icon(Icons.search_rounded, size: 18.sp, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            EdgeInsets.symmetric(horizontal: OpsDS.s3.w, vertical: OpsDS.s3.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpsDS.rSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(OpsDS.rSm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        isDense: true,
      ),
    );
  }
}

/// Centered empty placeholder with optional action.
class KitEmptyState extends StatelessWidget {
  const KitEmptyState({
    required this.icon, required this.title, super.key,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(OpsDS.s8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24.sp, color: AppColors.textTertiary),
            ),
            SizedBox(height: OpsDS.s4.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: OpsDS.cardTitle(context),
            ),
            if (message != null) ...[
              SizedBox(height: OpsDS.s1.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: OpsDS.meta(context),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: OpsDS.s4.h),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered failure state with a retry action.
class KitErrorState extends StatelessWidget {
  const KitErrorState({required this.error, required this.onRetry, super.key});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return KitEmptyState(
      icon: Icons.cloud_off_rounded,
      title: error.toString(),
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

/// Shimmer skeleton mimicking a stack of [KitTile]s while loading.
class KitShimmerList extends StatelessWidget {
  const KitShimmerList({super.key, this.items = 5, this.itemHeight = 76});

  final int items;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmer,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(OpsDS.padScreen.w),
        itemCount: items,
        itemBuilder: (_, _) => Container(
          height: itemHeight.h,
          margin: EdgeInsets.only(bottom: OpsDS.s2.h),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(OpsDS.rCard),
          ),
        ),
      ),
    );
  }
}

/// Square quick-action tile with icon chip and centered label.
class KitQuickAction extends StatelessWidget {
  const KitQuickAction({
    required this.icon, required this.label, required this.onTap, super.key,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? AppColors.primary;
    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(OpsDS.rCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: 72.h),
          padding: EdgeInsets.all(OpsDS.s3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpsDS.rCard),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(OpsDS.rSm),
                ),
                child: Icon(icon, size: 17.sp, color: c),
              ),
              SizedBox(height: OpsDS.s2.h),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient command-center header with eyebrow, hero value, footnote.
class KitHeroHeader extends StatelessWidget {
  const KitHeroHeader({
    required this.eyebrow, required this.value, required this.footnote, super.key,
    this.trailing,
  });

  final String eyebrow;
  final String value;
  final String footnote;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(OpsDS.s5.w),
      decoration: OpsDS.heroGradient(),
      child: Stack(
        children: [
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(OpsDS.rLg),
            gradient: OpsDS.heroSheen(),
          ))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      eyebrow.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              SizedBox(height: OpsDS.s2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                footnote,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pulsing status dot used as a live indicator.
class KitPulseDot extends StatefulWidget {
  const KitPulseDot({
    super.key,
    this.size = 10,
    this.color = const Color(0xFF16A34A),
  });

  final double size;
  final Color color;

  @override
  State<KitPulseDot> createState() => _KitPulseDotState();
}

class _KitPulseDotState extends State<KitPulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.4,
      height: widget.size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.6, end: 1.6).animate(
              CurvedAnimation(parent: _c, curve: Curves.easeOut),
            ),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 0).animate(_c),
              child: Container(
                width: widget.size * 2.2,
                height: widget.size * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.40),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Key-value row for detail sheets, with optional copy affordance.
class KitInfoRow extends StatelessWidget {
  const KitInfoRow({
    required this.label, required this.value, super.key,
    this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: OpsDS.s2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: OpsDS.meta(context)),
          ),
          Expanded(
            child: Text(value, style: OpsDS.body(context)),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: Icon(Icons.copy_rounded,
                  size: 15.sp, color: AppColors.textTertiary),
            ),
        ],
      ),
    );
  }
}
