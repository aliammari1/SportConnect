import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/app_modal_sheet.dart';
import 'package:sport_connect/core/widgets/empty_state_widget.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// People lookup: accepts a UID, email, or username prefix. Results come from
/// the server-side admin callable so UID/email lookups are possible (the
/// client-side query could only match username prefixes).
class AdminPeopleTab extends ConsumerStatefulWidget {
  const AdminPeopleTab({super.key});

  @override
  ConsumerState<AdminPeopleTab> createState() => _AdminPeopleTabState();
}

class _AdminPeopleTabState extends ConsumerState<AdminPeopleTab> {
  Timer? _debounce;
  String? _query;

  void _onChanged(String value) {
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      if (mounted) setState(() => _query = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = q);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results =
        _query == null ? null : ref.watch(adminFindUsersProvider(_query!));

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: TextField(
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).peopleSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: results == null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      AppLocalizations.of(context).peopleSearchHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : results.when(
                  loading: () => const SkeletonLoader(),
                  error: (e, _) => EmptyStateWidget(
                    icon: Icons.error_outline,
                    title:
                        AppLocalizations.of(context).somethingWentWrong,
                    subtitle: e.toString(),
                    actionLabel: AppLocalizations.of(context).retry,
                    onAction: () => ref
                        .invalidate(adminFindUsersProvider(_query!)),
                  ),
                  data: (users) {
                    if (users.isEmpty) {
                      return Center(
                        child: EmptyStateWidget(
                          icon: Icons.person_off_outlined,
                          title: AppLocalizations.of(context).noResults,
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: users.length,
                      separatorBuilder: (_, _) => SizedBox(height: 6.h),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final name =
                            (user['name'] as String?) ?? '(unnamed)';
                        final email = (user['email'] as String?) ?? '';
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  (user['photoUrl'] as String?)?.isNotEmpty ==
                                          true
                                      ? NetworkImage(user['photoUrl']! as String)
                                      : null,
                              child: (user['photoUrl'] as String?)
                                      ?.isNotEmpty !=
                                  true
                                  ? Text(name[0].toUpperCase())
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                if (user['isPremium'] == true)
                                  Icon(Icons.workspace_premium_rounded,
                                      size: 16.sp, color: AppColors.primary),
                                if (user['isBanned'] == true)
                                  Icon(Icons.block_rounded,
                                      size: 16.sp, color: AppColors.error),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (email.isNotEmpty)
                                  Text(email,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                Text('UID ${user['uid']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () => _showActions(ref, context, user),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showActions(
    WidgetRef ref,
    BuildContext context,
    Map<String, dynamic> user,
  ) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(adminRepositoryProvider);
    final uid = user['uid'] as String;
    final isPremium = user['isPremium'] == true;

    Future<void> run(Future<void> Function() action) async {
      Navigator.of(context).pop();
      try {
        await action();
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: l10n.configSaved,
          type: AdaptiveSnackBarType.success,
        );
      } on Exception catch (e) {
        if (!context.mounted) return;
        AdaptiveSnackBar.show(
          context,
          message: e.toString(),
          type: AdaptiveSnackBarType.error,
        );
      }
    }

    AppModalSheet.show<void>(
      context: context,
      title: (user['name'] as String?) ?? uid,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(l10n.pushTargetUid),
              subtitle: Text(uid, maxLines: 1),
              onTap: () async {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(
                user['isBanned'] == true
                    ? Icons.lock_open_rounded
                    : Icons.block_rounded,
              ),
              title: Text(
                user['isBanned'] == true
                    ? l10n.actionReinstateUser
                    : l10n.actionSuspendUser,
              ),
              onTap: () => run(() => repo.setUserSuspended(
                    userId: uid,
                    suspended: user['isBanned'] != true,
                  )),
            ),
            ListTile(
              leading: Icon(
                isPremium
                    ? Icons.workspace_premium_rounded
                    : Icons.workspace_premium_outlined,
              ),
              title: Text(isPremium
                  ? l10n.actionRevokePremium
                  : l10n.actionGrantPremium),
              onTap: () =>
                  run(() => repo.setPremiumOverride(userId: uid, premium: !isPremium)),
            ),
            ListTile(
              leading: const Icon(Icons.send_rounded),
              title: Text(l10n.sendPushAction),
              onTap: () => run(() => repo.sendAdminPush(
                    userId: uid,
                    title: l10n.opsConsoleTitle,
                    body: l10n.peopleSearchHint,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

