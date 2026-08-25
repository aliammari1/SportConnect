import 'dart:async';
import 'dart:math' as math;

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/adaptive_tap_surface.dart';
import 'package:sport_connect/features/onboarding/view_models/onboarding_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

// -----------------------------------------------------------------------------
// SportConnect onboarding
// Product story:
// 1. Runners find rides to events.
// 2. Drivers offer empty seats and earn.
// 3. Riders and drivers plan pickup and route.
// 4. Everyone connects safely before going.
// No humans / portraits / photos. All visuals are cards, icons, and painters.
// -----------------------------------------------------------------------------

double _clamped(num value, double min, double max) {
  // On tablets the global ScreenUtil design scale is ~1.5× (see main.dart), so
  // scale these phone-tuned size caps up by the same factor — otherwise the
  // hard maxima (title 32, card heights, etc.) would keep the onboarding small
  // and leave the iPad mostly empty. Phones (scaleWidth ≤ ~1.15) are untouched.
  final sw = ScreenUtil().scaleWidth;
  final s = sw > 1.2 ? sw : 1.0;
  return value.clamp(min * s, max * s).toDouble();
}

/// Width cap that must always fit the physical screen, so it is NOT scaled up
/// on tablets the way [_clamped] is.
double _clampedWidth(num value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  int get _currentPage =>
      ref.read(onboardingViewModelProvider).currentPageIndex;

  /// The PageController's live page, rounded to the nearest index. This is the
  /// single source of truth for next/back/completion decisions, so rapid taps
  /// can't act on a stale VM snapshot that lags the controller (setPageIndex
  /// only fires asynchronously after a page-change animation begins).
  int get _controllerPage {
    if (!_pageController.hasClients || _pageController.page == null) {
      return _currentPage;
    }
    return _pageController.page!.round().clamp(0, _onboardingSteps.length - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingViewModelProvider.notifier).setPageIndex(page);
  }

  Future<void> _completeOnboarding() async {
    final success = await ref
        .read(onboardingViewModelProvider.notifier)
        .completeOnboarding();

    if (!success || !mounted) return;

    // Navigation is driven by isOnboardingCompleteProvider invalidation in the
    // VM, which triggers the GoRouter redirect. No explicit go() call needed.
    unawaited(HapticFeedback.mediumImpact());
  }

  void _goNext() {
    unawaited(HapticFeedback.lightImpact());

    if (_controllerPage == _onboardingSteps.length - 1) {
      unawaited(_completeOnboarding());
      return;
    }

    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _goBack() {
    if (_controllerPage == 0) return;

    unawaited(HapticFeedback.lightImpact());
    unawaited(
      _pageController.previousPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(onboardingViewModelProvider);

    // Show a SnackBar whenever an error is set in the VM state.
    ref.listen<OnboardingState>(onboardingViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        // The VM emits a stable, non-PII error key; map it to a localized
        // message so users never see a raw exception string.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).somethingWentWrong),
          ),
        );
        ref.read(onboardingViewModelProvider.notifier).clearError();
      }
    });

    final maxWidth = context.screenWidth >= Breakpoints.medium
        ? 1180.0
        : kMaxWidthForm;

    return AdaptiveScaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.060),
              AppColors.cardBg,
              AppColors.cardBg,
            ],
          ),
        ),
        child: MaxWidthContainer(
          maxWidth: maxWidth,
          child: SafeArea(
            child: Column(
              children: [
                _OnboardingTopBar(
                  currentPage: _currentPage,
                  totalPages: _onboardingSteps.length,
                  onSkip: _completeOnboarding,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _onboardingSteps.length,
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        step: _onboardingSteps[index],
                        index: index,
                      );
                    },
                  ),
                ),
                _OnboardingBottomControls(
                  currentPage: _currentPage,
                  totalPages: _onboardingSteps.length,
                  vmState: vmState,
                  onBack: _goBack,
                  onNext: _goNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Content model
// -----------------------------------------------------------------------------

enum _OnboardingVisual {
  findRide,
  earnSeats,
  planPickup,
  connectGo,
}

class _OnboardingStepSpec {
  const _OnboardingStepSpec({
    required this.visual,
  });

  final _OnboardingVisual visual;

  String eyebrow(AppLocalizations l10n) => switch (visual) {
    _OnboardingVisual.findRide => l10n.onboardingRunningEvents,
    _OnboardingVisual.earnSeats => l10n.onboardingDriveEarn,
    _OnboardingVisual.planPickup => l10n.onboardingPickupPlanning,
    _OnboardingVisual.connectGo => l10n.onboardingTrustedRides,
  };

  String title(AppLocalizations l10n) => switch (visual) {
    _OnboardingVisual.findRide => l10n.onboardingFindRideTitle,
    _OnboardingVisual.earnSeats => l10n.onboardingOfferSeatsTitle,
    _OnboardingVisual.planPickup => l10n.onboardingPlanRouteTitle,
    _OnboardingVisual.connectGo => l10n.onboardingConnectGoTitle,
  };

  String description(AppLocalizations l10n) => switch (visual) {
    _OnboardingVisual.findRide => l10n.onboardingFindRideDescription,
    _OnboardingVisual.earnSeats => l10n.onboardingOfferSeatsDescription,
    _OnboardingVisual.planPickup => l10n.onboardingPlanRouteDescription,
    _OnboardingVisual.connectGo => l10n.onboardingConnectGoDescription,
  };
}

const _onboardingSteps = [
  _OnboardingStepSpec(
    visual: _OnboardingVisual.findRide,
  ),
  _OnboardingStepSpec(
    visual: _OnboardingVisual.earnSeats,
  ),
  _OnboardingStepSpec(
    visual: _OnboardingVisual.planPickup,
  ),
  _OnboardingStepSpec(
    visual: _OnboardingVisual.connectGo,
  ),
];

// -----------------------------------------------------------------------------
// Top bar
// -----------------------------------------------------------------------------

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final showSkip = currentPage < totalPages - 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _clamped(24.w, 18, 28),
        _clamped(14.h, 10, 16),
        _clamped(24.w, 18, 28),
        _clamped(8.h, 6, 10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StepIndicator(
              currentPage: currentPage,
              totalPages: totalPages,
            ),
          ),
          SizedBox(width: _clamped(12.w, 8, 14)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showSkip
                ? _TextActionButton(
                    key: const ValueKey('skip'),
                    label: AppLocalizations.of(context).skip,
                    onPressed: onSkip,
                  )
                : SizedBox(
                    key: const ValueKey('empty-skip'),
                    width: _clamped(56.w, 48, 62),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  final int currentPage;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    final pageCount = totalPages <= 0 ? 1 : totalPages;
    final page = currentPage.clamp(0, pageCount - 1);
    final l10n = AppLocalizations.of(context);
    const activeColor = AppColors.primary;
    final completedColor = AppColors.primary.withValues(alpha: 0.82);
    final inactiveColor = AppColors.border.withValues(alpha: 0.62);
    final inactiveFill = AppColors.surfaceVariant.withValues(alpha: 0.74);

    final activeSize = _clamped(28.w, 24, 30);
    final completedSize = _clamped(18.w, 16, 20);
    final inactiveSize = _clamped(9.w, 7, 10);
    final lineHeight = _clamped(3.h, 2, 4);

    return Semantics(
      label: l10n.onboardingStepCount(page + 1, pageCount),
      child: ExcludeSemantics(
        child: SizedBox(
          height: _clamped(34.h, 30, 38),
          child: Row(
            children: List.generate(pageCount * 2 - 1, (slot) {
              if (slot.isOdd) {
                final connectorIndex = slot ~/ 2;
                final isCompleted = connectorIndex < page;

                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: lineHeight,
                    margin: EdgeInsets.symmetric(
                      horizontal: _clamped(8.w, 5, 10),
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? completedColor.withValues(alpha: 0.42)
                          : inactiveColor,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                );
              }

              final index = slot ~/ 2;
              final isActive = index == page;
              final isPast = index < page;
              final size = isActive
                  ? activeSize
                  : isPast
                  ? completedSize
                  : inactiveSize;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor
                      : isPast
                      ? completedColor
                      : inactiveFill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive || isPast
                        ? activeColor.withValues(alpha: 0.18)
                        : inactiveColor,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.24),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isActive
                      ? Text(
                          '${index + 1}',
                          key: ValueKey('active-$index'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _clamped(11.sp, 9, 12),
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        )
                      : isPast
                      ? Icon(
                          Icons.check_rounded,
                          key: ValueKey('past-$index'),
                          color: Colors.white,
                          size: _clamped(12.sp, 10, 13),
                        )
                      : const SizedBox.shrink(
                          key: ValueKey('future'),
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: AdaptiveTapSurface(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () {
          unawaited(HapticFeedback.lightImpact());
          onPressed();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _clamped(10.w, 8, 12),
            vertical: _clamped(8.h, 6, 9),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: _clamped(13.sp, 12, 14),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page body
// -----------------------------------------------------------------------------

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.step,
    required this.index,
  });

  final _OnboardingStepSpec step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontalPadding = _clamped(24.w, 18, 28);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletLayout = constraints.maxWidth >= Breakpoints.medium;
        // Treat iPad-portrait (shortestSide >= 600 but width < 840) as a tablet
        // too: use a wider, richer single column instead of a phone-width column
        // floating in the middle of the canvas.
        final isTabletDevice =
            MediaQuery.sizeOf(context).shortestSide >= Breakpoints.compact;
        final maxContentWidth = isTabletLayout
            ? _clampedWidth(980.w, 760, 1040)
            : isTabletDevice
            ? _clampedWidth(640.w, 560, 720)
            : _clampedWidth(430.w, 320, 460);
        final visual = _VisualCard(
          visual: step.visual,
        ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.025);
        final copy = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isTabletLayout
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            _Eyebrow(
              text: step.eyebrow(l10n),
            ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
            SizedBox(height: _clamped(10.h, 7, 12)),
            Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: isTabletLayout
                    ? Alignment.centerLeft
                    : Alignment.center,
                child: Text(
                  step.title(l10n),
                  textAlign: isTabletLayout ? TextAlign.start : TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _clamped(29.sp, 24, 32),
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),
            SizedBox(height: _clamped(10.h, 7, 12)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTabletLayout
                    ? _clamped(380.w, 320, 420)
                    : _clamped(320.w, 280, 360),
              ),
              child: Text(
                step.description(l10n),
                textAlign: isTabletLayout ? TextAlign.start : TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: _clamped(14.sp, 12.5, 15),
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ).animate().fadeIn(delay: 220.ms).slideY(begin: 0.08),
            SizedBox(height: _clamped(12.h, 8, 16)),
          ],
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            _clamped(10.h, 6, 14),
            horizontalPadding,
            _clamped(28.h, 20, 34),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              // Center vertically so the extra height on tablets/landscape is
              // balanced as margins around the content instead of dumped into
              // an empty bottom. On phones the content ~fills, so this is a
              // no-op there.
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: isTabletLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: visual),
                          SizedBox(width: _clamped(28.w, 24, 36)),
                          Expanded(flex: 5, child: copy),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          visual,
                          SizedBox(height: _clamped(18.h, 12, 22)),
                          copy,
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(12.w, 10, 14),
        vertical: _clamped(6.h, 5, 7),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.085),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: _clamped(10.sp, 9, 11),
          fontWeight: FontWeight.w900,
          letterSpacing: 1.25,
        ),
      ),
    );
  }
}

class _VisualCard extends StatelessWidget {
  const _VisualCard({required this.visual});

  final _OnboardingVisual visual;

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      _OnboardingVisual.findRide => const _FindRideVisual(),
      _OnboardingVisual.earnSeats => const _EarnSeatsVisual(),
      _OnboardingVisual.planPickup => const _PlanPickupVisual(),
      _OnboardingVisual.connectGo => const _ConnectGoVisual(),
    };
  }
}

// -----------------------------------------------------------------------------
// Screen 1 — Find ride
// -----------------------------------------------------------------------------

class _FindRideVisual extends StatelessWidget {
  const _FindRideVisual();

  @override
  Widget build(BuildContext context) {
    final heroHeight = _clamped(224.h, 188, 252);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FindRideHeroCard(height: heroHeight),
        SizedBox(height: _clamped(12.h, 9, 14)),
        const _RideAvailabilityCard(),
      ],
    );
  }
}

