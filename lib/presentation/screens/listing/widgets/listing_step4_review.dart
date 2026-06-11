import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../data/models/listing_form_data.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/common/wave_card.dart';
import '../../../../core/constants/app_spacing.dart';

class ListingStep4Review extends StatelessWidget {
  final ListingFormData formData;
  final Function(ListingFormData) onUpdate;
  final List<String> stepErrors;
  const ListingStep4Review({super.key, required this.formData, required this.onUpdate, this.stepErrors = const []});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.paddingLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, l10n.listingSummary),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _summaryCard(context, l10n.listingSummaryProperty,
                      '${formData.type == 'house' ? l10n.listingHouse : l10n.listingLand}\n${_getLocalizedHouseType(formData.houseType, l10n)}',
                      icon: formData.type == 'house' ? Icons.home_rounded : Icons.landscape_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryCard(context, l10n.listingLocation,
                      '${[formData.addressKebele, formData.addressWoreda].where((e) => e != null && e.isNotEmpty).join(', ')}\n${[formData.addressZone, formData.addressRegion].where((e) => e != null && e.isNotEmpty).join(', ')}',
                      icon: Icons.location_on_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _summaryCard(context, l10n.listingFinancial,
                      '${formData.priceFixed != null ? "${_formatPrice(formData.priceFixed!)} ETB" : l10n.listingPriceOnRequest}\n${_getLocalizedHoldingType(formData.holdingType, l10n)}',
                      icon: Icons.account_balance_wallet_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryCard(context, l10n.listingStepMedia,
                      _buildMediaSummary(formData),
                      icon: Icons.photo_library_rounded)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (formData.description != null) ...[
            _sectionTitle(context, l10n.listingDescriptionLabel),
            const SizedBox(height: 4),
            Text(formData.description!,
                style: AppTextStyles.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: formData.isVip,
                  onChanged: (v) => onUpdate(formData.copyWith(isVip: v ?? false)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onUpdate(formData.copyWith(isVip: !formData.isVip)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.diamond, size: 16, color: AppColors.vip),
                          const SizedBox(width: 4),
                          Text('Mark as VIP', style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.vip,
                            letterSpacing: 0.3,
                          )),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Get a VIP badge for premium visibility', style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: formData.termsAccepted,
                  onChanged: (v) => onUpdate(formData.copyWith(termsAccepted: v ?? false)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => onUpdate(formData.copyWith(termsAccepted: !formData.termsAccepted)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.listingAcceptTerms, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700, color: context.theme.textSecondary, letterSpacing: 0.3)),
                      const SizedBox(height: 2),
                      Text(l10n.listingTermsSubtitle, style: AppTextStyles.bodySmall.copyWith(color: context.theme.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(title,
        style: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ));
  }

  Widget _summaryCard(BuildContext context, String title, String content, {IconData? icon}) {
    return WaveCard(
      isGlass: true,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: context.theme.textSecondary),
                const SizedBox(width: 6),
              ],
              Text(title,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.theme.textSecondary,
                  )),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
              child: Text(content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.theme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  String _buildMediaSummary(ListingFormData data) {
    final imageCount = data.images.length + data.existingImages.length - data.removedImageIds.length;
    final hasSitePlan = data.sitePlan != null || (data.existingSitePlanUrl != null && !data.removeExistingSitePlan);
    final hasOwnership = data.ownershipProof != null || data.existingOwnershipProofUrl != null;
    final hasVideo = data.videoFile != null || (data.existingVideoUrl != null && !data.deleteVideo);
    final lines = <String>[
      '$imageCount ${imageCount == 1 ? 'Picture' : 'Pictures'}',
      if (hasSitePlan) '1 Site Plan',
      if (hasOwnership) '1 Ownership Proof',
      if (hasVideo) '1 Video',
    ];
    return lines.join('\n');
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _getLocalizedHouseType(String? type, AppLocalizations l10n) {
    if (type == null) return '';
    switch (type) {
      case 'villa': return l10n.listingVilla;
      case 'apartment': return l10n.listingApartment;
      case 'condominium': return l10n.listingCondominium;
      case 'townhouse': return l10n.listingTownhouse;
      case 'bungalow': return l10n.listingBungalow;
      default: return type;
    }
  }

  String _getLocalizedHoldingType(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Free Hold': return l10n.listingFreeHold;
      case 'Lease Hold': return l10n.listingLeaseHold;
      case 'Cooperative': return l10n.listingCooperative;
      default: return type;
    }
  }
}
