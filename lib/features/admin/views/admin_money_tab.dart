import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/widgets/empty_state_widget.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
// ── Money ────────────────────────────────────────────────────────────────────

class AdminMoneyTab extends StatelessWidget {
  const AdminMoneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: AppColors.surface,
            child: TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context).paymentsTitle),
                Tab(text: AppLocalizations.of(context).refundsQueue),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [_PaymentsList(), _RefundsQueue()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentsList extends ConsumerWidget {
  const _PaymentsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(adminPaymentsProvider);
    return payments.when(
      loading: () => const SkeletonLoader(),
      error: (e, _) => EmptyStateWidget(title: e.toString(), icon: Icons.error_outline),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: AppLocalizations.of(context).noResults,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPaymentsProvider),
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: rows.length,
            separatorBuilder: (_, _) => SizedBox(height: 6.h),
            itemBuilder: (context, i) {
              final p = rows[i];
              final cents = (p['amountInCents'] as num?) ?? 0;
              return ListTile(
                leading: const Icon(Icons.receipt_rounded),
                title: Text('€${(cents / 100).toStringAsFixed(2)}'),
                subtitle: Text(
                  '${p['status'] ?? ''} · ${p['riderName'] ?? p['riderId'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RefundsQueue extends ConsumerWidget {
  const _RefundsQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refunds = ref.watch(adminRefundRequestsProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return refunds.when(
      loading: () => const SkeletonLoader(),
      error: (e, _) => EmptyStateWidget(title: e.toString(), icon: Icons.error_outline),
      data: (issues) {
        if (issues.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: AppLocalizations.of(context).noResults,
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminRefundRequestsProvider),
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: issues.length,
            separatorBuilder: (_, _) => SizedBox(height: 8.h),
            itemBuilder: (context, i) {
              final issue = issues[i];
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(issue.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppColors.textSecondary)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => repo.rejectRefundRequest(
                              refundRequestId: issue.id,
                            ),
                            child: Text(AppLocalizations.of(context).reject),
                          ),
                          FilledButton(
                            onPressed: () => repo.approveRefundRequest(
                              refundRequestId: issue.id,
                            ),
                            child: Text(AppLocalizations.of(context).approve),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── More hub ─────────────────────────────────────────────────────────────────