class _FindRideHeroCard extends StatelessWidget {
  const _FindRideHeroCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: DecoratedBox(
            decoration: _softGreenGradient(),
            child: CustomPaint(
              painter: const _FindRidePainter(color: AppColors.primary),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  _clamped(20.w, 16, 24),
                  _clamped(20.h, 16, 24),
                  _clamped(20.w, 16, 24),
                  _clamped(16.h, 12, 18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _HeroEventTitle(
                            title: AppLocalizations.of(context).paris,
                            distance: '10K',
                            location: AppLocalizations.of(
                              context,
                            ).onboardingRunningEventLabel,
                          ),
                        ),
                        SizedBox(width: _clamped(12.w, 8, 14)),
                        _EventBadge(
                          labelTop: AppLocalizations.of(context).ride,
                          labelMain: '3',
                          labelBottom: AppLocalizations.of(
                            context,
                          ).onboardingRideBadgeOpen,
                          size: _clamped(70.w, 58, 76),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatPill(
                            icon: Icons.directions_car_filled_rounded,
                            label: AppLocalizations.of(
                              context,
                            ).valueRidesAvailable(3),
                          ),
                        ),
                        SizedBox(width: _clamped(8.w, 6, 10)),
                        Expanded(
                          child: _MiniStatPill(
                            icon: Icons.payments_outlined,
                            label: AppLocalizations.of(context).from_8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RideAvailabilityCard extends StatelessWidget {
  const _RideAvailabilityCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.fromLTRB(
        _clamped(18.w, 15, 20),
        _clamped(16.h, 14, 18),
        _clamped(18.w, 15, 20),
        _clamped(17.h, 14, 19),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _StatusPill(
                label: AppLocalizations.of(context).rides_available,
                icon: Icons.route_rounded,
              ),
              const Spacer(),
              Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.textSecondary,
                size: _clamped(21.sp, 18, 22),
              ),
            ],
          ),
          SizedBox(height: _clamped(13.h, 9, 15)),
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context).ride_to_paris_10k,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _clamped(23.sp, 20, 25),
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
                ),
              ),
              SizedBox(width: _clamped(10.w, 8, 12)),
              _SmallPill(label: AppLocalizations.of(context).valueSeats(2)),
            ],
          ),
          SizedBox(height: _clamped(14.h, 10, 16)),
          _InfoLine(
            icon: Icons.event_outlined,
            text: AppLocalizations.of(context).sun_15_jun_2025,
          ),
          SizedBox(height: _clamped(8.h, 5, 9)),
          _InfoLine(
            icon: Icons.location_on_outlined,
            text: AppLocalizations.of(context).pickup_near_paris_france,
          ),
          SizedBox(height: _clamped(8.h, 5, 9)),
          _InfoLine(
            icon: Icons.euro_rounded,
            text: AppLocalizations.of(context).passenger_contribution_from_8,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 2 — Earn seats
// -----------------------------------------------------------------------------

class _EarnSeatsVisual extends StatelessWidget {
  const _EarnSeatsVisual();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _EarningsHeroCard(),
        SizedBox(height: _clamped(12.h, 9, 14)),
        _PremiumCard(
          padding: EdgeInsets.fromLTRB(
            _clamped(16.w, 14, 18),
            _clamped(15.h, 13, 17),
            _clamped(16.w, 14, 18),
            _clamped(16.h, 14, 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SeatSelectorHeader(),
              SizedBox(height: _clamped(12.h, 9, 14)),
              const _SeatChips(),
              SizedBox(height: _clamped(14.h, 10, 16)),
              Row(
                children: [
                  Expanded(
                    child: _MiniSummaryTile(
                      icon: Icons.local_gas_station_outlined,
                      label: AppLocalizations.of(context).fuel_offset,
                      value: AppLocalizations.of(context).onboardingSharedLabel,
                    ),
                  ),
                  SizedBox(width: _clamped(9.w, 7, 10)),
                  Expanded(
                    child: _MiniSummaryTile(
                      icon: Icons.verified_user_outlined,
                      label: AppLocalizations.of(context).passengers,
                      value: AppLocalizations.of(context).verified,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _clamped(13.h, 10, 15)),
              const _IncludedRideBenefits(),
            ],
          ),
        ),
      ],
    );
  }
}

class _EarningsHeroCard extends StatelessWidget {
  const _EarningsHeroCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: DecoratedBox(
          decoration: _softGreenGradient(),
          child: CustomPaint(
            painter: const _EarningsPainter(color: AppColors.primary),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _clamped(18.w, 16, 20),
                _clamped(17.h, 15, 19),
                _clamped(18.w, 16, 20),
                _clamped(17.h, 15, 19),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const _IconSquare(
                        icon: Icons.directions_car_filled_rounded,
                      ),
                      SizedBox(width: _clamped(12.w, 9, 14)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).offer_your_ride,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: _clamped(16.sp, 14, 18),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).paris_10k_2_seats_available,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: _clamped(11.sp, 10, 12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: _clamped(8.w, 6, 10)),
                      _SmallPill(label: AppLocalizations.of(context).driver),
                    ],
                  ),
                  SizedBox(height: _clamped(16.h, 12, 18)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: _clamped(15.w, 13, 17),
                      vertical: _clamped(15.h, 12, 17),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(19.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).estimated_earning,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: _clamped(10.sp, 9, 11),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(height: _clamped(7.h, 5, 8)),
                              Text(
                                AppLocalizations.of(context).fill_2_seats,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: _clamped(12.sp, 11, 13),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: _clamped(12.w, 8, 14)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppLocalizations.of(context).onboardingEstimatedEarning,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: _clamped(44.sp, 34, 48),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              height: 0.95,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeatSelectorHeader extends StatelessWidget {
  const _SeatSelectorHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context).set_available_seats,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: _clamped(13.sp, 12, 14),
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const Spacer(),
        Text(
          AppLocalizations.of(context).flexible,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: _clamped(11.sp, 10, 12),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SeatChips extends StatelessWidget {
  const _SeatChips();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seats = List<String>.generate(
      4,
      (index) => l10n.valueSeatValue(index + 1, index == 0 ? '' : 's'),
    );

    return Wrap(
      spacing: _clamped(8.w, 6, 9),
      runSpacing: _clamped(8.h, 6, 9),
      children: seats.map((seat) {
        final selected = seat == l10n.valueSeatValue(2, 's');
        return _SelectableChip(
          label: seat,
          selected: selected,
          icon: selected
              ? Icons.check_circle_rounded
              : Icons.event_seat_outlined,
        );
      }).toList(),
    );
  }
}

class _IncludedRideBenefits extends StatelessWidget {
  const _IncludedRideBenefits();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = <({IconData icon, String label})>[
      (icon: Icons.payments_outlined, label: l10n.earn),
      (icon: Icons.schedule_outlined, label: l10n.set_time),
      (icon: Icons.pin_drop_outlined, label: l10n.pickup),
      (icon: Icons.chat_bubble_outline_rounded, label: l10n.chat),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.driver_tools,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: _clamped(12.sp, 11, 13),
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: _clamped(10.h, 8, 12)),
        Wrap(
          spacing: _clamped(8.w, 6, 9),
          runSpacing: _clamped(8.h, 6, 9),
          children: items.map((item) {
            return _BenefitChip(icon: item.icon, label: item.label);
          }).toList(),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 3 — Plan pickup route
// -----------------------------------------------------------------------------

class _PlanPickupVisual extends StatelessWidget {
  const _PlanPickupVisual();

  @override
  Widget build(BuildContext context) {
    final mapHeight = _clamped(205.h, 172, 224);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PremiumCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    _clamped(16.w, 14, 18),
                    _clamped(14.h, 12, 16),
                    _clamped(16.w, 14, 18),
                    _clamped(10.h, 8, 12),
                  ),
                  child: Row(
                    children: [
                      const _IconSquare(icon: Icons.route_outlined),
                      SizedBox(width: _clamped(11.w, 8, 12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).pickup_route,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: _clamped(14.sp, 12.5, 15),
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).coordinate_pickup_before_the_event,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: _clamped(11.sp, 10, 12),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: _clamped(8.w, 6, 10)),
                      _SmallPill(label: AppLocalizations.of(context).ride),
                    ],
                  ),
                ),
                SizedBox(
                  height: mapHeight,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _PickupRoutePainter(
                      color: AppColors.primary,
                      borderColor: AppColors.border,
                      startLabel: AppLocalizations.of(context).start,
                      pickupLabel: AppLocalizations.of(context).pickup,
                      eventLabel: AppLocalizations.of(
                        context,
                      ).onboardingEventLabel,
                      driverRouteLabel: AppLocalizations.of(
                        context,
                      ).onboardingDriverRouteLabel,
                      sharedArrivalLabel: AppLocalizations.of(
                        context,
                      ).onboardingSharedArrivalLabel,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: _clamped(12.h, 9, 14)),
        _PremiumCard(
          padding: EdgeInsets.fromLTRB(
            _clamped(16.w, 14, 18),
            _clamped(15.h, 13, 17),
            _clamped(16.w, 14, 18),
            _clamped(16.h, 14, 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context).trip_plan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: _clamped(14.sp, 12.5, 15),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    AppLocalizations.of(context).sun_15_jun,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: _clamped(11.sp, 10, 12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _clamped(14.h, 10, 16)),
              _TimelineItem(
                icon: Icons.home_outlined,
                time: '06:15',
                title: AppLocalizations.of(context).driver_starts,
                subtitle: AppLocalizations.of(
                  context,
                ).route_opens_for_passengers,
                isFirst: true,
              ),
              _TimelineItem(
                icon: Icons.person_pin_circle_outlined,
                time: '06:40',
                title: AppLocalizations.of(context).pickup_confirmed,
                subtitle: AppLocalizations.of(context).shared_meeting_point,
              ),
              _TimelineItem(
                icon: Icons.flag_outlined,
                time: '07:30',
                title: AppLocalizations.of(context).arrive_at_event,
                subtitle: AppLocalizations.of(
                  context,
                ).paris_10k_race_village,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 4 — Connect safely
// -----------------------------------------------------------------------------

class _ConnectGoVisual extends StatelessWidget {
  const _ConnectGoVisual();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _ConfirmedRideCard(),
        SizedBox(height: _clamped(12.h, 9, 14)),
        _PremiumCard(
          padding: EdgeInsets.fromLTRB(
            _clamped(16.w, 14, 18),
            _clamped(15.h, 13, 17),
            _clamped(16.w, 14, 18),
            _clamped(16.h, 14, 18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.verified_user_outlined,
                      title: AppLocalizations.of(context).verified,
                      subtitle: AppLocalizations.of(context).trusted_runners,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: AppLocalizations.of(context).chat,
                      subtitle: AppLocalizations.of(context).before_pickup,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _clamped(10.h, 8, 12)),
              Row(
                children: [
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.location_on_outlined,
                      title: AppLocalizations.of(context).live_route,
                      subtitle: AppLocalizations.of(context).trip_visibility,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _FeatureTile(
                      icon: Icons.shield_outlined,
                      title: AppLocalizations.of(context).safer_rides,
                      subtitle: AppLocalizations.of(context).event_travel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: _clamped(12.h, 9, 14)),
        const _RideNetworkCard(),
      ],
    );
  }
}

class _ConfirmedRideCard extends StatelessWidget {
  const _ConfirmedRideCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: DecoratedBox(
          decoration: _softGreenGradient(),
          child: CustomPaint(
            painter: const _TrustPainter(color: AppColors.primary),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _clamped(18.w, 16, 20),
                _clamped(17.h, 15, 19),
                _clamped(18.w, 16, 20),
                _clamped(17.h, 15, 19),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _EventBadge(
                        labelTop: AppLocalizations.of(context).ride,
                        labelMain: AppLocalizations.of(context).ok,
                        labelBottom: AppLocalizations.of(
                          context,
                        ).onboardingRideBadgeSet,
                        size: _clamped(76.w, 62, 82),
                        filled: true,
                      ),
                      SizedBox(width: _clamped(15.w, 12, 18)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).booking_confirmed,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: _clamped(20.sp, 18, 22),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: _clamped(5.h, 4, 7)),
                            Text(
                              AppLocalizations.of(
                                context,
                              ).paris_10k_2_passengers,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: _clamped(12.sp, 11, 13),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: _clamped(10.h, 8, 12)),
                            _SmallPill(
                              label: AppLocalizations.of(context).pickup_0640,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _clamped(16.h, 12, 18)),
                  const _ChatPreviewCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatPreviewCard extends StatelessWidget {
  const _ChatPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        _clamped(14.w, 12, 16),
        _clamped(12.h, 10, 14),
        _clamped(14.w, 12, 16),
        _clamped(12.h, 10, 14),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: [
          const _IconSquare(icon: Icons.chat_bubble_outline_rounded),
          SizedBox(width: _clamped(11.w, 8, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).inapp_chat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _clamped(13.sp, 12, 14),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(
                    context,
                  ).confirm_bags_pickup_spot_and_arrival_time,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: _clamped(11.sp, 10, 12),
                    height: 1.25,
                    fontWeight: FontWeight.w600,
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

class _RideNetworkCard extends StatelessWidget {
  const _RideNetworkCard();

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      padding: EdgeInsets.fromLTRB(
        _clamped(15.w, 13, 17),
        _clamped(14.h, 12, 16),
        _clamped(15.w, 13, 17),
        _clamped(14.h, 12, 16),
      ),
      child: Row(
        children: [
          const _IconSquare(icon: Icons.groups_2_outlined),
          SizedBox(width: _clamped(12.w, 9, 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).runner_carpool_network,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _clamped(14.sp, 13, 15),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  AppLocalizations.of(
                    context,
                  ).travel_with_people_going_to_the_same_event,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: _clamped(11.sp, 10, 12),
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
            size: _clamped(24.sp, 21, 25),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Shared UI widgets
// -----------------------------------------------------------------------------

BoxDecoration _softGreenGradient() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withValues(alpha: 0.13),
        AppColors.primary.withValues(alpha: 0.055),
        AppColors.cardBg,
      ],
    ),
  );
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(_clamped(18.w, 15, 20)),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.52),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeroEventTitle extends StatelessWidget {
  const _HeroEventTitle({
    required this.title,
    required this.distance,
    required this.location,
  });

  final String title;
  final String distance;
  final String location;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 0.92,
            ),
          ),
          Text(
            distance,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 40.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
              height: 0.98,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            location,
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.82),
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge({
    required this.labelTop,
    required this.labelMain,
    required this.size,
    this.labelBottom,
    this.filled = false,
  });

  final String labelTop;
  final String labelMain;
  final String? labelBottom;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShieldPainter(
        color: AppColors.primary,
        filled: filled,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              labelTop,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.primary,
                fontSize: (size * 0.12).clamp(8.0, 12.0),
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            SizedBox(height: size * 0.03),
            Text(
              labelMain,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.primary,
                fontSize: (size * 0.27).clamp(15.0, 24.0),
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            if (labelBottom != null) ...[
              SizedBox(height: size * 0.035),
              Text(
                labelBottom!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: filled ? Colors.white : AppColors.primary,
                  fontSize: (size * 0.105).clamp(7.0, 10.0),
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({
    required this.icon,
  });

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = _clamped(44.w, 38, 48);

    return Container(
      width: resolvedSize,
      height: resolvedSize,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: _clamped(21.sp, 18, 23),
      ),
    );
  }
}

class _MiniStatPill extends StatelessWidget {
  const _MiniStatPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(10.w, 8, 11),
        vertical: _clamped(8.h, 6, 9),
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: _clamped(14.sp, 12, 15),
          ),
          SizedBox(width: _clamped(5.w, 4, 6)),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: _clamped(11.sp, 10, 12),
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(10.w, 8, 12),
        vertical: _clamped(5.h, 4, 6),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: _clamped(11.sp, 10, 12),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(9.w, 8, 10),
        vertical: _clamped(5.h, 4, 6),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: _clamped(13.sp, 12, 14)),
          SizedBox(width: _clamped(5.w, 4, 6)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: _clamped(10.sp, 9, 11),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: _clamped(18.sp, 16, 19),
        ),
        SizedBox(width: _clamped(9.w, 7, 10)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: _clamped(12.sp, 11, 13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.icon,
  });

  final String label;
  final bool selected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(13.w, 11, 15),
        vertical: _clamped(10.h, 8, 11),
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.11)
            : AppColors.surfaceVariant.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.76)
              : AppColors.border.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            size: _clamped(14.sp, 12, 15),
          ),
          SizedBox(width: _clamped(5.w, 4, 6)),
          Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontSize: _clamped(12.sp, 11, 13),
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSummaryTile extends StatelessWidget {
  const _MiniSummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(11.w, 9, 12),
        vertical: _clamped(11.h, 9, 12),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.62),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: _clamped(18.sp, 16, 20),
          ),
          SizedBox(width: _clamped(8.w, 6, 9)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: _clamped(10.sp, 9, 11),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: _clamped(12.sp, 11, 13),
                    fontWeight: FontWeight.w900,
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

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _clamped(10.w, 8, 11),
        vertical: _clamped(9.h, 7, 10),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: _clamped(16.sp, 14, 18),
          ),
          SizedBox(width: _clamped(6.w, 5, 7)),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: _clamped(11.sp, 10, 12),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.time,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String time;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final markerSize = _clamped(26.w, 22, 28);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _clamped(30.w, 26, 32),
            child: Column(
              children: [
                Container(
                  width: markerSize,
                  height: markerSize,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: isFirst ? AppColors.primary : Colors.white,
                    size: _clamped(14.sp, 12, 15),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: _clamped(2.w, 1.5, 2),
                      margin: EdgeInsets.symmetric(
                        vertical: _clamped(4.h, 3, 5),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: _clamped(10.w, 8, 12)),
          SizedBox(
            width: _clamped(48.w, 42, 54),
            child: Text(
              time,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: _clamped(13.sp, 11.5, 14),
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(width: _clamped(8.w, 6, 10)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : _clamped(17.h, 12, 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: _clamped(13.sp, 12, 14),
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: _clamped(4.h, 3, 5)),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: _clamped(11.sp, 10, 12),
                      fontWeight: FontWeight.w600,
                      height: 1.28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        _clamped(12.w, 10, 14),
        _clamped(12.h, 10, 14),
        _clamped(12.w, 10, 14),
        _clamped(12.h, 10, 14),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: _clamped(20.sp, 18, 22)),
          SizedBox(height: _clamped(8.h, 6, 10)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: _clamped(12.sp, 11, 13),
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: _clamped(10.sp, 9, 11),
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Bottom controls
// -----------------------------------------------------------------------------

class _OnboardingBottomControls extends StatelessWidget {
  const _OnboardingBottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.vmState,
    required this.onBack,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final OnboardingState vmState;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    final isCompleting = vmState.isCompleting;
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _clamped(24.w, 18, 28),
        _clamped(10.h, 8, 12),
        _clamped(24.w, 18, 28),
        _clamped(18.h, 14, 22),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLast) ...[
            Text(
              AppLocalizations.of(context).onboardingCreateAccountPrompt,
              style: TextStyle(
                fontSize: _clamped(12.sp, 11, 13),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _clamped(10.h, 8, 12)),
          ],
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: currentPage == 0
                    ? SizedBox(
                        width: _clamped(54.w, 48, 58),
                        key: const ValueKey('empty-back'),
                      )
                    : _BackButton(
                        key: const ValueKey('back'),
                        onPressed: onBack,
                      ),
              ),
              SizedBox(width: _clamped(12.w, 9, 14)),
              Expanded(
                child: _PrimaryCtaButton(
                  label: isCompleting
                      ? loc.loading
                      : isLast
                      ? loc.getStarted
                      : loc.kContinue,
                  isLoading: isCompleting,
                  onPressed: isCompleting ? null : onNext,
                  icon: Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).previous_step,
      child: AdaptiveTapSurface(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        onTap: onPressed,
        child: SizedBox(
          width: _clamped(54.w, 48, 58),
          height: _clamped(54.h, 48, 58),
          child: Icon(
            Icons.adaptive.arrow_back_rounded,
            color: AppColors.textSecondary,
            size: _clamped(21.sp, 19, 23),
          ),
        ),
      ),
    );
  }
}

class _PrimaryCtaButton extends StatelessWidget {
  const _PrimaryCtaButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Semantics(
      button: true,
      enabled: !disabled,
      child: AdaptiveTapSurface(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onPressed,
        child: Container(
          height: _clamped(62.h, 54, 68),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: disabled
                  ? [
                      AppColors.primary.withValues(alpha: 0.35),
                      AppColors.primary.withValues(alpha: 0.26),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.86),
                      AppColors.primary,
                    ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _clamped(20.w, 16, 22)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _clamped(16.sp, 14, 17),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: _clamped(12.w, 9, 14)),
                if (isLoading)
                  SizedBox(
                    width: _clamped(21.sp, 19, 22),
                    height: _clamped(21.sp, 19, 22),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: Colors.white,
                    size: _clamped(21.sp, 19, 22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Painters
// -----------------------------------------------------------------------------

class _FindRidePainter extends CustomPainter {
  const _FindRidePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawCity(canvas, size);
    _drawRoute(canvas, size);
    _drawCar(canvas, Offset(w * 0.63, h * 0.63), math.min(w, h) * 0.16);
  }

  void _drawCity(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final riverPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final river = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.22, h * 0.70, w * 0.40, h * 0.87, w * 0.62, h * 0.76)
      ..cubicTo(w * 0.78, h * 0.68, w * 0.88, h * 0.80, w, h * 0.72)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(river, riverPaint);

    final towerPaint = Paint()
      ..color = color.withValues(alpha: 0.30)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final top = Offset(w * 0.52, h * 0.25);
    final leftBase = Offset(w * 0.42, h * 0.78);
    final rightBase = Offset(w * 0.64, h * 0.78);

    canvas.drawLine(top, leftBase, towerPaint);
    canvas.drawLine(top, rightBase, towerPaint);
    canvas.drawLine(
      Offset(w * 0.45, h * 0.60),
      Offset(w * 0.61, h * 0.60),
      towerPaint,
    );
    canvas.drawLine(
      Offset(w * 0.47, h * 0.47),
      Offset(w * 0.58, h * 0.47),
      towerPaint,
    );

    final skylinePaint = Paint()
      ..color = color.withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 7; i++) {
      final x = w * (0.04 + i * 0.075);
      final height = h * (0.05 + (i.isEven ? 0.04 : 0.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, h * 0.80 - height, w * 0.045, height),
          const Radius.circular(3),
        ),
        skylinePaint,
      );
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.16, h * 0.70)
      ..cubicTo(w * 0.32, h * 0.54, w * 0.46, h * 0.74, w * 0.60, h * 0.58)
      ..cubicTo(w * 0.72, h * 0.44, w * 0.84, h * 0.52, w * 0.91, h * 0.38);

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawCar(Canvas canvas, Offset center, double size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 1.85, height: size * 0.82),
      Radius.circular(size * 0.28),
    );

    canvas.drawRRect(
      body,
      Paint()
        ..color = AppColors.cardBg.withValues(alpha: 0.92)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      body,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final roof = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.05, center.dy - size * 0.34),
        width: size * 0.98,
        height: size * 0.55,
      ),
      Radius.circular(size * 0.22),
    );

    canvas.drawRRect(
      roof,
      Paint()
        ..color = color.withValues(alpha: 0.13)
        ..style = PaintingStyle.fill,
    );

    final wheelPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas
      ..drawCircle(
        Offset(center.dx - size * 0.55, center.dy + size * 0.40),
        size * 0.15,
        wheelPaint,
      )
      ..drawCircle(
        Offset(center.dx + size * 0.55, center.dy + size * 0.40),
        size * 0.15,
        wheelPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _FindRidePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _EarningsPainter extends CustomPainter {
  const _EarningsPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(w * 0.90, h * 0.12),
      size.shortestSide * 0.35,
      accentPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.12, h * 0.90),
      size.shortestSide * 0.26,
      accentPaint,
    );

    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final y = h * (0.28 + i * 0.18);
      canvas.drawLine(
        Offset(w * 0.70, y),
        Offset(w * 0.92, y - h * 0.07),
        linePaint,
      );
    }

    final coinPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * (0.76 + i * 0.055), h * (0.66 - i * 0.07)),
        9 + i * 1.5,
        coinPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EarningsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _PickupRoutePainter extends CustomPainter {
  const _PickupRoutePainter({
    required this.color,
    required this.borderColor,
    required this.startLabel,
    required this.pickupLabel,
    required this.eventLabel,
    required this.driverRouteLabel,
    required this.sharedArrivalLabel,
  });

  final Color color;
  final Color borderColor;
  final String startLabel;
  final String pickupLabel;
  final String eventLabel;
  final String driverRouteLabel;
  final String sharedArrivalLabel;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawRoadGrid(canvas, size);
    _drawRoute(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.060),
            color.withValues(alpha: 0.030),
            AppColors.cardBg,
          ],
        ).createShader(Offset.zero & size),
    );

    final w = size.width;
    final h = size.height;
    final riverPath = Path()
      ..moveTo(0, h * 0.66)
      ..cubicTo(w * 0.17, h * 0.55, w * 0.31, h * 0.78, w * 0.48, h * 0.65)
      ..cubicTo(w * 0.65, h * 0.52, w * 0.77, h * 0.68, w, h * 0.56)
      ..lineTo(w, h * 0.76)
      ..cubicTo(w * 0.80, h * 0.86, w * 0.63, h * 0.69, w * 0.48, h * 0.80)
      ..cubicTo(w * 0.31, h * 0.92, w * 0.15, h * 0.70, 0, h * 0.82)
      ..close();

    canvas.drawPath(
      riverPath,
      Paint()
        ..color = color.withValues(alpha: 0.055)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawRoadGrid(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final roadPaint = Paint()
      ..color = borderColor.withValues(alpha: 0.45)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    for (var i = 1; i < 6; i++) {
      final y = h * (0.12 + i * 0.12);
      canvas.drawLine(
        Offset(w * 0.08, y),
        Offset(w * 0.92, y + (i.isEven ? h * 0.025 : -h * 0.018)),
        roadPaint,
      );
    }

    for (var i = 1; i < 5; i++) {
      final x = w * (0.13 + i * 0.17);
      canvas.drawLine(
        Offset(x, h * 0.10),
        Offset(x + (i.isEven ? w * 0.05 : -w * 0.04), h * 0.90),
        roadPaint,
      );
    }

    final parkPaint = Paint()
      ..color = color.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;

    final blocks = [
      Rect.fromLTWH(w * 0.08, h * 0.13, w * 0.24, h * 0.18),
      Rect.fromLTWH(w * 0.68, h * 0.15, w * 0.22, h * 0.20),
      Rect.fromLTWH(w * 0.12, h * 0.78, w * 0.25, h * 0.13),
    ];

    for (final block in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(block, const Radius.circular(16)),
        parkPaint,
      );
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final start = Offset(w * 0.16, h * 0.77);
    final pickup = Offset(w * 0.42, h * 0.53);
    final event = Offset(w * 0.80, h * 0.36);

    final route = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(w * 0.22, h * 0.58, w * 0.32, h * 0.61, pickup.dx, pickup.dy)
      ..cubicTo(w * 0.55, h * 0.43, w * 0.66, h * 0.47, event.dx, event.dy);

    canvas.drawPath(
      route,
      Paint()
        ..color = color.withValues(alpha: 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      route,
      Paint()
        ..color = color.withValues(alpha: 0.76)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    _drawMarker(
      canvas,
      start,
      startLabel,
      Icons.home_outlined,
      filled: false,
    );
    _drawMarker(
      canvas,
      pickup,
      pickupLabel,
      Icons.person_pin_circle_outlined,
      filled: true,
    );
    _drawMarker(
      canvas,
      event,
      eventLabel,
      Icons.flag_outlined,
      filled: false,
    );
  }

  void _drawMarker(
    Canvas canvas,
    Offset center,
    String label,
    IconData icon, {
    required bool filled,
  }) {
    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = filled ? color : AppColors.cardBg
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center,
      15,
      Paint()
        ..color = color.withValues(alpha: filled ? 0.0 : 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawText(
      canvas,
      label,
      Offset(center.dx, center.dy + 22),
      color: filled ? color : AppColors.textPrimary,
      fontSize: 10,
      fontWeight: FontWeight.w900,
      align: TextAlign.center,
    );
  }

  void _drawLabels(Canvas canvas, Size size) {
    _drawSoftLabel(
      canvas,
      Offset(size.width * 0.09, size.height * 0.16),
      driverRouteLabel,
    );
    _drawSoftLabel(
      canvas,
      Offset(size.width * 0.58, size.height * 0.71),
      sharedArrivalLabel,
    );
  }

  void _drawSoftLabel(Canvas canvas, Offset offset, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: 0.62),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final rect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      tp.width + 14,
      tp.height + 8,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(999)),
      Paint()
        ..color = AppColors.cardBg.withValues(alpha: 0.72)
        ..style = PaintingStyle.fill,
    );

    tp.paint(canvas, Offset(offset.dx + 7, offset.dy + 4));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    )..layout();

    final dx = align == TextAlign.center ? offset.dx - tp.width / 2 : offset.dx;
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _PickupRoutePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.startLabel != startLabel ||
        oldDelegate.pickupLabel != pickupLabel ||
        oldDelegate.eventLabel != eventLabel ||
        oldDelegate.driverRouteLabel != driverRouteLabel ||
        oldDelegate.sharedArrivalLabel != sharedArrivalLabel;
  }
}

class _TrustPainter extends CustomPainter {
  const _TrustPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(w * 0.88, h * 0.16),
      size.shortestSide * 0.32,
      accentPaint,
    );
    canvas.drawCircle(
      Offset(w * 0.08, h * 0.88),
      size.shortestSide * 0.25,
      accentPaint,
    );

    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * 0.72, h * 0.38),
        size.shortestSide * (0.14 + i * 0.08),
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrustPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter({
    required this.color,
    required this.filled,
  });

  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.50, h * 0.05)
      ..cubicTo(w * 0.70, h * 0.10, w * 0.82, h * 0.18, w * 0.88, h * 0.24)
      ..lineTo(w * 0.82, h * 0.67)
      ..cubicTo(w * 0.78, h * 0.82, w * 0.64, h * 0.91, w * 0.50, h * 0.97)
      ..cubicTo(w * 0.36, h * 0.91, w * 0.22, h * 0.82, w * 0.18, h * 0.67)
      ..lineTo(w * 0.12, h * 0.24)
      ..cubicTo(w * 0.18, h * 0.18, w * 0.30, h * 0.10, w * 0.50, h * 0.05)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = filled
            ? color.withValues(alpha: 0.90)
            : color.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: filled ? 0.0 : 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.filled != filled;
  }
}
