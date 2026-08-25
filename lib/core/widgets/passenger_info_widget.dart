import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Base widget that fetches passenger data and provides it to a builder
/// Following database normalization - no denormalized passenger data in models
class PassengerInfoWidget extends ConsumerWidget {
  const PassengerInfoWidget({
    required this.passengerId,
    required this.builder,
    super.key,
  });
  final String passengerId;
  final Widget Function(BuildContext context, UserModel passenger) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        if (passenger == null) {
          return Text(AppLocalizations.of(context).passengerNotFound);
        }
        return builder(context, passenger);
      },
      loading: () => const CircularProgressIndicator.adaptive(),
      error: (_, _) => Text(AppLocalizations.of(context).errorLoadingPassenger),
    );
  }
}

/// Displays passenger name with loading/error states
class PassengerNameWidget extends ConsumerWidget {
  const PassengerNameWidget({
    required this.passengerId,
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
  });
  final String passengerId;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) => Text(
        passenger?.username ?? AppLocalizations.of(context).unknown,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
      loading: () => Text(
        AppLocalizations.of(context).loading,
        style: style?.copyWith(color: AppColors.textTertiary),
        maxLines: maxLines,
        overflow: overflow,
      ),
      error: (_, _) => Text(
        AppLocalizations.of(context).unknown,
        style: style?.copyWith(color: AppColors.error),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Displays passenger avatar with loading/error states
class PassengerAvatarWidget extends ConsumerWidget {
  const PassengerAvatarWidget({
    required this.passengerId,
    super.key,
    this.radius = 20,
  });
  final String passengerId;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        final photoUrl = passenger?.photoUrl;
        final username =
            passenger?.username ?? AppLocalizations.of(context).unknown;

        return CircleAvatar(
          radius: radius,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          backgroundColor: AppColors.primarySurface,
          child: photoUrl == null
              ? Text(
                  username.isNotEmpty ? username[0] : '?',
                  style: TextStyle(
                    fontSize: radius * 0.7,
                    color: AppColors.primary,
                  ),
                )
              : null,
        );
      },
      loading: () => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        child: SizedBox(
          width: radius * 0.7,
          height: radius * 0.7,
          child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
      error: (_, _) => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        child: Icon(Icons.error, size: radius * 0.7, color: AppColors.error),
      ),
    );
  }
}

/// Displays passenger phone number with loading/error states
class PassengerPhoneWidget extends ConsumerWidget {
  const PassengerPhoneWidget({
    required this.passengerId,
    super.key,
    this.style,
  });
  final String passengerId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));
    return passengerAsync.when(
      data: (passenger) => Text(
        passenger?.asRider?.phoneNumber ?? AppLocalizations.of(context).noPhone,
        style: style,
      ),
      loading: () => Text(
        AppLocalizations.of(context).loading,
        style: style?.copyWith(color: AppColors.textTertiary),
      ),
      error: (_, _) => Text(
        AppLocalizations.of(context).notAvailableShort,
        style: style?.copyWith(color: AppColors.error),
      ),
    );
  }
}

