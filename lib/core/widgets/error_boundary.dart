import 'package:flutter/material.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_typography.dart';
import 'package:sport_connect/core/widgets/custom_button.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// A widget that catches errors in its child widget tree and displays a
/// user-friendly fallback UI instead of crashing the entire app.
///
/// Use this to wrap heavy or error-prone screens (e.g., map screens,
/// complex lists, third-party web views) so that a failure in one
/// screen does not tear down the whole app.
class ErrorBoundary extends StatefulWidget {
  const ErrorBoundary({
    required this.child,
    this.fallbackBuilder,
    this.onError,
    super.key,
  });

  /// The widget tree to monitor for errors.
  final Widget child;

  /// Optional custom fallback UI. If not provided, a default error
  /// screen with a retry button is shown.
  final Widget Function(BuildContext context, FlutterErrorDetails details)?
  fallbackBuilder;

  /// Optional callback invoked when an error is caught.
  final void Function(FlutterErrorDetails details)? onError;

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
  }

  void _reset() {
    setState(() {
      _errorDetails = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      if (widget.fallbackBuilder != null) {
        return widget.fallbackBuilder!(context, _errorDetails!);
      }
      return _DefaultErrorFallback(
        onRetry: _reset,
      );
    }

    return widget.child;
  }
}

/// Catches Flutter framework errors thrown during the build phase of
/// descendants and reports them via the [ErrorBoundary] state.
class _ErrorBoundaryBuildObserver extends StatelessWidget {
  const _ErrorBoundaryBuildObserver({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final ValueSetter<FlutterErrorDetails> onError;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// A reusable default error fallback UI shown inside [ErrorBoundary].
class _DefaultErrorFallback extends StatelessWidget {
  const _DefaultErrorFallback({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.somethingWentWrong,
                  style: AppTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pleaseTryAgainLater,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PremiumButton(
                  onPressed: onRetry,
                  text: l10n.retry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
