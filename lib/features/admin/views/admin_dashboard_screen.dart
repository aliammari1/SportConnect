import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/providers/admin_access_provider.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/locale_formatters.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final access = ref.watch(adminAccessProvider);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.adminDashboard,
      ),
      body: access.when(
        data: (allowed) {
          if (!allowed) {
            return Center(child: Text(l10n.adminAccessRequired));
          }
          return const MaxWidthContainer(
            maxWidth: kMaxWidthWide,
            child: _AdminDashboardBody(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text(l10n.adminAccessCheckFailed(error.toString()))),
      ),
    );
  }
}

class _AdminDashboardBody extends ConsumerWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              tabs: [
                Tab(text: l10n.refundsTab),
                Tab(text: l10n.disputesTab),
                Tab(text: l10n.supportTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _IssueList(
                  issues: ref.watch(adminRefundRequestsProvider),
                  emptyText: l10n.noRefundRequests,
                  type: _IssueType.refund,
                ),
                _IssueList(
                  issues: ref.watch(adminDisputesProvider),
                  emptyText: l10n.noDisputes,
                  type: _IssueType.dispute,
                ),
                _IssueList(
                  issues: ref.watch(adminSupportTicketsProvider),
                  emptyText: l10n.noSupportTickets,
                  type: _IssueType.support,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _IssueType { refund, dispute, support }

class _IssueList extends ConsumerWidget {
  const _IssueList({
    required this.issues,
    required this.emptyText,
    required this.type,
  });

  final AsyncValue<List<AdminIssue>> issues;
  final String emptyText;
  final _IssueType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return issues.when(
      data: (items) {
        if (items.isEmpty) return Center(child: Text(emptyText));
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            switch (type) {
              case _IssueType.refund:
                ref.invalidate(adminRefundRequestsProvider);
              case _IssueType.dispute:
                ref.invalidate(adminDisputesProvider);
              case _IssueType.support:
                ref.invalidate(adminSupportTicketsProvider);
            }
          },
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) => _IssueTile(
              issue: items[index],
              type: type,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          AppLocalizations.of(context).adminCouldNotLoadIssues(
            error.toString(),
          ),
        ),
      ),
    );
  }
}

class _IssueTile extends ConsumerWidget {
  const _IssueTile({required this.issue, required this.type});

  final AdminIssue issue;
  final _IssueType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = issue.createdAt == null
        ? ''
        : AppLocaleFormatters.formatMonthDayTime(context, issue.createdAt!);
    final needsAction = _isOpen(issue.status);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(status: issue.status),
            ],
          ),
          if (date.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              date,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            issue.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (type == _IssueType.refund && needsAction)
                _ActionButton(
                  label: AppLocalizations.of(context).adminApproveRefund,
                  icon: Icons.undo_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .approveRefundRequest(
                          refundRequestId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.refund && needsAction)
                _ActionButton(
                  label: AppLocalizations.of(context).adminReject,
                  icon: Icons.close_rounded,
                  isDestructive: true,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .rejectRefundRequest(
                          refundRequestId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.dispute && needsAction)
                _ActionButton(
                  label: AppLocalizations.of(context).adminRefund,
                  icon: Icons.undo_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .approveDisputeRefund(
                          disputeId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.dispute && needsAction)
                _ActionButton(
                  label: AppLocalizations.of(context).actionClose,
                  icon: Icons.done_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .rejectDispute(
                          disputeId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.support && needsAction)
                _ActionButton(
                  label: AppLocalizations.of(context).adminResolve,
                  icon: Icons.done_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .resolveSupportTicket(
                          ticketId: issue.id,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isOpen(String status) {
    return !{
      'resolved',
      'closed',
      'rejected',
      'refunded',
      'partiallyRefunded',
      'done',
      'completed',
    }.contains(status);
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: AppLocalizations.of(context).actionUpdated,
        type: AdaptiveSnackBarType.success,
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: error.toString(),
        type: AdaptiveSnackBarType.error,
      );
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;
  final bool isDestructive;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _busy = false;

  Future<void> _handlePressed() async {
    // Re-entry guard: ignore taps while a previous action is in flight to
    // prevent duplicate money-moving submissions on rapid double-taps.
    if (_busy) return;

    final l10n = AppLocalizations.of(context);
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.actionConfirm),
        content: Text(widget.label),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.actionConfirm,
              style: widget.isDestructive
                  ? const TextStyle(color: AppColors.error)
                  : null,
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : _handlePressed,
      icon: _busy
          ? SizedBox(
              width: 16.sp,
              height: 16.sp,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(widget.icon, size: 16.sp),
      label: Text(widget.label),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.isDestructive
            ? AppColors.error
            : AppColors.primary,
        side: BorderSide(
          color: widget.isDestructive ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }
}
