import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/utils/responsive_utils.dart';
import 'package:sport_connect/features/profile/view_models/help_center_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Help Center screen with FAQ sections and support access.
///
/// Features:
/// - Searchable FAQ categories
/// - Expandable Q&A sections
/// - Quick links to contact support and report issues
class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  List<_FAQCategory> _faqCategories(AppLocalizations l10n) => [
    _FAQCategory(
      title: l10n.getting_started,
      icon: Icons.rocket_launch_rounded,
      color: const Color(0xFF4CAF50),
      questions: [
        _FAQ(
          l10n.helpCenterGettingStartedCreateAccountQuestion,
          l10n.helpCenterGettingStartedCreateAccountAnswer,
        ),
        _FAQ(
          l10n.helpCenterGettingStartedSwitchRoleQuestion,
          l10n.helpCenterGettingStartedSwitchRoleAnswer,
        ),
        _FAQ(
          l10n.helpCenterGettingStartedFreeQuestion,
          l10n.helpCenterGettingStartedFreeAnswer,
        ),
      ],
    ),
    _FAQCategory(
      title: l10n.rides_booking,
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF2196F3),
      questions: [
        _FAQ(
          l10n.helpCenterRidesBookingQuestion,
          l10n.helpCenterRidesBookingAnswer,
        ),
        _FAQ(
          l10n.helpCenterRidesCancelQuestion,
          l10n.helpCenterRidesCancelAnswer,
        ),
        _FAQ(
          l10n.helpCenterRidesMatchingQuestion,
          l10n.helpCenterRidesMatchingAnswer,
        ),
        _FAQ(
          l10n.helpCenterRidesLateQuestion,
          l10n.helpCenterRidesLateAnswer,
        ),
      ],
    ),
    _FAQCategory(
      title: l10n.payments,
      icon: Icons.payment_rounded,
      color: const Color(0xFFFF9800),
      questions: [
        _FAQ(
          l10n.helpCenterPaymentsQuestion,
          l10n.helpCenterPaymentsAnswer,
        ),
        _FAQ(
          l10n.helpCenterPayoutsQuestion,
          l10n.helpCenterPayoutsAnswer,
        ),
        _FAQ(
          l10n.helpCenterFeesQuestion,
          l10n.helpCenterFeesAnswer,
        ),
      ],
    ),
    _FAQCategory(
      title: l10n.safety_trust,
      icon: Icons.shield_rounded,
      color: const Color(0xFFF44336),
      questions: [
        _FAQ(
          l10n.helpCenterSafetyQuestion,
          l10n.helpCenterSafetyAnswer,
        ),
        _FAQ(
          l10n.helpCenterSafetyReportQuestion,
          l10n.helpCenterSafetyReportAnswer,
        ),
        _FAQ(
          l10n.helpCenterSafetyShareQuestion,
          l10n.helpCenterSafetyShareAnswer,
        ),
      ],
    ),
    _FAQCategory(
      title: l10n.account_profile,
      icon: Icons.person_rounded,
      color: const Color(0xFF9C27B0),
      questions: [
        _FAQ(
          l10n.helpCenterAccountVerifyQuestion,
          l10n.helpCenterAccountVerifyAnswer,
        ),
        _FAQ(
          l10n.helpCenterAccountDeleteQuestion,
          l10n.helpCenterAccountDeleteAnswer,
        ),
        _FAQ(
          l10n.helpCenterAccountEmailQuestion,
          l10n.helpCenterAccountEmailAnswer,
        ),
      ],
    ),
  ];

  List<_FAQCategory> _filteredCategories(
    String searchQuery,
    AppLocalizations l10n,
  ) {
    final faqCategories = _faqCategories(l10n);
    if (searchQuery.isEmpty) return faqCategories;
    final normalizedQuery = searchQuery.toLowerCase();
    return faqCategories
        .map((cat) {
          final filteredQuestions = cat.questions
              .where(
                (q) =>
                    q.question.toLowerCase().contains(normalizedQuery) ||
                    q.answer.toLowerCase().contains(normalizedQuery),
              )
              .toList();
          if (filteredQuestions.isEmpty) return null;
          return _FAQCategory(
            title: cat.title,
            icon: cat.icon,
            color: cat.color,
            questions: filteredQuestions,
          );
        })
        .whereType<_FAQCategory>()
        .toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uiState = ref.watch(helpCenterUiViewModelProvider);
    final filteredCategories = _filteredCategories(uiState.searchQuery, l10n);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        useNativeToolbar: false,
        title: l10n.settingsHelpCenter,
        leading: IconButton(
          tooltip: l10n.goBackTooltip,
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: MaxWidthContainer(
        maxWidth: kMaxWidthContent,
        child: SingleChildScrollView(
          padding: adaptiveScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              // Search bar
              _HelpCenterSearchField(
                initialQuery: uiState.searchQuery,
                onChanged: ref
                    .read(helpCenterUiViewModelProvider.notifier)
                    .setSearchQuery,
                onClear: ref
                    .read(helpCenterUiViewModelProvider.notifier)
                    .clearSearch,
                fieldKey: uiState.searchFieldKey,
              ).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 20.h),

              // Quick actions
              _buildQuickActions(
                context,
                l10n,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05),

              SizedBox(height: 28.h),

              // FAQ sections
              Text(
                l10n.frequentlyAskedQuestions,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ).animate().fadeIn(delay: 200.ms),

              SizedBox(height: 16.h),

              ...filteredCategories.asMap().entries.map((entry) {
                return _buildFAQSection(context, entry.value)
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 250 + (entry.key * 100)),
                    )
                    .slideY(begin: 0.03);
              }),

              if (filteredCategories.isEmpty)
                _buildEmptySearch(context).animate().fadeIn(duration: 300.ms),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildQuickActionCard(
          icon: Icons.support_agent_rounded,
          label: l10n.contactSupport,
          color: AppColors.primary,
          onTap: () => context.push(AppRoutes.contactSupport.path),
        ),
        SizedBox(width: 12.w),
        _buildQuickActionCard(
          icon: Icons.bug_report_rounded,
          label: l10n.settingsReportProblem,
          color: AppColors.warning,
          onTap: () => context.push(AppRoutes.reportIssue.path),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28.sp),
              SizedBox(height: 10.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, _FAQCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: AdaptiveExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(category.icon, color: category.color, size: 22.sp),
          ),
          title: Text(
            category.title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            '${category.questions.length} ${AppLocalizations.of(context).articles}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
          ),
          children: category.questions.map((faq) {
            return _buildFAQItem(context, faq);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, _FAQ faq) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: AdaptiveExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Text(
              faq.answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              AppLocalizations.of(context).noResultsFound,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              AppLocalizations.of(context).tryDifferentKeywordsOrContactSupport,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful widget that owns the [TextEditingController] for the help-center
/// search field. The outer screen is a [ConsumerWidget] (no State), so this
/// encapsulates the controller lifecycle. [fieldKey] changes (from the view
/// model's `clearSearch` action) force the field to remount, resetting its
/// controller text — the canonical reactive pattern when you cannot use a
/// [Form].
class _HelpCenterSearchField extends StatefulWidget {
  const _HelpCenterSearchField({
    required this.initialQuery,
    required this.onChanged,
    required this.onClear,
    required this.fieldKey,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final int fieldKey;

  @override
  State<_HelpCenterSearchField> createState() => _HelpCenterSearchFieldState();
}

class _HelpCenterSearchFieldState extends State<_HelpCenterSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: l10n.searchHelpArticles,
        hintText: l10n.searchHelpArticles,
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textTertiary),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.textSecondary,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                tooltip: l10n.clearSearchTooltip,
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                  setState(() {});
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}

class _FAQCategory {
  const _FAQCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.questions,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<_FAQ> questions;
}

class _FAQ {
  const _FAQ(this.question, this.answer);
  final String question;
  final String answer;
}
