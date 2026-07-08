import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/services/report_service.dart';
import '../../../../l10n/app_localizations.dart';

class ListingReportSheet extends ConsumerStatefulWidget {
  final int listingId;

  const ListingReportSheet({super.key, required this.listingId});

  @override
  ConsumerState<ListingReportSheet> createState() => _ListingReportSheetState();
}

class _ListingReportSheetState extends ConsumerState<ListingReportSheet> {
  String? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  static const _reasons = [
    'spam',
    'fake',
    'wrong_category',
    'duplicate',
    'inappropriate',
    'other',
  ];

  String _reasonLabel(AppLocalizations l10n, String reason) {
    return switch (reason) {
      'spam' => l10n.reportSpam,
      'fake' => l10n.reportFake,
      'wrong_category' => l10n.reportWrongCategory,
      'duplicate' => l10n.reportDuplicate,
      'inappropriate' => l10n.reportInappropriate,
      'other' => l10n.reportOther,
      _ => reason,
    };
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    final service = ReportService();
    final response = await service.submitReport(
      reportableType: 'listing',
      reportableId: widget.listingId,
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    if (response.success) {
      setState(() => _isSubmitted = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message.isNotEmpty
              ? response.message
              : AppLocalizations.of(context).reportErrorGeneric),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.primary800 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: context.theme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  l10n.reportListing,
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.reportReason,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedReason,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: context.theme.divider),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    hint: Text(l10n.reportSelectReason),
                  ),
                  items: _reasons.map((r) {
                    return DropdownMenuItem(
                      value: r,
                      child: Text(_reasonLabel(l10n, r)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedReason = v),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.reportDescription,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText: l10n.reportDescriptionHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: context.theme.divider),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isSubmitted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.reportSuccess,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedReason != null && !_isSubmitting)
                          ? _submit
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        _isSubmitting ? l10n.reportSubmitting : l10n.reportSubmit,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
