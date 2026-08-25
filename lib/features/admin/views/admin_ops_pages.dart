import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:sport_connect/core/widgets/empty_state_widget.dart';
import 'package:sport_connect/core/widgets/reactive_adaptive_text_field.dart';
import 'package:sport_connect/core/widgets/skeleton_loader.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';
// ── More hub ─────────────────────────────────────────────────────────────────

class AdminMoreTab extends StatelessWidget {
  const AdminMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    Widget entry(IconData icon, String title, Widget page) => ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => page),
          ),
        );

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        entry(Icons.flag_outlined, AppLocalizations.of(context).reportsQueue,
            const AdminReportsPage()),
        entry(Icons.support_agent_outlined,
            AppLocalizations.of(context).supportInbox, const AdminSupportPage()),
        entry(Icons.send_outlined, AppLocalizations.of(context).broadcastPush,
            const AdminCommsPage()),
        entry(Icons.tune_rounded, AppLocalizations.of(context).platformSettings,
            const AdminSettingsAuditPage()),
      ],
    );
  }
}

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(adminReportsProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).reportsQueue,
      ),
      body: reports.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) =>
            EmptyStateWidget(title: e.toString(), icon: Icons.error_outline),
        data: (rows) => rows.isEmpty
            ? Center(
                child: EmptyStateWidget(
                  icon: Icons.inbox_outlined,
                  title: AppLocalizations.of(context).noResults,
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: rows.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, i) {
                  final r = rows[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text('${r['reason'] ?? r['type'] ?? 'Report'}',
                          maxLines: 1),
                      subtitle: Text(
                        '${r['description'] ?? ''}\n'
                        'target: ${r['reportedUserId'] ?? r['targetId'] ?? '-'}',
                        maxLines: 3,
                      ),
                      isThreeLine: true,
                      trailing: TextButton(
                        onPressed: () => repo.resolveReport(
                          reportId: r['id'] as String? ?? '',
                        ),
                        child: Text(AppLocalizations.of(context).markResolved),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class AdminSupportPage extends ConsumerWidget {
  const AdminSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets = ref.watch(adminSupportTicketsProvider);
    final repo = ref.watch(adminRepositoryProvider);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).supportInbox,
      ),
      body: tickets.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) =>
            EmptyStateWidget(title: e.toString(), icon: Icons.error_outline),
        data: (rows) => rows.isEmpty
            ? Center(
                child: EmptyStateWidget(
                  icon: Icons.inbox_outlined,
                  title: AppLocalizations.of(context).noResults,
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: rows.length,
                separatorBuilder: (_, _) => SizedBox(height: 8.h),
                itemBuilder: (context, i) {
                  final t = rows[i];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(t.title, maxLines: 1),
                      subtitle: Text(t.subtitle, maxLines: 2),
                      trailing: TextButton(
                        onPressed: () => repo.resolveSupportTicket(
                          ticketId: t.id,
                        ),
                        child: Text(AppLocalizations.of(context).markResolved),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}


class AdminCommsPage extends ConsumerStatefulWidget {
  const AdminCommsPage({super.key});

  @override
  ConsumerState<AdminCommsPage> createState() => _AdminCommsPageState();
}

class _AdminCommsPageState extends ConsumerState<AdminCommsPage> {
  late final FormGroup _form;

  @override
  void initState() {
    super.initState();
    _form = FormGroup({
      'userId': FormControl<String>(
        validators: [Validators.required, Validators.minLength(2)],
      ),
      'title': FormControl<String>(
        validators: [Validators.required, Validators.minLength(3)],
      ),
      'body': FormControl<String>(
        validators: [Validators.required, Validators.minLength(3)],
      ),
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(adminRepositoryProvider).sendAdminPush(
            userId: _form.control('userId').value as String? ?? '',
            title: _form.control('title').value as String? ?? '',
            body: _form.control('body').value as String? ?? '',
          );
      if (!mounted) return;
      _form.reset();
      AdaptiveSnackBar.show(
        context,
        message: l10n.configSaved,
        type: AdaptiveSnackBarType.success,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.toString(),
        type: AdaptiveSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).broadcastPush,
      ),
      body: ReactiveForm(
        formGroup: _form,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            AdaptiveReactiveTextField(
              formControlName: 'userId',
              labelText: l10n.pushTargetUid,
            ),
            SizedBox(height: 10.h),
            AdaptiveReactiveTextField(
              formControlName: 'title',
              labelText: l10n.pushTitleHint,
            ),
            SizedBox(height: 10.h),
            AdaptiveReactiveTextField(
              formControlName: 'body',
              labelText: l10n.pushBodyHint,
              maxLines: 4,
              minLines: 3,
            ),
            SizedBox(height: 16.h),
            ReactiveFormConsumer(
              builder: (context, formGroup, _) => FilledButton.icon(
                onPressed: formGroup.valid ? _send : null,
                icon: const Icon(Icons.send_rounded),
                label: Text(l10n.sendPushAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsAuditPage extends ConsumerStatefulWidget {
  const AdminSettingsAuditPage({super.key});

  @override
  ConsumerState<AdminSettingsAuditPage> createState() =>
      _AdminSettingsAuditPageState();
}

class _AdminSettingsAuditPageState
    extends ConsumerState<AdminSettingsAuditPage> {
  late final FormGroup _form;
  bool _maintenance = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(platformConfigProvider).value ?? const {};
    _form = FormGroup({
      'commissionPercent': FormControl<String>(
        value: config['commissionPercent']?.toString(),
        validators: [Validators.number()]
      ),
      'refundWindowDays': FormControl<String>(
        value: config['refundWindowDays']?.toString(),
        validators: [Validators.number()]
      ),
    });
    _maintenance = config['maintenanceMode'] == true;
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_form.invalid) {
      _form.markAllAsTouched();
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).setPlatformConfig(
            commissionPercent:
                int.tryParse(_form.control('commissionPercent').value as String? ?? ''),
            refundWindowDays:
                int.tryParse(_form.control('refundWindowDays').value as String? ?? ''),
            maintenanceMode: _maintenance,
          );
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: l10n.configSaved,
        type: AdaptiveSnackBarType.success,
      );
    } on Exception catch (e) {
      if (!mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: e.toString(),
        type: AdaptiveSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final audit = ref.watch(adminAuditProvider);
    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: AppLocalizations.of(context).platformSettings,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          ReactiveForm(
            formGroup: _form,
            child: Column(
              children: [
                AdaptiveReactiveTextField(
                  formControlName: 'commissionPercent',
                  labelText: l10n.commissionPercent,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.h),
                AdaptiveReactiveTextField(
                  formControlName: 'refundWindowDays',
                  labelText: l10n.refundWindowDays,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.maintenanceMode),
            value: _maintenance,
            onChanged: (v) => setState(() => _maintenance = v),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_rounded),
            label: Text(l10n.configSaved),
          ),
          SizedBox(height: 20.h),
          Text(l10n.auditLog,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 6.h),
          audit.when(
            loading: () => const SkeletonLoader(),
            error: (e, _) => Text(e.toString()),
            data: (rows) => Column(
              children: [
                for (final row in rows.take(30))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.history_rounded, size: 18),
                    title: Text('${row['action']} · ${row['targetId']}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('by ${row['adminUid']}',
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





