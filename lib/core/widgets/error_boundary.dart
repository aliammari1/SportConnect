import 'package:flutter/material.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
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

  void _handleError(FlutterErrorDetails details) {
    // Report to the framework as usual (Crashlytics, console, etc.).
    FlutterError.presentError(details);
    widget.onError?.call(details);

    // Schedule the fallback rebuild for after the current build/layout pass,
    // since errors are typically raised while building a descendant.
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _errorDetails == null) {
        setState(() {
          _errorDetails = details;
        });
      }
    });
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

    // Install a scoped error widget builder so a build failure in a descendant
    // is captured here (and reported) instead of tearing down the subtree.
    return _ErrorBoundaryScope(
      onError: _handleError,
      child: widget.child,
    );
  }
}

/// Installs a scoped [ErrorWidget.builder] for the lifetime of [child] so that
/// build-phase errors in descendants are reported to [onError] and rendered as
/// an inert placeholder instead of the red error box / a crash.
class _ErrorBoundaryScope extends StatefulWidget {
  const _ErrorBoundaryScope({
    required this.child,
    required this.onError,
  });

  final Widget child;
  final ValueSetter<FlutterErrorDetails> onError;

  @override
  State<_ErrorBoundaryScope> createState() => _ErrorBoundaryScopeState();
}

class _ErrorBoundaryScopeState extends State<_ErrorBoundaryScope> {
  late final ErrorWidgetBuilder _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      widget.onError(details);
      // Return an inert placeholder; the boundary will swap in the fallback UI.
      return const SizedBox.shrink();
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousBuilder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pleaseTryAgainLater,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
