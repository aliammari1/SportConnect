import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/core/providers/user_providers.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/events/view_models/event_participants_view_model.dart';
import 'package:sport_connect/features/events/view_models/event_view_model.dart';
import 'package:sport_connect/features/messaging/view_models/chat_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

class EventAttendeesScreen extends ConsumerWidget {
  const EventAttendeesScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        leading: IconButton(
          icon: Icon(Icons.adaptive.arrow_back_rounded, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: eventAsync.value != null
            ? '${l10n.eventParticipants} (${eventAsync.value!.participantIds.length})'
            : l10n.eventParticipants,
      ),
      body: MaxWidthContainer(
        child: eventAsync.when(
          loading: () => const SkeletonLoader(
            type: SkeletonType.profileCard,
            itemCount: 5,
          ),
          error: (e, _) => Center(
            child: Text(
              l10n.errorLoadingData,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          data: (event) {
            if (event == null || event.participantIds.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.group_off_rounded,
                      size: 48.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      l10n.noResultsFound,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }
            // Batch-fetch every attendee profile through a single provider
            // (chunked whereIn) instead of one document listener per card.
            final profilesAsync = ref.watch(
              eventParticipantProfilesProvider(
                eventParticipantProfilesKey(event.participantIds),
              ),
            );
            final profiles = profilesAsync.value ?? const <String, UserModel>{};

            return ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              itemCount: event.participantIds.length,
              separatorBuilder: (_, _) => SizedBox(height: 8.h),
              itemBuilder: (context, i) {
                final userId = event.participantIds[i];
                return _AttendeeCard(
                  userId: userId,
                  eventId: eventId,
                  profile: profiles[userId],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AttendeeCurrentUser {
  const _AttendeeCurrentUser({
    required this.uid,
    required this.username,
    this.photoUrl,
  });

  factory _AttendeeCurrentUser.from(UserModel user) {
    return _AttendeeCurrentUser(
      uid: user.uid,
      username: user.username,
      photoUrl: user.photoUrl,
    );
  }

  final String uid;
  final String username;
  final String? photoUrl;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _AttendeeCurrentUser &&
            other.uid == uid &&
            other.username == username &&
            other.photoUrl == photoUrl;
  }

  @override
  int get hashCode => Object.hash(uid, username, photoUrl);
}

class _AttendeeCard extends ConsumerWidget {
  const _AttendeeCard({
    required this.userId,
    required this.eventId,
    required this.profile,
  });

  final String userId;
  final String eventId;

  /// Resolved profile from the batched [eventParticipantProfilesProvider];
  /// null while the batch is still loading or if the user document is missing.
  final UserModel? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(
      currentUserProvider.select((value) {
        final user = value.value;
        return user == null ? null : _AttendeeCurrentUser.from(user);
      }),
    );
    final isSelf = currentUser?.uid == userId;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primarySurface,
            backgroundImage: profile?.photoUrl != null
                ? CachedNetworkImageProvider(profile!.photoUrl!)
                : null,
            child: profile?.photoUrl == null
                ? Icon(
                    Icons.person_rounded,
                    size: 22.sp,
                    color: AppColors.primary,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          // Name + expertise + rating
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile?.username ?? '…',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelf) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          AppLocalizations.of(context).you,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (profile?.expertise != null) ...[
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        profile!.expertise.displayName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Icon(
                      Icons.star_rounded,
                      size: 12.sp,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      (switch (profile) {
                        final RiderModel rider => rider.rating.average,
                        final DriverModel driver => driver.rating.average,
                        _ => 0.0,
                      }).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Message button (skip for self)
          if (!isSelf)
            IconButton(
              onPressed: () => _openChat(context, ref, profile, currentUser),
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
              tooltip: AppLocalizations.of(context).messageButton,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                padding: EdgeInsets.all(8.w),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    WidgetRef ref,
    UserModel? profile,
    _AttendeeCurrentUser? currentUser,
  ) async {
    if (profile == null || currentUser == null) return;
    try {
      final chat = await ref.read(
        getOrCreateChatProvider(
          userId1: currentUser.uid,
          userId2: userId,
          userName1: currentUser.username,
          userName2: profile.username,
          userPhoto1: currentUser.photoUrl,
          userPhoto2: profile.photoUrl,
        ).future,
      );
      if (!context.mounted) return;
      await context.pushNamed(
        AppRoutes.chatDetail.name,
        pathParameters: {'id': chat.id},
        extra: profile,
      );
    } on Exception {
      if (context.mounted) {
        AdaptiveSnackBar.show(
          context,
          message: AppLocalizations.of(context).failedOpenChatError,
          type: AdaptiveSnackBarType.error,
        );
      }
    }
  }
}
